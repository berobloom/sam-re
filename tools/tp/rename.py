#!/usr/bin/env python3
"""rename.py OLD NEW            rename a global identifier in src/match (whole words; Pascal ignores case)
rename.py --field TYPE OLD NEW  rename a record field: its declaration in TYPE and every `.OLD` reached through a
                                variable of that type (the variables are found in the .VAR files)

Files: src/match/*.PAS, .VAR, .SIG, .EXT (latin1, line endings kept). Refuses when NEW is already an identifier
there, or when OLD is not found. Names are not in the image, so a rename never changes the build; run
gen_scaffold.py and match.py after it anyway (MATCHING.md section 7)."""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MATCH = os.path.join(ROOT, 'src', 'match')


def files():
    for f in sorted(os.listdir(MATCH)):
        if f.endswith(('.PAS', '.VAR', '.SIG', '.EXT')):
            yield os.path.join(MATCH, f)


def read(p):
    return open(p, 'rb').read().decode('latin1')


def write(p, s):
    open(p, 'wb').write(s.encode('latin1'))


def code(s):
    """the text with comments and string literals blanked (same length), so matches land in code only"""
    s = re.sub(r"\{[^}]*\}", lambda m: ' ' * len(m.group(0)), s)
    return re.sub(r"'[^'\n]*'", lambda m: ' ' * len(m.group(0)), s)


def used(name):
    rx = re.compile(r'\b%s\b' % re.escape(name), re.I)
    return any(rx.search(code(read(p))) for p in files())


def sub_code(s, rx, repl):
    """replace in code positions only"""
    c = code(s)
    out, last = [], 0
    for m in rx.finditer(c):
        out.append(s[last:m.start()])
        out.append(m.expand(repl))
        last = m.end()
    out.append(s[last:])
    return ''.join(out), len(out) // 2


def main(argv):
    if len(argv) == 5 and argv[1] == '--field':
        typ, old, new = argv[2:]
        # variables of the type: `Name: array[..] of TYPE` or `Name: TYPE`
        vs = []
        for p in files():
            if p.endswith('.VAR'):
                for m in re.finditer(r'^\s*([\w, ]+):\s*(?:array\s*\[[^\]]*\]\s*of\s+)?%s\s*;' % typ, code(read(p)),
                                     re.M | re.I):
                    vs += [x.strip() for x in m.group(1).split(',')]
        if not vs:
            print('no variable of type %s' % typ)
            return 1
        acc = re.compile(r'\b((?:%s)(?:\[[^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*\])?)\.%s\b' % ('|'.join(vs), old), re.I)
        total = 0
        for p in files():
            s = read(p)
            s, n = sub_code(s, acc, r'\1.' + new)
            if p.endswith('.VAR'):                          # the declaration inside the record type
                m = re.search(r'\b%s\s*=\s*(?:packed\s+)?record\b(.*?)\bend\b' % typ, s, re.S | re.I)
                if m:
                    body, k = sub_code(m.group(1), re.compile(r'\b%s\b' % old), new)
                    s = s[:m.start(1)] + body + s[m.end(1):]
                    n += k
            if n:
                write(p, s)
                total += n
        print('%s.%s -> %s: %d places (variables %s)' % (typ, old, new, total, ', '.join(vs)))
        return 0 if total else 1
    if len(argv) != 3:
        print(__doc__)
        return 2
    old, new = argv[1:]
    if used(new):
        print('%s is already used' % new)
        return 1
    rx = re.compile(r'(?<![.\w])%s\b' % re.escape(old), re.I)   # not a field access `.OLD`
    total = 0
    for p in files():
        s = read(p)
        s, n = sub_code(s, rx, new)
        if p.endswith('.VAR'):                              # the pin comment names the declaration's line only
            pass
        if n:
            write(p, s)
            total += n
    print('%s -> %s: %d places' % (old, new, total))
    return 0 if total else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv))
