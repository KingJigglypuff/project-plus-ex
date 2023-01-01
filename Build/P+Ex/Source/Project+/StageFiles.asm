#################################
Stage File System Neo [DukeItOut]

# Location of Safety Check Changed
#################################
	.BA<-FileFormatSetup
	.BA->$8053EFE0
	.BA<-FileNameFolder
	.BA->$8053EFE4
	.BA<-FileNameLocation
	.BA->$8053EFE8
	.BA<-FileNameLocation2
	.BA->$8053EFEC	
	.BA<-FileNameLocation3
	.BA->$8053CFF8	
	.BA<-FileNameLocation4
	.BA->$8053EFB4
	.BA<-FileNameFormat
	.BA->$8053EFF0
	.BA<-FileNameFormat2
	.BA->$8053EFF4
	.BA<-FileNameFormat3
	.BA->$8053CFFC	
	.BA<-FileNameFormat4
	.BA->$8053EFB0
	.RESET
	.GOTO->FileLoadCode
FileFormatSetup:
	string "%s%s%02X%s"
FileNameFolder:
	string "/stage/"
FileNameLocation:
	string "stageslot/"
FileNameLocation2:
	string "stageinfo/"	
FileNameLocation3:
	string "/sound/tracklist/"
FileNameLocation4:
	string "pf/sound/"
FileNameFormat:
 	string ".asl"
FileNameFormat2:
	string ".param"
FileNameFormat3:
 	string "%s%s.tlst"
FileNameFormat4:
	string "_b.brstm"
# sd: 		 		@ $8059C568
# mod folder name	@ $80406920
# sound/tracklist_	<-$8053CFF8
# %02X.cmm	
FileLoadCode:
HOOK @ $8094A0F8	# Stage Loading, special case for replays needed
{
	lis r12, 0x805B			# \
	lwz r12, 0x50AC(r12)	# | Retrieve the game mode name
	lwz r12, 0x10(r12)		# |
	lwz r4,  0x14(r12)		# | And also the scene stage mode
	lwz r12, 0x0(r12)		# /
	lis r3, 0x8070;	
	ori r0, r3, 0x2B60;	cmpw r0, r12;	beq skip		# Skip if this is "sqAdventure"
	ori r0, r3, 0x29E8; cmpw r0, r12;	beq skip		# Skip if this is "sqSingleBoss"
	ori r0, r3, 0x24D0; cmpw r0, r12;   bne notClassic	# This special check only applies to Classic Mode's Master Hand fight
Classic:
	cmpwi r4, 13; beq skip		# If the Master Hand fight (Stage 13), then skip this!
notClassic:	# Classic Mode stages other than the one above are treated more normally
	lwz r3, 0x40(r31)	# \ Obtain the stage ID
	lhz r3, 0x1A(r3)	# /
	lis r12, 0x8053
	ori r12, r12, 0xE000
	mtctr r12
	bctrl
skip:	
	lwz r12, 0x3C(r31)	# Original operation
}
HOOK @ $8010F994	# Stage Loading, earliest handled by stages, normally
{
	mr r30, r6				# Original operation
	lis r12, 0x8053
	ori r12, r12, 0xE000
	mtctr r12
	bctrl
skip:
	mr r5, r29				# Restore register 5
	mr r3, r27				# Restore register 3
	cmpwi r30, 0			# Do a test that was overruled, before	
}
HOOK @ $8117DF4C	# My Music
{
	mr r3, r7		# Stage ID
	lis r12, 0x8053			# \ 10-byte row dedicated to individual menu shenanigans
	ori r4, r12, 0xEF70		# /
	lis r7, 0x800B			# \
	ori r7, r7, 0x9EA0		# | Grab the input and store it. We'll use this to prevent the menu shortcuts from failing
	lhz r7, 2(r7)			# |
	andi. r7, r7, 0x60		# | by filtering for just the shoulder inputs and 	
	stw r7, 0(r4)			# /
	ori r12, r12, 0xE000	#
	ori r7, r12, 0x24		# Bypass the safety check.
	mtctr r7
	bctrl
	mr r3, r30		# Restore register 3
}
	
