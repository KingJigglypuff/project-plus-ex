########################################################################
[Project+] CPU characters can use tags within Special Brawl [DukeItOut]
# Necessary for the below code if wanting to fight Boss AI!!!!
# Requires a controller to remain in the slot the AI will 
# use in order to select the tag.
# Only triggers within Special Brawl or Replays
########################################################################
HOOK @ $8011033C
{
  lis r12, 0x805B
  lwz r12, 0x50AC(r12)
  lwz r12, 0x10(r12)
  lwz r12, 0x0(r12)
  lis r6, 0x8070
  ori r5, r6, 0x2024; cmpw r5, r12; beq- %END%	# "sqSpMelee"
  ori r5, r6, 0x39D8; cmpw r5, r12; beq- %END%	# "sqReplay"
  
clearCPUtag:
  sth r0, 0xC(r3)	# Original operation, clears tags in AI slots

}
############################################################################
[Project+] BOSS Characters in Special Modes v1.1 [DukeItOut]
# If someone has a tag containing the word "BOSS"
# Then characters that do not will not experience
# special mode's behaviors
#
# BOSS = FF22FF2FFF33FF33
# boss = FF42FF4FFF53FF53
# Boss = FF22FF4FFF53FF53
# ボス  = 30DC30B9
#
# When used with "CPU characters can use tags", assign the
# tag first, then switch the character to be a CPU!
#
# v1.1: Fixed issue where ports other than P1 no longer could activate this
###########################################################################
HOOK @ $8094693C		# $80946914 for Stamina support [incomplete]
{
	li r3, 4				# \ Amount of ports to check
	mtctr r3				# /
	li r3, 0				# Set to 0 to indicate it has not found BOSS tags
	lwz r12, 0x40(r26)		# \ Get port 1's tag
	addi r12, r12, 0xA4		# /
loopCheck:
JapaneseCheck:		# Look for "ボス"
	lis r5, 0x30DC		# \ r5 = "ボス"
	ori r5, r5, 0x30B9	# /
	lwz r4, 0(r12);	cmpw r4, r5;	beq- hasBossTag
	lwz r4, 2(r12);	cmpw r4, r5;	beq- hasBossTag
	lwz r4, 4(r12);	cmpw r4, r5;	beq- hasBossTag
	lwz r4, 6(r12);	cmpw r4, r5;	beq- hasBossTag
BOSScheck:
	lis r5, 0xFF22		# \ r5 = "BO"
	ori r5, r5, 0xFF2F	# /
	lis r6,	0xFF33		# \ r6 = "SS"
	ori r6, r6, 0xFF33 	# /
B_0a:
	lwz r4, 0(r12); cmpw r4, r5; bne+ B_1a
	lwz r4, 4(r12); cmpw r4, r6; beq- hasBossTag
B_1a:
	lwz r4, 2(r12); cmpw r4, r5; bne boss_Check
	lwz r4, 6(r12); cmpw r4, r6; beq- hasBossTag
boss_Check:		
	lis r5, 0xFF42		# \ r5 = "bo"
	ori r5, r5, 0xFF4F	# /
	lis r6,	0xFF53		# \ r6 = "ss"
	ori r6, r6, 0xFF53 	# /
B_0b:
	lwz r4, 0(r12); cmpw r4, r5; bne+ B_1b
	lwz r4, 4(r12); cmpw r4, r6; beq- hasBossTag
B_1b:
	lwz r4, 2(r12); cmpw r4, r5; bne continueLoop
	lwz r4, 6(r12); cmpw r4, r6; beq- hasBossTag
boss_Check2:	
	lis r5, 0xFF22		# \ r5 = "Bo"
	ori r5, r5, 0xFF4F	# /
	lis r6,	0xFF53		# \ r6 = "ss"
	ori r6, r6, 0xFF53 	# /
B_0c:
	lwz r4, 0(r12); cmpw r4, r5; bne+ B_1c
	lwz r4, 4(r12); cmpw r4, r6; beq- hasBossTag
B_1c:
	lwz r4, 2(r12); cmpw r4, r5; bne continueLoop
	lwz r4, 6(r12); cmpw r4, r6; beq- hasBossTag	
hasBossTag:
	ori r3, r3, 1		# Confirm there is a boss tag on one of the slots!	
	addi r5, r31, 0xC	# Get the tag for THIS port
	cmpw r5, r12
	bne+ continueLoop
	ori r3, r3, 2		# I'm the boss!
continueLoop:
	addi r12, r12, 0x5C	# Go to next port!
	bdnz+ loopCheck

determineBossStatus:	
	andi. r0, r3, 1;	beq+ normal	# Is there a boss?
	andi. r0, r3, 2;	bne+ normal	# Am I the boss?
	# lbz r3, 0x1C(r31)		# \
	# andi. r3, r3, 0x7F		# | Turn off stamina behavior for this character.
	# stb r3, 0x1C(r31)		# / Commented out currently until it works.
	lis r12, 0x8094			# \
	ori r12, r12, 0x6A08	# | Skip checking special mode statuses on spawning if someone else has a BOSS tag
	mtctr r12				# |
	bctr					# /
normal:
	# lhz r0, 0x24(r31)		# Original operation for stamina version [incomplete]
	lfs f1, 0x40(r31)		# Original operation for non-stamina version 
}