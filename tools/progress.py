#!/usr/bin/env python3
"""progress.py: writes PROGRESS.md, docs/SAMPROGRESS.HTML and docs/SAMPROGRESS.SVG from a fresh build.

usage: tools/progress.py [--no-build] [--no-pack]

Builds src/ with tools/tp/gen_scaffold.py (unless --no-build) and compares the build with the unpacked
original the way tools/tp/match.py does: a routine counts as done only when every byte of its span and every
relocation in it are the same. The routines are recipe/units.json's, of the 10 game units; System, Crt and Dos
come from TURBO.TPL and are listed as parts, not routines. tools/tp/pack.py (unless --no-pack, or when its
LZEXE.EXE is missing) checks the packed result against original/SAM1.EXE.

Names: the routine's src/match file (`<SEG>_<OFF>_<Name>.PAS` / `.EXT`), a `{ nested: .. }` routine's
declaration inside its parent, an asm block's `<SEG>.LABELS`, else `L<offset>`.

docs/SAMPROGRESS.HTML (template tools/progress.html) lists every routine, searchable and filterable by unit;
clicking one shows its source: the Pascal file, or its lines of the unit's OBJ<SEG>.ASM block.
docs/SAMPROGRESS.SVG is the README badge.
"""
import base64
import io
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'tools', 'tp'))
PY = os.path.join(ROOT, '.work', 'venv', 'bin', 'python')
MATCH = os.path.join(ROOT, 'src', 'match')
LIBS = ('2961', '2CC7', '2CD1')
LZEXE = os.path.join(ROOT, '..', 'cosmore', 'src', 'LZEXE91', 'LZEXE.EXE')

# what each unit is (STATUS.md, findings/), in code order
UNITS = {
    '0000': 'Main program',
    '0529': 'Actors',
    '0D9C': 'Map',
    '1802': 'Menus, windows, save/load',
    '25E6': 'Text',
    '2643': 'Genus PCX Toolkit',
    '286F': 'Joystick',
    '287F': 'Sound',
    '2891': 'Start-up, data',
    '29C3': 'Graphics',
}


def run(args, **kw):
    return subprocess.run(args, cwd=ROOT, capture_output=True, text=True, **kw)


def read(path):
    return open(path, encoding='latin1').read()


def files():
    """{(seg, off): (path, ext, name)} for src/match"""
    out = {}
    for f in sorted(os.listdir(MATCH)):
        m = re.match(r'([0-9A-F]{4})_([0-9A-F]{4})(?:_(\w+))?\.(PAS|EXT)$', f)
        if m:
            out.setdefault((m.group(1), m.group(2)), (os.path.join(MATCH, f), m.group(4), m.group(3)))
    return out


def labels(seg):
    p = os.path.join(MATCH, seg + '.LABELS')
    out = {}
    if os.path.exists(p):
        for line in open(p):
            f = line.split('#')[0].split()
            if len(f) >= 2:
                out[f[0].upper()] = f[1]
    return out


def nested(fs):
    """{(seg, off): (parent path, name)} from `{ nested: A B }`, names in declaration order"""
    out = {}
    for (seg, _), (path, ext, _) in fs.items():
        if ext != 'PAS':
            continue
        t = read(path)
        m = re.search(r'\{ nested: ([0-9A-F ]+) \}', t)
        if not m:
            continue
        decl = re.findall(r'^[ \t]+(?:procedure|function)\s+(\w+)', t, re.M)
        for off, name in zip(sorted(m.group(1).split()), decl):
            out[(seg, off)] = (path, name)
    return out


def asm_slices(seg, spans, obj):
    """{off: text} the lines of OBJ<seg>.ASM inside each routine's span; labels go with the code after them,
    data lines with the code before them"""
    p = os.path.join(MATCH, 'OBJ%s.ASM' % seg)
    if not os.path.exists(p):
        return {}
    lines = read(p).splitlines()
    offs = []                                           # each line's own offset, or None
    for ln in lines:
        m = re.search(r';\s*([0-9A-F]{4})\s*$', ln)
        offs.append(int(m.group(1), 16) if m and not ln.lstrip().startswith(';') else None)
    starts = sorted(spans)

    def owner(o):
        own = None
        for s in starts:
            if s <= o < s + spans[s]:
                own = s
        return own

    out = {}
    cur = None
    for i, ln in enumerate(lines):
        s = ln.strip()
        if not s or s.startswith(('segment', 'global', 'extern', '; ' + seg + ' {$L}')):
            continue
        if offs[i] is not None:
            cur = owner(offs[i])
            who = cur
        elif s == 'OBJ%s:' % seg:                       # the block's start: the data before its first code
            cur = who = obj
        elif re.match(r'^\w+:$', s) or cur is None:     # a label, or data before any code: the next line's owner
            nxt = next((o for o in offs[i + 1:] if o is not None), None)
            who = owner(nxt) if nxt is not None else cur
        else:
            who = cur
        if who is not None:
            out.setdefault(who, []).append(ln)
    return {k: '\n'.join(v) for k, v in out.items()}


