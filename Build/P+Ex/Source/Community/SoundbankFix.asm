###############################
Soundbank Clone Fix [DukeItOut]
###############################
# Replaces "Manual Clone Soundbank Unload Fix"
#
# This version of the code is dependent
# on "Costume Alternate Soundbank Loader" also being present!
#
# Also dependent on Heritage.asm and SFXExpand.asm!
###

.alias Mod_Brawl = 0x80AD89E0
.alias Mod_PM = Mod_Brawl
.alias Mod_EX = 0x817C92E0
.alias Mod_REX = 0x817BAF20

.alias GameMod = Mod_EX
.alias ModAddr_Hi = GameMod / 0x10000
.alias ModAddr_Lo = GameMod & 0xFFFF


.macro SoundbankCheck()
{
    rlwinm r12, r0, 2, 0, 29 # Existing bank to check for
    rlwinm r11, r4, 2, 0, 29 # Self
    lis r10, ModAddr_Hi		 # \ Table is 80AD89E0 in Brawl/PM. Compare with operation at 8084CA70
    ori r10, r10, ModAddr_Lo # / Make sure it matches REX/P+EX's location! 817BAF20 in REX. 817C92E0 in P+EX for now.
    lwzx r11, r10, r11
    lwzx r12, r10, r12
    # cmpw r11, r12         # Compare the banks expected instead of instance IDs
	crset 2					# Force to skip character check by setting eq flag
							# The bank will still get referenced but we don't want it to be character-only
}
.macro PT_Convert()
{
	cmpwi r7, 2; bne+ 0x18 # 2 = Pokemon Trainer audio slot. 3 is normal.
	cmpwi r3, 0x1D; blt+ 0x10 # \ 1D-1F = Charizard, Squirtle, Ivysaur
	cmpwi r3, 0x1F; bgt+ 0x8  # /
	li r3, 0x1C				# 1C = Pokemon Trainer instance
}

HOOK @ $8084C9D4 # Load
{
    %SoundbankCheck()
}
HOOK @ $8084C9E8 # Character Soundbank Load
{
	mr r4, r0			# character compared with's costume
	lwz r3, 0x18(r5)	# character compared with's instance ID
	%PT_Convert()
	bla 0x3FF8			# character being compared with
	mr r10, r3
	mr r3, r31			# instance
	mr r4, r23			# costume
	%PT_Convert()
	bla 0x3FF8			# character loading
	cmpwi r10, -1; beq+ 0x8
	rlwimi r12, r10, 16, 4, 15	# character being compared with
	cmpwi r3, -1; beq+ 0x8
	rlwimi r11, r3, 16, 4, 15	# character being loaded
	cmplw r11, r12		# See if they share banks
	mr r4, r31			# restore r4
}
HOOK @ $8084C30C # Unload
{
    cmpw r0, r4  # Original operation
	cmpwi cr1, r7, 2; beq+ cr1, check # Secondary Soundbank for next PT mon?
    cmpwi cr1, r7, 3; bne- cr1, %END% # Standard Soundbank
check:
    %SoundbankCheck()
}
HOOK @ $8084C320 # Character Soundbank Unload
{
	cmpw r0, r8  		# Original operation. Compare costume ID
	cmpwi cr1, r7, 2	# secondary soundbank?
	beq- cr1, check		
    cmpwi cr1, r7, 3	# Similar premise to 
    bne- cr1, %END%		# 3 for fighter banks. Is 7 for Pokemon Trainer for future reference.
check:
	stwu r1, -0x20(r1)
	mflr r0
	stw r0, 0x24(r1)
	stw r3, 8(r1)
	stw r4, 0xC(r1)
	stw r5, 0x10(r1)
	stw r6, 0x14(r1)
	
	mr r3, r4 
	mr r4, r8
	%PT_Convert()
	bla 0x3FF8
	mr r5, r3
	
	lwz r3, 0x18(r9) # instance being compared with
	lbz r4, 0x30(r9) # costume being compared with
	%PT_Convert()
	bla 0x3FF8
	cmpwi r3, -1; beq 0x8
	rlwimi r12, r3, 16, 4, 15	# Character being compared with
	cmpwi r5, -1; beq 0x8
	rlwimi r11, r5, 16, 4, 15	# Character being unloaded
	cmplw r12, r11
	
	lwz r3, 8(r1)
	lwz r4, 0xC(r1)
	lwz r5, 0x10(r1)
	lwz r6, 0x14(r1)
	lwz r0, 0x24(r1)
	mtlr r0
	addi r1, r1, 0x20
}

