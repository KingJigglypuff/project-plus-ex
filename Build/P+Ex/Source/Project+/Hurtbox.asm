############################################################################################
Skip Attacker On-Hit Functions if it hits a Custom Hurtbox kind 1.1 [MarioDox, DukeItOut]
#
# Allows aesthetic or projectile-unaffecting stage hazards to exist
#
# 1.1: Fixed bug where some reflectors could fail in Subspace or other scenarios.
############################################################################################
# Hit types: Player = A | Items = B | Articles = C | Stage hurtboxes = 6 | Boss hitboxes = 5
# bit 0x80 = No Attacker Reaction
# bit 0x40 = No Attacker Reaction if not the player, themselves.
HOOK @ $807463E4
{
    lwz r3, 0(r3) 							# original op
	cmpwi r29, 0;			bne+ %END%		# Only do the following on the first pass!
    lbz r4, 0x82(r3)						# Get something related to hit target's kind
	andi. r12, r4, 0x3F;
	cmpwi r12, 0x6; 		bne %END%		# We're only checking for stage hurtboxes!
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
op rlwinm r0, r4, 2, 24, 29	@ $8002F018 # Filter out highest two unused bits for task types.