##############################################
Stage File System Neo v2 [DukeItOut, Kapedani]
##############################################
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
	lwz r3, 0x40(r31)	# \
	lhz r3, 0x1a(r3)	# | check loader->globalModeMelee->meleeInitData.stageKind == Stage_Subspace
	cmpwi r3, 0x3d		# |
	beq- skip 			# /
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
HOOK @ $806ee40c	# sqEvent::setNext
{
	lis r12, 0x8054			#
	lhz r12, -0x1046(r12)   # Get ASL input from 8053EFBA (copied from 800B9EA2)
	lis r11, 0x800C 		# \ restore to 800B9EA2 (after CSS in event mode since was wiped from transition between event to CSS)
	sth r12, -0x615E(r11)	# /
	lwz r12, 0x8(r3)	# \ GameGlobal->modeMelee.meleeInitData.songId
	lhz r12, 0x5E(r12)	# /
	lis r11, 0x8054			# \ Place song ID at 8053CFD4	
	stw r12, -0x102C(r11) 	# /
	mr r3, r15	# Original operation
}
	
###
# Load Soundbank from Stage File
HOOK @ $8094BF6C
{
	lwz r12, 0x40(r31)	# \
	lhz r12, 0x1a(r12)	# | check loader->globalModeMelee->meleeInitData.stageKind == Stage_Subspace
	cmpwi r12, 0x3d		# | Subspace needs to ignore this for special reasons
	bne %END%			# /
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
/*
### NO LONGER USED, LEFT HERE FOR NOW TO REMEMBER HOW IT WAS ACHIEVED
###
# Load RGBA Overlay
# Suggested values for overlays:
# 000000FF (0, 0, 0, 255)     for full black
# 3C6C24B4 (60, 108, 36, 180) for Game Boy green
# This affects characters, but not stages articles or effects
HOOK @ $8083413c	# Fighter::postInitialize
{
	extsb r0, r3	# Original operation
	lis r4, 0x8054			# \ Stage file RGBA settings @ $8053F00C
 	lwzu r12, -0xFF4(r4)	# / (normally uninitialized in Brawl)
	andi. r12, r12, 0xFF	# Check alpha settings
	beq- %end%		# If the alpha was clear, then behave normally and do not provide an overlay
	lis	r11, 0x805A				# \
	lwz r11, 0xE0(r11) 			# |
	lwz r11, 0x8(r11)			# | GameGlobal->globalModeMelee->meleeInitData.stageKind
	lhz r11, 0x1a(r11)			# /
	cmpwi r11, 0x3d			# \ check if stage id == adventure
	beq+ %end%				# /
	lwz	r3, 0xD8(r29)	# \ moduleAccesser->moduleEnumeration->colorBlendModule
	lwz	r3, 0xAC(r3)	# /
	li r5, 1				# Enable overlay
	lis r12, 0x8083			# \
	ori r12, r12, 0x4164	# | jump to call setSubColor
	mtctr r12 				# |
	bctr					# /
}
*/
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
Stage Roster Expansion System v3.2 [Phantom Wings, DukeItOut]
#
# 3.2: Modified memory allocation based on Sammi's new File
#         Patch Code. Parameter entry now defines secondary
#         allocation, instead. (Only needed for stages based
#         on Mario Bros., Castle Siege, Lylat Cruise and the
#         Stage Builder.)
#############################################################
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

# Force secondary stage pacs to load based on the parameter
# 806BC610
# 805A00E0 0008 001A
CODE @ $806BE230
{
	# Normally access the stage ID from 805A00E0 -> 08 -> 1A to check if Castle Siege or Lylat Cruise
	lis r12, 0x8054			# Get Dual Load flag at 80530015
	lbz r12, -0xFEB(r12)	#
	andi. r12, r12, 8		# Bit flag relevant
	beq+ 0x10				# Skip setting Dual Load flag!
}
# HOOK @ $8094ac18
# {
# 	lhz	r0, 0x1A(r4)	# Original operation
# 	cmpwi r0, 0x3d			# \
# 	bne+ %end%				# |
# 	lis r12, 0x8094			# | skip if Subspace
# 	ori r12, r12, 0xae80	# |
# 	mtctr r12				# |
# 	bctr					# /
# }
CODE @ $8094AC1C
{
	# Normally access the stage ID from 0x40(r3) -> 1A
	lis r12, 0x8054			# Get Dual Load flag at 80530015
	lbz r12, -0xFEB(r12)	#
	andi. r12, r12, 8		# Bit flag relevant
	beq+ 0x258				# Skip setting Dual Load behavior!
}
HOOK @ $806BE22C
{
	lhz r0, 0x1A(r3)		# Original operation. Get stage slot ID
	cmpwi r0, 0x28			# Is this the results screen? 
	bne NormalStage
	#cmpwi r0, 0x3D
	#bne NormalStage
	lis r12, 0x806B
	ori r12, r12, 0xE24C
	mtctr r12
	bctr					# If it is, it is not a dual-load stage!
NormalStage:
}

# TODO: Address secondary pac shuffling for Lylat Cruise. Currently checks for substage count at 8094AEA4???
# TODO: Address secondary pac being randomized.

# Force Regular Stages To Use Secondary Allocation when needed. (See Mario Bros, Lylat Cruise, Castle Siege)
HOOK @ $80949F40
{
	cmpwi r0, 0x3d			# \ stageKind == Stage_Subspace 
	beq- SSE				# / 
	lis r12, 0x8054			# \ Get reserved memory allocation from STEX system at 8053F024
	lwz r3, -0xFDC(r12)		# /
	cmpwi r3, 0				# \ If a value is hardcoded, use it!
	bnelr-					# / 
SSE:
Normal:
	cmplwi r0, 39		# Original operation
}


#80949F38 special cases for:
#39/0x27	?????
#19/0x13	Lylat Cruise			lis r3, 0x36; addi r3, r3, 0x6640
#25/0x19 Castle Siege			lis r3, 0x4B, addi r3, r3, 0x3300
#53/0x35 Stage Editor Stage		lis r3, 0x10
#61/0x3D ????? something in SSE		really special scenario with special coding?
#31/0x1F Mario Bros			lis r3, 0x10
#default: r3 = 0x2000

# Below is a temp fix until I make the above modular
# op cmplwi r0, 5 @ $80949FC0	# Normally 0x1F (Famicom), allows Mario Bros to load properly from Metal Cavern

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
Custom Stage SD File Loader [DukeItOut, Kapedani]
# 
# This version forces stage reloading if a flag is set, as well as uses the flag to determine if it's a replay
#
# Requires:
# CMM SD File Saver
# mtRand::randi behaves as mtRand->randi(max)
#
# NEW: Random support and character based results/target smash
#
# Prerequisite: Stage ID in r3 (retrieves input, itself)
########################################################

.alias g_GameGlobal                 = 0x805a00E0
.alias g_mtRand_net					= 0x805a0420
.alias ftInfo__getNamePtr			= 0x808588d8
.alias ftKindConversion__convertKind = 0x808545ec
.alias ipSwitch__getInstance		= 0x8004a750
.alias gfFileIORequest__setReadParam	= 0x8002239c
.alias gfFileIO__readFile			= 0x8001bf0c
.alias sprintf						= 0x803f89fc

.alias RSS_EXDATA_BONUS				= 0x8042C840 
.alias ASL_DATA						= 0x8053F000
.alias TRACKLIST_DATA				= 0x8053F200
.alias CODEMENU_ASL_LOC				= 0x804E00E8

.macro lbd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lbz     <reg>, temp_Lo(<reg>)
}
.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}
.macro lwdu(<reg1>, <reg2>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg2>, temp_Hi
    lwzu    <reg1>, temp_Lo(<reg2>)
}
.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro call(<addr>)
{
  %lwi(r12, <addr>)
  mtctr r12
  bctrl    
}

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
	%lwi (r22, ASL_DATA)

	lis r28, 0x800B 
	ori r28, r28, 0x9EA0
	sth r3, 0(r28)			# Store stage ID for future reference
	mr r7, r3				# Stage ID
	li r0, 0xFF				# Clear random reroll flag for substages
	stb r0, -0x7E(r22)		#
	sth r7, -0x80(r22)		# Store stage ID
	addi r3, r1, 0x90

	lwz r4, -0x20(r22)		# "%s%s%02X%s"
	lwz r5, -0x1C(r22)		# "/stage/"
	lwz	r6, -0x18(r22)		# "stageslot/" 
	lwz	r8, -0x10(r22)		# ".asl"

	cmpwi r7, 0x38			# \ check if targetsmash
	bne+ notSpecialStage	# /
	%lwd (r12, g_GameGlobal)	
	lwz r12, 0x8(r12)			# \ g_GameGlobal->modeMelee->playerInitData[0].characterKind
	lbz r3, 0x98(r12)			# /
	addi r4, r1, 0x90
	%call (ftKindConversion__convertKind)
	lwz r4, 0x90(r1)
	li r3, 0x0
	%call (ftInfo__getNamePtr)
	mr r9, r3
	addi r3, r1, 0x90
	lwz r5, -0x1C(r22)		# "/stage/"
	lwz	r6, -0x18(r22)		# "stageslot/"
	lwz	r10, -0x10(r22)		# ".asl"
	%lwi (r7, 0x80B2EC03)	# "tBreak"
	%lwi (r4, 0x8048EFF0)	# "%s%s%s%s%s%s"
	addi r8, r5, 0x6		# "/"