###
# Load Soundbank from Stage File
HOOK @ $8094BF6C
{
    lis r12, 0x805B
    lwz r12, 0x50AC(r12)
	lwz r12, 0x10(r12)
	lwz r12, 0x00(r12)
	lis r0, 0x8070;	ori r0, r0, 0x2B60; cmpw r0, r12; # "sqAdventure"
	bne %END%	# Subspace needs to ignore this for special reasons
	mr r3, r31	# Restore register 3	
	lwz r12, 0x3C(r31)		# \
	lwz r12, 0x74(r12)		# |
	mtctr r12				# | Behave like normal within subspace
	bctrl					# /
}
HOOK @ $8094BEEC
{
	lis r12, 0x8054			# \ Stage file
	lhz r3, -0xFF0(r12)		# / Soundbank ID to load @ $8054F010
	cmplwi r3, 0xFFFF
	bnelr
	li r3, -1
}
HOOK @ $8094BF64
{
	lis r12, 0x8054			# \ Stage file
	lhz r3, -0xFF0(r12)		# / Soundbank ID to load @ $8054F010
	cmplwi r3, 0xFFFF
	bne+ %END%
	li r3, -1
}
op NOP @ $8094BED8			# \ Suppress sound check that'd normally disable soundbanks for expansion stages
op NOP @ $8094BEDC			# / This isn't read by the SSE, so it is safe 
###
# Load Effectbank from Stage File
op b 0x8 @ $80949BF0
HOOK @ $80949BEC
{
	lis r12, 0x8054			# \ Stage file
	lhz r4, -0xFEE(r12)		# / Effectbank ID to load @ $8054F012
	stw r4, 0x94(r3)   	 	# store stage effectbank ID, not read by SSE
}
###
# Load RGBA Overlay
# Suggested values for overlays:
# 000000FF (0, 0, 0, 255)     for full black
# 3C6C24B4 (60, 108, 36, 180) for Game Boy green
# This affects characters, but not stages articles or effects
HOOK @ $807C9768
{
	lis r12, 0x8054			# \ Stage file RGBA settings @ $8053F00C
	lwz r12, -0xFF4(r12)	# / (normally uninitialized in Brawl)
	stw r12, 0x14A(r26)		# /
	andi. r12, r12, 0xFF	# Check alpha settings
	mr  r12, r30
	beq- clear				# If the alpha was clear, then behave normally and do not provide an overlay
	lis r4, 0x805B			# \
	lwz r4, 0x50AC(r4)		# | Get pointer to mode name
	lwz r4, 0x10(r4)		# |
	lwz r4, 0x4(r4)			# /
	lis r27, 0x8070			# \ is the mode "sqAdventure"?
	ori r27, r27, 0x2E50	# |
	cmpw r4, r27			# | Don't enable the overlay if it is.
	beq clear				# /
	li r12, 1				# Enable overlay
clear:
	stb r12, 0x14F(r26)		# Set the overlay toggle (boolean, normally 0)
}	
###
# Load Secondary Stage Name on Slots 0x13 and 0x19
op NOP @ $8094AB24			# Make all dual pac stages run the same code
HOOK @ $8094AB2C
{
	lis r4, 0x80B2			# \ Load "/STAGE/MELEE/STG"
	ori r4, r4, 0xC320		# /
}
HOOK @ $8094AB44
{
	lis r4, 0x8053			# \ Offset of stagenames
	ori r12, r4, 0xF02C		# |
	ori r5, r4, 0xF000		# /
	lwzx r4, r12, r0		# r0 is the substage ID, multiplied by 4. Load stage name
	lwz r12, 0x4(r5)
	add r4, r4, r12
	add r4, r4, r5
}	
###
# Code at 806BE22C determines if the stage dual loads
# TODO: Can't create yet because of stage ID conflict with SSE. Will wait until after release to attempt to make possible
# 			if it does get attended to.
###
# Flatten the stage if requested to do so
CODE @ $806CF6F4
{
	lis r12, 0x8054			# \
	lhz r12, -0xFEC(r12)	# |		
	andi. r0, r12, 0x1		# | Check if the stage should flatten
	beq- 0x14				# /
}
###
# Load a fixed camera if the STEX file indicates to
CODE @ $806D3A5C
{
	lis r12, 0x8054			# \
	lhz r12, -0xFEC(r12)	# | Check for fixed camera status
	andi. r0, r12, 0x2		# /
	beq- 0x8
}
CODE @ $806CF5E0
{
	lis r12, 0x8054			# \
	lhz r12, -0xFEC(r12)	# | Check for fixed camera status
	andi. r0, r12, 0x2		# /
	beq- 0x8
}
HOOK @ $80105400
{
	lis r12, 0x8054			# \
	lhz r12, -0xFEC(r12)	# | Check for fixed camera status
	andi. r4, r12, 0x2		# /
	li r4, 2				# Normal camera type, original operation
	beq+ %END% 
	li r4, 12				# Set it to the twelth type of camera reset for fixed camera stages when in training mode.
}
###
# Only triggers the slowdown seen on Mushroomy Kingdom, Rumble Falls and Lylat Cruise within Brawl if the STEX files suggest the stage should, 
# rather than relying on stage ID
CODE @ $8094EBF4
{
	lis r12, 0x8053
	ori r12, r12, 0xF000
	lhz r3, 0x14(r12)
	andi. r3, r3, 0x4		# Check if the flag for a slow start is present in the param file, if it is, apply the slow start.
	beq+ 0x10
}
CODE @ $80951408
{
	lis r12, 0x8053
	ori r12, r12, 0xF000
	lhz r3, 0x14(r12)
	andi. r3, r3, 0x4		# Check if the flag for a slow start is present in the TLST, if it is, remove the slow start.
	beq+ 0x3C
}
###
# Brute forces stages to load a filename, even if unexpected

CODE @ $80015568
{
	NOP; NOP; NOP
}

#############################################################
Stage Roster Expansion System v3.1 [Phantom Wings, DukeItOut]
#############################################################
# Force Regular Stages To Use Maximum Plausible Allocation, including Expansion Slots 

HOOK @ $8094A1D0
{
	mr r29, r3				# Original operation, places allocation size in r29
	lis r3, 0x805B			# \
	lwz r3, 0x50AC(r3)		# | Get pointer to mode name
	lwz r3, 0x10(r3)		# |
	lwz r3, 0x4(r3)			# /
	lis r12, 0x8070			# \ is the mode "sqAdventure"?
	ori r12, r12, 0x2E50	# |
	cmpw r3, r12			# |	Then use the allocation it expects, don't take chances.
	beq- %END%				# / 
	lis r12, 0x8053			# \
	ori r12, r12, 0xF000	# | Get reserved memory allocation from STEX system
	lwz r3, 0x24(r12)		# /
	cmpwi r3, 0				# \ If a value is hardcoded, use it!
	bne- forceMemory		# /
	cmpwi r29, -1			# \ To get more reliable memory results, the below only activates for new stage slots.
	bne- %END%				# /
	lis r3, 0x37			# The size of a stage should be expanded to if not already at (370000)
forceMemory:
	mr r29, r3				# Give it this new memory allocation size.
}

