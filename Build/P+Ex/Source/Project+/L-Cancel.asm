#########################
L-Cancelling Rework [Eon]
#########################
.macro getInt(<id>)
{
    %workModuleCmd(<id>, 0x18)
}
.macro setInt(<id>)
{
.alias arg_Hi = <id> / 0x10000
.alias arg_Lo = <id> & 0xFFFF
    lis r5, arg_Hi
    ori r5, r5, arg_Lo
	%ModuleCmd(0x64, 0x1C)
}
.macro decInt(<id>)
{
    %workModuleCmd(<id>, 0x28)
}
.macro workModuleCmd(<id>, <cmd>)
{
.alias arg_Hi = <id> / 0x10000
.alias arg_Lo = <id> & 0xFFFF
    lis r4, arg_Hi
    ori r4, r4, arg_Lo
	%ModuleCmd(0x64, <cmd>)
}

.macro ModuleCmd(<module>, <cmd>)
{
    lwz r3, 0xD8(r31)
    lwz r3, <module>(r3)
    lwz r12, 0x0(r3)
    lwz r12, <cmd>(r12)
    mtctr r12
    bctrl
}
#initStatus
HOOK @ $80874314
{
	stwu r1, -0x30(r1)
	mflr r0
	stw r0, 0x34(r1)
	stw r31, 0xC(r1)
  stw r30, 0x10(r1)
	mr r31, r4

	li r4, 0
	%setInt(0x1000005a)


  %getInt(0x1000004D)
  cmpwi r3, 1
  beq lcancel
  #controller module get held
  %ModuleCmd(0x5C, 0xAC) 
  mr r30, r3
  #controller module get pressed this frame
  %ModuleCmd(0x5C, 0xA0)
  and r3, r30, r3
  andi. r3, r3, 0x8
  beq end
lcancel: 
	li r4, 0x7
	%setInt(0x1000005a)
end:
  lwz r30, 0x10(r1)
	lwz r31, 0xC(r1)
	lwz r0, 0x34(r1)
	mtlr r0
	addi r1, r1, 0x30
	blr
}

#execStatus
HOOK @ $80874318 
{
	stwu r1, -0x30(r1)
	mflr r0
	stw r0, 0x34(r1)
	stw r31, 0xC(r1)
	stw r30, 0x10(r1)
	mr r31, r4

  %getInt(0x1000004D)
  cmpwi r3, 1
  beq lcancel
  #controller module get held
  %ModuleCmd(0x5C, 0xAC) 
  mr r30, r3
  #controller module get pressed this frame
  %ModuleCmd(0x5C, 0xA0)
  and r3, r30, r3
  andi. r3, r3, 0x8
  beq decCount
lcancel:
	li r4, 0x7
	%setInt(0x1000005a)
	b end


	#decrement lcancel timer every frame, detect shield and set to 8 if so

decCount:
	%decInt(0x1000005a)
end:
	#original command equivalent, writing what was r4 to r3
	mr r3, r31
	lwz r31, 0xC(r1)
  lwz r30, 0x10(r1)
	lwz r0, 0x34(r1)
	mtlr r0
	addi r1, r1, 0x30
  lis r12, 0x808a
  ori r12, r12, 0x019C
  mtctr r12
  bctr
}

word 0x8087431C @ $80B11830
word 0x8087431C @ $80B0DCB8
#execStop
HOOK @ $8087431C 
{
	stwu r1, -0x30(r1)
	mflr r0
	stw r0, 0x34(r1)
	stw r31, 0xC(r1)
	stw r30, 0x10(r1)
  mr r31, r4
  
	#if requirement 0x4E (any shield pressed)
  %getInt(0x1000004D)
  cmpwi r3, 1
  beq lcancel
  #controller module get held
  %ModuleCmd(0x5C, 0xAC) 
  mr r30, r3
  #controller module get pressed this frame
  %ModuleCmd(0x5C, 0xA0)
  and r3, r30, r3
  andi. r3, r3, 0x8
  beq end
lcancel:
	li r4, 0x8
	%setInt(0x1000005a)
end:
	lwz r31, 0xC(r1)
  lwz r30, 0x10(r1)
	lwz r0, 0x34(r1)
	mtlr r0
	addi r1, r1, 0x30
	blr
}


