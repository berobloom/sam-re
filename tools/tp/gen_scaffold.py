#!/usr/bin/env python3
"""Assemble SAM1's Turbo Pascal 5.0 source from src/match/, build it, check the layout and fit the data pads.

usage: gen_scaffold.py [--rounds N]

MATCHING.md section 4. Writes src/SAM1.PAS, src/U<seg>.PAS, src/GENUS.PAS and src/OBJ<seg>.ASM, builds them in
.work/scaffold with TP 5.0 (`TPC /GD /B`), and reads the map: every unit must sit at its original base, every routine,
init and `.OBJ` block at its recipe offset with its recipe size (each routine's `begin` stands alone on its line,
so the map's line-number table gives its address), and every pinned variable at its DS address. Only the data pads
are fitted (`{ @XXXX }` pins, src/FILL.JSON under `data`); they are saved after a round that is all right, so a
failed build never leaves pads fitted to a broken layout. Up to N rounds (default 6).

Per unit, from src/match/: `<SEG>_<OFF>_<Name>.PAS` the routines (directives: `{ interface }` declares it in the
interface, `{ init }` marks the unit init / program body, `{ from: XXXX }` its string literals start there,
`{ to: XXXX }` the next routine's literals start there, `{ nested: XXXX .. }` routines declared inside it),
`<SEG>_<OFF>_<Name>.EXT` the asm entry points, `OBJ<SEG>.ASM` the `{$L}` block (tools/tp/obj2asm.py), `<SEG>.VAR` the
data, `<SEG>.USES` the uses clause. The routine regions come from recipe/units.json; nothing reads image bytes.
"""
import json
import os
import re
import shutil
import subprocess
import sys

import srcfiles

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(ROOT, 'src')
MATCH = os.path.join(SRC, 'match')
BUILD = os.path.join(ROOT, '.work', 'scaffold')
TP = os.path.join(ROOT, '.work', 'toolchains', 'tp50')
LIBS = {'2961', '2CC7', '2CD1'}
USES = ['Dos', 'U29C3', 'Crt', 'U2891', 'U287F', 'U286F', 'GENUS', 'U25E6', 'U1802', 'U0D9C', 'U0529']
DATAFILL = {}      # seg -> {pinned address or 'END': pad bytes}, kept in FILL.JSON under 'data'


def h(x):
    return int(x, 16)


def unit_name(seg):
    return 'SAM1' if seg == '0000' else 'GENUS' if seg == '2643' else 'U' + seg


def match_files(seg, ext):
    return [f for f in sorted(os.listdir(MATCH)) if f.startswith(seg + '_') and f.endswith(ext)]


def read(path):
    return open(path, encoding='latin1').read().replace('\r', '')


def directive_map(seg, name):
    """{routine offset: directive argument} for the fragments with `{ name: ... }`"""
    out = {}
    for f in match_files(seg, '.PAS'):
        m = re.search(r'\{ %s: ([0-9A-F ]+) \}' % name, read(os.path.join(MATCH, f)))
        if m:
            out[h(f[5:9])] = m.group(1)
    return out


def literal_starts(seg):
    """{routine offset: region start} for fragments with `{ from: XXXX }`: the routine's literals start there"""
    return {o: h(a) for o, a in directive_map(seg, 'from').items()}


def regions(u, rec):
    """[(kind, name, offset, size)] in segment order; kinds: proc, init, obj"""
    seg = u['seg']
    init = h(u['init']) if u.get('init') else h(rec['entry'][5:])
    cuts = sorted({0} | {h(f['addr'][5:]) for f in u['functions'] if h(f['addr'][5:]) < init}
                  | {h(a[5:]) for a in rec['frame_only'] if a[:4] == seg and h(a[5:]) < init})
    lits = literal_starts(seg)
    if init in lits:                                    # the init's literals: no routine before it from there
        init = lits.pop(init)
        cuts = [c for c in cuts if c < init]
    for off, frm in lits.items():                       # a routine's string literals precede its code
        cuts = sorted((set(cuts) - {off}) | {frm})
    nested = {h(x) for v in directive_map(seg, 'nested').values() for x in v.split()}
    cuts = sorted(set(cuts) - nested)                   # nested routines are part of their parent's region
    for to in sorted(h(v) for v in directive_map(seg, 'to').values()):   # a fragment ends there, the next
        if to < init:                                   # routine's region starts at its literals
            nxt = [c for c in cuts if c > to][:1] if to not in cuts else []
            cuts = sorted((set(cuts) - set(nxt)) | {to})
    if init == 0:
        cuts = []
    out = [('proc', 'S%s_%04X' % (seg, c), c, (cuts[i + 1] if i + 1 < len(cuts) else init) - c)
           for i, c in enumerate(cuts)]
    obj_start = h(u['obj_start']) if u.get('obj_start') else None   # recipe: after the init's epilogue
    out.append(('init', 'INIT', init, (obj_start if obj_start is not None else u['code_len']) - init))
    if obj_start is not None:
        out.append(('obj', 'OBJ%s' % seg, obj_start, u['code_len'] - obj_start))
    return out


