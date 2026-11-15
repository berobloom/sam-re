"""pasgen.py DIS SEG START END [--name=bp+8:X ...] [--epi=XXXX] -> Pascal statements for TP 5.0 code.

A pattern decompiler for the code TP 5.0 emits with the game's switches: DIS is `tdis.py` output, [START, END) the
statement range (hex), --epi the routine's epilogue (`jmp` there is Exit), --name the frame names
(`bp+8:X`, `bp-2:I`). It evaluates ax/dx/bx/di/es symbolically and knows TP's shapes: if (with and/or chains,
the long `jcc +3; jmp` form, else), case (labels, ranges, else), repeat/until, while, for, Exit; stores, Inc/Dec,
LongInt adds, string assigns, calls (names and signatures from src/match/*.PAS|EXT|SIG), literals (from the image).
Data names come from the src/match/*.VAR declarations: their `{ @XXXX }` pins and the declaration order after
them, with record fields and arrays resolved (Map[A, B].Front, Slots[I].X, TextLines[3]).
Anything it does not know stops it with the instruction: extend it, do not hand-patch around it."""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from inventory import Prog  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MATCH = os.path.join(ROOT, 'src', 'match')


# ---------------------------------------------------------------- types and data

BASIC = {'byte': 1, 'boolean': 1, 'char': 1, 'shortint': 1, 'integer': 2, 'word': 2, 'longint': 4,
         'pointer': 4, 'real': 6, 'registers': 20, 'file': 128, 'text': 256}
TYPES = {}          # (unit seg, lower name) -> type
SCOPE = ['']        # the unit whose VAR file is being parsed


def strip(text):
    return re.sub(r'\{[^}]*\}', '', text.replace('\r', ''))


def ptype(t):
    """type text -> ('basic', name) | ('arr', [(lo, hi)], elem) | ('rec', [(name, off, type)]) | ('str', n)"""
    t = t.strip().rstrip(';').strip()
    lo = t.lower()
    m = re.match(r'packed\s+(.*)', t, re.S | re.I)
    if m:
        return ptype(m.group(1))
    if lo.startswith('^'):
        return ('ptr', t[1:].strip())
    m = re.match(r'string\s*\[\s*(\d+)\s*\]$', lo)
    if m:
        return ('str', int(m.group(1)))
    if lo == 'string':
        return ('str', 255)
    m = re.match(r'array\s*\[(.*?)\]\s*of\s+(.*)$', t, re.S | re.I)
    if m:
        dims = []
        for d in m.group(1).split(','):
            a, b = d.split('..')
            dims.append((num(a), num(b)))
        return ('arr', dims, ptype(m.group(2)))
    m = re.match(r'record\s+(.*)\s+end$', t, re.S | re.I)
    if m:
        fields, off = [], 0
        for decl in m.group(1).split(';'):
            if ':' not in decl:
                continue
            ns, ft = decl.split(':', 1)
            ft = ptype(ft)
            for n in ns.split(','):
                fields.append((n.strip(), off, ft))
                off += size(ft)
        return ('rec', fields)
    m = re.match(r'file\s+of\s+', lo)
    if m or lo == 'file':
        return ('basic', 'file')
    if lo in BASIC:
        return ('basic', lo)
    return ('named', t, SCOPE[0])


def num(s):
    s = s.strip()
    return int(s[1:], 16) if s.startswith('$') else int(s)


def resolve(t):
    while t[0] == 'named':
        k = (t[2], t[1].lower())
        t = TYPES[k] if k in TYPES else next(v for (u, n), v in TYPES.items() if n == k[1])
    return t


def size(t):
    t = resolve(t)
    if t[0] == 'basic':
        return BASIC[t[1]]
    if t[0] == 'ptr':
        return 4
    if t[0] == 'str':
        return t[1] + 1
    if t[0] == 'arr':
        n = 1
        for a, b in t[1]:
            n *= b - a + 1
        return n * size(t[2])
    return sum(size(f[2]) for f in t[1])


def tname(t):
    t = resolve(t)
    return t[1] if t[0] == 'basic' else t[0]


VARS = []           # (addr, name, type), sorted


UNITS = {}


def load_vars():
    import json
    for u in json.load(open(os.path.join(ROOT, 'recipe', 'units.json')))['units']:
        UNITS[u['seg']] = u
    for f in sorted(os.listdir(MATCH)):
        if f.endswith('.USES') or f.endswith('.PAS'):
            continue
        if not f.endswith('.VAR') and not f.endswith('.TYP'):
            continue
        raw = open(os.path.join(MATCH, f), encoding='latin1').read().replace('\r', '')
        SCOPE[0] = f[:4]
        for m in re.finditer(r'(?:^|\n)\s*type\b(.*?)(?=\n\s*(?:var|const)\b|\Z)', raw, re.S | re.I):
            body = strip(m.group(1))
            for d in re.finditer(r'(\w+)\s*=\s*((?:packed\s+)?record\b.*?\bend|[^;]+);', body, re.S | re.I):
                TYPES[(f[:4], d.group(1).lower())] = ptype(d.group(2))
    for f in sorted(os.listdir(MATCH)):
        if not f.endswith('.VAR'):
            continue
        raw = open(os.path.join(MATCH, f), encoding='latin1').read().replace('\r', '')
        SCOPE[0] = f[:4]
        u = UNITS.get(f[:4], {}).get('data') or {}
        starts = {'var': int(u['vars'][0], 16) if u.get('vars') else None,
                  'const': int(u['tconsts'][0], 16) if u.get('tconsts') else None}
        invar = False
        for sect in re.split(r'\n\s*(?=(?:type|var|const)\b)', '\n' + raw):
            kw = sect.strip().split(None, 1)[0].lower() if sect.strip() else ''
            if kw != 'var' and kw != 'const':
                continue
            body = sect.strip()[len(kw):]
            addr = starts[kw]
            # declarations, each with the pin of its line
            for d in re.finditer(r'([\w, ]+):\s*([^;{]+?(?:\([^)]*\))?)\s*(?:=\s*\([^;]*\))?;\s*(\{[^}]*\})?', body):
                pin = re.search(r'@([0-9A-F]{4})', d.group(3) or '')
                if 'absolute' in d.group(2).lower():
                    continue
                if pin:
                    addr = int(pin.group(1), 16)
                if addr is None:
                    continue
                t = ptype(d.group(2))
                for n in d.group(1).split(','):
                    VARS.append((addr, n.strip(), t))
                    addr += size(t)
            starts[kw] = addr
    VARS.extend([(0x71B8, 'Input', ('basic', 'text')), (0x72B8, 'Output', ('basic', 'text'))])   # System (TURBO.TPL)
    VARS.sort()


