############################################
SFX and Music Setting Customizer [DukeItOut]
############################################
.alias BrawlMusic_lo = 0x26F9	# Lowest ID considered Brawl music
.alias BrawlMusic_hi = 0x286B	# Highest ID considered Brawl music (Expansion music in the 0xF000+ range does not pass through here!)
.alias MusicEntrySize = 4
.alias SoundEntrySize = 4

HOOK @ $801C744C
{
	lbz r0, 0x14(r3)	# \ Set volume
	stw r0, 0x0C(r31)	# /
	lbz r0, 0x17(r3)	# \
	stw r0, 0x10(r31)	# / 
	mfcr r0		# Preserve the condition register for later!	
	lis r12, 0x801C
	andi. r5, r30, 0xFFFF
	cmplwi r5, BrawlMusic_lo;  blt SFX_behavior	# Normal SFX and voice clip banks
	cmplwi r5, BrawlMusic_hi;	bgt SFX_behavior	# Custom SFX and voice clip banks
Music_behavior:
	lwz r12, 0x7458(r12)	# \ 2 16-bit values (4 bytes) per song in the table
	li r29, MusicEntrySize	# / 	r29 is safe in this context because it gets replaced shortly after the hook
	b checkStart
SFX_behavior:
	lwz r12, 0x7454(r12)	# \ 3 16-bit values (6 bytes) per SFX in the table
	li r29, SoundEntrySize	# /		r29 is safe in this context because it gets replaced shortly after the hook
checkStart:	
	sub r12, r12, r29		# Roll back slightly to avoid missing the first entry
checkLoop:
	lhzux r4, r12, r29
	cmplwi r4, 0xFFFF;	beq notFound			# If it has reached the point where the terminator is present, it has not been found
	cmplw r4, r5;		bne checkLoop			# ID not found! Look in next entry.
	lhz r4, 2(r12)		# \ Set volume
	stw r4, 0xC(r31)	# /
	# cmpwi r4, SoundEntrySize;	bne complete		
	# Available for sound effect-specific meta data if needed in the future
	
complete:
notFound:	
	mtcr r0			# Restore condition register status for comparison!
}

op b 0xC @ $801C7450	# Have locations to place the following pointers

	.BA<-SFX_Table
	.BA->$801C7454
	.BA<-MUSIC_Table
	.BA->$801C7458
	.GOTO->Table_Skip
SFX_Table:		# Table size should be (sound effect count edited + 1) * 2 (i.e. 0 SFX = 2, 1 sound = 4, etc.)
				# SFX ID, Volume (0-127)
	uint16_t [120] |
	| #
	0x4FC, 99,  | # Luigi "Aww Yeah!"
	| #
	0x5A5, 110, | # Bowser taunt roar
	| #
	0xCF0, 105, | # Pikachu Iron Tail (Light)
	0xCF2, 110, | # Pikachu Iron Tail (Medium)
	0xCF3, 118, | # Pikachu Iron Tail (Heavy)
	| #
	0x402F, 67, | # Mewtwo Down Throw noise
	0x4030, 69, | # Mewtwo Up/Forward Throw noise
	0x408E, 75, | # Shadow Ball launch
	0x409A, 57, | # Tail Swing (strong)
	0x409C, 67, | # Tail Swing (medium)
	0x409D, 95, | # Tail Swing (light)
	0x4031, 105,| # Shadow Ball fire
	0x4033, 85, | # Up B Teleport
	0x4034, 85, | # Mid-Air Jump
	0x403D, 80, | # Air Dodge Teleport
	0x403E, 80, | # Sidestep Teleport
	0x4035, 86, | # Mewtwo Up Smash Cloud
	0x406B, 64, | # Mewtwo Hyper Beam Final Smash
	| #
	0x697, 72,  | # Marth counter clip 2 "Soko da!"
	0x698, 72,  | # Marth counter clip 3 "Mikitta!"
	0x699, 72,  | # Marth counter clip 4 "Saseru mono ka!"
	0x6A0, 75,  | # Marth "Minna, miteite kure!"	
	0x6A1, 82,  | # Marth "Let's Dance!"
	0x69B, 81,	| # Marth Up B voice clip
	0x1141, 97, | # Marth Up B sound
	| #
	0x40A6, 78, | # Roy taunt clip "Eeeeyah!"
	0x40B3, 72, | # Roy counter clip 1 "HAAAH!"
	0x40B4, 72, | # Roy counter clip 2 "Ima da!"
	0x40B5, 72, | # Roy counter clip 3 "Soko!"
	0x40D6, 80, | # Roy counter start
	0x40D7, 104,| # Roy Blazer rising
	0x40D8, 112,| # Roy Flare Blade charge starting
	0x40D5, 112,| # Roy Flare Blade charging
	0x40D9, 72, | # Roy Side Taunt Glimmer
	0x40DA, 56, | # Roy Entrance
	0x410E, 76, | # Roy Critical Hit/Counter/Final Smash
	0x40FF, 108,| # Roy sword set in victory pose 2
	| #
	0xA66, 105, | # Sonic "Knuckles, you're late!" used for 'Up' Victory Pose
	| #
	0x414D, 90, | # Knuckles "HYAH!" used for Forward Smash, Side B and Neutral B
	| #
	0xB95B, 82, | # Fountain of Dreams Tangible Star 
	0xB95C, 82, | # Fountain of Dreams Tangible Star 
	0xB95D, 79, | # Fountain of Dreams Ambiance 
	0xB95E, 24, | # Fountain of Dreams Left Pillar Ring  
	0xB95F, 25, | # Fountain of Dreams Right Pillar Ring 
	0xB960, 39, | # Fountain of Dreams Platform Fountain 
	| #
	0xBA00, 48, | # Thwomp Appearance
	0xBA01, 110,| # Thwomp Shaking
	0xBA02, 120,| # Thwomp "ARNGH"
	0xBA03, 50, | # Thwomp Woosh
	0xBA04, 60, | # Bricks Breaking
	0xBA05, 107,| # Bricks Reappearing
	0xBA06, 62, | # Lava Ambiance
	0xBA07, 108,| # Bowser Laugh
	0xBA08, 79, | # Podoboo Appearance 1
	0xBA09, 79, | # Podoboo Appearance 2
	0xBA0A, 79, | # Podoboo Appearance 3
	0xBA0B, 72, | # Podoboo Splash 1
	0xBA0C, 72, | # Podoboo Splash 2
	0xBA0D, 72, | # Podoboo Splash 3	
	| #
	0xFFFF, 0  	  # Make sure the table ends with this as a terminator!

