#!/usr/bin/env python3
"""Absolute DS operands per code segment of an unpacked TP EXE.

usage: dsrefs.py UNPACKED.EXE [SEG] [--lo 0xNNN]

For every routine the inventory finds, decodes its span and collects memory operands with no base/index register and
DS (default) segment, plus `mov reg16, imm` followed within 3 instructions by `push ds` (TP's way of passing a
variable's address). Prints per segment the count, min and max address, and the address list compressed into runs
(`0x2a2-0x2b0` = touched words in that range). With SEG, prints every address with its first user.
"""
import sys
from capstone import Cs, CS_ARCH_X86, CS_MODE_16
from capstone.x86 import X86_OP_MEM, X86_OP_IMM, X86_OP_REG, X86_REG_DS, X86_REG_INVALID
from inventory import Prog


def refs(p, seg):
    md = Cs(CS_ARCH_X86, CS_MODE_16)
    md.detail = True
    out = {}
    for off, size in p.spans(seg):
        lin = seg * 16 + off
        ins = list(md.disasm(p.img[lin:lin + size], off))
        for k, i in enumerate(ins):
            for o in i.operands:
                if o.type == X86_OP_MEM and o.mem.base == X86_REG_INVALID and o.mem.index == X86_REG_INVALID \
                        and o.mem.segment in (X86_REG_INVALID, X86_REG_DS):
                    out.setdefault(o.mem.disp & 0xFFFF, '%04X:%04X' % (seg, i.address))
            if i.mnemonic == 'mov' and len(i.operands) == 2 and i.operands[0].type == X86_OP_REG \
                    and i.operands[1].type == X86_OP_IMM and i.operands[0].size == 2:
                if any(j.mnemonic == 'push' and j.op_str == 'ds' for j in ins[k + 1:k + 4]):
                    out.setdefault(i.operands[1].imm & 0xFFFF, '%04X:%04X' % (seg, i.address))
    return out


def runs(addrs):
    addrs = sorted(addrs)
    res, start, prev = [], None, None
    for a in addrs:
        if start is None:
            start = prev = a
        elif a - prev <= 0x10:
            prev = a
        else:
            res.append((start, prev))
            start = prev = a
    if start is not None:
        res.append((start, prev))
    return res


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    p = Prog(argv[1])
    lo = int(argv[argv.index('--lo') + 1], 0) if '--lo' in argv else 0
    one = [int(a, 16) for a in argv[2:] if not a.startswith('--') and a != str(lo) and not a.startswith('0x')]
    for seg in p.code:
        if one and seg not in one:
            continue
        r = {a: w for a, w in refs(p, seg).items() if a >= lo}
        if not r:
            print('%04X: none' % seg)
            continue
        print('%04X: %d addresses, %04X..%04X  runs: %s' % (seg, len(r), min(r), max(r),
              ' '.join('%x-%x' % x if x[0] != x[1] else '%x' % x[0] for x in runs(r))[:600]))
        if one:
            for a in sorted(r):
                print('   %04X  %s' % (a, r[a]))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
