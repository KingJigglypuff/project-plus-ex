##########################################################################
Fall animations can accept animation transition blend settings [DukeItOut]
##########################################################################
# Allows you to use the blend setting parameters for the following 
#	subactions: Fall (0x20), FallAerial (0x23) and FallSpecial (0x26)
#
# Characters will only start to be able to lean with Fall_F and Fall_B 
#	after the blending is over!
##########################################################################
.alias FallBlend = 9
.alias FallAerialBlend = 3
.alias FallSpecialBlend = 5
HOOK @ $80871DE4
{
	lwz r3, 0x70(r31)	# \
	lwz r3, 0x24(r3)	# | RA-Basic
	lwz r3, 0x0C(r3)	# /
	lwz r3, 0x18(r3)	# RA-Basic 6
	cmpwi r3, 0			# 
	bne+ continue		# Only do at the start of the falling process!
	
	/*
	lwz r3, 0x14(r31)	# \ Get the subaction
	lwz r4, 0x58(r3)	# /
	addi r3, r3, 0x34	# Subaction Content
	li r5, 1			#
	bla 0x72B9F8		# Get subaction info
	lbz r4, 0(r3)		# Transition frame count
	
	//This is the normal way to do it.
	//However, we are doing a code-only method instead to make it universal.
	*/
	lwz r3, 0x7C(r31)	# \ Action
	lwz r3, 0x38(r3)	# /
	
	li r4, FallBlend			
	cmpwi r3, 0x20; beq- animMatch
	li r4, FallAerialBlend
	cmpwi r3, 0x23; beq- animMatch
	li r4, FallSpecialBlend	# Default to assuming special fall
animMatch:	
	
	stb r4, 0x10(r1)
	psq_l f1, 0x10(r1), 1, 2	# Load and convert unsigned 8-bit value to float
	
	lwz r3, 0x14(r31)	#
	lfs f0, 0x40(r3)	# Current frame
	
	fcmpu cr0, f0, f1	# See if it's past blend setting.
	bge+ startContinue	# If so, make it return to normal behavior.
	ba 0x872050			# Go to the check for turning off coyote time
startContinue:
	lwz r3, 0x70(r31)	# \
	lwz r3, 0x24(r3)	# | RA-Basic
	lwz r3, 0x0C(r3)	# /
	li r4, 1			# Set RA-BAsic 6 to 1 
	stw r4, 0x18(r3)	# so that the animation loop doesn't re-trigger this code!
continue:
	lis r29, 0x2100	# Original operation
	mr r4, r31		# Restore r4
}


###############################################################
Animation Blend Override Engine [DukeItOut]
###############################################################
# Due to oddities in the animation engine of Brawl, 
# if a character is able to buffer an option during hitstop,
# they will be stuck in the first frame of the NEXT subaction
# if animation blending is not explicitly defined in the 
# subaction's header. (Typically set to 0)
#
# This exploits this property by forcing blending on such a
# cancel option.
#
# For some reason, Yoshi's armored rising aerials ignore this
# fix even when modifying the area in memory where they do the
# above to do the same thing though it still applies fine to 
# air dodges.
#
# This also modifies blending for falling animations to make
# them smoother.
#
# Replaces Hitstop Cancels Maintain The Hitframe On Transition
###############################################################
.alias HitstopBlendFrameCount = 5 # For attacks
.alias HitstopBlendFrameCountB = 1 # For defensive actions
.alias FallBlend = 9
.alias FallAerialBlend = 3
.alias FallSpecialBlend = 5
HOOK @ $80724344
{
	stwu r1, -0x10(r1)
	
	lwz r3, 0x8(r26)	# \
	lwz r3, 0x3C(r3)	# | This code must only modify
	lwz r3, 0xA4(r3)	# | characters!
	mtctr r3			# |
	bctrl				# |
	cmpwi r3, 0			# |
	bne+ normal			# /
	
	lwz r3, 0x7C(r26)
	lwz r4, 0x38(r3)	# Current action [entering]

	cmpwi r4, 0x0E; beq- fall			# \
	cmpwi r4, 0x0F; beq- fallAerial		# | Falling animations
	cmpwi r4, 0x10; beq- fallSpecial	# /
	
	lwz r3, 0x50(r26)	# \ Frames of hitlag left.
	lwz r3, 0x10(r3)	# /
	cmpwi r3, 0			# \ Don't modify if not in hitlag!
	beq+ normal			# /
	
	cmpwi r4, 0x0D; blt- runCancel		# Dashes, Runs, Jumps
	cmpwi r4, 0x1E; blt- normal			# \ Grounded Dodges
	cmpwi r4, 0x21; beq- dodge			# / and Air Dodge
	cmpwi r4, 0x24; blt+ normal			# \ Grounded Normals
	cmpwi r4, 0x34; ble+ normalAttack	# / Aerials and Standing Grab
	cmpwi r4, 0x7F; beq- normalAttack	# Tether Aerial
	cmpwi r4, 0x112; blt+ normal 		# Specials
normalAttack:
	li r5, HitstopBlendFrameCount
	b continue
fall:
	li r5, FallBlend
	b continue
fallAerial:
	li r5, FallAerialBlend
	b continue
fallSpecial:
	li r5, FallSpecialBlend
	b continue
runCancel:	
dodge:
	li r5, HitstopBlendFrameCountB
continue:
	stb r5, 0x8(r1)
	addi r3, r24, 0x34
	lwz r4, 0x348(r1)	# Subaction (0x338 + 0x10)
	li r5, 1
	bla 0x72B9F8		# Get subaction info
	lbz r4, 0(r3)		# Transition frame count
	lbz r5, 8(r1)
	cmpw r4, r5		# \ If it already does this to this extent,
	bge- normal		# / don't bother modifying!
	stw r3, 0x8(r1)
	stb r4, 0xC(r1)
	stb r5, 0(r3)		# Force to blend in this context
	
	mr r3, r24			# Restore r3
	addi r4, r1, 0x348	# Restore r4 0x338 + 0x10
	
	lwz r12, 0(r24)		# \ Original operation
	lwz r12, 0x80(r12)	# |
	mtctr r12			# |
	bctrl				# /
	
	lwz r3, 0x8(r1)		# \
	lbz r4, 0xC(r1)		# | Restore transition frames for subaction
	stb r4, 0(r3)		# / 
	addi r1, r1, 0x10
	ba 0x724354			# Return
	
normal:
	addi r1, r1, 0x10
	mr r3, r24			# Restore r3
	addi r4, r1, 0x338	# Restore r4
	lwz r12, 0(r24)		# Original operation
}