MUSIC_Table:	# Table size should be (song count edited + 1 ) * 2 (i.e. 0 songs = 2, 1 song = 4, 2 songs = 6, 3 songs = 8, etc.)
	uint16_t [30] |
	0x27CE, 90, | # Tunnel Scene (X)
	0x2719, 90, | # Castle / Fortress Boss (SMW/SMB3)
	0x2722, 105,| # Main Theme (Super Mario 64)
	0x271B, 110,| # Main Theme (New Super Mario Bros.)
	0x27CB, 90, | # Title (3D Hot Rally)
	0x2807, 83, | # Pokémon Red & Blue Medley
	0x280E, 64, | # Pokémon Gold & Silver Medley
	0x277D, 90, | # Devil's Call in Your Heart
	0x2816, 65, | # Temple
	0x2735, 100,| # Great Temple / Temple
	0x2737, 95, | # Black Mist
	0x273F, 115,| # Gerudo Valley
	0x2736, 115,| # The Dark World
	0x273C, 100,| # Song of Storms
	0xFFFF,	0	# Make sure the table ends with this as a terminator!
Table_Skip:
	.RESET

###########################################################################################################################################################
[Project+] SoundBank Expansion System (RSBE.Ver) v3.1 [codes, DukeItOut, JOJI, Squidgy]
# v1.1 - Kirbycide Fix + Voice clips volume fix + CSS Hiccup Fix
# v1.2 - Fixes Mr. Resetti's brsar conflicts
# v2.0 - Removed Sound Resource table occupation and made dynamic to better support resource size changes
# v2.1 - Removed overaggressive check that could crash the game if a custom SFX ID played while another 
#			custom soundbank was being loaded in
# v2.2 - Made pointers even more flexible to account for potential Sound Resource changes
# v2.3 - Added a safety to prevent crashing when attempting to load a custom soundbank that failed to be found.
# v2.4 - Fixed issue where sounds could be paired with the wrong soundbanks if not played the moment they are called.
# v2.5 - Increased stability of sample check to avoid introduced error where the wrong bank was accessed sometimes.
# v3.0 - Adds support for variant soundbanks
# v3.1 - Variant soundbanks support SEQ bank access
#			# Since PSA scripts are read after module calls, you don't need to edit the .rel files!
#			# Simply call command 0A0C0100 (play SFX without 3D pos) to play within the final smash action!
#			# To suppress the .rel ID calls, the sound routine function was replaced with li r3, -1 (indicates invalid sound. Normally calls 800742B0).
#			# By sheer luck, no .rel edits are required, as only one character SEQ can play at a time and the most recent attempt at a SEQ replaces the previous.
#			# As such, you only need to add the above command with the appropriate ID.
#			# The following characters are affected: Luigi (Action 0x116), Peach (Action 0x116), Donkey Kong (Action 0x133) and Dedede (Action 0x116)
#			# Dedede already does this from the .pac file, so he did not require modification.
#			# SEQ banks and melodies for characters are still limited to the above four and clones of their banks.
#
# 90432134 references -> Sound Resource + 0x298934-to-0x29897F
# 901A3090 references -> Written to CodeFlag+0x4
# 901A30F8 references -> Written to CodeFlag+0x8
# 901A30FC references -> Written to CodeFlag+0xC
# 901A3200 size index table -> 8053ED00
###########################################################################################################################################################

.alias CustomSoundbankRange = 0x0144	# Custom soundbanks are 0x144 or higher
.alias MaxCustomBank		= 0x0244	# 0x144-to-0x243
.alias MaxBankRange			= 0x7244
.alias CustomSound_Lo		= 0x4000	# Custom sfx lower range 
.alias CustomSound_Hi 		= 0xE500	# Custom sfx upper range 
.alias normalMusic_Lo		= 0x26F9	# Brawl music lower range
.alias normalMusic_Hi		= 0x286B	# Brawl music upper range
.alias MrResettiBank		= 2			# What it expects if this is Mr. Resetti's special brsar
.alias PointerBlock			= 0x8053ED00
.alias TableBlockPtr		= 0x801C75A4

	.BA<-TablePointer
	.BA->$801C75A4
	.GOTO->SkipTable

CodeFlag:
	word[4] 0, 0, 0, 0	# Turned into C0DE, two indexes and a blank space if initialized correctly
