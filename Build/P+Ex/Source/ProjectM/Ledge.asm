########################################################
No Reverse Grabbing in Common Actions [Dantarion, Magus]
########################################################
HOOK @ $807357CC
{
  rlwinm r4, r0, 11, 29, 31
  cmpwi r27, 0x112;  bge- %END%	//only special moves can ledge grab backwards
  cmpwi r4, 0x2;  blt- %END%
  li r4, 0x1
}

##############################################################
Melee Edge Grab Box Offset Mechanics & Thin Ledges Fix v1.1 [Magus, Eon]
##############################################################
op lis r28, 0x0 	@ $80B883AC
HOOK @ $8013598C
{
loc_0x0:
  	stw r0, 0x84(r1)
	mfcr r6
	sub r4, r4, r3
	cmpwi r4, 28 #if offset from r3 is not looking at current frames positioning, look at previous frames positioning.

  	lwz r10, 0x64(r3)
  	lwz r10, 0x30(r10)
  	lwz r4, 0x18(r10)
  	addi r4, r4, 0x0C
  	lwz r9, 0x60(r3)

	#If not checking current, update lookup
	beq loc_0x38
  	addi r4, r4, 0xC
  	addi r9, r9, 0x3C

loc_0x38:
	mtcr r6
  	lfs f3, 0x90(r1)
  	lfs f4, 0x88(r1)
  	lfs f5, 0x80(r1)
  	lfs f6, 0x00(r4)
  	lfs f7, 0x1C(r9)
  	lfs f8, 0x24(r9)
  	fsubs f7, f6, f7;  fsubs f8, f8, f6
  	bne- loc_0x6C
  	fmr f0, f8
  	fmr f8, f7
  	fmr f7, f0
loc_0x6C:
  	fadds f4, f4, f8;  fadds f5, f5, f7
  	fsubs f4, f4, f3;  fadds f5, f5, f3
  	stfs f4, 0x88(r1);  stfs f5, 128(r1)
}

###########################################################
Slide Off Edges in Certain Actions v3.1a [Magus, DukeItOut]
###########################################################
# 3.0: 
# -Allows characters that crawl to be able to crawl away
#	from ledges
# -You can no longer be pushed off the ledge during idle
#	preventing awkward interactions sending opponents
#	off the stage
# 3.1:
# -Prevents issue where you could accidentally airdodge
#	right at the ledge by being pushed off during
#	the startup of shielding
###########################################################
HOOK @ $807357AC
{
	
	lwz r5, 0x1C(r1)	# Important pointer for character information
	lwz r3, 0x8(r5)		# \
	lwz r3, 0x3C(r3)	# |
	lwz r3, 0xA4(r3)	# | Check the type
	mtctr r3			# |
	bctrl				# /
	cmpwi r3, 0			# \ if it isn't a fighter, behave normally!
	bne- default		# /

	cmpwi r27, 0x12; beq- crouchCheck  # check if specifically in the crouch state
  	cmpwi r27, 0x13; beq- noSlidingOff # \ Is the character crawling
  	cmpwi r27, 0x14; beq- noSlidingOff # / forwards or backwards?
  	cmpwi r27, 0x1A; beq- idleCheck 	# Starting to shield (actually shielding is still pushed off)
  	cmpwi r27, 0x1C; beq- idleCheck 	# Disengaging shield (actually shielding is still pushed off)
	cmpwi r27, 0x0; beq- idleCheck				# Idle
  	cmpwi r27, 0x3; beq- canSlideOff			# Dash
  	cmpwi r27, 0x6; beq- canSlideOff			# Turning while standing
  	cmpwi r27, 0x7; beq- canSlideOff			# Turning while dashing
  	cmpwi r27, 0x11; blt+ checkForGlideLanding	# \ Various actions related to
  	cmpwi r27, 0x1D; ble+ canSlideOff			# / crouching and shielding
checkForGlideLanding:
  	cmpwi r27, 0x86; bne+ default				# Glide Landing
canSlideOff:
  	li r4, 0x1	# Can slide off.
  	b finish
idleCheck:
	lwz r3, 0xD8(r5) 	# \
	lwz r3, 0x7C(r3) 	# / Information for speed behavior
	lfs f2, 0x10(r13)	# 0.0
	lwz r4, 0xA0(r3) 	# \ Get the jostling X speed
	lfs f1, 0x8(r4)	 	# /
	fcmpu cr0, f1, f2	# See if no one is pushing us around.
	beq+ canSlideOff	# Skip if not being pushed! This will need to be edited to allow
						# front wavedashes at some point to address that this code only seems to
						# trigger on action change instead of every frame.
	lwz r4, 0x28(r5) 	# \ Get the true entire X speed
	lfs f0, 0x40(r4)	# / (including knockback and momentum shifting)
	fcmpu cr0, f0, f1
	bne+ canSlideOff 			# \ Only prevent sliding off if
	b noSlidingOff 				# / not in knockback or voluntarily momentum!
crouchCheck:
	lwz r3, 0x7C(r5)	# \ Get the previous action.
	lhz r3, 0x06(r3) 	# /
	cmpwi r3, 0x13; beq- noSlidingOff			# \ If attempting to swap crawl directions
	cmpwi r3, 0x14; canSlideOff					# / don't slide off!
noSlidingOff:
  	li r4, 0x2	# Don't slide off.
  	b finish	
default:
  	rlwinm r4, r0, 8, 28, 31	# Original operation with collision information.
finish:	
	mr r5, r31			# \ Restored as these are replaced earlier
	mr r3, r29			# /
}
# -Wait, Dash, Turns, Squats, Landings, Shields. Crawls are 3

