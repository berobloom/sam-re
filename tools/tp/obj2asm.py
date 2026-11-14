#!/usr/bin/env python3
"""A unit's {$L} block (the .OBJ code TP links after the unit's Pascal code) as NASM source that assembles to the
same bytes.

usage: obj2asm.py SEG

Reads the block [obj_start, size) of SEG from recipe/units.json and the unpacked target. Code is found by recursive
descent from the block start, the unit's .EXT entries (src/match/SEG_OFF.EXT: their names become the labels the
Pascal side declares external) and every routine start the inventory has in the block; the rest is `db`. Each
decoded instruction is written in NASM syntax with branch targets as labels; NASM assembles the file (-f bin, with a
listing) and every instruction whose bytes differ, or that NASM rejects, becomes `db` with the instruction as a
comment, until the whole block is identical. A relocated word (MZ relocation) becomes `dw CODE` (the unit's own code
segment) or `dw DATA` (the data segment): an instruction holding one is written as db/dw.
Writes src/match/OBJ<SEG>.ASM (CRLF); gen_scaffold.py uses it instead of filler.
"""
import json
import os
import re
import subprocess
import sys
import tempfile

from capstone import Cs, CS_ARCH_X86, CS_MODE_16, CS_GRP_CALL, CS_GRP_RET
from capstone.x86 import X86_OP_IMM

from inventory import Prog

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
def is_branch(ins):
    m = ins.mnemonic
    return (m.startswith(('j', 'loop')) or m == 'call') and bool(ins.operands) and ins.operands[0].type == X86_OP_IMM


SIZE = {'byte': 'byte', 'word': 'word', 'dword': 'dword', 'qword': 'qword', 'tbyte': 'tword'}


def nasm_ops(ins, labels):
    """capstone operand text -> NASM"""
    op = ins.op_str
    m = ins.mnemonic
    if m in ('lcall', 'ljmp'):
        if ', ' not in op:                              # indirect: call far [mem]
            op = re.sub(r'\b(dword|word) ptr ', '', op)
            op = re.sub(r'\b(\w\w):\[', r'[\1:', op)
            return '%s far %s' % (m[1:], op)
        a, b = op.split(', ')
        return '%s %s:%s' % (m[1:], a, b)
    if is_branch(ins):
        t = ins.operands[0].imm & 0xFFFF
        if t not in labels:
            return None
        kind = '' if m == 'call' or m.startswith(('loop', 'jcxz')) else 'short ' if ins.size == 2 else 'near '
        return '%s %s%s' % (m, kind, labels[t])
    op = re.sub(r'\b(byte|word|dword|qword|tbyte) ptr (\w\w):\[', lambda x: SIZE[x.group(1)] + ' [' + x.group(2) + ':', op)
    op = re.sub(r'\b(byte|word|dword|qword|tbyte) ptr \[', lambda x: SIZE[x.group(1)] + ' [', op)
    op = re.sub(r'\bptr (\w\w):\[', r'[\1:', op)
    op = re.sub(r'\bptr \[', '[', op)
    op = re.sub(r'\b(\w\w):\[', r'[\1:', op)
    if m.startswith('rep') and ' ' in m:
        return m + (' ' + op if op else '')
    if m in ('movsb', 'movsw', 'stosb', 'stosw', 'lodsb', 'lodsw', 'scasb', 'scasw', 'cmpsb', 'cmpsw', 'insb', 'insw',
             'outsb', 'outsw'):
        return m if not re.search(r'\[(cs|es|ss):', op) else None
    return m + (' ' + op if op else '')