notSpecialStage:
	%call (sprintf)			# Create the filename string
	mr r5, r22				# Stage files to 8053F000
	addi r3, r1, 0x60
	addi r4, r1, 0x90
	li r6, 0x0
	li r7, 0x0
	%call (gfFileIORequest__setReadParam) # set read parameter
	addi r3, r1, 0x60
	li r18, 0
	li r19, 0
	%call (gfFileIO__readFile)	# load the file

	addi r23, r22, 8		# Get to the list of inputs and title offsets
	li r26, 0				# Choice-checking
	li r29, 0				
	li r21, 0	

	lhz 	r27, 0(r28)			# Get access to the stage ID
	lhz		r16, 2(r28)			# / Get the input assigned
    cmpwi 	r17, 0x52		  #\ Replays require different info
    bne+    Multiplayer       #/
Replay:
   	#li r3, 11					# \
	#bla 0x0249CC				# / Get replay heap offset
	#lhz 	r16, 0x44A(r3)		# \ Get Replay ASL value	
	%call (ipSwitch__getInstance)	# \
	lwz r3, 0x18(r3)				# |
	lwz r3, 0x24(r3)				# | ipSwitch->keyRecorder->bufferData->buttonASL
	lhz r16, 0x34A(r3)				# /
	sth     r16, 2(r28)       	# /
	li		r0, 0xFF			# r0 was overwritten, but we still need it!
	b notRandom
Multiplayer:    	
	li r31, 0x2 
	%lwd(r12, CODEMENU_ASL_LOC)		# Attempt to grab the address of the Alt Stage line from the Code Menu.
	cmplwi r12, 0x00				# If the line doesn't exist though...
	beq skipToCheck					# ... skip trying to load its value, cuz we'd crash otherwise.
	lwz r12, 0x08(r12)				# If it *does* exist though, load its value!
skipToCheck:
	cmpwi r12, 0x1
	beq+ startRandomLoop
	%lbd (r31, RSS_EXDATA_BONUS)	# \ 
	andi. r0, r31, 0x10 			# | check if 0x10 bit is on (don't select random)
	bne- notRandom					# / 
	andi. r31, r31, 0x6				# \ check if 0x2 or 0x4
	beq+ notRandom					# /
	cmpwi r31, 0x6			# \ check if both
	bne+ startRandomLoop	# /
	li r4, 0x2						# \
	%lwdu (r12, r3, g_mtRand_net)	# |
	lwz r12, 0x18(r12)				# | g_mtRand_net->randi(endIndex - beginningIndex)
	mtctr r12						# |
	bctrl 							# /
	li r31, 0x2
	cmpwi r3, 0x0
	beq+ startRandomLoop
	li r31, 0x4
startRandomLoop:
	slwi r31, r31, 13	# shift 0x2/0x4 to make 0x4000/0x8000 mask
	lhz r12, 4(r22)			# \ Get the slot count
	mtctr r12 				# /
randomLoop:
	# r29 - start index
	# r21 - count/end index
	# NOTE: >=0x4000 alts should be ordered sequentially together (and shouldn't be at the very first entry)
	lhzx r25, r23, r26	
	cmpwi r29, 0x0		# \ check if already found start of alts
	bne+ alreadyStarted	# /
	cmplwi r25, 0xC000		# \ 
	bge+ endRandomLoop		# | check to see if start of alts was found
	and. r11, r31, r25		# |
	beq+ endRandomLoop		# / 
	mr r29, r21			# get startIndex of alts
alreadyStarted:
	cmplwi r25, 0xC000		# \ 
	bge+ finishRandomLoop	# |
	and. r11, r31, r25		# | check to see if end of alts was found
	beq- finishRandomLoop	# /
endRandomLoop:
	addi r21, r21, 0x1
	addi r26, r26, 0x4
	bdnz+ randomLoop
finishRandomLoop:
	li r3, 0			# \
	cmpwi r29, 0x0 		# | check if any random alts found, default if not
	beq- noRandomAlts	# /
	sub r4, r21, r29				# \
	%lwdu (r12, r3, g_mtRand_net)	# |
	lwz r12, 0x18(r12)				# | g_mtRand_net->randi(endIndex - beginningIndex)
	mtctr r12						# |
	bctrl 							# /
	add r3, r3, r29		
