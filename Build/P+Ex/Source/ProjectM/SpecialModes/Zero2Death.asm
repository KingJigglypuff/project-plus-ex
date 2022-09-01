0 to death mode 3.4d [wiiztec]
HOOK @ $806DF180
{
loc_0x0:
  lbz r8, 26(r26)
  cmpwi r8, 0x2
  bne- loc_0x10
  li r8, 0x0

loc_0x10:
}
HOOK @ $80769694
{
loc_0x0:
  stfs f1, 0(r4)
  stwu r1, -128(r1)
  stmw r2, 8(r1)
  lis r12, 0x9018
  lbz r12, 3899(r12)
  cmpwi r12, 0x28
  beq- loc_0x1A8
  cmpwi r27, 0x3
  beq- loc_0x1A8
  lis r12, 0x8058
  ori r12, r12, 0x82FC
  lis r14, 0x8171
  ori r14, r14, 0xD278
  lis r15, 0x9018
  ori r15, r15, 0xC1C
  lis r19, 0x901C
  ori r19, r19, 0x4930
  lbz r8, -6306(r15)
  cmpwi r8, 0x2
  bne- loc_0x1A8
  lis r8, 0x8180
  lwz r11, 60(r22)
  lwz r24, 8(r11)
  lwz r23, 272(r24)
  cmpwi r23, 0xF
  bne- loc_0x74
  lhz r24, 252(r24)
  cmpwi r24, 0x0
  bgt- loc_0x1A8

loc_0x74:
  lwz r18, 124(r11)
  lbz r17, 127(r18)
  lhz r18, 58(r18)
  lwz r11, 28(r11)
  cmplw r11, r8
  bgt- loc_0x1A8
  lwz r11, 40(r11)
  cmplwi r11, 65535
  blt- loc_0x1A8
  lwz r11, 16(r11)
  cmplwi r11, 65535
  blt- loc_0x1A8
  lwz r24, 16(r11)
  cmpwi r24, 0x0
  blt- loc_0x1A8
  lbz r24, 85(r11)
  lbzx r10, r19, r24
  cmpwi r10, 0xAD
  beq- loc_0xD4
  cmpwi r18, 0x74
  beq- loc_0xD4
  lwz r10, 4(r4)
  cmpwi r10, 0x0
  beq- loc_0xDC

loc_0xD4:
  stbx r0, r12, r24
  b loc_0x1A8

loc_0xDC:
  lbzx r10, r12, r24
  cmpwi r10, 0x0
  bgt- loc_0xF0
  cmpwi r18, 0xB
  bgt- loc_0x1A8

loc_0xF0:
  mulli r21, r24, 0x5C
  lbz r20, -6327(r15)
  cmpwi cr2, r20, 0x2
  cmpwi r10, 0x5A
  bne- cr2, loc_0x110
  addi r20, r15, 0x2
  lhzx r20, r20, r21
  cmpw r10, r20

loc_0x110:
  blt- loc_0x1A0
  cmpwi r17, 0x1
  beq- loc_0x134
  cmpwi r18, 0xB
  ble- loc_0x134
  cmpwi r18, 0x1A
  blt- loc_0x1A8
  cmpwi r18, 0x20
  bgt- loc_0x1A8

loc_0x134:

  #mode Check
  lbz r11, -6308(r15)
  cmpwi r11, 0
  beq- normalMatch
  cmpwi r11, 1
  beq suddenDeath
  b stamina
suddenDeath:
  li r5, 300
  li r6, 301
  lis r0, 0x4396
  b setDamage
stamina:
  li r0, 0x0
  lhzx r5, r15, r21
  subi r6, r5, 0x1
  b setDamage
normalMatch:
  li r0, 0x0 #set internal damage = 0
  li r5, 0x0 #set visual damage = 0
  li r6, 0x1 #set current displayed damage = 1
setDamage:
  stw r0, 0x0(r4)
  lis r3, 0x8061
  ori r3, r3, 0x5520
  mulli r4, r24, 0x4
  add r3, r4, r3
  lwz r3, 0x4C(r3)

  stw r6, 0x1C(r3)
  stw r5, 0x18(r3)
  
loc_0x19C:
  li r10, 0xFFFF

loc_0x1A0:
  addi r10, r10, 0x1
  stbx r10, r12, r24

loc_0x1A8:
  lmw r2, 8(r1)
  addi r1, r1, 0x80

}
op li r29, 25 @ $806a0348
op li r30, 25 @ $8069F3CC
op li r30, 25 @ $8069F890
op li r31, 25 @ $8069FDCC
HOOK @ $806844E4
{
loc_0x0:
  li r0, 0x1
  cmpwi r8, 0x0
  bne- loc_0x24
  lis r12, 0x9017
  ori r12, r12, 0xF365
  lbz r12, 0(r12)
  cmpwi r12, 0x2
  bne- loc_0x24
  li r0, 0x0

loc_0x24:
  
}
HOOK @ $80693A6C
{
loc_0x0:
  stw r5, 464(r30)
  lis r12, 0x8058
  ori r12, r12, 0x82E0
  mulli r11, r25, 0x4
  cmplwi cr3, r11, 12
  bgt- cr3, loc_0x30
  stwx r30, r12, r11
  lis r12, 0x9018
  lbz r11, -3208(r12)
  cmpwi cr3, r11, 0x2
  bne- cr3, loc_0x30
  stb r8, -3227(r12)

loc_0x30:

}
HOOK @ $806A8388
{
loc_0x0:
  stb r0, 5(r30)
  lis r5, 0x8100
  lis r7, 0x8180
  li r10, 0x0
  lis r12, 0x9018
  ori r12, r12, 0xC1C

loc_0x18:
  lis r11, 0x8058
  ori r11, r11, 0x82E0
  lwzx r11, r11, r10
  cmplw r11, r5
  blt- loc_0x5C
  cmplw r11, r7
  bgt- loc_0x5C
  lwz r11, 464(r11)
  mulli r11, r11, 0xA
  cmpwi r11, 0x0
  bne- loc_0x48
  li r11, 0x1

loc_0x48:
  sth r11, 0(r12)
  addi r12, r12, 0x5C
  addi r10, r10, 0x4
  cmpwi r10, 0x10
  bne+ loc_0x18

loc_0x5C:


}
HOOK @ $80769698
{
loc_0x0:
  lis r12, 0x9018
  lbz r11, 3899(r12)
  cmpwi r11, 0x28
  bne- loc_0x28
  lis r11, 0x8059
  stw r0, -32008(r11)
  lbz r11, -3208(r12)
  cmpwi r11, 0x2
  bne- loc_0x28
  stb r0, -3227(r12)

loc_0x28:
  blr 
}
op nop @ $80693AA4