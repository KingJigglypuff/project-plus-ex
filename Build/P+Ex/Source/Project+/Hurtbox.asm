############################################################################################
Skip Attacker On-Hit Functions if it hits a Custom Hurtbox kind 2.0 [MarioDox, DukeItOut]
############################################################################################
# Allows aesthetic or projectile-unaffecting stage hazards to exist
#
# 1.1: Fixed bug where some reflectors could fail in Subspace or other scenarios.
# 2.0: No longer relies upon task ID manipulation to function.
############################################################################################
# Hit types: Player = A | Items = B | Articles = C | Stage hurtboxes = 6-9 | Boss hitboxes = 5
# Normal Stage Hurtboxes = 6
# Hanenbow Tadpole Hurtboxes = 7
# ? = 8
# Skyworld Hurtboxes = 9
# bit 0 set = No Attacker Reaction
# bit 1 set = No Attacker Reaction if not the player, themselves. (i.e. projectiles pierce)
HOOK @ $807463E4
{
    lwz r3, 0(r3) 							# original op
	cmpwi r29, 0;			bne+ %END%		# Only do the following on the first pass!
    lbz r4, 0x82(r3)						# Get something related to hit target's kind
	cmpwi r4, 0x6; 			blt- %END%		# \ We're only checking for stage hurtboxes!
	cmpwi r4, 0x9;			bgt+ %END%		# /
	lbz r4, 0x8B(r3)						# Custom byte for checking flags
	andi. r12, r4, 0x80;    bne- noAttackerReaction		
	andi. r12, r4, 0x40;	beq+ %END%		# Branch if neither of the custom flags are set
	lbz r4, 0x78(r28)						# Get something related to the hit owner's kind
	cmpwi r4, 0xA;			beq %END%
noAttackerReaction:	
	li r3, 0					# \ Act like nothing happened from this interaction
	stw r3, 0x90(r28)			# |
	stw r3, 0x94(r28)			# / 	
    lis r12, 0x8074          	#\    skip attacker functions entirely
    ori r12, r12, 0x6428      	#|
    mtctr r12                	#|
    bctr                    	#/
}
HOOK @ $8074C224				# Related to reassigning hurtbox category.
{
	andi. r12, r31, 0x3F		# There won't be more than 10 hitbox categories.
	slw r0, r0, r12				# Used r31 before, we're doing this to mask the top bits
	rlwimi r0, r31, 24, 0, 1	# 0x80 and 0x40 are used as flags for custom flag concepts.
}
HOOK @ $8074BF60				# Related to initializing a hurtbox category.
{
	andi. r12, r31, 0x3F		# There won't be more than 10 hitbox categories.
	slw r0, r0, r12				# Used r31 before, we're doing this to mask the top bits
	rlwimi r0, r31, 24, 0, 1	# 0x80 and 0x40 are used as flags for custom flag concepts.
}
HOOK @ $807420C0
{
	stb r7, 0x22(r28)	# Original operation. Set task type parameter for collision
	
	li r6, 0			# Default to initalize custom byte to.
	lbz r8, 0x10(r16)
	cmpwi r8, 6; blt- end # \ Only stage hazards should be manipulatable!
	cmpwi r8, 9; bgt- end # /
	
	lwz r8, 0x04(r16)
	lwz r8, 0x30(r8)
	lwz r8, 0x2C(r8)
	lwz r8, 0x30(r8)
	lbz r6, 0x48(r8)	# Self Collision Mask's custom upper byte
end:
	stb r6, 0x2B(r28)	# Set the collision type there, we'll need it!
}
HOOK @ $80780414
{
	stb r0, 0xA2(r3)	# Original Operation. Transfer task type ID
	lbz r0, 0x2B(r4)
	stb r0, 0xAB(r3)	# Set the custom collision ID bit here!
}