def name_source(text):
    m = re.search(r'\{ src: (\w+)', text)
    if not m:
        return ''
    return 'EXE' if re.fullmatch(r'[0-9A-F]{4}', m.group(1)) else m.group(1)   # `{ src: SSSS:OOOO, ..}` cites the binary


def compare(rec, fs):
    """{(seg, off): bytes that differ (0 = byte-identical, relocations included)} as tools/tp/match.py checks"""
    from inventory import Prog
    t = Prog(os.path.join(ROOT, '.work', 'tp', 'SAM1_unp.exe'))
    b = Prog(os.path.join(ROOT, '.work', 'scaffold', 'SAM1.EXE'))
    if len(t.img) != len(b.img):
        sys.exit('the build and the original differ in length; run tools/tp/match.py')
    out = {}
    for u in rec['units']:
        if u['seg'] in LIBS:
            continue
        seg = int(u['seg'], 16)
        for f in u['functions']:
            off = f['addr'][5:]
            lo = seg * 16 + int(off, 16)
            hi = lo + f['size']
            fp = fs.get((u['seg'], off))
            to = re.search(r'\{ to: ([0-9A-F]{4}) \}', read(fp[0])) if fp and fp[1] == 'PAS' else None
            if to:
                hi = seg * 16 + int(to.group(1), 16)
            nd = sum(1 for k in range(lo, hi) if t.img[k] != b.img[k])
            rt = {r for r in t.rel if lo <= r < hi}
            rb = {r for r in b.rel if lo <= r < hi}
            out[(u['seg'], off)] = nd + len(rt ^ rb)
    lib = {}
    for u in rec['units']:
        if u['seg'] in LIBS:
            lo = int(u['seg'], 16) * 16
            lib[u['seg']] = sum(1 for k in range(lo, lo + u['size']) if t.img[k] != b.img[k])
    ds = t.data_seg * 16
    data = sum(1 for k in range(ds, len(t.img)) if t.img[k] != b.img[k])
    return out, lib, data, len(t.img) - ds, len(t.img)


def routines(rec):
    fs = files()
    nest = nested(fs)
    out = []
    for u in rec['units']:
        if u['seg'] in LIBS:
            continue
        lab = labels(u['seg'])
        obj = int(u['obj_start'], 16) if u.get('obj_start') else None
        spans = {int(f['addr'][5:], 16): f['size'] for f in u['functions']
                 if obj is not None and int(f['addr'][5:], 16) >= obj}
        asm = asm_slices(u['seg'], spans, obj)
        for f in u['functions']:
            off = f['addr'][5:]
            o = int(off, 16)
            key = (u['seg'], off)
            r = {'seg': u['seg'], 'off': off, 'size': f['size'], 'unit': UNITS.get(u['seg'], u['seg'])}
            pas = fs.get(key) if fs.get(key, (0, ''))[1] == 'PAS' else None
            ext = fs.get(key) if fs.get(key, (0, ''))[1] == 'EXT' else None
            if pas:
                txt = read(pas[0])
                r.update(n=pas[2] or 'L' + off, k='Pascal', file='src/match/' + os.path.basename(pas[0]), src=txt)
            elif key in nest:
                path, name = nest[key]
                txt = read(path)
                r.update(n=name, k='Pascal, nested', file='src/match/' + os.path.basename(path), src=txt)
            elif obj is not None and o >= obj:
                name = ext[2] if ext else lab.get(off) or ('OBJ' + u['seg'] if o == obj else 'L' + off)
                txt = asm.get(o, '')
                if ext:
                    txt = read(ext[0]).rstrip() + '\n\n' + txt
                r.update(n=name, k='asm', file='src/match/OBJ%s.ASM' % u['seg'], src=txt)
            else:
                r.update(n='L' + off, k='?', file='', src='')
            r['ns'] = name_source(r['src'])
            out.append(r)
    return out


