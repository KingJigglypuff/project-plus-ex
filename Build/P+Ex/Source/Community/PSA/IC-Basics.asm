##################################################
Custom Integer IC-Basics 1.1 [DukeItOut, Eon]
##################################################
#
# Custom int return values in the IC-20000 range
# Please add new ones to this code rather than
# making new hooks!
#
# 1.0:
#
# IC-Basic[20027] Terrain [Eon]
# IC-Basic[20028] Throwing/Thrown Character ID [DukeItOut]
#
# 1.1:
#
# IC-Basic[20029] Event Match ID [DukeItOut]
# IC-Basic[20030] Frames In Air [DukeItOut]
##################################################
HOOK @ $807966B0
{
	cmplwi r0, 26;  ble+ %END%		# Original operation, skip if a Brawl IC-Basic!	
	cmplwi r0, 27;	beq Terrain		# IC-Basic[20027] = Terrain
	cmplwi r0, 28;  beq ThrowID		# IC-Basic[20028] = Instance ID of other character in throw
	cmplwi r0, 29;  beq EventID		# IC-Basic[20029] = ID of Event Match (-1 if not an event match, 100+ if Co-Op)
	cmplwi r0, 30;  beq FramesAir	# IC-Basic[20030] = frames in air
	li r3, 0			# Default return value for invalid variable entries
	b finish
#	
Terrain:				# Return Terrain for IC-Basic[20027]
    lwz r3, 0xD8(r4)	# r4 main index
    li r4, 8
    li r5, 0
    lwz r3, 0x10(r3)
    lwz r12, 0x8(r3)
    lwz r12, 0x100(r12)
    mtctr r12
    bctrl
	b finish
#
ThrowID:				# Return Throw-Involved Character ID for IC-Basic[20028]
	lwz r3, 0x60(r4)
	lwz r3, 0x18(r3)		# Linkage to character throwing or being thrown (Most recent object acquired)
	cmpwi r3, 0				# \
	beq noThrownCharacter	# / Handler for if no object is attached!
	
	lwz r3, 0x10(r3)	# \
	lwz r3, 0x44(r3)	# | Get to base of object information 
	lwz r4, 0x08(r3)	# /
	
    lwz r12, 0x3C(r4)	# \
    lwz r12, 0xA4(r12)	# | Get object type
	mtctr r12			# |
	bctrl				# /
	cmpwi r3, 0				# \ Fighters are type 0!
	bne noThrownCharacter	# /
	
	lwz r3, 0x110(r4)	# Get character instance ID
	b finish
noThrownCharacter:
notEventID:
	li r3, -1			# Default (Mario is 0, so can't use that.)
	b finish
EventID:

	lwz r3, -0x43C0(r13)	# get the scene manager instance
	lwz r4, 0x10(r3)
	lwz r4, 0x08(r4)
	cmpwi r4, 8; bne notEventID	# Check if currently in an event match
	lwz r3, 0x7C(r3)		# Event scene
	lwz r4, 0x368(r3)		# 1 if Normal Event, 2 if Co-Op
	lwz r3, 0x360(r3)		# Event Match ID
	
	li r12, 0			# Default
	cmpwi r4, 1; blt+ notEventID		# Is it a normal Event Match?
	cmpwi r4, 2; bgt- notEventID		# Is it a co-op Event Match?
	bne notCoOpEvent
CoOpEvent:
	li r12, 2000		# Just to make it easier to identify from PSA	
notCoOpEvent:
	
	addi r3, r3, 1			# Make it match with what is seen on-screen
	add r3, r3, r12			# 20xx for Co-Op Event Match IDs
	b finish
FramesAir:
	lwz r3, 0x70(r4)
	lwz r3, 0x20(r3)
	lwz r3, 0x0C(r3)
	lwz r3, 0x2D0(r3)
	lwz r3, 0x10(r3)		# Frames airborne (AIS variable)
	
#	
finish:
    lis r12, 0x8079
    ori r12, r12, 0x6A20
    mtctr r12
    bctr
}

