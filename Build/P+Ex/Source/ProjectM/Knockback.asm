##################################################
Knockback Reduced 1/3 while Crouching v2.2 [Magus]
##################################################
# Normal Angles
HOOK @ $80769FCC
{
  lwz r3,  0x3C(r23)
  lwz r12, 0x7C(r3)
  lwz r12, 0x38(r12)
  cmpwi r12, 0x11;  blt+ %END%				# \ Only reduce knockback if in action 0x11 (entering crouch) or 0x12 (crouching) 
  cmpwi r12, 0x12;  bgt+ %END%				# /
  lis r12, 0x80B9;  						# \ An address that holds the value 2/3 in float format
  lfs f1, -0x7CB8(r12)						# /
  fmuls f27, f27, f1
}

########################################
Subtractive Knockback Armor v1.1 [Magus]
########################################
HOOK @ $8076A4A0
{
  cmpwi r30, 0x4; beq- %END%
  cmpwi r30, 0x2
}
HOOK @ $80769FD0
{
  lwz r12, 0x44(r3)
  lwz r11, 0x48(r12)
  cmpwi r11, 0x4;  bne+ loc_0x30
  lfs f1, 0x4C(r12)
  fsubs f27, f27, f1
  lis r12, 0x80		# \
  stw r12, 0x10(r2)	# | 
  lfs f1, 0x10(r2)	# /
  fcmpo cr0, f27, f1;  bge- loc_0x30
  fmr f27, f1
loc_0x30:
  lwz r3, 216(r3)
}
HOOK @ $807BBED4
{
  cmpwi r0, 0x4;  beq- %END%
  cmpwi r0, 0x2
}
HOOK @ $807BBF04
{
  cmpwi r0, 0x4;  bne+ loc_0x18
  lis r12, 0x80			# \
  stw r12, 0x10(r2)		# |
  lfs f3, 0x10(r2)		# /
  b %END%
loc_0x18:
  lfs f3, 8(r3)
}

###########################################################################
Melee KB Stacking and Stacks After 10th Frame of KB v2.0 [Magus, DukeItOut]
#
# 1.1: made it so the Char ID check doesn't cause a memory leak
# 1.2: made knockback stacking not randomly fail to apply to high knockback
# 1.3: made a more robust character check that isn't dependent on char ID
# 2.0: made it so that knockback always stacks when hit by items or projectiles
###########################################################################

