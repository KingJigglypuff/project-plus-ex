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
L-Cancel Landing Lag and Success Rate and Score Display is Auto L-Cancel Option + White L-cancel Flash v3.5 [Magus, Standardtoaster, wiiztec, Eon, DukeItOut, QuickLava]
#
# 3.1: Added replay support
# 3.1a: Fixed Multiman Brawl Alloy crash.
# 3.5: Removed Purple Flash on Missed L-Cancel w/ Input Buffer On, Reworked Logic so Fail Flash Triggers Only if Enabled!
#########################################################################################################################################################################
#check frame = 6 and disable flash
# Code Menu mod made by Desi, based on Per Player versions by wiiztec

.alias CM_P1_ALC_LOC_HI = 0x804E
.alias CM_P1_ALC_LOC_LO = 0x02A8

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
HOOK @ $8087459C                    # [0x198 bytes into symbol "execStatus/[ftStatusUniqProcessLanding]/ft_status_uniq_pr" @ 0x808746B8]
{                                   
  lfs f0, -0x5B98(r2)               # Load default L-Cancel Lag Multiplier, since we may need it later!
                                    # Get LA-Basic[90]
  lwz r3, 0xD8(r31)                 # \
  lwz r3, 0x64(r3)                  # / Get soWorkManageModule* from ModuleAccesser
  lis r4, 0x1000                    # \
  ori r4, r4, 90                    # / Prepare LA-Basic[90] ID (0x1000005A) in r4
  lwz r12, 0x0(r3)                  # \
  lwz r12, 0x18(r12)                # |
  mtctr r12                         # | Call getInt to get value!
  bctrl                             # / 
  cmpwi cr7, r3, 0                  # Check if returned value is 0 (in CR7, to reuse it later)...
  ble cr7 checkForAutoLcancel       # ... and if so, L-Cancel input failed, check for Auto L-Cancel!
                                    
trueLcancel:                        # Otherwise, the input succeeded!
  fmuls f30, f30, f0                # Apply Landing Lag Multiplier Reduction
  lis r0, 0xFFFF                    # \
  ori r0, r0, 0xFFDC                # / Prepare Flash Color
  b applyFlashThenCalcStat          # Apply the flash and calc!
                 
				 
checkForAutoLcancel:                
  li r0, 0x00                       # Assume by default that we don't want Fail Flash, so zero our Flash Color to start!
                                    # Then, check the Code Menu's settings for this slot!
  lwz r12, 0xD8(r31)                # \
  lwz r12, 0x10(r12)                # / Get soGroundModule* from ModuleAccesser...
  lwz r12, 0x28(r12)                # \ 
  lwz r12, 0x10(r12)                # |
  lbz r12, 0x55(r12)                # / ... somehow get Player ID through the soGroundShape Vector?
  cmplwi r12, 0x04                  # Check if this Fighter is in Slot 4 or higher...
  bge- checkGlobalALC               # ... and if so, they don't have Code Menu lines to check, so skip to checking Global ALC!
             
			 
handleCodeMenuALCSettings:                   
  lis r11, CM_P1_ALC_LOC_HI         # \
  rlwimi r11, r12, 2, 16, 29        # | Get this Fighter's ALC Line Address in r11!
  lwz r11, CM_P1_ALC_LOC_LO(r11)    # /
  lwz r12, 0x08(r11)                # Load the current setting from the line.
  cmplwi cr1, r12, 0x1              # Compare the current setting against 0x1, storing the result in the CR1 for re-use later!
  lhz r12, 0x00(r11)                # Get the ALC line's size...
  lhzux r12, r11, r12               # ... LHZUX to push r11 forward to the ALC Modifier Line, while also grabbing its size!
  ble+ cr1, checkFailFlash          # If the setting is less than or equal to 0x1, we're not on Modified ALC, so skip handling it!
  lfs f0, 0x08(r11)                 # Otherwise though, replace the default multiplier with the one specified in the ALC Modifier line!
  lis r0, 0x8000                    # \ 
  ori r0, r0, 0x8080                # / Additionally, overwrite our Flash Color with Purple to signify we used the Modified Multiplier...
  b applyCodeMenuALCMult            # ... and skip checking for Fail Flash, cuz we want Modified Flash to overrule that!
checkFailFlash:                     
  add r11, r11, r12                 # Jump forward now again to the Fail Flash Line...
  lwz r12, 0x08(r11)                # ... and load its current setting.
  cmplwi r12, 0x00                  # Check if it's set to off...
  beq+ applyCodeMenuALCMult         # ... and if so, just skip to applying the multiplier.
  lis r0, 0xFF00                    # \ 
  ori r0, r0, 0x0080                # / Otherwise though, set our Flash Color to Red instead!
applyCodeMenuALCMult:               
  blt+ cr1, checkGlobalALC          # Finally, if Code Menu ALC was off, then skip down to checking if Global ALC was instead!
  fmuls f30, f30, f0                # Otherwise though, apply our Landing Lag Multiplier...
  b applyFlashThenCalcStat          # ... then apply flash and calc!
                             
							 
checkGlobalALC:                     # Next, check if Global ALC is on!
  lis r12, 0x805A                   # 
  lwz r12, 0xE0(r12)	            #
  lwz r12, 0x08(r12)		        #
  lbz r12, 0xE5(r12)	            # 0x4D (+ 0x98)
  andi. r12, r12, 1                 # Check Global ALC Bit...
  beq applyFlashThenCalcStat        # ... and if it was 0, then Global ALC is off, skip applying our multiplier!
  fmuls f30, f30, f0                # Otherwise though, apply Landing Lag Multiplier, and flow into applying flash!

  
applyFlashThenCalcStat:             # Flash then Calc! Set r0 to color (0xRRGGBBAA)!
  lwz r3, 0xD8(r31)                 # \
  lwz r3, 0xAC(r3)                  # / Get soColorBlendModule from ModuleAccesser
  addi r4, r1, 0x18                 # \
  stw r0, 0(r4)                     # / Setup Initial Colour
  li r5, 1                          # 
  lwz r12, 0(r3)                    # \
  lwz r12, 0x24(r12)                # |
  mtctr r12                         # | Call setFlash!
  bctrl                             # / 
                                    # 
  lwz r3, 0xD8(r31)                 # \
  lwz r3, 0xAC(r3)                  # / Get soColorBlendModule from ModuleAccesser again.
  lis r0, 0x40C0                    # \
  stw r0, 0x18(r1)                  # | Setup time to transition.
  lfs f1, 0x18(r1)                  # /
  lis r0, 0xFFFF                    # \
  ori r0, r0, 0xFF00                # |
  addi r4, r1, 0x18                 # | Setup target transition color!
  stw r0, 0(r4)                     # /
  li r5, 1                          #
  lwz r12, 0x0(r3)                  # \
  lwz r12, 0x28(r12)                # |
  mtctr r12                         # | Call setFlashColorFrame!
  bctrl                             # /


calcStat:                           # Everything past this point is for the stat!
#add one to total aerial count
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
  ble cr7 loc_0x98
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