noRandomAlts:	 
	mulli r29, r3, 0x4		
	b slotFound
notRandom:
	lhz r12, 4(r22)			# \ Get the slot count
	mtctr r12 				# /
	%lwd (r12, g_GameGlobal)
	lwz r10, 0x18(r12)		# g_GameGlobal->resultInfo
    cmpwi r27, 0x28		# \ check if results
	beq+ isResult		# /
	cmpwi r27, 0x39				# \ check if cRoll
	beq+ getCharacterKind		# /
	cmpwi r27, 0x38		# \ check if target smash
	bne- loop			# /
	lwz r12, 0x8(r12)	# \ turn substages into input so bonus stages can have their own param
	lbz r16, 0x1C(r12)	# / 
	b loop
isResult:
	li r16, 0x0
	lbz r11, 0x11(r10)		# \
	cmpwi r11, 0x0			# | check if noContest
	beq+ loop				# /
	lbz r11, 0x1f(r10)		# |
	mulli r11, r11, 0x2ac	# | turn g_GameGlobal->resultInfo->playerResultInfo[winningPlayer].characterKind so that can have per character results screen
	add r10, r10, r11		# | 
getCharacterKind:
	lbz r16, 0x24(r10)		# |
	addi r16, r16, 0x1		# /
loop:	
	# r29 - Most accurate choice, defaulting to the start
	# r21 - How many inputs it shares
	lhzx r25, r23, r26
	and. r25, r16, r25
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
    cmpwi r27, 0x26			# \ Do not save if CSS
	beq DoNotSaveASL		# /
	cmpwi r27, 0x28         # \ Do not save if results stage
    beq DoNotSaveASL		# /
    addi r23, r22, 8		# \ Get to the list of inputs and title offsets
    lhzx r25, r23, r29      # /
	lis r12, 0x8054			#
	sth r25, -0x1046(r12)   # Set ASL input to 8053EFBA (copied from 800B9EA2)
	li r12, 0
	sth r12, 2(r28)         # Reset alt stage helper ASL loc
    # %call (ipSwitch__getInstance)	# \
	# lwz r3, 0x18(r3)				# |
	# lwz r3, 0x24(r3)				# | set ipSwitch->keyRecorder->bufferData->buttonASL
	# sth r25, 0x34A(r3)				# /
DoNotSaveASL:
	addi r29, r29, 0xA		# \ pass the 8-byte header and add 2 to get the offset instead of input
	lhzx r29, r22, r29		# /
	lhz r23, 6(r22)			# \ Get offset to param file names
	add r23, r23, r22		# /
	add r23, r23, r29		# Get the title address

	addi r3, r1, 0x90
	lis r4, 0x8048			#
	ori r4, r4, 0xEFF4		# %s%s%s%s	
	lwz r5, -0x1C(r22)		# "/stage/"
	lwz	r6, -0x14(r22)		# "stageinfo/" 
	mr r7, r23				# <-r23 filename 
	lwz	r8, -0xC(r22)		# ".param"
	%call (sprintf)			# Create the filename string
	
	mr r5, r22				# Stage params are written to 8053F000 
	addi r3, r1, 0x60
	addi r4, r1, 0x90
	li r6, 0x0
	li r7, 0x0
	%call (gfFileIORequest__setReadParam)	# set the read parameter
	addi r3, r1, 0x60
	li r18, 0
	li r19, 0
	%call (gfFileIO__readFile)	# load the file

	lwz r8, 0x18(r22)		# \
	lwz r4, 0x4(r22)		# | Get the tracklist file name
	add r4, r4, r22			# |
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
	%call (sprintf)		# Create the filename string
	addi r5, r22, 0x200 # Tracklists are written to 8053F200, stage files to 8053F000
	addi r3, r1, 0x30
	addi r4, r1, 0x60
	li r6, 0x0
	li r7, 0x0
	%call (gfFileIORequest__setReadParam)	# set the read parameter
	addi r3, r1, 0x30
	li r6,0					# Necessary to prevent a max filesize override by the File Patch Code!
	%call (gfFileIO__readFile)	# load the file
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

#################################################################################
If No Song Titles Are Found, Obtain Them From The TLST File [DukeItOut, Kapedani]
#################################################################################
.alias tlstHeaderSize = 0xC		# Data block size for the header
.alias tlstSongSize = 0x10		# Data block size for each available song

.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro call(<addr>)
{
  %lwi(r12, <addr>)
  mtctr r12
  bctrl    
}

# 
op b -0x158 @ $800DE81C # Go to below
op li r5, -2 @ $800DE6D4
op nop @ $800de6c8
# Force it to read for a title, even if the title section isn't present in the info pac file

###
HOOK @ $800B91F0 
{
	cmpwi r5, -2	# Check if this is a custom tracklist title request
	bne+ end		# 
enteringBattle:

	lis r12, 0x8053			# \ Location of tracklist file.
	ori r12, r12, 0xF200	# /
	lwz r5, 4(r12)			# \ Get the song count
	mtctr r5				# /
	li r6, 0
	addi r11, r12, tlstHeaderSize		# Beginning of song data
	lis r10, 0x8054						# \ Get song ID from mirror 8053EFD4
	lwz  r10, -0x102C(r10)				# /
songLoop:
	lwzx r5, r11, r6
	cmpw r10, r5
	beq- foundSong
	addi r6, r6, tlstSongSize	# Size of each song parameter block
	bdnz+ songLoop
	b end		# Location was unsuccessful if it reached this point
foundSong:
	add r5, r11, r6				# Offset of the song
	lwz r6, 0xC(r5)				#
	stw r6, -0x254(r12)			# Set song pinch mode statuses (16-bit timer, bool for pinch mode in stock contexts,
								#									bool for if a song is hidden from the tracklist
	lhz r9, 0xA(r12)			# Pointer to string table
	lhz r6, 0xA(r5)				# Offset for title

	add r6, r6, r9
	add r5, r12, r6
	%call(0x800b9230) #bla 0x0b9230		# MuMsg::printf

	li r3, 1				# Force it to assume it is successful
	b %end%
end:
	li r3, 0		# Normally tells it that it is false

}
# Force My Music to load titles from the TLST (modified by Desi to remove song limit on My Music)
#

