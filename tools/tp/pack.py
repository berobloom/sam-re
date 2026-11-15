#!/usr/bin/env python3
"""pack.py [LZEXE.EXE] -> the shipped SAM1.EXE from the build, and the comparison with original/SAM1.EXE.

Copies .work/scaffold/SAM1.EXE (gen_scaffold.py's build) to .work/pack/, sets its header's min/max alloc to
3248/44208 paragraphs, packs it with LZEXE 0.91 in the stock DOSBox (dummy video, as tpc.sh) and compares the
result with original/SAM1.EXE. Exit 0 when they are identical.

Why the header edit (MATCHING.md section 8): LZEXE's packed min/max follow the input's one to one (packed
min = input min + 8234, packed max = input max + 8645 paragraphs, measured), so the file Jungck packed had
3248/44208. TP 5.0 writes 2837/43797 for this layout with the default {$M 16384,0,655360}; {$M 16384,6576,..}
gives the minimum, but the maximum would need a heapmax over 655360, which TP rejects. So the header was set
after linking (LIKELY an EXEMOD-style edit); everything else is TP's output.
LZEXE.EXE defaults to ../cosmore/src/LZEXE91/LZEXE.EXE (not in this repository)."""
import os
import shutil
import struct
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MINALLOC, MAXALLOC = 3248, 44208


def main(argv):
    lz = argv[1] if len(argv) > 1 else os.path.join(ROOT, '..', 'cosmore', 'src', 'LZEXE91', 'LZEXE.EXE')
    work = os.path.join(ROOT, '.work', 'pack')
    os.makedirs(work, exist_ok=True)
    for f in ('SAM1.EXE', 'SAM1.OLD'):
        p = os.path.join(work, f)
        if os.path.exists(p):
            os.remove(p)
    shutil.copy(lz, os.path.join(work, 'LZEXE.EXE'))
    exe = bytearray(open(os.path.join(ROOT, '.work', 'scaffold', 'SAM1.EXE'), 'rb').read())
    struct.pack_into('<HH', exe, 10, MINALLOC, MAXALLOC)
    open(os.path.join(work, 'SAM1.EXE'), 'wb').write(exe)
    env = dict(os.environ, SDL_VIDEODRIVER='dummy', SDL_AUDIODRIVER='dummy')
    subprocess.run(['timeout', '120', 'dosbox', '-noconsole', '-exit', '-c', 'mount d "%s"' % work, '-c', 'd:',
                    '-c', 'LZEXE.EXE SAM1.EXE > LZ.OUT', '-c', 'exit'], env=env, capture_output=True)
    if not os.path.exists(os.path.join(work, 'SAM1.OLD')):
        print('LZEXE did not run (no SAM1.OLD in %s)' % os.path.relpath(work, ROOT))
        return 1
    got = open(os.path.join(work, 'SAM1.EXE'), 'rb').read()
    want = open(os.path.join(ROOT, 'original', 'SAM1.EXE'), 'rb').read()
    if got == want:
        print('packed: %d bytes, identical to original/SAM1.EXE' % len(got))
        return 0
    diff = [i for i in range(min(len(got), len(want))) if got[i] != want[i]]
    print('packed: %d bytes (shipped %d), %d bytes differ, first at %s' % (
        len(got), len(want), len(diff), hex(diff[0]) if diff else 'the end'))
    return 1


if __name__ == '__main__':
    sys.exit(main(sys.argv))