##########################################
Custom Float IC-Basics[DukeItOut]
##########################################
#
# Custom float value returns
#
# IC-Basic[1100] = Current Knockback Speed
##########################################
HOOK @ $808548EC
{
	ble+ %END%		# if 36 or less, it's an already-existing IC-Basic!
		
	cmpwi r0, 100; beq+ Knockback
	
	b invalid

Knockback:
	lwz r12, 0x88(r31)
	lwz r12, 0x14(r12)
	lwz r12, 0x4C(r12) # Knockback info
	lfs f0, 0x8(r12)	# Current X Knockback
	lfs f1, 0xC(r12)	# Current Y Knockback
	fmuls f0, f0, f0	# X^2
	fmuls f1, f1, f1	# Y^2
	fadds f1, f0, f1	# (X^2)+(Y^2)
	bla 0x400D94		# sqrt of f1. Vector length of knockback.
	b finish
#	
invalid:
	fsubs f1, f1, f1	# Return Zero if not valid
finish:
    lis r12, 0x8085
    ori r12, r12, 0x52A4
    mtctr r12
    bctr
}


###############################
Custom IC-Variable Engine [Eon]
###############################
#exposes a range from IC-Basic[30000] to IC-Basic[30031]
#writes a pointer at 0x80548D00 to the function array.

#write pointer to function for IC-variable, e.g. to add IC-Basic[30000+i] write function pointer at (0x80548D00) + i*0x4

HOOK @ $8079721C
{
  cmpwi r4, 30000
  blt original
  subi r0, r4, 30000
  rlwinm r0, r0, 2, 0, 29
  lis r3, 0x8054
  ori r3, r3, 0x8D00
  lwz r3, 0x0(r3)
  lwzx r12, r3, r0
  cmpwi r12, 0
  beq exit  #if unset, return 0
  mr r3, r29  #r3 = soModuleAccessor of object
              #r4 = the IC-Basic requested
  mr r5, r31  #r5 = i honestly dont know but this is important enough to be passed through function calls in the other accessors so you get it too
  mtctr r12
  bctrl

exit:
  lis r12, 0x8079
  ori r12, r12, 0x72B4
  mtctr r12
  bctr
original:
  lwz r3, 0x8(r3)
}

  .BA<-functions  
  .BA->$80548D00 #function array pointer
  .RESET
  .GOTO->end
functions:
int[32] 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
end:

##################################
Timestamp at IC-Basic[30000] [Eon]
##################################
#first two lines get function pointer
  .BA<-CustomCommand
* 42100000 00000008 #BA+=8 to abuse Pulse command as an easy way to write a block of code
#get function array, write to wanted index, in this case 4*0x0 = 0x0
* 48000000 80548D00
* 54010000 00000000 #set second word to 4*IC-variable you want it to be
  .RESET
  .GOTO->end

CustomCommand:
PULSE
{
    stwu r1, -0x10(r1)
    mflr r0
    stw r0, 0x14(r1)

    #gfSceneManager.getInstance() static function
    #could just be replaced by `lwz r3, -0x43C0(r13)` if you feel like it`
    lis r12, 0x8002
    ori r12, r12, 0xD018
    mtctr r12 
    bctrl 

    #r4 = "scMelee"
    lis r4, 0x8070
    addi r4, r4, 0x1B50
    addi r4, r4, 64

    lis r12, 0x8002
    ori r12, r12, 0xD3F4
    mtctr r12 
    bctrl #gfSceneManager.searchScene("scMelee")

    lwz r3, 0x54(r3) #\scMelee.stOperatorRuleMelee.currentFrameCounter 
    lwz r3, 0xE8(r3) #/
    
    lwz r0, 0x14(r1)
    mtlr r0
    addi r1, r1, 0x10
    blr
}
end:

