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

###############################################################################################
Classic and All-Star Ending Choice Engine v1.1d [DukeItOut]
#
# v1.1: addresses quirk where Wario-Man would be misinterpreted as ZSS due to range limitations
#			This version is more robust about understanding if it is in Classic or All-Star
# v1.1b: fixed misinterpretation of the default value
# v1.1c: fixes compatibility with Boss Battles
# v1.1d: rewrote to remove ambiguity for Boss Battles to prevent issues
################################################################################################
# r29 = r30 if in Classic (r30 holds cosmetic ID of character)
# r29 = r30 + 50 in All-Star as a roundabout way to get to strings in the same table, equivalent to +0x960 within the table
CODE @ $806C1428
{
	andis. r0, r0, 0x8000
	bne- 0x10
}
op NOP @ $806C14A4 # Redundant code split that makes this code unstable if not NOP'd
CODE @ $806C148C
{
	andis. r0, r0, 0xC000
	beq+ 0x08
}
CODE @ $806C14DC	
{
	andis. r12, r0, 0x8000		# Determines if a video should play. r0 will be useful in a bit, so don't clear it!
	bne- 0x10					# Make this "b 0x10" to always skip playing a video at the end of Classic/All-Star!
}
CODE @ $806C151C
{
	andis. r0, r0, 0x8000
	bne- 0x1C
}
CODE @ $806C155C
{
	andis. r0, r0, 0x8000
	bne- 0x10
}
CODE @ $806C15A0
{
	andis. r0, r0, 0x8000
	bne- 0x10
}

op oris r5, r5, 0x4000 @ $806E36B8	# Instead of adding 50, use 4000 as an All-Star flag for how to load the imagery
op oris r5, r5, 0x8000 @ $806E4E54	# Instead of adding 100, use 8000 as a Boss Battles flag for how to load the imagery
op NOP @ $806C1460
CODE @ $806C146C
{
	lhz r3, 0x282(r3)	# Avoid custom All-Star flag
	NOP
	NOP
}	// Force an ID check for a character

HOOK @ $806C14B0
{
	andi. r3, r29, 0xFFFF
	andis. r12, r29, 0x8000
	beq+ notBoss
	addi r3, r3, 100		# Compensation for removing 100 before
notBoss:
	mulli r0, r3, 0x30
}
HOOK @ $806C14C0		
{
	andi. r6, r29, 0xFFFF  # Force to read normally
	andis. r7, r29, 0x8000
	bne- BossBattles

	lis r12, 0x806C        	# \
	lwz r12, 0x14C8(r12)	# | Access ending ID from the table that has a pointer at $806C14C8!
	lbzx r5, r12, r6       	# /
	cmplwi r5, 0xFF;bne+ notDefault	# Use -1 (0xFF) as a value when you don't have Classic or All-Star results ready for the character!
default:
	addi r4, r31, 8
	andis. r12, r29, 0x4000; beq Classic_a
AllStar_a:
	addi r4, r4, 0x960		# Go to All-Star section
Classic_a:
	b setString
notDefault:
	addi r3, r31, 0x57
	andis. r12, r29, 0x4000; beq Classic_b
AllStar_b:
	addi r3, r31, 0x9B4		# Go to All-Star section
Classic_b:

	lis r4, 0x8048;	 ori r4, r4, 0xD9F8		# "%02d"	
	lis r12, 0x803F; ori r12, r12, 0x89FC 	# \ sprintf
	mtctr r12								# |
	bctrl									# /
	li r3, 0x2E								# \ "."					 
	andis. r12, r29, 0x4000; beq Classic_c	# |
AllStar_c:									# |
	addi r4, r31, 0x998						# Go to All-Star section to replace the period
	stb r3, 0x1E(r4)						# |
	b setString								# |
Classic_c:									# |
	addi r4, r31, 0x38						# | Replace the period lost	
	stb r3, 0x21(r4)						# /	
	b setString 
BossBattles:
	add r4, r31, r0							# Original operation
	addi r4, r4, 8
setString:	
	lwz r3, 0x14A8(r31)	# restore r3
	li r5, 43
	li r6, 0		# This was originally cleared before this set of hooks was made
	li r7, 0
}
op b 0x8 @ $806C14C4
	.BA<-ENDINGTABLE
	.BA->$806C14C8
	.GOTO->ENDINGTABLESKIP