# Force stage modules to load their filenames from the STEX files. WARNING! Module names can be no longer than 32 characters!!!
HOOK @ $80043B28
{
	li r5, 0						# Original operation
	cmpwi r3, 0x26; beq- %END%		# Make an exception for the config menu
	cmpwi r3, 0x28; beq- %END%		# Make an exception for the results screen since it doesn't even use a module
	cmpwi r3, 0x36; beq- %END%		# Make an exception for the All-Star rest area since it doesn't properly deallocate if it tries to use STEX files
	cmpwi r3, 0x39; beq- %END%		# Make an exception for credits
	lis r3, 0x8053		# \ Set the pointer to the string name to be within the STEX param file
	ori r12, r3, 0xF000 # |
	lwz r3, 0x20(r12)	# | Access offset of the string
	lwz r5, 0x04(r12)	# | Access offset of the string table
	add r3, r3, r5		# |
	add r3, r3, r12		# /
	blr					# Return, pointer achieved
}
# Force stage pacs to load 
HOOK @ $80949C20
{
	lhz r0, 0x1A(r3)						# Original operation, places stage ID in r0
	cmpwi r0, 0x28; beq- SpecialCase		# Results screen uses a special case
	cmpwi r0, 0x39; beq- %END%				# Make an exception for credits
ModifyStageName:	
	stwu r1, -0x20(r1)
	lis r12, 0x8053				# \ Set the pointer to the STEX param file
	ori r12, r12, 0xF000		# | and obtain the stage name
	stw r12, 0x8(r1)			# |
	lwz r4, 0x1C(r12)			# |
	lwz r5, 0x04(r12)			# |
	add r4, r4, r5				# |
	add r4, r4, r12				# /
	addi r3, r30, 0x48			# \
	lis r12, 0x803F				# |
	ori r12, r12, 0xA384		# |
	stw r12, 0xC(r1)			# |
	mtctr r12					# |
	bctrl 						#/ Concatenate the string
	lwz r12, 0x8(r1)			# \
	lhz r6, 0x14(r12)			# | Get special bits related to stage loading
	lbz r4, 0x16(r12)			# | Get the stage operation type
	lbz r5, 0x17(r12)			# / Get the substage ID information
	andi. r12, r6, 0x20			# \ If it is set to retain the substage ID that was set by the game
	bne- keep_Substage_Val		# /		then bypass this	(Used for Smashville, Break the Targets, Stage Editor stages)
	andi. r12, r6, 0x08			# \ If it is a dual pac-loading stage, also bypass appending a title
	bne- NoSubtitle				# /
	cmpwi r4, 0xFF				# \
	beq NoSubtitle				# / Assume no stage suffix was requested
	lis r5, 0x5F00				# \ Concatenate "_"
	stw r5, 0x10(r1)			# |
	lwz r12, 0xC(r1)			# |
	addi r4, r1, 0x10			# |
	addi r3, r30, 0x48			# |
	mtctr r12					# |
	bctrl						# /
	lwz r12, 0x8(r1)			# \
	lbz r4, 0x16(r12)			# |
	lbz r5, 0x17(r12)			# | Mode 00 = no random behavior
	cmpwi r4, 0					# |
	beq static					# /
	lbz r4, -0x7E(r12)			# \ Check if the stage was already loaded.
	cmplwi r4, 0xFF
	bne maintain_substage
random:							# 01 setting
	cmpwi r5, 0					# \
	beq static					# | Avoid imploding from an invalid range value
	mr r3, r5					# The range to randomize with. (0-to-[val-1])
	lis r12, 0x8003				# |
	ori r12, r12, 0xFC7C		# | Randi seeding to get a substage value
	mtctr r12					# |
	bctrl						# |
	mr r5, r3					# /
	b static
keep_Substage_Val:
	cmpwi r4, 0xFF				# \
	lwz r6, 0x40(r30)			# |\ Get substage ID
	lbz r4, 0x1C(r6)			# |/
	beq NoSubtitle_Force		# / Assume no stage suffix was requested if it is set to this
maintain_substage:
	mr r5, r4
static:							# 00 setting
	lwz r6, 0x40(r30)			# Get the stage data pointer
	stb r5, 0x1C(r6)			# Brute force the substage ID
	mulli r3, r5, 4				# \
	
	lwz r12, 0x8(r1)			# | Get the offset to the offset of the suffix
	stb r5, -0x7E(r12)			# | Make sure to limit the RNG factor to only one iteration.
	add r4, r12, r3				# |
	lwz r4, 0x2C(r4)			# | Access the offset within the string block of the appropriate suffix
	lwz r5, 0x4(r12)			# | Access string block offset
	add r4, r4, r12				# |
	add r4, r4, r5				# /
	addi r3, r30, 0x48			# \
	lwz r12, 0xC(r1)			# | Concatenate this suffix
	mtctr r12					# |
	bctrl						# /
	b FinishNameCreation
NoSubtitle_Force:
	mr r5, r4
NoSubtitle:
	lwz r6, 0x40(r30)			# Get the stage data pointer
	stb r5, 0x1C(r6)			# Brute force the substage ID
FinishNameCreation:	
	addi r1, r1, 0x20			# \
	lis r12, 0x8094				# | Prepare to append the .PAC file extension to the end.
	ori r12, r12, 0x9F14		# |
	mtctr r12					# |
	bctr						# /	
#
SpecialCase:
	mr r3, r0
	lis r12, 0x8053
	ori r12, r12, 0xE000
	mtctr r12
	bctrl
	b ModifyStageName	
}

# TODO: Force secondary stage pacs to load

# TODO: Address stage-specific memory allocation:
#

#80949F38 special cases for:
#39/0x27	?????
#19/0x13	Lylat Cruise			lis r3, 0x36; addi r3, r3, 0x6640
#25/0x19 Castle Siege			lis r3, 0x4B, addi r3, r3, 0x3300
#53/0x35 Stage Editor Stage		lis r3, 0x10
#61/0x3D ????? something in SSE		really special scenario with special coding?
#31/0x1F Mario Bros			lis r3, 0x10
#default: r3 = 0x2000

# Below is a temp fix until I make the above modular
op cmplwi r0, 5 @ $80949FC0	# Normally 0x1F (Famicom), allows Mario Bros to load properly from Metal Cavern

# Miscellaneous stage ID 
.alias WarioWare = 0x4D

op cmplwi r0, WarioWare @ $80989324 # Make sure that taunting is seen by WarioWare
op cmplwi r0, WarioWare @ $80988A70	# Make sure movement is seen by WarioWare

##########################################################################
[Legacy TE] Stage Modules Are Portable Without Modification V2 [DukeItOut]
##########################################################################
address $80B8A554 @ $80B8A4D0
address $80B8A564 @ $80B8A504
HOOK @ $80930314
{
	li r0, 0
    cmplwi r4, 0x36; bne- %END%		# Is it the All-Star rest area? If not, don't mess with this
	rlwinm r0, r4, 2, 0, 29
}
HOOK @ $80930300
{
  li r0, 0x0						# r3 = stage ID
  cmplwi r3, 0x28; beq- unusual		# Is it the Result Screen?
  cmplwi r3, 0x36; beq- unusual		# Is it the All-Star rest area?
  cmplwi r3, 0x35; bne+ %END% 		# Is it a Stage Builder Stage?
unusual:				//Those two stage types demand hardcoded pointers
  rlwinm r0, r3, 2, 0, 29
}	
	
########################################################
Custom Stage SD File Loader [DukeItOut, Replay Fix by Kapedani]
# 
# This version forces stage reloading if a flag is set, as well as uses the flag to determine if it's a replay
#
# Requires CMM SD File Saver
#
# Prerequisite: Stage ID in r3 (retrieves input, itself)
########################################################
CODE @ $8053E000
{
	lhz r0, 0xFB8(r12)
	lis r10, 0x8054
    lbz r10, -0xFFD(r10)
	cmpwi r10, 0x52			# If start of replays stage flag is on (STER) (flag turns off when stage gets loaded)
	beq Reload
	cmpwi r10, 0x21         # If end of match and endless friendlies stage load stage flag is on (STE!) (flag turns off when stage gets loaded)
	beq Reload
	cmpw r3, r0
	beqlr+					# Don't reload multiple times!
Reload:
	sth r3, 0xFB8(r12)
	stwu r1, -0x130(r1)
	mflr r0
	stw r0, 0x134(r1)
	addi r11, r1, 0x50
	lis r12, 0x803F 		# \
	ori r12, r12, 0x12EC	# |
	mtctr r12				# | preserve registers r14-r31
	bctrl					# /
	mr r17, r10
	lis r12, 0x8053
	ori r12, r12, 0xF000
	lis r28, 0x800B 
	ori r28, r28, 0x9EA0
	sth r3, 0(r28)			# Store stage ID for future reference
	mr r7, r3				# Stage ID
	li r0, 0xFF				# Clear random reroll flag for substages
	stb r0, -0x7E(r12)		#
	sth r7, -0x80(r12)		# Store stage ID
	addi r3, r1, 0x90
	lwz r4, -0x20(r12)		# "%s%s%02X%s"
	lwz r5, -0x1C(r12)		# "/stage/"
	lwz	r6, -0x18(r12)		# "stageslot/" 
	lwz	r8, -0x10(r12)		# ".asl"
	lis r12, 0x803F			# \
	ori r12, r12, 0x89FC	# | Create the filename string
	mtctr r12				# |
	bctrl					# /	
	lis  r5, 0x8053			# Stage files to 8053F000
	ori  r5, r5, 0xF000		#
	addi r3, r1, 0x60
	addi r4, r1, 0x90
	li r6, 0x0
	li r7, 0x0
	lis r12, 0x8002			# \
	ori r12, r12, 0x239C	# | set the read parameter
	mtctr r12				# |
	bctrl 					# /
	addi r3, r1, 0x60
	li r18, 0
	li r19, 0
	lis r12, 0x8001			# \
	ori r12, r12, 0xBF0C	# | load the file
	mtctr r12				# | 
	bctrl 					# /

	lhz		r16, 2(r28)			# / Get the input assigned
	lhz 	r3, 0(r28)			# Get access to the stage ID
    cmpwi 	r17, 0x52		  #\ Replays require different info
    bne+    Multiplayer       #/
Replay:
    lis     r16, 0x9130       #\  Ignore real inputs and only receive them from the replay info.
    lhz     r16, 0x1F4A(r16)  # | Replays insert them into 91301F4A
    sth     r16, 2(r28)       #/
Multiplayer:    
	lis r22, 0x8053
	ori r22, r22, 0xF000
	lhz r23, 4(r22)			# \ Get the slot count
	mtctr r23 				# /
	addi r23, r22, 8		# Get to the list of inputs and title offsets
	li r26, 0				# Choice-checking
	li r29, 0				# Most accurate choice, defaulting to the start
	li r21, 0				# How many inputs it shares
	mr r27, r16				# The input to check against
loop:	
	lhzx r25, r23, r26
	and. r25, r27, r25
	beq- not_found
found:
	mfctr r0				# Preserve the stage loop
	li r30, 16
	mtctr r30
	li r30, 1
	li r7, 0
checkPass:
	and. r24, r25, r30
	slwi r30, r30, 1
	beq bitSet
	addi r7, r7, 1
bitSet:
	bdnz checkPass
	mtctr r0				# Return the stage loop
	cmpw r7, r21			# \ If it doesn't match more than the previous best, skip
	ble+ not_found			# /
	mr r21, r7				# The amount of inputs shared by the new highest
	mr r29, r26				# Most accurate input offset 
not_found:	
	addi r26, r26, 4
	bdnz+ loop
slotFound:
    cmpwi r3, 0x28          # Do not save results
    beq DoNotSaveASL
    addi r23, r22, 8		# \ Get to the list of inputs and title offsets
    lhzx r25, r23, r29      # /
    sth r25, 2(r28)         # Store in alt stage helper ASL loc
    lis r11, 0x815F         # \ Store in ALT_STAGE_VAL_LOC
    sth r25, -0x7BDE(r11)   # /
    lis r11, 0x9135         # \ Store in CURRENT_ALT_STAGE_INFO_LOC
    stw r25, -0x3700(r11)   # /
DoNotSaveASL:
	addi r29, r29, 0xA		# \ pass the 8-byte header and add 2 to get the offset instead of input
	lhzx r29, r22, r29		# /
	lhz r23, 6(r22)			# \ Get offset to param file names
	add r23, r23, r22		# /
	add r23, r23, r29		# Get the title address
	lis r12, 0x8053			# Stage files write to 8053F000
	ori r12, r12, 0xF000	#	
	
	addi r3, r1, 0x90
	lis r4, 0x8048			#
	ori r4, r4, 0xEFF4		# %s%s%s%s	
	lwz r5, -0x1C(r12)		# "/stage/"
	lwz	r6, -0x14(r12)		# "stageinfo/" 
	mr r7, r23				# <-r23 filename 
	lwz	r8, -0xC(r12)		# ".param"
	lis r12, 0x803F			# \
	ori r12, r12, 0x89FC	# | Create the filename string
	mtctr r12				# |
	bctrl					# /	
	
	lis  r5, 0x8053			# Stage lists are written to 8053F200
	ori  r5, r5, 0xF000		#
	addi r3, r1, 0x60
	addi r4, r1, 0x90
	li r6, 0x0
	li r7, 0x0
	lis r12, 0x8002			# \
	ori r12, r12, 0x239C	# | set the read parameter
	mtctr r12				# |
	bctrl 					# /
	addi r3, r1, 0x60
	li r18, 0
	li r19, 0
	lis r12, 0x8001			# \
	ori r12, r12, 0xBF0C	# | load the file
	mtctr r12				# | 
	bctrl 					# /

	lis r12, 0x8053			# \
	ori r12, r12, 0xF000	# | Get the tracklist file name
	lwz r8, 0x18(r12)		# |
	lwz r4, 0x4(r12)		# |
	add r4, r4, r12			# |
	add r8, r8, r4			# /
	
TracklistLoading:	
	stwu r1, -0xF0(r1)
	stw r4, 0x8(r1)
	stw r5, 0xC(r1)
	stw r6, 0x10(r1)
	stw r7, 0x14(r1)
	stw r3, 0x18(r1)
	lis r4, 0x8053;  ori r4, r4, 0xCFF8	# 
	lwz r5, 0x0(r4)						# "sound/tracklist/"
	lwz r4, 0x4(r4)						# "%s%s.tlst"
	mr r6, r8
	addi r3, r1, 0x60
	lis r12, 0x803F				# \
	ori r12, r12, 0x89FC		# | Create the filename string
	mtctr r12					# |
	bctrl						# /
	lis  r5, 0x8053				# Tracklists are written to 8053F200, stage files to 8053F000
	ori  r5, r5, 0xF200			#
	addi r3, r1, 0x30
	addi r4, r1, 0x60
	li r6, 0x0
	li r7, 0x0
	lis r12, 0x8002			# \
	ori r12, r12, 0x239C	# | set the read parameter
	mtctr r12				# |
	bctrl 					# /
	addi r3, r1, 0x30
	li r6,0					# Necessary to prevent a max filesize override by the File Patch Code!
	lis r12, 0x8001			# \
	ori r12, r12, 0xBF0C	# | load the file
	mtctr r12				# | 
	bctrl 					# /
	lwz r4, 0x8(r1)
	lwz r5, 0xC(r1)
	lwz r6, 0x10(r1)
	lwz r7, 0x14(r1)
	lwz r3, 0x18(r1)
	addi r1, r1, 0xF0	

FinishedTracklistLoading:
	
	addi r11, r1, 0x50
	lis r12, 0x803F			# \
	ori r12, r12, 0x1338	# |
	mtctr r12				# | Restore registers r14-r31
	bctrl					# /
	lwz r0, 0x134(r1)
	mtlr r0
	lwz r1, 0(r1)
	blr
}

