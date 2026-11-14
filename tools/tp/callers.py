#!/usr/bin/env python3
"""Far and near callers of each routine of a segment.

usage: callers.py SEG [OFF ...]

Far calls (9A off seg, with an MZ relocation) from other segments make a routine an interface routine; `push cs;
call near` from its own segment is a call to a far routine of the same unit; a plain near call is a near routine.
Prints per routine: far calls from outside (by segment), push-cs calls, plain near calls.
"""
import struct
import sys
from collections import Counter, defaultdict

from inventory import Prog
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    seg = int(argv[1], 16)
    want = {int(x, 16) for x in argv[2:]}
    t = Prog(os.path.join(ROOT, '.work', 'tp', 'SAM1_unp.exe'))
    far, pcs, near = defaultdict(Counter), Counter(), Counter()
    for x in t.rel:
        if t.img[x - 3] == 0x9A and struct.unpack_from('<H', t.img, x)[0] == seg:
            src = max(s for s in t.code if s * 16 <= x)
            far[struct.unpack_from('<H', t.img, x - 2)[0]][src] += 1
    lo, hi = seg * 16, t.ends[seg]
    for k in range(lo, hi - 3):
        if t.img[k] == 0xE8:
            tgt = (k - lo + 3 + struct.unpack_from('<h', t.img, k + 1)[0]) & 0xFFFF
            if (seg, tgt) in t.routines:
                (pcs if t.img[k - 1] == 0x0E else near)[tgt] += 1
    for off, size in t.spans(seg):
        if want and off not in want:
            continue
        f = ' '.join('%04X:%d' % (s, n) for s, n in sorted(far[off].items()))
        print('%04X:%04X %5d  far %-28s push-cs %-3d near %d' % (seg, off, size, f or '-', pcs[off], near[off]))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
