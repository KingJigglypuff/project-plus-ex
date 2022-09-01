######################################################################################
[Legacy TE] ASL Helper for Solo Modes, SFX/GFX, and Replays V1.1 [DukeItOut]
#
# 1.1: Changes hookpoint so that D-pad inputs don't get replaced by control stick ones
# 			This fixes an issue where the D-pad couldn't get read when disabling it
#			on the SSS with a different code!
######################################################################################
.macro LoadAddress(<arg1>,<arg2>)
{
.alias temp_Hi = <arg2> / 0x10000 
.alias temp_Lo = <arg2> & 0xFFFF
	lis <arg1>, temp_Hi
	ori <arg1>, <arg1>, temp_Lo 
}
.macro BranchBitSet(<arg1>,<arg2>)
{
	andi. r0, r3, <arg1>; 
	bne- <arg2>
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
  lis r12, 0x805B
  lwz r12, 0x50AC(r12)
  lwz r12, 0x10(r12)	# \
  lwz r3, 0xC(r12)		# | Bail if current mode is NOT a menu
  cmpwi r3, 6			# | (this avoids issues when on a transforming stage, since they can poll menu information for a split-second)
  lwz r12, 0x0(r12)		# | 
  bgt- abort			# /
  lis r3, 0x8070		
  ori r0, r3, 0x3028; cmpw r0, r12; beq eventMatch	# "sqEvent"
  ori r0, r3, 0x39D8; cmpw r0, r12; beq replay		# "sqReplay"
  ori r0, r3, 0x1B54; cmpw r0, r12; beq multiplayer	# "sqVsMelee"
  ori r0, r3, 0x2024; cmpw r0, r12; beq multiplayer	# "sqSpMelee"
  ori r0, r3, 0x24D0; cmpw r0, r12; beq classic		# "sqSingleSimple"
  ori r0, r3, 0x27E0; cmpw r0, r12; beq allStar		# "sqSingleAllStar"
  ori r0, r3, 0x3850; cmpw r0, r12; beq training	# "sqTraining"  
myMusicCheck:
  ori r0, r3, 0x17B0; cmpw r0, r12; bne abort     # "sqMenuMain" is the only one this should currently run for
  lis r12, 0x805C		# \ 805B8BC4
  lwz r12, -0x743C(r12)	# /
  lwz r12, 0x3D0(r12)	# Get current page of sqMenuMain
  cmpwi r12, 0xC		# Is it My Music's?
  bne abort				# If not, bail.
  b multiplayer
# Additional, more strict tests needed for My Music
eventMatch:
  lwz r12, 0x8(r24)		# \
  lwz r12, 0x17B8(r12)	# | Retrieve event match number and add 1 for human readability 
  addi r12, r12, 1		# /
  lis r3, 0x815E		# \ Is it co-op for Event Match?
  lwz r3, 0x7DBC(r3)	# | Those events are different if it is!
  cmpwi r3, 0			# |
  bne co_op_event		# /
single_event:
  cmpwi r12,  4;	beq- single_L	# Event Match  4 (A Skyworld Engagement), load Brawl Skyworld
  cmpwi r12,  6;	beq- single_X	# Event Match  6 (Bird in the Darkest Night), loads Brinstar (Planet Zebes' X-alt)
  cmpwi r12,  9;	beq- single_X	# Event Match  9 (Clash of Swords), load Castle Siege Brawl
  cmpwi r12, 17;	beq- single_L	# Event Match 17 (Brisk Expedition), load Summit (Infinite Glacier's L-alt)
  cmpwi r12, 19;	beq- single_Y	# Event Match 19 (Metal Battle in Metal Cavern), load Metal Cavern 64
  cmpwi r12, 26;	beq- single_Y	# Event Match 26 (Carefree Concert), load K.K. Smashville
  cmpwi r12, 33;	beq- single_L	# Event Match 33 (Advent of the Evil King), loads Ganon's Castle (Hyrule Castle's L-alt)
  cmpwi r12, 38;	beq- single_X	# Event Match 38 (The Wolf Hunts The Fox), load tilting version of Lylat
  cmpwi r12, 41;	beq- single_R	# Event Match 41 (The FINAL final battle), loads PM Final Destination
  b single_default
co_op_event:
  cmpwi r12, 7;		beq- single_Z	# Event Match  7 (Battle of the Dark Sides), loads Bridge of Eldin 
  cmpwi r12, 17;	beq- single_L	# Event Match 17 (Sonic & Mario), loads Brawl Green Hill Zone
  cmpwi r12, 20;	beq- single_L	# Event Match 20 (The Final Battle for Two), loads Brawl FD (with Melee FD collisions)
  b single_default
classic:
allStar:
  lwz r3, 0xC(r1)		# Get the game input without the control stick influence
  mflr r0
  stw r0, -4(r4)		# preserve link register
  %LoadAddress(r4,0x800B9F84)
  lbz r4, 3(r4);  	  cmpwi r4, 0x3;  beq- single_default #Event mode always loads default.
  %BranchBitSet(0x8,single_R)
  %BranchBitSet(0x4,single_default)
  %BranchBitSet(0x1,single_L)
  %BranchBitSet(0x2,single_Z)
  %LoadAddress(r4,0x803F8C3C) 	# \
  mtctr r4						# | rand
  bctrl 						# /
  andi. r3, r3, 0x3;  cmpwi r3, 0x0;  beq- single_default
					  cmpwi r3, 0x1;  beq- single_R
					  cmpwi r3, 0x2;  beq- single_L

single_Z:
  li r0, 0x10;  b single
single_L:
  li r0, 0x40;  b single
single_R:
  li r0, 0x20;  b single
single_Y:	# Only forced in event match contexts
  li r0, 0x800; b single
single_X:
  li r0, 0x400; b single
single_default:
  li r0, 0x0;	b single
replay:
myMusic:
multiplayer:
training:
  lwz r0, 0xC(r1);  b setStage	# Get the input, without the control stick
single:
  %LoadAddress(r4,0x800B9EA4)
  lwz r3, -4(r4)
  mtlr r3
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