###############################################################################################
Item Custom IC-Basic[21021] = EmitterTask, IC-Basic[21022] = TeamOwnerTask [MarioDox, Kapedani]
###############################################################################################
HOOK @ $809CA83C #getVariableIntCore/[itValueAccesser]
{
    cmplwi    r0, 21        #original op + 1
    beq-    customIC_21
    cmplwi  r0, 22
    bne+    %END%
customIC_22:
    lwz r3, 0xd8(r28)   # \
    lwz r3, 0x18(r3)    # |
    lwz r12, 0x0(r3)    # | moduleAccesser->moduleEnumeration->teamModule->getTeamOwnerTaskId()
    lwz r12, 0x28(r12)  # |
    mtctr r12           # |
    bctrl               # /
    b gotTaskId
customIC_21:
    lwz    r3, 0x8C8(r3)    #emitterTaskId
gotTaskId:
    addis    r0, r3, 0x1
    cmplwi    r0, 0xFFFF
    beq-    customIC_21_fail
    lis    r12, 0x8002        #\
    ori    r12, r12, 0xDC40    #| getTask/[gfTask]
    mtctr    r12            #|
    bctrl                #/
    b    goToEnd
customIC_21_fail:
    li    r3, 0
goToEnd:
    lis    r12, 0x809C
    ori    r12, r12, 0xAC74
    mtctr    r12
    bctrl
}

##################################################################################################
Character Team via IC-Basic (Eon IC-Variable Engine) v1.0.0 [QuickLava]
#
# Require's Eon's "Custom IC-Variable Engine" code!
# Mapped to IC-Basic[30001] by default, can be changed using the line below.
# When in Team Modes, returns 0-3 for Red Team through Green Team. Returns -1 otherwise!
##################################################################################################
#first two lines get function pointer
  .BA<-GetTeamNum
* 42100000 00000008 # BA+=8 to abuse Pulse command as an easy way to write a block of code
* 48000000 80548D00 # Get function array...
* 54010000 00000004 # ... and write to wanted index (set second word to 4*IC-variable ID you want).
  .RESET
  .GOTO->end

GetTeamNum:
PULSE
{
	lis r12, 0x805A				# \
	lwz r12, 0x00E0(r12)		# / Load GameGlobal ptr into r12
	lwz r12, 0x8(r12)			# Get GlobalModeMelee ptr
	lbz r3, 0x13(r12)			# Get Team Battle status!
	subi r3, r3, 1				# Subtract 1 from Team Battle status, so 0 if on, -1 if not.
	cmpwi r3, 0					# And if that put us below 0...
	blt exit					# ... then we can exit!

								# Otherwise, we can continue and grab the actual Team ID.
	stwu r1, -0x10(r1)			# Allocate some stack space to store LR...
    mflr r0						# ... pull LR into r0...
    stw r0, 0x14(r1)			# ... and store it on the stack.
	
								# Note: r29 is soModuleAccesser ptr, from Engine Hook
	lwz r3, 0xD8(r29)			# Get soModuleEnumeration ptr
	lwz r3, 0x64(r3)			# Get soWorkManageModuleImpl ptr
	lwz r12, 0x00(r3)			# Get ptr to vTables
	lwz r12, 0x18(r12)			# Get ptr to getInt()
	lis r4, 0x1000				# Set r4 to 0x10000000 to grab LA-Basic[0]!
	mtctr r12					# Move func ptr to CTR
	bctrl						# Execute! r3 is Entity ID!
	
	mr r4, r3					# Move Entity ID to r4
	lis r3, 0x8062				# \
	ori r3, r3, 0x9A00			# / Set r3 to ftManager addr
	lis r12, 0x8081				# \
	ori r12, r12, 0x59E4		# |
	mtctr r12					# / Load ptr to ftManager::getOwner() into CTR
	bctrl						# Execute! r3 is ptr to this character's ftOwner
	
	lis r12, 0x8081				# \
	ori r12, r12, 0xBD78		# | 
	mtctr r12					# / Load ptr to ftOwner::getTeam() into CTR
	bctrl						# Execute! r3 is now team ID!
	
	lwz r0, 0x14(r1)			# Retrieve store LR value...
    mtlr r0						# ... move it into Link Register...
    addi r1, r1, 0x10			# ... and deallocate stack space.
exit:
    blr							# Return to Engine body.
}
end: