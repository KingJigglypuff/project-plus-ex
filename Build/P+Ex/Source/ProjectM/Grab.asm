###############################################################
Grab and Special Grab Single Jump Return [Phantom Wings, Magus]
###############################################################
HOOK @ $809131B0
{
  lwz r4, 0x7C(r21)
  lwz r4, 0x38(r4)		# Get Action
  
  cmpwi r4, 0x3D;  blt+ notGrabbed	    # \ Check if grabbed
  cmpwi r4, 0x3F;  ble- Grabbed   		# /
  cmpwi r4, 0xCC;  blt+ notGrabbed		# \ Wario Chomp, Falcon Dive, Inhale
  cmpwi r4, 0xD5;  beq- notGrabbed		# Unknown action
  cmpwi r4, 0xD8;  beq- notGrabbed		# Unused action with potential utility?
  cmpwi r4, 0xDB;  ble- Grabbed 		# / Diddy, DK command grabs
  cmpwi r4, 0xEB;  bgt-  checkKoopa		# \ Egg Lay (but not being Egged)
  cmpwi r4, 0xE6;  bge-  Grabbed		# / and Ganondorf command grabs
checkKoopa:	
  cmpwi r4, 0xEE;  beq-  Grabbed		# Koopa Klaw/Flying Slam
  cmpwi r4, 0xFA;  beq-  Grabbed		# Master/Crazy Hand Grab
  cmpwi r4, 0x10A;  bgt- notGrabbed		# \ Yoshi (Regular Grab)
  cmpwi r4, 0x102;  blt+ notGrabbed		# / Gulpin, Tabuu, Bucculus	
  b notGrabbed
Grabbed:
  lwz r4, 0x70(r21)
  lwz r4, 0x20(r4)
  lwz r4, 0xC(r4)
  lwz r5, 4(r4)
  cmpwi r5, 0x2;  blt+ noJumpChange
  lwz r18, 0xD0(r21)
  lwz r18, 0x3B0(r18) // check total jump count 
  cmpw r5, r18;  blt- noJumpChange
  subi r5, r18, 0x1	// subtract one from jump count
  stw r5, 4(r4)
finishJumpChange:
noJumpChange:
notGrabbed:
  lwz r4, 0xAC(r25)	// original operation
}

##################################################
Weight Dependent Grab Hold Time [Magus, DukeItOut] (char id fix fix fix)
##################################################
# Note: Pikmin and Exhaled Stars ignore this but tether grabs do not!
op li r7, 2 @ $8088D3EC # Wario Chomp
op li r7, 2 @ $8088433C # Grab
op li r7, 2 @ $80891584 # DK Cargo Hold
op li r7, 2 @ $80890C80 # Diddy Monkey Flip
op li r7, 2 @ $8088F210 # Inhaled
op li r7, 2 @ $80892828	# Yoshi Egg

HOOK @ $8076303C
{
  stfs f29, 0(r3)		# Original operation. Sets frames of grab hold time normally anticipated. 
  
  cmpwi r7, 2 			# \ Bail out of this code if it isn't specifically desired
  bne- %END%			# / to go through this!
  
  mr r11, r3			# We'll need this later if anything is altered
  
  lwz r31, 0x54(r3)		# This is safe, though unorthodox, because r31 is overwritten later.
  
  lwz r5, 0x5C(r31)		# \
  lwz r5, 0x94(r5)		# | Get grabber
  lwz r5, 0x44(r5)		# /
  
  lwz r12, 0x08(r5)
  lwz r12, 0x3C(r12)
  lwz r12, 0xA4(r12)
  mtctr r12
  bctrl
  cmpwi r3, 0
  bne- %END%	# Don't do this code if the one grabbing is not a fighter!
  
  lwz r4, 0xD0(r31)
  lfs f1, 0xB8(r4)	# Weight of grabbed
  
  lwz r4, 0xD0(r5)
  lfs f2, 0xB8(r4)	# Weight of grabber
  
  fsubs f1, f1, f2	# Subtract grabbed from grabber
  
  lis r12, 0x4316		# \
  stw r12, 0x10(r2)		# | Load 150.0 into f2
  lfs f2, 0x10(r2)  	# / 

  fcmpo cr0, f1, f2;  ble+ belowUpperBound
  fmr f1, f2			# Cap upper at 150.0

belowUpperBound:	
  fneg f2, f2;    fcmpo cr0, f1, f2;  bge+ aboveLowerBound
  fmr f1, f2			# Cap lower at -150.0
	
aboveLowerBound:
  lis r12, 0x4396	# \
  stw r12, 0x10(r2)	# | Load 300.0 into f2
  lfs f2, 0x10(r2)	# /
  fdivs f1, f1, f2 # (Weight of Attacked - Weight of Attacker) / 300.0
  lfs f2, 0x18(r13)	# Load 1.0 into f2
  fsubs f2, f2, f1 # 1.0 - ((Weight of Attacked - Weight of Attacker)/300.0)
  fmuls f29, f29, f2 # multiply by what the formula already is
  stfs f29, 0(r11)	# Saves altered time of max frames grabbed
}

#######################################################
Conditional Grab Mash Multiplier 2.0 [Magus, DukeItOut]
#######################################################
HOOK @ $8085B3C0
{
	lwz r3, 0x60(r28)
	lwz r4, 0x7C(r3); lhz r4, 0x36(r4)	# The current action
	
	cmpwi r4, 0xD9; beq- noMash		# Beginning of cargo hold
	cmpwi r4, 0x107; beq- noMash	# Yoshi Standard Grab
	
	lwz r4, 0x50(r3); lbz r4, 0x1C(r4)	# \
	rlwinm. r4, r4, 25, 31, 31			# | Check for if in hitlag
	beq+ allowMash						# /
	
noMash:
	lwz r4, 0x68(r3); lwz r4, 0x10(r4) # Mashing info
	lfs f1, 0x0C(r4)  # Current amount of held frames
	lfs f2, 0x10(r13) # \
	fcmpu cr0, f1, f2 # | Check if already at 0
	ble+ skip 		  # /
	lfs f2, 0x10(r4)  # Base reduction rate
	fsubs f1, f1, f2  # Reduce by this amount per frame.
	stfs f1, 0x0C(r4) # Update frame counter!
skip:	
    ba 0x85B3CC		# Don't check the controller!
allowMash:		
	mr r3, r29		# Original operation
}

###########################################
Grab Mash X Axis Initialization Fix [Magus]
###########################################
op sth r31, 0xC(r30) @ $807630DC

#########################
DK Cargo Mash Fix [Magus]
#########################
op NOP @ $80891774

############################################################################
Grab victims don't shake violently when pushed to the edge [DukeItOut]
############################################################################
int 1 @ $80FB01C8 # Action 3E - Being held
int 2 @ $80FAFE88 # Action 3D - Getting grabbed