Big Head Mode v1.0 [Eon]
#Code Menu Variation by Desi

.alias CodeMenuStart = 0x804E
.alias CodeMenuHeader = 0x02B8       #Offset of word containing location of the Big Head Mode. Source is compiled with headers for this.

HOOK @ $80839010
{ 
  stwu r1, -0x20(r1)
  mflr r0
  stw r0, 0x24(r1)
 
  #Code Menu Check
  lis r3, CodeMenuStart
  ori r3, r3, CodeMenuHeader    #Load Code Menu Header
  lwz r3, 0 (r3)
  lbz r3, 0xB(r3)
  cmpwi r3, 0x1
  blt return

  #getCameraSubject(0)
  lwz r3, 0xD8(r31)
  lwz r3, 0x60(r3)
  lwz r3, 0x18(r3)
  li r4, 0
  lwz r12, 0x0(r3)
  lwz r12, 0xC(r12)
  mtctr r12
  bctrl 
 
  lwz r4, 0x10(r3)

  lis r3, CodeMenuStart
  ori r3, r3, CodeMenuHeader    #Load Code Menu Header
  lwz r3, 0 (r3)
  lbz r3, 0xB(r3)
  lis r0, 0x4000
Large:
  cmpwi r3, 2
  bne Larger
  lis r0, 0x4025
Larger:
  cmpwi r3, 3
  bne Largerest
  lis r0, 0x4050
Largerest:
  cmpwi r3, 4
  bne Size_Set
  lis r0, 0x4075

Size_Set:

  lwz r4, 0x0(r4) #HeadN node ID 
  stw r0, 0x8(r1)
  stw r0, 0xC(r1)
  stw r0, 0x10(r1)
  addi r5, r1, 0x8
 
  lwz r3, 0xD8(r31)
  lwz r3, 0x4(r3)
  lwz r12, 0x8(r3)
  lwz r12, 0x68(r12)
  mtctr r12 
  bctrl 
 
 return:
  lwz r0, 0x24(r1)
  mflr r0
  addi r1, r1, 0x20
 
orig:
  lis r3, 0x80B8
}