HOOK @ $8010fe28	# stGetStageParameter
{
	oris r0, r30, 0xFF00	# Original operation
	lis r12, 0x8054		 	# \ Place song ID at 8053CFD4 	
	stw r30, -0x102C(r12) 	# /
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

#################################################################################################
SSSRES:Stage Selection Screen Roster Expansion System (RSBE.Ver) v1.3 [JOJI, DukeItOut, Kapedani]
#
# 1.1: fixed issue where page 3 wouldn't load all stages if page 1 had less, overall
# 1.2: fixed issue where the wrong button was displayed when no custom stages 
#			were present
# 1.3: Compatibility with new random
#################################################################################################
.alias g_muSelectStageFileTask		= 0x806BB388
.alias STAGELIST_TYPE				= 0x8042C842 #0x806AEE1A
.alias STAGE_PAGES					= 0x8042C524
.alias STAGE_PAGES_IDS				= 0x8042C525

.alias MaxPages = 3			# Amount of normal expansion stage pages
.alias BackFrame = 4		# Frame that the last page will use to indicate the next is page 1
.alias CustomFrame = 3		# Frame for the Stage Builder

.macro lbd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lbz     <reg>, temp_Lo(<reg>)
}
.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}
.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro branch(<addr>)
{
    %lwi(r12, <addr>)
    mtctr r12
    bctr
}

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
HOOK @ $806b22a8	# muSelectStageTask::dispPage
{	bctrl 			# Original operation
	mr r29, r27		# Store next page number
}

op sth r0, 0x398(r28) @ $806b7fec	# muSelectStageFileTask::__ct
HOOK @ $806b8b6c	# muSelectStageFileTask::mainStepNANDListing
{
	stw	r3, 0x50(r30)	# Original operation
	cmpwi r3, 0x0	# \ check if there is any stages
	beq+ %end%		# /
	%lbd (r12, STAGELIST_TYPE)	# \
	cmpwi r12, 0x0				# | check if normal default stagelist type
	bne+ %end%					# /
	li r12, 1			# \ keep track that at least one custom stage exists
	stb r12, 0x399(r30)	# /
}
HOOK @ $806b8c18	# muSelectStageFileTask::mainStepSDListing
{
	stw	r3, 0x8(r30)	# Original operation
	cmpwi r3, 0x0	# \ check if there is any stages
	beq+ %end%		# /
	%lbd (r12, STAGELIST_TYPE)	# \
	cmpwi r12, 0x0				# | check if normal default stagelist type
	bne+ %end%					# /
	li r12, 1			# \ keep track that at least one custom stage exists
	stb r12, 0x341(r30)	# /
}
HOOK @ $806b5934	# muSelectStageTask::buttonProc
{
	%lwd (r12, g_muSelectStageFileTask)	# \ check if any stage builder stages exist (go to custom page if it is)
	lbz r0, 0x399(r12)					# /
}
HOOK @ $806B2310		# Updates the page number texture icon
{
	# lwz r3, 0x228(r29)	# Page Number as is observed by Brawl
	cmpwi r29, 2			# Is it the Brawl custom stage page?
	beq- LastPage

	li r4, 2			# Max amount of normal pages in Brawl
	lbz r5, 0x0(r12)	# Active Page

	%lbd(r5, 0x80496000)	# Page Number as is observed by the new SSS system
	%lwi(r12, STAGE_PAGES)
	lbz r3, 0x50(r12); cmpwi r3, 0; beq- notAny; addi r4, r4, 1 # Amount of stages on page 3 (if any)
	lbz r3, 0x78(r12); cmpwi r3, 0; beq- notAny; addi r4, r4, 1 # Amount of stages on page 4 (if any)
	lbz r3, 0xA0(r12); cmpwi r3, 0; beq- notAny; addi r4, r4, 1 # Amount of stages on page 5 (if any)
notAny:	
	addi r0, r5, 1
	cmpw r0, r4			# If this isn't relevant due to being less than the latest normal page
	blt %END%			# Then don't bother.
	li r0, CustomFrame
	%lwd (r5, g_muSelectStageFileTask)	# \ 
	cmpwi r5, 0x0						# | 
	beq+ LastPage 						# | Get if there is at least one stage builder stage (and if muSelectStageFileTask is NULL)
	lbz r12, 0x399(r5)					# /
	cmpwi r12, 0	# \ Check if there are zero
	bne- %END%		# / Don't have the button point to a stage builder page if nothing is on it!
LastPage:
	li r0, BackFrame
}
# HOOK @ $806B3834		# Updates the page number texture icon, but every frame
# {
# 	lis r3, 0x8049
# 	lbz r5, 0x6000(r3)
# 	lwz r3, 0x228(r31)
# 	cmpwi r3, 2
# 	bne+ normalStage
# 	li r5, 4
# 	b %END%
# normalStage:
# 	addi r5, r5, 1
# }
op nop @ $806b3850	# Disable updating page number texture icon based on stage builder

HOOK @ $806B0AB8	# muSelectStageTask::__ct
{
  stw r30, 0x228(r29)		# Original operation
  lis r16, 0x8049			# \
  stb r30, 0x6000(r16)		# / Set page number
  stb r0, 0x605A(r29)	# Set page number for stagelists to -1
}

HOOK @ $806B5910	# muSelectStage::buttonProc
{
    lis r12, 0x8049					# \
  	lbz r11, 0x6000(r12)			# / Get the page button value number
  	mulli r11, r11, 40  	# \
	%lwi(r12, STAGE_PAGES)	# | get number of stages in pages
	lbzx r0, r11, r12		# /
}

HOOK @ $806b1f7c	# muSelectStage::dispPage
{
	subi r16, r16, 28648	# Original operation
	%lbd (r12, STAGELIST_TYPE)	# \
	cmpwi r12, 0x0				# | check if not builder stagelist
	bne+ notBuilderStagelist	# /
	li r12, 0			# set hazard on when page switches
	lbz r11, 0x46(r26)	# \
	cmpwi r11, 0x2		# | Unless all hazards off
	bne+ notHazardOff	# /
	li r12, 1
notHazardOff:
	stb r12, 0x45(r26)	
notBuilderStagelist:
  	lis r12, 0x8049					# \
  	lbz r11, 0x6000(r12)			# / Get the page button value number
  	mulli r11, r11, 40  	# \
	%lwi(r12, STAGE_PAGES)	# | get number of stages in pages
	lbzx r10, r11, r12		# /
setStageCount:
  	stb r10, 0x230(r26)			
}

CODE @ $806b8f38		# MuStageTblAcces_GetNumStageInPage
{
	%lwi(r8, STAGE_PAGES)
	mulli r3, r3, 40
	lbzx r3, r8, r3
	blr
}

CODE @ $806b8f50	# MuStageTblAcces_GetStageKind
{
	%lwi(r8, STAGE_PAGES_IDS)
	mulli r3, r3, 40
	add r3, r3, r8
	lbzx r3, r3, r4
	blr
}
HOOK @ $806b20c8	# muSelectStageTask::dispPage
{
	lis r3, 0x8049				# \
  	lbz r3, 0x6000(r3)			# / Get the page button value number
}
HOOK @ $806b5c2c	# muSelectStageTask::dispPage
{
	lis r3, 0x8049				# \
  	lbz r3, 0x6000(r3)			# / Get the page button value number
	cmplwi r4, 255	# Original operation
}
HOOK @ $806b6b80	# muSelectStageTask::dispPreview
{
	lis r3, 0x8049				# \
  	lbz r3, 0x6000(r3)			# / Get the page button value number
	cmplwi r4, 255	# Original operation
}

