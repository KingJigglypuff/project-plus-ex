######################################################################################
[Legacy TE] Special modes rules menu change cosmetics 4.1 [wiiztec,Yohan1044,Fracture]
######################################################################################
HOOK @ $80004350
{
  lis r12, 0x9017
  ori r12, r12, 0xF377
					cmpwi r27, 0x1;  bne- loc_0xF0
					cmpwi r0, 0xFF;  bne- loc_0xF0
					cmpwi r11, 0x18;  bne- loc_0xF0
					cmplwi r28, 6;  bgt- loc_0xB0
					cmplwi r28, 2;  blt- loc_0xF0
  lbz r10, 1(r12);  cmpwi r10, 0x2;  bne- loc_0xB0
					cmpwi r5, 0x25;  beq- loc_0x74
					cmpwi r5, 0x18;  beq- loc_0x84
					cmpwi r5, 0x30;  beq- loc_0x94
					cmpwi r5, 0x1C;  beq- loc_0xA4
					cmpwi r5, 0x32;  bne- loc_0xB0
  addi r4, r4, 0x109F
  li r30, 0x3E
  li r5, 0x3C
  b loc_0xF0

loc_0x74:
  addi r4, r4, 0x10A0
  li r30, 0x26
  li r5, 0x1F
  b loc_0xF0

loc_0x84:
  addi r4, r4, 0x109A
  li r30, 0x29
  li r5, 0x22
  b loc_0xF0

loc_0x94:
  addi r4, r4, 0x10A4
  li r30, 0x2C
  li r5, 0x25
  b loc_0xF0

loc_0xA4:
  addi r4, r4, 0x1099
  li r30, 0x29
  li r5, 0x22

loc_0xB0:
  lbz r10, 3(r12);  cmpwi r10, 0x2;  bne- loc_0xF0
					cmpwi r28, 0x4;  beq- loc_0xF0
					cmpwi r5, 0x2C;  beq- loc_0xE4
					cmpwi r5, 0x2F;  bne- loc_0xF0
  addi r4, r4, 0x1271
  li r30, 0x4C
  li r5, 0x45
  b loc_0xF0

loc_0xE4:
  addi r4, r4, 0x126F
  li r30, 0x35
  li r5, 0x2E

loc_0xF0:
  lbzu r0, 1(r4)
}


HOOK @ $806A792C
{
  cmplwi r4, 2
  lis r12, 0x9017
  ori r12, r12, 0xF37A
  lbz r12, 0(r12);  cmpwi cr1, r12, 0x2;  bne- cr1, %end%
  cmplwi r4, 1
}

op li r5, 0 @ $806A77E4

HOOK @ $80206130
{
  cmpwi cr2, r3, 0xFF;  	bne- cr2, loc_0x30
  cmpwi cr2, r5, 0x224;  	bne- cr2, loc_0x30
  cmpwi cr2, r11, 0x35;  	bne- cr2, loc_0x30
  lis r12, 0x9017
  ori r12, r12, 0xF37A
  lbz r12, 0(r12)
  cmpwi cr2, r12, 0x2;  	bne- cr2, loc_0x30
  li r3, 0xF0
loc_0x30:
  stb r3, 0(r4)
}

HOOK @ $80206134
{
  lis r12, 0x9018;  lbz r12, -0xC88(r12);  cmpwi cr3, r12, 0x2
  lis r12, 0x9018;  lbz r12, -0xC86(r12);  cmpwi cr4, r12, 0x2
  lis r12, 0x3353
  ori r12, r12, 0x656C
  lwz r15, -0x3005(r4);  cmpw cr2, r15, r12;  bne- cr2, loc_0x54
  lhz r12, -0x3001(r4);  cmpwi cr2, r12, 0x3033;  bne- cr2, loc_0x74
												 bne- cr3, loc_0x48
  li r12, 0x39;  stb r12, -0x33D2(r4)
  li r12, 0x34;  stb r12, -0x3000(r4)
loc_0x48:  
												bne- cr4, loc_0x74
  li r12, 0x3130
  sth r12, -0x340B(r4)
loc_0x54:
  lis r12, 0x644E
  ori r12, r12, 0x6F63
  lwz r15, -0x703C(r4);  cmpw cr2, r15, r12;  bne- cr2, loc_0x74
											 bne- cr4, loc_0x74
  li r12, 0x74
  stb r12, -0x7080(r4)
loc_0x74:
  addi r4, r4, 0x1
}

HOOK @ $806A8278
{
  lbz r4, 0x66E(r3)
  cmpwi r4, 0xA;  ble- %end%
  li r4, 0x0;  stb r4, 0x66E(r3)
}