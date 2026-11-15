{ src: SAM1RE 1802:3832 (../SAM: loads SAM101.GFX (16 records of $1F80) and SAM102.GFX (3 of $800)
  into the heap, each decrypted; the record order is the file order) }
{ from: 381C }
{ interface }
{$I-}
procedure LoadGraphics;
begin
  Assign(GfxFile, 'SAM101.GFX');
  Reset(GfxFile);
  GetMem(Gfx[14], $1F80);
  Read(GfxFile, Gfx[14]^);
  Decrypt(Gfx[14]^, $1F80);
  GetMem(Gfx[1], $1F80);
  Read(GfxFile, Gfx[1]^);
  Decrypt(Gfx[1]^, $1F80);
  GetMem(Gfx[2], $1F80);
  Read(GfxFile, Gfx[2]^);
  Decrypt(Gfx[2]^, $1F80);
  GetMem(Gfx[4], $1F80);
  Read(GfxFile, Gfx[4]^);
  Decrypt(Gfx[4]^, $1F80);
  GetMem(Gfx[5], $1F80);
  Read(GfxFile, Gfx[5]^);
  Decrypt(Gfx[5]^, $1F80);
  GetMem(Gfx[6], $1F80);
  Read(GfxFile, Gfx[6]^);
  Decrypt(Gfx[6]^, $1F80);
  GetMem(Gfx[7], $1F80);
  Read(GfxFile, Gfx[7]^);
  Decrypt(Gfx[7]^, $1F80);
  GetMem(Gfx[8], $1F80);
  Read(GfxFile, Gfx[8]^);
  Decrypt(Gfx[8]^, $1F80);
  GetMem(Gfx[9], $1F80);
  Read(GfxFile, Gfx[9]^);
  Decrypt(Gfx[9]^, $1F80);
  GetMem(Gfx[13], $1F80);
  Read(GfxFile, Gfx[13]^);
  Decrypt(Gfx[13]^, $1F80);
  GetMem(Gfx[10], $1F80);
  Read(GfxFile, Gfx[10]^);
  Decrypt(Gfx[10]^, $1F80);
  GetMem(Gfx[11], $1F80);
  Read(GfxFile, Gfx[11]^);
  Decrypt(Gfx[11]^, $1F80);
  GetMem(Gfx[12], $1F80);
  Read(GfxFile, Gfx[12]^);
  Decrypt(Gfx[12]^, $1F80);
  GetMem(Gfx[3], $1F80);
  Read(GfxFile, Gfx[3]^);
  Decrypt(Gfx[3]^, $1F80);
  GetMem(Gfx[16], $1F80);
  Read(GfxFile, Gfx[16]^);
  Decrypt(Gfx[16]^, $1F80);
  GetMem(Gfx[15], $1F80);
  Read(GfxFile, Gfx[15]^);
  Decrypt(Gfx[15]^, $1F80);
  Close(GfxFile);
  Assign(GfxSmallFile, 'SAM102.GFX');
  Reset(GfxSmallFile);
  GetMem(GfxSmall[2], $800);
  Read(GfxSmallFile, GfxSmall[2]^);
  Decrypt(GfxSmall[2]^, $800);
  GetMem(GfxSmall[3], $800);
  Read(GfxSmallFile, GfxSmall[3]^);
  Decrypt(GfxSmall[3]^, $800);
  GetMem(GfxSmall[1], $800);
  Read(GfxSmallFile, GfxSmall[1]^);
  Decrypt(GfxSmall[1]^, $800);
  Close(GfxSmallFile);
end;
{$I+}