def descend(img, base, lo, hi, entries):
    md = Cs(CS_ARCH_X86, CS_MODE_16)
    md.detail = True
    seen, todo = {}, list(entries)
    while todo:
        off = todo.pop()
        while lo <= off < hi and off not in seen:
            ins = next(md.disasm(img[base + off:base + min(hi, off + 16)], off), None)
            if ins is None or off + ins.size > hi:
                break
            seen[off] = ins
            m = ins.mnemonic
            if is_branch(ins):
                todo.append(ins.operands[0].imm & 0xFFFF)
            if m in ('jmp', 'ljmp', 'ret', 'retf', 'iret') or ins.group(CS_GRP_RET):
                break
            off += ins.size
    # drop instructions that overlap an entry or another one's bytes (data decoded as code)
    out, end = {}, -1
    for off in sorted(seen):
        if any(off < e < off + seen[off].size for e in entries):
            continue
        if off >= end:
            out[off] = seen[off]
            end = off + seen[off].size
    return out


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    seg = argv[1].upper()
    rec = json.load(open(os.path.join(ROOT, 'recipe', 'units.json')))
    u = next(x for x in rec['units'] if x['seg'] == seg)
    t = Prog(os.path.join(ROOT, '.work', 'tp', 'SAM1_unp.exe'))
    s = int(seg, 16)
    lo, hi = int(u['obj_start'], 16), u['size']
    while hi > lo and t.img[s * 16 + hi - 1] == 0 and s * 16 + hi > t.ends[s] - 16:
        hi -= 1                                             # not the paragraph padding after the block
    hi = u['size']
    base = s * 16
    import struct
    fix = {}
    for r in t.rel:
        if base + lo <= r < base + hi:
            v = struct.unpack_from('<H', t.img, r)[0]
            if v not in (s, t.data_seg):
                print('%s: relocation at %04X holds %04X, neither its code segment nor DATA' % (seg, r - base, v))
                return 1
            fix[r - base] = 'CODE' if v == s else 'DATA'
    names = {lo: 'OBJ' + seg}
    d = os.path.join(ROOT, 'src', 'match')
    for f in sorted(os.listdir(d)):
        if f.startswith(seg + '_') and f.endswith('.EXT'):
            nm = re.search(r'(?:procedure|function) (\w+)', open(os.path.join(d, f)).read()).group(1).upper()
            names[int(f[5:9], 16)] = nm
    start = {lo} if t.routines.get((s, lo)) or t.img[base + lo] == 0x55 else set()   # reached, or `push bp`
    entries = (set(names) - {lo}) | start | {int(f['addr'][5:], 16) for f in u['functions']
                                     if lo <= int(f['addr'][5:], 16) < hi and f.get('reached')}
    code = descend(t.img, base, lo, hi, entries)
    labels = dict(names)
    md = Cs(CS_ARCH_X86, CS_MODE_16)
    md.detail = True
    for off, ins in code.items():
        if is_branch(ins):
            tg = ins.operands[0].imm & 0xFFFF
            if tg in code:
                labels.setdefault(tg, 'L%04X' % tg)
    force_db = set()
    for attempt in range(8):
        lines, where = ['; %s {$L} block %s:%04X..%04X, generated by tools/tp/obj2asm.py' % (seg, seg, lo, hi),
                        'segment CODE public align=1'], []
        if fix:
            lines.append('segment DATA public')
            lines.append('segment CODE')
        lines += ['global %s' % n for _, n in sorted(names.items())]
        off = lo
        while off < hi:
            if off in labels:
                lines.append('%s:' % labels[off])
            ins = code.get(off)
            if ins and any(off <= f < off + ins.size for f in fix):
                force_db.add(off)
            if off in fix:                              # a relocated word: a segment fixup
                lines.append('    dw %s' % fix[off])
                off += 2
                continue
            text = nasm_ops(ins, labels) if ins and off not in force_db else None
            if ins and text:
                where.append((len(lines) + 1, off, ins.size))
                lines.append('    %-40s; %04X' % (text, off))
                off += ins.size
            else:
                n = ins.size if ins else 1
                if ins:
                    cut = [f - off for f in fix if off < f < off + n]
                    if cut:
                        n = cut[0]                      # db up to the fixup; the rest after it
                        ins = None
                if not ins:                             # a run of data up to the next instruction or label
                    while (off + n < hi and off + n not in code and off + n not in labels and off + n not in fix
                           and n < 16):
                        n += 1
                cmt = '   ; %s %s' % (ins.mnemonic, ins.op_str) if ins else ''
                lines.append('    db %s%s' % (', '.join('0x%02X' % b for b in t.img[base + off:base + off + n]), cmt))
                off += n
        with tempfile.TemporaryDirectory() as tmp:
            src = os.path.join(tmp, 'a.asm')
            open(src, 'w').write('\n'.join(lines) + '\n')
            # NASM -f bin needs a plain section; assemble the same text with the segment line swapped
            open(src, 'w').write('\n'.join(['bits 16', 'org %d' % lo, 'CODE equ 0x%04X' % s, 'DATA equ 0x%04X' % t.data_seg]
                                           + [l for l in lines if not l.startswith(('segment', 'global'))]) + '\n')
            lst = os.path.join(tmp, 'a.lst')
            r = subprocess.run(['nasm', '-f', 'bin', '-l', lst, '-o', os.path.join(tmp, 'a.bin'), src],
                               capture_output=True, text=True)
            body = [l for l in lines if not l.startswith(('segment', 'global'))]
            bad = set()
            for m in re.finditer(r'a\.asm:(\d+): error', r.stderr):
                ln = int(m.group(1)) - 4                 # the four header lines
                hit = re.search(r'; ([0-9A-F]{4})$', body[ln - 1]) if 0 < ln <= len(body) else None
                if hit:
                    bad.add(int(hit.group(1), 16))
            if r.returncode != 0 and not bad:
                print(r.stderr[:500])
                return 1
            if not bad:
                out = open(os.path.join(tmp, 'a.bin'), 'rb').read()
                if out == bytes(t.img[base + lo:base + hi]):
                    break
                got = {}                                 # listing: source line -> bytes
                for l in open(lst).read().split('\n'):
                    m = re.match(r'\s*(\d+) [0-9A-F]{8} ([0-9A-F]+)', l)
                    if m:
                        got.setdefault(int(m.group(1)) - 4, b'')
                        got[int(m.group(1)) - 4] += bytes.fromhex(m.group(2))
                for i, l in enumerate(body, 1):
                    hit = re.search(r'; ([0-9A-F]{4})$', l)
                    if hit:
                        o = int(hit.group(1), 16)
                        n = code[o].size
                        if got.get(i, b'') != bytes(t.img[base + o:base + o + n]):
                            bad.add(o)
                if not bad:
                    print('bytes differ but every instruction matches: check the db runs')
                    return 1
            force_db |= bad
    else:
        print('%s: no identical assembly after %d attempts' % (seg, attempt + 1))
        return 1
    path = os.path.join(d, 'OBJ%s.ASM' % seg)
    open(path, 'w', newline='\r\n').write('\n'.join(lines) + '\n')
    n_ins = sum(1 for l in lines if l.startswith('    ') and not l.startswith('    db'))
    print('%s: %d bytes, %d instructions, %d as db (encoding differs), %d db lines -> %s' % (
        seg, hi - lo, n_ins, len(force_db), sum(1 for l in lines if l.startswith('    db')), os.path.relpath(path, ROOT)))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
