{ src: SAM1RE 1802:0000 (../SAM: the page flip: DrawPage page 0/1, PageY its y offset 16 or 416) }
{ interface }
procedure FlipPage;
begin
  if DrawPage = 0 then
  begin
    DrawPage := 1;
    PageY := $1A0;
  end
  else
  begin
    DrawPage := 0;
    PageY := $10;
  end;
end;
