{ The runtime keeper: one use of every System / Dos / Crt routine SAM1 links,
  and nothing else, so TP 5.0's smart linker produces SAM's runtime segments.
  Mapping: tools/tp/rtlmap.py (findings/executables.md §Runtime set).
  Pasted into the main program body by tools/tp/gen_scaffold.py (TP 5.0
  allows no include in a statement part); a stub with a structured value
  parameter links 025D. It never runs. }
Assign(KF, '');
Reset(KF);
Rewrite(KF);
Read(KF, KR);
Write(KF, KR);
Close(KF);
Reset(KT);
Rewrite(KT);
Writeln(KT);
Write(KT, KS);
GetMem(KP, 1);
FreeMem(KP, 1);
KL := MemAvail;
KS := KS2;
KS := KS + KS2;
KS := Copy(KS, 1, 1);
KI := Pos(KS, KS2);
Delete(KS, 1, 1);
KB := KS = KS2;
KS := KC;
Str(KI, KS);
Val(KS, KI, KI);
KI := Random(2);
KL := KL * KI;
KI := IOResult;
KB := KC in ['a'..'z', '_'];
FillChar(KR, 1, 0);
Halt;
Intr(0, KRegs);
GetIntVec(0, KP);
SetIntVec(0, KP);
Delay(1);
Sound(1);
NoSound;
KB := KeyPressed;
KC := ReadKey;
GotoXY(1, 1);
ClrScr;
TextColor(1);
TextBackground(0);
TextMode(3);
