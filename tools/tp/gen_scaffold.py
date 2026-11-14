#!/usr/bin/env python3
"""Generate the size-exact Pascal scaffold of SAM1 from recipe/units.json, build it, and fit the stubs.

usage: gen_scaffold.py [--rounds N]

MATCHING.md section 4. Writes src/SAM1.PAS, src/U<seg>.PAS, src/GENUS.PAS and src/OBJ<seg>.ASM (filler for the
`{$L}` part of a unit), builds them in .work/scaffold with TP 5.0 (`TPC /GD /B`), reads every stub's address from the
map's line-number table (each stub's `begin` stands alone on its line) and corrects each stub's filler by the
difference, until every stub, init and `.OBJ` block starts at its recipe offset and every segment at its original
base, or N rounds (default 6) pass. Fillers live in src/FILL.JSON so a re-run starts from the last fit.

Unit regions, from the recipe: Pascal chunks [0, init) cut at every routine and frame_only start, the init
[init, init+reached), the `.OBJ` block after it when routines start there. The largest chunk is the unit's keeper:
it calls every other stub and the `.OBJ` block and names every data block with `Inline(>Name)`; it is exported and
the main program body calls it (some inits are empty 7-byte blocks with no room for a call), so TP's smart linker
keeps everything. A unit with no Pascal stubs (Genus) uses its init as the keeper. The main program's keeper is its body, which also holds the runtime
keeper (src/RTLKEEP.INC, pasted: TP 5.0 allows no include in a statement part).
Never reads image bytes: everything comes from the recipe.
"""
import json
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(ROOT, 'src')
BUILD = os.path.join(ROOT, '.work', 'scaffold')
TP = os.path.join(ROOT, '.work', 'toolchains', 'tp50')
LIBS = {'2961', '2CC7', '2CD1'}
USES = ['Dos', 'U29C3', 'Crt', 'U2891', 'U287F', 'U286F', 'GENUS', 'U25E6', 'U1802', 'U0D9C', 'U0529']
KEEPVARS = '''type KRec = array[0..41] of Byte;
var KF: file of KRec; KT: Text; KR: KRec; KS, KS2: string; KRegs: Registers;
    KL: LongInt; KP: Pointer; KI: Integer; KC: Char; KB: Boolean;'''
KEEPVARS_SIZE = 128 + 256 + 42 + 256 + 256 + 20 + 4 + 4 + 2 + 1 + 1


def h(x):
    return int(x, 16)


def unit_name(seg):
    return 'SAM1' if seg == '0000' else 'GENUS' if seg == '2643' else 'U' + seg


def regions(u, rec):
    """[(kind, name, offset, want_size)] in segment order; kinds: stub, init, obj"""
    seg = u['seg']
    fns = {h(f['addr'][5:]): f for f in u['functions']}
    starts = sorted(fns)
    init = h(u['init']) if u.get('init') else h(rec['entry'][5:])
    cuts = sorted({0} | {o for o in starts if o < init}
                  | {h(a[5:]) for a in rec['frame_only'] if a[:4] == seg and h(a[5:]) < init})
    lits = literal_starts(seg)
    if init in lits:                                    # the init's literals: no stub before it from there
        init = lits.pop(init)
        cuts = [c for c in cuts if c < init]
    for off, frm in lits.items():                       # a routine's string literals precede its code
        cuts = sorted((set(cuts) - {off}) | {frm})
    d = os.path.join(SRC, 'match')                      # `{ to: XXXX }`: a fragment ends there, the next
    for f in sorted(os.listdir(d)) if os.path.isdir(d) else []:   # (unmatched) routine's literals follow
        if f.startswith(seg + '_') and f.endswith('.PAS'):
            m = re.search(r'\{ to: ([0-9A-F]{4}) \}', open(os.path.join(d, f)).read())
            if m and h(m.group(1)) < init:              # the next routine's region starts at its literals
                to = h(m.group(1))
                nxt = [c for c in cuts if c > to][:1] if to not in cuts else []   # `from:` made it already
                cuts = sorted((set(cuts) - set(nxt)) | {to})
    if init == 0:
        cuts = []
    merged = []
    for i, c in enumerate(cuts):
        end = cuts[i + 1] if i + 1 < len(cuts) else init
        if merged and end - c < 8:
            continue                                    # a stub needs 7 bytes; the previous one absorbs it
        if not merged and end - c < 8 and i + 1 < len(cuts):
            continue
        merged.append(c)
    out = []
    for i, c in enumerate(merged):
        end = merged[i + 1] if i + 1 < len(merged) else init
        out.append(('stub', 'S%s_%04X' % (seg, c), c, end - c))
    obj_start = h(u['obj_start']) if u.get('obj_start') else None   # recipe: after the init's epilogue
    out.append(('init', 'INIT', init, (obj_start if obj_start is not None else u['code_len']) - init))
    if obj_start is not None:
        out.append(('obj', 'OBJ%s' % seg, obj_start, u['code_len'] - obj_start))
    return out