#########################################################################################################################################################################
L-Cancel Landing Lag and Success Rate and Score Display is Auto L-Cancel Option + White L-cancel Flash v3.1a [Magus, Standardtoaster, wiiztec, Eon, DukeItOut, QuickLava]
#
# 3.1: Added replay support
# 3.1a: Fixed Multiman Brawl Alloy crash.
#########################################################################################################################################################################
#check frame = 6 and disable flash
# Code Menu mod made by Desi, based on Per Player versions by wiiztec

.alias CodeMenuStart = 0x804E
.alias CodeMenuHeader = 0x02A8       #Offset of word containing location of the player 1 toggle. Source is compiled with headers for this.
.alias CodeMenuHeaderInputBuffer = 0x2C4

HOOK @ $80874850 
{
	cmpwi r3, 0x5
	mr r31, r3
	bne end
	#soColorBlendModule
	lwz r3, 0xD8(r28)
	lwz r3, 0xAC(r3)
	li r4, 1
	lwz r12, 0(r3)
	lwz r12, 0x20(r12)
	mtctr r12
	bctrl
end:
	lwz r4, 0xD8(r28)
}
#land and detect lcancel state, set flash and stat appropriately
op nop @ $8081BE8C
HOOK @ $8087459C
{
loc_0x0:
                            # Multiman Brawl Fix
  lwz r11, 28(r31)          # \
  lwz r11, 40(r11)          # |
  lwz r11, 16(r11)          # | Obtain Player ID...
  lbz r11, 85(r11)          # /
  cmplwi r11, 0x3           # \ ... and check if it corresponds to a valid slot.
  ble+ validPlayerID        # / If it does, continue through L-Cancel code.
  fdivs f31, f31, f0        # If it doesn't, just do the normal operation...
  b %END%                   # ... and exit.
  
validPlayerID:
#get LA-Basic[90]
  lwz r3, 0xD8(r31)
  lwz r3, 0x64(r3)
  lis r4, 0x1000
  ori r4, r4, 90
  
  lwz r12, 0x0(r3)
  lwz r12, 0x18(r12)
  mtctr r12
  bctrl 
  cmpwi r3, 0
  ble checkForAutoLcancel
trueLcancel:
  #Set R0 to White, branch to Apply Flash
  lis r0, 0xFFFF
  ori r0, r0, 0xFFDC
  bl 0x4  #set LR
  mflr r11 #Store Link Register in R11
  addi r11, r11, 0xC
  bl applyFlash
  li r6, 1
  lfs f0, -23448(r2)
  fmuls f30, f30, f0
  b calcStat

checkForAutoLcancel: 
  lwz r11, 28(r31)          #\Obtain Player ID 
  lwz r11, 40(r11)          #|
  lwz r11, 16(r11)          #|
  lbz r11, 85(r11)          #/
  mulli r11, r11, 0x4       #Determine which player offset to load
  lis r6, CodeMenuStart
  ori r6, r6, CodeMenuHeader    #Load Code Menu Header
  lwzx r6, r6, r11
  lbz r11, 0xB(r6)     #Load Option Selection
  cmpwi r11, 0x1
  beq applyLCancelRedFlash
  cmpwi r11, 0x2
  beq applyModifiedLCancelFlash
  lis r11, 0x805A
  lwz r11, 0xE0(r11)	
  lwz r11, 0x08(r11)		
  lbz r11, 0xE5(r11)	# 0x4D (+ 0x98)
  andi. r11, r11, 1	# bit used for ALC
  bne applyLcancel  #Skip applying fail flash if universal option is on
  lhz r11, 0 (r6)
  add r6, r11, r6   #Load up next toggle (Modifier)
  lhz r11, 0 (r6)
  add r6, r11, r6   #Load up next toggle (Red Flash on L Cancel)
  lbz r11, 0xB(r6)     #Load Option Selection
  cmpwi r11, 0x1
  beq applyRedFlashNoCancel
  b checkForInputBuffer

applyRedFlashNoCancel:
  lis r0, 0xFF00      #Red Flash
  ori r0, r0, 0x0080
  bl 0x4  #set LR
  mflr r11 #Store Link Register in R11
  addi r11, r11, 0xC
  bl applyFlash
  li r6, 0
  b checkForInputBuffer

applyModifiedLCancelFlash:
  lhz r11, 0 (r6)
  add r6, r11, r6
  lfs f0, 0x8 (r6)
  fmuls f30, f30, f0
  lis r0, 0x8000      #Purple Flash for Modified Values
  ori r0, r0, 0x8080
  bl 0x4  #set LR
  mflr r11 #Store Link Register in R11
  addi r11, r11, 0xC
  bl applyFlash
  li r6, 0
  b calcStat

applyLCancelRedFlash:
  lis r0, 0xFF00    #RedFlash
  ori r0, r0, 0x0080
  bl 0x4  #set LR
  mflr r11 #Store Link Register in R11
  addi r11, r11, 0x0C
  bl applyFlash
applyLcancel:
  lfs f0, -23448(r2)
  fmuls f30, f30, f0
  li r6, 0

checkForInputBuffer:
  lwz r11, 28(r31)          #\Obtain Player ID 
  lwz r11, 40(r11)          #|
  lwz r11, 16(r11)          #|
  lbz r11, 85(r11)          #/
  mulli r11, r11, 0x4       #Determine which player offset to load
  lis r4, CodeMenuStart
  ori r4, r4, CodeMenuHeaderInputBuffer    #Load Code Menu Header
  lwzx r4, r4, r11
  lbz r4, 0xB(r4)     #Load Option Selection
  cmpwi r4, 0
  beq calcStat
  lis r0, 0xB000    #Apply Purple Flash indicating Input Buffer
  ori r0, r0, 0xFF80
  bl 0x4  #set LR
  mflr r11 #Store Link Register in R11
  addi r11, r11, 0xC
  bl applyFlash
  li r6, 0

#everything past this point is for the stat
calcStat:
#add one to total aerial count
  cmpwi r6, 0x0
  lis r6, 0x80B8
  ori r6, r6, 0x8394
  lfs f6, 0(r6)
  #gets a pointer to LA-Basic data
  lwz r4, 0xD8(r31)
  lwz r4, 0x64(r4)
  lwz r4, 0x20(r4)
  lwz r4, 0xC(r4)

  lfs f5, 0x238(r4)
  fadds f5, f5, f6
  stfs f5, 0x238(r4)

  lis r5, 0x80B8
  lwz r5, 0x7C28(r5)
  lwz r5, 0x154(r5)
  lwz r5, 0(r5)
  lwz r6, 0x8(r31)
  lwz r6, 0x10C(r6)
  rlwinm r6, r6, 0, 24, 31
  mulli r6, r6, 0x244
  add r5, r5, r6
  lwz r5, 40(r5)
  addi r5, r5, 0x850

#check lcancel occured
  ble loc_0x98
#successful L-cancel
  lis r6, 0x80B8
  ori r6, r6, 0x8394
  lfs f6, 0(r6)
  lfs f4, 572(r4)
  fadds f4, f6, f4
  stfs f4, 572(r4)

loc_0x98:
  lfs f4, 572(r4)
  fdivs f5, f4, f5
  lis r6, 0x80B8
  ori r6, r6, 0x83A0
  lfs f6, 0(r6)
  fmuls f5, f6, f5
  fctiwz f5, f5
  stfd f5, 48(r2)
  lhz r12, 54(r2)
  stw r12, 0(r5)
  fctiwz f30, f30
  stfd f30, 16(r2)
  lhz r12, 22(r2)
  lfd f0, -31632(r2)
  lis r3, 0x4330
  ori r3, r3, 0x0
  stw r3, 16(r2)
  xoris r12, r12, 32768
  stw r12, 20(r2)
  lfd f30, 16(r2)
  fsub f30, f30, f0
  fadds f31, f31, f1
  fdivs f31, f31, f30
  b %end%


applyFlash:
  #Set r0 to color. First 6 digits are color, last 2 digits are opacity.
    #start flash effect
  lwz r3, 0xD8(r31)
  lwz r3, 0xAC(r3)

  #initial colour
  addi r4, r1, 0x18
  stw r0, 0(r4)

  li r5, 1
  lwz r12, 0(r3)
  lwz r12, 0x24(r12)
  mtctr r12
  bctrl

  lwz r3, 0xD8(r31)
  lwz r3, 0xAC(r3)
  #time to transition
  lis r0, 0x40C0
  stw r0, 0x18(r1)
  lfs f1, 0x18(r1)
  #target colour of transition
  lis r0, 0xFFFF
  ori r0, r0, 0xFF00
  addi r4, r1, 0x18
  stw r0, 0(r4)
  #true
  li r5, 1

  lwz r12, 0x0(r3)
  lwz r12, 0x28(r12)
  mtctr r12
  bctrl
  mtlr r11
  blr
}