##########################################################
!Slide Off Edges in Certain Actions v3.2 [Magus, DukeItOut]
##########################################################
# 3.0: 
# -Allows characters that crawl to be able to crawl away
#	from ledges
# -You can no longer be pushed off the ledge during idle
#	preventing awkward interactions sending opponents
#	off the stage
# 3.1:
# -Prevents issue where you could accidentally airdodge
#	right at the ledge by being pushed off during
#	the startup of shielding
# 3.2:
# -Makes it so wavedashes forwards will teeter, but not
#	backwards
# disabled while adjustments are still being made
##########################################################
HOOK @ $807357AC
{
	
	lwz r5, 0x1C(r1)	# Important pointer for character information
	lwz r3, 0x8(r5)		# \
	lwz r3, 0x3C(r3)	# |
	lwz r3, 0xA4(r3)	# | Check the type
	mtctr r3			# |
	bctrl				# /
	cmpwi r3, 0			# \ if it isn't a fighter, behave normally!
	bne- default		# /

	cmpwi r27, 0x12; beq- crouchCheck  # check if specifically in the crouch state
  	cmpwi r27, 0x13; beq- noSlidingOff # \ Is the character crawling
  	cmpwi r27, 0x14; beq- noSlidingOff # / forwards or backwards?
  	cmpwi r27, 0x19; beq- wavelandCheck # Is it landing lag?
	cmpwi r27, 0x1A; beq- noSlidingOff # Starting to shield (actually shielding is still pushed off)
  	cmpwi r27, 0x1C; beq- noSlidingOff # Disengaging shield (actually shielding is still pushed off)
	cmpwi r27, 0x0; beq- idleCheck				# Idle
  	cmpwi r27, 0x3; beq- canSlideOff			# Dash
  	# cmpwi r27, 0x6; beq- idleCheck				# Turning while standing
  	cmpwi r27, 0x7; beq- canSlideOff			# Turning while dashing
  	cmpwi r27, 0x11; blt+ checkForGlideLanding	# \ Various actions related to
  	cmpwi r27, 0x1D; ble+ canSlideOff			# / crouching and shielding
checkForGlideLanding:
  	cmpwi r27, 0x86; bne+ default				# Glide Landing
canSlideOff:
  	li r4, 0x1	# Can slide off.
  	b finish
wavelandCheck:
	lwz r3, 0x7C(r5)	# \ Get the previous action.
	lhz r3, 0x06(r3) 	# /
	cmpwi r3, 0x21		# \ If it wasn't an airdodge
	bne+ default 		# / then behave like usual
idleCheck:
	lwz r3, 0xD8(r5) # \
	lwz r3, 0x7C(r3) # | Information for speed behavior
	lwz r3, 0x14(r3) # /
	lwz r4, 0x1C(r3) # \ \ Momentum X Speed
	lfs f0, 0x8(r4)  # | /
	lwz r4, 0x4C(r3) # | \
	lfs f1, 0x8(r4)	 # | / Knockback X Speed
	fadds f0, f0, f1 # /
	lwz r4, 0x18(r5) # \ Direction
	lfs f2, 0x40(r4) # /
	fmuls f0, f0, f2 # Make the speed relative!
	lwz r4, 0x70(r3) # \ Get the relative jostling X speed
	lfs f1, 0x8(r4)	 # |
	fmuls f1, f1, f2 # /
	fcmpu cr0, f0, f1
	beq- noSlidingOff 			# \ Only prevent sliding off if
								# / not in knockback or voluntarily momentum!
	lfs f1, -0xB0(r13)			# 0.0
	fcmpu cr0, f0, f1			# \ Don't slide off forwards!
	bgt noSlidingOff			# /
	b canSlideOff 				
crouchCheck:
	lwz r3, 0x7C(r5)	# \ Get the previous action.
	lhz r3, 0x06(r3) 	# /
	cmpwi r3, 0x13; beq- noSlidingOff			# \ If attempting to swap crawl directions
	cmpwi r3, 0x14; canSlideOff					# / don't slide off!
noSlidingOff:
  	li r4, 0x2	# Don't slide off.
  	b finish	
default:
  	rlwinm r4, r0, 8, 28, 31	# Original operation with collision information.
finish:	
	mr r5, r31			# \ Restored as these are replaced earlier
	mr r3, r29			# /
}
# -Wait, Dash, Turns, Squats, Landings, Shields. Crawls are 3