#######################################################################
If No Song Titles Are Found, Obtain Them From The TLST File [DukeItOut]
#######################################################################
.alias tlstHeaderSize = 0xC		# Data block size for the header
.alias tlstSongSize = 0x10		# Data block size for each available song
# 
op b -0x158 @ $800DE81C # Go to below
op li r5, -2 @ $800DE6D4
# Force it to read for a title, even if the title section isn't present in the info pac file
HOOK @ $800DE6C4
{
	bne+ wasFound
	lwz r12, 0(r1)
	lwz r12, 0(r12)
	lwz r12, 4(r12)
	lis r5, 0x8095		# \ Check if battle is starting
	ori r5, r5, 0x1214 	# /
	cmpw r12, r5
	beq forceRead
	lis r5, 0x8095
	ori r5, r5, 0x11D8
	cmpw r12, r5
	beq forceRead
	lwz r12, 4(r1)
	lis r5, 0x8117
	ori r5, r5, 0xF428
	cmpw r12, r5
	bne defaultBehavior
forceRead:
	lwz r3, 0x164(r30)
	li r4, 0
	li r5, -2
	lis r12, 0x800D
	ori r12, r12, 0xE6D8
	mtctr r12
	bctr 
defaultBehavior:
	cmpwi r3, 0			# reset conditions
wasFound:	
	mr r5, r3			# Original operation
}
###
HOOK @ $800B91F0 
{
	li r3, 0		# Normally tells it that it is false
	cmpwi r5, -2	# Check if this is a custom tracklist title request
	bne+ %END%		#
entertingMyMusic:
enteringBattle:

	stwu r1, -0x10(r1)
	stw r4, 0x8(r1)
	lis r12, 0x8053			# \ Location of tracklist file.
	ori r12, r12, 0xF200	# /
	lwz r5, 4(r12)			# \ Get the song count
	mtctr r5				# /
	li r6, 0
	addi r12, r12, tlstHeaderSize		# Beginning of song data
	# lwz r4, 0x698(r25)				# Get song ID
	lis r4, 0x8054						# \ Get song ID from mirror 8053EFD4
	lwz  r4, -0x102C(r4)				# /
songLoop:
	lwzx r5, r12, r6
	cmpw r4, r5
	beq- foundSong
	addi r6, r6, tlstSongSize	# Size of each song parameter block
	bdnz+ songLoop
	li r3, 0				# Location was unsuccessful if it reached this point
	addi r1, r1, 0x10
	b %END%			
foundSong:
	#lis r4, 0x8054				# \ Title already placed here.
	#lwz r4, -0x1028(r4)		# /
	mr r4, r12
	subi r12, r4, tlstHeaderSize #
	add r5, r4, r6				# Offset of the song
	lwz r6, 0xC(r5)				#
	stw r6, -0x254(r12)			# Set song pinch mode statuses (16-bit timer, bool for pinch mode in stock contexts,
								#									bool for if a song is hidden from the tracklist
	lhz r3, 0xA(r12)			# Pointer to string table
	lhz r6, 0xA(r5)				# Offset for title
	cmplwi r6, 0xFFFF
	bne hasTitle
	lis r4, 0x8047				# \ "ERROR" title
	ori r4, r4, 0xF4E9			# /
	b setTitle
hasTitle:
	add r6, r6, r3
	add r4, r12, r6
setTitle:
	stw r4, -0x0228(r12)
	
	stw r4, 0xC(r1)			# Preserve this offset!
	
	mr r3, r29 
	lwz r4, 0x8(r1)			# Retrieve r4 for initialization
	
	lis r12, 0x800B
	ori r12, r12, 0x8EE8
	mtctr r12
	bctrl
	mr r4, r31
	mr r5, r30
	
	lwz r4, 0xC(r1)			# Where to write from
	li r5, 0
IllBeBack:
	lbzx r3, r4, r5
	cmpwi r3, 0
	beq foundTerminator
	addi r5, r5, 1
	b IllBeBack
foundTerminator:
	lwz r3, 0x8(r29)		# \
	lwz r31, 0x1D0(r3)		# |
	lwz r0, 0x4C(r31)		# |
	lwz r3, 0x50(r31)		# |
	add r3, r3, r0			# / Where to write to
	cmpwi r5, 0				# \ r5 contains the string length to write
	bne hasLength
	stb r5, 0(r3)			# Still guarantee the title doesn't get corrupted if 0
	b finishProcess
hasLength:
	lwz r0, 0x4C(r31)
	add r0, r0, r5
	stw r0, 0x4C(r31)
	lis r12, 0x8000			# \
	ori r12, r12, 0x4338	# | Write title
	mtctr r12				# |
	bctrl 					# /
finishProcess:	
	addi r1, r1, 0x10

	li r3, 1				# Force it to assume it is successful
}
# Force My Music to load titles from the TLST (modified by Desi to remove song limit on My Music)
#
# Fixed issue where altering the My Music menu too extensively would break compatibility with this code
HOOK @ $8117F418
{
	addi r4, r3, 0x40			#\Get Song ID, but load from 8053F200 instead of 81521880
	subf r4, r4, r25			#|
	mulli r4, r4, 0x4			#|
	lis r5, 0x8053				#|
	ori r5, r5, 0xF20C			#|
	add r4, r5, r4				#|
	lwz r5, 0 (r4)				#/
	lis r4, 0x8054				# \ Place the song ID
	stw r5, -0x102C(r4)			# /	
	li r4, 0					#
	li r5, -2					# Activate behavior acknowledging no title file
}

