###################################
Expansion GCT Available [DukeItOut]
###################################
	.BA<-FILENAME
	.BA->$80550000
	.RESET
	.GOTO->ROUTINE
FILENAME:
		string "BOOST.GCT"

ROUTINE:

HOOK @ $8002D500
{
	stwu r1, -0xF0(r1)
	stw r3, 0x8(r1)
	stw r4, 0xC(r1)
	stw r5, 0x10(r1)
	addi r3, r1, 0x60
	lis r4, 0x8048				# \ %s%s
	ori r4, r4, 0xEFF8			# /
	lis r5, 0x8040				# \ Mod name folder
	ori r5, r5, 0x6921			# /
	lis r6, 0x8055				# \ Pointer to "BOOST.GCT"
	lwz r6, 0(r6)				# /
	lis r12, 0x803F				# \
	ori r12, r12, 0x89FC		# | Compile name
	mtctr r12					# |
	bctrl 						# /

	addi r3, r1, 0x30			# Where the info block will reside
	addi r4, r1, 0x60			# Filename
	lis r5, 0x8055				# \
	ori r5, r5, 0x10			# / Location to upload
	li r6, 0x0
	li r7, 0x0
	lis r12, 0x8002				# \
	ori r12, r12, 0x239C		# | Set up the read parameter block
	mtctr r12					# |
	bctrl 						# /
	addi r3, r1, 0x30
	lis r12, 0x8001				# \
	ori r12, r12, 0xCBF4		# | and read the file to the desired location in memory if on the SD
	mtctr r12					# |
	bctrl 						# /
	cmpwi r3, 0
	beq+ FoundFile
checkDisc:
	addi r3, r1, 0x30
	lis r4, 0x8055
	ori r5, r4, 0x10
	lwz r4, 0(r4)
	li r6, 0x0
	li r7, 0x0
	lis r12, 0x8002				# \
	ori r12, r12, 0x239C		# | Set up the read parameter block
	mtctr r12					# |
	bctrl 						# /
	addi r3, r1, 0x30
	lis r12, 0x8001				# \
	ori r12, r12, 0xC114		# | and read the file to the desired location in memory if on the DVD
	mtctr r12					# |
	bctrl 						# /
FoundFile:
	li r3, 1
	lis r4, 0x8055
	stw r3, 0xC(r4)
	lwz r3, 0x8(r1)
	lwz r4, 0xC(r1)
	lwz r5, 0x10(r1)
	lwz r1, 0(r1)
	addi r11, r1, 0x20			# Original operation
}

* 20550010 00D0C0DE
* 2055000C 00000001
PULSE
{
	lis r15, 0x8055
	li r4, 0x18		# 8 for header + 0x10 for info
	blr
}
.RESET