####################################################################
Characters starting to teeter on the ledge take priority [DukeItOut]
####################################################################
HOOK @ $807CC598
{
	lfsx f30, r3, r0	# Original operaton, gets push force (normally 0.3)

	
	lwz r11, -0x04(r24)	# Check object 1
	lwz r3, 0x8(r11)
	lwz r3, 0x3C(r3)
	lwz r3, 0xA4(r3)
	mtctr r3
	bctrl
	cmpwi r3, 0			# \ Only check for fighters!
	bne- %END% 			# /
	
	lwz r3, 0x7C(r11)	# \ Get the action
	lhz r3, 0x3A(r3)	# /
	cmpwi r3, 0x7C		# \ Starting to teeter?
	bne noCompensationA	# /
	
	lwz r3, 0x18(r11)
	lfs f1, 0x40(r3)	# character direction

	lwz r3, 4(r30)
	lfs f0, -0xC(r3)	# 4.3. A custom offset to shift referencing position by.
	fmuls f0, f1, f0	# Multiply by direction facing!

	lfs f1, 0(r6)		# \
	fadds f1, f1, f0	# | Manipulate interpretation of position!
	stfs f1, 0(r6)		# /

noCompensationA:
	
	lwz r11, -0x04(r30)	# Check object 2
	lwz r3, 0x8(r11)
	lwz r3, 0x3C(r3)
	lwz r3, 0xA4(r3)
	mtctr r3
	bctrl
	cmpwi r3, 0			# \ Only check for fighters!
	bne- %END% 			# /

	lwz r3, 0x7C(r11)	# \ Get the action
	lhz r3, 0x3A(r3)	# /
	cmpwi r3, 0x7C		# \ Starting to teeter?
	bne %END%			# /

	lwz r3, 0x18(r11)
	lfs f1, 0x40(r3)	# character direction
	
	lwz r3, 4(r30)
	lfs f0, -0xC(r3)	# 4.3. A custom offset to shift referencing position by.
	fmuls f0, f1, f0	# Multiply by direction facing!

	lfs f1, 0(r5)		# \
	fadds f1, f1, f0	# | Manipulate interpretation of position!
	stfs f1, 0(r5)		# /

}
# r24 & r6
# r30 & r5