# Redirect the title information to the TLST
HOOK @ $80079334
{
	lwzux r31, r4, r0		# Original operation, obtains song ID
	lis r12, 0x8053
	ori r12, r12, 0xF200
	li r0, 0	
	stw r0, -0x254(r12)			# (Pinch Mode Time Transition, Statuses)
	stw r0, -0x230(r12)			# \ (Filename)
	stw r0, -0x22C(r12)			# | (Song ID) 		Clear settings
	stw r0, -0x228(r12)			# / (Title)
	lis r5, 0x805B				# \ 
	lwz r5, 0x50AC(r5)			# | Get current game mode.
	lwz r5, 0x10(r5)			# |
	lwz r5, 0x0C(r5)			# /
	cmpwi r5,   1; beq- MyMusic		 # \ if the main menu
	cmpwi r5,   7; beq- SinglePlayer # | Or a single-player mode
	cmpw  r5, 0xD; beq- SinglePlayer # / then don't apply a startup delay!
	lhz r0, 0x4(r4)					 # (Startup Delay)
SinglePlayer:
MyMusic:
	sth r0, -0x224(r12)			# 
	lbz r0, 0x6(r4)				# \ (Song Volume)
	stb r0, -0x222(r12)			# / 
	lwz r0, 0xC(r4)				# \ Song transition time (if applicable)
	stw r0, -0x254(r12)			# /
	cmpwi r31, 0
	beq didNotFind
	lhz r0, 0x8(r4)				# Load filename
	cmplwi r0, 0xFFFF
	beq- noFilename
	lhz r5, 0xA(r12)			# \ Get offset to string table
	add r5, r5, r12				# |
	add r5, r5, r0				# | and store filename to 805ECFD0
	stw r5, -0x230(r12)			# /
noFilename:
	lhz r0, 0xA(r4)
	cmplwi r0, 0xFFFF
	beq- noTitle
	lhz r5, 0xA(r12)			# \ Get offset to string table
	add r5, r5, r12				# \ Get offset to string table
	add r5, r5, r0				# | and store title to 805ECFD8
	stw r5, -0x228(r12)			# /
noTitle:
	lwz r5, -0x230(r12)
	lwz r0, -0x228(r12)
	cmpwi r5, 0
	bne hasFilename
	stw r0, -0x230(r12)			# Place the title in the filename
	cmpwi r0, 0
	bne hasFilename
didNotFind:	
	lis r5, 0x817F				# \ "000.brstm" default stream
	ori r5, r5, 0x7E28			# |
	stw r5, -0x230(r12)			# /	
	lis r5, 0x8047				# \ "ERROR" title
	ori r5, r5, 0xF4E9			# |
	stw r5, -0x228(r12)			# /
hasFilename:
setID:
	stw r31, -0x22C(r12)		# Place song ID at 8053CFD4	
}	
HOOK @ $80073ED4
{
	cmpwi r29, 0x2705			# \ Classic Results music breaks the engine, avoid that!
	beq- forceSkip				# /
	lis r12, 0x8053
	ori r12, r12, 0xF200
	li r0, 0	
	stw r0, -0x230(r12)			# \ (Filename)
	stw r0, -0x22C(r12)			# | (Song ID) 		Clear settings
	stw r0, -0x228(r12)			# | (Title)
	sth r0, -0x224(r12)			# | (Startup Delay)
	stb r0, -0x222(r12)			# / (Song Volume)
	addi r6, r12, 0xC			# Go past header
	li r7, 0
	lwz r8, 0x4(r12)			# \ Song count
	mtctr r8					# /
	cmpwi r8, 0					# \
	beq didNotFind				# / Avoids feedback loop error
songLoop:	
	lwzx r0, r6, r7				# \
	cmpw r29, r0				# | Is this the right song?
	beq- foundSong				# /
	addi r7, r7, 0x10			# Size of each song block
	bdnz+ songLoop
	b didNotFind				# Write default info in this case
foundSong:
	add r4, r6, r7	
	lis r5, 0x805B				# \ 
	lwz r5, 0x50AC(r5)			# | Get current game mode.
	lwz r5, 0x10(r5)			# |
	lwz r5, 0x0C(r5)			# /
	cmpwi r5,   1; beq- MyMusic		 # \ if the main menu
	cmpwi r5,   7; beq- SinglePlayer # | Or a single-player mode
	cmpw  r5, 0xD; beq- SinglePlayer # / then don't apply a startup delay!
	lhz r0, 0x4(r4)				# \ (Startup Delay)
	sth r0, -0x224(r12)			# /
SinglePlayer:	
MyMusic:	
	lbz r0, 0x6(r4)				# \ (Song Volume)
	stb r0, -0x222(r12)			# / 
	cmpwi r29, 0
	beq didNotFind
	lhz r0, 0x8(r4)				# Load filename
	cmplwi r0, 0xFFFF
	beq- noFilename
	lhz r5, 0xA(r12)			# \ Get offset to string table
	add r5, r5, r12				# |
	add r5, r5, r0				# | and store filename to 805ECFD0
	stw r5, -0x230(r12)			# /
noFilename:
	lhz r0, 0xA(r4)
	cmplwi r0, 0xFFFF
	beq- noTitle
	lhz r5, 0xA(r12)			# \ Get offset to string table
	add r5, r5, r12				# \ Get offset to string table
	add r5, r5, r0				# | and store title to 805ECFD8
	stw r5, -0x228(r12)			# /
noTitle:
	lwz r5, -0x230(r12)
	lwz r0, -0x228(r12)
	cmpwi r5, 0
	bne hasFilename
	stw r0, -0x230(r12)			# Place the title in the filename
	cmpwi r0, 0
	bne hasFilename
didNotFind:	
	lis r5, 0x817F				# \ "000.brstm" default stream
	ori r5, r5, 0x7E28			# |
	stw r5, -0x230(r12)			# /	
	lis r5, 0x8047				# \ "ERROR" title
	ori r5, r5, 0xF4E9			# |
	stw r5, -0x228(r12)			# /
hasFilename:
setID:
	stw r29, -0x22C(r12)		# Place song ID at 8053CFD4	
forceSkip:
	mr r5, r29	# Restores song ID, original operation
}
	
