#!/usr/bin/env python3
"""Disassemble part of the target: SEG:OFF [SIZE], or a routine from the recipe when SIZE is left out.

usage: tdis.py SEG:OFF [SIZE] [--str]

`R` marks an instruction holding an MZ relocation. --str first prints the Pascal string literals (length-prefixed)
found in the bytes just before OFF (back to the previous routine's retf).
"""
import json
import os
import sys

from capstone import Cs, CS_ARCH_X86, CS_MODE_16

from inventory import Prog

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    seg, off = (int(x, 16) for x in argv[1].split(':'))
    t = Prog(os.path.join(ROOT, '.work', 'tp', 'SAM1_unp.exe'))
    args = [a for a in argv[2:] if not a.startswith('--')]
    if args:
        size = int(args[0], 16)
    else:
        rec = json.load(open(os.path.join(ROOT, 'recipe', 'units.json')))
        size = next(f['size'] for u in rec['units'] for f in u['functions']
                    if f['addr'] == '%04X:%04X' % (seg, off))
    base = seg * 16
    if '--str' in argv:
        k = off - 1
        while k > 0 and t.img[base + k] not in (0xCB, 0xCA) and off - k < 512:
            k -= 1
        k += 3 if t.img[base + k] == 0xCA else 1
        while k < off:
            n = t.img[base + k]
            print('LIT %04X %r' % (k, bytes(t.img[base + k + 1:base + k + 1 + n]).decode('latin1')))
            k += 1 + n
    md = Cs(CS_ARCH_X86, CS_MODE_16)
    for i in md.disasm(t.img[base + off:base + off + size], off):
        r = ' R' if any(base + i.address <= x < base + i.address + i.size for x in t.rel) else ''
        print('%04X %s %s%s' % (i.address, i.mnemonic, i.op_str, r))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