###########################################################
Knockback doesn't Initiate Edge Grab Waiting Period [Magus]
###########################################################
op NOP @ $808758E0

##############################################################
Ledge Possession Controlled by Variable V2a [Magus, DukeItOut]
##############################################################
# V2: Relocated and fixed one-frame bug where characters
#		visually warp downwards.
##############################################################
op NOP 			@ $8087AD9C
op li r0, 0xB	@ $8087AE00
HOOK @ $8087AEA0
{
	lwz r12, 0x60(r26)
	lwz r11, 0x7C(r12) # \ Current Action
	lhz r11, 0x36(r11)  # /
	cmpwi r11, 0x76; blt- normal # \
	cmpwi r11, 0x78; bgt- normal # / Only triggers for Ledge Attack, Climb and Roll
	lwz r11, 0x70(r12) # \
	lwz r11, 0x24(r11) # | RA-Bit 2 controls 
	lwz r11, 0x1C(r11) # | whether the ledge will be occupied within these 3 actions!
	lbz r11, 3(r11)    # /
	andi. r11, r11, 4; beq- %END% # If set, allow the ledge to clear!
normal:	
	bctrl # Original operation. Removes Ledge Behavior.
}
HOOK @ $8083A360
{
	cmplwi r3,1 # Original operation
	bne- %END%
	
	lwz r12, 0x60(r26)
	lwz r11, 0x7C(r12) # \ Current Action
	lhz r11, 0x36(r11)  # /
	cmpwi cr1, r11, 0x76; blt- cr1, %END% # \
	cmpwi cr1, r11, 0x78; bgt- cr1, %END% # / Only triggers for Ledge Attack, Climb and Roll
removeOccupancy:
	lwz r11, 0x70(r12) # \
	lwz r11, 0x24(r11) # | RA-Bit 2 controls 
	lwz r11, 0x1C(r11) # | whether the ledge will be occupied within these 3 actions!
	lbz r12, 3(r11)     # /
	andi. r4, r12, 0xFB # Filter out RA-Bit 2
	andi. r3, r12, 4 # If set, don't recalculate position, this causes warping for a single frame!
	stb r4, 3(r11)	# Now clear it!	
}
HOOK @ $8087B0F4
{
	lwz r4, 0x7C(r30)
	lwz r5, 0x38(r4)	# Action transitiong to
	cmpwi r5, 0xE; bne- finish		# Falling
	lwz r11, 0x70(r30) 	# \
	lwz r11, 0x24(r11) 	# | RA-Bit 2 controls 
	lwz r11, 0x1C(r11) 	# | whether the ledge will be occupied within these 3 actions!
	lbz r12, 3(r11)     # /
	andi. r4, r12, 0xFB # Filter out RA-Bit 2
	stb r4, 3(r11)		# Now clear it!	
	
finish:
	lwz r0, 0x24(r1) 	# Original operation
}

