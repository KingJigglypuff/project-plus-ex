# AIS Variables 
#
# 0x000 = "P+" tag 
# 0x004 = Accessor to entire fighter entity
# 0x008 = Accessor to slot
#
# 0x010 = Frames airborne
# 0x014 = Frames grounded
# 0x018 = Lockout window for SCD changes
#
# 0x020 = Port ID
# 0x024 = Sub  ID
####################################################################
LA Variables Expansion and Additional Info System [Magus, DukeItOut]
####################################################################
.alias LA_region = 0x935F0000
.macro Address(<arg1>)
{
.alias temp_Hi = <arg1> / 0x10000
.alias temp_Lo = <arg1> & 0xFFFF
	lis r12, temp_Hi
	ori r12, r12, temp_Lo
}
HOOK @ $80585540
{
  cmpwi r26, 0x2329;  bne+ loc_0x34
  mr r30, r12			# Will be overwritten, later
  %Address(LA_region)	# Area to use as freespace for LA variables
  lhz r7, -0x86(r30)	# Get the port ID
  lhz r6, -0x98(r30)	# Get the sub character ID  
  mulli r11, r7, 0x880		# Allocate 0x880 bytes for each port (total space used for four slots: 0x2200 bytes, up from 0x21C0 for PM)
  mulli r3, r6, 0x2D4		# Allocate 0x2D4 bytes for each sub character (up to 3 slots, allowed, up from 0x2D0 bytes for PM and 0x1C4 bytes in Brawl)
  add r12, r12, r11
  add r12, r12, r3
  li r3, 0x2D4			# \ 0x2D4
  mtctr r3				# | Prepare initialization of memory, here.
  li r3, 0xCC			# /
  subi r26, r12, 1		# Adjust for below
clearLoop:  
  stbu r3, 1(r26)		# \ loop until all cleared for initialization
  bdnz+ clearLoop		# /
  
  subi r28, r25, 0x190	# implied old LA-Basic location using old LA-Float location as a reference, minus the size of all 3 old allocations (0x1C0), but minus 0x30
  stw r28, 0x2D0(r12)	# pointer to store old data pool address into, providing room for more information.
  li r3, 0x64			# 0x190 / 4
  mtctr r3
  li r3, 0
  subi r26, r28, 4		# Adjust for below
clearLoop2:  			
  stwu r3, 4(r26)		# \ loop until all cleared for initialization
  bdnz+ clearLoop2		# /  
  
  stw r7, 0x20(r28)		# Set to the port ID
  stw r6, 0x24(r28)		# Set to the sub character ID
  mulli r3, r7, 0x244	# \
  lis r11, 0x8062		# | Store accessor to fighter entity
  ori r11, r11, 0x32F0	# |
  add r11, r3, r11		# |
  stw r11, 0x04(r28)	# /
  lis r30, 0x8000
  cmplw r24, r30
  mr r30, r24 			# r24 assumed to contain the correct accessor 
  bgt AssumedAccessor
  mr r30, r23 			# if r24 does not contain accessor, it is likely within r23
  						# if not in r23, either cry or needs a module edit
AssumedAccessor:
  stw r30, 0x08(r28)	# Store accessor to slot    
  li  r30, 0x502B		#\ "P+", used as a tag to verify that the space was allocated for character manipulation to other codes.
  stw r30, 0x0(r28)		#/ Leaves an additional 0x1BC bytes (0x004-0x1BB) to use for content
  
  mr r26, r12			# r26 = LA-Basic location	(0x190 bytes, total, 0-99. Originally in Brawl: 0x134 bytes, total 0-76)
  addi r28, r12, 0x190	# r28 = LA-Float location	(0x128 bytes, total, 0-73. Originally in Brawl: 0x080 bytes, total 0-31)
  addi r30, r12, 0x2B8	# r30 = LA-Bit location		(0x18 bytes, total, 0-192. Originally in Brawl: 0x00C bytes, total 0-95)
loc_0x34:
  stw r26, 0x0C(r25)	# \	LA-Basic
  stw r27, 0x10(r25)	# |
  stw r28, 0x14(r25)	# | LA-Float		original set of operations
  stw r29, 0x18(r25)	# |
  stw r30, 0x1C(r25)	# | LA-Bit 
  stw r31, 0x20(r25)	# / 
  blr 
}

