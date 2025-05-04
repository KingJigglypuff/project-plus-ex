################################################
Flat Zone Knockout Graphics Fix [DukeItOut, Eon]
################################################
# Fixes issues where graphics attached to
# characters that are being star/screen KO'd
# fail to visually appear where they should.
#
# To fix Charizard's tail, use an override
# on the death action to regenerate the tail
# effect!
################################################
HOOK @ $807A2B7C
{
	lwz r5, 0x44(r3)	# Owner of effect.	
	
	lwz r3, 0x8(r5)
	lwz r3, 0x3C(r3)
	lwz r3, 0xA4(r3)
	mtctr r3
	bctrl
	cmpwi r3, 0
	bne- Normal			# Check if a fighter.
	
	lwz r3, 0x7C(r5)
	lhz r0, 0x36(r3)
	cmpwi r0, 0x10B		# Check if KO'd or Unloaded
	bne+ notUnloaded
	lhz r0, 0x06(r3)	# Check if the PREVIOUS action was dying
notUnloaded:
	cmpwi r0, 0xBD		# Check if dying
	bne+ Normal		

	lwz r5, 0x70(r5)	# \
	lwz r5, 0x20(r5)	# | LA-Basic
	lwz r5, 0x0C(r5)	# /
	lwz r3, 0xA4(r5)	# LA-Basic 41
	cmpwi r3, 0			# \ Normal KO Blast
	beq+ Normal			# /
BlastingOff:	
	subi r12, r12, 0x2C	# \
	mtctr r12			# | Go to the function that
	bctr				# / ignores Z depth manipulation!
	
Normal:	
	lis r31, 0x805A		# Original operation
}