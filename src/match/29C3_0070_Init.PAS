{ src: 29C3:0070, the unit init (SAM1RE: sets the video mode; copies the notice to DS:7166) }
{ from: 0000 }
{ init }
  SetGraphMode(1);
  GetRomFonts;
  SelectFont(0);
  SetBiosMode($10);
  SetColor($F);
  Copyright := 'Copyright 1991 Peder Jungck';
  Copyright := '1019 W Lovers Lane         ';
  Copyright := 'Arlington, Texas  76013    ';
  Copyright := '(817) 795-8903             ';
