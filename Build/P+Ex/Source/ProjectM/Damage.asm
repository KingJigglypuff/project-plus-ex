#######################################################################
[Project M] Half Damage from Outside Sources While Grabbed v1.2 [Magus]
#######################################################################
HOOK @ $80769E58
{
  lfs f0, 4(r31)
  stwu r1, -24(r1)
  stmw r28, 8(r1)
  lis r28, 0x8180;  cmpw r7, r28;  bge- loc_0xA8
  lwz r30, 100(r7);  cmpw r30, r28;  bge- loc_0xA8
  lwz r30, -12(r30);  cmpw r30, r28;  bge- loc_0xA8
  lwz r30, 56(r30);  cmpw r30, r28;  bge- loc_0xA8
  lwz r30, 68(r30)
  lwz r31, 112(r7)
  lwz r31, 32(r31)
  lwz r31, 20(r31);  cmpw r24, r28;  bge- loc_0x90
  lwz r29, 40(r24);  cmpw r29, r30;  bne- loc_0x90
  lis r28, 0xC120
  stw r28, 24(r31)
  b loc_0xA8

loc_0x90:
  lis r28, 0x3F00
  stw r28, 16(r2)
  lfs f1, 16(r2)
  fmuls f0, f0, f1
  lis r28, 0xC0A0
  stw r28, 24(r31)

loc_0xA8:
  lmw r28, 8(r1)
  addi r1, r1, 0x18
  stfs f0, 4(r31)
  lfs f1, 0(r31)

}

########################################################
Stale Moves Stale Damage Output but not KBG v3.1 [Magus]
########################################################
HOOK @ $80769F5C
{
  lwz r12, 40(r24)
  lwz r12, 208(r12)
  lfs f3, 8(r12)
  lis r0, 0x8100;  cmpw r12, r0;  bge+ loc_0x1C
  lfs f3, -23464(r2)

loc_0x1C:
  fdivs f2, f28, f3
  fctiwz f2, f2
  stfd f2, 16(r2)
  lhz r12, 22(r2)
  lfd f0, -31632(r2)
  lis r3, 0x4330
  stw r3, 16(r2)
  xoris r12, r12, 32768
  stw r12, 20(r2)
  lfd f2, 16(r2)
  fsub f2, f2, f0
  fmuls f2, f27, f2
}

Stale Move Queue Ratios Modifier [spunit262]
* 06FC0988 00000028
* 00000000 3DB851EC
* 3DA3D70A 3D8F5C29
* 3D75C28F 3D4CCCCD
* 3D23D70A 3CF5C28F
* 3CA3D70A 3C23D70A

######################################################
Store Hitbox Damage into Variables On Hit v1.2 [Magus]
######################################################
HOOK @ $8083FDF8
{
  stfs f30, 0x114(r29)
  stw r30, 0x10(r2)
  lis r0, 0x8123;  ori r0, r0, 0xEF00;  cmpw r31, r0;  blt- loc_0xBC
  lis r0, 0x8138;  ori r0, r0, 0x6EFC;  cmpw r31, r0;  bgt- loc_0xBC
  lwz r12, 0x70(r31)
  lwz r12, 0x20(r12)
  lwz r12, 0x14(r12)
  mflr r0
  lis r30, 0x8083;  ori r30, r30, 0xFC6C;  cmpw r0, r30;  beq- loc_0xA8
  lis r30, 0x8083;  ori r30, r30, 0xFD28;  cmpw r0, r30;  beq- loc_0x90
  lis r30, 0x8083;  ori r30, r30, 0xFDE8;  cmpw r0, r30;  bne- loc_0xBC

loc_0x90:
  stfs f30, 0x18(r12)
  lis r30, 0x80B8
  ori r30, r30, 0x83EC
  lfs f30, 0(r30)
  stfs f30, 0x1C(r12)
  b loc_0xBC

loc_0xA8:
  stfs f30, 0x1C(r12)
  lis r30, 0x80B8
  ori r30, r30, 0x83EC
  lfs f30, 0(r30)
  stfs f30, 0x18(r12)

loc_0xBC:
  lfs f30, 0x114(r29)
  lwz r30, 0x10(r2)
}

###########################################
Store Damage Absorbed into Variable [Magus]
###########################################
HOOK @ $807531AC
{
  lwz r5, 0x70(r29)
  lwz r5, 0x20(r5)
  lwz r5, 0x14(r5)
  stfs f1, 0x18(r5)
  mr r5, r27
}