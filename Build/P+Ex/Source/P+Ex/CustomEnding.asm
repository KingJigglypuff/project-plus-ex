###################################
CheckModFileSD function [DukeItOut]
###################################
# allows you to bctrl to 8001F0D0 to check if a file exists on the SD card without first applying 
# the prefixes needed
# 
# Prerequisite: r3 = string of file to search for
#################################################
HOOK @ $8001F0CC
{
	addi r1, r1, 0x30	# Original operation
	blr					# Following operation, replaced by following hook for accessing ease
}
HOOK @ $8001F0D0
{
	stwu r1, -0xD0(r1)
	mflr r0
	stw r0, 0xD4(r1)
	stw r3, 0x8(r1)			# string name
	
	lis r12, 0x7066			# \ "pf"
	stw r12, 0x1C(r1)		# /
	lis r12, 0x7364			# \"sd:"
	ori r12, r12, 0x3A00	# |
	stw r12, 0x20(r1)		# /
	lis r4, 0x8040			# \ Mod name on SD
	ori r4, r4, 0x6920		# /
	addi r3, r1, 0x20		# full string
	
	lis r12, 0x803F			# \
	ori r12, r12, 0xA384	# | concatenate string
	mtctr r12				# |
	bctrl					# /
	
	addi r3, r1, 0x20		# \ concatenate pf
	addi r4, r1, 0x1C		# |
	bctrl					# /
	
	addi r3, r1, 0x20		# \ concatenate filename to look for
	lwz r4, 0x8(r1)			# |
	bctrl					# /
	
	addi r4, r1, 0x20
	addi r3, r1, 0x1C		# pointer to full string
	stw r4, 0(r3)			# write address to pointer 
	lis r12, 0x8001
	ori r12, r12, 0xF0D4
	mtctr r12
	bctrl				# Check for the file. r3 is zero if found
	
	lwz r0, 0xD4(r1)
	mtlr r0
	addi r1, r1, 0xD0
	blr
}