ENDINGTABLE:
	byte[128] |	
		 1,  2,  3,  4,  5,  6,  7,  8, |	# These are based on the cosmetic ID
		 9, 10, 11, 12, 13, 42, 42, 16, |	# Zelda and Sheik use 42
		17, 18, 19, 20, 38, 22, 23, 24, |	#
		25, 26, 27, 28, 28, 28, 28, 32, |	# Mewtwo is 31 instead of 28 so Pokemon Trainer monsters can access PT's.
		33, 34, 35, 37, 40, 41, -1, 44, |	# 40 used by Roy!
		46, 47, -1, -1, -1, 31, -1, 43, |   # 31 used by Mewtwo, 43 used by Knuckles!
    	12, -1, 39, 36, -1, 38, -1, -1, |	# 36 used by Waluigi! 39 used by Ridley!
		-1, -1, -1, -1, -1, -1, -1, -1, |
		45, -1, -1, -1, -1, -1, -1, -1, |	# 45 used by Dark Samus!
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, 30, -1, -1, -1, -1, 67, |	# 30 used by Sceptile! 67 used by Zero!
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1  |  

# Unused slots: 14, 15, 21, 29, 30*, 31*, 36*, 39*, 40*, 43*, 45*		*= Used by Project+ or P+Ex

ENDINGTABLESKIP:
	.RESET

#######################################################################
Clone Classic & All-Star Result Data V1.21 [ds22, Dantarion, DukeItOut]
#######################################################################
# Note: Cosmetic slots for clone/ex characters exceeding 
# 50/0x32 need to alter code at 806C148C if they are to have Classic Congrats screens
#
# Useful trophy IDs for general modders that stumble across this asm file:
#
# 0x145 = Mewtwo
# 0x113 = Isaac
# 0x10A = Lyn
# 0x116 = Shadow
# 0x0FF = Waluigi
# 0x1A8 = Toad
# 0x1E6 = Dark Samus
# 0x224 = Blood Falcon
# 0x225 = Black Shadow
# 0x22C = Roy (Ashnard in Brawl)
# 0x24E = Knuckles
#
# To find more, locate figdisp.pac and rummage through the texture data
# Convert the decimal value to hex to get the trophy ID
####################################################################################
## TODO: Have a table for this

.alias Roy_Slot = 0x32
.alias Mewtwo_Slot = 0x33
.alias Knuckles_Slot = 0x35
.alias Giga_Bowser_Slot = 0x2C
.alias Wario_Man_Slot = 0x2D
.alias Ridley_Slot = 0x38
.alias Waluigi_Slot = 0x39
.alias Dark_Samus_Slot = 0x40
.alias Charizard_Slot = 0x1D
.alias Squirtle_Slot = 0x1F
.alias Ivysaur_Slot = 0x20
.alias Sceptile_Slot = 0x62
.alias Mewtwo_Trophy = 0x145
.alias Roy_Trophy = 0x22C
.alias Knuckles_Trophy = 0x24E
.alias Giga_Bowser_Trophy = 0x17
.alias Giga_Bowser_Trophy_AllStar = 0x68
.alias Wario_Man_Trophy = 0x29
.alias Wario_Man_Trophy_AllStar = 0x6F
.alias Ridley_Trophy = 0x184
.alias Ridley_Trophy_AllStar = 0x186
.alias Waluigi_Trophy = 0xFF
.alias Dark_Samus_Trophy = 0x1E6
.alias Charizard_Trophy = 0x75
.alias Squirtle_Trophy = 0x75
.alias Ivysaur_Trophy = 0x75
.alias Sceptile_Trophy = 0x277

op b 0x34 @ $806E29DC	#Disables vBrawl Classic Mode trophy replacement behavior for the Poke Trio.

