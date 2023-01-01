########################################
Raycast ignores Nonetype collision [Eon]
#
# This prevents collisions that 
# characters can't see from activating
# collision detection. This most
# notably comes into play with how AI
# decides where to attempt to land.
########################################
HOOK @ $80138154
{

  lhz r0, 0xE(r3)
  andi. r0, r0, 0xF
  lbz r0, 0x10(r3)
  bne %end%
  lis r12, 0x8013
  ori r12, r12, 0x8310
  mtctr r12
  bctr
}