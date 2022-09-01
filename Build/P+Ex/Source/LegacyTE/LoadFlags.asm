##########################################################
[Legacy TE] New Load Flag Commands For Etc 1.2 [DukeItOut]
##########################################################
string[4] |
"/fighter/%s%s%s%s",   |
"/fighter/%s%s%02d%s", |
"AltR",                |
"AltZ"                 |
@ $80546FB0

op NOP @ $8084D2A4
HOOK @ $8084D104
{
	rlwinm r0, r0, 0, 26, 27
	cmpwi r0, 0x10
}
op bne- 0xC @ $8084D108
HOOK @ $8084D23C
{
	rlwinm r0, r0, 0, 26, 27
	mr r12, r0
	cmpwi r0, 0x10
}
op bne- 0xC @ $8084D240
HOOK @ $8084D314
{
	rlwinm r0, r0, 0, 26, 27
	cmpwi r0, 0x10
}
op beq- 0xC @ $8084D318
HOOK @ $8082EF88
{
	rlwinm r0, r0, 0, 26, 27
	cmpwi r0, 0x10
}
op bne- 0x28 @ $8082EF8C
HOOK @ $8084D29C
{
	lis r6, 0x80B0;  ori r6, r6, 0xA67C
	mr r3, r12
	cmpwi r3, 0x20;  blt+ NormalBehavior	# bit 4 determines if Etc files will use costume-based behavior!
	mr r8, r7							# Move ".pac" into register 8
	andi. r12, r27, 0x7F				# Get the costume ID (filters out bit related to Clear Smash)
	lis r4, 0x8054
	cmplwi r12, 62;  beq- SetAltZ	# 
	cmplwi r12, 61;  beq- SetAltR
	mr r7, r12
	cmplwi r3, 0x20;  beq+ perCostume
# This filters sets to the nearest 10 if bit 5 is set in the load flag
# AltR and AltZ are still given their own, but Dark and Fake are not
perCostumeSet:
moduloFunction:
	cmpwi r7, 10;  blt- modulo_10
	subi r7, r7, 10
	b moduloFunction
modulo_10:
	sub r7, r12, r7
	cmpwi r7, 10; bne notFirstSet
	subi r7, r7, 10			# First twenty costumes use the same Etc file if a set!
notFirstSet:
perCostume:
	lis r12, 0x805B			# \
	lwz r12, 0x50AC(r12)	# | Retrieve the game mode name
	lwz r12, 0x10(r12)		# |
	lwz r12, 0x0(r12)		# /
    lis r3, 0x8070;	ori r3, r3, 0x2B60	
	cmpw r3, r12;	bne numberedEtcName		# Adventure mode has dark and fake costumes!
	cmpwi r7, 12; beq SetDark				#
	cmpwi r7, 13; beq SetFake				# Note that these two don't trigger if using sets. That's by design.
numberedEtcName:
	ori r4, r4, 0x6FC2;  	b %END%			# "/fighter/%s%s%02d%s"
NormalBehavior:								# \ Get the expected string, don't do the rest of this
	addi r4, r29, 0xAC0;  	b %END%			# /
SetDark:
	addi r7, r17, 0x10;		b stringEtcName	# "Dark"
SetFake:
	addi r7, r17, 0x18;		b stringEtcName	# "Fake"
SetAltZ:
	ori r7, r4, 0x6FDB;  	b stringEtcName	# "AltZ"
SetAltR:
	ori r7, r4, 0x6FD6 					# "AltR"			
stringEtcName:
	ori r4, r4, 0x6FB0	# "/fighter/%s%s%s%s"
}