def logo_png(box=(25, 10, 615, 125)):
    """The SECRET AGENT logo cut from the title capture (docs/media/cover.jpg), as PNG"""
    from PIL import Image
    buf = io.BytesIO()
    Image.open(os.path.join(ROOT, 'docs', 'media', 'cover.jpg')).convert('RGB').crop(box).save(buf, 'PNG')
    return base64.b64encode(buf.getvalue()).decode()


def write_html(path, rs, head, summary):
    data = json.dumps({'commit': head, 'units': list(UNITS.values()), 'summary': summary,
                       'functions': [{'a': '%s:%s' % (r['seg'], r['off']), 'n': r['n'], 'sub': r['unit'],
                                      'k': r['k'], 'z': r['size'], 's': 'match' if r['d'] == 0 else 'near',
                                      'd': r['d'], 'f': r['file'], 'ns': r['ns'], 'src': r['src']} for r in rs]},
                      separators=(',', ':'))
    t = read(os.path.join(ROOT, 'tools', 'progress.html'))
    t = t.replace('/*ICON*/', logo_png()).replace('/*DATA*/', data.replace('</', '<\\/'))
    open(path, 'w').write(t)


def write_svg(path, done, total):
    pct = 100.0 * done / total
    w = 290 * pct / 100
    svg = (
        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
        'width="320" height="160" viewBox="0 0 320 160">\n'
        '<rect width="320" height="160" rx="8" fill="#3a0008"/>\n'
        '<image x="15" y="12" width="290" height="57" preserveAspectRatio="none" style="image-rendering:pixelated" '
        'xlink:href="data:image/png;base64,%s"/>\n'
        '<text x="160" y="100" text-anchor="middle" font-family="monospace" font-weight="bold" font-size="22" '
        'fill="#ffff55">SAM1.EXE</text>\n'
        '<clipPath id="fill"><rect x="15" y="118" width="%.2f" height="24"/></clipPath>\n'
        '<rect x="15" y="118" width="290" height="24" fill="#000" stroke="#ffffff" stroke-width="1.5"/>\n'
        '<text x="160" y="135" text-anchor="middle" font-family="monospace" font-weight="bold" font-size="14" '
        'fill="#ffffff">%.1f%%</text>\n'
        '<g clip-path="url(#fill)"><rect x="15" y="118" width="290" height="24" fill="#ffff55"/>\n'
        '<text x="160" y="135" text-anchor="middle" font-family="monospace" font-weight="bold" font-size="14" '
        'fill="#3a0008">%.1f%%</text></g>\n'
        '</svg>\n') % (logo_png(), w, pct, pct)
    open(path, 'w').write(svg)