.include source/Project+/MyMusic.asm		# Integrated heavily into the above!
.include source/Project+/Random.asm			# Custom random code to load expansion and non-striked slots, properly

#####################################################################################################
[Legacy TE] Hold Y on Smashville to Guarantee a Concert V2 (requires ASL Helper and SFSN) [DukeItOut]
#####################################################################################################
HOOK @ $8010FBC4
{
  lbz r0, 0(r31)
  lis r5, 0x800B			# \ Access player input via ASL Helper
  ori r5, r5, 0x9EA0		# |
  lhz r12, 2(r5)			# /
  andi. r12, r12, 0x800		# If holding Y (800)
  beq- noConcert			# Attempt the code. (Only Smashville reads here.)
  lis r12, 0x8010			# \
  ori r12, r12, 0xFCA8		# | Go straight to triggering the concert mode substage ID 5
  mtctr r12					# |
  bctr 						# /
noConcert:
}
##########################################################
KK Concert Music Only Triggers Via TLST File [DukeItOut]
# 
# Makes music only trigger KK Concert songs when holding Y
#
# 00 = 0  	# Dawn
# 01 = 1	# Morning
# 02 = 2	# Day
# 03 = 3	# Evening, No Concert
# 03 = 4	# Evening, KK Slider Prepping Guitar
# 03 = 5 	# Evening, KK Concert
# 04 = 6	# Midnight, No Concert
# 04 = 7	# Midnight, KK Concert
##########################################################
op b 0x15C @ $8010FCC4

###########################################################################
Metal Cavern and Online Training Room Can Use Custom Tracklists [DukeItOut]
###########################################################################
op NOP 		@ $8010FBB0
op NOP	 	@ $8010FE08
op b -0x4 	@ $8010FABC		# Makes Slot # 5, Mushroomy Kingdom/Metal Cavern, behave normally
op b -0x4	@ $8010FDFC		# Makes Slot 

# 8010FDC0 sets ID 2708	Home-Run Contest
# 8010FDF0 sets ID 2707	All-Star Rest Area
# 8010FE04 sets ID 26FF Online Practice Stage
# 8010FE18 sets ID 2712 Break the Targets

#######################################################################################
SSSRES:Stage Selection Screen Roster Expansion System (RSBE.Ver) v1.1 [JOJI, DukeItOut]
#
# 1.1: fixed issue where page 3 wouldn't load all stages if page 1 had less, overall
#######################################################################################
HOOK @ $806B1F04				# Forces it to fill the amount of stage slots to max possible to avoid an error with expansion pages
{
	li r3, 39					# \ Use this as a max possible for a page. Do not raise above this!
	mtctr r3					# /
	lwz r3, 0x22C(r27)			# Get the table address of stage index offsets
	li r12, 0
TableWriteLoop:
    stbx r12, r3, r12			# \ The order is consecutive, so this works.
    addi r12, r12, 1			# /
	bdnz+ TableWriteLoop
	lwz r0, 0x40(r24)			# Original operation
}
HOOK @ $806B58EC
{
  addi r4, r4, 0x1	# Original operation
  lis r18, 0x9100
  lis r16, 0x8049
  ori r16, r16, 0x6000
  lwz r18, -0x62B0(r18)
  cmpwi r18, 0xC;  bne- loc_0x24
  li r17, 0xC
  b loc_0x28

loc_0x24:
  li r17, 0x0

loc_0x28:
  stb r17, 5(r16)
  lbz r17, 0(r16)
  addi r17, r17, 0x1
  stb r17, 0(r16)
  cmpwi r17, 0x1;  beq- loc_0x64
  cmpwi r17, 0x4;  bne- loc_0x50
  li r4, 0x2	# Set to page 2 state if trying to access a page 4, makes it try to access the custom stage page
  b loc_0x64

loc_0x50:
  cmpwi r17, 0x5;  bne- loc_0x60
  li r17, 0x0						# \ Force reset if inexplicably too high
  stb r17, 0(r16)					# /

loc_0x60:
  li r4, 0x3

loc_0x64:
  li r18, 0x0
}
HOOK @ $806B2310		# Updates the page number texture icon
{
	lis r3, 0x8049		# \ Page Number as is observed by the new SSS system
	lbz r0, 0x6000(r3)	# /
	lwz r3, 0x228(r29)	# Page Number as is observed by Brawl
	cmpwi r3, 2			# Is it the Brawl custom stage page?
	bne+ normalStage
	li r3, 4
	b %END%
normalStage:
	mr r3, r0			# \ Unorthodox increment due to limitations of register 0
	addi r0, r3, 1		# /
}
HOOK @ $806B3834		# Updates the page number texture icon, but every frame
{
	lis r3, 0x8049
	lbz r5, 0x6000(r3)
	lwz r3, 0x228(r31)
	cmpwi r3, 2
	bne+ normalStage
	li r3, 4
	b %END%
normalStage:
	addi r5, r5, 1
}
HOOK @ $806B0AB8
{
  stw r30, 0x228(r29)		# Original operation
  lis r16, 0x8049			# \
  ori r16, r16, 0x6000		# | Set page number
  stb r30, 0(r16)			# /
}

HOOK @ $806B5910
{
  lis r16, 0x8049			# \
  ori r16, r16, 0x6000		# | Load page number
  lbz r17, 0(r16)			# /
  cmpwi r17, 0x1;  blt- page_1
  cmpwi r17, 0x1;  beq- page_2
  lbzx r0, r16, r17			# Load byte value from 80496002-80496004 for amount of stages on this page if page 3 or higher
  b setStageCount

page_1:
  lis r22, 0x806B				# \
  ori r22, r22, 0x929C			# | Obtain stage count from table "# Page 1" below.
  lbz r0, 0(r22)				# /
  b setStageCount

page_2:
  lis r22, 0x806B				# \ 
  ori r22, r22, 0x92A4			# | Obtain stage count from table "# Page 2" below.
  lbz r0, 0(r22)				# /
setStageCount:
  stb r0, 0x230(r29)			#
}