TablePointer:
	word[18] |				# Table 1 (0x48 bytes)
	0x01B872A0, 0x0000B720, |
	0x01B57540, 0x000CC1A0, |
	0x01000000, 0x000E3C94, |
	0x00000002, 0x01000000, |
	0x000E3CA8, 0x01000000, |
	0x000E3CC0, 0x00004321, |
	0x00003460, 0x00000000, |
	0x00003460, 0x000082C0, |
	0x00100000, 0x00001234	

	word[18] |				# Table 2 (0x48 bytes) (offset 0x48)
	0x000041C3, 0x60000000, |
	0x00000002, 0x01000000, |
	0x00084090, 0x2E400300, |
	0x01030000, 0x00084080, |
	0x00000000, 0x00000000, |
	0x00000000, 0x00000000, |
	0x00000001, 0x40000000, |
	0x00000000, 0x00000005, |
	0x01800000, 0x00000000	
	
	word[18] |				# Table 3 (0x48 bytes) (offset 0x90)
	0x00004194, 0x70000000, |
	0x00000002, 0x01000000, |
	0x00042CD8, 0x3E400300, |
	0x01030000, 0x00042CC8, |
	0x00000000, 0x00000000, |
	0x00000000, 0x00000025, |
	0x00000001, 0x40000000, |
	0x00000000, 0x00000005, |
	0x01800000, 0x00000000	
	
	word[10] |				# Table 4 (0x28 bytes) (offset 0xD8)
	0x00003460, 0x00053A80, |
	0xFFFFFFFF, 0x00000000, |
	0x00000000, 0x01000000, |
	0x000CFE0C, 0x00000001, |
	0x01000000, 0x000CFE18	
	
	word[10] |				# Table 5 (0x28 bytes) (offset 0x100)
	0x000082C0, 0x00078340, |
	0xFFFFFFFF, 0x00000000, |
	0x00000000, 0x01000000, |
	0x000D4FDC, 0x00000001, |
	0x01000000, 0x000D4FE8
	
.alias Table1Size = 0x48
.alias Table2Size = 0x48
.alias Table3Size = Table2Size	
.alias Table4Size = 0x28
.alias Table5Size = Table4Size
.alias Table2Offset = Table1Size
.alias Table3Offset = Table2Size + Table2Offset
.alias Table4Offset = Table3Size + Table3Offset
.alias Table5Offset = Table4Size + Table4Offset	
	
SkipTable:
	.RESET

HOOK @ $801C75A0
{
	addi r1, r1, 0x20 # Original operations, making room for pointer to tables
	blr
}

#### Treats the Soundbank Count as the custom range for the normal brsar ####
HOOK @ $801C7BD8 # Important! Expands bank table!
{
  cmpwi r3, MrResettiBank; beq %END%
  li r3, MaxBankRange+1 
}
op NOP @ $801CA2E0 # Goes into the above on bank load, but we don't want to modify the boot process more than adding one bank!
HOOK @ $801C9784
{
  cmpwi r0, MrResettiBank; beq %END%
  # li r0, MaxBankRange
  lis r0, 0x1000	# 0x0FFFxxxx max clone size  
}
HOOK @ $801C98D0
{
  cmpwi r0, MrResettiBank; beq %END%
  # li r0, MaxBankRange
  lis r0, 0x1000	# 0x0FFFxxxx max clone size
}
HOOK @ $801CA2F8
{
  cmpwi r0, MrResettiBank; beq %END%
  # li r0, MaxBankRange
  lis r0, 0x1000	# 0x0FFFxxxx max clone size
}
# HOOK @ $801CA420 # Unloading bank
# {
#   cmpwi r0, MrResettiBank; beq %END%
#   li r0, MaxBankRange
# }
# HOOK @ $801CA474 # Unloading wave data
# {
#   cmpwi r0, MrResettiBank; beq %END%
#   li r0, MaxBankRange
# }
HOOK @ $801C78EC # Check if bank to load is valid
{
  cmpwi r0, MrResettiBank; beq %END%
  lis r0, 0x1000	# 0x0FFFxxxx max clone size
}

