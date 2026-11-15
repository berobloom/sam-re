"""chargen.py DIS SEG START END -> the `if S = 'c' then ...` chain of a 0D9C row-char routine (2E88).
DIS is `tdis.py` output; START is the chain's first `lea di, [bp - 0x100]`, END the address after it (hex).
Bodies: SetCell calls (arguments X, Y, constants, W6840, W685A + n, FO), Inc(W685A), and ifs on
SiteDone[W685A + 2] or B6868; anything else stops it with the unknown instruction."""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from inventory import Prog  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def load(path):
    out = []
    for l in open(path):
        m = re.match(r'([0-9A-F]{4}) (.*)', l.rstrip())
        if m:
            out.append((int(m.group(1), 16), m.group(2).strip()))
    return out


def tgt(t):
    return int(t.split()[-1], 16)


def lit(img, seg, off):
    n = img[seg * 16 + off]
    s = img[seg * 16 + off + 1: seg * 16 + off + 1 + n]
    out, run = '', ''
    for c in s:
        if 32 <= c < 127:
            run += chr(c) * (2 if c == 39 else 1)
        else:
            if run:
                out += "'%s'" % run
                run = ''
            out += '#%d' % c
    if run:
        out += "'%s'" % run
    return out


def hexn(n):
    return '$%X' % n if n > 9 else str(n)


def args(seq):
    """SetCell's pushes -> argument texts"""
    out, ax = [], None
    for t in seq:
        if t == 'push word ptr [bp + 0xc]':
            out.append('X')
        elif t == 'push word ptr [bp + 0xa]':
            out.append('Y')
        elif t.startswith('push word ptr [0x'):
            out.append(NAMES[int(t[t.index('[') + 1:-1], 16)])
        elif t == 'xor ax, ax':
            ax = '0'
        elif t == 'mov ax, word ptr [bp + 0xc]':
            ax = 'X'
        elif t == 'mov ax, word ptr [bp + 0xa]':
            ax = 'Y'
        elif t == 'dec ax':
            ax = '%s - 1' % ax
        elif t == 'inc ax':
            ax = '%s + 1' % ax
        elif t.startswith('mov ax, word ptr [0x'):
            ax = NAMES[int(t[t.index('[') + 1:-1], 16)]
        elif t.startswith('mov ax, ') or t.startswith('mov al, 0x') or re.match(r'mov al, \d', t):
            ax = hexn(int(t.split(',')[1], 0))
        elif t == 'mov al, byte ptr [bp - 0x105]':
            ax = 'FO'
        elif t.startswith('add ax, '):
            ax = '%s + %s' % (ax, hexn(int(t.split(',')[1], 0)))
        elif t.startswith('sub ax, '):
            ax = '%s - %s' % (ax, hexn(int(t.split(',')[1], 0)))
        elif t == 'push ax':
            out.append(ax)
        elif t in ('push cs', 'call 0x2c6e'):
            pass
        else:
            raise ValueError(t)
    return out


NAMES = {0x6840: 'W6840', 0x685A: 'W685A'}


def stmts(body):
    """a statement list: SetCell calls, Inc(W685A), and `if COND then .. [else ..]` on the two gates"""
    out, seq, i = [], [], 0
    while i < len(body):
        a, t = body[i]
        if t == 'cmp byte ptr [0x6868], 0' or (t == 'mov ax, word ptr [0x685a]' and i + 3 < len(body)
                                              and body[i + 3][1].startswith('cmp byte ptr [di + 0x69df]')):
            assert not seq, seq
            if t.startswith('cmp'):
                cond, k = 'B6868 = 0', i + 1
            else:
                cond, k = 'SiteDone[W685A + 2] <> 0', i + 4
            els = tgt(body[k][1])
            then = [x for x in body[k + 1:] if x[0] < els]
            j = i
            while j < len(body) and body[j][0] < els:
                j += 1
            if then and then[-1][1].startswith('jmp '):
                join = tgt(then[-1][1])
                then = then[:-1]
                rest = [x for x in body[j:] if x[0] < join]
                j += len(rest)
                out.append(('if', cond, stmts(then), stmts(rest)))
            else:
                out.append(('if', cond, stmts(then), None))
            i = j
            continue
        if t == 'inc word ptr [0x685a]':
            out.append('Inc(W685A)')
            i += 1
            continue
        seq.append(t)
        if t == 'call 0x2c6e':
            out.append('SetCell(%s)' % ', '.join(args(seq)))
            seq = []
        i += 1
    assert not [t for t in seq if not t.startswith('jmp')], seq
    return out


def emit(st, ind):
    """statement list -> Pascal at indent ind (a list of more than one becomes begin..end)"""
    def one(x, ind):
        if isinstance(x, str):
            return ind + x
        _, cond, th, el = x
        r = ind + 'if %s then\n' % cond + block(th, ind + '  ')
        if el is not None:
            r += '\n' + ind + 'else\n' + block(el, ind + '  ')
        return r

    def block(lst, ind):
        if len(lst) == 1:
            return one(lst[0], ind)
        return ind[:-2] + 'begin\n' + ';\n'.join(one(x, ind) for x in lst) + ';\n' + ind[:-2] + 'end'
    return block(st, ind)


def gen(L, img, seg, start, end):
    idx = {a: i for i, (a, _) in enumerate(L)}
    i = idx[start]
    out = []
    while L[i][0] < end:
        assert L[i][1] == 'lea di, [bp - 0x100]', (hex(L[i][0]), L[i][1])
        c = lit(img, seg, int(L[i + 3][1].split(',')[1], 16))
        assert L[i + 6][1] == 'lcall 0x2cd1, 0x724 R'
        nx = tgt(L[i + 7][1])
        i += 8
        body = []
        while L[i][0] < nx:
            body.append(L[i])
            i += 1
        out.append('  if S = %s then\n%s;\n' % (c, emit(stmts(body), '    ')))
    return ''.join(out)


def main(argv):
    L = load(argv[1])
    p = Prog(os.path.join(ROOT, '.work', 'tp', 'SAM1_unp.exe'))
    sys.stdout.write(gen(L, p.img, int(argv[2], 16), int(argv[3], 16), int(argv[4], 16)))


if __name__ == '__main__':
    main(sys.argv)
