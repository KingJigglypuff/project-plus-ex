#########################################################################
[Legacy TE] Random Element Mode (Over Flower mode) 2.0 [PyotrLuzhin, Eon]
#########################################################################

HOOK @ $806DF184
{
	cmpwi r8, 1
	bne 0x8 
	li r8, 0
	cmpwi r8, 1

}

HOOK @ $80744A24
{
  stwu r1, -0x20(r1)
loc_0x0:
  stw r3, 0x08(r1)
  stw r4, 0x0C(r1)
  stw r5, 0x10(r1)
  stw r6, 0x14(r1)
  stw r11, 0x18(r2)
  lis r4, 0x9017
  ori r4, r4, 0xF360
  lbz r4, 26(r4)
  cmpwi r4, 0x1
  bne- loc_0x5C

loc_0x28:
#randi
  li r3, 18
  lis r12, 0x8003
  ori r12, r12, 0xfc7c
  mtctr r12
  bctrl

  cmpwi r3, 1
  blt end
  addi r3, r3, 1
  cmpwi r3, 0xA
  blt end
  addi r3, r3, 1
  cmpwi r3, 0xF
  blt end
  addi r3, r3, 3


end:
  lwz r6, 0x14(r1)
  word 0x54c60034 #rlwinm r6, r6, 0, 0, 26

  add r6, r3, r6

loc_0x5C:
  lwz r0, 52(r30)
  lwz r3, 0x08(r1)
  lwz r4, 0x0C(r1)
  lwz r5, 0x10(r1)
  lwz r11, 0x18(r2)
  addi r1, r1, 0x20
  stw r6, 52(r3)
}