###################################
.macro mimicSnd(<reg>)
{
  rlwinm r0, <reg>, 3, 0, 28	# Original operation
  cmplwi <reg>, CustomSound_Lo;  blt- %END%
  li r4, 0x270F					# \ Mimic Sound 0x270F
  rlwinm r0, r4, 3, 0, 28		# /
}
.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
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
###################################
.alias ActiveExpansionBankMax = 40 	# Amount of custom banks allowed to be active at a time	(unlikely to ever be hit)
/*
Dictonary Element Size = 0x108

0x00 - SoundbankID
0x04 - Group Data
0x08 - Group Wave Data
0x0C - Sound Group Info (size 0x14)	# \ See HOOK $801C7A8C
0x20 - Voice Group Info (size 0x14)	# /
0x34 - Sound Group Info (size 0x14)	# \ Second set of banks for dual characters (Zelda-Sheik, Samus, Bowser, Wario)
0x48 - Voice Group Info (size 0x14)	# / and SEQ characters (Peach, Luigi, DK, Dedede)
0x5C - Sound Data (size 0xAC) (0x4C + bankcount * 0x20. Max assumed count 4)
*/	
HOOK @ $80003FEC
{
	# r3 = (normal) block pointer
	# r4 = soundbank ID
	mr r11, r3
	mr r12, r4 
	%lwi(r3,PointerBlock)
	lwz r3, -8(r3)	
	
	li r5, 40	# Max times to loop
	mtctr r5
	li r5, 0
	li r0, -1
lookupLoop:
	mulli r4, r5, 0x108	# Each dictionary element is of size 0x84 and leads with a bank ID
	lwzx r6, r3, r4
	cmpw r6, r12		# See if it's the soundbank
	beq found
	cmpwi r6, 0; bne+ notFirstFree
	cmpwi r0, -1; bne+ notFirstFree
	mr r0, r4		# Note first offset where there is no info
notFirstFree:
	addi r5, r5, 1
	bdnz+ lookupLoop
	add r3, r3, r0		# Return first address free in case trying to write!
	blr
found:
	add r3, r3, r4		 # Return address that was located at!
	blr
}
###################################
HOOK @ $801C7918 # Copy original equivalent to expansion banks if need be
{
	mr r31, r30			# r31 gets written to later. Now holds soundbank ID.
	mr r30, r3			# Original operation
	cmpwi r31, 0x144	# \ 
	blt+ %END%			# / Only modify custom bank data!
	mr r4, r31
	bla 0x3FEC			# Find new slot or existing if already utilized
	stw r31, 0x00(r3)	# Write bank ID to slot
	addi r3, r3, 0x5C	# Address to write to
	mr r4, r30			# Data to copy
	lwz r5, 0x28(r30)	# Bank Count
	lwz r0, 0x28(r3)	# \ Bank Count in Copy (Should be blank the first time)
	cmpwi r0, 0			# | Don't copy if already copied!
	bne+ %END%			# /
	mulli r5, r5, 0x20	# Amount per bank to add (1 bank = 0x4C, 2 = 0x6C, 4 = 0xAC, etc.)
	addi r5, r5, 0x2C	# Byte count to move
	bla 0x4338			# memcpy
}
HOOK @ $801C7A2C		# Get copy when playing a sound if high enough bank
{
	cmpwi r29, 0x144
	blt+ end
	mr r4, r29
	bla 0x3FEC
	addi r3, r3, 0x5C
end:
	mr r4, r3			# Original operation
}
###################################
op andi. r4, r29, 0xFFFF @ $801C9A40 # Loop sound type info 
HOOK @ $801C7900
{
  andi. r5, r30, 0xFFF
  # mr r5, r30
  rlwinm r0, r5, 3, 0, 28	# r5 where Brawl was r30
  cmplwi r5, CustomSoundbankRange;  blt- %END%
  li r0, CustomSoundbankRange
  rlwinm r0, r0, 3, 0, 28
}
# op rlwimn r0, r29 3, 0, 28 @ $801CA30C # Normally gated 0, 28 instead of 0. 
HOOK @ $801CA314
{
  # andi. r5, r29, 0xFFF
  
  cmplwi r29, CustomSoundbankRange;  blt- Normal
  li r0, 0
  b %END%
Normal:  
  lwz r0, 4(r3)			# Original operation
}
#### During sound initialization
HOOK @ $80079F90	
{
	%lwi(r4,PointerBlock)
	addi r5, r31, 0x474	# Beginning of soundbank allocations
	stw r5, -0x4(r4)	# Store to 8053ECFC
	mr r4, r3		# Original operation
}
HOOK @ $8007A194
{
	%lwi(r27,PointerBlock)	
	li r3, 5		# Sound Heap (5)
	li r4, 0x2800	# block size needed is 0x28 * 0x100
	bla 0x0249E4
	stw r3, -0x8(r27)
	
	li r4, 0xA00	# 0x2800 / 4
	subi r3, r3, 4	# Done so that the below clears the right area.
	mtctr r4
	li r4, 0
clearLoop:
	stwu r4, 4(r3)
	bdnz+ clearLoop
	
	li r0, 0 # Original operation
}
### Soundbank address info
HOOK @ $801C7A00
{
  %lwd(r4,TableBlockPtr)
  lis r0, 0x0;  ori r0, r0, 0xC0DE
  # stw r0, 0(r4)
  stw r0, -0xC(r4)
  lwz r0, 0(r3)						# Original operation
  andi. r5, r29, 0xFFF # Filter out alt bank info!
  cmplwi r5, CustomSoundbankRange  
  blt- %END%
  cmpwi r0, MrResettiBank; beq %END%  
  li r0, MaxCustomBank
}
op cmplw r5, r0 @ $801C7A04
HOOK @ $801C7A14
{
  rlwinm r0, r5, 3, 0, 28		# Original operation but modified to only account for alt bank info
  cmplwi r5, CustomSoundbankRange;  blt- %END%
  li r0, CustomSoundbankRange
  rlwinm r0, r0, 3, 0, 28
}
### Sound Data
HOOK @ $801C7C2C
{
  andi. r5, r31, 0xFFFF
  lwz r0, 0(r3)		# Original operation.  Get anticipated sound range.
  cmplwi r5, CustomSound_Lo;  blt- %END%
  cmplwi r5, CustomSound_Hi;  bgt+ %END%

  li r0, 0xE5				# \ E500: CustomSound_Hi
  rlwinm r0, r0, 8, 0, 31	# /
}
op cmplw r5, r0 @ $801C7C30
HOOK @ $801C7C4C
{
  rlwinm r0, r31, 3, 13, 28		# Original operation but filtering high half out to account for clone banks
  andi. r5, r31, 0xFFFF
  cmplwi r5, CustomSound_Lo;  blt- %END%
  li r4, 0x270F					# \ Mimic Sound 0x270F
  rlwinm r0, r4, 3, 0, 28		# /
}
### 3D positional data
HOOK @ $801C74EC
{
  lwz r0, 0(r3)			# Original operation. Get anticipated sound range.
  andi. r5, r30, 0xFFFF
  cmplwi r5, CustomSound_Lo;  blt- %END%
  
  li r0, 0xE5				# \ E500: CustomSound_Hi
  rlwinm r0, r0, 8, 0, 31	# /
}
HOOK @ $801C750C
{
  rlwinm r0, r30, 3, 13, 28	# Original operation but filtering high half out to account for clone banks
  andi. r5, r30, 0xFFFF
  cmplwi r5, CustomSound_Lo;  blt- %END%
  li r4, 0x270F					# \ Mimic Sound 0x270F
  rlwinm r0, r4, 3, 0, 28		# /
}
HOOK @ $801C7570
{
  cmplwi r30, CustomSound_Lo;  blt- loc_0x10
  
  %lwd(r3,TableBlockPtr); addi r3, r3, Table2Offset+0x3C
loc_0x10:
  lwz r0, 0(r3)			# Original operation
}
###
HOOK @ $801CA384	# Loading groups within a bank and writing the two addresses to data info for that bank.
{					# Contains dictionary lookup
	cmplwi r29, 0x144
	blt+ normal
	
	mr r8, r3
	mr r4, r29
	bla 0x3FEC		# Expansion Bank Lookup
	stw r8, 4(r3)	# Normal data
	lwz r4, 8(r1)
	stw r4, 8(r3)	# Wave data

	lis r12, 0x801C			# \
	ori r12 r12, 0xA3AC		# | Skip normal writing process!
	mtctr r12				# |
	bctr 					# /
normal:
	rlwinm r0, r29, 3, 0, 28	# Original operation
}
# 801ca480 is not written to because we're relying on the below, unlike the previous implementation
# Contains dictionary lookup
HOOK @ $801CA42C # Unloading a bank.
{
	cmpwi r0, 2; beqlr-				# If it isn't the normal brsar, bail!
HandleExpansionDictionary:	
	li r10, 0
	li r11, 0	
	%lwi(r8,PointerBlock)	
	lwz r8, -8(r8)
	
DictionaryLoop:		
	mulli r10, r10, 0x108	# size of dictionary object to use
	
	add r9, r8, r10
	lwz r7, 0x4(r9)
	cmpw r4, r7
	bne continue
	
	li r10, 66				# 0x108 / 4
	mtctr r10
	li r10, 0
	li r8, 0
	lwz r12, 0x0(r9)		# for debugging purposes, place bank ID in r12!
clearLoop:
	stwx r8, r9, r10		# clear data!
	addi r10, r10, 4
	bdnz+ clearLoop
	blr
continue:		
	addi r11, r11, 1
	cmpwi r11, ActiveExpansionBankMax
	blt+ DictionaryLoop
	blr		# Original operaton
}