#################################################################
Hitbox Sound Effect Change System v3.0 [Eon, MarioDox, DukeItOut]
#################################################################
#hitbox flags sfx 29, 30 and 31 point to ra-basic[8],ra-basic[9],ra-basic[10], 12 is currently the same as 29
#hitbox sfx flag is specifically mapped to 0x00003E00 of hitbox flags
#formulas to stick into wolfram alpha to set id as you want : 
#   (0x<originalhitboxflag> bitwise and 0xFFFFC1FF) + (29 << 9) = new flag with sfx id 29, replace the 29 with 30 or 31 if you want them
#
#example - falcon punches original hitbox flag was 29030485, so putting into wolfram alpha
#(0x29030485 bitwise and 0xFFFFC1FF) + (30 << 9) gives me 29033c85, so that is the hitbox flag if i wanted to have that hitbox read ra-basic[9] for its sfx id
# 2.2: SFX is now played by the attacker, to be compatible with costume alternate soundbanks
# 3.0: Now works in Subspace but 12 no longer stacks 8 through 10. Now behaves the same as 29 until further progress.
#			Also helps fix unique hit SFX foor clone banks.
# TODO: Convert 29, 30 and 31 to sound levels of 12 so 29-31 can be global instead
############################################
# Manipulate Hit SFX!
HOOK @ $80761604
{
	rlwinm r0, r4, 4, 0, 27	# Original operation
	mr r7, r4				# I want r4 for later!
}
HOOK @ $80761614
{
	lwzx r4, r4, r0			# Original operation. Get SFX
	cmpwi r7, 12			# \
	beq- override			# | Only manipulate 12 and 29-31!
	cmpwi r7, 29			# |
	blt+ %END%				# /
override:
	li r4, 0				# Force it to not skip.
}
HOOK @ $80761624
{
	# Stage props don't trigger this
	# Items, fighters and projectiles go through the second check
	# Subspace enemies go through the first
	
	mflr r6
	# lis r8, 0x811B		# \ Subspace and Boss Battles go through here
	# ori r8, r8, 0xEA04	# /
	
	lis r9, 0x8076		# \
	ori r8, r9, 0x89A8	# | When damaged by something other than a hitbox.
	cmpw r6, r8			# |
	beq- oddBehavior	# /
	
	ori r8, r9, 0x2098	# | We only want to modify from this function!
	cmpw r6, r8			# | Others are probably enemies or something undesired.
	mr r8, r31			# | Expected hitbox register if normal
	beq- normalHit		# /
enemyHit:
	mr r8, r28			# Expected hitbox register if an enemy
normalHit:
	stwu r1, -0x20(r1)
	mflr r0
	stw r0, 0x24(r1)
	stw r3, 0xC(r1)		# Owner of sound
	stw r4, 0x10(r1)	# Sound ID
	stw r7, 0x14(r1)	# Sound Type
	stw r5, 0x18(r1)	# Sound Level (0-3)
	lwz r3, 0xC(r8)		# Hitbox's Task
	bla 0x02DC40		# Get pointer!
	lwz r3, 0x60(r3)
	bla 0x3FF0			# Get founder of object!
	cmpwi r3, 0			# \ if 0, not a fighter
	beq+ normal			# /
	
	lwz r7, 0x14(r1)	# Sound Type
	cmpwi r7, 12
	beq- customSound
	cmpwi r7, 29
	blt+ notCustomSound
	subi r7, r7, 17		# 12 & 29 = 8, 30 = 9, 31 = 10
customSound:
	subi r7, r7, 4		# TODO, get all moveset to use different setup
	/*
	# Disabled for now.
	lwz r7, 0x18(r1)	# \ Intended approach to get: using volume to decide the variable.
	add r7, r7, 8		# / RA-Basic 8-11 for custom sound type 12	
	*/
    lis r4, 0x2000 #RA-Basic
	add r4, r4, r7
	stw r3, 0x1C(r1)
	lwz r3, 8(r3)		# Get pointer needed
	lis r12, 0x8079
	ori r12, r12, 0x76D8
	mtctr r12
	bctrl				# Get variable!
	mr r4, r3
	lwz r3, 0x1C(r1)
	b soundLoad
notCustomSound:	
	lwz r4, 0x10(r1)	# Sound ID
soundLoad:
	lwz r3, 0xD8(r3)	# \
	lwz r3, 0x50(r3)	# / Sound info
	bla 0x3FF4
	b modifiedSound
normal:
	lwz r4, 0x10(r1)
modifiedSound:
	lwz r3, 0xC(r1)
	lwz r0, 0x24(r1)
	mtlr r0
	addi r1, r1, 0x20
oddBehavior:
	lwz r12, 0(r3)		# Original operation
}

