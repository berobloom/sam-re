"""Find the files of src/match by address: `<SEG>_<OFF>_<Name>.<EXT>` (the name says what the routine is; the
address, from the original image, is what the tools go by). A file without the name part is found too."""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MATCH = os.path.join(ROOT, 'src', 'match')
PATTERN = re.compile(r'([0-9A-F]{4})_([0-9A-F]{4})(?:_(\w+))?\.(PAS|EXT|SIG)$')


def find(seg, off, ext='PAS'):
    """the path of the file for SEG:OFF (strings or ints), or None"""
    seg = seg if isinstance(seg, str) else '%04X' % seg
    off = off if isinstance(off, str) else '%04X' % off
    for f in os.listdir(MATCH):
        m = PATTERN.match(f)
        if m and m.group(1) == seg.upper() and m.group(2) == off.upper() and m.group(4) == ext:
            return os.path.join(MATCH, f)
    return None