op b 0x1AC @ $8085C8D4
HOOK @ $8076D3B0
{
  mfcr r12
  stw r12, 0x14(r2)
  stw r4,  0x18(r2)
  
  lfs f4,  0x24(r1)

  lwz r12, 0x8(r18)
  lwz r12, 0x3C(r12)
  lwz r12, 0xA4(r12)
  mtctr r12
  mr r4, r3
  bctrl
  cmpwi r3, 0; mr r3, r4; bne- loc_0x118 # check if the object hit is a character. Other objects don't get knockback stacking!

  lwz r12, 0x70(r18) # \
  lwz r12, 0x20(r12) # | LA-Basic
  lwz r12, 0x0C(r12) # /
  lwz r4, 0x138(r12) # LA-Basic[78]
  cmpwi r4, 0x9
  li r4, 0x0
  stw r4, 0x138(r12)
					ble- loc_0x118 # Check if the counter is 9 or less
forceStack:	
  cmpwi r28, 0x4;  beq+ loc_0x74
  cmpwi r28, 0x5;  beq+ loc_0x74
  cmpwi r28, 0x7;  beq+ loc_0x74
  cmpwi r28, 0xF;  beq- loc_0x74
  b loc_0x118
loc_0x74:
  lwz r12, 0x88(r18)
  lwz r12, 0x14(r12)
  lwz r12, 0x4C(r12)
  lfs f1, 0x10(r13)	# Force f1 to be zero
  lfs f2, 0x8(r12)	# New X. Old X in f0.
  lfs f3, 0xC(r12)	# New Y. Old Y in f4.
  
  ## Checking X
  fcmpo cr0, f2, f1;  beq+ loc_0xD4	# Is f2 = 0.0?
					  blt- loc_0xB8 # Is f2 < 0.0?
  fcmpo cr0, f0, f1;  ble- loc_0xD0 # \
  fcmpo cr0, f2, f0;  ble+ loc_0xD4 # / Is f2 > f0 & f0 > 0.0?
  fmr f0, f2						# If so, f2 replaces f0!
  b loc_0xD4

loc_0xB8: # when f2 < 0.0
  fcmpo cr0, f0, f1;  bge- loc_0xD0 # \
  fcmpo cr0, f2, f0;  bge+ loc_0xD4 # / Is f2 < f0 & f0 < 0.0?
  fmr f0, f2						# If so, f2 replaces f0!
  b loc_0xD4

loc_0xD0: # when (f0 ≤ 0.0 & f2 > 0.0) or (f0 ≥ 0.0 & f2 < 0.0)
  fadds f0, f0, f2

  ## Checking Y
loc_0xD4:
  fcmpo cr0, f3, f1;  beq+ loc_0x114 # Is f3 = 0.0?
					  blt- loc_0xF8  # Is f3 < 0.0?
  fcmpo cr0, f4, f1;  ble- loc_0x110 # \
  fcmpo cr0, f3, f4;  ble+ loc_0x114 # / Is f3 > f4 & f4 > 0.0?
  fmr f4, f3						 # If so, f3 replaces f4!
  b loc_0x114

loc_0xF8: # when f3 < 0.0
  fcmpo cr0, f4, f1;  bge- loc_0x110 # \
  fcmpo cr0, f3, f4;  bge+ loc_0x114 # / Is f3 < f4 & f4 < 0.0?
  fmr f4, f3						 # If so, f3 replaces f4!
  b loc_0x114

loc_0x110: # when (f4 ≤ 0.0 & f3 > 0.0) or (f4 ≥ 0.0 & f3 < 0.0)
  fadds f4, f4, f3

loc_0x114:
  stfs f0, 0xC(r20)

loc_0x118:
  lwz r12, 0x14(r2)
  mtcr r12
  lwz r4, 0x18(r2)
}
HOOK @ $80913194
{
  lwz r12, 0x50(r21);  lbz r12, 0x1C(r12)	# \
  rlwinm. r12, r12, 25, 31, 31				# | Check if in hitstop
  bne- loc_0x3C								# / 
  lwz r12, 0x14(r21);  lhz r12, 0x5A(r12)	# \
  cmpwi r12, 0xA9;  beq- loc_0x3C 			# / Check if paralyzed. Don't increment if so.
  lwz r12, 0x70(r21)	# \
  lwz r12, 0x20(r12)	# | Access LA-Basic
  lwz r12, 0xC(r12)		# /
  lwz r4, 0x138(r12)	# \
  addi r4, r4, 0x1		# | Increment LA-Basic[78] each frame. It resets whenever hit.
  stw r4, 0x138(r12)	# /
loc_0x3C:
  lis r4, 0x1000
}

