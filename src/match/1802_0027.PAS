{ src: SAM1RE 1802:0027 (shows the page: view start at CamX, W6866 + CamY) }
{ interface }
{ keep: ShowPage; }
procedure ShowPage;
begin
  if W70EC = 0 then
    SetViewStart(CamX, W6866 + CamY)
  else
    SetViewStartAlt(CamX, W6866 + CamY);
  W6862 := W6866;
end;
