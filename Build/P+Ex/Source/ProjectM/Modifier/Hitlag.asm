####################################
Hitlag Modifier [Magus] 
####################################
#	float 0.33333333 @ $80B87AEC # d * float(hitlag modifier)  # Hitlag mult written by code menu so disabled here
	float 3.0 @ $80B87AF0 # Additional frames after d * hitlag multiplier is calculated
op nop @ $80772B78
HOOK @ $80772B90
{
	fmuls f0, f0, f4
	fctiwz f0, f0
}

#####################################################
Projectiles Can Experience Hitstop [Magus, DukeItOut]
#####################################################
HOOK @ $808E53B4
{
	lbz r0, 0x21(r27)				# Collision Hit Type
	cmpwi r0, 3; beq- finish		# No hitlag when being reflected!
	lwz r0, 0xB8(r26) 				# Get the weapon ID
	cmpwi r0, 3; beq- checkHitstun 	# Link's Boomerang
	cmpwi r0, 5; beq- checkHitstun 	# Link's Arrows
	cmpwi r0, 23; beq- checkHitstun # Snake's Cypher
	cmpwi r0, 140; beq- checkHitstun# Toon Link's Arrows
	cmpwi r0, 141; bne+ finish		# Toon Link's Boomerang

checkHitstun:
	lwz r12, 0x90(r26)		# \
	lwz r12, 0xC4(r12)		# |
	mtctr r12				# | Get the creator of this projectile
	bctrl					# |
	mr r4, r3				# / 
	li r5, 0				# r5 will be a pointer to write to if non-zero!
	lis r6, 0x80B8			# \ Fighter Manager
	lwz r3, 0x7C28(r6) 		# /
	bla 0x815CB0			# \ Get the fighter entry
	mr r4, r3				# /
	
	lwz r3, 0x7C28(r6) 		# Fighter Manager
	li r5, -1				# \
	bla 0x814F20			# / Get the fighter pointer
		
	lwz r4, 0x110(r3) 		# Fighter Character ID
	cmpwi r4, 0x05; bne+ notKirby # Kirby copy abilities will need to be checked!
	lwz r4, 0x60(r3)		# \
	lwz r4, 0x70(r4)		# | Check the copy ability ID!
	lwz r4, 0x20(r4)		# | It is in LA-Basic[72]
	lwz r4, 0x0C(r4)		# |
	lwz r4, 0x120(r4)		# /
	
notKirby:
	cmpwi r4, 0x02; beq+ haveHitstun # Link
	cmpwi r4, 0x29; beq+ haveHitstun # Toon Link
	cmpwi r4, 0x2E; bne- finish		 # Snake
	# These checks are here so that, in builds that clone characters,
	# they can choose to opt-in on their own terms!
	# The only clone I currently can think of that should add support
	# for this code in those builds is Young Link.
	
haveHitstun:
	lwz r3, 0x60(r26)			# \
	lwz r3, 0x28(r3)			# |
	li r4, 0					# |
	li r5, 0					# |
	lwz r12, 0(r3)				# | Get the hitbox's damage
	lwz r12, 0x70(r12)			# |
	mtctr r12					# |
	bctrl 						# /
	fsubs f2, f2, f2			# zero out
	fcmpu cr0, f1, f2			# \ Treat as invalid if no damage!
	beq finish					# /
	
	lis r12, 0x80B8				# \
	lfs f0, 0x7AEC(r12)			# 0.333333	# \ (Damage/3 + 3.0)
	lfs f2, 0x7AF0(r12)			# 3.0		# /
	fmuls f0, f1, f0			# |
	fadds f0, f0, f2			# /
	lwz r3, 0x60(r26)			# \
	lwz r4, 0x28(r3)			# | 
	lwz r4, 0x30(r4)			# | Hitstop Multiplier
	lfs f1, 0x38(r4)			# /
	fmuls f1, f0, f1 			# (Damage/3 + 3.0) * HitstopMult = Hitstop
	fctiwz f1, f1				# \ Convert the float to the nearest integer!
	stfd f1, 0x34(r1)			# |
	lhz r12, 0x3A(r1)			# /
	lwz r4, 0x50(r3)			# \ Set the amount of hitstop frames!
	stw r12, 0x10(r4)			# /
	li r12, 0xD4				# \ Let know that it's going to have hitstop!
	stb r12, 0x1C(r4)			# /
finish:
	subi r31, r31, 0x6B48	# Original operation
	fmr f1, f30				# Restore f1, just in case
}
HOOK @ $807724F4
{
	stb r0, 0x1C(r3)		# Original operation
	lwz r3, 0x3C(r27)
	lwz r3, 0xA4(r3)
	mtctr r3
	bctrl
	cmpwi r3, 2				# check if it is a weapon
	mr r3, r30				# restore r3
	bne+ %END%
	lbz r4, 0x1C(r3)		# \
	andi. r4, r4, 0xEB		# |
	stb r4, 0x1C(r3)		# /	
}

##########################################################
Link's Arrows Don't Disappear Instantly On Hit [DukeItOut]
##########################################################
HOOK @ $809EEEDC
{
	mr r31, r4		   # Original operation
	
	lwz r6, 0x60(r3)   # \
	lwz r12, 0x50(r6)  # | Hitstop of Link arrow projectile
	lwz r12, 0x10(r12) # /
	cmpwi r12, 0	   # \ If it didn't hit anything
	beq %END%		   # / act normally
	lwz r12, 0x70(r6)  # \
	lwz r12, 0x20(r12) # |
	lwz r12, 0x0C(r12) # | LA-Basic 4 (lifespan)
	li r0, 0		   # | is set to 0. It will deactivate after the hitstun!
	stw r0, 0x10(r12)  # /
	
	stw r30, 0x8(r1)   # We are going to need to preserve this!
	
	lwz r3, 0x28(r6)   # \
	lwz r12, 0(r3)	   # | Destroy the hitboxes!
	lwz r12, 0x18(r12) # | This is only aesthetic!
	mtctr r12		   # |
	bctrl			   # /
	
	ba 0x9EEF18		   # Restore values
}
HOOK @ $80AB4194
{
	lis r12, 0x809E			# \ 
	ori r12, r12, 0xEEC8	# | Deactivate the exact same as the arrow this projectile
	mtctr r12				# | was based on code-wise.
	bctr 					# /
}