{ src: GUESS 25E6:0101 (a frame. Frame 0 blank, 1 single, 2 double, 3 double sides,
  4 double top; else every part is Chr(Frame)) }
{ keep: - }
{$F+}
procedure Box(X1, Y1, X2, Y2, Fg, Bg, Frame: Integer);
var
  I: Integer;
  TL, TR, BL, BR, H, V: Char;
  Attr: Byte;
begin
  case Frame of
    0: begin
         TL := ' ';
         TR := ' ';
         BL := ' ';
         BR := ' ';
         H := ' ';
         V := ' ';
       end;
    1: begin
         TL := #$DA;
         TR := #$BF;
         BL := #$C0;
         BR := #$D9;
         H := #$C4;
         V := #$B3;
       end;
    2: begin
         TL := #$C9;
         TR := #$BB;
         BL := #$C8;
         BR := #$BC;
         H := #$CD;
         V := #$BA;
       end;
    3: begin
         TL := #$D6;
         TR := #$B7;
         BL := #$D3;
         BR := #$BD;
         H := #$C4;
         V := #$BA;
       end;
    4: begin
         TL := #$D5;
         TR := #$B8;
         BL := #$D4;
         BR := #$BE;
         H := #$CD;
         V := #$B3;
       end;
  else
    begin
      TL := Chr(Frame);
      TR := Chr(Frame);
      BL := Chr(Frame);
      BR := Chr(Frame);
      H := Chr(Frame);
      V := Chr(Frame);
    end;
  end;
  Attr := MakeAttr(Fg, Bg);
  FastWrite(X1, Y1, Attr, TL);
  FastWrite(X1 + 1, Y1, Attr, Replicate(X2 - X1 - 1, H));
  FastWrite(X2, Y1, Attr, TR);
  for I := Y1 + 1 to Y2 - 1 do
  begin
    FastWrite(X1, I, Attr, V);
    FastWrite(X2, I, Attr, V);
  end;
  FastWrite(X1, Y2, Attr, BL);
  FastWrite(X1 + 1, Y2, Attr, Replicate(X2 - X1 - 1, H));
  FastWrite(X2, Y2, Attr, BR);
end;
{$F-}
