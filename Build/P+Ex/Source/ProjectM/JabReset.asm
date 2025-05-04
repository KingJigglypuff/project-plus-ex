################################################################
Jab Reset Hitstun Linker and Jab Resets v9.0 [Shanus, DukeItOut]
################################################################
#
# Converted to ASM from PSA.
# Fixed issues regarding jab reset animations playing improperly
# in the air and forcing standing up in stamina at 0HP.
#
# Currently disabled as it doesn't work completely as desired.
# Kept in the codeset to revisit potentially later.
################################################################
HOOK @ $8085C1B4
{
	lwz r3, 0x7C(r31)	# \ Get the action we're moving away from
	lhz r3, 0x3A(r3)	# /
	cmpwi r3, 0x4D;	bne+ finish	# Were they fallen?
	cmpwi r4, 0x44;	bne+ finish	# Are we trying to do an airborne landing hit?
	lwz r3, 0x44(r31)	# \
	lwz r3, 0x40(r3)	# | Get the damage of the last hit to connect
	lwz r3, 0x48(r3)	# /
	cmpwi r3, 7; bge+ finish	# only jab reset if 6% or less!		
	li r4, 0x54			# Force to jab reset
finish:
	mr r5, r31		# Original operation
}
op beq- 0x1C @ $80878D68 # Force getup on the first jab reset! No jab locks!
HOOK @ $80876D10
{
	cmpwi r30, 0x51	# Getting up from being fallen
	bne- finish
	
	lwz r12, 0x70(r31)	# \
	lwz r12, 0x20(r12)	# |
	lwz r12, 0x0C(r12)  # | LA-Basic[56] Hitstun frames remaining
	lwz r12, 0xE0(r12)  # /
	cmpwi r12, 13		# \ If it performs 13 frames of hitstun or more but was only enough damage to jab reset
	blt- finish			# / then have the following options available: roll and getup attack!
	
	lwz r12, 0xD8(r31)	# \
	lwz r12, 0x5C(r12)	# | Get controller info
	lwz r12, 0x14C(r12)	# /
	
	lwz r11, 0x44(r12)	# \
	andi. r0, r11, 3	# | Check if an attack or special button was pressed
	bne+ getupAttack	# / If they were, go to the getup attack action
	
	lfs f1, 0x8(r12)	# Stick X
	fabs f1, f1, f1		# We don't care about direction here.
	lis r11, 0x80B9 		# \ 80B88370 - IC-Basic[3181] - Trip Roll Sensitivity
	lfs f0, -0x7C90(r11)	# / (0.2)
	fcmpu cr0, f1, f0		# \ If meeting the threshold, we will roll!
	blt- finish				# /
getupRoll:
	li r12, 0x52		# Getup Roll animations (direction decided within action)
	b forceChange
getupAttack:
	li r12, 0x53		# Getup Attack animation
forceChange:	
	sth r12, 0x3A(r29)	# \ Alter the action that we actually will enter!
	mr r30, r12			# /
finish:
	stwu r1, -0x20(r1)	# Original operation
}

# Prevent Subactions AD and B6 from being read, they're missing in most PM characters!
# Use AC and B5, instead!
# Values read normally from Action 0x54
address $80FB4E3C @ $80FB4F30 # 80F9FC20 + 15310 (Fighter.pac)
address $80FB4E44 @ $80FB4F40 # 80F9FC20 + 15320