##############################################
Disable Aerial Attack Landing Lag IASA [Magus]
##############################################
* 04FAF168 800000FF

########################################
Remove grabbing Items with Aerials [Eon]
########################################
CODE @ $80FC2798
{
  word 0x00020000; word 0
  word 0x00020000; word 0
  word 0x00020000; word 0
}

#############################################
Aerial Staling Set before Subaction Set [Eon]
#############################################
#nair
CODE @ $80FC2820
{
  word 0x0C1C0200; word 0x80FB2EC4
  word 0x04000100; word 0x80FB2EBC
}
#fair
CODE @ $80FC2848
{
  word 0x0C1C0200; word 0x80FB2F04
  word 0x04000100; word 0x80FB2EFC
}
#bair
CODE @ $80FC2860
{
  word 0x0C1C0200; word 0x80FB2F1C
  word 0x04000100; word 0x80FB2F14
}
#uair
CODE @ $80FC2888
{
  word 0x0C1C0200; word 0x80FB2F54
  word 0x04000100; word 0x80FB2F4C
}
#dair
CODE @ $80FC28A0
{
  word 0x0C1C0200; word 0x80FB2F6C
  word 0x04000100; word 0x80FB2F64
}

#############################################################
Teeter Cancelling [Shanus, Yeroc, Dantarion, Wind Owl, Magus]
#############################################################
.alias Teeter_Loc = 0x80546120