HOOK @ $801C9798	# File Data Sound Access 
{
	rlwinm. r0, r29, 16, 16, 31
	beq+ normal
	bla 0x3FEC			# Expansion Bank Lookup
	lwz r4, 8(r1)		# Get soundbank ID (see 801c9770)
	li r0, 0
	b %END% 
normal:
	rlwinm r0, r4, 3, 0, 28	# Original operation, uses soundbank to get 0x8-sized object offset
}
HOOK @ $801C98E4	# Wave Data Sound Access
{
	rlwinm. r0, r29, 16, 16, 31
	beq+ normal
	mr r31, r4
	bla 0x3FEC			# Expansion Bank Lookup
	mr r4, r31
	li r0, 0
	b %END% 
normal:
	rlwinm r0, r4, 3, 0, 28	# Original operation, uses soundbank to get 0x8-sized object offset
}

# Manipulate custom banks into accessing a new table
HOOK @ $801C7A8C
{
  lwz r4, 0(r1)
  lwz r4, 8(r4)
  cmpwi r4, CustomSoundbankRange; blt+ Normal
  
  # rlwinm r4, r29, 0, 8, 31	# Filter out top byte being used for SFX-Voice identification elsewhere!
  bla 0x3FEC
  addi r3, r3, 0xC
  mulli r4, r30, 0x14
  add r3, r3, r4
Normal:
	cmpwi r3, 0 # Original operation
}
### More Sound Info Data
HOOK @ $801C73CC
{  
  mr r6, r3 # We need to keep this
  lwz r5, 0x28(r29)
  lbz r3, 0x20(r5)
  lwz r4, 0x24(r5)
  bla 0x1D3698
  addi r4, r3, 0xA20	# 0x144 * 8 = 0xA20
  lbz r3, 4(r4)			# Normally 1 for "Indirect". 0 is "Direct"
  lwz r4, 8(r4)			# Normally E3C6C
  lwz r5, 0x28(r29)
  bla 0x1D3698			# Gets pointer info for bank 144
  addi r8, r3, 0x10		# Desired Offset: E3C7C (E3C6C+10)
  %lwd(r4,TableBlockPtr); lwz r0, -0xC(r4) 
  
  andi. r5, r30, 0xFFFF # Filter sound ID # TODO: Be careful!
  
  cmplwi r0, 0xC0DE;  bne- loc_0x68
  lwz r0, 0x18(r8); cmpwi r0, 2; beq- loc_0x68 # Can corrupt soundbanks if initialized more than once!
  # r4 has pointer to Table 1
  
loc_0x24:
  lwz r0, 0(r4);  cmplwi r0, 0x4321;  beq- loc_0x40	
  stw r0, 0(r8)
  addi r4, r4, 0x4
  addi r8, r8, 0x4
  b loc_0x24

loc_0x40:
  lwz r0, 4(r4)
  stw r0, 8(r8)
  lwz r0, 8(r4)
  stw r0, 20(r8)
  lwz r0, 12(r4)
  stw r0, 28(r8)
  lwz r0, 16(r4)
  stw r0, 32(r8)
  lwz r0, 20(r4)
  stw r0, 40(r8)

loc_0x68:
  cmplwi r5, normalMusic_Lo;  blt- loc_0x84		# Branch if a normal sound effect
  lis r0, 0x0;  ori r0, r0, 0xC0DE
  %lwd(r4,TableBlockPtr)
  stw r0, -0xC(r4)

loc_0x84:
  mr r3, r6			# restore r3
  lwz r0, 0(r3)		# Original operation
  cmplwi r5, CustomSound_Lo;  blt- %END%		# TODO: Probably need to set upper bound so music can read this
  li r0, 0xE5				# \ E500: CustomSound_Hi
  rlwinm r0, r0, 8, 0, 31	# /
}
op cmplw r5, r0 @ $801C73D0
HOOK @ $801C73EC
{
  andi. r5, r30, 0xFFFF  # Filter sound ID
  
  rlwinm r0, r5, 3, 13, 28	# r5 instead of Brawl's r30 and filtering out top half
  cmplwi r5, CustomSound_Lo;  blt- %END%
  li r4, 0x270F					# \ Mimic Sound 0x270F
  rlwinm r0, r4, 3, 0, 28		# /
}
HOOK @ $801C742C
{
  andi. r5, r30, 0xFFFF # Filter sound ID
  
  lwz r4, 4(r3)			# Original operation
  cmplwi r5, CustomSound_Lo;  blt- finish
  cmplwi r5, CustomSound_Hi;  bge- %END%

  subi r3, r5, 0x3F5B 	# TODO: Add GCTRM support for minus on offsets subi r3, r30, CustomSound_Lo-0xA5
  li r4, 0x143 			# li r4, CustomSoundbankRange-1
bankLoop:  
  subi r3, r3, 0xA5
  addi r4, r4, 1
  cmpwi r3, 0xA5; bge+ bankLoop
  mr r0, r4	# True soundbank ID
  
  cmpwi r3, 0x2F	# See if the range is 4000-402E (Voice) or 402F-40A4 (SFX)
  
  %lwd(r3,TableBlockPtr)
  addi r3, r3, Table2Offset	# Table 2

  bge- isSFX
isVoice:
  addi r3, r3, Table2Size	# Table 3
isSFX:
  lwz r4, 4(r3)
  add r4, r4, r0	# force to be 0x6000+Soundbank if SFX or 0x7000+Soundbank if Voice
finish:
  rlwimi r4, r30, 0, 4, 15 # Pass the bank info digits of the sound ID. This is being referenced for clone info!
}
### Sound Typing
HOOK @ $801C72D0
{
  andi. r5, r31, 0xFFFF # Filter sound ID
  
  lwz r0, 0(r3)			# Original operation
  cmplwi r5, CustomSound_Lo;  blt- %END%
  li r0, 0xE5				# \ E500: CustomSound_Hi
  rlwinm r0, r0, 8, 0, 31	# /
}
HOOK @ $801C72F0
{
  rlwinm r0, r5, 3, 0, 28	# r5 instead of Brawl's r31
  cmplwi r5, CustomSound_Lo;  blt- %END%
  li r4, 0x270F
  rlwinm r0, r4, 3, 0, 28
}
HOOK @ $801C7318
{
  andi. r5, r31, 0xFFFF # Filter sound ID
  cmplwi r5, CustomSound_Lo;  blt- loc_0x10

  %lwd(r3,TableBlockPtr); addi r3, r3, Table2Offset # Table 2
loc_0x10:
  lbz r0, 0x16(r3)		# Original operation
}
### Sound Info
HOOK @ $801C8050
{
  andi. r5, r31, 0xFFFF # Filter sound ID
  
  lwz r0, 0(r3)			# Original operation
  cmplwi r5, CustomSound_Lo;  blt- %END%
  li r0, 0xE5				# \ E500: CustomSound_Hi
  rlwinm r0, r0, 8, 0, 31	# /
}
op cmplw r5, r0 @ $801C8054
HOOK @ $801C8074
{
  rlwinm r0, r5, 3, 13, 28	# Original operation but filtering out high half to account for clone banks
  cmplwi r5, CustomSound_Lo;  blt- %END%
  li r4, 0x270F
  rlwinm r0, r4, 3, 0, 28
}
HOOK @ $801C80A8
{
  andi. r5, r31, 0xFFFF
  cmplwi r5, CustomSound_Lo;  blt- loc_0x18 # min sound ID
  cmplwi r5, CustomSound_Hi;  bge- loc_0x18 # max sound ID

  %lwd(r3,TableBlockPtr); addi r3, r3, Table2Offset # Table 2
loc_0x18:
  lwz r4, 0x18(r3)	# Original operation
}
### File Data
op lis r0, 0x8000 @ $801C7CF4 # If r30 is a pointer, it's related to music
HOOK @ $801C7D08
{
  rlwinm r5, r30, 16, 16, 23
  cmplwi r5, 0x6000;  blt- loc_0x24;  li r4, 0x275;  rlwinm r0, r4, 3, 0, 28
  cmplwi r5, 0x7000;  blt- loc_0x28;  li r4, 0x105;  rlwinm r0, r4, 3, 0, 28
  b loc_0x28

loc_0x24:
  rlwinm r0, r30, 3, 13, 28		# Original operation

loc_0x28:
  mr r31, r30

}
HOOK @ $801C7D34
{
  rlwinm r5, r31, 16, 16, 23
  cmplwi r5, 0x6000;  blt- loc_0x20
  %lwd(r3,TableBlockPtr); addi r3, r3, Table5Offset # Table 5
  cmplwi r5, 0x7000;  blt- loc_0x1C
  subi r3, r3, Table4Size # Table 4
loc_0x1C:
  mr r30, r3

loc_0x20:
  lbz r3, 0x14(r3)	# Original operation
}
### File Offset. Abuses soundbank ID by making it appear to be 6xxx (SFX) or 7xxx (Voice)
HOOK @ $801C7DF8
{
  # cmplwi r29, 0x6000;  blt- loc_0x10
  lis r0, 0xF000
  # b %END%

loc_0x10:
  # lwz r0, 0(r3)		# Original operation
}
HOOK @ $801C7E0C
{
  rlwinm r6, r29, 0, 16, 31
  rlwinm r5, r29, 16, 16, 23
  cmplwi r5, 0x6000;  blt- loc_0x24;  li r4, 0x275;  rlwinm r0, r4, 3, 0, 28
  cmplwi r5, 0x7000;  blt- %END%;     li r4, 0x105;  rlwinm r0, r4, 3, 0, 28
  b %END%

loc_0x24:
  rlwinm r0, r6, 3, 0, 28	# Original operation but with r6 instead of r29
}
HOOK @ $801C7E38
{
  rlwinm r5, r29, 16, 16, 23
  cmplwi r5, 0x6000;  blt- loc_0x20
  %lwd(r3,TableBlockPtr); addi r3, r3, Table5Offset # Table 5
  cmplwi r5, 0x7000;  blt- loc_0x1C
  subi r3, r3, Table4Size # Table 4

loc_0x1C:
  mr r4, r3

loc_0x20:
  lbz r3, 0x14(r3)	# Original operation
}
HOOK @ $801C7E94
{
  rlwinm r5, r29, 16, 16, 23
  lwz r0, 0(r3)		# Original operation
  cmplwi r5, 0x6000;  blt- finish
  
  %lwd(r4,TableBlockPtr); lwz r0, -0x8(r4)
  
  rlwinm r4, r29, 0, 16, 31

loc_0x28:
  cmplw r4, r0;  beq- finish
  mr r0, r4
finish:
  rlwimi r0, r29, 28, 8, 19 # Transfer 0x10000-0xFFF0000 to 0x1000-0xFFF000
}
HOOK @ $801C7E9C
{
  lwz r0, 4(r3)	# Original operation
  rlwinm r5, r29, 16, 16, 23
  cmplwi r5, 0x6000;  blt- loc_0x10
  li r0, 0x1

loc_0x10:
  cmplwi r5, 0x7000;  blt- %END%
  li r0, 0x0
}
### Wave Sound Info
HOOK @ $801C76E4
{
  lwz r4, 0(r3)		# Original operation
  andi. r5, r29, 0xFFFF # Filter out the X0000 digit that is used for alt banks!
  cmplwi r5, CustomSound_Lo;  blt- %END%
  
  stwu r1, -0x10(r1)
  stw r14, 4(r1)
  stw r15, 8(r1)
  stw r16, 0xC(r1)
  
  li r14, CustomSound_Lo		# Bottom section of expansion bank
  li r15, CustomSound_Lo+0x2F	# Border between voice and regular SFX
  li r16, CustomSound_Lo+0xA5 	# Top section of expansion bank

loc_0x28:
  cmplw r5, r16;  bge- loc_0x48
  sub r4, r5, r15
  cmplw r5, r15;  bge- loc_0x58
  sub r4, r5, r14
  cmplw r5, r14;  bge- loc_0x58

loc_0x48:
  addi r14, r14, 0xA5		# \
  addi r15, r15, 0xA5		# | Loop upwards one soundbank (all expansion banks have 0xA5 IDs)
  addi r16, r16, 0xA5		# /
  b loc_0x28

loc_0x58:
  lwz r14, 4(r1)
  lwz r15, 8(r1)
  lwz r16, 0xC(r1)
  lwz r1, 0(r1)
}
###
# Don't clone item or stage SEQ files the way the below does! Use normal stage soundbank clones that keep the bank ID!!!
# The below is ONLY for the 4 final smash seq files in Brawl and banks cloned from them.
HOOK @ $801CA4DC # SEQ notation interpretor
{
	lwz r4, 4(r31)	# Original operation. Get sound ID of playing SEQ
	andis. r0, r4, 0xFFFF # See if it is a cloned ID. Those use the high half to indicate this.
	beq+ %END%		# If not, behave normally!
	andi. r0, r4, 0xFFFF	# Get ID it normally would be interpreted as.
	
	cmpwi r0, 0x1B49; 	blt+ %END%	# Behave normally if not a fighter SEQ!
						bne+ notDededeSeq
	li r5, 394  # Dedede bnk data (Matches BankFile ID in brsar. Use BrawlCrate to see. snd/bnk/)
notDededeSeq:	
	cmpwi r0, 0x1B4A; bne+ notPeachSeq
	li r5, 452	# Peach bnk data 
notPeachSeq:
	cmpwi r0, 0x1B4B; bne+ notDonkeySeq
	li r5, 188 # Donkey Kong bnk data
notDonkeySeq:
	cmpwi r0, 0x1B4C; bgt+ %END% 	# Behave normally if not a fighter SEQ!
					  bne+ notLuigiSeq
	li r5, 176 # Luigi bnk data
notLuigiSeq:
	rlwimi r5, r4, 0, 4, 15	# Filter bank ID and tack it onto expected index
	stw r5, 8(r1)	# We need this! 8(r1) gets used later
	lis r12, 0x801C
	ori r12, r12, 0xA51C
	mtctr r12
	bctr				# Brute force that we obtained bank info written to 8(r1)!
}
###
HOOK @ $801CA63C # Prevents crash when attempting to play a sound that is not loaded.
{
	addi r3, r1, 8		# Operation being replaced below
	lwz r5, 4(r3)		# \ Check if the soundbank is STILL uninitialized
	cmpwi r5, 0			# / after initialization. This means it was not found!
	mr r5, r29			# Original operation.
}
op beq- 0x10 @ $801CA640

