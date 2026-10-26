##############################################
Aerial Forbidden SDI [DukeItOut]	
##############################################
# Only Grounded Forbidden SDI exists in Brawl. 
# This makes it also perform Melee-style
# Aerial Forbidden SDI
##############################################
HOOK @ $80876CA0
{
	lbz r0, 0x45(r31)			# \
	rlwinm r0, r0, 26, 31, 31	# | We don't want to modify anything if on the ground!
	cmplwi r0, 1				# | The game already calculates grounded forbidden SDI!
	beq setPosition				# /
	
	lfs f1, -0x4(r4)	# Y to shift by (X to shift by in -0x8)
	lfs f2, 0x10(r13)	# 0.0
	fcmpu cr0, f1, f2	# Is it negative, meaning we're trying to shift downwards?
	bge setPosition		# If not, we're not modifying this. This is a check
						# for ground underneath the character!
	
	stwu r1, -0x30(r1)
	mflr r0
	stw r0, 0x34(r1)
	stw r3, 0x8(r1)
	stw r4, 0xC(r1)
	stw r12, 0x1C(r1)
	
	stfs f2, 0x20(r1)# X (temp shift) (0.0) Only calculating directly downwards.
	stfs f1, 0x24(r1)# Y (temp shift) (Y to shift by)
	stfs f2, 0x28(r1)# Z (temp shift) (0.0)
	
	lfs f1,  0x00(r4) # X (calculated anticipated X position)
	stfs f1, 0x10(r1) # X (temp pos)
	lfs f2,  0x10(r3) # Y (current)
	stfs f2, 0x14(r1) # Y (temp pos)
	lfs f3,  0x14(r3) # Z (current)
	stfs f3, 0x18(r1) # Z (temp pos)
	
	
	addi r3, r1, 0x10 # The offset to the XYZ pos info expected
	addi r4, r1, 0x20 # Pointer to 3D shift vector
	li r5, 1
	li r6, 0
	li r7, 1
	li r8, 1
	bla 0x932600	# raytrace the stage based on the current position and 
					# see if it might collide
	cmpwi r3, 0		# Is there NOT an anticipated collision? 
					# If there is a collision, r3 will be 1
					# Abusing beq/bne here! Don't lose the condition register
					# by adding stuff here!
	lwz r3, 0x8(r1)
	lwz r4, 0xC(r1)
	lwz r12, 0x1C(r1)
	lwz r0, 0x34(r1)
	mtlr r0
	addi r1, r1, 0x30
	
	beq+ setPosition	# If the collision check failed to find an anticipated
						# collision, don't modify the Y value!

	lfs f1,  0x10(r3)	# Keep the Y pos the same
	stfs f1, 0x04(r4)	# 
	
setPosition:
	mtctr r12		# Original operation. Preparing to set the position.
}