###################################################################
Windbox Stacking For Fighter Hitboxes [DukeItOut]
###################################################################
#
# Still not treated as standard knockback, but doesn't
# remove existing knockback in normal conditions.
#
# Treated as knockback stack avoidance in the first 12 frames
# of knockback an opponent is in with an extra 3 frames of leniency
# if the opponent is moving downwards.
#
# Does not stack if the windbox is appreciably moving downwards.
#
###################################################################
HOOK @ $8076C988
{
	lwz r12, 0x8(r28)	# \
	lwz r12, 0x3C(r12)	# | Get the object type!
	lwz r12, 0xA4(r12)	# |
	mtctr r12			# |
	bctrl				# |
	mr r7, r3			# /
	lwz r12, 0(r27) 	# Original operation
}
HOOK @ $8076C9A4
{
	cmpwi r7, 0; bne- skip		# This stuff is ONLY supposed to be for fighters!
								# Interestingly, items don't have this bug anyway.

	lwz r12, 0x44(r28)			# \
	lwz r12, 0x40(r12)			# | Hitbox Angle
	lwz r12, 0x5C(r12)			# /
	cmpwi r12, 0; beq- skip		# Brawl's non-fighter windboxes use angle 0

	stwu r1, -0x20(r1)
	

	lfs f1, 0x90(r29)	# Y Speed of Hitbox
	lfs f2, -0x90(r13)	# -1.0
	fcmpu cr1, f1, f2	# Checking if hitbox is moving downwards

	lwz r12, 0x7C(r28)	#
	lhz r7, 0x3A(r12)	# Current Action
	cmpwi r7, 0x45; bne+ normal	# Knockback Action
calculate:	
	lwz r12, 0x70(r28)
	lwz r12, 0x20(r12)
	lwz r12, 0x0C(r12)
	lwz r3, 0x14C(r12)	# LA-Basic[83] (KB Stacking timer. Also used for Up Special timings outside of this action's context)
	bge cr1, notDownwards	# They're falling at a rate that even is lenient enough for what
							# you are at after pausing in mid-air from charging Offense Up (-1.25)	
	cmpwi r3, -5
	bge normal			# Allow for stacking under 15 frames if moving downwards!
notDownwards:
	cmpwi r3, -2
	bge normal			# Allow for stacking under 12 frames otherwise!
	
	lwz r12, 0x88(r28)	# \
	lwz r12, 0x14(r12)	# | Knockback Info
	lwz r12, 0x4C(r12)	# /
gotKnockbackPointer:
	stw r12, 0x10(r1)	# Pointer will come in handy in a bit.
	psq_l f1, 0x8(r12), 0, 1 # \ X&Y Knockback
	psq_st f1, 0x8(r1), 0, 1 # /
	bctrl				# Original operation. Reset knockback
				
	# This formula progressively weakens the windbox the stronger
	# the original knockback is
	
	lwz r12, 0x10(r1)
	
	psq_l f1, 0x8(r12), 0, 1	# New X&Y
	psq_l f0, 0x8(r1), 0, 1		# Old X&Y
	
	ps_add f2, f1, f0			# sum of new and old
	
	ps_abs f3, f2				# \ Get the sign
	ps_div f3, f2, f3			# / We have a safety if this result is NaN below.
	
	ps_abs f4, f1		# \
	ps_abs f5, f0		# |
	ps_mul f1, f1, f4	# | New X&Y squared (retaining sign)
	ps_mul f2, f0, f5	# | Old X&Y squared (retaining sign)
	ps_add f1, f1, f2	# / merged
	
	ps_abs f1, f1
	ps_rsqrte f1, f1	# \ reciprocal of reciprocal square root is
	ps_res f1, f1		# / square root
	ps_mul f1, f1, f3	# Restore sign
	
	lfs f3, -0xDC8(r13)	# \ 0.85 for calibration of result
	ps_mul f1, f1, f3	# /
	ps_abs f3, f1		# NaN tester
	
	ps_sel f1, f3, f1, f0 # Sets f1 to a default of f0 if NaN, otherwise proceeds to use f1 
	
	psq_st f1, 0x8(r12), 0, 1 # store X and Y	
normal:
	addi r1, r1, 0x20
skip:	
	bctrl				# Original operation. Reset knockback.
}

#########################################################
Meteor Cancel Timer Doesn't Reset on Wall Bounce [mawwwk]
#########################################################
# PSA REQUIREMENTS:
# Flags0 on Action 47 must have 00040000 enabled
# for this to function correctly.
####################################################
HOOK @ $808757F0
{
    lwz r6, 0x7C(r30)    # Get current action
    lhz r6, 0x3A(r6)     # at IC-Basic[20000].
    cmpwi r6, 0x47       # If not in wallbounce,
    beq %END%            # don't change timer.
    bctrl                # Original op to set timer (LA-Basic[57])
}