* E0000000 80008000

#TODO: op andi. r5, r9, 0xFFFF @ $80074F60 for "language modification????"
# op nop @ $80078068
# Check how it works in the base game to support PAL (EU) language switching.
# Not relevant for Brawl versions other than European so not implemented for now.

############################################
Hitbox Sound Effect Change System v2.1 [Eon]
############################################
#hitbox flags sfx 29, 30 and 31 point to ra-basic[8],ra-basic[9],ra-basic[10], and then flag 12 plays all three sounds at once, reading from same 3 ra's (0 = no sound)
#hitbox sfx flag is specifically mapped to 0x00003E00 of hitbox flags
#formulas to stick into wolfram alpha to set id as you want : 
#   (0x<originalhitboxflag> bitwise and 0xFFFFC1FF) + (29 << 9) = new flag with sfx id 29, replace the 29 with 30 or 31 if you want them
#
#example - falcon punches original hitbox flag was 29030485, so putting into wolfram alpha
#(0x29030485 bitwise and 0xFFFFC1FF) + (30 << 9) gives me 29033c85, so that is the hitbox flag if i wanted to have that hitbox read ra-basic[9] for its sfx id
############################################
.macro playSound(<soundRegister>) 
{
  mr r4, <soundRegister>  #sound id
  mr r3, r29 #sound module
  li r5, 0 
  li r6, 0
  li r7, 0
  lwz r12, 0x0(r3)
  lwz r12, 0x1C(r12)
  mtctr r12
  bctrl #play sound  
}
.macro readRA(<arg>)
{
  mr r3, r31
  lis r4, 0x2000 #RA-Basic
  or r4, r4, <arg>
  lis r12, 0x8079
  ori r12, r12, 0x76D8
  mtctr r12
  bctrl
}

