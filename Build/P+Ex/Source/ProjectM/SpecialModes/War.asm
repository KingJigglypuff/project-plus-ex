War Mode 1.5 [PyotrLuzhin, wiiztec]
HOOK @ $80816508
{
loc_0x0:
  lis r12, 0x9018
  lbz r12, -0xC81(r12) 
  cmplwi r12, 1
  bne- loc_0x74   # Check Special Mode setting
  cmpwi r20, 0x0
  beq- loc_0x74
  lwz r12, 40(r3)
  lwz r12, 0(r12)
  lwz r11, 52(r12)
  cmpwi r11, 0x0
  addi r11, r11, 0x1
  stw r11, 52(r12)
  lwz r11, 24(r3)
  bne- loc_0x54
  lis r12, 0x8059
  lwz r12, 0x82F4(r12)
  subi r12, r12, 0x4BA
  mulli r17, r11, 0x80
  sub r12, r12, r17
  li r17, 0x1
  stb r17, 0(r12)

loc_0x54:
  mulli r11, r11, 0xA0
  lis r12, 0x8058
  ori r12, r12, 0x8000
  add r12, r12, r11
  lbz r11, 157(r12)
  beq- loc_0x70
  subi r11, r11, 0x1

loc_0x70:
  stb r11, 157(r12)

loc_0x74:
  lbz r0, 15(r3)
}