HOOK @ $800791F0		# Music-related?
{
  lwz r12, 0x170(r3)
  cmpwi r12, 0x0;  beq- loc_0x14
  mr r3, r12;  b %END%
loc_0x14:
  lwz r3, 0x194(r3)
}
HOOK @ $806E29D0		# Character trophy to load for Classic
{
  cmpwi r28, 0x2B;  ble+ GotTrophy
  li r29, Mewtwo_Trophy;  cmpwi r28, Mewtwo_Slot;  beq+ GotTrophy	# If it's Mewtwo's PM slot
  li r29, Roy_Trophy; 	  cmpwi r28, Roy_Slot;	   beq+ GotTrophy	# If it's Roy's PM slot
  li r29, Knuckles_Trophy;cmpwi r28, Knuckles_Slot;beq+ GotTrophy	# if it's Knuckles' P+ slot 
  li r29, Giga_Bowser_Trophy;cmpwi r28, Giga_Bowser_Slot;beq+ GotTrophy	# if it's Giga Bowser's slot 
  li r29, Wario_Man_Trophy;cmpwi r28, Wario_Man_Slot;beq+ GotTrophy	# if it's Wario-Man's slot 
  li r29, Ridley_Trophy;cmpwi r28, Ridley_Slot;beq+ GotTrophy	# if it's Ridley's P+Ex slot 
  li r29, Waluigi_Trophy;cmpwi r28, Waluigi_Slot;beq+ GotTrophy	# if it's Waluigi's P+Ex slot 
  li r29, Dark_Samus_Trophy;cmpwi r28, Dark_Samus_Slot;beq+ GotTrophy	# if it's Dark Samus' P+Ex slot 
  li r29, Sceptile_Trophy;cmpwi r28, Sceptile_Slot;beq+ GotTrophy	# if it's Sceptile's P+Ex slot 
  li r29, 0x1		# Default to Mario!!!
GotTrophy:
  rlwinm r3, r29, 0, 16, 31
}
HOOK @ $806E47D8	# Character trophy to load for All-Star 
{
  cmpwi r4, Squirtle_Slot; beq- SquirtleTrophy
  cmpwi r4, Ivysaur_Slot; beq- IvysaurTrophy
  cmpwi r4, Charizard_Slot; beq- CharizardTrophy
  cmpwi r4, 0x2B;  ble+ GotTrophy
  li r26, Mewtwo_Trophy;  cmpwi r4, Mewtwo_Slot;   beq+ GotTrophy	# If it's Mewtwo's PM slot
  li r26, Roy_Trophy; 	  cmpwi r4, Roy_Slot;	   beq+ GotTrophy	# If it's Roy's PM slot
  li r26, Knuckles_Trophy;cmpwi r4, Knuckles_Slot; beq+ GotTrophy	# if it's Knuckles' P+ slot 
  li r26, Giga_Bowser_Trophy_AllStar;cmpwi r4, Giga_Bowser_Slot; beq+ GotTrophy	# if it's Giga Bowser's slot 
  li r26, Wario_Man_Trophy_AllStar;cmpwi r4, Wario_Man_Slot; beq+ GotTrophy	# if it's Wario-Man's slot 
  li r26, Ridley_Trophy_AllStar;cmpwi r4, Ridley_Slot; beq+ GotTrophy	# if it's Ridley's P+Ex slot
  li r26, Waluigi_Trophy;cmpwi r4, Waluigi_Slot; beq+ GotTrophy	# if it's Waluigi's P+Ex slot  
  li r26, Dark_Samus_Trophy;cmpwi r4, Dark_Samus_Slot; beq+ GotTrophy	# if it's Dark Samus' P+Ex slot  
  li r26, Sceptile_Trophy;cmpwi r4, Sceptile_Slot; beq+ GotTrophy	# if it's Sceptile's P+Ex slot 
  li r26, 0x5D		# Default to Mario Finale!!!
  b GotTrophy
SquirtleTrophy:
  li r26, Squirtle_Trophy; b gotTrophy
IvysaurTrophy:
  li r26, Ivysaur_Trophy; b GotTrophy
CharizardTrophy:
  li r26, Charizard_Trophy
GotTrophy:
  rlwinm r3, r26, 0, 16, 31
}

#########################################################
BrawlEx Classic/All-Star Cosmetic ID Fix [KingJigglypuff]
#########################################################
op cmpwi r0, 0x80 @ $806C148C