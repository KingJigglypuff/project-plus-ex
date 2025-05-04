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
	cmplwi r30, BrawlMusic_lo;  blt SFX_behavior	# Normal SFX and voice clip banks
	cmplwi r30, BrawlMusic_hi;	bgt SFX_behavior	# Custom SFX and voice clip banks
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
	cmplw r4, r30;		bne checkLoop			# ID not found! Look in next entry.
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
[Project+] SoundBank Expansion System (RSBE.Ver) v2.4 [codes, DukeItOut, JOJI]
# v1.1 - Kirbycide Fix + Voice clips volume fix + CSS Hiccup Fix
# v1.2 - Fixes Mr. Resetti's brsar conflicts
# v2.0 - Removed Sound Resource table occupation and made dynamic to better support resource size changes
# v2.1 - Removed overaggressive check that could crash the game if a custom SFX ID played while another 
#			custom soundbank was being loaded in
# v2.2 - Made pointers even more flexible to account for potential Sound Resource changes
# v2.3 - Added a safety to prevent crashing when attempting to load a custom soundbank that failed to be found.
# v2.4 - Fixed issue where sounds could be paired with the wrong soundbanks if not played the moment they are called.
#
# 90432134 references -> Sound Resource + 0x298934-to-0x29897F
# 901A3090 references -> Written to CodeFlag+0x4
# 901A30F8 references -> Written to CodeFlag+0x8
# 901A30FC references -> Written to CodeFlag+0xC
# 901A3200 size index table -> 8053ED00
###########################################################################################################################################################

.alias CustomSoundbankRange = 0x0144	# Custom soundbanks are 0x144 or higher
.alias MaxCustomBank		= 0x0244	# 0x144-to-0x243
.alias CustomSound_Lo		= 0x4000	# Custom sfx lower range 
.alias CustomSound_Hi 		= 0xE500	# Custom sfx upper range 
.alias normalMusic_Lo		= 0x26F9	# Brawl music lower range
.alias normalMusic_Hi		= 0x286B	# Brawl music upper range
.alias MrResettiBank		= 2			# What it expects if this is Mr. Resetti's special brsar

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
	0x000041C3, 0x00006000, |
	0x00000002, 0x01000000, |
	0x00084090, 0x2E400300, |
	0x01030000, 0x00084080, |
	0x00000000, 0x00000000, |
	0x00000000, 0x00000000, |
	0x00000001, 0x40000000, |
	0x00000000, 0x00000005, |
	0x01800000, 0x00000000	
	
	word[18] |				# Table 3 (0x48 bytes) (offset 0x90)
	0x00004194, 0x00007000, |
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
	
	
SkipTable:
	.RESET

HOOK @ $801C75A0
{
	addi r1, r1, 0x20 # Original operations, making room for pointer to tables
	blr
}