###################################################################################################################################
[Project+] Tethers Can't Edgehog or Be Edgehogged v1.6 (P+ : Nana Occupies ledge during Up-b and ZSS/Ivysaur Up-b fix) [Magus, Eon]
###################################################################################################################################
HOOK @ $80112DBC
{
	stw r4, 0x10(r2)
	li r0, 0x8
}
op beq- 0x14	@ $80112DF4
HOOK @ $80112DF8
{
.alias PreviousAction = 25
.alias CurrentAction = 28
.alias OpponentPrevAction = 29
.alias OpponentAction = 31
.alias Character = 26
.alias OpponentCharacter = 22
.alias CurrentFrame = 1


  #store r22+ for end
  stwu r1, -0x50(r1)
  stmw r22, 8(r1)

  lis r24, 0x8180

  lwz r25, 0x10(r2)
  lwz r25, 0x64(r25)
  lwz r25, 0x5C(r25)
  
  lwz r26, 0x8(r25)
  lwz Character, 0x110(r26)

  lwz r27, 0x70(r25)		# \
  lwz r27, 0x20(r27)		# | Access LA-Float
  lwz r27, 0x14(r27)		# /
  
  lwz r28, 0x7C(r25)		# Action info		
  lwz r25, 0x14(r25)		# Animation Info
  
  lfs CurrentFrame, 0x40(r25)
  lhz PreviousAction, 0x06(r28)
  lhz CurrentAction, 0x3A(r28)

  lwz r29, 0(r7)
  lwz r29, 0x64(r29)
  lwz r29, 0x5C(r29)
  
  lwz r22, 0x8(r29)
  lwz OpponentCharacter, 0x110(r22)
  
  lwz r30, 0x70(r29)		# \
  lwz r30, 0x24(r30)		# | Access RA-Bit
  lwz r30, 0x1C(r30)		# /
  
  lwz r31, 0x7C(r29)		# Action info

  lhz OpponentPrevAction, 0x6(r31)
  lhz OpponentAction, 0x36(r31); 

SpecialCases:  
  cmpwi Character, 0x1F;  beq- ivysaurCheck
  cmpwi Character, 0x18;  bne+ CommonActionsCheck // ZSS

zssCheck:
	cmpwi CurrentAction, 0x113;  beq- LedgeFree          //Side Special
	cmpwi CurrentAction, 0x114;  bne+ CommonActionsCheck //Up Special
    lis r24, 0x4140   // frame 12.0 (float) (hitboxes come out this frame) (technically frame 13)
    b ledgeFrameCheck
ivysaurCheck:
	cmpwi CurrentAction, 0x114;  bne CommonActionsCheck // Up Special
  	lis r24, 0x41A0   // frame 20.0 (float) (hitboxes come out this frame) (technically frame 21) 
ledgeFrameCheck:
  	stw r24, 0x40(r1)
  	lfs f0, 0x40(r1)
  	fcmpu, cr0, CurrentFrame, f0 // Check if earlier than that frame
  	blt LedgeFree // Only allows those up specials to override the ledge in those early windows!

CommonActionsCheck:
	cmpwi CurrentAction, 0x7F;  blt- CommonActionsCheck2 # \ Tether Actions
	cmpwi CurrentAction, 0x82;  ble- LedgeFree           # /
CommonActionsCheck2:
	cmpwi OpponentAction, 0x75;     bne- EnemyCheck1     # \ Ledge and Tether Actions
	cmpwi OpponentPrevAction, 0x82; bne- EnemyCheck1     # /

  lbz r30, 3(r30);  andi. r30, r30, 0x4;  beq- LedgeFree // RA-Bit 2

EnemyCheck1:
  cmpwi OpponentCharacter, 0x0F; bne+ EnemyCheck2 # Check if Ice Climbers
  cmpwi OpponentAction, 0x11E;   beq- ledgeHeld   # and if the partner climber is grabbing the ledge

EnemyCheck2:
	cmpwi OpponentAction, 0x73;  blt- LedgeFree  # \ Normal Ledge Actions
	cmpwi OpponentAction, 0x79;  bgt- LedgeFree  # /

CommonActionsCheck3:
	cmpwi CurrentAction, 0x75;  bne- ledgeHeld3  # \ Ledge and Tether Actions
	cmpwi PreviousAction, 0x82; bne- ledgeHeld2  # /

ledgeHeld:
  lis r24, 0xC040	// -3.0 float
  b ledgeHeld2b
ledgeHeld2:
  li r24, 0x0		// 0.0 float
ledgeHeld2b:
  stw r24, 0x1C(r27)// LA-Float 7
ledgeHeld3: 
  b default
  
LedgeFree:
  cmpwi CurrentAction, 0x75;  bne- LedgeFree2 //Check if holding the ledge
  li r24, 0x0		// 0.0 float
  stw r24, 0x1C(r27)// LA-Float 7
LedgeFree2:
  cmplw r6, r6 // Forces it to always be equal
  b end
default:
  cmplw r0, r6
end:
  lmw r22, 8(r1)
  addi r1, r1, 0x50
}

