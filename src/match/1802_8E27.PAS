{ src: SAM1RE 1802:8E27 (the debug level warp prompt; SAM1RE: DS:684C 1..$10 -> level) }
{ from: 8DDD }
{ to: 8EE1 }
{ interface }
{ keep: if AskWarp = 0 then; }
function AskWarp: Integer;
var
  N, Code: Integer;
begin
  ClearText;
  TextLines[1] := 'Warp to which level?';
  TextLines[2] := '--------------------';
  TextLines[3] := '';
  TextLines[4] := 'Select (1-16) : ^';
  TextLines[5] := '';
  TextLines[6] := 'END OF WINDOW';
  NameInput := InputLine(2);
  MemW[0:$41C] := MemW[0:$41A];
  Val(NameInput, N, Code);
  AskWarp := N;
  EscHeld := 0;
  MenuReq := 0;
end;