def fragment(seg, off):
    """the routine whose region starts at OFF: src/match/<SEG>_<OFF>_<Name>.PAS (or the one whose `{ from: }` is
    OFF); its header is the first procedure/function line, its `begin` stands alone on a line"""
    path, lit = srcfiles.find(seg, off), 0
    for r, frm in literal_starts(seg).items():
        if frm == off:
            path, lit = srcfiles.find(seg, r), r - frm
    if not path:
        raise SystemExit('%s: no routine for %s:%04X (src/match/%s_%04X_<Name>.PAS)' % (unit_name(seg), seg, off,
                                                                                        seg, off))
    text = read(path).rstrip('\n')
    if '{ init }' in text:                          # the unit init / program body: statements only
        return {'text': text, 'init': True, 'interface': False, 'name': 'INIT', 'head': None, 'lit': lit}
    head = next(l for l in text.split('\n') if re.match(r'(procedure|function) ', l))
    return {'text': text, 'head': head, 'name': re.match(r'(?:procedure|function) (\w+)', head).group(1),
            'lit': lit, 'interface': '{ interface }' in text, 'init': False}


def externals(seg):
    """asm routines of a unit's {$L} block: src/match/<SEG>_<OFF>_<Name>.EXT holds the Pascal external declaration
    (e.g. `{$F+} function ReadAxis(Axis: Word): Word; external; {$F-}`)"""
    out = []
    for f in match_files(seg, '.EXT'):
        text = read(os.path.join(MATCH, f)).strip()
        kind, name = re.search(r'(procedure|function) (\w+)', text).groups()
        iface = '{ interface }' in text
        text = re.sub(r'\{ (src|interface)[^}]*\}\s*', '', text).strip()
        out.append({'off': h(f[5:9]), 'name': name, 'kind': kind, 'text': text, 'interface': iface})
    return out


def var_pins(u):
    """[(name, DS address)] of the `{ @XXXX }` (or `{ @XXXX; note }`) lines of the unit's .VAR, in order"""
    vf = os.path.join(MATCH, u['seg'] + '.VAR')
    if not os.path.exists(vf):
        return []
    out = []
    for l in read(vf).split('\n'):
        m = re.match(r'\s*(?:var\s+|const\s+)?(\w+)[\w, ]*:.*\{ @([0-9A-F]{4})[ ;]', l)
        if m:
            out.append((m.group(1), m.group(2)))
    return out


def data_decls(u):
    """the unit's data declarations (src/match/<SEG>.VAR with the fitted pads) and the variable names"""
    vf = os.path.join(MATCH, u['seg'] + '.VAR')
    if not os.path.exists(vf):
        if u.get('data'):
            raise SystemExit('%s has data but no src/match/%s.VAR' % (unit_name(u['seg']), u['seg']))
        return '', []
    text = read(vf).strip()
    pads = DATAFILL.setdefault(u['seg'], {})
    lines = []
    for l in text.split('\n'):            # `{ @XXXX }` pins a variable's address: a fitted pad goes before it
        m = re.search(r'\{ @([0-9A-F]{4})[ ;]', l)
        if m and pads.get(m.group(1), 0) > 0:
            lines.append('  P_%s: array[1..%d] of Byte;' % (m.group(1), pads[m.group(1)]))
        lines.append(l)
    if pads.get('END', 0) > 0:          # in the last var section: TP 5.0 drops a var section nothing uses
        last = re.findall(r'^\s*(type|var|const)\b', re.sub(r'\{[^}]*\}', '', text), re.M)
        lines.append('%sP_%s_END: array[1..%d] of Byte;' % ('  ' if last and last[-1] == 'var' else 'var ',
                                                             u['seg'], pads['END']))
    text = '\n'.join(lines)
    names, sect = [], None
    for l in re.sub(r'\{[^}]*\}', '', text).split('\n'):
        w = l.strip().split()
        if w and w[0] in ('type', 'var', 'const'):
            sect = w[0]
            l = l.strip()[len(w[0]):]
        m = re.match(r'\s*([\w, ]+?)\s*:', l)
        if m and sect in ('var', 'const'):
            names += [x.strip() for x in m.group(1).split(',')]
    return text, names


