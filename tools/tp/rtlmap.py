#!/usr/bin/env python3
"""Which source construct links each runtime routine SAM calls.

usage: rtlmap.py UNPACKED.EXE TEST.EXE TEST.MAP TEST.PAS [SEG=2CD1]

TEST is a program built with `TPC /GD` (line numbers) that writes one construct per line. For every entry point of
SAM's segment SEG that code outside SEG far-calls, the tool finds the same routine in TEST's last-but-n segment of the
same unit (byte pattern with layout wildcards, else the same instruction shape, as rtlcmp.py), then the TEST lines
whose code far-calls it. Prints: SAM entry, call count, TEST offset, how it was found, the lines.
"""
import re
import struct
import sys
from collections import Counter

from inventory import Prog
from rtlcmp import pattern, shape


def map_lines(mapf):
    m = open(mapf, encoding='latin1').read().replace('\r', '')
    out = []
    for sec in m.split('Line numbers for')[1:]:
        out += [(int(s, 16) * 16 + int(o, 16), int(n)) for n, s, o in re.findall(r'(\d+) ([0-9A-F]{4}):([0-9A-F]{4})', sec)]
    return sorted(out)


def map_segs(mapf):
    m = open(mapf, encoding='latin1').read().replace('\r', '')
    return {name: int(start, 16) for start, name in re.findall(r'\s([0-9A-F]{5})H [0-9A-F]{5}H [0-9A-F]{5}H (\S+)\s+CODE', m)}


def locate(t, seg, off, r, rseg):
    """offset in r's segment rseg of SAM routine seg:off, and how; None if absent"""
    size = dict(t.spans(seg))[off]
    n = min(size, t.routines.get((seg, off), size)) or size
    lo, hi = rseg * 16, r.ends[rseg]
    m = pattern(t.masked(seg, off, n)).search(r.img, lo, hi)
    if m:
        return m.start() - lo, 'same'
    want = shape(t.img, seg * 16 + off, off, n)
    first = t.img[seg * 16 + off]
    k = r.img.find(bytes([first]), lo, hi)
    while k != -1:
        if shape(r.img, k, off, n) == want:
            return k - lo, 'layout'
        k = r.img.find(bytes([first]), k + 1, hi)
    return None


def main(argv):
    if len(argv) < 5:
        print(__doc__)
        return 2
    t, r = Prog(argv[1]), Prog(argv[2])
    seg = int(argv[5], 16) if len(argv) > 5 else 0x2CD1
    lines = map_lines(argv[3])
    src = open(argv[4], encoding='latin1').read().replace('\r', '').split('\n')
    rseg = r.code[-1] if seg == t.code[-1] else None
    if rseg is None:
        name = {0x2CC7: 'DOS', 0x2961: 'CRT'}.get(seg)
        rseg = map_segs(argv[3])[name] // 16
    called = Counter()
    for x in t.rel:
        if t.img[x - 3] == 0x9A and struct.unpack_from('<H', t.img, x)[0] == seg:
            if not (seg * 16 <= x < t.ends[seg]):
                called[struct.unpack_from('<H', t.img, x - 2)[0]] += 1
    for e, c in sorted(called.items(), key=lambda kv: -kv[1]):
        if (seg, e) not in t.routines:
            print('%04X:%04X x%-4d not a routine start' % (seg, e, c))
            continue
        loc = locate(t, seg, e, r, rseg)
        if not loc:
            print('%04X:%04X x%-4d NOT IN TEST' % (seg, e, c))
            continue
        roff, how = loc
        pat = struct.pack('<BHH', 0x9A, roff, rseg)
        sites, k = [], r.img.find(pat, 0, rseg * 16)
        while k != -1:
            sites.append(k)
            k = r.img.find(pat, k + 1, rseg * 16)
        ls = sorted({max((n for a, n in lines if a <= s), default=0) for s in sites})
        txt = ' | '.join('%d %s' % (n, src[n - 1].strip()) for n in ls[:3]) or '(internal / start-up)'
        print('%04X:%04X x%-4d %04X %-6s %s' % (seg, e, c, roff, how, txt))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