op li r0, 4 @ $806B50B0

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

.include Source/Project+/Gimmick.asm

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

op lis r4, 0x8042 		@ $800AF58C
op ori r4, r4, 0xC5EC	@ $800AF594
op lis r4, 0x8042		@ $800AF614
op ori r4, r4, 0xC5EC	@ $800AF61C
op lis r4, 0x8042		@ $800AF66C
op ori r4, r4, 0xC5EC	@ $800AF674
op lis r4, 0x8042		@ $800AF6A0
op ori r4, r4, 0xC5EC	@ $800AF6A8
op lis r4, 0x8042		@ $800AF6D8
op ori r4, r4, 0xC5EC	@ $800AF6E0

###########################################################
SSS Stage Lists and Alt Stage Display [DukeItOut, Kapedani]
###########################################################

.alias muSelectStageSwitch__selectRandom		= 0x806b74f0
.alias muSelectStageSwitch__dispPreview			= 0x806b6ab4
.alias g_muSelectStageFileTask					= 0x806BB388
.alias muSelectStageFileTask__deleteAllFileData	= 0x806b8768
.alias MuStageTblAcces_GetStageKind				= 0x806b8f50
.alias muMenu__exchangeMuStageKindToSrStageKind	= 0x800af614
.alias MuObject__setFrameNode					= 0x800b7798
.alias g_gfPadSystem							= 0x805A0040
.alias gfPadSystem__getSysPadStatus				= 0x8002ae48
.alias MuObject__changeClrAnimN					= 0x800b50cc
.alias g_sndSystem                  		 	= 0x805A01D0
.alias sndSystem__playSE             			= 0x800742b0
.alias g_GameGlobal                 			= 0x805a00E0
.alias sprintf									= 0x803f89fc
.alias strcat 									= 0x803fa384
.alias __memfill                    			= 0x8000443c

.alias PAGE_INDEX						= 0x8049601E
.alias STAGELIST_STAGEKIND				= 0x8042C841
.alias STAGELIST_TYPE					= 0x8042C842
.alias STAGELIST_FOLDER_NAME			= 0x8042C846
.alias STAGELIST_FILE_NAME				= 0x80423674
.alias _pf               				= 0x80507b70
.alias MOD_FOLDER        				= 0x80406920
.alias STAGE_FOLDER 					= 0x8053EFE4
.alias ASL_BUTTON						= 0x800B9EA0
.alias STAGE_STRIKE_TABLE				= 0x8042C822
.alias RSS_HAZARD_DATA					= 0x8042C506
.alias RSS_EXDATA_BONUS					= 0x8042C840
.alias CURRENT_PAGE						= 0x80496000
.alias MUSIC_SELECT_STEP				= 0x80002810

.macro lbd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lbz     <reg>, temp_Lo(<reg>)
}
.macro lbdu(<reg1>, <reg2>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg2>, temp_Hi
    lbzu    <reg1>, temp_Lo(<reg2>)
}
.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}
.macro sbd(<reg1>, <reg2>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg2>, temp_Hi
    stb     <reg1>, temp_Lo(<reg2>)
}
.macro sbdu(<reg1>, <reg2>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg2>, temp_Hi
    stbu     <reg1>, temp_Lo(<reg2>)
}
.macro swd(<storeReg>, <addrReg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <addrReg>, temp_Hi
    stw     <storeReg>, temp_Lo(<addrReg>)
}
.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro call(<addr>)
{
  %lwi(r12, <addr>)
  mtctr r12
  bctrl    
}
.macro branch(<addr>)
{
    %lwi(r12, <addr>)
    mtctr r12
    bctr
}

HOOK @ $806b0aa4	# muSelectStageTask::__ct
{
	stb r31, 0x44(r29)	# Original operation
	stb r31, 0x45(r29)	# Initialize 0x45 field for stage hazard on/off
	stb r31, 0x46(r29)	# Initialize 0x46 field for all hazards default/on/off
}

HOOK @ $806b1300	# muSelectStageTask::initProcWithScreen
{
	lfs	f1, 0x0(r30)	# \
	lwz r3, 0x80(r26)	# |
	lwz r3, 0x14(r3)	# | 
	lwz r3, 0xc(r3)		# |
	lwz r12, 0x0(r3)	# | this->previewMuObject->modelAnim->SetUpdateRate(0.0)
	lwz r12, 0x28(r12)	# |
	mtctr r12			# |
	bctrl 				# /
	%lwd(r12, MUSIC_SELECT_STEP)	# \
	cmpwi r12, 0x7					# | check if returning from MyMusic
	bne+ end						# /
	%lbd(r12, RSS_EXDATA_BONUS)
	srawi r3, r12, 6
	andi. r0, r12, 0xC0
	beq+ end
	lis r8, 0x806B
	ori r4, r8, 0x93B3	# SelmapRandom
	andi. r3, r3, 0x02
	stb r3, 0x46(r26)	# store all hazards  
	beq+ changeRandomClr
	ori r4, r8, 0x93B9	# Random
changeRandomClr:
	lwz r3, 0x1FC(r26)
	%call(MuObject__changeClrAnimN)
end:
	lwz	r3, 0x40(r26)	# Original operation
}

string "%s%s%s%sstagelist/%02X_%s/" @ $8042C846  

HOOK @ $806b6b38	# muSelectStageTask::dispPreview
{
	%lwd(r12, MUSIC_SELECT_STEP)	# \
	cmpwi r12, 0x7					# | check if returning from MyMusic
	bne+ notMusicSelect				# /
	%lwd(r12, g_GameGlobal)	# \
	lwz	r12, 0x14(r12)		# | g_GameGlobal->selStageData->hazard
	lbz r3, 0x25(r12)		# /
	b forceHazard 
notMusicSelect:
	lbz r3, 0x46(r29)	# \ check if mixed hazards
	cmpwi r3, 0x1		# /
	srawi r3, r3, 1		# shift bit to the right so that all hazards = 0x0, no hazards = 0x1
	bne+ forceHazard 	
	subi r3, r28, 0x2
	%lbd (r4, CURRENT_PAGE)
	%call(muSelectStageSwitch__selectRandom)	# get if hazard from hazard switch
forceHazard:
	lis r12, 0x806B
	ori r4, r12, 0x94EC	# MenSelMapCursorB
	cmpwi r3, 0x0
	bne+ noHazard
	ori r4, r12, 0x94EF # SelMapCursorB
noHazard:
	stb r3, 0x45(r29)	# Set hazard in unused field in muSelectStageTask
	lwz	r3, 0x204(r29)	# this->menSelmapCursorB
	%call(MuObject__changeClrAnimN)
	subic. r5, r28, 2 # Original operation
}