#############################################################
Costume Alternate Soundbank Loader v1.2 [Squidgy, DukeItOut]
#############################################################
# 1.1 - Make soundbank variants function with non-fighter IDs
# 1.2 - More stable solution for hit SFX
#############################################################
# arguments: 
# r3 = instance ID
# r4 = costume ID
#
# If a CLONE uses an alt bank as the base, make sure to include the base costume range if
# 	and ONLY if they sometimes use ones the base character does, too!
# (Clone banks only used by a single fighter instance ID do not need to be added.)
#####
.alias Fighter_Link = 0x02
.alias Fighter_Zelda = 0x0D
.alias Fighter_Sheik = 0x0E
.alias Fighter_Ganondorf = 0x14

.alias Fighter_Fox = 0x06
.alias Fighter_Falco = 0x13

.alias Fighter_Pit = 0x17

.alias Fighter_Peach = 0x0C # SEQ-containing sawnd test
.alias Bank_Peach_Test = 0xFFF # Max bank test

.alias Bank_Link_OoT = 1	# Alt bank 1 (0x1002)
.alias Bank_Zelda_OoT = 1
.alias Bank_Sheik_OoT = 1
.alias Bank_Ganondorf_OoT = 1

.alias Bank_Fox_64 = 1
.alias Bank_Falco_64 = 1

.alias Bank_Pit_KIU = 1
.alias Bank_Dark_Pit_KIU = 2
.alias Bank_Pit_SSBB = 0


.macro altDefault(<ftKind>,<soundbankID>)
{
	cmpwi r3, <ftKind>	# r3 holds ftKind, check if it matches
    bne+ 0x8
    li r0, <soundbankId> # Alt bank to use as a default for this character if not 0.
}

.macro costumeCheck(<ftKind>,<costumeId_Min>,<costumeID_Max>,<soundbankId>)
{
	cmpwi r3, <ftKind>	# r3 holds ftKind, check if it matches
    bne+ 0x18
    cmpwi r4, <costumeId_Min>	# r4 holds costume ID, check if it matches
    blt+ 0x10
    cmpwi r4, <costumeID_Max>
    bgt+ 0x08
    li r0, <soundbankId>		# load soundbank based on costume ID
}
###
HOOK @ $80003FF8
{
	li r0, -1
	andi r4, r4, 0x7F # Mask away the clear skins (0x80+)
	
	%costumeCheck(Fighter_Link,20,29,Bank_Link_OoT) # 0x1002 for 20-29	
	%costumeCheck(Fighter_Zelda,20,29,Bank_Zelda_OoT) # 0x1011 for 20-29
	%costumeCheck(Fighter_Sheik,20,29,Bank_Sheik_OoT) # 0x1011 for 20-29
	%costumeCheck(Fighter_Ganondorf,20,29,Bank_Ganondorf_OoT) # 0x1016 for 20-29
	
	# %costumeCheck(Fighter_Fox,20,29,Bank_Fox_64) # 0x100A for 20-29
	# %costumeCheck(Fighter_Falco,20,29,Bank_Falco_64) # 0x1015 for 20-29
	# The existing Fox and Falco banks are kinda awkward so disabled for now.
	# Left to make it easy to add since they seem likely to be implemented by people.
	
	# %costumeCheck(Fighter_Peach,5,5,Bank_Peach_Test) # SEQ test (Daisy color).
	# Only present for debugging.
	
	
	# %altDefault(Fighter_Pit,Bank_Pit_KIU) # 0x1003 for 00-19
	# %costumeCheck(Fighter_Pit,20,29,Bank_Dark_Pit_KIU) # 0x2003 for 20-29
	# %costumeCheck(Fighter_Pit,30,39,Bank_Pit_SSBB) # 0x003 for 30-39
	# This was an idea that likely will be of interest to people.
	# However, personal testing of the concept left me to come to the same conclusion
	# the official games do: Dark Pit as an alt feels wrong and makes more sense as a separate character.
	
	mr r3, r0
	blr
}

op mr r6, r23 @ $8084CACC # Move costume ID into r6 instead of leaving -1 (assumes all costumes have identical audio)

