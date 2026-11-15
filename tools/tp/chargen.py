"""chargen.py DIS SEG START END -> the `if S = 'c' then ...` chain of a 0D9C row-char routine (2E88).
DIS is `tdis.py` output; START is the chain's first `lea di, [bp - 0x100]`, END the address after it (hex).
Bodies: SetCell calls (arguments X, Y, constants, W6840, W685A + n, FO), Inc(W685A), and ifs on
SiteDone[W685A + 2] or B6868; anything else stops it with the unknown instruction."""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from inventory import Prog  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def load(path):
    out = []
    for l in open(path):
        m = re.match(r'([0-9A-F]{4}) (.*)', l.rstrip())
        if m:
            out.append((int(m.group(1), 16), m.group(2).strip()))
    return out


def tgt(t):
    return int(t.split()[-1], 16)


def lit(img, seg, off):
    n = img[seg * 16 + off]
    s = img[seg * 16 + off + 1: seg * 16 + off + 1 + n]
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
    return out


def hexn(n):
    if n >= 0x8000:                     # a 16-bit immediate into an Integer: TP takes no $FFFF there
        return str(n - 0x10000)
    return '$%X' % n if n > 9 else str(n)


PROFILES = {   # routine -> (X, Y, FO, S) operands as tdis prints them
    '2E88': ('word ptr [bp + 0xc]', 'word ptr [bp + 0xa]', 'byte ptr [bp - 0x105]', '[bp - 0x100]'),
    '68A9': ('word ptr [bp - 0x2c]', 'word ptr [bp + 0xa]', 'byte ptr [bp - 0x131]', '[bp - 0x12c]'),
    '3A91': ('word ptr [bp + 0xe]', 'word ptr [bp + 0xc]', 'byte ptr [bp + 6]', '[bp - 0x100]'),
}
PX, PY, PFO, PS = PROFILES['2E88']
XN = 'X'


FIELDS = {0: 'W00', 2: 'X', 4: 'Y', 6: 'W06', 8: 'W08', 0xA: 'W0A', 0xC: 'W0C', 0xE: 'W0E', 0x10: 'W10',
          0x12: 'W12', 0x14: 'W14', 0x16: 'W16', 0x18: 'W18', 0x1A: 'W1A', 0x1C: 'W1C', 0x1E: 'Free', 0x1F: 'B1F'}
CALLS = {'call 0x2c6e': 'SetCell', 'call 0x3a91': 'SpawnActor', 'call 0x2e88': 'WorldCell',
         'lcall 0x29c3, 0x19f9 R': 'DrawTileB'}
NEG = {'jne': '=', 'je': '<>', 'jle': '>', 'jl': '>=', 'jg': '<=', 'jge': '<', 'jbe': '>', 'jae': '<', 'ja': '<=',
       'jb': '>='}


def names():
    """DS address -> name, from the `{ @XXXX }` pins of src/match/*.VAR"""
    out = {}
    d = os.path.join(ROOT, 'src', 'match')
    for f in os.listdir(d):
        if not f.endswith('.VAR'):
            continue
        for l in open(os.path.join(d, f), encoding='latin1'):
            m = re.match(r'\s*([\w, ]+):\s*([^;]+);.*\{ @([0-9A-F]{4})', l)
            if not m:
                continue
            ns = [x.strip() for x in m.group(1).split(',')]
            size = 1 if m.group(2).strip() in ('Byte', 'Boolean', 'Char') else 2
            for k, n in enumerate(ns):
                out[int(m.group(3), 16) + k * size] = n
    return out


NAMES = {}


def opnd(o):
    if o == PX:
        return XN
    if o == PY:
        return 'Y'
    if o == PFO:
        return 'FO'
    m = re.match(r'(?:word|byte) ptr \[0x([0-9a-f]+)\]$', o)
    if m:
        return NAMES[int(m.group(1), 16)]
    if re.match(r'(0x[0-9a-f]+|\d+)$', o):
        return hexn(int(o, 0))
    raise ValueError(o)