CODE @ $80546120
{
  word 2; word Teeter_Loc+0x8
  word 0x02010200; word 0x80FAF3EC
  word 0x00070100; word 0x80FABBB4
  word 0x00080000; word 0;
}
CODE @ $80FC1C58
{
  word 0x00070100; word Teeter_Loc
}

##############################################
Ignore Damage Gauge Setting [InternetExplorer]
##############################################
op li r3, 1 @ $8005063C

#####################################################################
Damage Gauge Toggles 3-Frame Buffer 1.1 [InternetExplorer, DukeItOut]
#
# 1.1: Added replay support
#####################################################################
HOOK @ $8085B784
{
	lis r12, 0x805A
	lwz r12, 0xE0(r12)
	lwz r12, 0x08(r12)
	lbz r3, 0xE5(r12)	# 0x4D (+ 0x98)
	andi. r3, r3, 2	# bit used for buffer
	li r3, 0		# \ If the handicap damage gauge rule is enabled . . . 
	beq- %END%		# /
	li r3, 3		# Set the buffer to 3 frames instead of 0
}

###################################################
ALC and Buffer Are Preserved in Replays [DukeItOut]
###################################################
HOOK @ $8004FF64
{
	lis r12, 0x805A
	lwz r12, 0xE0(r12)
	lwz r12, 0x08(r12)
	lbz r6, 0xE5(r12)	# 0x4D (+ 0x98)
	andi. r6, r6, 0xFC	# Clear lowest two bits
	lis r4, 0x9018; 
	
	lbz r5, -0xC94(r4)	# 9017F36C
	cmpwi r5, 1
	bne noBuffer
	ori r6, r6, 0x02	# this bit is being used for buffer
noBuffer:
	lbz r5, -0xC95(r4)	# 9017F36B
	cmpwi r5, 1
	bne noALC
	ori r6, r6, 0x01	# this bit is being used for auto L-cancel
noALC:
	stb r6, 0xE5(r12)	# store this information somewhere a replay can observe it!
	
	lbz r0, 0x1C(r30)	# Original operation
}