HOOK @ $806b6930	# muSelectStageTask::pointPointerEditList
{
	lwz	r25, 0x1C8(r24)	# Original operation
	mr r3, r25 
	lis r10, 0x806B
	ori r4, r10, 0x93F0	# MenSelmapEdit0002_TopN
	lbz r12, 0x45(r29)
	cmpwi r12, 0
	bne+ notHazard
	ori r4, r10, 0x93F3	# SelmapEdit0002_TopN
notHazard:
	%call(MuObject__changeClrAnimN)
}

op stwu r1, -0x90(r1) @ $806b626c
op stw r0, 0x94(r1) @ $806b6274
HOOK @ $806b6564	# muSelectStageTask::pointPointer
{	
	%lwd (r3, g_gfPadSystem)
	lwz r4, 0x278(r30)
	addi r5, r1, 0x40
	%call (gfPadSystem__getSysPadStatus)
	li r28, 0x0
	lwz r12, 0x44(r1)
	andi. r0, r12, 0x0040	# \ Check if L
	bne+ isL				# /
	andi. r0, r12, 0x0020	# \ Check if R
	beq- setFrame			# /
isR:
	li r28, 0x52
	b setFrame
isL:
	li r28, 0x4c
setFrame:
	lis r0, 0x4330			# \
	stw r0, 0x40(r1)		# |
	xoris r0, r12, 0x8000	# | 
	stw r0, 0x44(r1)		# | convert to input to float
	lfd f0, 0x40(r1)		# |
	lfd f1, 0x10(r29)		# |
	fsubs f1, f0, f1		# /
	lwz r3, 0x80(r30)	# this->previewMuObject
	%call (MuObject__setFrameNode)

	lwz r9, 0x244(r30)	
	lwz r10, 0x228(r30)	# get page	
	cmplwi r9, 0x36
	beq+ checkForSetHazard
	cmpwi r10, 0x2			# \ check for custom page
	beq- checkForSetHazard 	# /
	lwz r12, 0x248(r30)	# \
	cmplwi r12, 0x35	# |
	bge- dontSetHazard	# | Check if pointing to a stage
	cmplwi r9, 0x35		# |
	bge- dontSetHazard	# /
checkForSetHazard:
	lwz r12, 0x4C(r1)
	andi. r0, r12, 0x0010		# 0x0010 # Gamecube Z
	bne+ setHazard  
	rlwinm. r0, r12, 0, 10, 10	# 0x00200000	# Classic Controller ZL/ZR
	beq+ dontSetHazard 
setHazard:
	lis r8, 0x806B
	li r11, 0
	cmpwi r10, 0x2 
	bne+ dontResetPointerIndex	
	stw r11, 0x244(r30)		# reset pointer index on custom page so cursors can change colour
	b notRandom
dontResetPointerIndex:
	cmplwi r9, 0x36
	bne+ notRandom
	lbz r11, 0x46(r30)
	subi r11, r11, 0x1
	cmpwi r11, 0x1
	beq+ defaultHazards
	cmpwi r11, 0x0
	beq+ allHazards
noHazards:	
	li r11, 0x2
	ori r4, r8, 0x93B9	# Random
	b selectedRandomClr
defaultHazards:
	ori r4, r8, 0x93B0	# MenSelmapRandom
	b selectedRandomClr
allHazards:
	ori r4, r8, 0x93B3	# SelmapRandom
selectedRandomClr:
	stb r11, 0x46(r30)
	lwz r3, 0x1FC(r30)
	b changeClr
notRandom:
	lwz	r3, 0x204(r30)
	ori r4, r8, 0x94EF	# SelMapCursorB
	lbz r12, 0x45(r30)
	cmpwi r12, 0
	bne+ hazard
	li r11, 1
	ori r4, r8, 0x94EC	# MenSelMapCursorB
hazard:
	stb r11, 0x45(r30) 
changeClr:
	%call(MuObject__changeClrAnimN)
	lwz r10, 0x228(r30)		# \
	cmpwi r10, 0x2			# | check for custom page
	bne- notCustomPage 		# /
	lwz r3, 0x1FC(r30)
	lbz r12, 0x45(r30)	# get hazard setting
	lis r8, 0x806B
	ori r4, r8, 0x93B9	# Random
	cmpwi r12, 0
	bne+ changeRandomClr
	ori r4, r8, 0x93B3	# SelmapRandom
changeRandomClr:
	%call(MuObject__changeClrAnimN)
	lfs f1, 0x0(r29)	# \
	lwz r3, 0x1FC(r30)	# |
	lwz r3, 0x14(r3)	# |
	lwz r3, 0x18(r3)	# |
	lwz r12, 0x0(r3)	# | this->menSelmapRandom->modelAnim->anmObjMatClrRes->setUpdateRate(0.0)
	lwz r12, 0x28(r12)	# |
	mtctr r12			# |
	bctrl 				# /
notCustomPage:
	li r4, 0x24                 # play scroll sound
    %lwd (r3, g_sndSystem)      # \
    li r5, -0x1                 # |
    li r6, 0x0                  # | g_sndSystem->playSE(0x24, -0x1, 0x0, 0x0, -0x1);
    li r7, 0x0                  # |
    li r8, -0x1                 # |
    %call (sndSystem__playSE)   # /
dontSetHazard:

	%lwd (r12, g_muSelectStageFileTask)
	cmpwi r12, 0x0	# \ check if g_muSelectStageFileTask exists (i.e. is this MyMusic)
	beq- end		# /

	cmpwi r31, 0x35
	%lbdu (r10, r31, STAGELIST_TYPE)
	bne+ dontLoadStageBuilderStages
	lbz r11, 0x605A(r30)
	cmpwi r11, 0xff 
	bne+ dontLoadStageBuilderStages	
	cmpwi r10, 0x0
	beq+ dontLoadStageBuilderStages
	
	lbz r11, 0x58(r12)
	andi. r0, r11, 0x40
	beq+ dontLoadStageBuilderStages
	andi. r11, r11, 0xBF
	stb r11, 0x58(r12)
	lbz r11, 0x48(r12)
	andi. r11, r11, 0xBF
	stb r11, 0x48(r12)

	li r11, 0x0 
	stb r11, -0x1(r31)
	stb r11, 0x0(r31)

dontLoadStageBuilderStages:
	lwz r3, 0x228(r30)	# \
	cmplwi r3, 0x1		# | check if page 2
	bgt- end			# /
	lwz r11, 0x248(r30)
	cmpwi r11, 0x0
	blt- end
	rlwinm r0, r3, 3, 0, 28
	add r4, r30, r0
	lbz r0, 0x230(r4)
	cmplw r11, r0
	blt- loc_notCustom
	li r3, 0x29
loc_notCustom:
	%lbd (r3, CURRENT_PAGE)
	lwz r4, 0x22c(r4)
	lbzx r4, r4, r11
	%call (MuStageTblAcces_GetStageKind)
	%call (muMenu__exchangeMuStageKindToSrStageKind)
	cmpwi r28, 0x0	# \ check if holding L/R
	beq- end		# /	
	lbz r9, -0x1(r31)
	cmpw r3, r9
	bne+ changeStageList
	lbz r10, 0x0(r31)
	cmpw r10, r28
	beq- end
	
changeStageList:
	%lwd (r12, g_muSelectStageFileTask)
	lbz r10, 0x58(r12)
	andi. r0, r10, 0x40
	beq+ end
	andi. r10, r10, 0xBF
	stb r10, 0x58(r12)
	lbz r10, 0x48(r12)
	andi. r10, r10, 0xBF
	stb r10, 0x48(r12)

	stb r3, -0x1(r31)
	stb r28, 0x0(r31)

end:
	lwz r0, 0x94(r1)
}
op addi	r1, r1, 0x90 @ $806b657c