HOOK @ $80762040
{
  rlwinm r0, r0, 7, 27, 31
  cmpwi r0, 12
  beq customSound
  cmpwi r0, 28
  ble end
customSound:
  lis r12, 0x8002
  ori r12, r12, 0xE30C
  mtctr r12
  bctrl #getInstance/[gfTaskScheduler]

  #get task id's from hit log entry
  lbz r4, 0x22(r31)
  lwz r5, 0x0C(r31)
  lis r12, 0x8002
  ori r12, r12, 0xF018
  mtctr r12
  bctrl #getTaskById/[gfTaskScheduler] #gets the attackers main index 
  mr r31, r3
  lwz r5, 0x34(r30)
  rlwinm r5, r5, 7, 27, 31
  cmpwi r5, 12
  beq allThree

  #select which ra-basic to read based on hitbox sound flag
  subi r5, r5, 21 #29 -> 8, 30 -> 9, 31 -> 10 
  %readRA(r5)
  %playSound(r3)
  cmpw r3, r3
  b %end%
allThree:
  li r5, 8
  %readRA(r5)
  cmpwi r3, 0
  beq skipOne
  %playSound(r3)
skipOne:
  li r5, 9
  %readRA(r5)
  cmpwi r3, 0
  beq skipTwo
  %playSound(r3)
skipTwo:
  li r5, 10
  %readRA(r5)
  cmpwi r3, 0
  beq skipThree
  %playSound(r3)
skipThree:
  cmpw r3, r3
  b %end%
    
end:
  cmpwi r0, 0
}

