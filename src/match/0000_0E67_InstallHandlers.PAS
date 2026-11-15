{ src: GUESS 0000:0E67 (installs ExitHandler as ExitProc and the timer and keyboard handlers, saving the old
  ones) }
procedure InstallHandlers;
begin
  OldExit := ExitProc;
  ExitProc := @ExitHandler;
  GetIntVec($1C, OldInt1C);
  SetIntVec($1C, @TimerISR);
  GetIntVec(9, OldInt9);
  SetIntVec(9, @KeyISR);
end;
