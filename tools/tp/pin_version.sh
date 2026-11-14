#!/bin/sh
# Pin the Turbo Pascal version: build the runtime test programs with one
# candidate compiler and classify every System/Crt/Dos routine of SAM1.
#
#   tools/tp/pin_version.sh TPDIR
#
# TPDIR holds TPC.EXE + TURBO.TPL. Builds in .work/pin/<name of TPDIR>/.
# The right compiler leaves `differ 0` on all three lines (findings/executables.md
# §Compiler version); TP 5.5 and 6.0 do not.
set -eu
[ $# -eq 1 ] || { sed -n 2,10p "$0"; exit 2; }
here=$(cd "$(dirname "$0")/../.." && pwd)
out="$here/.work/pin/$(basename "$1")"
mkdir -p "$out"
cp "$here"/tools/tp/rtltest/*.PAS "$out/"
for p in T2 T3; do "$here/tools/tp/tpc.sh" "$1" "$out" $p.PAS >/dev/null; done
"$here/.work/venv/bin/python" "$here/tools/tp/rtlcmp.py" "$here/.work/tp/SAM1_unp.exe" \
    "$out/T2.EXE,$out/T3.EXE" 2CD1 2961 2CC7
