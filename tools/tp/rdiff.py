#!/usr/bin/env python3
"""Disassemble one routine of the target and the scaffold build side by side, from a little before the first
difference.

usage: rdiff.py SEG:OFF [N=24] [--exe BUILD.EXE]

SEG:OFF is a routine in recipe/units.json. Prints N instruction pairs (target | build), `*` where they differ.
"""
import json
import os
import re
import sys

from capstone import Cs, CS_ARCH_X86, CS_MODE_16

from inventory import Prog

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def ins(img, lin, off, end):
    md = Cs(CS_ARCH_X86, CS_MODE_16)
    return [(i.address, '%s %s' % (i.mnemonic, i.op_str)) for i in md.disasm(img[lin:lin + end - off], off)]


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    seg, off = (int(x, 16) for x in argv[1].split(':'))
    n = int(argv[2]) if len(argv) > 2 and not argv[2].startswith('-') else 24
    exe = argv[argv.index('--exe') + 1] if '--exe' in argv else os.path.join(ROOT, '.work', 'scaffold', 'SAM1.EXE')
    t, b = Prog(os.path.join(ROOT, '.work', 'tp', 'SAM1_unp.exe')), Prog(exe)
    rec = json.load(open(os.path.join(ROOT, 'recipe', 'units.json')))
    size = next(f['size'] for u in rec['units'] for f in u['functions'] if f['addr'] == '%04X:%04X' % (seg, off))
    lo = seg * 16 + off
    k = next((x for x in range(lo, lo + size) if t.img[x] != b.img[x] and not any(r <= x < r + 2 for r in t.rel)), None)
    if k is None:
        print('identical')
        return 0
    a, c = ins(t.img, lo, off, off + size), ins(b.img, lo, off, off + size + 64)
    first = max(0, next(i for i, (ad, _) in enumerate(a) if ad + 8 > k - lo + off) - 3)
    for i in range(first, min(first + n, max(len(a), len(c)))):
        x = a[i] if i < len(a) else (0, '')
        y = c[i] if i < len(c) else (0, '')
        same = re.sub(r'(lcall|ljmp) 0x[0-9a-f]+', r'\1 SEG', x[1]) == re.sub(r'(lcall|ljmp) 0x[0-9a-f]+', r'\1 SEG', y[1])
        print('%s %04X %-34s | %04X %s' % (' ' if same else '*', x[0], x[1], y[0], y[1]))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