op beq- 0xC @ $80112DFC
HOOK @ $80112E10
{
	lwz r4, 0x10(r2)
	
	lwz r4, 0x64(r4)
	lwz r4, 0x5C(r4)
	
	lwz r5, 0x70(r4) # \
	lwz r5, 0x24(r5) # | RA-Bit
	lwz r5, 0x1C(r5) # /
	
	lwz r6, 0x7C(r4)
	lhz r12, 0x6(r6) # Previous Action
	lhz r6, 0x36(r6) # Current Action
	
	cmpwi r6, 0x75; bnelr-	# \ Check if reeling into a ledge with a tether.
	cmpwi r12,0x82; bnelr-	# /
	
	lbz r6, 3(r5)	# \
	ori r6, r6, 4	# | Set RA-Bit 2
	stb r6, 3(r5)	# /
	blr
}

####################################################################################
Ledge Invinicibility Is Zero after 5 Ledge Grabs V2.2 [standardtoaster, ds22, Magus]
####################################################################################
HOOK @ $8074D070
{
  cmpwi r27, 0x75
  bne- ledgeGrabs		//skip if not in the ledge hang action
  lwz r5, 0x2C(r28)  
  lwz r5, 0x70(r5)   # \
  lwz r5, 0x20(r5)   # | LA-Basic[79]: Ledge Grab Counter
  lwz r5, 0xC(r5)    # |
  lwz r27, 0x13C(r5) # /
  addi r27, r27, 0x1		//increment ledge counter
  stw r27, 0x13C(r5)
  cmpwi r27, 0x5		//if consecutive grab count is >5
  bgt- tooManyLedgeGrabs	//don't grant invuln
  b ledgeGrabs
tooManyLedgeGrabs:
  li r4, 0x0
ledgeGrabs:
  stw r4, 0x24(r3)
}

################################################################################################
[Project+] Aerial Attacks and Specials remove ledge invulnerability from ledge jumps [DukeItOut]
################################################################################################
HOOK @ $8074D1EC
{
    subi r0, r4, 1    # Original operation: Decreases ledge invulnerability each frame.
    lwz r12, 0x7C(r29)    # \ Obtain the previous action
    lhz r4, 0x6(r12)        # /
   cmpwi r4, 0x7A; bne %END%  # If it was the end of ledge jumping, then look at the coding, below
    lwz r12, 0x38(r12)  # Obtain the current action
    cmpwi r12, 0x33; beq clearInvuln        # If an aerial . . .
    cmpwi r12, 0x112; blt+ %END%            # Or starting a special
    cmpwi r12, 0x115; bgt- %END%            # then clear the invuln count!
clearInvuln:    
    li r0, 0
}

#############################################################################
Tether Reel Size Fix [DukeItOut]
#############################################################################
# The game mistakenly scales the tether when you attach to a ledge by the 
# size of the fighter. This effectively makes it the size of the fighter to 
# the power of two. Tether users are near exactly a scale of 1.0 in Brawl, 
# so this was not caught during development.
#############################################################################
op NOP @ $808E86F4 # Don't make the grapple move rescale!