def main():
    if '--no-build' not in sys.argv:
        b = run([PY, 'tools/tp/gen_scaffold.py'])
        if b.returncode:
            sys.exit('gen_scaffold.py failed:\n' + (b.stdout + b.stderr)[-2000:])
    packed = None
    if '--no-pack' not in sys.argv and os.path.exists(LZEXE):
        p = run([PY, 'tools/tp/pack.py'], timeout=600)
        packed = p.returncode == 0
    rec = json.load(open(os.path.join(ROOT, 'recipe', 'units.json')))
    diff, lib, data_diff, data_len, img_len = compare(rec, files())
    rs = routines(rec)
    for r in rs:
        r['d'] = diff[(r['seg'], r['off'])]
    total = len(rs)
    done = sum(1 for r in rs if r['d'] == 0)
    head = run(['git', 'rev-parse', '--short', 'HEAD']).stdout.strip()
    tbytes = sum(r['size'] for r in rs)
    dbytes = sum(r['size'] for r in rs if r['d'] == 0)

    def pct(a, b):
        return '%.1f%%' % (100.0 * a / b) if b else '-'

    def num(x):
        return '{:,}'.format(x)

    unit_rows = []
    for u in rec['units']:
        if u['seg'] in LIBS:
            continue
        ur = [r for r in rs if r['seg'] == u['seg']]
        m = sum(1 for r in ur if r['d'] == 0)
        pas = sum(1 for r in ur if r['k'].startswith('Pascal'))
        unit_rows.append((u['seg'], UNITS[u['seg']], len(ur), pas, len(ur) - pas, u['size'], m))
    whole = sum(1 for x in unit_rows if x[6] == x[2])

    L = []
    w = L.append
    w('# Progress')
    w('')
    w('How much of `SAM1.EXE` is rebuilt from Turbo Pascal source. Generated by `tools/progress.py` (do not')
    w('edit by hand), measured at commit `%s`.' % head)
    w('')
    w('**%d of the game\'s %d routines compile to the original\'s exact bytes (%s), %d of 10 game units whole.**'
      % (done, total, pct(done, total), whole))
    if packed:
        w('Packed with LZEXE 0.91, the build is `original/SAM1.EXE` byte for byte.')
    w('')
    w('A routine counts only when the TP 5.0 build of `src/` has the same bytes and the same relocations')
    w('as the unpacked original over the routine\'s whole span (`tools/tp/match.py`).')
    w('')
    w('To search the routines and read each one\'s source, open')
    w('[`docs/SAMPROGRESS.HTML`](docs/SAMPROGRESS.HTML) in a browser.')
    w('')
    w('## SAM1.EXE part by part')
    w('')
    w('| Part | Size | Status |')
    w('|---|---:|---|')
    w('| The game\'s 10 units (Pascal and `{$L}` asm), `src/match/` | %s bytes | %d of %d routines byte-identical (%s of the bytes) |'
      % (num(tbytes), done, total, pct(dbytes, tbytes)))
    for seg, nm in (('2961', 'Crt'), ('2CC7', 'Dos'), ('2CD1', 'System')):
        u = next(x for x in rec['units'] if x['seg'] == seg)
        w('| %s (Borland, `TURBO.TPL` of TP 5.0) | %s bytes | %s; linked from the library, nothing to rewrite |'
          % (nm, num(u['size']), 'byte-identical' if lib[seg] == 0 else '%d bytes differ' % lib[seg]))
    w('| Data segment | %s bytes | %s |' % (num(data_len), 'byte-identical' if data_diff == 0 else '%d bytes differ' % data_diff))
    w('| The packed file (LZEXE 0.91) | | %s |' % (
        'identical to `original/SAM1.EXE`, SHA-256 included' if packed else
        'not checked in this run (`tools/tp/pack.py` needs LZEXE.EXE)' if packed is None else 'differs'))
    w('')
    w('## By unit')
    w('')
    w('| Segment | Unit | Routines | Pascal | Asm | Code bytes | Byte-identical |')
    w('|---|---|---:|---:|---:|---:|---:|')
    for seg, nm, n, p, a, sz, m in unit_rows:
        w('| %s | %s | %d | %d | %d | %s | %s |' % (seg, nm, n, p, a, num(sz), pct(m, n)))
    w('| | **All** | **%d** | **%d** | **%d** | **%s** | **%s** |' % (
        total, sum(x[3] for x in unit_rows), sum(x[4] for x in unit_rows), num(sum(x[5] for x in unit_rows)),
        pct(done, total)))
    w('')
    w('## Every routine')
    w('')
    w('In address order (`SEG:OFF`, the segment relative to the load segment). The name source is the')
    w('`{ src: }` tag: `SAM1RE` the sister project\'s notes, `EXE` the binary, `GUESS` ours (MATCHING.md section 6).')
    w('')
    w('| Address | Routine | Unit | Kind | Bytes | Name source | Status |')
    w('|---|---|---|---|---:|---|---|')
    for r in rs:
        w('| %s:%s | `%s` | %s | %s | %d | %s | %s |' % (
            r['seg'], r['off'], r['n'], r['unit'], r['k'], r['size'], r['ns'] or '-',
            'byte-identical' if r['d'] == 0 else '%d bytes differ' % r['d']))
    w('')
    open(os.path.join(ROOT, 'PROGRESS.md'), 'w').write('\n'.join(L))
    summary = {'whole': whole, 'packed': packed, 'image': img_len, 'libs': all(v == 0 for v in lib.values()),
               'data': data_diff == 0}
    os.makedirs(os.path.join(ROOT, 'docs'), exist_ok=True)
    write_html(os.path.join(ROOT, 'docs', 'SAMPROGRESS.HTML'), rs, head, summary)
    write_svg(os.path.join(ROOT, 'docs', 'SAMPROGRESS.SVG'), done, total)
    print('PROGRESS.md: %d of %d routines byte-identical (%s), %d of 10 units whole, packed: %s'
          % (done, total, pct(done, total), whole, {True: 'identical', False: 'DIFFERS', None: 'not checked'}[packed]))


if __name__ == '__main__':
    main()
