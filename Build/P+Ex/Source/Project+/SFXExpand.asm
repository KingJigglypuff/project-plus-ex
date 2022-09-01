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
	uint16_t [80] |
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
	0x603D, 90, | # Knuckles "HYAH!" used for Forward Smash, Side B and Neutral B
	| #
	0xFFFF, 0  # Make sure the table ends with this as a terminator!

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
[Project+] SoundBank Expansion System (RSBE.Ver) (Kirby-cide fix + Voice clips volume fix + CSS Hiccup Fix + Mr. Resetti fix) v1.2 [codes, DukeItOut, JOJI]
# v1.2 - Fixes Mr. Resetti's brsar conflicts
###########################################################################################################################################################
.alias CustomSoundbankRange = 0x0144	# Custom soundbanks are 0x144 or higher
.alias CustomSound_Lo		= 0x4000	# Custom sfx lower range 
.alias CustomSound_Hi 		= 0xE500	# Custom sfx upper range 
.alias normalMusic_Lo		= 0x26F9	# Brawl music lower range
.alias normalMusic_Hi		= 0x286B	# Brawl music upper range
.alias MrResettiBank		= 2			# What it expects if this is Mr. Resetti's special brsar

HOOK @ $801C7A00
{
  lis r4, 0x901A;  ori r4, r4, 0x3090
  lis r0, 0x0;  ori r0, r0, 0xC0DE
  stw r0, 0(r4)
  lwz r0, 0(r3)						# Original operation
  cmplwi r29, CustomSoundbankRange  
  blt- %END%
  cmpwi r0, MrResettiBank; beq %END%  
  li r0, 0x244
}
* 4A000000 90000000

# Associated with hook $801C73CC
* 161A3040 00000048
* 01B872A0 0000B720
* 01B57540 000CC1A0
* 01000000 000E3C94
* 00000002 01000000
* 000E3CA8 01000000
* 000E3CC0 00004321
* 00003460 00000000
* 00003460 000082C0
* 00100000 00001234

# Associated with hook $801C7E94, $801C7C2C, $801C742C, $801C7318, $801C80A8
* 161A3100 00000048
* 000041C3 00006000
* 00000002 01000000
* 00084090 2E400300
* 01030000 00084080
* 00000000 00000000
* 00000000 00000000
* 00000001 40000000
* 00000000 00000005
* 01800000 00000000

# Associated with hook $801C7570
* 161A3150 00000048
* 00004194 00007000
* 00000002 01000000
* 00042CD8 3E400300
* 01030000 00042CC8
* 00000000 00000000
* 00000000 00000025
* 00000001 40000000
* 00000000 00000005
* 01800000 00000000

# Associated with hook $801C7A00, $801C78EC, $801C7BD8, $801C9784, $801C98D0, $801CA2F8, $801CA420, $801CA474, $801C73CC
* 161A30A0 00000028
* 00003460 00053A80
* FFFFFFFF 00000000
* 00000000 01000000
* 000CFE0C 00000001
* 01000000 000CFE18

# Associated with hook $801C7E38, $801C7D34
* 161A30D0 00000028
* 000082C0 00078340
* FFFFFFFF 00000000
* 00000000 01000000
* 000D4FDC 00000001
* 01000000 000D4FE8

# Others: Block 901A3200 from hook $801C8374, $801C7AB4, $801C7ABC
# Block 90432134 from hook $801C7A14, $801C73CC
* E0000000 80008000