#### Treats the Soundbank Count as the custom range for the normal brsar ####
HOOK @ $801C7BD8
{
  cmpwi r3, MrResettiBank; beq %END%
  li r3, MaxCustomBank+1 
}
HOOK @ $801C9784
{
  cmpwi r0, MrResettiBank; beq %END%
  li r0, MaxCustomBank  
}
HOOK @ $801C98D0
{
  cmpwi r0, MrResettiBank; beq %END%
  li r0, MaxCustomBank
}
HOOK @ $801CA2F8
{
  cmpwi r0, MrResettiBank; beq %END%
  li r0, MaxCustomBank
}
HOOK @ $801CA420
{
  cmpwi r0, MrResettiBank; beq %END%
  li r0, MaxCustomBank
}
HOOK @ $801CA474
{
  cmpwi r0, MrResettiBank; beq %END%
  li r0, MaxCustomBank
}
HOOK @ $801C78EC
{
  cmpwi r0, MrResettiBank; beq %END%
  li r0, MaxCustomBank
}
###################################
HOOK @ $801C7900
{
  rlwinm r0, r30, 3, 0, 28	# Original operation
  cmplwi r30, CustomSoundbankRange;  blt- %END%
  li r0, CustomSoundbankRange
  rlwinm r0, r0, 3, 0, 28
}
HOOK @ $801CA314
{
  lwz r0, 4(r3)			# Original operation
  cmplwi r29, CustomSoundbankRange;  blt- %END%
  li r0, 0x0
}
HOOK @ $80079F90	#### During sound initialization
{
	lis r4, 0x8054 
	addi r5, r31, 0x474	# Beginning of soundbank allocations
	stw r5, -0x1304(r4)	# Store to 8053ECFC
	mr r4, r3		# Original operation
}
### Soundbank loading
HOOK @ $801C836C
{
  mtctr r12			# Original operation
  cmplwi r26, CustomSoundbankRange;  blt- %END%
  
  lwz r4, 0x18(r31) 	#
  lwz r4, 0x04(r4)		#
  lwz r4, 0x28(r4)		# RSAR info
  addis r4, r4, 0xE		#
  addi  r4, r4, 0x3C6C	# Desired Offset: E3C6C 
  
  addi r5, r26, 0x7		# Soundbank ID + 7
  stw r5, 0(r4)

}
HOOK @ $801C8374
{
  cmpwi r26, CustomSoundbankRange;  blt- loc_0x34
  
  
  # lwz r15, 0x40(r1)
  # lwz r15, 0x1C(r15)
  # lwz r15, 0x94(r15)
  # lwz r15, 0x490(r15)		# Pointer to mostly unused FRMH sound heap. Commented out as it was actually used by Pokemon Trainer 
  # addi r15, r15, 0x60		# Fills only up to 0x58 normally
  
  stwu r1, -0x30(r1)
  stw r15, 0x8(r1)
  stw r14, 0xC(r1)
  stw r19, 0x10(r1)
  stw r12, 0x14(r1)
  stw r11, 0x18(r1)
  
    lis r15, 0x8053;  ori r15, r15, 0xED00
  
  subi r14, r28, 0x80	# 909ebbe0 -> 909EBB60
  
  li r12, 11	# \ Loop 11 times!
  mtctr r12		# /
  lwz r12, -0x4(r15)	# Pointer to a table of 11 pointers
  
  li r19, 0
  
 loopPass:  
  lwzx r11, r12, r19
  cmpw r11, r14		# Check if in the same allocation
  beq endLoop
  addi r19, r19, 4
  bdnz+ loopPass 
 endLoop:
  mulli r19, r19, 2	# 4 apart -> 8 apart
  
  lwz r14, 0x18(r31) 		#
  lwz r14, 0x04(r14)		#
  lwz r14, 0x28(r14)		# RSAR info
  addis r14, r14, 0xE		#
  addi  r14, r14, 0x3C6C	# Desired Offset: E3C6C  
  
  add r15, r15, r19
  lwz r19, 0x4C(r14)
  stw r19, 0x00(r15)
  lwz r19, 0x60(r14)
  stw r19, 0x04(r15)
  
  lwz r15, 0x8(r1)
  lwz r14, 0xC(r1)
  lwz r19, 0x10(r1)
  lwz r12, 0x14(r1) 
  lwz r11, 0x18(r1) 
  lwz r1, 0(r1)
 
loc_0x34:
  cmpwi r3, 0x0			# Original operation
}
### Soundbank address info
HOOK @ $801C7AB4
{
  lwz r0, 0xC(r3)	# Original operation
  cmplwi r29, CustomSoundbankRange;  blt- %END%

	stwu r1, -0x10(r1)
	stw r4, 0x8(r1)
	stw r5, 0xC(r1)

  # lwz r28, 0x10(r1)
  # lwz r28, 0x1C(r28)
  # lwz r28, 0x94(r28)
  # lwz r28, 0x490(r28)		# Pointer to mostly unused FRMH sound heap. Commented out as it actually was used by Pokemon Trainer 
  # addi r28, r28, 0x60		# Start at offset 0x60
  
  lwz r28, 0x2C(r1)	# 1C + 10
  subi r28, r28, 0x80 
  
  lis r3, 0x8053;  ori r3, r3, 0xED00
  
  li r12, 11	# \ Loop 11 times!
  mtctr r12		# /
  lwz r12, -0x4(r3)	# Pointer to a table of 11 pointers
  
  li r5, 0
  
 loopPass:  
  lwzx r4, r12, r5
  cmpw r4, r28		# Check if in the same allocation
  ble endLoop		# The checks are in order from highest address to lowest!
  addi r5, r5, 4
  bdnz+ loopPass 
 endLoop:
  mulli r5, r5, 2	# 4 apart -> 8 apart 
  add r12, r3, r5

	lwz r4, 0x8(r1)
	lwz r5, 0xC(r1)
	lwz r1, 0(r1)
  
  
  li r0, 0	# Pointer to voices within bank (Start of it). Without this, it could get invalid values before.
  cmplwi r30, 0;  beq- %END% 	# Use below to get index for SFX

  lwz r0, 0x04(r12)

}
HOOK @ $801C7ABC
{
  lwz r0, 0x10(r3)	# Original operation
  cmplwi r29, CustomSoundbankRange;  blt- %END%

  lwz r0, 0x00(r12)
}
HOOK @ $801C7A00
{
  # lis r4, 0x901A;  ori r4, r4, 0x3090
  lis r4, 0x801C; lwz r4, 0x75A4(r4)
  lis r0, 0x0;  ori r0, r0, 0xC0DE
  # stw r0, 0(r4)
  stw r0, -0xC(r4)
  lwz r0, 0(r3)						# Original operation
  cmplwi r29, CustomSoundbankRange  
  blt- %END%
  cmpwi r0, MrResettiBank; beq %END%  
  li r0, 0x244
}
HOOK @ $801C7A14
{
  rlwinm r0, r29, 3, 0, 28		# Original operation
  cmplwi r29, CustomSoundbankRange;  blt- %END%
  li r0, CustomSoundbankRange
  rlwinm r0, r0, 3, 0, 28
  
  lwz r5, 0x28(r28) 	# RSAR info
  addis r5, r5, 0xE		#
  addi  r5, r5, 0x3C6C	# Desired Offset: E3C6C   
  
  addi r4, r29, 0x7
  stw r4, 0(r5)
}
### Sound Data
HOOK @ $801C7C2C
{
  lwz r0, 0(r3)		# Original operation.  Get anticipated sound range.
  cmplwi r31, CustomSound_Lo;  blt- %END%
  cmplwi r31, CustomSound_Hi;  bgt+ %END%

  li r0, 0xE5				# \ E500: CustomSound_Hi
  rlwinm r0, r0, 8, 0, 31	# /
}
HOOK @ $801C7C4C
{
  rlwinm r0, r31, 3, 0, 28		# Original operation
  cmplwi r31, CustomSound_Lo;  blt- %END%
  li r4, 0x270F					# \ Mimic Sound 0x270F
  rlwinm r0, r4, 3, 0, 28		# /
}
### 3D positional data
HOOK @ $801C74EC
{
  lwz r0, 0(r3)			# Original operation. Get anticipated sound range.
  cmplwi r30, CustomSound_Lo;  blt- %END%
  
  li r0, 0xE5				# \ E500: CustomSound_Hi
  rlwinm r0, r0, 8, 0, 31	# /
}
HOOK @ $801C750C
{
  rlwinm r0, r30, 3, 0, 28	# Original operation
  cmplwi r30, CustomSound_Lo;  blt- %END%
  li r4, 0x270F					# \ Mimic Sound 0x270F
  rlwinm r0, r4, 3, 0, 28		# /
}
HOOK @ $801C7570
{
  cmplwi r30, CustomSound_Lo;  blt- loc_0x10
  
  lis r3, 0x801C; lwz r3, 0x75A4(r3); addi r3, r3, 0x84 # Table 2 + 0x3C
loc_0x10:
  lwz r0, 0(r3)			# Original operation
}
### More Sound Info Data
HOOK @ $801C73CC
{  
  lis r4, 0x801C; lwz r4, 0x75A4(r4); lwz r0, -0xC(r4) 
  cmplwi r0, 0xC0DE;  bne- loc_0x68
   
  # r4 has pointer to Table 1 already
  
  lwz r8, 0x28(r29) 	# RSAR info
  addis r8, r8, 0xE		#
  addi  r8, r8, 0x3C7C	# Desired Offset: E3C7C (E3C6C+10)
  
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
  # stw r0, 40(r8) # Unnecessary and can break soundbank loading.

loc_0x68:
  cmplwi r30, normalMusic_Lo;  blt- loc_0x84		# Branch if a normal sound effect
  lis r0, 0x0;  ori r0, r0, 0xC0DE
  lis r4, 0x801C; lwz r4, 0x75A4(r4)
  stw r0, -0xC(r4)

loc_0x84:
  lwz r0, 0(r3)		# Original operation
  cmplwi r30, CustomSound_Lo;  blt- %END%		# TODO: Probably need to set upper bound so music can read this
  li r0, 0xE5				# \ E500: CustomSound_Hi
  rlwinm r0, r0, 8, 0, 31	# /
}
HOOK @ $801C73EC
{
  rlwinm r0, r30, 3, 0, 28	# Original operation
  cmplwi r30, CustomSound_Lo;  blt- %END%
  li r4, 0x270F					# \ Mimic Sound 0x270F
  rlwinm r0, r4, 3, 0, 28		# /
}
HOOK @ $801C742C
{
  lwz r4, 4(r3)			# Original operation
  cmplwi r30, CustomSound_Lo;  blt- %END%
  cmplwi r30, CustomSound_Hi;  bge- %END%

  subi r3, r30, 0x3F5B 	# TODO: Add GCTRM support for minus on offsets subi r3, r30, CustomSound_Lo-0xA5
  li r4, 0x143 			# li r4, CustomSoundbankRange-1
bankLoop:  
  subi r3, r3, 0xA5
  addi r4, r4, 1
  cmpwi r3, 0xA5; bge+ bankLoop
  mr r0, r4	# True soundbank ID
  
  cmpwi r3, 0x2F	# See if the range is 4000-402E (Voice) or 402F-40A4 (SFX)
  
  lis r3, 0x801C; lwz r3, 0x75A4(r3) 
  addi r3, r3, 0x48	# Table 2

  bge- isSFX
isVoice:
  addi r3, r3, 0x48	# Table 3
isSFX:
  lwz r4, 4(r3)
  add r4, r4, r0	# force to be 0x6000+Soundbank if SFX or 0x7000+Soundbank if Voice

}
### Sound Typing
HOOK @ $801C72D0
{
  lwz r0, 0(r3)			# Original operation
  cmplwi r31, CustomSound_Lo;  blt- %END%
  li r0, 0xE5				# \ E500: CustomSound_Hi
  rlwinm r0, r0, 8, 0, 31	# /
}
HOOK @ $801C72F0
{
  rlwinm r0, r31, 3, 0, 28	# Original operation
  cmplwi r31, CustomSound_Lo;  blt- %END%
  li r4, 0x270F
  rlwinm r0, r4, 3, 0, 28
}
HOOK @ $801C7318
{
  cmplwi r31, CustomSound_Lo;  blt- loc_0x10

  lis r3, 0x801C; lwz r3, 0x75A4(r3); addi r3, r3, 0x48	# Table 2
loc_0x10:
  lbz r0, 0x16(r3)		# Original operation
}
### Sound Info
HOOK @ $801C8050
{
  lwz r0, 0(r3)			# Original operation
  cmplwi r31, CustomSound_Lo;  blt- %END%
  li r0, 0xE5				# \ E500: CustomSound_Hi
  rlwinm r0, r0, 8, 0, 31	# /
}
HOOK @ $801C8074
{
  rlwinm r0, r31, 3, 0, 28	# Original operation
  cmplwi r31, CustomSound_Lo;  blt- %END%
  li r4, 0x270F
  rlwinm r0, r4, 3, 0, 28
}
HOOK @ $801C80A8
{
  cmplwi r31, CustomSound_Lo;  blt- loc_0x18 # min sound ID
  cmplwi r31, CustomSound_Hi;  bge- loc_0x18 # max sound ID

  lis r3, 0x801C; lwz r3, 0x75A4(r3); addi r3, r3, 0x48	# Table 2
loc_0x18:
  lwz r4, 0x18(r3)	# Original operation
}
### File Data
HOOK @ $801C7CF4
{
  cmplwi r30, CustomSound_Hi;  bge- loc_0x18 # max sound ID
  cmplwi r30, 0x6000;  blt- loc_0x18		 # Not quite sure why 6000 is such a specific choice????
  lis r0, 0x1
  b %END%

loc_0x18:
  lwz r0, 0(r3)			# Original operation
}
HOOK @ $801C7D08
{
  cmplwi r30, 0x6000;  blt- loc_0x24;  li r4, 0x275;  rlwinm r0, r4, 3, 0, 28
  cmplwi r30, 0x7000;  blt- loc_0x28;  li r4, 0x105;  rlwinm r0, r4, 3, 0, 28
  b loc_0x28

loc_0x24:
  rlwinm r0, r30, 3, 0, 28		# Original operation

loc_0x28:
  mr r31, r30

}
HOOK @ $801C7D34
{
  cmplwi r31, 0x6000;  blt- loc_0x20
  lis r3, 0x801C; lwz r3, 0x75A4(r3); addi r3, r3, 0x100 # Table 5
  cmplwi r31, 0x7000;  blt- loc_0x1C
  subi r3, r3, 0x28 # Table 4
loc_0x1C:
  mr r30, r3

loc_0x20:
  lbz r3, 0x14(r3)	# Original operation
}
### File Offset. Abuses soundbank ID by making it appear to be 6xxx (SFX) or 7xxx (Voice)
HOOK @ $801C7DF8
{
  cmplwi r29, 0x6000;  blt- loc_0x10
  lis r0, 0x1
  b %END%

loc_0x10:
  lwz r0, 0(r3)		# Original operation
}
HOOK @ $801C7E0C
{
  cmplwi r29, 0x6000;  blt- loc_0x24;  li r4, 0x275;  rlwinm r0, r4, 3, 0, 28
  cmplwi r29, 0x7000;  blt- %END%;     li r4, 0x105;  rlwinm r0, r4, 3, 0, 28
  b %END%

loc_0x24:
  rlwinm r0, r29, 3, 0, 28	# Original operation
}
HOOK @ $801C7E38
{
  cmplwi r29, 0x6000;  blt- loc_0x20
  lis r3, 0x801C; lwz r3, 0x75A4(r3); addi r3, r3, 0x100 # Table 5
  cmplwi r29, 0x7000;  blt- loc_0x1C
  subi r3, r3, 0x28 # Table 4

loc_0x1C:
  mr r4, r3

loc_0x20:
  lbz r3, 0x14(r3)	# Original operation
}
HOOK @ $801C7E94
{
  lwz r0, 0(r3)		# Original operation
  cmplwi r29, 0x6000;  blt- %END%
  
  lis r4, 0x801C; lwz r4, 0x75A4(r4); lwz r0, -0x8(r4)
  
  subi r4, r29, 0x6000
  cmplwi r29, 0x7000;  blt- loc_0x28
  subi r4, r29, 0x7000

loc_0x28:
  cmplw r4, r0;  beq- %END%
  mr r0, r4
}
HOOK @ $801C7E9C
{
  lwz r0, 4(r3)	# Original operation
  cmplwi r29, 0x6000;  blt- loc_0x10
  li r0, 0x1

loc_0x10:
  cmplwi r29, 0x7000;  blt- %END%
  li r0, 0x0
}
### Wave Sound Info
HOOK @ $801C76E4
{
  lwz r4, 0(r3)		# Original operation
  cmplwi r29, CustomSound_Lo;  blt- %END%
  
  stwu r1, -0x10(r1)
  stw r14, 4(r1)
  stw r15, 8(r1)
  stw r16, 0xC(r1)
  li r14, CustomSound_Lo		# Bottom section of expansion bank
  li r15, CustomSound_Lo+0x2F	# Border between voice and regular SFX
  li r16, CustomSound_Lo+0xA5 	# Top section of expansion bank

loc_0x28:
  cmplw r29, r16;  bge- loc_0x48
  sub r4, r29, r15
  cmplw r29, r15;  bge- loc_0x58
  sub r4, r29, r14
  cmplw r29, r14;  bge- loc_0x58

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
HOOK @ $801CA63C # Prevents crash when attempting to play a sound that is not loaded.
{
	addi r3, r1, 8		# Operation being replaced below
	lwz r5, 4(r3)		# \ Check if the soundbank is STILL uninitialized
	cmpwi r5, 0			# / after initialization. This means it was not found!
	mr r5, r29			# Original operation.
}
op beq- 0x10 @ $801CA640

* E0000000 80008000

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
#######################################
[Project+] Sawnd Pop Fix V5 [DukeItOut]
#######################################
HOOK @ $801D3760
{
  lbz r12, 0x1(r4)		// loop flag
  lhz r0, 0x4(r4)		// sample rate
  lwz r4, 0xC(r4)		// the original operation
  cmplwi r4, 512;  blt- %END%	// Sample size 512 or less?
  cmplwi r12, 1; beq- loops	//skip looped samples
  b fixRate
loops:
  cmplwi r4, 0x8000; bge- %END%	# Don't let long loops be affected
  cmplwi r0, 16000; ble- %END%
  cmplwi r0, 22050; blt- midRate
fixRate: 
  addi r4, r4, 128		// "subi r4, r4, 128" for sample rates
midRate: 
  subi r4, r4, 256		// if 512 samples or higher, cut it off 256 samples early to compensate for odd sawnd quirks
}

######################################################################
[Project+] Expansion sawnd characters are mute while metal [DukeItOut]
######################################################################
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