HOOK @ $806B8F60
{
  lis r3, 0x8049				# \
  lbz r7, 0x6000(r3)			# / Get the page button value number
  mulli r7, r7, 4				#
  ori r8, r3, 0x5D04			# Pointer table to separate stage tables in memory
  lwzx r3, r7, r8				# 80496014 = Page 3? 8049603C = Page 4? 80496064 = Page 5?
}

op li r0, 4 @ $806B50B0
HOOK @ $806B41C8
{
  lis r16, 0x8049
  ori r16, r16, 0x6000
  li r15, 0x4												# \
  lbz r17, 0x4(r16);  cmpwi r17, 0x0;  bne- loc_0x3C		# / Skip page 5 if it has no additions
  li r15, 0x3												# \
  lbz r17, 0x3(r16);  cmpwi r17, 0x0;  bne- loc_0x3C		# / Skip page 4 if it has no additions
  li r15, 0x2												# \
  lbz r17, 0x2(r16);  cmpwi r17, 0x0;  bne- loc_0x3C		# / Skip page 3 if it has no additions
  li r15, 0x1												# Page 2 is the highest it will go to if the above 3 are deemed empty.

loc_0x3C:
  lbz r17, 0xC(r16);  cmpw r17, r15;  bne- loc_0x50			
  li r17, 0x0												# Set page button back to 0 if at the highest one.
  b loc_0x54

loc_0x50:
  addi r17, r17, 0x1										# Increment page button texture

loc_0x54:
  stb r17, 0xC(r16)											# 8049600C contains page animation value as a byte
  subi r30, r30, 0x6FE8										# Different from the original operation for unknown reasons
}

HOOK @ $806B36C0
{
  stw r0, 0x224(r30)		# Original operation.
  lis r16, 0x8049			# \
  ori r16, r16, 0x6000		# |
  li r17, 0xFF				# | Set to invalid value in certain contexts 
  stb r17, 0xE(r16)			# /
}

############################################
Expansion Stages in All-Star Fix [DukeItOut]
############################################
HOOK @ $806E3D2C
{
	lis r12, 0x8059
	ori r5, r12, 0xCA70	# "Unknown" default
	lis r0, 0x805A
	cmpw r3, r12; blt %END%	# \ Invalid, if not in this range
	cmpw r3, r0;  bgt %END%	# /
	mr r5, r3	# Original operation
}
byte 0x58 @ $8070294D	# "X"

############################
Crush anywhere anytime [Eon] 
############################
op nop @ $8083b1ac 

#####################################################################################
Crush effect in ef_StgBattleField outside of SSE [DukeItOut]
#
#Requires a special ef_StgBattleField pac file to be included in the stage to show up
#Requires "Crush anywhere anytime [Eon]" to function
#####################################################################################
HOOK @ $8087C838
{
	ori r4, r4, 18		# Get SSE effect
	lis r3, 0x80B8
	lwz r3, 0x7C28(r3)
	lbz r0, 0x68(r3)
	cmplwi r0, 1; beq+ %END% 	# Branch if in SSE
	lis r4, 0x32; ori r4, r4, 1		# First effect ID in ef_StgBattlefield 
}

############################################################################
Stage Builder Can Not Save to Wii NAND [DukeItOut]
#
# Prevents getting accidentally locked out of booting
# hackless method from saving to the Wii instead of the SD card.
# If this was done in the past, it required deleting the stage from the Wii
# to load a Brawl mod with this method, again.
############################################################################
HOOK @ $800F3B4C
{
	lis r12, 0x805B			# \
	lwz r12, 0x50AC(r12)	# | Retrieve the game mode name
	lwz r12, 0x10(r12)		# |
	lwz r12, 0x0(r12)		# /
	lis r3, 0x8070			# \ "sqEdit"
	ori r3, r3, 0x3940		# /
	cmpw r12, r3			# If in Stage Builder . . . . 
	lwz r3, -0x4250(r13)	# (Original operation)
	bne %END%	
	lis r12, 0x800F			# \
	ori r12, r12, 0x3B74	# | Force to SD selection, only!
	mtctr r12				# |
	bctr					# /
}

##############################################
Universal Stage Camera Speed: 2.0 [DukeItOut]
#
# This code makes having a consistent camera
# across the entirety of a build much easier.
# Instead of loading from the stage files, it
# is brute forced.
#
# Recommended values:
# 1.0  (0x3F800000) (Brawl)
# 1.45 (0x3FB9999A) (Personal preference)
# 2.0  (0x40000000) (Project M)
##############################################
HOOK @ $8009D0C0
{
    lis r12, 0x4000         # \ 2.0 (0x40000000) in PM
    ori r12, r12, 0x0000    # / This operaton is technically not necessary for this specific value, but it is left here for user customization convenience.
    stw r12, 0xB8(r3)       # sets Camera Speed from PAC, used to do so from f2
}

######################################################################################
Custom Stage Select Screen V2 [Spunit, Phantom Wings, SOJ, Yohan1044, DukeItOut, JOJI]
######################################################################################
op mr r0, r4				@ $806B8F5C # Access stage location in table
op lbzx r3, r3, r0			@ $806B8F64	# Entry variable is a byte, rather than a half
op rlwinm r0, r3, 1, 0, 30	@ $800AF618	# Access stage to load
op addi r4, r4, 2			@ $800AF68C	# Table entry size
op rlwinm r3, r3, 1, 0, 30	@ $800AF6AC	# \ Relates to loading the stage frame icon
op lbz r0, 1(r3)			@ $800AF6C0	# /
op li r3, -1				@ $800AF6E8	# Disables message?
op li r3, 0xC				@ $800AF59C	# Disables stage unlocking
CODE @ $800B91C8
{
	stmw r29, 0x14(r1)
	mr r31, r6
	mr r30, r5
	mr r29, r3
	cmpwi cr2, r5, -1
	ble- cr2, 0x14		
}

op lis r4, 0x8049 		@ $800AF58C
op lwz r4, 0x5D00(r4)	@ $800AF594
op lis r4, 0x8049		@ $800AF614
op lwz r4, 0x5D00(r4)	@ $800AF61C
op lis r4, 0x8049		@ $800AF66C
op lwz r4, 0x5D00(r4)	@ $800AF674
op lis r4, 0x8049		@ $800AF6A0
op lwz r4, 0x5D00(r4)	@ $800AF6A8
op lis r4, 0x8049		@ $800AF6D8
op lwz r4, 0x5D00(r4)	@ $800AF6E0

.include Source/Project+/StageTable.asm


