###################################################
Temporary Requirement ID Storage System [DukeItOut]
###################################################
HOOK @ $807824CC
{
  stw r0, 0x4F8(r1)	
  lis r27, 0x8078
  stw r4, 0x24D4(r27)
  mr r27, r5
  mr r28, r6
}
op b 0x8 @ $807824D0

#####################################################
Extra Requirement Checks (Requires TRISS) [DukeItOut]
#####################################################
HOOK @ $807824EC
{
  cmpwi r4, 0x64
  bne- loc_0xC
  li r4, 0x17

loc_0xC:
  cmpwi r4, 0x4D
}

HOOK @ $80783650	
{
  lis r4, 0x8078
  lwz r4, 0x24D4(r4)
  cmplwi r4, 0x17
  addi r4, r1, 0x428	# Original operation
loc_0x10:
  beq+ %END%			
						# Skip the below if this is the normal way to access the raytracing
  stwu r1, -0x10(r1)	# 0x64 Is Floor In Front
  lis r5, 0x4330
  stw r5, 8(r1)
  lis r5, 0x8000
  stw r5, 0xC(r1)
  lfd f0, 8(r1)
  lfd f1, 0x508(r1)
  fsubs f1, f1, f0
  lis r5, 0x476A
  ori r5, r5, 0x6000
  stw r5, 8(r1)
  lfs f0, 8(r1)
  fdivs f1, f1, f0
  lwz r5, 0x18(r28)
  lfs f0, 0x40(r5)
  fmuls f1, f1, f0
  lfs f0, 0(r4)
  fadds f0, f0, f1
  stfs f0, 0(r4)
  lis r5, 0x3F40
  stw r5, 0xC(r1)
  lfs f1, 0xC(r1)
  addi r1, r1, 0x10
  mr r3, r30
  rlwinm r5, r0, 1, 31, 31
}
