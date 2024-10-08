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
[Project+] BOSS Characters in Special Modes v1.3 [DukeItOut, Kapedani]
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
HOOK @ $806df2d4		
{
	li r8, 4				# Amount of ports to check
	li r0, 0				# Set to 0 to indicate it has not found BOSS tags
	addi r12, r27, 0xA4		# /
loopCheck:
JapaneseCheck:		# Look for "ボス"
	lis r10, 0x30DC		# \ r10 = "ボス"
	ori r10, r10, 0x30B9	# /
	lwz r9, 0(r12);	cmpw r9, r10;	beq- hasBossTag
	lwz r9, 2(r12);	cmpw r9, r10;	beq- hasBossTag
	lwz r9, 4(r12);	cmpw r9, r10;	beq- hasBossTag
	lwz r9, 6(r12);	cmpw r9, r10;	beq- hasBossTag
BOSScheck:
	lis r10, 0xFF22		# \ r10 = "BO"
	ori r10, r10, 0xFF2F	# /
	lis r11,	0xFF33		# \ r11 = "SS"
	ori r11, r11, 0xFF33 	# /
B_0a:
	lwz r9, 0(r12); cmpw r9, r10; bne+ B_1a
	lwz r9, 4(r12); cmpw r9, r11; beq- hasBossTag
B_1a:
	lwz r9, 2(r12); cmpw r9, r10; bne boss_Check
	lwz r9, 6(r12); cmpw r9, r11; beq- hasBossTag
boss_Check:		
	lis r10, 0xFF42		# \ r10 = "bo"
	ori r10, r10, 0xFF4F	# /
	lis r11,	0xFF53		# \ r11 = "ss"
	ori r11, r11, 0xFF53 	# /
B_0b:
	lwz r9, 0(r12); cmpw r9, r10; bne+ B_1b
	lwz r9, 4(r12); cmpw r9, r11; beq- hasBossTag
B_1b:
	lwz r9, 2(r12); cmpw r9, r10; bne continueLoop
	lwz r9, 6(r12); cmpw r9, r11; beq- hasBossTag
boss_Check2:	
	lis r10, 0xFF22		# \ r10 = "Bo"
	ori r10, r10, 0xFF4F	# /
	lis r11,	0xFF53		# \ r11 = "ss"
	ori r11, r11, 0xFF53 	# /
B_0c:
	lwz r9, 0(r12); cmpw r9, r10; bne+ B_1c
	lwz r9, 4(r12); cmpw r9, r11; beq- hasBossTag
B_1c:
	lwz r9, 2(r12); cmpw r9, r10; bne continueLoop
	lwz r9, 6(r12); cmpw r9, r11; beq- hasBossTag	
hasBossTag:
	ori r0, r0, 1		# Confirm there is a boss tag on one of the slots!	
	addi r10, r6, 0xA4	# Get the tag for THIS port
	cmpw r10, r12
	bne+ continueLoop
	ori r0, r0, 2		# I'm the boss!
continueLoop:
	addi r12, r12, 0x5C	# Go to next port!
	subi r8, r8, 0x1
	cmpwi r8, 0x0
	bgt+ loopCheck

determineBossStatus:	
	andi. r12, r0, 1;	beq+ end	# Is there a boss?
	andi. r12, r0, 2;	bne+ boss	# Am I the boss?
	li r12, 0x10		
	stb r12, 0x0(r5)	
	li r12, 0
	stb r12, 0x0(r7)
	sth r12, 0xba(r6)	# startDamage
	sth r12, 0xbc(r6)	# hitPointMax
	stfs f4, 0xd8(r6)	# scale
	stfs f4, 0xe0(r6)	# gravity
	stfs f4, 0xd0(r6)	# damageReactionMul
	stfs f4, 0xcc(r6)	# attackReacitonMul
	stfs f4, 0xc8(r6)	# damageRatio
	stfs f4, 0xc4(r6)	# attackRatio
	b end
boss:
	lbz r12, 0x18(r26)	
	cmpwi r12, 0x2
	bne+ end 
	li r12, 1
	stb r12, 0x9c(r6)
end:
	addi r5, r5, 92	# Original operation
}

######################################################
Disable Hardcoded Special Mode Item Switch [Kapedani]
######################################################
op b 0x8C @ $806df358