HOOK @ $801C78EC
{
  mr r0, r3
  lis r3, 0x901A;  ori r3, r3, 0x3090
  lwz r3, 0(r3)
  cmplwi r3, 0xC0DE
  mr r3, r0
  lwz r0, 0(r3)	# Original operation
  bne- %END%
  cmpwi r0, MrResettiBank; beq %END%
  cmplwi r30, CustomSoundbankRange;  blt- %END%
  li r0, 0x244
}
HOOK @ $801C7BD8
{
  mr r0, r3
  lis r3, 0x901A;  ori r3, r3, 0x3090
  lwz r3, 0(r3)
  cmplwi r3, 0xC0DE
  mr r3, r0
  lwz r3, 0(r3)	# Original operation
  bne- %END%
  cmpwi r3, MrResettiBank; beq %END%  
  cmplwi r29, CustomSoundbankRange;  blt- %END%
  li r3, 0x245
}
HOOK @ $801C9784
{
  mr r0, r3
  lis r3, 0x901A;  ori r3, r3, 0x3090
  lwz r3, 0(r3)
  cmplwi r3, 0xC0DE
  mr r3, r0
  lwz r0, 0(r3)		# Original operation
  bne- %END%
  cmpwi r0, MrResettiBank; beq %END%
  li r0, 0x244
}
HOOK @ $801C98D0
{
  mr r0, r3
  lis r3, 0x901A;  ori r3, r3, 0x3090
  lwz r3, 0(r3)
  cmplwi r3, 0xC0DE
  mr r3, r0
  lwz r0, 0(r3)		# Original operation
  bne- %END%
  cmpwi r0, MrResettiBank; beq %END%
  li r0, 0x244
}
HOOK @ $801CA2F8
{
  mr r0, r3
  lis r3, 0x901A;  ori r3, r3, 0x3090
  lwz r3, 0(r3)
  cmplwi r3, 0xC0DE
  mr r3, r0
  lwz r0, 0(r3)		# Original operation
  bne- %END%
  cmpwi r0, MrResettiBank; beq %END%
  li r0, 0x244
}
HOOK @ $801CA420
{
  mr r0, r8
  lis r8, 0x901A;  ori r8, r8, 0x3090
  lwz r8, 0(r8)
  cmplwi r8, 0xC0DE
  mr r8, r0
  lwz r0, 0(r8)		# Original operation
  bne- %END%
  cmpwi r0, MrResettiBank; beq %END%
  li r0, 0x244
}
HOOK @ $801CA474
{
  mr r0, r8
  lis r8, 0x901A;  ori r8, r8, 0x3090
  lwz r8, 0(r8)
  cmplwi r8, 0xC0DE
  mr r8, r0
  lwz r0, 0(r8)		# Original operation
  bne- %END%
  cmpwi r0, MrResettiBank; beq %END%
  li r0, 0x244
}
HOOK @ $801C836C
{
  mtctr r12			# Original operation
  cmplwi r26, CustomSoundbankRange;  blt- %END%
  lis r4, 0x9043;  ori r4, r4, 0x2134
  addi r5, r26, 0x7
  stw r5, 0(r4)

}
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
HOOK @ $801C8374
{
  cmpwi r26, CustomSoundbankRange;  blt- loc_0x34
  lis r14, 0x9043;  ori r14, r14, 0x2134
  lis r15, 0x901A;  ori r15, r15, 0x3200	# Todo, remove copy or move it
  subi r19, r26, CustomSoundbankRange
  mulli r19, r19, 0x8
  add r15, r19, r15
  lwz r19, 76(r14)
  stw r19, 0(r15)
  lwz r19, 96(r14)
  stw r19, 4(r15)

loc_0x34:
  cmpwi r3, 0x0			# Original operation
}
HOOK @ $801C7AB4
{
  lwz r0, 0xC(r3)	# Original operation
  cmplwi r29, CustomSoundbankRange;  blt- %END%
  cmplwi r30, 0;  beq- %END%
  subi r29, r29, CustomSoundbankRange
  mulli r29, r29, 0x8
  lis r28, 0x901A;  ori r28, r28, 0x3200
  add r28, r28, r29
  lwz r0, 4(r28)

}
HOOK @ $801C7ABC
{
  lwz r0, 0x10(r3)	# Original operation
  cmplwi r29, CustomSoundbankRange;  blt- %END%
  cmplwi r30, 1;  beq- %END%
  subi r29, r29, CustomSoundbankRange
  mulli r29, r29, 0x8
  lis r28, 0x901A;  ori r28, r28, 0x3200
  add r28, r28, r29
  lwz r0, 0(r28)
}
HOOK @ $801C7A14
{
  rlwinm r0, r29, 3, 0, 28		# Original operation
  cmplwi r29, CustomSoundbankRange;  blt- %END%
  li r0, CustomSoundbankRange
  rlwinm r0, r0, 3, 0, 28
  lis r5, 0x9043;  ori r5, r5, 0x2134
  addi r4, r29, 0x7
  stw r4, 0(r5)
}
HOOK @ $801C7C2C
{
  lwz r0, 0(r3)		# Original operation
  cmplwi r31, CustomSound_Lo;  blt- %END%
  cmplwi r31, 0xFFFF;          bgt+ %END%
  stwu r1, -0x10(r1)
  stw r14, 4(r1)
  stw r15, 8(r1)
  stw r16, 0xC(r1)
  li r14, CustomSoundbankRange
  li r15, CustomSound_Lo+0xA5

loc_0x2C:
  cmplw r31, r15;  blt- loc_0x40
  addi r14, r14, 0x1
  addi r15, r15, 0xA5
  b loc_0x2C

loc_0x40:
  lis r4, 0x901A
  ori r4, r4, 0x30F8
  stw r14, 0(r4)
  li r14, CustomSound_Lo+0x2F
  li r15, CustomSound_Lo+0xA5

loc_0x54:
  li r16, 0x0;  cmplw r31, r14;  blt- loc_0x78
  li r16, 0x1;  cmplw r31, r15;  blt- loc_0x78
  addi r14, r14, 0xA5
  addi r15, r15, 0xA5
  b loc_0x54

loc_0x78:
  stw r16, 4(r4)
  li r0, 0xE5
  rlwinm r0, r0, 8, 0, 31
  lwz r14, 4(r1)
  lwz r15, 8(r1)
  lwz r16, 12(r1)
  lwz r1, 0(r1)
}
HOOK @ $801C7C4C
{
  rlwinm r0, r31, 3, 0, 28		# Original operation
  cmplwi r31, CustomSound_Lo;  blt- %END%
  li r4, 0x270F
  rlwinm r0, r4, 3, 0, 28
}
HOOK @ $801C74EC
{
  lwz r0, 0(r3)			# Original operation
  cmplwi r30, CustomSound_Lo;  blt- %END%
  li r0, 0xE5
  rlwinm r0, r0, 8, 0, 31
}
HOOK @ $801C750C
{
  rlwinm r0, r30, 3, 0, 28	# Original operation
  cmplwi r30, CustomSound_Lo;  blt- %END%
  li r4, 0x270F
  rlwinm r0, r4, 3, 0, 28
}
HOOK @ $801C7570
{
  cmplwi r30, CustomSound_Lo;  blt- loc_0x10
  lis r3, 0x901A
  ori r3, r3, 0x313C
loc_0x10:
  lwz r0, 0(r3)			# Original operation
}
HOOK @ $801C73CC
{
  lis r4, 0x901A
  ori r4, r4, 0x3090
  lwz r0, 0(r4);  cmplwi r0, 0xC0DE;  bne- loc_0x68
  lis r4, 0x901A;  ori r4, r4, 0x3040
  lis r8, 0x9043;  ori r8, r8, 0x2144

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
  cmplwi r30, normalMusic_Lo;  blt- loc_0x84		# Branch if a normal sound effect
  lis r4, 0x901A;  ori r4, r4, 0x3090
  lis r0, 0x0;  ori r0, r0, 0xC0DE
  stw r0, 0(r4)

loc_0x84:
  lwz r0, 0(r3)		# Original operation
  cmplwi r30, CustomSound_Lo;  blt- %END%		# TODO: Probably need to set upper bound so music can read this
  li r0, 0xE5
  rlwinm r0, r0, 8, 0, 31
}
HOOK @ $801C73EC
{
  rlwinm r0, r30, 3, 0, 28	# Original operation
  cmplwi r30, CustomSound_Lo;  blt- %END%
  li r4, 0x270F
  rlwinm r0, r4, 3, 0, 28
}
HOOK @ $801C742C
{
  lwz r4, 4(r3)			# Original operation
  cmplwi r30, CustomSound_Lo;  blt- %END%
  cmplwi r30, CustomSound_Hi;  bge- %END%
  lis r3, 0x901A;  ori r3, r3, 0x3100	# \ Load from resource
  lwz r4, -4(r3)
  lwz r0, -8(r3)
  cmplwi r4, 0;  bne- loc_0x30
  addi r3, r3, 0x50

loc_0x30:
  lwz r4, 4(r3)
  add r4, r4, r0

}
HOOK @ $801C72D0
{
  lwz r0, 0(r3)			# Original operation
  cmplwi r31, CustomSound_Lo;  blt- %END%
  li r0, 0xE5
  rlwinm r0, r0, 8, 0, 31
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
  lis r3, 0x901A
  ori r3, r3, 0x3100
loc_0x10:
  lbz r0, 0x16(r3)		# Original operation
}
HOOK @ $801C8050
{
  lwz r0, 0(r3)			# Original operation
  cmplwi r31, CustomSound_Lo;  blt- %END%
  li r0, 0xE5
  rlwinm r0, r0, 8, 0, 31
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
  lis r3, 0x901A
  ori r3, r3, 0x3100

loc_0x18:
  lwz r4, 0x18(r3)	# Original operation
}
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
  lis r3, 0x901A
  ori r3, r3, 0x30D0
  cmplwi r31, 0x7000;  blt- loc_0x1C
  subi r3, r3, 0x30

