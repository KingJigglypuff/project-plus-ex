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

#######################################################
Costume Alternate Soundbank Loader [Squidgy, DukeItOut]
#######################################################
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
	%costumeCheck(Fighter_Ganondorf,20,39,Bank_Ganondorf_OoT) # 0x1016 for 20-39
	
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
HOOK @ $80003FF4
{
	stwu r1, -0x10(r1)
	mflr r0
	stw r0, 0x14(r1)
	stw r4, 0x8(r1)		# Sound ID
	lwz r3, 0x40(r3)	# Sound owner
	
	andi. r0, r4, 0xFFFF
	# cmplwi r4, 0xE500; bgt finish			# anything higher is not attempted
	cmplwi r0, 0x010E; blt nullPtr			# Mario's first sound
	cmplwi r0, 0x1B4C; ble tryCloneSound	# last character sound
	# cmpwi r0, 0x1DDA # last normal stage sound. Disabled for now.
	cmplwi r0, 0x4000; blt nullPtr			# expansion sounds

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