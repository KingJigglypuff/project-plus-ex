######################################################################################
[Legacy TE] ASL Helper for Solo Modes, SFX/GFX, and Replays V1.3 [DukeItOut, Kapedani]
#
# 1.1: Changes hookpoint so that D-pad inputs don't get replaced by control stick ones
# 			This fixes an issue where the D-pad couldn't get read when disabling it
#			on the SSS with a different code!
# 1.2: Adds support for Wiimotes and Wiimote+Nunchuk
# 1.3: Add support for >=0x4000 forced ASL
######################################################################################
.alias gfSceneManager__searchScene                = 0x8002d3f4
.alias ASL_BUTTON						= 0x800B9EA2

.macro LoadAddress(<arg1>,<arg2>)
{
.alias temp_Hi = <arg2> / 0x10000 
.alias temp_Lo = <arg2> & 0xFFFF
	lis <arg1>, temp_Hi
	ori <arg1>, <arg1>, temp_Lo 
}
.macro shd(<storeReg>, <addrReg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <addrReg>, temp_Hi
    sth     <storeReg>, temp_Lo(<addrReg>)
}
.macro BranchBitSet(<arg1>,<arg2>)
{
	andi. r0, r3, <arg1>; 
	bne- <arg2>
}
.macro call(<addr>)
{
  %LoadAddress(r12, <addr>)
  mtctr r12
  bctrl    
}

