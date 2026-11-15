"""casegen.py DIS [--inline] X:FIELD:START:END ... -> the Pascal case statements of a cell repaint routine.
DIS is `tdis.py` output of a 0D9C DrawBack-style routine; each spec names a case on Map[..].FIELD whose
`cmp ax, N` chain starts at START and ends at END (hex). Arms are draw calls with (Src, PX, PY + W6866), the
inline (CX shl 1, (CY shl 4) + W6866), or CopySheet(.., N), optionally under `if W6866 = P`. --inline: the
routine indexes Map[CX + 1, CY + 1] instead of Map[MX, MY] (DrawSheet). Written for 0D9C:0000/1185/2530."""
import re
import sys

MAP = 'Map[MX, MY]'
CALLEE = {0x475: 'DrawTile', 0x2A9F: 'DrawTileO', 0x2E6D: 'CopySheet'}


def load(path):
    out = []
    for l in open(path):
        m = re.match(r'([0-9A-F]{4}) (.*)', l.rstrip())
        if m:
            out.append((int(m.group(1), 16), m.group(2).strip()))
    return out


def lab(n):
    return '$%X' % n if n > 9 else str(n)


def tgt(t):
    return int(t.split()[-1], 16)


def draws(lines, field):
    """the calls in a run of instructions, as Pascal statements"""
    out, seg = [], []
    for a, t in lines:
        seg.append(t)
        if t.startswith('lcall'):
            off = int(t.split(',')[1].split()[0], 16)
            name = CALLEE[off]
            if name == 'CopySheet':
                if 'dec ax' in seg:
                    n = '%s.%s - 1' % (MAP, field)
                else:
                    n = [lab(int(s.split(',')[1], 16)) for s in seg if s.startswith('mov ax, ') and
                         not s.startswith('mov ax, word')][-1]
                xy = 'PX, PY + W6866' if 'push word ptr [bp - 0xa]' in seg else 'CX shl 1, (CY shl 4) + W6866'
                out.append('CopySheet(%s, %s)' % (xy, n))
            else:
                g = [s for s in seg if s.startswith('les di, ptr [')][-1]
                gi = (int(g[g.index('[') + 1:-1], 16) - 0x6D98) // 4 + 1
                if 'add di, ax' in seg:
                    sub = [s for s in seg if s.startswith('sub ax, ')]
                    tile = '%s.%s' % (MAP, field) + (' - %s' % lab(int(sub[-1].split(',')[1], 16)) if sub else '')
                else:
                    k = [int(s.split(',')[1], 0) for s in seg if s.startswith('add di, ') and s != 'add di, ax'][-1]
                    tile = str((k - 3) // 160 + 1)
                xy = 'PX, PY + W6866' if 'push word ptr [bp - 0xa]' in seg else 'CX shl 1, (CY shl 4) + W6866'
                out.append('%s(Gfx[%d]^.Tile[%s], %s)' % (name, gi, tile, xy))
            seg = []
    return out


def stmt(st, ind):
    return '\n'.join(ind + s + ';' for s in st) if len(st) != 1 else ind + st[0]


def gen_case(L, field, start, end):
    idx = {a: i for i, (a, _) in enumerate(L)}
    i = idx[start]
    arms = []
    while i < len(L) and L[i][0] < end:
        labels = []
        while True:
            a, t = L[i]
            assert t.startswith('cmp ax, '), (hex(a), t)
            A = int(t.split(',')[1], 16)
            j = L[i + 1][1]
            if j.startswith('je ') and L[i + 2][1].startswith('jmp '):   # long form of a last label
                labels.append(lab(A)); nx = tgt(L[i + 2][1]); i += 3; break
            if j.startswith('je '):
                labels.append(lab(A)); i += 2; continue
            if j.startswith('jne '):
                labels.append(lab(A)); nx = tgt(j); i += 2; break
            if j.startswith('jl '):
                B = int(L[i + 2][1].split(',')[1], 16)
                k = L[i + 3][1]
                labels.append('%s..%s' % (lab(A), lab(B)))
                i += 4
                if k.startswith('jle '):
                    continue
                nx = tgt(k)
                break
            raise ValueError((hex(a), t, j))
        body = []
        while i < len(L) and L[i][0] < nx:
            body.append(L[i]); i += 1
        if body and body[0][1] == 'jmp 0x%x' % end or (len(body) == 1 and body[0][1].startswith('jmp')):
            arms.append((labels, '        ;'))
            continue
        if body and body[-1][1] == 'jmp 0x%x' % end:
            body = body[:-1]
        if body[0][1].startswith('cmp word ptr [0x6866], '):
            P = int(body[0][1].split(',')[1], 16)
            els = tgt(body[1][1])
            then = [x for x in body[2:] if x[0] < els]
            rest = [x for x in body if x[0] >= els]
            has_else = then and then[-1][1].startswith('jmp ')
            if has_else:
                then = then[:-1]
            s = '        if W6866 = %s then\n' % lab(P)
            s += stmt(draws(then, field), '          ')
            if has_else:
                s += '\n        else\n' + stmt(draws(rest, field), '          ')
            arms.append((labels, s + ';'))
        else:
            st = draws(body, field)
            if len(st) == 1:
                arms.append((labels, '        ' + st[0] + ';'))
            else:
                arms.append((labels, '        begin\n' + '\n'.join('          %s;' % x for x in st) + '\n        end;'))
    out = '  case %s.%s of\n' % (MAP, field)
    for labels, s in arms:
        out += '    %s:\n%s\n' % (', '.join(labels), s)
    return out + '  end;\n'


def main(argv):
    global MAP
    L = load(argv[1])
    if '--inline' in argv:
        MAP = 'Map[CX + 1, CY + 1]'
    for spec in [a for a in argv[2:] if a != '--inline']:
        _, field, s, e = spec.split(':')
        sys.stdout.write(gen_case(L, field, int(s, 16), int(e, 16)))


if __name__ == '__main__':
    main(sys.argv)