def access(t, off, base, whole=False):
    """the access path of byte `off` inside a value of type t named base -> (text, type at that point, rest);
    whole: stop at the first aggregate the offset starts (an address push)"""
    t = resolve(t)
    if off == 0 and (t[0] in ('basic', 'ptr', 'str') or whole):
        return base, t, 0
    if t[0] == 'rec':
        for n, fo, ft in t[1]:
            if fo <= off < fo + size(ft):
                return access(ft, off - fo, '%s.%s' % (base, n), whole)
    if t[0] == 'arr':
        es = size(t[2])
        idx, rest = [], off
        strides = []
        n = es
        for a, b in reversed(t[1]):
            strides.insert(0, n)
            n *= b - a + 1
        for (a, b), s in zip(t[1], strides):
            idx.append(str(rest // s + a))
            rest %= s
        return access(t[2], rest, '%s[%s]' % (base, ', '.join(idx)), whole)
    if t[0] == 'basic' and t[1] == 'longint' and off == 2:
        return base, t, 2
    raise KeyError((base, off))


def dsname(a, want=None):
    """DS address -> (Pascal access text, type)"""
    for va, n, t in reversed(VARS):
        if va <= a < va + size(t):
            txt, tt, rest = access(t, a - va, n)
            if rest:
                return txt + '.hi', tt
            return txt, tt
    raise KeyError('no variable at DS:%04X' % a)


def array_of(disp, strides):
    """an indexed access [di + disp] with index strides -> (var name, type, field offset in element)"""
    for va, n, t in VARS:
        rt = resolve(t)
        if rt[0] != 'arr':
            continue
        es = size(rt[2])
        st = []
        k = es
        for a, b in reversed(rt[1]):
            st.insert(0, k)
            k *= b - a + 1
        if st != list(strides):
            continue
        zero = va - sum(a * s for (a, b), s in zip(rt[1], st))
        if zero <= disp < zero + es:
            return n, rt, disp - zero
    raise KeyError('no array with strides %s for disp %04X' % (strides, disp))


# ---------------------------------------------------------------- routines

SIGS = {}           # (seg, off) -> (name, [(pname, type, var)], result type or None)


def load_sigs():
    for f in os.listdir(MATCH):
        m = re.match(r'([0-9A-F]{4})_([0-9A-F]{4})(?:_\w+)?\.(PAS|EXT|SIG)$', f)
        if not m:
            continue
        text = strip(open(os.path.join(MATCH, f), encoding='latin1').read())
        d = re.search(r'\b(procedure|function)\s+(\w+)\s*(\(([^)]*)\))?\s*(:\s*(\w+(?:\[\d+\])?))?', text, re.I)
        if not d:
            continue
        ps = []
        for g in (d.group(4) or '').split(';'):
            if ':' not in g and not g.strip():
                continue
            isvar = g.strip().lower().startswith('var ')
            g = re.sub(r'^\s*(var|const)\s+', '', g, flags=re.I)
            if ':' in g:
                ns, pt = g.split(':')
                pt = ptype(pt)
            else:
                ns, pt = g, ('untyped',)
            for n in ns.split(','):
                ps.append((n.strip(), pt, isvar))
        SIGS[(int(m.group(1), 16), int(m.group(2), 16))] = (d.group(2), ps, ptype(d.group(6)) if d.group(6) else None)


W, B, C, L = ('basic', 'word'), ('basic', 'boolean'), ('basic', 'char'), ('basic', 'longint')
U = ('untyped',)
LIB = {(0x2CD1, 0x980): ('Random', [('N', W, False)], W),
       (0x2CD1, 0x3B5): ('MemAvail', [], L),
       (0x2CD1, 0x207): ('IOResult', [], W),
       (0x2CD1, 0xFA9): ('Assign', [('F', U, True), ('S', ('str', 255), False)], None),
       (0x2CD1, 0x1058): ('Close', [('F', U, True)], None),
       (0x2CD1, 0x329): ('GetMem', [('P', U, True), ('N', W, False)], None),
       (0x2CD1, 0x364): ('FreeMem', [('P', U, True), ('N', W, False)], None),
       (0x2961, 0x29E): ('Delay', [('N', W, False)], None),
       (0x2961, 0x2BC): ('Sound', [('N', W, False)], None),
       (0x2961, 0x2F3): ('NoSound', [], None),
       (0x2961, 0x2FA): ('KeyPressed', [], B),
       (0x2961, 0x30C): ('ReadKey', [], C)}
SPECIAL = {(0x2CD1, 0xFD7): 'Reset', (0x2CD1, 0xFE0): 'Rewrite', (0x2CD1, 0x108C): 'Read', (0x2CD1, 0x1093): 'Write',
           (0x2CD1, 0xF6B): 'WriteStr', (0x2CD1, 0xEEE): 'WriteLn', (0x2CD1, 0xD8): 'Halt'}


# ---------------------------------------------------------------- expressions

class E:
    """an expression: text, precedence (0 relational, 1 additive, 2 multiplicative, 3 primary), type"""
    def __init__(self, s, p=3, t=None):
        self.s, self.p, self.t = s, p, t

    def at(self, p):
        return self.s if self.p >= p else '(%s)' % self.s

    def __repr__(self):
        return self.s


def hexn(n, signed=True):
    if signed and n >= 0x8000:
        return str(n - 0x10000)
    return '$%X' % n if n > 9 else str(n)


def binop(a, op, b):
    p = {'+': 1, '-': 1, 'or': 1, 'xor': 1, '*': 2, 'div': 2, 'mod': 2, 'and': 2, 'shl': 2, 'shr': 2}[op]
    e = E('%s %s %s' % (a.at(p), op, b.at(p + 1)), p, a.t)
    if op == 'shl' and re.match(r'\d+$', b.s):
        e.scale = (a, 1 << int(b.s))
    return e


NEG = {'jne': '=', 'je': '<>', 'jle': '>', 'jl': '>=', 'jg': '<=', 'jge': '<', 'jbe': '>', 'jb': '>=',
       'ja': '<=', 'jae': '<'}
POS = {'je': '=', 'jne': '<>', 'jg': '>', 'jge': '>=', 'jl': '<', 'jle': '<=', 'ja': '>', 'jae': '>=',
       'jb': '<', 'jbe': '<='}
NOTOP = {'=': '<>', '<>': '=', '<': '>=', '>=': '<', '>': '<=', '<=': '>'}
INV = {'je': 'jne', 'jne': 'je', 'jl': 'jge', 'jge': 'jl', 'jg': 'jle', 'jle': 'jg', 'jb': 'jae', 'jae': 'jb',
       'ja': 'jbe', 'jbe': 'ja'}


def load(path):
    out = []
    for l in open(path):
        m = re.match(r'([0-9A-F]{4}) (.*)', l.rstrip())
        if m:
            out.append((int(m.group(1), 16), m.group(2).strip()))
    return out


def tgt(t):
    return int(t.split()[-1], 16) & 0xFFFF


def isj(t):
    return re.match(r'j[a-z]+ 0x', t) is not None


def iscj(t):
    return isj(t) and not t.startswith('jmp')


class Dec:
    def __init__(self, L, img, seg, frame, epi):
        self.L, self.img, self.seg, self.frame, self.epi = L, img, seg, frame, epi
        self.idx = {a: i for i, (a, _) in enumerate(L)}
        self.backt = {tgt(t) for a, t in L if isj(t) and tgt(t) <= a}
        self.reset()

    def reset(self):
        self.ax = self.dx = self.bx = self.di = self.es = self.cx = None
        self.stack = []

    def save(self):
        return (self.ax, self.dx, self.bx, self.di, self.es, self.cx, list(self.stack), getattr(self, 'cxe', None),
                getattr(self, 'dxe', None), list(getattr(self, 'witems', [])))

    def restore(self, st):
        self.ax, self.dx, self.bx, self.di, self.es, self.cx, stack, self.cxe, self.dxe, w = st
        self.stack, self.witems = list(stack), list(w)

    def addr(self, i):
        return self.L[i][0] if i < len(self.L) else 0x10000

    # -- operands
    def mem(self, o):
        """a memory operand -> E"""
        m = re.match(r'(word|byte) ptr es:\[di\]$', o)
        if m and self.di and self.di[0] == 'abs':
            return E('%s[%s:%s]' % ('MemW' if m.group(1) == 'word' else 'Mem', self.di[1].s, hexn(self.di[2], False)),
                     3, ('basic', 'word' if m.group(1) == 'word' else 'byte'))
        m = re.match(r'(word|byte|dword)? ?ptr (?:ss:|ds:)?\[(.*)\]$', o)
        if not m:
            raise ValueError(o)
        w, inner = m.groups()
        m = re.match(r'bp ([+-]) (0x[0-9a-f]+|\d+)$', inner)
        if m:
            k = ('bp' + m.group(1) + str(int(m.group(2), 0)))
            if k not in self.frame:
                raise KeyError('frame slot %s' % k)
            n, t = self.frame[k]
            return E(n, 3, t)
        m = re.match(r'0x([0-9a-f]+)$', inner)
        if m:
            n, t = dsname(int(m.group(1), 16))
            return E(n, 3, t)
        m = re.match(r'di \+ 0x([0-9a-f]+)$', inner) or re.match(r'(di)$', inner)
        if m:
            disp = int(m.group(1), 16) if m.group(1) != 'di' else 0
            return self.indexed(disp)
        raise ValueError(o)

    def indexed(self, disp):
        d = self.di
        if d is None:
            raise ValueError('di unknown')
        if d[0] == 'ptr':               # es:di -> a pointer's target plus offset
            base, t = d[1], d[2]
            txt, tt, rest = access(t, disp + d[3], base)
            return E(txt, 3, tt)
        terms = d[1]                    # [(E index, stride)]
        n, rt, foff = array_of(disp, [s for _, s in terms])
        txt, tt, rest = access(rt[2], foff, '%s[%s]' % (n, ', '.join(e.s for e, _ in terms)))
        return E(txt, 3, tt)

    def opnd(self, o):
        if re.match(r'-?(0x[0-9a-f]+|\d+)$', o):
            return E(hexn(int(o, 0) & 0xFFFF), 3, ('basic', 'integer'))
        if o in ('ax', 'al'):
            return self.ax
        if o in ('dx', 'dl'):
            return self.dxe
        return self.mem(o)

    def lit(self, off):
        n = self.img[self.seg * 16 + off]
        s = self.img[self.seg * 16 + off + 1: self.seg * 16 + off + 1 + n]
        out, run = '', ''
        for c in s:
            if 32 <= c < 127:
                run += chr(c) * (2 if c == 39 else 1)
            else:
                if run:
                    out += "'%s'" % run
                    run = ''
                out += '#%d' % c
        if run:
            out += "'%s'" % run
        return out or "''"

    # -- conditions
    def cond_at(self, i):
        """a test at i -> (left E, right E, index of its jcc) or None; evaluates the code before the test"""
        t = self.L[i][1]
        m = re.match(r'cmp dx, (-?0x[0-9a-f]+|-?\d+)$', t)
        if m:                                       # LongInt against a constant: hi, then lo
            k = next(k for k in range(i + 1, i + 6) if self.L[k][1].startswith('cmp ax, '))
            v = ((int(m.group(1), 0) & 0xFFFF) << 16) | (int(self.L[k][1].split(', ')[1], 0) & 0xFFFF)
            v = v - (1 << 32) if v >= 1 << 31 else v
            return self.ax, E(str(v), 3, L), k + 1
        if t == 'cmp dx, bx':                       # LongInt: the hi jumps, then the lo compare decides
            k = next(k for k in range(i + 1, i + 6) if self.L[k][1] == 'cmp ax, cx')
            return self.ax, self.cxe, k + 1
        if t.startswith('cmp '):
            l, r = [x.strip() for x in t[4:].split(',', 1)]
            return self.opnd(l), self.opnd(r), i + 1
        if t in ('or ax, ax', 'or al, al'):
            return self.ax, None, i + 1
        if t == 'cmp dx, bx':                       # LongInt: hi jg/jl, then lo unsigned
            assert self.L[i + 3][1] == 'cmp ax, cx', self.L[i + 3]
            return self.ax, self.cxe, i + 4
        return None

    def rel(self, l, r, op):
        if r is None:                   # or al, al
            if tname(l.t) == 'boolean' if l.t else False:
                return E(l.s if op == '<>' else 'not ' + l.at(3), 3)
            return E('%s %s 0' % (l.at(1), op), 0)
        if l.t and tname(l.t) == 'boolean' and r.s in ('0', '1'):
            truth = (op == '<>') == (r.s == '0')
            return E(l.s if truth else 'not ' + l.at(3), 3, ('basic', 'boolean'))
        if l.t and tname(l.t) == 'char' and re.match(r'-?\$?[0-9A-F]+$', r.s):
            v = num(r.s)
            r = E("'%s'" % chr(v) if 32 <= v < 127 and v != 39 else '#%d' % v)
        return E('%s %s %s' % (l.at(1), op, r.at(1)), 0, ('basic', 'boolean'))

    def chain(self, i, stop, limit=None):
        """a condition chain from i: [(cond E, jump sense op table, target, start index)], index after it.
        A test is the evaluation code up to a cmp/or plus its jcc (or the long `jcc +; jmp T` form)."""
        out = []
        while i < len(self.L) and self.addr(i) < stop and (limit is None or len(out) < limit):
            if out and self.addr(i) in self.backt:     # a loop head starts its own statement
                break
            start = i
            j = self.eval_until_test(i, stop)
            if j is None:
                break
            c = self.cond_at(j)
            k = c[2]
            jt = self.L[k][1]
            if not iscj(jt):
                break
            op = jt.split()[0]
            target = tgt(jt)
            if target == self.addr(k + 2) and self.L[k + 1][1].startswith('jmp ') and self.addr(k + 1) < stop:
                op, target, k = INV[op], tgt(self.L[k + 1][1]), k + 1
            out.append((c[0], c[1], op, target, start, k + 1))
            i = k + 1
            if not self.next_is_test(i, stop):
                break
        for n in range(len(out), 0, -1):            # the longest prefix with targets only its T and F
            T, F = self.addr(out[n - 1][5]), out[n - 1][3]
            if all(x[3] in (T, F) or x[3] in [self.addr(y[4]) for y in out[:n]] for x in out[:n]):
                if n < len(out):
                    self.reset()
                    return self.chain_n(out[0][4], n), out[n - 1][5]
                return [x[:5] for x in out], i
        return [x[:5] for x in out], i

    def chain_n(self, i, n):
        """re-evaluate the first n tests from i (the state after them is what later code sees)"""
        out, _ = self.chain(i, self.addr(i) + 0x10000, n)
        return out

    def next_is_test(self, i, stop):
        """does a test follow at i (before any statement)?"""
        save = self.save()
        try:
            j = self.eval_until_test(i, stop)
            return j is not None and iscj(self.L[j + 1][1])
        except Exception:
            return False
        finally:
            self.restore(save)

    def eval_until_test(self, i, stop):
        """evaluate expression code from i up to a test; None if a statement comes first"""
        save = self.save()
        while i < len(self.L) and self.addr(i) < stop:
            t = self.L[i][1]
            if self.cond_at_ok(t) and i + 1 < len(self.L) and iscj(self.L[i + 1][1]):
                return i
            if not self.step(i):
                break
            i += 1
        self.restore(save)
        return None

    def cond_at_ok(self, t):
        return t.startswith('cmp ') or t in ('or ax, ax', 'or al, al')

    def boolexpr(self, tests, T, F):
        """tests [(l, r, jump op, target, start index)], then label T (after the last test), else label F -> E.
        Short-circuit code is a graph of tests (true exit: the jump, false exit: the next test); adjacent tests
        that share an exit merge into and/or until one node with exits T and F is left."""
        nodes = []
        for n, (l, r, op, target, start) in enumerate(tests):
            nxt = self.addr(tests[n + 1][4]) if n + 1 < len(tests) else T
            nodes.append([self.addr(start), ('rel', l, r, POS[op]), target, nxt])
        while len(nodes) > 1:
            for n in range(len(nodes) - 1):
                a, b = nodes[n], nodes[n + 1]
                if any(b[0] in (x[2], x[3]) for k, x in enumerate(nodes) if k != n):
                    continue
                if a[3] == b[0] and a[2] == b[2]:
                    c = ('or', a[1], b[1])
                elif a[3] == b[0] and a[2] == b[3]:
                    c = ('and', ('not', a[1]), b[1])
                elif a[2] == b[0] and a[3] == b[3]:
                    c = ('and', a[1], b[1])
                elif a[2] == b[0] and a[3] == b[2]:
                    c = ('or', ('not', a[1]), b[1])
                else:
                    continue
                nodes[n:n + 2] = [[a[0], c, b[2], b[3]]]
                break
            else:
                raise ValueError('irreducible condition %r' % [(hex(x[0]), hex(x[2]), hex(x[3])) for x in nodes])
        _, c, t, f = nodes[0]
        if (t, f) == (F, T):
            c = ('not', c)
        elif (t, f) != (T, F):
            raise ValueError('condition exits %04X/%04X, not %04X/%04X' % (t, f, T, F))
        return self.render(c, False)

    def render(self, c, neg):
        """a condition tree -> E, with not pushed into the relations"""
        k = c[0]
        if k == 'not':
            return self.render(c[1], not neg)
        if k == 'rel':
            _, l, r, op = c
            return self.rel(l, r, NOTOP[op] if neg else op)
        k = {'and': 'or', 'or': 'and'}[k] if neg else k
        a, b = self.render(c[1], neg), self.render(c[2], neg)
        p = 2 if k == 'and' else 1
        def side(e, right):
            if e.p == 0 or (e.p < p) or (right and e.p == p and e.s.split(' ')[0] != e.s) and e.p != 3 and False:
                return '(%s)' % e.s
            return e.s if e.p >= p and e.p != 0 else '(%s)' % e.s
        return E('%s %s %s' % (side(a, False), k, side(b, True)), p, ('basic', 'boolean'))

    # -- expression evaluation (no side effects)
    def expr_step(self, t):
        ax = self.ax
        m = re.match(r'mov (ax|al), (.*)$', t)
        if t == 'mov cx, ax':
            self.cxe = self.ax
            return True
        if t == 'mov dx, ax':
            self.dxe = self.ax
            return True
        if t == 'mov bx, dx':
            return True
        if m and not m.group(2).startswith(('ds', 'es')):
            v = m.group(2)
            if v in ('ax', 'al'):
                return True
            self.ax = self.opnd(v)
            if m.group(1) == 'al' and re.match(r'(0x[0-9a-f]+|\d+)$', v):
                self.ax = E(self.ax.s, 3, ('basic', 'byte'))
            return True
        if t in ('xor ax, ax', 'sub ax, ax'):
            self.ax = E('0', 3, ('basic', 'integer'))
            return True
        if t == 'xor ah, ah':
            if ax.t and tname(ax.t) == 'char':
                self.ax = E('Ord(%s)' % ax.s, 3, ('basic', 'integer'))
            return True
        m = re.match(r'(add|sub|and|or|xor) ax, (.*)$', t)
        if m and m.group(2) != 'ax':
            op = {'add': '+', 'sub': '-', 'and': 'and', 'or': 'or', 'xor': 'xor'}[m.group(1)]
            v = m.group(2)
            if ax.t and tname(ax.t) == 'longint' and re.match(r'(0x[0-9a-f]+|\d+)$', v):
                r = E(hexn(int(v, 0), False))
            else:
                r = self.opnd(v)
            self.ax = binop(ax, op, r)
            return True
        if t == 'idiv cx':                          # cwd; idiv: div in ax, mod in dx
            d = E(hexn(self.cx)) if not getattr(self, 'cxdiv', None) else self.cxdiv
            a0 = E(ax.s, ax.p, ('basic', 'integer'))
            self.ax = binop(a0, 'div', d)
            self.dxe = binop(a0, 'mod', d)
            self.ax.t = self.dxe.t = ('basic', 'integer')
            self.cxdiv = None
            return True
        m = re.match(r'mov cx, (word ptr .*)$', t)
        if m:
            self.cxdiv = self.mem(m.group(1))
            return True
        if t == 'neg ax':
            self.ax = E('-' + ax.at(2), 1, ax.t)
            return True
        if t == 'inc ax':
            self.ax = binop(ax, '+', E('1'))
            return True
        if t == 'dec ax':
            self.ax = binop(ax, '-', E('1'))
            return True
        m = re.match(r'mov (cx|cl), (0x[0-9a-f]+|\d+)$', t)
        if m:
            self.cx = int(m.group(2), 0)
            self.cxdiv = None
            return True
        m = re.match(r'(shl|shr) ax, (cl|1)$', t)
        if m:
            n = self.cx if m.group(2) == 'cl' else 1
            self.ax = binop(ax, m.group(1), E(str(n)))
            return True
        if t == 'mov bx, ax':
            self.bx = self.ax
            return True
        m = re.match(r'mov dx, (0x[0-9a-f]+|\d+)$', t)
        if m:
            self.dx = int(m.group(1), 0)
            return True
        if t == 'mul dx':
            self.ax = ('scaled', self.ax, self.dx)
            return True
        if t == 'mov di, ax':
            self.di = ('idx', [self.scaled(self.ax)])
            return True
        if t == 'add di, bx':
            self.di = ('idx', self.di[1] + [self.scaled(self.bx)])
            return True
        m = re.match(r'mov di, (word ptr .*)$', t)
        if m:
            self.di = ('idx', [(self.mem(m.group(1)), 1)])
            return True
        m = re.match(r'shl di, (cl|1)$', t)
        if m:
            e, s = self.di[1][-1]
            self.di = ('idx', self.di[1][:-1] + [(e, s << (self.cx if m.group(1) == 'cl' else 1))])
            return True
        m = re.match(r'les di, ptr \[(.*)\]$', t)
        if m:
            n, pt = dsname(int(m.group(1), 16))
            tt = resolve(pt)
            self.di = ('ptr', n + '^', resolve(('named', tt[1], '')) if tt[0] == 'ptr' else tt, 0)
            return True
        m = re.match(r'add di, (0x[0-9a-f]+|\d+)$', t)
        if m and self.di and self.di[0] == 'ptr':
            v = int(m.group(1), 0)
            self.di = self.di[:3] + (self.di[3] + (v - 0x10000 if v >= 0x8000 else v),) + self.di[4:]
            return True
        if t == 'add di, ax' and self.di and self.di[0] == 'ptr':     # a pointer's array indexed by ax
            self.di = self.di[:4] + (self.scaled(self.ax),)
            return True
        m = re.match(r'les ax, ptr \[(.*)\]$', t)
        if m:
            self.ax = self.mem('dword ptr [%s]' % m.group(1))
            return True
        if t == 'mov dx, es':
            return True
        if t == 'cdq':
            self.ax = E(self.ax.s, self.ax.p, ('basic', 'longint')) if self.ax.t is None or \
                tname(self.ax.t) != 'longint' else self.ax
            return True
        if t in ('and dx, 0', 'adc dx, 0', 'sbb dx, 0'):
            return True
        return False

    def scaled(self, v):
        if isinstance(v, tuple) and v[0] == 'scaled':
            return (v[1], v[2])
        return getattr(v, 'scale', (v, 1))

    # -- statements
    def block(self, i, end):
        """statements from i up to address end -> (list, i)"""
        out = []
        while i < len(self.L) and self.addr(i) < end:
            s, i = self.stmt(i, end)
            if s is not None:
                out.append(s)
        return out, i

    def backrefs(self, a, end):
        """indexes of later jumps back to address a (before end)"""
        return [k for k in range(self.idx[a], len(self.L)) if self.addr(k) < end and isj(self.L[k][1])
                and tgt(self.L[k][1]) == a and k > self.idx[a]]

    def stmt(self, i, end):
        self.reset()
        a, t = self.L[i]
        # repeat .. until: a conditional jump back here
        back = [k for k in self.backrefs(a, end) if iscj(self.L[k][1])]
        if back and not getattr(self, '_inrepeat', None) == a:
            k = back[-1]
            after = self.addr(k + 1)
            # the until chain: find its start by trying each test start backwards
            for s in range(i, k):
                self.reset()
                try:
                    tests, j = self.chain(s, after)
                except Exception:
                    continue
                if j == k + 1 and tests and all(x[3] in (a, after) for x in tests):
                    break
            else:
                raise ValueError('until chain at %04X' % self.addr(k))
            self._inrepeat = a
            body, _ = self.block(i, self.addr(s))
            self._inrepeat = None
            self.reset()
            tests, j = self.chain(s, after)
            c = self.boolexpr(tests, after, a)
            return ('repeat', body, c), j
        # while: jmp/jcc to the test later... TP: test at top, `jmp top` at the end
        jback = [k for k in self.backrefs(a, end) if self.L[k][1].startswith('jmp ')]
        if jback:
            k = jback[-1]
            after = self.addr(k + 1)
            tests, j = self.chain(i, self.addr(k))
            body, _ = self.block(j, self.addr(k))
            return ('while', self.boolexpr(tests, self.addr(j), after), body), k + 1
        f = self.for_at(i, end)
        if f:
            return f
        if t.startswith('jmp '):
            x = tgt(t)
            if x == self.epi:
                return 'Exit', i + 1
            raise ValueError('stray jmp at %04X' % a)
        # if / case
        j = self.eval_until_test(i, end)
        if j is not None:
            c = self.cond_at(j)
            if c[1] is not None and self.L[j][1].startswith('cmp ax, ') and re.match(
                    r'cmp ax, (0x[0-9a-f]+|\d+)$', self.L[j][1]) and self.is_case(j, end):
                return self.case(c[0], j, end)
            self.reset()
            tests, k = self.chain(i, end)
            T = self.addr(k)
            F = tests[-1][3]
            if F == T:                              # if C then ;
                return ('if', self.boolexpr(tests, T, F), [], None), k
            if F < T:
                raise ValueError('backward if at %04X' % a)
            then_end, else_end = F, None
            last = self.idx[F] - 1
            if self.L[last][1].startswith('jmp ') and tgt(self.L[last][1]) > F:
                x = tgt(self.L[last][1])
                if x <= end and x != self.epi or (x == self.epi and end >= self.epi):
                    then_end, else_end = self.addr(last), x
            if F > end:
                raise ValueError('if at %04X jumps past its block' % a)
            th, _ = self.block(k, then_end)
            if else_end is not None:
                el, _ = self.block(self.idx[F], else_end)
                return ('if', self.boolexpr(tests, T, F), th, el), self.idx[else_end] if else_end in self.idx \
                    else len(self.L)
            return ('if', self.boolexpr(tests, T, F), th, None), self.idx[F]
        return self.simple(i, end)

    def for_tmp(self, i, end):
        """for with a variable limit: `tmp := hi; ax := lo; cmp ax, tmp; jg END; V := ax; jmp L1; L0: inc V;
        L1: S; mov ax, V; cmp ax, tmp; jne L0` (tmp: a frame word with no name)"""
        save = self.save()
        k = i
        while k < len(self.L) and self.step(k):
            k += 1
        m = re.match(r'mov word ptr \[bp - (0x[0-9a-f]+|\d+)\], ax$', self.L[k][1])
        if not m or 'bp-%d' % int(m.group(1), 0) in self.frame:
            self.restore(save)
            return None
        tmp = '[bp - %s]' % m.group(1)
        hi = self.ax
        k += 1
        while k < len(self.L) and self.step(k):
            k += 1
        if self.L[k][1] != 'cmp ax, word ptr %s' % tmp:
            self.restore(save)
            return None
        lo = self.ax
        op, END, w = self.jinfo(k + 1)
        k += 1 + w
        mv = re.match(r'mov (word|byte) ptr (\[.*\]), ax$', self.L[k][1])
        mi = re.match(r'(inc|dec) (word|byte) ptr (\[.*\])$', self.L[k + 2][1])
        assert mv and mi and mi.group(3) == mv.group(2), self.L[k:k + 3]
        v = self.mem('%s ptr %s' % (mv.group(1), mv.group(2)))
        L0 = self.addr(k + 2)
        q = self.idx[END] - 1                       # jne L0 or je +; jmp L0
        c = q - 2 if self.L[q][1].startswith('jmp ') else q - 1
        assert self.L[c][1] == 'cmp ax, word ptr %s' % tmp, self.L[c]
        body, _ = self.block(k + 3, self.addr(c - 1))
        return ('for', v, lo, {'jg': 'to', 'jl': 'downto'}[op], hi, body), q + 1

    def for_at(self, i, end):
        """for V := lo to|downto hi do S: `V := lo; jmp L1; L0: inc|dec V; L1: S; cmp V, hi; jne L0`"""
        f = self.for_tmp(i, end)
        if f:
            return f
        k = i
        save = self.save()
        while k < len(self.L) and self.step(k):
            k += 1
        m = re.match(r'mov (word|byte) ptr (\[.*\]), (.*)$', self.L[k][1]) if k + 2 < len(self.L) else None
        if not m or not self.L[k + 1][1].startswith('jmp ') or tgt(self.L[k + 1][1]) != self.addr(k + 3):
            self.restore(save)
            return None
        mi = re.match(r'(inc|dec) (word|byte) ptr (\[.*\])$', self.L[k + 2][1])
        if not mi or mi.group(3) != m.group(2):
            self.restore(save)
            return None
        v = self.mem('%s ptr %s' % (m.group(1), m.group(2)))
        lo = self.ax if m.group(3) in ('ax', 'al') else self.opnd(m.group(3))
        L0 = self.addr(k + 2)
        back = [q for q in range(k + 3, len(self.L)) if isj(self.L[q][1]) and tgt(self.L[q][1]) == L0]
        q = back[-1]
        if self.L[q][1].startswith('jmp '):         # long form: cmp; je +; jmp L0
            c = q - 2
        else:
            c = q - 1
        mc = re.match(r'cmp (word|byte) ptr (\[.*\]), (.*)$', self.L[c][1])
        if not mc or mc.group(2) != m.group(2):
            raise ValueError('for at %04X: no limit test' % self.addr(i))
        hi = self.opnd(mc.group(3))
        body, _ = self.block(k + 3, self.addr(c))
        return ('for', v, lo, 'to' if mi.group(1) == 'inc' else 'downto', hi, body), q + 1

    def is_case(self, j, end):
        """a `cmp ax, k` that starts a case: its label chain's fail target is another `cmp ax, k` or the
        chain has more than one label"""
        k = j
        while True:
            t = self.L[k][1]
            if not re.match(r'cmp ax, (0x[0-9a-f]+|\d+)$', t):
                return False
            jt = self.L[k + 1][1]
            op = jt.split()[0]
            if op == 'je' and self.L[k + 2][1].startswith('jmp ') and tgt(jt) == self.addr(k + 3):
                nx = tgt(self.L[k + 2][1])
                break
            if op in ('je', 'jl', 'jle'):
                return True
            if op == 'jne':
                nx = tgt(jt)
                break
            return False
        if nx not in self.idx:
            return False
        n = self.idx[nx]
        return re.match(r'cmp ax, (0x[0-9a-f]+|\d+)$', self.L[n][1]) is not None or \
            (self.L[n - 1][1].startswith('jmp ') and tgt(self.L[n - 1][1]) > nx)

    def case(self, sel, j, end):
        arms, END = [], None
        i = j
        while True:
            labels = []
            while True:
                A = int(self.L[i][1].split(', ')[1], 0)
                op, x, w = self.jinfo(i + 1)
                if op == 'je' and x == self.addr(i + 1 + w) and False:
                    pass
                if op == 'je' and w == 2:                # `jne +; jmp X`: an empty arm
                    arms.append(([hexn(A)], ['Exit'] if x == self.epi and end < self.epi else []))
                    END = x if END is None else END
                    i += 1 + w
                    if labels:
                        raise ValueError('case label at %04X' % self.addr(i))
                    if not self.L[i][1].startswith('cmp ax, '):
                        nx = self.addr(i)
                        break
                    continue
                if op == 'je':
                    labels.append(hexn(A))
                    i += 1 + w
                    if self.L[i][1].startswith('cmp ax, '):
                        continue
                    raise ValueError('case label at %04X' % self.addr(i))
                if op == 'jne':
                    labels.append(hexn(A))
                    nx = x
                    i += 1 + w
                    break
                if op in ('jl', 'jge') and op == 'jl':
                    nxt_lab = x
                    B = int(self.L[i + 1 + w][1].split(', ')[1], 0)
                    op2, x2, w2 = self.jinfo(i + 2 + w)
                    labels.append('%s..%s' % (hexn(A), hexn(B)))
                    i += 2 + w + w2
                    if op2 == 'jle':
                        continue
                    nx = x2
                    break
                raise ValueError('case label at %04X: %s' % (self.addr(i), op))
            if not labels:                              # the chain ended on an empty arm
                break
            n = self.idx[nx] if nx in self.idx else len(self.L)
            bend = nx
            if self.L[n - 1][1].startswith('jmp ') and n - 1 >= i:
                x = tgt(self.L[n - 1][1])
                if x > nx:
                    END = x if END is None else END
                    bend = self.addr(n - 1)
            body, _ = self.block(i, bend)
            arms.append((labels, body))
            i = n
            if END is not None and nx >= END or nx >= end:
                break
            if not re.match(r'cmp ax, (0x[0-9a-f]+|\d+)$', self.L[i][1]):
                break
        els = None
        if END is not None and self.addr(i) < END and END <= max(end, self.addr(i)):
            if END == self.epi and end < self.epi:
                pass
            else:
                els, _ = self.block(i, END)
                i = self.idx[END] if END in self.idx else len(self.L)
        if sel.t and tname(sel.t) == 'char':
            arms = [([self.chr_label(x) for x in ls], b) for ls, b in arms]
        return ('case', sel, arms, els), i

    def jinfo(self, k):
        """the jump at k as (op, target, instructions): `jcc +; jmp T` is the inverse jcc to T; a `je` to a
        body right after a long-form last label stays je"""
        jt = self.L[k][1]
        op, x = jt.split()[0], tgt(jt)
        if op != 'jmp' and k + 1 < len(self.L) and self.L[k + 1][1].startswith('jmp ') and x == self.addr(k + 2):
            return INV[op], tgt(self.L[k + 1][1]), 2
        return op, x, 1

    def chr_label(self, x):
        def one(v):
            v = num(v)
            return "'%s'" % chr(v) if 32 <= v < 127 and v != 39 else '#%d' % v
        return '..'.join(one(v) for v in x.split('..'))

    def simple(self, i, end):
        """straight-line code up to the next statement end"""
        while i < len(self.L) and self.addr(i) < end:
            a, t = self.L[i]
            if self.step(i):
                i += 1
                continue
            m = re.match(r'mov (word|byte) ptr (es:\[di\]), (dx|dl|ax|al)$', t)
            if m:
                dst = self.mem('%s ptr %s' % (m.group(1), m.group(2)))
                return self.assign(dst, self.opnd(m.group(3))), i + 1
            m = re.match(r'mov (word|byte) ptr (\[.*\]), (.*)$', t)
            if m:
                v = m.group(3)
                if v == 'dx':
                    return None, i + 1          # the high word of a LongInt store
                dst = self.mem('%s ptr %s' % (m.group(1), m.group(2)))
                val = self.ax if v in ('ax', 'al') else self.opnd(v)
                return self.assign(dst, val), i + 1
            m = re.match(r'(add|sub) (word|byte) ptr (\[.*\]), (.*)$', t)
            if m:
                dst = self.mem('%s ptr %s' % (m.group(2), m.group(3)))
                v = self.ax if m.group(4) in ('ax', 'al') else self.opnd(m.group(4))
                return '%s(%s, %s)' % ({'add': 'Inc', 'sub': 'Dec'}[m.group(1)], dst.s, v.s), i + 1
            m = re.match(r'(inc|dec) (word|byte) ptr (\[.*\])$', t)
            if m:
                dst = self.mem('%s ptr %s' % (m.group(2), m.group(3)))
                return '%s(%s)' % (m.group(1).capitalize(), dst.s), i + 1
            if t.startswith('lcall ') or t.startswith('call '):
                return self.call(i)
            raise ValueError('%04X %s' % (a, t))
        raise ValueError('no statement end before %04X' % self.addr(i))

    def step(self, i):
        """one instruction of expression code (registers, pushes, function calls) -> consumed?"""
        t = self.L[i][1]
        if self.expr_step(t):
            return True
        if t == 'push ax':
            self.stack.append(self.ax)
        elif t == 'push dx':
            self.stack.append(None)                 # the hi word of a LongInt temporary or argument
        elif t == 'pop es' and self.di and self.di[0] == 'addr':   # Mem[seg:ofs]: seg pushed, ofs in di
            self.di = ('abs', self.stack.pop(), self.di[1])
        elif re.match(r'mov (dx|ax|al|dl), (word|byte) ptr es:\[di\]$', t):
            v = self.mem(t.split(', ')[1])
            if t.startswith('mov d'):
                self.dxe = v
            else:
                self.ax = v
        elif t == 'pop cx':
            self.cxe = self.stack.pop()
        elif t == 'pop bx':
            assert self.stack.pop() is None
        elif t == 'push di':
            self.stack.append(self.di_val())
        elif t in ('push es', 'push ds', 'push ss'):
            pass
        elif t == 'push cs':
            if i + 1 < len(self.L) and self.L[i + 1][1] == 'push di':
                self.di = ('lit', self.lit(self.di[1]))
        elif t.startswith('push '):
            self.stack.append(self.opnd(t[5:]))
        elif re.match(r'mov di, (0x[0-9a-f]+)$', t):
            self.di = ('addr', int(t.split(', ')[1], 16))
        elif re.match(r'lea di, \[bp - (0x[0-9a-f]+|\d+)\]$', t):
            k = 'bp-' + str(int(t.split('- ')[1][:-1], 0))
            self.di = ('frame', self.frame[k][0])
        elif (t.startswith('lcall ') or t.startswith('call ')) and SPECIAL.get(self.target(i)) == 'WriteStr':
            f, item, w = self.stack[-3:]            # Write(t, s:w) item; the file stays pushed
            self.witems = getattr(self, 'witems', []) + [item.s + ('' if w.s == '0' else ':' + w.s)]
            self.stack = self.stack[:-3] + [f]
        elif t.startswith('lcall ') or t.startswith('call '):
            text, res = self.callexpr(i)
            if res is None:
                return False
            self.ax = E(text, 3, res)
            self.stack = []
        else:
            return False
        return True

    def di_val(self):
        d = self.di
        if d[0] == 'lit':
            return E(d[1])
        if d[0] == 'addr':
            return E(dsname(d[1])[0])
        if d[0] == 'frame':
            return E(d[1])
        if d[0] == 'ptr' and len(d) > 4:            # base^ + index*stride + disp: an array field of the target
            e, stride = d[4]
            t = resolve(d[2])
            for n, fo, ft in t[1] if t[0] == 'rec' else []:
                ft = resolve(ft)
                if ft[0] == 'arr' and len(ft[1]) == 1 and size(ft[2]) == stride and fo - ft[1][0][0] * stride == d[3]:
                    return E('%s.%s[%s]' % (d[1], n, e.s), 3, ft[2])
            raise ValueError('no array of stride %d at %d in %s' % (stride, d[3], d[1]))
        if d[0] == 'ptr':
            txt, tt, rest = access(d[2], d[3], d[1], True)
            return E(txt, 3, tt)
        raise ValueError(d)

    def assign(self, dst, val):
        if dst.t and resolve(dst.t)[0] == 'str' and val.s == '0':
            val = E("''")
        elif dst.t and tname(dst.t) == 'boolean' and val.s in ('0', '1'):
            val = E(['False', 'True'][int(val.s)])
        elif dst.t and tname(dst.t) == 'char' and re.match(r'-?\$?[0-9A-F]+$', val.s):
            v = num(val.s)
            val = E("'%s'" % chr(v) if 32 <= v < 127 and v != 39 else '#%d' % v)
        elif dst.t and tname(dst.t) == 'word' and val.s.startswith('-'):
            val = E(hexn(int(val.s) & 0xFFFF, False))
        return '%s := %s' % (dst.s, val.s)

    def target(self, i):
        t = self.L[i][1]
        if t.startswith('lcall '):
            return tuple(int(x, 0) for x in re.match(r'lcall (0x[0-9a-f]+), (0x[0-9a-f]+|\d+)', t).groups())
        return self.seg, tgt(t)

    def callexpr(self, i):
        """the call at i with the pushed arguments -> (text, result type or None)"""
        seg, off = self.target(i)
        if (seg, off) == (0x2CD1, 0x64E) or (seg, off) in SPECIAL:     # statements of their own
            return None, None
        sig = LIB.get((seg, off)) or SIGS.get((seg, off))
        if sig is None:
            raise KeyError('no signature for %04X:%04X' % (seg, off))
        name, ps, res = sig
        args = [x for x in self.stack if x is not None]
        if len(args) != len(ps):
            raise ValueError('%s: %d args for %d params at %04X' % (name, len(args), len(ps), self.addr(i)))
        out = []
        for e, (pn, pt, isvar) in zip(args, ps):
            if pt[0] != 'untyped' and tname(pt) == 'boolean' and e.s in ('0', '1'):
                e = E(['False', 'True'][int(e.s)])
            out.append(e.s)
        return name + ('(%s)' % ', '.join(out) if out else ''), res

    def call(self, i):
        seg, off = self.target(i)
        if (seg, off) == (0x2CD1, 0x64E):
            src, dst = self.stack[0], self.stack[1]
            return '%s := %s' % (dst.s, src.s), i + 1
        sp = SPECIAL.get((seg, off))
        if sp:
            st, self.stack = self.stack, []
            if sp in ('Reset', 'Rewrite'):         # typed file: the record size is TP's
                return '%s(%s)' % (sp, st[0].s), i + 1
            if sp in ('Read', 'Write'):            # typed file: then `add sp, 4` drops the variable
                assert self.L[i + 1][1] == 'add sp, 4', self.L[i + 1]
                return '%s(%s, %s)' % (sp, st[0].s, st[1].s), i + 2
            if sp == 'WriteStr':                   # Write(t, s:w) item; the file stays pushed
                f, item, w = st
                self.wfile = f
                self.witems = getattr(self, 'witems', []) + [item.s + ('' if w.s == '0' else ':' + w.s)]
                self.stack = [f]
                return None, i + 1
            if sp == 'WriteLn':
                f, items = st[0], getattr(self, 'witems', [])
                self.witems = []
                args = ([] if f.s == 'Output' else [f.s]) + items
                return 'WriteLn' + ('(%s)' % ', '.join(args) if args else ''), i + 1
            if sp == 'Halt':
                return ('Halt' if self.ax.s == '0' else 'Halt(%s)' % self.ax.s), i + 1
        text, res = self.callexpr(i)
        self.stack = []
        return text, i + 1


# ---------------------------------------------------------------- output

def emit(st, ind):
    def one(x, ind):
        if isinstance(x, str):
            return ind + x
        k = x[0]
        if k == 'if':
            _, c, th, el = x
            r = ind + 'if %s then\n' % c.s + block(th, ind + '  ', el is not None and dangles(th))
            if el is not None:
                r += '\n' + ind + 'else\n' + block(el, ind + '  ')
            return r
        if k == 'case':
            _, sel, arms, els = x
            r = ind + 'case %s of\n' % sel.s
            for labels, body in arms:
                r += ind + '  %s:\n' % ', '.join(labels) + (block(body, ind + '    ') if body else ind + '    ') + ';\n'
            if els is not None:
                r += ind + 'else\n' + ''.join(one(s, ind + '  ') + ';\n' for s in els)
            return r + ind + 'end'
        if k == 'repeat':
            _, body, c = x
            return ind + 'repeat\n' + ''.join(one(s, ind + '  ') + ';\n' for s in body) + ind + 'until %s' % c.s
        if k == 'for':
            _, v, lo, d, hi, body = x
            return ind + 'for %s := %s %s %s do\n' % (v.s, lo.s, d, hi.s) + block(body, ind + '  ')
        if k == 'while':
            _, c, body = x
            return ind + 'while %s do\n' % c.s + block(body, ind + '  ')
        raise ValueError(x)

    def dangles(lst):
        """does a single statement end in an if without else (which would take a following else)?"""
        if len(lst) != 1 or isinstance(lst[0], str):
            return False
        x = lst[0]
        if x[0] == 'if':
            return x[3] is None or dangles(x[3])
        if x[0] in ('for', 'while'):
            return dangles(x[-1] if x[0] == 'for' else x[2])
        return False

    def block(lst, ind, force=False):
        if len(lst) == 1 and not force:
            return one(lst[0], ind)
        if not lst:
            return ind + 'begin end'
        return ind[:-2] + 'begin\n' + ';\n'.join(one(x, ind) for x in lst) + ';\n' + ind[:-2] + 'end'
    return ''.join(one(s, ind) + ';\n' for s in st)


def wrap(text, width=110):
    """break lines TP would reject (over 126 characters) after an and/or/comma"""
    out = []
    for l in text.split('\n'):
        ind = len(l) - len(l.lstrip()) + 4
        while len(l) > width:
            cut = max(l.rfind(' and ', 0, width), l.rfind(' or ', 0, width), l.rfind(', ', 0, width))
            if cut <= ind:
                break
            cut += 1 if l[cut:cut + 2] != ', ' else 2
            out.append(l[:cut].rstrip())
            l = ' ' * ind + l[cut:].lstrip()
        out.append(l)
    return '\n'.join(out)


def main(argv):
    frame, epi = {}, 0x10000
    for a in argv:
        if a.startswith('--name='):
            k, n = a[7:].split(':')
            n, _, ty = n.partition('/')
            frame[k] = (n, ptype(ty) if ty else ('basic', 'integer'))
        elif a.startswith('--epi='):
            epi = int(a[6:], 16)
    argv = [a for a in argv if not a.startswith('--')]
    load_vars()
    load_sigs()
    p = Prog(os.path.join(ROOT, '.work', 'tp', 'SAM1_unp.exe'))
    L = load(argv[1])
    d = Dec(L, p.img, int(argv[2], 16), frame, epi)
    st, _ = d.block(d.idx[int(argv[3], 16)], int(argv[4], 16))
    sys.stdout.write(wrap(emit(st, '  ')))


if __name__ == '__main__':
    main(sys.argv)
