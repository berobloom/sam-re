{ src: GUESS 0000:0EC2 (puts back the int $1C and int 9 vectors, ExitProc left hooked) }
{ to: 0EE9 }
procedure RestoreInts;
begin
  SetIntVec($1C, OldInt1C);
  SetIntVec(9, OldInt9);
end;
