{ src: GUESS 0529:86DF (the main loop's touch pass: Touch at the four corners of the player's box, inset one
  pixel left and right) }
{ interface }
procedure TouchPlayer;
begin
  Touch(Slots[1].X + 1, Slots[1].Y);
  Touch(Slots[1].X + 14, Slots[1].Y);
  Touch(Slots[1].X + 1, Slots[1].Y + 15);
  Touch(Slots[1].X + 14, Slots[1].Y + 15);
end;