#########################################################################
[Project+] Expansion sawnd characters are mute while metal V2 [DukeItOut]
#
# V2: Added clone bank support
#########################################################################
HOOK @ $80077EA0
{
	andi. r4. r4. 0xFFFF # Filter sfx clones
	andi. r3, r3, 0xFFF	 # Filter bank clones
	cmpwi r3, 38	# Original operation
}
HOOK @ $80077EA4
{
	ble %END%
	cmpwi r3, 0x144; bge- %END%		# Is it an expansion bank? Then it's probably for a character.
	cmpwi r3, 0x26;	ble+ %END%		# 0x01-0x26 are for normal character soundbanks
	lis r12, 0x8007
	ori r12, r12, 0x7FC4
	mtctr r12
	bctr
}
HOOK @ $80077EB4
{
  lwzx r0, r5, r6	# Original operation
  cmplwi r3, 0x144;  blt+ %END%		# If less than this, it knows how to get the metal status
  cmpwi r4, 0x4000;	 blt+ sfxClip	# They're probably playing a global sound effect if it is less than this!
  subi r12, r4, 0x4000	# \
  subi r8, r3, 0x144	# | All of these banks use similar formatting, so exploit this!
  mulli r8, r8, 0xA5	# | 
  sub r12, r12, r8		# /
  cmpwi r12, 0x2E; bgt+ sfxClip		# 2F-A4 in a bank are normal SFX IDs, not voice clips!
voiceClip:
 li r3, 1; blr
sfxClip:
 li r3, 0; blr
}