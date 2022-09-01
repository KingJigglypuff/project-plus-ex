###########################################################
Random Angle Mode 1.2 [PyotrLuzhin, Eon]
###########################################################
#Code Menu Variant by Desi
.alias CodeMenuStart = 0x804E
.alias CodeMenuHeader = 0x02BC       #Offset of word containing location of the Random Angle Mode Toggle. Source is compiled with headers for this.
HOOK @ $80767adc
{
  lwz r0, 0x14(r3)
  stwu r1, -0x10(r1)
loc_0x0:
  stw r3, 0x08(r1)
  stw r4, 0x0C(r1)
  lis r4, CodeMenuStart
  ori r4, r4, CodeMenuHeader    #Load Code Menu Header
  lwz r4, 0 (r4)
  lbz r4, 0xB(r4)
  cmpwi r4, 0x1
  bne- loc_0x5C

loc_0x28:
#randi
  li r3, 360
  lis r12, 0x8003
  ori r12, r12, 0xfc7c
  mtctr r12
  bctrl
  addi r0, r3, 1

loc_0x5C:

  lwz r3, 0x08(r1)
  lwz r4, 0x0C(r1)
  addi r1, r1, 0x10
}