#!/usr/bin/env python3
"""The matching check: compare the scaffold build with SAM1's unpacked image.

usage: match.py [--exe BUILD.EXE] [-v] [--update]

Default BUILD is .work/scaffold/SAM1.EXE (tools/tp/gen_scaffold.py builds it); the target is .work/tp/SAM1_unp.exe.
Checks, in order (MATCHING.md section 5):

  layout    entry CS:IP, SS:SP, image length, every code segment base and the data segment base;
  library   System / Crt / Dos (from TP 5.0's TURBO.TPL) byte for byte, and their relocations;
  data      the initialised data DS:0000..end of image; the Genus typed constants are zeros in the scaffold
            until the Genus unit is matched, so differences there are counted apart and do not fail;
  matched   every routine with status `matched` in recipe/units.json or a hand-written src/match/<SEG>_<OFF>.PAS:
            the bytes of its span and its relocations. --update writes status `matched` / `unmatched` back to the
            recipe for routines with a src/match file (a matched routine that stops matching fails either way).

Prints one line per check and the routines that fail, never image bytes. Exit 0 when everything holds.
"""
import json
import re
import os
import struct
import sys

from inventory import Prog

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LIBS = (0x2961, 0x2CC7, 0x2CD1)


def first_diff(a, b, lo, hi):
    for k in range(lo, hi):
        if a[k] != b[k]:
            return k
    return None


def main(argv):
    exe = argv[argv.index('--exe') + 1] if '--exe' in argv else os.path.join(ROOT, '.work', 'scaffold', 'SAM1.EXE')
    verbose = '-v' in argv
    t = Prog(os.path.join(ROOT, '.work', 'tp', 'SAM1_unp.exe'))
    b = Prog(exe)
    rec = json.load(open(os.path.join(ROOT, 'recipe', 'units.json')))
    ok = True
    hd_t = open(os.path.join(ROOT, '.work', 'tp', 'SAM1_unp.exe'), 'rb').read(0x18)
    hd_b = open(exe, 'rb').read(0x18)
    ssp = struct.unpack_from('<HH', hd_t, 0xE) == struct.unpack_from('<HH', hd_b, 0xE)
    lay = [t.entry == b.entry, ssp, len(t.img) == len(b.img), t.code == b.code, t.data_seg == b.data_seg]
    print('layout   %s  (entry, SS:SP, image length, %d code bases, DS base)' % (
        'OK' if all(lay) else 'FAIL ' + str(lay), len(t.code)))
    ok &= all(lay)
    if not all(lay[2:5]):
        return 1
    for seg in LIBS:
        lo, hi = seg * 16, t.ends[seg]
        diff = sum(1 for k in range(lo, hi) if t.img[k] != b.img[k])
        rt = {r for r in t.rel if lo <= r < hi}
        rb = {r for r in b.rel if lo <= r < hi}
        good = diff == 0 and rt == rb
        print('library  %04X %s  (%d bytes, %d differ; %d relocations, %d differ)' % (
            seg, 'OK' if good else 'FAIL', hi - lo, diff, len(rt), len(rt ^ rb)))
        ok &= good
    ds = t.data_seg * 16
    g = next((u for u in rec['units'] if u['seg'] == '2643'), None)
    glo, ghi = (int(x, 16) for x in g['data']['tconsts']) if g and 'tconsts' in g.get('data', {}) else (0, 0)
    genus_matched = any(f['status'] == 'matched' for f in (g or {}).get('functions', []))
    d_all = [k - ds for k in range(ds, len(t.img)) if t.img[k] != b.img[k]]
    d_genus = [k for k in d_all if glo <= k < ghi and not genus_matched]
    d_rest = [k for k in d_all if k not in d_genus]
    print('data     %s  (%d bytes; %d differ outside the Genus constants, %d inside: scaffold zeros)' % (
        'OK' if not d_rest else 'FAIL', len(t.img) - ds, len(d_rest), len(d_genus)))
    if d_rest:
        print('         first at DS:%04X' % d_rest[0])
        ok = False
    n_m, bad = 0, []
    for u in rec['units']:
        seg = int(u['seg'], 16)
        obj_asm = u.get('obj_start') and os.path.exists(os.path.join(ROOT, 'src', 'match', 'OBJ%s.ASM' % u['seg']))
        for f in u['functions']:
            frag = os.path.exists(os.path.join(ROOT, 'src', 'match', '%s_%s.PAS' % (u['seg'], f['addr'][5:])))
            frag = frag or bool(obj_asm and int(f['addr'][5:], 16) >= int(u['obj_start'], 16))
            if f['status'] != 'matched' and not frag:
                continue
            n_m += 1
            lo = seg * 16 + int(f['addr'][5:], 16)
            hi = lo + f['size']
            fp = os.path.join(ROOT, 'src', 'match', '%s_%s.PAS' % (u['seg'], f['addr'][5:]))
            to = re.search(r'\{ to: ([0-9A-F]{4}) \}', open(fp).read()) if os.path.exists(fp) else None
            if to:                                      # the next routine's literals follow: not this one's
                hi = seg * 16 + int(to.group(1), 16)
            k = first_diff(t.img, b.img, lo, hi)
            rt = {r for r in t.rel if lo <= r < hi}
            rb = {r for r in b.rel if lo <= r < hi}
            if k is not None or rt != rb:
                nd = sum(1 for x in range(lo, hi) if t.img[x] != b.img[x])
                bad.append('%s (%d bytes): %s' % (f['addr'], f['size'], 'relocations differ' if k is None else
                           'first difference at +%04X, %d bytes differ' % (k - lo, nd)))
                if frag and f['status'] != 'matched':
                    f['status'] = 'unmatched'
                continue
            if frag:
                f['status'] = 'matched'
            elif verbose:
                print('         %s %s match' % (f['addr'], f.get('name') or ''))
    total = sum(f['size'] for u in rec['units'] for f in u['functions'])
    done = sum(f['size'] for u in rec['units'] for f in u['functions'] if f['status'] == 'matched')
    print('matched  %s  (%d routines checked, %d fail; %d of %d routine bytes matched = %.2f%%)' % (
        'OK' if not bad else 'FAIL', n_m, len(bad), done, total, 100.0 * done / total))
    for x in bad:
        print('         ' + x)
    ok &= not bad
    whole = [u['seg'] for u in rec['units'] if int(u['seg'], 16) not in LIBS and
             first_diff(t.img, b.img, int(u['seg'], 16) * 16, int(u['seg'], 16) * 16 + u['size']) is None and
             {r for r in t.rel if 0 <= r - int(u['seg'], 16) * 16 < u['size']} ==
             {r for r in b.rel if 0 <= r - int(u['seg'], 16) * 16 < u['size']}]
    print('units    %d of %d game units byte-identical: %s' % (
        len(whole), len([u for u in rec['units'] if int(u['seg'], 16) not in LIBS]), ' '.join(whole) or '-'))
    if '--update' in argv:
        json.dump(rec, open(os.path.join(ROOT, 'recipe', 'units.json'), 'w'), indent=1)
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv))