HOOK @ $8084cA64
{
    mr r6, r4            # We'll need r4 still but it can vary between builds!
    mr r3, r31
    mr r4, r23
    bla 0x3FF8
    mr r11, r3            # used in below hook
    mr r4, r6
    lis r3, 0x805A        # Original operation
}
HOOK @ $8084CA78
{
	lwzx r4, r4, r0            # original instruction, loads soundbank ID into r4
	cmpwi r11, -1; beq+ %END%	# Default does not do the below!
	rlwimi r4, r11, 12, 8, 19
}
###################
#Sound Manipulation
###################
.macro Test()
{
	lis r12 0x8000
	ori r12, r12, 0x3FF4
	mtctr r12 
	bctrl
}
HOOK @ $807612F4 # playSE
{
	%Test()
	lwz r3, 0x44(r28)	# Modified version of original operation
}
HOOK @ $807613D4 # playSENo3d
{
	%Test()
	lwz r3, 0x44(r30)	# Modified version of original operation
}
HOOK @ $80761474 # playSEPos
{
	mr r31, r3
	%Test()
	mr r3, r31
	lwz r12, 0(r3)	# Original operation
}
HOOK @ $80761500 # playStatusSE
{
	%Test()
	lwz r3, 0x44(r29)	# Modified version of original operation
}
HOOK @ $807615D8 # stopSE
{
	stwu r1, -0x10(r1)
	mflr r0
	stw r0, 0x14(r1)
	stw r5, 8(r1)
	stw r3, 0xC(r1)
	%Test()
	lwz r5, 8(r1)
	lwz r3, 0xC(r1)
	mr r6, r3 		# Original operation
	lwz r0, 0x14(r1)
	mtlr r0
	addi r1, r1, 0x10
}
HOOK @ $80761628 # Related to hit sounds
{
	oris r4, r4, 0xD000	# Make it clear this was a damage sound!
	li r5, 0	# Original operation
}
HOOK @ $80003FF4
{
	stwu r1, -0x10(r1)
	mflr r0
	stw r0, 0x14(r1)
	stw r4, 0x8(r1)		# Sound ID
	lwz r3, 0x40(r3)	# Sound owner
	cmpwi r4, -1; beq- finish	# Prevent invalid sound "-1" from being modified!
	rlwinm r5, r4, 4, 28, 31
	cmplwi r5, 0xD; bne+ notHit	# Was this from damage?
	rlwinm r4, r4, 0, 4, 31	# Clear top digit and keep the same!
	b finish
notHit:
	andi. r0, r4, 0xFFFF
	# cmplwi r4, 0xE500; bgt finish			# anything higher is not attempted
	cmplwi r0, 0x010E; blt finish			# Mario's first sound
	cmplwi r0, 0x1B4C; ble tryCloneSound	# last character sound
	# cmpwi r0, 0x1DDA # last normal stage sound. Disabled for now.
	cmplwi r0, 0x4000; blt finish			# expansion sounds

tryCloneSound:	
	lis r12, 0x8000			# \
	ori r12, r12, 0x3FF0	# |
	lwz r0, 0(r12)			# |
	cmpwi r0, 0				# | Safety in case VariableParameter.asm file wasn't added!
	beq nullPtr				# /
	mtctr r12
	bctrl
	cmpwi r3, 0			# \ If 0, it nor what created it is a fighter!
	beq normal			# /
	
	lwz r6, 0x70(r3)	# \
	lwz r6, 0x20(r6)	# |
	lwz r6, 0xC(r6)		# |
	lwz r4, 0xD8(r6)	# / Costume ID (LA-Basic 54)
	lwz r5, 0x8(r3)		# \
	lwz r3, 0x110(r5)	# / Character ID
	bla 0x3FF8			# function written earlier in code!	
	cmpwi r3, -1
	bne- foundSound
normal:
	lwz r4, 0x8(r1)		# Restore sound ID
	b finish
nullPtr:				# Below assumes r3 = 0 if going through nullPtr above
	li r3, 0			# Default to normal!
foundSound:
	lwz r4, 0x8(r1)		# Restore sound ID
	rlwimi r4, r3, 16, 4, 15
finish:
	lwz r0, 0x14(r1)
	mtlr r0
	addi r1, r1, 0x10
	blr
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

########################################
[Project+] Sawnd Pop Fix V5c [DukeItOut]
########################################
HOOK @ $801D3760
{
  lbz r12, 0x1(r4)		// loop flag
  lhz r0, 0x4(r4)		// sample rate
  lwz r4, 0xC(r4)		// the original operation
  cmpwi r4, 512;  blt- %END%	// Sample size 512 or less?
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