def inline_items(n, names=()):
    """Inline items emitting exactly n bytes, the named data blocks first (2 bytes each)"""
    items = ['>%s' % x for x in names]
    n -= 2 * len(names)
    if n < 0:
        raise ValueError('filler too small for its references')
    items += ['>$0000'] * (n // 2) + (['$00'] if n % 2 else [])
    lines, cur = [], ''
    for it in items:
        if len(cur) + len(it) + 1 > 100:
            lines.append(cur)
            cur = ''
        cur += it + '/'
    lines.append(cur)
    text = '\n'.join(lines).rstrip('/')
    return 'Inline(' + text + ')' if items else ''


DATAFILL = {}      # seg -> {pinned address or 'END': pad bytes}, kept in FILL.JSON under 'data'


def var_pins(u):
    """[(name, DS address)] of the `{ @XXXX }` lines of the unit's .VAR, in order"""
    vf = os.path.join(SRC, 'match', u['seg'] + '.VAR')
    if not os.path.exists(vf):
        return []
    out = []
    for l in open(vf).read().replace('\r', '').split('\n'):
        m = re.match(r'\s*(?:var\s+|const\s+)?(\w+)[\w, ]*:.*\{ @([0-9A-F]{4}) \}', l)
        if m:
            out.append((m.group(1), m.group(2)))
    return out


def data_decls(u, public):
    """the unit's data declarations and the names to keep: src/match/<SEG>.VAR (hand-written type/var/const
    text) replaces the generated block of the same range; else one byte array per range"""
    out, names = [], []
    d = u.get('data', {})
    vf = os.path.join(SRC, 'match', u['seg'] + '.VAR')
    if os.path.exists(vf):
        text = open(vf).read().replace('\r', '').strip()
        pads = DATAFILL.setdefault(u['seg'], {})
        lines = []
        for l in text.split('\n'):            # `{ @XXXX }` pins a variable's address: a fitted pad goes before it
            m = re.search(r'\{ @([0-9A-F]{4}) \}', l)
            if m and pads.get(m.group(1), 0) > 0:
                lines.append('  P_%s: array[1..%d] of Byte;' % (m.group(1), pads[m.group(1)]))
            lines.append(l)
        if pads.get('END', 0) > 0:
            lines.append('var P_%s_END: array[1..%d] of Byte;' % (u['seg'], pads['END']))
        text = '\n'.join(lines)
        body = re.sub(r'\{[^}]*\}', '', text)
        sect = None
        for l in body.split('\n'):
            w = l.strip().split()
            if w and w[0] in ('type', 'var', 'const'):
                sect = w[0]
                l = l.strip()[len(w[0]):]
            m = re.match(r'\s*([\w, ]+?)\s*:', l)
            if m and sect in ('var', 'const'):
                names += [x.strip() for x in m.group(1).split(',')]
        return text, names
    if 'tconsts' in d:
        a, b = map(h, d['tconsts'])
        n = 'T_%s' % u['seg']
        zeros = ','.join(['0'] * (b - a))
        zeros = re.sub(r'((?:0,){40})', r'\1\n  ', zeros)
        out.append('const %s: array[0..%d] of Byte = (\n  %s);' % (n, b - a - 1, zeros))
        names.append(n)
    if 'vars' in d:
        a, b = map(h, d['vars'])
        size = b - a - (KEEPVARS_SIZE if u['seg'] == '0000' else 0)
        n = 'V_%s' % u['seg']
        out.append('var %s: array[0..%d] of Byte;' % (n, size - 1))
        names.append(n)
    return '\n'.join(out), names


def literal_starts(seg):
    """{routine offset: region start} for fragments with `{ from: XXXX }`: the routine's literals start there"""
    out = {}
    d = os.path.join(SRC, 'match')
    for f in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        if f.startswith(seg + '_') and f.endswith('.PAS'):
            m = re.search(r'\{ from: ([0-9A-F]{4}) \}', open(os.path.join(d, f)).read())
            if m:
                out[h(f[5:9])] = h(m.group(1))
    return out


def fragment(seg, off):
    """a hand-written routine, src/match/<SEG>_<OFF>.PAS, or None. Lines `{ keep: STATEMENT }` (how the keeper uses
    it, so it is linked) and `{ interface }` (declare it in the interface: a far routine) are directives; the
    header is the first procedure/function line; its `begin` stands alone on a line."""
    path, lit = os.path.join(SRC, 'match', '%s_%04X.PAS' % (seg, off)), 0
    for r, frm in literal_starts(seg).items():
        if frm == off:
            path, lit = os.path.join(SRC, 'match', '%s_%04X.PAS' % (seg, r)), r - frm
    if not os.path.exists(path):
        return None
    text = open(path).read().replace('\r', '').rstrip('\n')
    if '{ init }' in text:                          # the unit init / program body: statements only
        return {'text': text, 'init': True, 'interface': False, 'keep': None, 'name': 'INIT', 'head': None, 'lit': lit}
    keep = re.search(r'\{ keep: (.*) \}', text)
    head = next(l for l in text.split('\n') if re.match(r'(procedure|function) ', l))
    name = re.match(r'(?:procedure|function) (\w+)', head).group(1)
    return {'text': text, 'keep': keep.group(1) if keep else name, 'head': head, 'name': name, 'lit': lit,
            'interface': '{ interface }' in text, 'init': False}


def externals(seg):
    """asm routines of a unit's {$L} block that Pascal code calls: src/match/<SEG>_<OFF>.EXT holds the Pascal
    external declaration (e.g. `{$F+} function ReadAxis(Axis: Word): Word; external; {$F-}`); the generator puts
    a label of that name at OFF in the unit's .OBJ"""
    out = []
    d = os.path.join(SRC, 'match')
    for f in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        if f.startswith(seg + '_') and f.endswith('.EXT'):
            text = open(os.path.join(d, f)).read().replace('\r', '').strip()
            kind, name = re.search(r'(procedure|function) (\w+)', text).groups()
            iface = '{ interface }' in text
            text = re.sub(r'\{ (src|interface)[^}]*\}\s*', '', text).strip()
            out.append({'off': h(f[5:9]), 'name': name, 'kind': kind, 'text': text, 'interface': iface})
    return out


def outside_keeps(units, regs):
    """statements the main program body runs to keep what units export: each unit's keeper, its interface
    routines (their `keep:` statement) and its .OBJ entry"""
    out = []
    for u in units:
        if u['seg'] == '0000':
            continue
        k = keeper_of(regs[u['seg']])
        if k:
            out.append(k)
        for kind, rname, off, size in regs[u['seg']]:
            f = fragment(u['seg'], off) if kind == 'stub' else None
            if f and f['interface']:
                out.append(f['keep'])
            if kind == 'obj':
                out.append(rname)
    return out


def signature(seg, off):
    """src/match/<SEG>_<OFF>.SIG: an unmatched routine's real header (`{$F+} function ReadMenuKey: Char;`), so
    matched code can call its stub; `{ keep: STATEMENT }` keeps it from the keeper (default: none, a matched
    caller keeps it)"""
    path = os.path.join(SRC, 'match', '%s_%04X.SIG' % (seg, off))
    d = os.path.join(SRC, 'match')
    tos = {h(m) for f in os.listdir(d) if f.startswith(seg + '_') and f.endswith('.PAS')
           for m in re.findall(r'\{ to: ([0-9A-F]{4}) \}', open(os.path.join(d, f)).read())}
    if not os.path.exists(path) and off in tos:         # the region starts at the routine's literals
        sigs = sorted(h(f[5:9]) for f in os.listdir(d) if f.startswith(seg + '_') and f.endswith('.SIG'))
        nxt = [o for o in sigs if off < o < off + 0x100]
        if nxt:
            path = os.path.join(d, '%s_%04X.SIG' % (seg, nxt[0]))
    if not os.path.exists(path):
        return None
    text = open(path).read().replace('\r', '')
    head = next(l for l in text.split('\n') if re.search(r'\b(procedure|function) ', l))
    far = '{$F+}' in head
    head = re.sub(r'\{\$F[+-]\}', '', head).strip()
    keep = re.search(r'\{ keep: (.*) \}', text)
    return {'head': head, 'far': far, 'name': re.search(r'(?:procedure|function) (\w+)', head).group(1),
            'keep': keep.group(1) if keep else '-', 'lit': h(os.path.basename(path)[5:9]) - off}


def keeper_of(regs):
    stubs = [r for r in regs if r[0] == 'stub' and not fragment(r[1][1:5], r[2]) and not signature(r[1][1:5], r[2])]
    return max(stubs, key=lambda r: r[3])[1] if stubs else None


def gen_unit(u, rec, fill, regs, keepers_of_units=(), unit_data=()):
    seg = u['seg']
    name = unit_name(seg)
    main = seg == '0000'
    decl, dnames = data_decls(u, True)
    if not main:
        dnames = []                         # unit data is in the interface; the main body keeps it
    stubs = [r for r in regs if r[0] == 'stub']
    frags = {r[1]: fragment(seg, r[2]) for r in stubs}
    sigs = {r[1]: signature(seg, r[2]) for r in stubs if not frags[r[1]]}
    plain = [r for r in stubs if not frags[r[1]] and not sigs.get(r[1])]
    obj = [r for r in regs if r[0] == 'obj']
    keeper = keeper_of(regs) if not main else None
    # the unit keeps its private routines; what other units can see (keeper, interface routines, the .OBJ entry)
    # is kept from the main program body (outside_keeps)
    calls = [frags[r[1]]['keep'] if frags[r[1]] else sigs[r[1]]['keep'] if sigs.get(r[1]) else r[1] for r in stubs
             if r[1] != keeper and not (frags[r[1]] and (frags[r[1]]['interface'] or frags[r[1]]['keep'] == '-'))
             and not (sigs.get(r[1]) and sigs[r[1]]['keep'] == '-')]
    if main:
        calls += [r[1] for r in obj]
    # links System 025D (structured value parameter); its prologue grows, so the largest stub carries it
    valpar = max(plain, key=lambda r: r[3])[1] if main and plain else None
    L = []
    if main:
        L += ['program SAM1;', '{$S-,D+,L+}', 'uses ' + ', '.join(USES) + ';', KEEPVARS, decl]
    else:
        L += ['unit %s;' % name, '{$S-,D+,L+}', 'interface']
        uf = os.path.join(SRC, 'match', seg + '.USES')      # the units this one uses, e.g. `uses U29C3;`
        if os.path.exists(uf):
            L.append(open(uf).read().replace('\r', '').strip())
        L.append(decl)
        if keeper:
            L.append('procedure %s;' % keeper)          # exported: the main program calls it (far)
        L += [f['head'] for f in frags.values() if f and f['interface']]
        L += ['procedure %s;' % r[1] for r in obj]
        L += [re.sub(r'\{\$F[+-]\}|external;', '', e['text']).strip() for e in externals(seg) if e['interface']]
        L.append('implementation')
    if obj:
        L.append('{$L %s.OBJ}' % obj[0][1])
    for r in stubs:
        f = frags[r[1]]
        if f and not f['interface']:                # a far private routine's forward is far too
            L.append(('{$F+} %s forward; {$F-}' if '{$F+}' in f['text'] else '%s forward;') % f['head'])
        elif sigs.get(r[1]):
            g = sigs[r[1]]
            L.append(('{$F+} %s forward; {$F-}' if g['far'] else '%s forward;') % g['head'])
        elif not f and r[1] != keeper:
            L.append('procedure %s%s; forward;' % (r[1], '(x: KRec)' if r[1] == valpar else ''))
    for r in obj:
        L.append('procedure %s; external;' % r[1])
        L += [e['text'] if not e['interface'] else '%s %s; external;' % (e['kind'], e['name'])
              for e in externals(seg)]

    def body(rname, extra_calls, refs, rtl=False):
        stmts = []
        if rtl:
            stmts += [l for l in open(os.path.join(SRC, 'RTLKEEP.INC')).read().split('\n')
                      if l.strip() and not l.startswith(('{', '  '))]
        stmts += ['%s%s;' % (c, '(KR)' if c == valpar else '') for c in extra_calls]
        inl = inline_items(fill.get(rname, 0), refs)
        if inl:
            stmts.append(inl)
        return stmts

    for r in stubs:
        if frags[r[1]]:
            L += frags[r[1]]['text'].split('\n')
            continue
        g = sigs.get(r[1])
        if g and g['far']:
            L.append('{$F+}')
        L.append(g['head'] if g else 'procedure %s%s;' % (r[1], '(x: KRec)' if r[1] == valpar else ''))
        if g and g['lit'] > 1:                      # a string literal of the same size before the code, as the
            L += ['var', '  Q_: String;', 'begin',     # original (a 1-char constant is a Char unless compared
                  "  if Q_ = '%s' then;" % ('x' * (g['lit'] - 1))]           # with a string)
        else:
            L.append('begin')
        L += body(r[1], calls if r[1] == keeper else [], dnames if r[1] == keeper else [])
        L.append('end;')
        if g and g['far']:
            L.append('{$F-}')
    L.append('begin')
    if main:
        L += body('INIT', calls + list(keepers_of_units), dnames + list(unit_data), rtl=True)
    else:
        init_off = next(r[2] for r in regs if r[0] == 'init')
        fi = fragment(seg, init_off)
        if fi:
            if not keeper and (calls or dnames):
                raise ValueError('%s: a hand-written init but nothing else keeps %s' % (name, calls + dnames))
            L += [l for l in fi['text'].split('\n') if l.strip()]
        else:
            L += body('INIT', [] if keeper else calls, [] if keeper else dnames)
    L.append('end.')
    text = '\n'.join(x for x in L if x is not None) + '\n'
    open(os.path.join(SRC, name + '.PAS'), 'w').write(text.replace('\n', '\r\n'))
    if obj:
        o = obj[0]
        n = o[3]                            # never fitted: its size is the region's
        fill[o[1]] = n
        hand = os.path.join(SRC, 'match', o[1] + '.ASM')     # tools/tp/obj2asm.py: the block as NASM source
        if os.path.exists(hand):
            open(os.path.join(SRC, o[1] + '.ASM'), 'w').write(open(hand).read())
            return
        asm = ['segment CODE public align=1', 'global %s' % o[1], '%s:' % o[1]]
        at = 0
        for e in externals(seg):            # a label at each named asm routine, filler between
            rel = e['off'] - o[2]
            if not 0 <= rel <= n or rel < at:
                raise ValueError('%s_%04X.EXT lies outside the .OBJ block' % (seg, e['off']))
            asm += ['    times %d db 0' % (rel - at), 'global %s' % e['name'].upper(), '%s:' % e['name'].upper()]
            at = rel
        asm.append('    times %d db 0' % (n - at))
        open(os.path.join(SRC, o[1] + '.ASM'), 'w').write('\n'.join(asm) + '\n')


def begin_lines(path):
    """{routine: line of its `begin`} for a generated unit: a standalone `begin` belongs to the last procedure
    header that is not a forward/external declaration, else to the unit's init / the program body"""
    out, cur = {}, None
    for i, l in enumerate(open(path, encoding='latin1').read().replace('\r', '').split('\n'), 1):
        m = re.match(r'(?:procedure|function) (\w+)\b(?!.*\b(?:forward|external);)', l)
        if l == 'implementation':
            cur = None                                  # interface headers have no body here
        elif m:
            cur = m.group(1)
        elif l == 'begin':
            out[cur or 'INIT'] = i
            cur = None
    return out


def read_map(path):
    m = open(path, encoding='latin1').read().replace('\r', '')
    segs = {n: int(s, 16) for s, n in re.findall(r'\s([0-9A-F]{5})H [0-9A-F]{5}H [0-9A-F]{5}H (\S+)\s+CODE', m)}
    lens = {n: int(l, 16) for l, n in re.findall(r'\s[0-9A-F]{5}H [0-9A-F]{5}H ([0-9A-F]{5})H (\S+)\s+CODE', m)}
    lines = {}
    for unit, sec in re.findall(r'Line numbers for (\w+)\([^)]*\) segment \w+\n\n(.*?)\n\n', m, re.S):
        lines[unit] = {int(n): int(s, 16) * 16 + int(o, 16) for n, s, o in re.findall(r'(\d+) ([0-9A-F]{4}):([0-9A-F]{4})', sec)}
    pubs = {n: int(s, 16) * 16 + int(o, 16) for s, o, n in re.findall(r'\s([0-9A-F]{4}):([0-9A-F]{4})\s+(\w+)\n', m)}
    return segs, lens, lines, pubs


def build():
    if os.path.isdir(BUILD):
        shutil.rmtree(BUILD)
    os.makedirs(BUILD)
    for f in os.listdir(SRC):
        if f.endswith('.ASM'):
            subprocess.run(['nasm', '-f', 'obj', '-o', os.path.join(BUILD, f[:-4] + '.OBJ'), os.path.join(SRC, f)],
                           check=True)
        elif f.endswith('.PAS'):
            shutil.copy(os.path.join(SRC, f), BUILD)
    r = subprocess.run([os.path.join(ROOT, 'tools', 'tp', 'tpc.sh'), TP, BUILD, 'SAM1.PAS', '/GD', '/B'],
                       capture_output=True, text=True)
    return r.returncode == 0, r.stdout.strip()


def main(argv):
    rounds = int(argv[argv.index('--rounds') + 1]) if '--rounds' in argv else 6
    rec = json.load(open(os.path.join(ROOT, 'recipe', 'units.json')))
    units = [u for u in rec['units'] if u['seg'] not in LIBS]
    bases = {u['seg']: u['image_offset'] for u in rec['units']}
    for u in rec['units']:
        u['code_len'] = u['size']
    fill_path = os.path.join(SRC, 'FILL.JSON')
    fill = json.load(open(fill_path)) if os.path.exists(fill_path) else {}
    DATAFILL.update(fill.setdefault('data', {}))
    fill['data'] = DATAFILL
    regs = {u['seg']: regions(u, rec) for u in units}
    for u in units:
        f = fill.setdefault(u['seg'], {})
        for kind, name, off, size in regs[u['seg']]:
            if name not in f:
                over = 7 if kind == 'stub' else 7 if kind == 'init' else 0
                f[name] = max(0, size - over)
    for rnd in range(rounds):
        keepers = outside_keeps(units, regs)
        udata = [n for u in units if u['seg'] != '0000' for n in data_decls(u, True)[1]]
        for u in units:
            gen_unit(u, rec, fill[u['seg']], regs[u['seg']], [k for k in keepers if k], udata)
        json.dump(fill, open(fill_path, 'w'), indent=1, sort_keys=True)
        ok, msg = build()
        if not ok:
            print('round %d: build failed:\n%s' % (rnd, msg[-600:]))
            return 1
        segs, lens, lines, pubs = read_map(os.path.join(BUILD, 'SAM1.MAP'))
        bad = 0
        report = []
        for u in units:
            name = unit_name(u['seg'])
            base = segs.get(name)
            if base is None:
                print('round %d: %s missing from the map' % (rnd, name))
                return 1
            if base != bases[u['seg']]:
                report.append('%s base %05X want %05X' % (name, base, bases[u['seg']]))
            bl = begin_lines(os.path.join(SRC, name + '.PAS'))
            ln = lines.get(name, {})
            actual = {}
            for kind, rname, off, size in regs[u['seg']]:
                fr = fragment(u['seg'], off) if kind == 'stub' else None
                if fr:
                    a = ln.get(bl.get(fr['name']))
                    a = a - fr['lit'] if a is not None else None    # its string literals precede the code
                elif kind == 'obj':                # TP puts the .OBJ code last; NASM emits exactly its size
                    a = base + lens[name] - fill[u['seg']][rname]
                else:
                    g = signature(u['seg'], off) if kind == 'stub' else None
                    a = ln.get(bl.get(g['name'] if g else rname))
                    if g and a is not None:
                        a -= g['lit']
                    fi = fragment(u['seg'], off) if kind == 'init' else None
                    if fi and a is not None:
                        a -= fi['lit']
                actual[rname] = None if a is None else a - base
            order = regs[u['seg']]
            for i, (kind, rname, off, size) in enumerate(order):
                start = actual[rname]
                nxt = actual[order[i + 1][1]] if i + 1 < len(order) else lens[name]
                if start is None or nxt is None:
                    report.append('%s %s not found in map' % (name, rname))
                    bad += 1
                    continue
                if start != off:
                    bad += 1
                got = nxt - start
                last = i + 1 == len(order)
                if last and got <= size < got + 16 and (base + start + got + 15) // 16 * 16 == base + u['size']:
                    got = size                          # the segment's paragraph padding follows the last region
                if got != size:
                    bad += 1
                    if kind in ('stub', 'init') and fragment(u['seg'], off):
                        report.append('%s %s is %d bytes, wants %d' % (name, rname, got, size))
                    elif kind != 'obj':
                        fill[u['seg']][rname] = max(0, fill[u['seg']][rname] + size - got)
        ds = int(re.search(r'\s([0-9A-F]{5})H [0-9A-F]{5}H [0-9A-F]{5}H DATA\s', open(os.path.join(BUILD, 'SAM1.MAP')).read()).group(1), 16)
        for u in units:
            d = u.get('data', {}) if u['seg'] != '0000' else {}   # main's vars follow the RTL keeper vars
            for kind in ('tconsts', 'vars'):
                if kind not in d:
                    continue
                first = data_decls(u, True)[1]
                first = [n for n in first if (n.startswith('T_') if kind == 'tconsts' else not n.startswith('T_'))]
                a = pubs.get(first[0].upper()) if first else None
                if a is None or a - ds != h(d[kind][0]):
                    bad += 1
                    report.append('%s %s %s at %s, wants DS:%s' % (unit_name(u['seg']), kind, first[:1],
                                  'missing' if a is None else 'DS:%04X' % (a - ds), d[kind][0]))
        dunits = [u for u in units if 'vars' in u.get('data', {}) and u['seg'] != '0000']
        dunits.sort(key=lambda u: h(u['data']['vars'][0]))
        for i, u in enumerate(dunits):
            pins = var_pins(u)
            if not pins:
                continue
            pads, prev = DATAFILL.setdefault(u['seg'], {}), 0
            nxt = dunits[i + 1] if i + 1 < len(dunits) else None
            nref = (var_pins(nxt)[:1] or [('V_' + nxt['seg'], nxt['data']['vars'][0])]) if nxt else []
            nfirst = nref[0][0] if nref else None
            for name, want in pins + nref:
                a = pubs.get(name.upper())
                if a is None:
                    bad += 1
                    report.append('%s not in map' % name)
                    break
                err = h(want) - (a - ds)
                key = want if name != nfirst else 'END'
                if err != prev:
                    bad += 1
                    report.append('%s at DS:%04X, wants DS:%s' % (name, a - ds, want))
                    pads[key] = pads.get(key, 0) + err - prev
                    if pads[key] < 0:
                        report.append('%s: the declarations before it are %d bytes too long' % (name, -pads[key]))
                        pads[key] = 0
                prev = err
        print('round %d: %d stubs off; %s' % (rnd, bad, '; '.join(report[:6]) or 'all bases right'))
        if not bad and not report:
            json.dump(fill, open(fill_path, 'w'), indent=1, sort_keys=True)
            return 0
    return 1


if __name__ == '__main__':
    sys.exit(main(sys.argv))