def paren(e):
    return '(%s)' % e if ' shl ' in e or ' shr ' in e else e


def stmts(body):
    """straight-line code with ifs -> a statement list"""
    out, stack, i = [], [], 0
    ax = src = di = idx = None
    cx = None
    while i < len(body):
        a, t = body[i]
        cond, k = None, None
        if t == 'mov ax, word ptr [0x685a]' and i + 3 < len(body) and body[i + 3][1].startswith('cmp byte ptr [di + 0x69df]'):
            cond, k = 'SiteDone[W685A + 2] %s 0' % NEG[body[i + 4][1].split()[0]], i + 4
        elif t.startswith('cmp ') or t == 'or ax, ax':
            if t == 'or ax, ax':
                l, r = ax, '0'
            else:
                l, r = [x.strip() for x in t[4:].split(',')]
                m = re.match(r'(?:word|byte) ptr \[di \+ 0x([0-9a-f]+)\]', l)
                l = '%s.%s' % (di, FIELDS[int(m.group(1), 16) - 0x34F2]) if m else opnd(l)
                r = opnd(r)
            j = body[i + 1][1].split()[0]
            cond, k = '%s %s %s' % (l, NEG[j], r), i + 1
        if cond:
            els = tgt(body[k][1])
            then = [x for x in body[k + 1:] if x[0] < els]
            j = k + 1 + len(then)
            if then and then[-1][1].startswith('jmp '):
                join = tgt(then[-1][1])
                then = then[:-1]
                rest = [x for x in body[j:] if x[0] < join]
                j += len(rest)
                out.append(('if', cond, stmts(then), stmts(rest)))
            else:
                out.append(('if', cond, stmts(then), None))
            i = j
            continue
        m = re.match(r'mov ax, (word ptr \[.*\]|0x[0-9a-f]+|\d+)$', t) or re.match(r'mov al, (byte ptr \[.*\]|0x[0-9a-f]+|\d+)$', t)
        if t.startswith('push ') and t not in ('push ax', 'push es', 'push di', 'push cs', 'push ss'):
            stack.append(opnd(t[5:]))
        elif t == 'push ax':
            stack.append(ax)
        elif t == 'push di':
            stack.append(src)
        elif t in ('push es', 'push cs', 'push ss'):
            pass
        elif t == 'lea di, ' + PS:
            src = 'S'
        elif t == 'xor ax, ax':
            ax = '0'
        elif m:
            ax = opnd(m.group(1))
        elif t.startswith('add ax, '):
            ax = '%s + %s' % (paren(ax), opnd(t.split(', ')[1]))
        elif t.startswith('sub ax, '):
            ax = '%s - %s' % (paren(ax), opnd(t.split(', ')[1]))
        elif t == 'dec ax':
            ax = '%s - 1' % paren(ax)
        elif t == 'inc ax':
            ax = '%s + 1' % paren(ax)
        elif t.startswith('mov cx, ') or (t.startswith('mov cl, ') and body[i + 1][1] == 'shl ax, cl'):
            cx = int(t.split(', ')[1], 0)
        elif t == 'shl ax, cl':
            ax = '%s shl %d' % ('(%s)' % ax if ' + ' in ax or ' - ' in ax else ax, cx)
        elif t == 'mov dx, 0xa0' or t == 'mul dx':
            idx = ax
        elif t.startswith('les di, ptr [0x'):
            g = (int(t[t.index('[') + 1:-1], 16) - 0x6D98) // 4 + 1
            src = 'Gfx[%d]^.Tile[%%s]' % g
        elif t == 'add di, ax':
            src = src % idx
        elif t.startswith('add di, '):
            src = src % ((int(t.split(', ')[1], 0) - 3) // 160 + 1)
        elif t == 'mov di, word ptr [0x6854]':
            di = 'Slots[W6854]'
        elif t in ('mov cl, 5', 'shl di, cl'):
            pass
        elif t.startswith('mov word ptr [di + ') or t.startswith('mov byte ptr [di + '):
            d, v = t.split(', ')
            f = FIELDS[int(d[d.index('+') + 2:-1], 16) - 0x34F2]
            out.append('%s.%s := %s' % (di, f, ax if v in ('ax', 'al') else opnd(v)))
        elif t.startswith('mov word ptr [0x') or t.startswith('mov byte ptr [0x'):
            d, v = t.split(', ')
            out.append('%s := %s' % (opnd(d), ax if v in ('ax', 'al') else opnd(v)))
        elif t.startswith('inc word ptr [0x') or t.startswith('inc byte ptr [0x'):
            out.append('Inc(%s)' % opnd(t[4:]))
        elif t in CALLS:
            if t == 'call 0x2c6e' and stack[-1] in ('0', '1'):   # FrontOnly: Boolean
                stack[-1] = ['False', 'True'][int(stack[-1])]
            out.append('%s(%s)' % (CALLS[t], ', '.join(stack)))
            stack = []
        elif t == 'lcall 0x2cd1, 0x980 R':
            ax = 'Random(%s)' % stack.pop()
        elif t.startswith('jmp ') and i == len(body) - 1:
            pass
        else:
            raise ValueError((hex(a), t))
        i += 1
    assert not stack, stack
    return out


def emit(st, ind):
    """statement list -> Pascal at indent ind (a list of more than one becomes begin..end)"""
    def one(x, ind):
        if isinstance(x, str):
            return ind + x
        _, cond, th, el = x
        r = ind + 'if %s then\n' % cond + block(th, ind + '  ')
        if el is not None:
            r += '\n' + ind + 'else\n' + block(el, ind + '  ')
        return r

    def block(lst, ind):
        if len(lst) == 1:
            return one(lst[0], ind)
        return ind[:-2] + 'begin\n' + ';\n'.join(one(x, ind) for x in lst) + ';\n' + ind[:-2] + 'end'
    return block(st, ind)


def gen(L, img, seg, start, end):
    idx = {a: i for i, (a, _) in enumerate(L)}
    i = idx[start]
    out = []
    def head(i):
        return L[i][1] == 'lea di, ' + PS and L[i + 6][1] == 'lcall 0x2cd1, 0x724 R'
    while L[i][0] < end:
        if not head(i):                     # plain statements between the arms
            body = []
            while L[i][0] < end and not head(i):
                body.append(L[i])
                i += 1
            out.append(''.join('  %s;\n' % x for x in [emit([st], '  ').strip() for st in stmts(body)]))
            continue
        c = lit(img, seg, int(L[i + 3][1].split(',')[1], 16))
        assert L[i + 6][1] == 'lcall 0x2cd1, 0x724 R'
        if L[i + 7][1].startswith('je ') and L[i + 8][1].startswith('jmp '):   # long form
            nx = tgt(L[i + 8][1])
            i += 9
        else:
            nx = tgt(L[i + 7][1])
            i += 8
        body = []
        while L[i][0] < nx:
            body.append(L[i])
            i += 1
        out.append('  if S = %s then\n%s;\n' % (c, emit(stmts(body), '    ')))
    return ''.join(out)


def main(argv):
    global PX, PY, PFO, PS, XN
    L = load(argv[1])
    for a in argv:
        if a.startswith('--profile='):
            PX, PY, PFO, PS = PROFILES[a.split('=')[1]]
            XN = 'I' if a.endswith('68A9') else 'X'
    argv = [a for a in argv if not a.startswith('--')]
    NAMES.update(names())
    p = Prog(os.path.join(ROOT, '.work', 'tp', 'SAM1_unp.exe'))
    sys.stdout.write(gen(L, p.img, int(argv[2], 16), int(argv[3], 16), int(argv[4], 16)))


if __name__ == '__main__':
    main(sys.argv)