HOOK @ $806b5c60	# muSelectStageTask::buttonProc
{	
	stw	r3, 0x258(r29)	# Original operation
	lwz r10, 0x134(r1)		# get input mask
	andi. r0, r10, 0x1000	# \ Check if start is pressed
	beq+ %end% 				# /
	li r11, 0x4c			# \
	andi. r0, r10, 0x0040	# | Check if L
	bne+ displayStageList	# /
	li r11, 0x52			# \
	andi. r0, r10, 0x0020	# \ Check if R
	beq- %end%				# /
displayStageList:
	%lwd (r12, g_muSelectStageFileTask)
	cmpwi r12, 0x0	# \ check if g_muSelectStageFileTask exists (i.e. is this MyMusic)
	beq- %end%		# /
	lbz r10, 0x58(r12)					# \
	andi. r0, r10, 0x40					# | Check if loaded
	beq- notReady						# /
	lwz r0, 0x60(r12)
	cmpwi r0, 0x0
	beq+ notReady

	%lbdu (r10, r12, STAGELIST_STAGEKIND)	# \ 
	cmpw r3, r10							# | Check if loaded stagelist is same as selected stage kind
	bne+ notReady							# /
	lbz r10, 0x1(r12)
	cmpw r11, r10
	bne+ notReady
ready:
	mr r3, r29									# \
	li r4, 0x35									# | set preview to 0x35 (page button) to make preview not appear in stage builder page
	%call (muSelectStageSwitch__dispPreview)	# /
	lwz r4, 0x228(r29)		# \
	stb r4, 0x605A(r29)		# | go to stage builder 
	li r4, 0x2				# |
	%branch (0x806b5940)	# /
notReady:
	%branch (0x806b6000)
}

HOOK @ $806b1fb0	# muSelectStageTask::dispPage
{
	lwz r3, 0x1FC(r26)	# \
	cmpwi r3, 0x0		# | check if this->menSelmapRandom == NULL
	beq+ end			# /
	lis r10, 0x806B
	cmpwi r27, 2			
	beq+ isNotCustomPage
	lbz r11, 0x46(r26)
	cmpwi r11, 0x1
	beq+ defaultHazards
	cmpwi r11, 0x0
	beq+ allHazards
noHazards:	
	ori r4, r10, 0x93B9	# Random
	b changeClr
defaultHazards:
	ori r4, r10, 0x93B0	# MenSelmapRandom
	b changeClr
allHazards:
	ori r4, r10, 0x93B3	# SelmapRandom
	b changeClr
isNotCustomPage:
	ori r4, r10, 0x93B9	# Random
	lbz r12, 0x45(r26)
	cmpwi r12, 0
	bne+ changeClr
	ori r4, r10, 0x93B3	# SelmapRandom
changeClr:
	%call(MuObject__changeClrAnimN)
	lfs f1, 0x0(r16)	# \
	lwz r3, 0x1FC(r26)	# |
	lwz r3, 0x14(r3)	# |
	lwz r3, 0x18(r3)	# |
	lwz r12, 0x0(r3)	# | this->menSelmapRandom->modelAnim->anmObjMatClrRes->setUpdateRate(0.0)
	lwz r12, 0x28(r12)	# |
	mtctr r12			# |
	bctrl 				# /
end:
	lwz	r0, 0x40(r26)	# Original operation
}

HOOK @ $806b5684	# muSelectStageTask::buttonProc
{
	li r5, -1	# Original operation
	lbz r12, 0x605A(r29)	# \
	cmpwi r12, 0xff			# |
	beq+ notStagelistPage 	# | return to previous page
	lbz r4, 0x605A(r29)		# |
	stb r5, 0x605A(r29)		# |
	%branch (0x806b5940)	# /
notStagelistPage:
	%lwi(r10, STAGE_STRIKE_TABLE)   # \
    li r12, 0						# |
loopThroughStrikes:					# |
	lhzx r0, r10, r12				# |
	cmpwi r0, 0						# | check if any stages are striked
	bne+ clearStageStrikes			# |
	addi r12, r12, 0x2				# |
	cmpwi r12, 0x1e 				# |
	blt- loopThroughStrikes			# |
	b %end%							# |
clearStageStrikes:					# /
	%branch(0x806b56a0)		# Don't back out if no stages are strike				
}

HOOK @ $806b58e8	# muSelectStageTask::buttonProc
{
	lwz	r4, 0x228(r29)	# Original operation
	lbz r12, 0x605A(r29)	# \
	cmpwi r12, 0xff			# |
	beq+ %end% 				# | return to previous page
	li r12, 0xff			# |
	lbz r4, 0x605A(r29)		# |
	stb r12, 0x605A(r29)	# |
	%branch (0x806b5940)	# /
}
HOOK @ $806b0e8c	# muSelectStageTask::exit
{
	stw	r0, -0x4C78(r31)	# Original operation
	%sbdu (r0, r12, STAGELIST_TYPE)	# \ reset stagelist
	stb r0, -0x1(r12)				# /
}

