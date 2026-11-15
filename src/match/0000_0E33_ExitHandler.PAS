{ src: GUESS 0000:0E33 (the exit procedure: puts back ExitProc and the int $1C and int 9 vectors) }
{$F+}
procedure ExitHandler;
begin
  ExitProc := OldExit;
  SetIntVec($1C, OldInt1C);
  SetIntVec(9, OldInt9);
end;
{$F-}
