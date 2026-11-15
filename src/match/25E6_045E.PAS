{ src: GUESS 25E6:045E (video segment from the BIOS mode: B000h for mode 7, else B800h) }
{$F+}
procedure InitVideo;
begin
  if GetVideoMode = 7 then
    VideoSeg := $B000
  else
    VideoSeg := $B800;
  SnowWait := DetectAdapter = 1;
end;
{$F-}