def gen_unit(u, regs):
    seg = u['seg']
    name = unit_name(seg)
    main = seg == '0000'
    decl = data_decls(u)[0]
    procs = [r for r in regs if r[0] == 'proc']
    frags = {r[1]: fragment(seg, r[2]) for r in procs}
    obj = [r for r in regs if r[0] == 'obj']
    L = []
    if main:
        L += ['program SAM1;', '{$S-,D+,L+}', 'uses ' + ', '.join(USES) + ';', decl]
    else:
        L += ['unit %s;' % name, '{$S-,D+,L+}', 'interface']
        uf = os.path.join(MATCH, seg + '.USES')      # the units this one uses, e.g. `uses U29C3;`
        if os.path.exists(uf):
            L.append(read(uf).strip())
        L.append(decl)
        L += [f['head'] for f in frags.values() if f['interface']]
        L += ['procedure %s;' % r[1] for r in obj]
        L += [re.sub(r'\{\$F[+-]\}|external;', '', e['text']).strip() for e in externals(seg) if e['interface']]
        L.append('implementation')
    if obj:
        L.append('{$L %s.OBJ}' % obj[0][1])
    for f in frags.values():
        if not f['interface']:                      # a far private routine's forward is far too
            L.append(('{$F+} %s forward; {$F-}' if '{$F+}' in f['text'] else '%s forward;') % f['head'])
    for r in obj:
        L.append('procedure %s; external;' % r[1])
        L += [e['text'] if not e['interface'] else '%s %s; external;' % (e['kind'], e['name'])
              for e in externals(seg)]
    for f in frags.values():
        text = f['text']
        if ' interrupt;' in f['head'] and not f['interface']:   # forwarded: TP takes no directive again
            text = text.replace(f['head'], f['head'].replace(' interrupt;', ''), 1)
        L += text.split('\n')
    L.append('begin')
    L += [l for l in fragment(seg, next(r[2] for r in regs if r[0] == 'init'))['text'].split('\n') if l.strip()]
    L.append('end.')
    open(os.path.join(SRC, name + '.PAS'), 'w', encoding='latin1').write('\r\n'.join(L) + '\r\n')
    if obj:
        hand = os.path.join(MATCH, obj[0][1] + '.ASM')     # tools/tp/obj2asm.py: the block as NASM source
        if not os.path.exists(hand):
            raise SystemExit('%s: no src/match/%s.ASM (tools/tp/obj2asm.py %s)' % (name, obj[0][1], seg))
        shutil.copy(hand, os.path.join(SRC, obj[0][1] + '.ASM'))


def begin_lines(path):
    """{routine: line of its `begin`} for a generated unit: a standalone `begin` belongs to the last procedure
    header that is not a forward/external declaration, else to the unit's init / the program body"""
    out, cur = {}, None
    for i, l in enumerate(read(path).split('\n'), 1):
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
    m = read(path)
    segs = {n: int(s, 16) for s, n in re.findall(r'\s([0-9A-F]{5})H [0-9A-F]{5}H [0-9A-F]{5}H (\S+)\s+CODE', m)}
    lens = {n: int(l, 16) for l, n in re.findall(r'\s[0-9A-F]{5}H [0-9A-F]{5}H ([0-9A-F]{5})H (\S+)\s+CODE', m)}
    lines = {}
    for unit, sec in re.findall(r'Line numbers for (\w+)\([^)]*\) segment \w+\n\n(.*?)\n\n', m, re.S):
        lines[unit] = {int(n): int(s, 16) * 16 + int(o, 16) for n, s, o in re.findall(r'(\d+) ([0-9A-F]{4}):([0-9A-F]{4})', sec)}
    pubs = {n: int(s, 16) * 16 + int(o, 16) for s, o, n in re.findall(r'\s([0-9A-F]{4}):([0-9A-F]{4})\s+(\w+)\n', m)}
    ds = int(re.search(r'\s([0-9A-F]{5})H [0-9A-F]{5}H [0-9A-F]{5}H DATA\s', m).group(1), 16)
    return segs, lens, lines, pubs, ds


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


