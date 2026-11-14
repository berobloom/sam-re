{ src: SAM1RE 1802:0000 (../SAM: the page flip: W6864 page 0/1, W6866 its y offset 16 or 416) }
{ interface }
{ keep: FlipPage; }
procedure FlipPage;
begin
  if W6864 = 0 then
  begin
    W6864 := 1;
    W6866 := $1A0;
  end
  else
  begin
    W6864 := 0;
    W6866 := $10;
  end;
end;
