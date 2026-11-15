{ src: SAM1RE 1802:0027 (shows the page: view start at CamX, W6866 + CamY) }
{ interface }
{ keep: ShowPage; }
procedure ShowPage;
begin
  if AltVideo = 0 then
    SetViewStart(CamX, PageY + CamY)
  else
    SetViewStartAlt(CamX, PageY + CamY);
  ScanPage := PageY;
end;