##########################################################
Custom Ending Videos in Classic/All-Star [DukeItOut]
##########################################################
# Attempts to find a THP video for the ending of Classic and All-Star on the SD card.
# 
# If not found, it will instead play Brawl's ending videos if a Brawl character or
# skip playing a video if an added mod character
#
# THIS CODE REQUIRES THE "CheckModFileSD function" CODE!!!
##########################################################
HOOK @ $806C14E8
{
	lis r12, 0x806C			# \
	lis r5, 0x807F			# | write lwz r3, 0x14AC(r31) to restore this operation in case it was written to, see below
	ori r5, r5, 0x14AC		# |
	stw r5, 0x1524(r12)		# / 

	lis r5, 0x817D			# \ Internal BrawlEX cosmetic slot info (817D5AC0)
	ori r5, r5, 0x5AC2		# / the third byte (0x02) within the 16-byte wide block is the primary character slot
    andi. r4, r0, 0xFFFF    # Filter to get character ID
    mulli r4, r4, 0x10      # Offsets are 0x10 apart
	lbzx r4, r5, r4			# Fighter to get primary character slot ID
    lis r5, 0x817C          # \ Internal BrawlEX fighter slot info 
    ori r5, r5, 0x8680      # /		
    mulli r4, r4, 0x10      # Offsets are 0x10 apart
	lwzx r4, r5, r4			# Fighter slot ID
    lis r5, 0x817C          # \ Internal BrawlEX internal fighter names
    ori r5, r5, 0xD820      # /	
    mulli r4, r4, 0x10      # Offsets are 0x10 apart
    add r4, r5, r4          # r4 now contains a pointer to the character filename when using P+EX
	
	addi r3, r3, 0x87		# \ (0x4C + 0x30 + 0xB to replace "Mario.thp")
	lis r12, 0x803F			# | copy the character name
	ori r12, r12, 0xA280	# |
	mtctr r12				# |
	bctrl					# / 
	
	lwz r3, 0x14AC(r31)
	addi r4, r3, 0xBC		# ".thp" from the Donkey Kong congrats video 
	addi r3, r3, 0x7C		# Pointer to the filename usually used for Mario's ending
	lis r12, 0x803F			# \
	ori r12, r12, 0xA384	# | concatenate ".thp"
	mtctr r12				# |
	bctrl					# /	
	
	lwz r3, 0x14AC(r31)
	addi r3, r3, 0x7C		# Pointer to the filename usually used for Mario's ending, which has at this point been edited
	
	lis r12, 0x8001			# \
	ori r12, r12, 0xF0D0	# | Check if the THP video exists on the SD card
	mtctr r12				# |
	bctrl					# /

	cmpwi r3, 0; bne+ SDTHP_NotFound	# if non-zero, it gives an error code

	lwz r3, 0x14AC(r31)			# \
	addi r4, r3, 0x7C			# |
	lwz r3, 0x09AC(r3)			# | Prepare to play this video
	li r5, 0					# |
	li r6, 0					# |
	li r7, 0					# |
	lis r12, 0x8007				# |
	ori r12, r12, 0xEC08		# |
	mtctr r12					# |
	bctrl						# |
	b endVideoPreparation		# /

SDTHP_NotFound:
	mr r4, r30 			# Original operation, gets index again for the video

	
	cmpwi r4, 0x2D; beq- forceBowser   # Giga Bowser plays Bowser's video instead of skipping
    cmpwi r4, 0x43; beq- forceWario    # Wario-Man plays Wario's video instead of skipping	

	cmpwi r4, 0x15; beq- extraCharFail
	cmpwi r4, 0x24; beq- extraCharFail 
	cmpwi r4, 0x28; beq- extraCharFail # check for Roy
	cmpwi r4, 0x28; beq- extraCharFail
	cmpwi r4, 0x2A; beq- extraCharFail
	cmpwi r4, 0x2B; beq- extraCharFail # Knuckles in P+
	cmpwi r4, 0x30; blt+ BrawlVideoBehavior # All expansion characters will otherwise have to skip
							# If it exists within the game, play Brawl's video. Otherwise, bail and do not load an Ending video at all
extraCharFail:
	lis r12, 0x806C			# \
	lis r3, 0x4800			# | write b 0x18 to force a video skip
	ori r3, r3, 0x0018		# |
	stw r3, 0x1524(r12)		# / 
endVideoPreparation:
	lis r12, 0x806C			# \ Don't play a video if it is not found! (also goes here if a video is already prepared)
	ori r12, r12, 0x14F0	# | If it tried to, it would crash!
	mtctr r12				# |
	bctr					# /
forceBowser:
	li r4, 0xC				# Bowser's video ID
	b BrawlVideoBehavior
forceWario:
	li r4, 0x26				# Wario's video ID	
BrawlVideoBehavior:		
	lwz r3, 0x14AC(r31) # restore r3
}

#######################################################
Independent Pokemon Custom Video/Ending Fix [DukeItOut]
#######################################################
# Squirtle, Ivysaur and Charizard load their own ending 
#   scenes instead of Pokemon Trainer's, which is 
#   currently occupied by Mewtwo
#######################################################
op b 0x14 @ $806E09CC
op b 0x14 @ $806E369C

###################################################################
BrawlEx Classic/All-Star Configurable Ending Skip [Desi, DukeItOut]
###################################################################
#Add an exception if your character has an ending.
op cmpwi r3, 0x80 @ $806E08D0 #If higher than or equal to 128, it will be skipped.
CODE @ $806E3474
{
    lbz r3, 0x24(r19)    # Overwrite EX Rel value here because it incorrectly used lwz!
    cmpwi r3, 0x80        #If higher than or equal to 128, it will be skipped.
    nop # removes unnecessary check from the EX Rel
}