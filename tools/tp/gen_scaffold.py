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
    init_end = init + (fns[init]['reached'] if init in fns else 0)
    after = [o for o in starts if o >= init_end]
    if seg == '0000':                                   # main body runs to the next routine
        init_end = after[0] if after else u['size']
        after = [o for o in starts if o >= init_end]
    cuts = sorted({0} | {o for o in starts if o < init}
                  | {h(a[5:]) for a in rec['frame_only'] if a[:4] == seg and h(a[5:]) < init})
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
    obj_start = after[0] if after else None
    if obj_start is not None:
        init_end = obj_start
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


def data_decls(u, public):
    out, names = [], []
    d = u.get('data', {})
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


def keeper_of(regs):
    stubs = [r for r in regs if r[0] == 'stub']
    return max(stubs, key=lambda r: r[3])[1] if stubs else None


def gen_unit(u, rec, fill, regs, keepers_of_units=()):
    seg = u['seg']
    name = unit_name(seg)
    main = seg == '0000'
    decl, dnames = data_decls(u, True)
    stubs = [r for r in regs if r[0] == 'stub']
    obj = [r for r in regs if r[0] == 'obj']
    keeper = keeper_of(regs) if not main else None
    calls = [r[1] for r in stubs if r[1] != keeper] + [r[1] for r in obj]
    # links System 025D (structured value parameter); its prologue grows, so the largest stub carries it
    valpar = max(stubs, key=lambda r: r[3])[1] if main and stubs else None
    L = []
    if main:
        L += ['program SAM1;', '{$S-,D+,L+}', 'uses ' + ', '.join(USES) + ';', KEEPVARS, decl]
    else:
        L += ['unit %s;' % name, '{$S-,D+,L+}', 'interface', decl]
        if keeper:
            L.append('procedure %s;' % keeper)          # exported: the main program calls it (far)
        L.append('implementation')
    if obj:
        L.append('{$L %s.OBJ}' % obj[0][1])
    for r in stubs:
        if r[1] != keeper:
            L.append('procedure %s%s; forward;' % (r[1], '(x: KRec)' if r[1] == valpar else ''))
    for r in obj:
        L.append('procedure %s; external;' % r[1])

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
        L.append('procedure %s%s;' % (r[1], '(x: KRec)' if r[1] == valpar else ''))
        L.append('begin')
        L += body(r[1], calls if r[1] == keeper else [], dnames if r[1] == keeper else [])
        L.append('end;')
    L.append('begin')
    if main:
        L += body('INIT', calls + keepers_of_units, dnames, rtl=True)
    else:
        L += body('INIT', [] if keeper else calls, [] if keeper else dnames)
    L.append('end.')
    text = '\n'.join(x for x in L if x is not None) + '\n'
    open(os.path.join(SRC, name + '.PAS'), 'w').write(text.replace('\n', '\r\n'))
    if obj:
        o = obj[0]
        n = fill.get(o[1], o[3])
        open(os.path.join(SRC, o[1] + '.ASM'), 'w').write(
            'segment CODE public align=1\nglobal %s\n%s:\n    times %d db 0\n' % (o[1], o[1], n))


def begin_lines(path):
    """{routine: line of its `begin`} for a generated unit: a standalone `begin` belongs to the last procedure
    header that is not a forward/external declaration, else to the unit's init / the program body"""
    out, cur = {}, None
    for i, l in enumerate(open(path, encoding='latin1').read().replace('\r', '').split('\n'), 1):
        m = re.match(r'procedure (\w+)(\(.*\))?;$', l)
        if m:
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
    regs = {u['seg']: regions(u, rec) for u in units}
    for u in units:
        f = fill.setdefault(u['seg'], {})
        for kind, name, off, size in regs[u['seg']]:
            if name not in f:
                over = 7 if kind == 'stub' else 7 if kind == 'init' else 0
                f[name] = max(0, size - over)
    for rnd in range(rounds):
        keepers = [keeper_of(regs[u['seg']]) for u in units if u['seg'] != '0000']
        for u in units:
            gen_unit(u, rec, fill[u['seg']], regs[u['seg']], [k for k in keepers if k])
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
                if kind == 'obj':                # TP puts the .OBJ code last; NASM emits exactly its size
                    a = base + lens[name] - fill[u['seg']][rname]
                else:
                    a = ln.get(bl.get(rname))
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
                if got != size:
                    bad += 1
                    if kind != 'obj':
                        fill[u['seg']][rname] = max(0, fill[u['seg']][rname] + size - got)
        print('round %d: %d stubs off; %s' % (rnd, bad, '; '.join(report[:6]) or 'all bases right'))
        if not bad and not report:
            json.dump(fill, open(fill_path, 'w'), indent=1, sort_keys=True)
            return 0
    return 1


if __name__ == '__main__':
    sys.exit(main(sys.argv))