def check_code(units, regs, bases, segs, lens, lines):
    """report lines for every unit base, routine, init and .OBJ block off its recipe offset or size"""
    report = []
    for u in units:
        name = unit_name(u['seg'])
        base = segs.get(name)
        if base is None:
            report.append('%s missing from the map' % name)
            continue
        if base != bases[u['seg']]:
            report.append('%s base %05X want %05X' % (name, base, bases[u['seg']]))
        bl = begin_lines(os.path.join(SRC, name + '.PAS'))
        ln = lines.get(name, {})
        order = regs[u['seg']]
        actual = []
        for kind, rname, off, size in order:
            if kind == 'obj':                       # TP puts the .OBJ code last; NASM emits exactly its size
                actual.append(lens[name] - size)
                continue
            f = fragment(u['seg'], off)
            a = ln.get(bl.get(f['name']))
            actual.append(None if a is None else a - f['lit'] - base)   # its string literals precede the code
        for i, (kind, rname, off, size) in enumerate(order):
            start = actual[i]
            nxt = actual[i + 1] if i + 1 < len(order) else lens[name]
            if start is None or nxt is None:
                report.append('%s %s:%04X not found in the map' % (name, u['seg'], off))
                continue
            got = nxt - start
            if i + 1 == len(order) and got <= size < got + 16 and \
                    (base + start + got + 15) // 16 * 16 == base + u['size']:
                got = size                          # the segment's paragraph padding follows the last region
            if start != off or got != size:
                report.append('%s %s %s:%04X at %04X, %d bytes; wants %04X, %d' % (name, kind, u['seg'], off,
                                                                                   start, got, off, size))
    return report


def fit_data(units, pubs, ds):
    """report lines for misplaced data, and the pad corrections (into DATAFILL) that move it"""
    report = []
    for u in units:
        d = u.get('data', {}) if u['seg'] != '0000' else {}
        for kind in ('tconsts', 'vars'):
            if kind not in d:
                continue
            first = [n for n in data_decls(u)[1] if n.startswith('T_') == (kind == 'tconsts')]
            a = pubs.get(first[0].upper()) if first else None
            if a is None or a - ds != h(d[kind][0]):
                report.append('%s %s %s at %s, wants DS:%s' % (unit_name(u['seg']), kind, first[:1],
                              'missing' if a is None else 'DS:%04X' % (a - ds), d[kind][0]))
    dunits = sorted((u for u in units if 'vars' in u.get('data', {}) and u['seg'] != '0000'),
                    key=lambda u: h(u['data']['vars'][0]))
    for i, u in enumerate(dunits):
        pins = var_pins(u)
        if not pins:
            continue
        pads, prev = DATAFILL.setdefault(u['seg'], {}), 0
        nxt = dunits[i + 1] if i + 1 < len(dunits) else None
        nvars = [n for n in data_decls(nxt)[1] if not n.startswith('T_')] if nxt else []
        nref = (var_pins(nxt)[:1] or [(nvars[0], nxt['data']['vars'][0])]) if nxt else []
        nfirst = nref[0][0] if nref else None
        for name, want in pins + nref:
            a = pubs.get(name.upper())
            if a is None:
                report.append('%s not in map' % name)
                break
            err = h(want) - (a - ds)
            key = want if name != nfirst else 'END'
            if err != prev:
                report.append('%s at DS:%04X, wants DS:%s' % (name, a - ds, want))
                pads[key] = pads.get(key, 0) + err - prev
                if pads[key] < 0:
                    report.append('%s: the declarations before it are %d bytes too long' % (name, -pads[key]))
                    pads[key] = 0
            prev = err
    return report


def main(argv):
    rounds = int(argv[argv.index('--rounds') + 1]) if '--rounds' in argv else 6
    rec = json.load(open(os.path.join(ROOT, 'recipe', 'units.json')))
    units = [u for u in rec['units'] if u['seg'] not in LIBS]
    bases = {u['seg']: u['image_offset'] for u in rec['units']}
    for u in rec['units']:
        u['code_len'] = u['size']
    fill_path = os.path.join(SRC, 'FILL.JSON')
    DATAFILL.update((json.load(open(fill_path)) if os.path.exists(fill_path) else {}).get('data', {}))
    regs = {u['seg']: regions(u, rec) for u in units}
    for rnd in range(rounds):
        for u in units:
            gen_unit(u, regs[u['seg']])
        ok, msg = build()
        if not ok:
            print('round %d: build failed:\n%s' % (rnd, msg[-600:]))
            return 1
        segs, lens, lines, pubs, ds = read_map(os.path.join(BUILD, 'SAM1.MAP'))
        code = check_code(units, regs, bases, segs, lens, lines)
        data = fit_data(units, pubs, ds)
        print('round %d: %s' % (rnd, '; '.join((code + data)[:6]) or 'all bases right'))
        if not code and not data:
            json.dump({'data': DATAFILL}, open(fill_path, 'w'), indent=1, sort_keys=True)
            return 0
        if code and not data:
            return 1                                # only a source change moves code
    return 1


if __name__ == '__main__':
    sys.exit(main(sys.argv))