loc_0x1C:
  mr r30, r3

loc_0x20:
  lbz r3, 0x14(r3)	# Original operation
}
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
  lis r3, 0x901A
  ori r3, r3, 0x30D0
  cmplwi r29, 0x7000;  blt- loc_0x1C
  subi r3, r3, 0x30

loc_0x1C:
  mr r4, r3

loc_0x20:
  lbz r3, 0x14(r3)	# Original operation
}
HOOK @ $801C7E94
{
  lwz r0, 0(r3)		# Original operation
  cmplwi r29, 0x6000;  blt- %END%
  lis r3, 0x901A;
  ori r3, r3, 0x30F8
  lwz r0, 0(r3)
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

* E0000000 80008000

Hitbox Sound Effect Change System v2.1 [Eon]
#hitbox flags sfx 29, 30 and 31 point to ra-basic[8],ra-basic[9],ra-basic[10], and then flag 12 plays all three sounds at once, reading from same 3 ra's (0 = no sound)
#hitbox sfx flag is specifically mapped to 0x00003E00 of hitbox flags
#formulas to stick into wolfram alpha to set id as you want : 
#   (0x<originalhitboxflag> bitwise and 0xFFFFC1FF) + (29 << 9) = new flag with sfx id 29, replace the 29 with 30 or 31 if you want them
#
#example - falcon punches original hitbox flag was 29030485, so putting into wolfram alpha
#(0x29030485 bitwise and 0xFFFFC1FF) + (30 << 9) gives me 29033c85, so that is the hitbox flag if i wanted to have that hitbox read ra-basic[9] for its sfx id
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
[Project+] Sawnd Pop Fix V2 [DukeItOut]
#######################################
HOOK @ $801D3760
{
  lwz r4, 0xC(r4)		// the original operation
  cmpwi r4, 512
  blt- %END%
  subi r4, r4, 64		// if 512 samples or higher, cut it off 64 samples early to compensate for odd brsar quirks
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