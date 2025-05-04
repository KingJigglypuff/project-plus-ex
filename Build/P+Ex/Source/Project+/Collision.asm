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

###################################################
Collisions of Size 0.0 are not tangible [DukeItOut]
###################################################
# 0.0 was previously "infinitely small"
# this makes a size of 0.0 ignored
#
# This section of the game updates every frame, so
# resizing the collision is enough to make it work
# again
###################################################
HOOK @ $8074C340
{
	lwz r11, 0x20(r27)	# Collision size. Technically a float.
	cmpwi r11, 0			# However, 0 is still 0 as an int.
	bne+ setActive		# If it isn't exactly 0, it's a real collision
	li r0, 0		# Deactivate this frame!
setActive:
	stw r0, 0(r3)	# Original operation
}