# This isn't optimal, but too many codes use the address 800B9EA0 at this point to move it.
HOOK @ $800B9E98
{
	stw r3, 0x8(r30)	# \
	stw r4, 0x14(r30)	# | Operations replaced
	stw r0, 0x20(r30)	# /
    %LoadAddress(r12,0x800B9EA4)# \
	mtctr r12					# | Skip eight bytes used for info
	bctr						# /
}
HOOK @ $800B99FC
{
  %LoadAddress(r4,0x800B9EA4)
  lis r3, 0x8070		
  lwz	r12, -0x43C0(r13) # gfSceneManager
  lwz r11, 0x4(r12)                             # \
  lwz r11, 0x0(r11)                             # | skip if gfSceneManager->currentScene->sceneName = "scMelee"
  ori r0, r3, 0x0250; cmpw r0, r11; beq abort   # /
  lwz r12, 0x10(r12)	# \ gfSceneManager->currentSequence->sequenceName
  lwz r12, 0x0(r12)		# /
  #ori r0, r3, 0x3028; cmpw r0, r12; beq eventMatch	# "sqEvent"
  ori r0, r3, 0x39D8; cmpw r0, r12; beq replay		# "sqReplay"
  ori r0, r3, 0x1B54; cmpw r0, r12; beq multiplayer	# "sqVsMelee"
  ori r0, r3, 0x2024; cmpw r0, r12; beq multiplayer	# "sqSpMelee"
  #ori r0, r3, 0x24D0; cmpw r0, r12; beq classic		# "sqSingleSimple"
  #ori r0, r3, 0x27E0; cmpw r0, r12; beq allStar		# "sqSingleAllStar"
  ori r0, r3, 0x3850; cmpw r0, r12; beq training	# "sqTraining" 
  ori r0, r3, 0x2130; cmpw r0, r12; beq rotation	# "sqQuMelee" 
  ori r0, r3, 0x1F10; cmpw r0, r12; beq tourney   # "sqToMelee"
myMusicCheck:
  ori r0, r3, 0x17B0; cmpw r0, r12; bne abort     # "sqMenuMain" is the only one this should currently run for
  lis r12, 0x805C		# \ 805B8BC4
  lwz r12, -0x743C(r12)	# /
  lwz r12, 0x3D0(r12)	# Get current page of sqMenuMain
  cmpwi r12, 0xC		# Is it My Music's?
  bne abort				# If not, bail.
#  b multiplayer
# Additional, more strict tests needed for My Music
eventMatch:
classic:
allStar:
#   lwz r3, 0xC(r1)		# Get the game input without the control stick influence
#   mflr r0
#   stw r0, -4(r4)		# preserve link register
#   %LoadAddress(r4,0x800B9F84)
#   lbz r4, 3(r4);  	  cmpwi r4, 0x3;  beq- single_default #Event mode always loads default.
#   %BranchBitSet(0x8,single_R)
#   %BranchBitSet(0x4,single_default)
#   %BranchBitSet(0x1,single_L)
#   %BranchBitSet(0x2,single_Z)
#   %LoadAddress(r4,0x803F8C3C) 	# \
#   mtctr r4						# | rand
#   bctrl 						# /
#   andi. r3, r3, 0x3;  cmpwi r3, 0x0;  beq- single_default
# 					  cmpwi r3, 0x1;  beq- single_R
# 					  cmpwi r3, 0x2;  beq- single_L

# single_Z:
#   li r0, 0x10;  b single
# single_L:
#   li r0, 0x40;  b single
# single_R:
#   li r0, 0x20;  b single
# single_Y:	# Only forced in event match contexts
#   li r0, 0x800; b single
# single_X:
#   li r0, 0x400; b single
# single_default:
#   li r0, 0x0;	b single
replay:
myMusic:
multiplayer:
training:
rotation:
tourney:
  lhz r12, -2(r4)     # \ 
  cmpwi r12, 0x4000   # | check if current input >= 0x4000
  bge+ abort          # /
  li r3, 0
	lis r5, 0xFFFF		  # \ Filter for ZL and ZR, see below. (FFFF 3FFF) 
	ori r5, r5, 0x3FFF	# /
	li r6, 0
	li r7, 0
portLoop:
	lis r12, 0x805B
	ori r12, r12, 0xAD00
	lwzx r3, r12, r6
	cmpwi r6, 0x100
	bge- Wiimote
GameCube:
	or r7, r7, r3	# Set the buttons as expected
	b buttonTested
Wiimote:
	and r3, r3, r5	# Filter out ZR and ZL to treat like Z on a Classic Controller.
	andis. r0, r3, 0xFFFF; beq GameCube		# Treat non-Wiimote/Nunchuk unique buttons as GC for Classic

	andis. r0, r3, 0x40; beq notWiiB;						# Wiimote B?


	andi. r0, r3, 0xF; beq notWiiB							# Act as a modifier to get other inputs
	andi. r0, r3, 1; beq notWiiMinusLeft; ori r7, r7, 0x40		# Wiimote B&Left? GC L
notWiiMinusLeft:
	andi. r0, r3, 8; beq notWiiMinusUp; ori r7, r7, 0x20		# Wiimote B&Up? GC R
notWiiMinusUp:
	andi. r0, r3, 2; beq notWiiMinusRight; ori r7, r7, 0x10		# Wiimote B&Right? GC Z
notWiiMinusRight:
	andi. r0, r3, 4; beq notWiiB; ori r7, r7, 0x400				# Wiimote B&Down? GC X

	
notWiiB:	
	andis. r0, r3, 0x04; beq notWiiC; ori r7, r7, 0x400		# Wiimote C? Treat like GC X
notWiiC:
	andis. r0, r3, 0x20; beq notWiiA; ori r7, r7, 0x20		# Wiimote A? Treat like GC R
notWiiA:
	andis. r0, r3, 0x10; beq notCCPlus; ori r7, r7, 0x1000	# Classic +? Treat like GC Start
notCCPlus:
	andis. r0, r3, 0x08; beq notWiiMinus; 
		
	andi. r0, r3, 0x1000; beq justWiiMinus	# Is Wiimote + also pressed?
	ori r7, r7, 0x800; b notWiiMinus	# Wiimote -&+? Treat like GC Y
justWiiMinus:
	ori r7, r7, 0x400					# Wiimote -? Treat like GC X
notWiiMinus:
	

buttonTested:	
	addi r6, r6, 0x40
	cmpwi r6, 0x200
	blt+ portLoop
	
	mr r0, r7
  #lwz r0, 0xC(r1) #;  b setStage	# Get the input, without the control stick
# single:
#   %LoadAddress(r4,0x800B9EA4)
#   lwz r3, -4(r4)
#   mtlr r3
setStage:
  stw r0, -4(r4)		# Stores input
abort:
  stw r30, -8(r4)
  lwz r0, 0xC(r1)		# Original operation, gets inputs, except for the control stick.
}

HOOK @ $800B9F80
{
  lwz r0, 0xB4(r1)
  mtlr r0
  addi r1, r1, 0xB0
  blr 
}
HOOK @ $806A51D0
{
  sth r29, 0x42(r30)
  %LoadAddress(r28,0x800B9F84)
  sth r29, 0x2(r28)
}

HOOK @ $806ee8fc  # sqEvent::setupEvent
{
  stb	r0, 0x1C(r27) # Original operation
  lhz r12, 0x22(r18)          # \ set asl button from event node
  %shd(r12, r11, ASL_BUTTON)  # /
}