###############################################################################
Character ID Fix 2.4 [spunit262, The Paprika Killer, DukeItOut]
# Allows the instance to easily get its accessor, since it is normally private
#
# Both values are also set by the code, above.
###############################################################################
HOOK @ $808152E4
{
	lwz r12, 0x60(r30)	# \
	lwz r12, 0x70(r12)	# |
	lwz r12, 0x20(r12)	# | Access old LA-Basic location
	lwz r12, 0x0C(r12)	# |
	lwz r12, 0x2D0(r12) # /
	stw r3, 0x4(r12)	# Store character accessor there
	lwz r3, 0x34(r3)	# \
	stw r3, 0x8(r12)	# / Store additional accessor here
	lwz r12, 0x3C(r30)	# original operation
}

#########################################################################################################################################
TopN Y Used as SCD Bottom in Air for 10 Frames v3.3 (Memory leak fix, requires above Additional Info System code) v1.1 [Magus, DukeItOut]
#
# v1.1: Fixes an error where the [Boss Battles/Subspace] Ridley fight would trigger a false positive and crash the game.
#########################################################################################################################################
HOOK @ $8073A2A4
{
  lis r8, 0x8120	# \ Used as an address validity check
  lis r9, 0x9380	# /
  lwz r10, 0x98(r27)# \
  lwz r7, 0x70(r10) # |
  lwz r7, 0x20(r7)	# | Access LA-Basic address. If the above system is in place, the address to access the AIS memory will be 0x2D0 off
					  cmplw r7, r8;  	 blt+ notValid # \
					  cmplw r7, r9;  	 bge+ notValid # / Don't account for it if it is unassigned!
  lwz r7, 0x0C(r7)	# /
  lwz r7, 0x2D0(r7);  cmplw r7, r8;  	 blt+ notValid # \
					  cmplw r7, r9;  	 bge+ notValid # / Don't account for it if it is unassigned!


  lwz r12, 0x0(r7)		# \ Look for the "P+" tag that indicates this is AIS memory 
  cmpwi r12, 0x502B		# | Bosses don't have this!!!
  bne- notValid			# /


  lwz r12, 0x14(r7)		# Access AIS variable for frames grounded
  lwz r9, 0x10(r7)		# Access AIS variable for frames airborne
  addi r9, r9, 0x1		# Increment it upwards
  
  lwz r10, 0x7C(r10)	# \
  lhz r10, 0x3A(r10); 	# / Get the action of the character
						cmpwi r10, 0x42;  blt- notInHitstunOrStandardThrow
						cmpwi r10, 0x42;  beq- beingThrown	# 42 = Standard Throw
notInHitstunOrStandardThrow:
						cmpwi r10, 0x72;  beq- platformDrop
						cmpwi r10, 0xCE;  beq- beingThrown
						cmpwi r10, 0xCF;  beq- beingThrown
						cmpwi r10, 0xD7;  beq- beingThrown
						cmpwi r10, 0xDB;  beq- beingThrown
						cmpwi r10, 0xE6;  beq- beingThrown
						cmpwi r10, 0xEE;  beq- beingThrown
  lwz r10, 4(r27)		# \ Get Air/Ground state
  lbz r10, 8(r10);   	# /
						cmpwi r10, 0x2;   beq- inAir
						cmpwi r10, 0x1;   bne- notValid

onGround:
  addi r12, r12, 1
  stw r12, 0x14(r7)
beingThrown:
  li r9, 0		# Reset timing
  b setState
platformDrop:
  lwz r10, 0x98(r27)	# \ 
  lwz r10, 0x14(r10)	# | Animation frame (float)
  lwz r10, 0x40(r10)	# /
  lis r12, 0x3F80		# 1.0
  cmpw r10, r12			# 
  bne+ inAir
  li r12, 9		# 10 frames of lockout total (9 + 1) # any value less than 10 defaults to 10 due to ecb-locking elsewhere, disabled in this state
  stw r12, 0x18(r7)	# Set lockout window for dropping through platforms so that you can't accidentally or intentionally clip with an aerial
inAir:
  cmpwi r9, 1
  bgt setState
  li r12, 0
  stw r12, 0x14(r7)
setState:
  stw r9, 0x10(r7) 	# <- culprit of leak 1 in PM when it was a different location  
  lwz r12, 0x18(r7)
  cmpwi r12, 0 
  ble+ canTransition
  subi r12, r12, 1
  stw r12, 0x18(r7)	# Reduce lockout window
  b forceTransition
canTransition:
  cmpwi r9, 0;   beq- notValid # Not in a state where this is reasonable (i.e. grounded)
  cmpwi r9, 10;  bge- tooLong
forceTransition:  
  lfs f7, 0x64(r1)		# access alternative bottom to the collision diamond
tooLong:
notValid:
  fadds f2, f8, f7	
}