HOOK @ $8003b91c	# gfCollectionIO::_processList
{
	addi r3, r1, 0x48	# Original operation
	cmpwi r25, 0x3	# \ check if retrieving stagelist
	bne+ %end%		# /
	%lbd (r10, STAGELIST_TYPE)	# \
	cmpwi r10, 0x0				# | check if not builder stagelist
	beq+ %end%					# /
	addi r3, r3, 0x1	# Mess up string so don't return custom stages from nand
}
HOOK @ $8003b944 	# gfCollectionIO::_processList
{
	addi r3, r1, 0x48	# Original operation
	cmpwi r25, 0x3	# \ check if retrieving stagelist
	bne+ %end%		# /
	%lbdu (r0, r10, STAGELIST_TYPE)
	cmpwi r0, 0x0
	beq+ %end%
	%lwi (r4, STAGELIST_FOLDER_NAME)
	subi r5, r13, 32060		# "sd:"
	%lwi (r6, MOD_FOLDER)	# /modFolderName/
	%lwi (r7, _pf)			# "pf"
	%lwd (r8, STAGE_FOLDER)	# "/stage/"
	lbz r9, -0x1(r10)	# stage slot
	%call (sprintf)
	addi r3, r1, 0x48
	%lwi (r4, STAGELIST_FILE_NAME)
	%call (strcat)
	%branch (0x8003b99c)
}
HOOK @ $8003af24	# gfCollectionIO::_processLoad
{
	addi r3, r1, 80		# Original operation
	cmpwi r24, 0x3	# \ check if retrieving stagelist
	bne+ %end%		# /
	%lbdu (r0, r10, STAGELIST_TYPE)
	cmpwi r0, 0x0
	beq+ %end%
	%lwi (r4, STAGELIST_FOLDER_NAME)
	subi r5, r13, 32060		# "sd:"
	%lwi (r6, MOD_FOLDER)	# /modFolderName/
	%lwi (r7, _pf)			# "pf"
	%lwd (r8, STAGE_FOLDER)	# "/stage/"
	lbz r9, -0x1(r10)	# stage slot
	%call (sprintf)
	%branch (0x8003af74)
}

HOOK @ $806b3a14	# muSelectStageTask::editListCompare
{
	mr r4, r31	# Original operation
	%lbd (r12, STAGELIST_TYPE)	# \
	cmpwi r12, 0x0				# | check if not builder stagelist
	beq+ %end%					# /
	mr r4, r3	# \ reverse filename comparison so it gets listed in ascending order
	mr r3, r31	# /
}
HOOK @ $806b4580	# muSelectStageTask::selectingProc
{
	lwz	r6, 0x6068(r27)		# Original operation
	%lbd (r12, STAGELIST_TYPE)	# \
	cmpwi r12, 0x0				# | check if not builder stagelist
	beq+ %end%					# /
	li r11, 0x0							# \
	stw r11, 0x6140(r27)				# | Skip waiting for loading	
	%branch (0x806b4648)				# /
}

HOOK @ $806c8f88	# scSelStage::process
{
	lwz	r0, 0x254(r3)	# Original operation
	lbz r8, 0x46(r3)	# \ 
	cmpwi r8, 0x1		# |
	blt+ allHazards		# | check if default/all hazards/no hazards
	beq+ %end%			# /
allNoHazards:
	li r11, 0x80
	b end
allHazards:
	li r11, 0x40
end:
	%sbd(r11, r10, RSS_EXDATA_BONUS)
}
HOOK @ $806c8f9c	# scSelStage::process
{
	addi r4, r30, 108	# Original operation
	%lbdu (r0, r12, STAGELIST_TYPE)	
	li r9, 0x8000					# \
	cmpwi r0, 0x4c					# | check if L stagelist
	beq- isLStagelist				# /
	li r9, 0x4000					# \ 
	cmpwi r0, 0x52					# | check if R stagelist
	bne+ %end%						# /
isRStagelist:
	li r11, 0x32
	b isNotBuilderStagelist
isLStagelist:
	li r11, 0x34
isNotBuilderStagelist:
	%sbd(r11, r10, RSS_EXDATA_BONUS)
	lwz	r10, 0x03AC(r31)
	li r11, 0x1			# \ set as normal stage
	stw r11, 0x254(r10)	# /
	lwz r11, 0x258(r10) 	# get selected id	
	add r11, r11, r9			# | set ASL_BUTTON = type + selectedid
	%swd (r11, r8, ASL_BUTTON)	# /
	lbz r11, -0x1(r12)	# \ set stagekind 
	stw r11, 0x258(r10)	# /
}

#####################################################################################
Stage Builder Files Supports Having JPEG and RGBA8 TEX0 Images [Squidgy, Kapedani]
# Allows for HD Textures since can't guarantee same JPEG decoding in game and outside
#####################################################################################
.alias memcpy 									= 0x80004338

.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro call(<addr>)
{
  %lwi(r12, <addr>)
  mtctr r12
  bctrl    
}
.macro branch(<addr>)
{
    %lwi(r12, <addr>)
    mtctr r12
    bctr
}

HOOK @ $806b8a6c	# muSelectStageFileTask::copyFileData
{
	lwz	r6, 0x10(r29) # Original operation
	lwz r12,0x0(r4)		# Get first four bytes
	%lwi(r11, 0x54455830)	# "TEX0"
	cmpw r12, r11   # \ check if TEX0
	bne+ %end%		# /
	mr r3, r6			# \
	addi r4, r4, 0x40	# | copy RGBA8
	mr r5, r7			# |
	%call(memcpy)		# /
	%branch(0x806b8a74)
}

###################################################################################
Stage Builder Files Supports Having UTF16 or UTF8 Encoded Names [Squidgy, Kapedani]
# Allows for double the stage name length
###################################################################################
.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro branch(<addr>)
{
    %lwi(r12, <addr>)
    mtctr r12
    bctr
}

op stb r3, 0xC(r29) @ $806b8a94	# Copy whole preview type byte from summary

op andi. r12, r0, 0x1 @ $806b2bf4 # use only first bit to determine preview pic setting
HOOK @ $806b2a98	# muSelectStageTask::dispEditLineData
{
	mr r4, r3	# Original operation
	lbz r12, 0xC(r4)		# \
	andi. r12, r12, 0x80	# | check if should use utf8 encoding
	beq+ %end%				# /
	lwz	r3, 0x6064(r25)	# \
	addi r5, r4, 0x20	# |
	addi r4, r26, 22	# | skip to printf
	%branch(0x806b2ab4)	# /
}

op andi. r12, r0, 0x1 @ $806b6e40 #  use only first bit to determine preview pic setting
HOOK @ $806b6db8	# muSelectStageTask::dispEditPreview
{
	mr r4, r3	# Original operation
	lbz r12, 0xC(r4)		# \
	andi. r12, r12, 0x80	# | check if should use utf8 encoding
	beq+ %end%				# /
	lwz	r3, 0x6064(r27)	# \
	addi r5, r4, 0x20	# | skip to printf
	%branch(0x806b6dd0)	# /
}


## TODO: Classic/All Star Mode ASL from certain range (use all L-alts?)
## TODO: Also investigate random substage handling with replays
## TODO: Song id in results based on costume id? also consider set sublevel based on costume?
## TODO: Investigate same song id playing during endless friendlies?
## TODO: Fix Replays always saying Home Run Contest?