################################################
SCD Bottom Point Initialization Fix v2.0 [Magus]
################################################
HOOK @ $80739AE8
{
  lwz r12, 0x1C(r23)
  lwz r12, 0x28(r12)
  lwz r12, 0x10(r12)
  lbz r12, 0x08(r12)
  cmpwi r12, 0x2
  bne+ loc_0x1C
  lfs f1, 0x08(r31)

loc_0x1C:
  stfs f1, 0(r25)
}

####################################
Ground Stabilization Fix [DukeItOut]
####################################
HOOK @ $808386F8
{
	lwz r3, 0x1C(r31)
	lwz r3, 0x28(r3)
	lwz r3, 0x10(r3)
	lbz r3, 0x8(r3)		# Get the air/ground state
	cmpwi r3, 1
	bne+ skip
	lwz r12, 0x70(r31)
	lwz r12, 0x20(r12)
	lwz r12, 0xC(r12)
	lwz r12, 0x2D0(r12)
	lwz r4, 0x14(r12)
	cmpwi r4, 0
	bne+ skip
	stw r4, 0x10(r12)	# Clear air frame count
	stw r3, 0x14(r12)	# Set ground frame count
skip:
	cmpwi r0, 0		# Original operation
}


###########################################
TopN Y and SCD Bottom Reference Fix [Magus]
###########################################
HOOK @ $80134200
{
  lwz r0, 0x18(r5)
  mflr r10
  lis r9, 0x8073;  ori r9, r9, 0xAA34;  cmpw r10, r9;   bne+ %END%
  lwz r10, 0x04(r30);  lbz r9, 8(r10);  cmpwi r9, 0x1;  beq+ %END%
  lwz r10, 0x64(r10)
  lwz r10, 0x30(r10)
  lwz r10, 0x18(r10)
  lwz r0,  0x10(r10)
}

######################################
Stage Collisions Update TopN Y [Magus]
######################################
.macro JumpToNewCode()
{
  lis r10, 0x8058
  ori r10, r10, 0x5470
  mtctr r10
  bctrl 
}
CODE @ $80585470
{
  lwz r10, 0x64(r3)
  lwz r10, 0x30(r10)
  lwz r10, 0x18(r10)
  lwz r3,  0x60(r3)
  lfs f1,  0x18(r3)
  lfs f2,  0x18(r4)
  fsubs f2, f2, f1
  lfs f1,  0x10(r10)
  fadds f1, f1, f2
  stfs f1, 0x10(r10)
  blr 
}
HOOK @ $8011B5F4
{
  %JumpToNewCode() 
}
HOOK @ $8011E6FC
{
  %JumpToNewCode() 
}
HOOK @ $8011F0CC
{
  %JumpToNewCode() 
}
HOOK @ $8011FC18
{
  %JumpToNewCode() 
}