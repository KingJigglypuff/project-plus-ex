#####################################################################################
[Project+] Independent Button Presses v3 [Magus, Eon, DukeItOut]
#
#
# v2: 2-frame Z-Sync Extension
# v3: Omitted solo Wiimotes from considering this code so D-pad inputs 
#		would stop malfunctioning on them
#####################################################################################
HOOK @ $80048F64
{
	cmpwi r12, 0x2329;	beqlr-;	lbz r5, 8(r5)
}
HOOK @ $80049DB4
{
	cmpwi r12, 0x2329;  beqlr-;  lbz r5, 9(r5)
}
HOOK @ $8004A19C
{
  mfcr r11
  cmpwi r12, 0x2329;  beq- %END%
  stb r0, 1(r6)
  mtcr r11
}
HOOK @ $80764F14
{
  stwu r1, -0x28(r1)
  stmw r24, 8(r1)
  lwz r31, -4(r30)
  lwz r26, 8(r31)
  lwz r27, 0x110(r26)		# Get character ID
  lhz r26, 0xFC(r26)		# Get subcharacter number
  cmpwi r27, 0xF;  bne+ loc_0x3C	# Check if Popo just below
  cmpwi r26, 0x1;  beq- loc_0x100	# don't do anything if Nana

loc_0x3C:
  lwz r29, 0x70(r31);  lwz r29, 0x20(r29);  lwz r29, 0xC(r29) # LA-Basic
  lis r7, 0x805B
  addi r8, r2, 0x10
  ori r9, r7, 0xAF00	# r9 = 805BAF00
  ori r3, r7, 0x7480	# r3 = 805B7480
  lbz r4, 0x42(r28)
  addi r5, r2, 0x14
  addi r6, r2, 0x54
  mulli r25, r4, 0x1C4


  lwz r10, 8(r28)		# Controller info
  cmpwi r10, 0x0;  blt- updateInputHistory		# If it's less than 0, it's a CPU or no controller
  cmpwi r10, 0x8;  bge- updateInputHistory		# If it's higher, it's a replay

  mulli r10, r10, 0x40		# Wiimote info is 0x100 later
  add r9, r9, r10			# r9 = 805BB000 if Wiimote
  
  lwz r7, 0x40(r9)			# CC = 1, WII = 2, NUN = 3
  cmpwi r7, 2				# \ Solo Wiimotes struggle to separate consecutive D-Pad inputs
  beq updateInputHistory	# / 
  
loc_0x70:
  lwzu r7, 4(r9)					# Copy a block of 
  stwu r7, 4(r8)					# 0x40 bytes over of inputs
  cmpw r8, r6;  beq- loc_0x84
  b loc_0x70

loc_0x84:
  lwz r7, -0x40(r9)
  lwz r8, 0x154(r29)		# Load LA-Basic[85]
  stw r7, 0x154(r29)		# Set LA-Basic[85]
  andc r7, r7, r8
  stw r7, 4(r5)
  
  li r12, 0x2329
  lis r10, 0x8004;  ori r10, r10, 0xA468	# \ getPadInput
  mtctr r10;  bctrl 						# / 
  
  lhz r10, 0x54(r2)
  li r8, 0x8;  mulli r8, r8, 0x1000
  andc r10, r10, r8
  lwz r9, 0x48(r30)
  andc r8, r9, r10
  stw r8, 0x48(r30)
  
  
  
updateInputHistory:
  cmpwi r27, 0xF;  bne+ loc_0x100
###
# only Update past if Popo
###
  lis r9, 0x8062;  ori r9, r9, 0x13D4
  add r9, r9, r25

calcChangedInputs:
  #go into input list found at 
  lwz r8, 0x40(r9)
  mulli r6, r8, 0x4
  lwzx r10, r9, r6 #current held inputs


  subi r8, r8, 1
  cmpwi r8, 0x0;  bge 0x8
  li r8, 0xF
  mulli r6, r8, 0x4
  lwzx r7, r9, r6 #previous held inputs
  
  lwz r8, 0x48(r30) #inputs that were blanked since last frame

  andc r10, r10, r7 #changed inputs since prev frame
  andc r8, r7, r8 #this is all inputs that are new to this frame
  or r10, r8, r10
  
  lwz r8, 0x40(r9)
  li r25, 3 			        #number of frames to retroactively change (caps at 16 coz only 16 frames are remembered)
DecrementInputCounter: 	  #defines how many frames are available to Zsync, 1 makes it match vanilla
  cmpwi r25, 0;  beq loc_0x100
  subi r25, r25, 0x1

  subi r8, r8, 0x1
  cmpwi r8, 0x0;  bge+ GetPreviousInput
  li r8, 0xF

GetPreviousInput:
  mulli r26, r8, 0x4
  lwzx r7, r9, r26
  andc r24, r7, r10 		#ands with compliment of new input
  stwx r24, r9, r26
  b DecrementInputCounter 		#always revert all n frames
  
  
loc_0x100:
  lmw r24, 8(r1)
  addi r1, r1, 0x28

loc_0x108:
  mr r3, r28

}

#####################################################################################
Gamecube Controller Light LR Button Presses when not Set to Shield [Dantarion, Magus]
#####################################################################################
HOOK @ $80029700
{
  stb r0, 0x34(r31)				# Current shoulder button pressed rate
  cmpwi r0, 45;  blt- %END%
  lbz r0, -0x26B0(r6)
  cmpwi r0, 0x3;   beq- %END%	# Shield setting
  lwz r0, 0(r31)
  ori r0, r0, 0x40				# L-button
  stw r0, 0(r31)
  stw r0, 4(r31)
}
HOOK @ $80029708
{
  stb r0, 0x35(r31)
  cmpwi r0, 45;  blt- %END%		# Current shoulder button pressed rate
  lbz r0, -0x26AF(r6)
  cmpwi r0, 0x3;   beq- %END%	# Shield setting
  lwz r0, 0(r31)
  ori r0, r0, 0x20				# R-button
  stw r0, 0(r31)
  stw r0, 4(r31)
}

#########################################################################
Classic Controller Light LR Button Presses when not Set to Shield [Magus]
#########################################################################
HOOK @ $80029E30
{
  stb r0, 0x34(r18)
  cmpwi r0, 57;  blt- %END%		# Current shoulder button pressed rate
  subi r11, r17, 0x393C
  mulli r0, r19, 0x21
  lbzx r0, r11, r0
  cmpwi r0, 0x3;   beq- %END%	# Shield setting
  lwz r0, 0(r18)
  ori r0, r0, 0x40				# L-button
  stw r0, 0(r18)
  stw r0, 4(r18)
}
HOOK @ $80029E48
{
  stb r0, 0x35(r18)
  cmpwi r0, 57;  blt- %END%		# Current shoulder button pressed rate
  subi r11, r17, 0x393B
  mulli r0, r19, 0x21
  lbzx r0, r11, r0
  cmpwi r0, 0x3;   beq- %END%	# Shield setting
  lwz r0, 0(r18)
  ori r0, r0, 0x20; 			# R-button
  stw r0, 0(r18)
  stw r0, 4(r18)

}

######################################################################################
Analog C-Stick, L R, & Light-Shield Button Stored as Variables v2.8 [Magus, DukeItOut]
######################################################################################
#
# 2.4: fixes issue where controllers could influence AI shielding or C-Stick behavior
# 2.5: made Wii Classic and GameCube C-Sticks be modified at the same rate so replays
#		were more stable
# 2.6: fixed exploit where the C-Stick could override Nana's inputs when she prepared
#		to throw someone
# 2.7: made it so heart swaps don't cause the wrong controller to receive analog 
#		inputs
# 2.8: addressed issue where Nana could receive inputs at distances not intended
#
# goes in ButtonPresses.asm
######################################################################################
#
# LA-Basic[77] = New L or R press
#	0 = No L or R
#	1 = No new L or R, but is held
#	2 = New L or R press
#
# LA-Float[34] = C-Stick Relative X
# LA-Float[35] = C-Stick Y
# LA-Float[36] = Analog L
# LA-Float[37] = Analog R
#
# LA-Float[38] = Previous C-Stick Relative X
# LA-Float[39] = Previous C-Stick Y
# LA-Float[40] = Previous Analog L
# LA-Float[41] = Previous Analog R
#
# LA-Float[52-71] = Duo Partner Frame Buffer for Nana (5 frames)
#
##################################################
HOOK @ $80913190
{
  stfs f1, 0xDC(r25)
  stwu r1, -0x20(r1)
  stmw r26, 8(r1)
  stfd f0, 0(r2)
  stfd f1, 8(r2)
  stfd f2, 0x20(r2)
  lwz r29, 0x70(r21);  lwz r29, 0x20(r29) # LA
  lwz r4, 0x1C(r29)		# Bit
  lwz r3, 0x2D0(r29)	# AIS
  lwz r28, 0xC(r29)		# Basic
  lwz r29, 0x14(r29)	# Float
  lwz r12, 0x88(r29);  stw r12, 0x98(r29)	# C-Stick Relative X -> C-Stick Relative X (prev frame)
  lwz r12, 0x8C(r29);  stw r12, 0x9C(r29)	
  lwz r12, 0x90(r29);  stw r12, 0xA0(r29)
  lwz r12, 0x94(r29);  stw r12, 0xA4(r29)
  lwz r27, 8(r21)
  lwz r26, 0x110(r27);  cmpwi r26, 0xF;  bne+ notNana	# Check if Ice Climbers
  lhz r26, 0xFC(r27);   cmpwi r26, 0x1;  beq- Nana		# check if sub character (Nana)

Popo:
  addi r26, r29, 0x2D4		# Access the Nana equivalents
  lwz r12, 0x98(r29); stw r12, 0xD0(r26)	# Store into previous duo partner frame variables. # 0x98 + 0x38 at LA Floats 52-55
  lwz r12, 0x9C(r29); stw r12, 0xD4(r26)
  lwz r12, 0xA0(r29); stw r12, 0xD8(r26)
  lwz r12, 0xA4(r29); stw r12, 0xDC(r26)

notNana:
  li r26, 0x0;  b loc_0xD8

Nana:
  lwz r12, 0x0C(r4) 	# Trying to access LA-Bit 113 - Secondary Ice Climber proximity
  andis. r12, r12, 2	# Try to filter for Bit 113 (0x20000)
  bne+ closeEnough
  
  li r12, 0				# Don't receive inputs
  stw r12, 0x88(r29)	# LA-Float[34]
  stw r12, 0x8C(r29)	# LA-Float[35]
  stw r12, 0x90(r29)	# LA-Float[36]
  stw r12, 0x94(r29)	# LA-Float[37]
  b finishNanaCheck
  
closeEnough:


  lwz r12, 0x110(r29);  stw r12, 0x88(r29)	# Set C-Stick Relative X
  lwz r12, 0x114(r29);  stw r12, 0x8C(r29)	# Set C-Stick Y
  lwz r12, 0x118(r29);  stw r12, 0x90(r29)	# Set Analog L
  lwz r12, 0x11C(r29);  stw r12, 0x94(r29)	# Set Analog R
  
  lwz r12, 0x7C(r21); lhz r12, 0x3A(r12)    # Get action
  cmpwi r12, 0x34; blt+ finishNanaCheck        # \ Check if in a foe-holding action
  cmpwi r12, 0x3A; bgt+ finishNanaCheck        # /
  
  li r12, 0;  stw r12, 0x88(r29)    # Set C-Stick Relative X to 0
              stw r12, 0x8C(r29)    # Set C-Stick Y to 0
              stw r12, 0x98(r29)    # \ Do the same with the "Previous C-Stick" variables
              stw r12, 0x9C(r29)    # /
finishNanaCheck:  
  addi r3, r29, 0x100		# LA Float 64-67 ... 68-71
  addi r31, r29, 0xD0		# LA Float 52-55 ... 56-59 ... 60-63 ...

duoBufferPass:
  lwz r12, 0(r3);    stw r12, 0x10(r3)
  lwz r12, 4(r3);    stw r12, 0x14(r3)
  lwz r12, 8(r3);    stw r12, 0x18(r3)
  lwz r12, 0xC(r3);  stw r12, 0x1C(r3)
  cmpw r3, r31
  subi r3, r3, 0x10
  bne+ duoBufferPass			# buffer an additional 5 frames worth of analog data
  
  lwz r12, 0x0C(r4)
  rlwinm r12, r12, 15, 31, 31
  cmpwi r12, 0x1;  bne- dont_control_Nana
  b loc_0x2A0

loc_0xD8:
  lis r30, 0x805B;  ori r30, r30, 0x7480
  lis r31, 0x805B;  ori r31, r31, 0xAD00
  
  lwz r4, 0x4C(r25)
  lbz r3, 0x28(r4);  cmpwi r3, 0; beq+ is_AI	# Fixes issue where players could set AI variables 

  lwz r3, 0x08(r4) # Get the proper port
					 cmpwi r3, 0x0;  blt- dont_control	# -1 or CCCCCCCC if no controller
					 cmpwi r3, 0x7;  bgt- dont_control	# 0x10 in replays
					 cmpwi r3, 0x4;  bge- Wii_control	# 4 = Wiimote
GC_control:					 
  mulli r12, r3, 0xC
  add r30, r30, r12
  lis r4, 0x4316		# 150.0		# GC
  li r27, 150			# int form?
  b loc_0x140
Wii_control:
  addi r30, r30, 0x44
  subi r12, r3, 0x4
  mulli r12, r12, 0x21
  add r30, r30, r12
  lis r4, 0x433E		# 190.0		# Wiimote
  li r27, 190			# int form?

loc_0x140:
  mulli r12, r3, 0x40
  add r31, r31, r12
  b loc_0x164

is_AI:
dont_control:
  li r12, 0x0								# Reset LA-Float[34] through LA-Float[37] (or for Nana LA-Float[52] through LA-Float[55])
  stw r12, 0x88(r29);  stw r12, 0x8C(r29)
  stw r12, 0x90(r29);  stw r12, 0x94(r29)
  b loc_0x294
dont_control_Nana:
  li r12, 0x0
  stw r12, 0xD0(r29);  stw r12, 0xD4(r29)
  stw r12, 0xD8(r29);  stw r12, 0xDC(r29)
  b loc_0x294  

loc_0x164:
  stw r4, 0x18(r2);  lfs f0, 0x18(r2)
  lis r12, 0x4330;  stw r12, 0x10(r2)	# 176.0
  lfd f2, -0x7B90(r2)
  li r4, 0x0

loc_0x17C:
  lbz r12, 0(r30);  cmpwi r12, 0x3;  beq+ loc_0x194
  li r12, 0x0;  stw r12, 0x90(r29)		# Reset LA-Float[36] (Analog L)
  b loc_0x1BC

loc_0x194:
  lbz r12, 0x34(r31);  cmpw r12, r27;  ble+ loc_0x1A4	# \ Max analog L/R threshold
  mr r12, r27											# / set to cap (150 for GC, 190 for Wii)

loc_0x1A4:
  xoris r12, r12, 0x8000;  stw r12, 0x14(r2)
  lfd f1, 0x10(r2);  fsub f1, f1, f2
  fdivs f1, f1, f0;  stfs f1, 0x90(r29)	# Set LA-Float[36] (Analog L)

loc_0x1BC:
  addi r30, r30, 0x1
  addi r29, r29, 0x4
  addi r31, r31, 0x1
  addi r4, r4, 0x1
  cmpwi r4, 0x2;  bne+ loc_0x17C
  subi r29, r29, 0x8
  subi r31, r31, 0x2
  
  li r4, 0x0
  cmpwi r3, 0x4;  
# bge- loc_0x1F4	# Disabled
  
  lis r12, 0x3C40;  ori r12, r12, 0xEBEE;  # b loc_0x1FC  
		# 0.011775	# GC C-Stick multiplier radius in PM.
					# Made to apply the same in P+ for Wii Classic Controllers

#loc_0x1F4:
#  lis r12, 0x3C23;  ori r12, r12, 0xD70A				#
#		# 0.01		# CC C-Stick multiplier radius.
# 
loc_0x1FC:
  stw r12, 0x18(r2)
  lis r12, 0x3F80	# 1.0
  stw r12, 0x1C(r2)

loc_0x208:
  lbz r12, 0x32(r31);  cmpwi r12, 0x80;  blt- loc_0x230
  subfic r12, r12, 0x100
  xoris r12, r12, 0x8000;  stw r12, 0x14(r2)
  lfd f1, 0x10(r2);  fsub f1, f1, f2
  fneg f1, f1
  b loc_0x240

loc_0x230:
  xoris r12, r12, 0x8000;  stw r12, 0x14(r2)
  lfd f1, 0x10(r2);  fsub f1, f1, f2

loc_0x240:
  lfs f0, 0x18(r2)  
  fmuls f1, f1, f0
  cmpwi r4, 0x0;  bne- loc_0x258
  lfs f0, 0x40(r24)
  fmuls f1, f1, f0

loc_0x258:
  lfs f0, 0x1C(r2)
  fcmpo cr0, f1, f0;  ble- loc_0x268
  fmr f1, f0

loc_0x268:
  fneg f0, f0
  fcmpo cr0, f1, f0;  bge- loc_0x278
  fmr f1, f0

loc_0x278:
  stfs f1, 0x88(r29)				# Set LA-Float[34] (C-Stick X Relative)
  addi r29, r29, 0x4
  addi r31, r31, 0x1
  addi r4, r4, 0x1
  cmpwi r4, 0x2;  bne+ loc_0x208
  subi r29, r29, 0x8

loc_0x294:
loc_0x2A0:
  lis r12, 0x3E99;  ori r12, r12, 0x999A		# 0.3. Analog threshold minimum.
  lwz r3, 0x90(r29)				# LA-Float[36] (Analog L)
  lwz r4, 0x94(r29)				# LA-Float[37] (Analog R)
  cmpw r3, r12;  bge- loc_0x2C8
  cmpw r4, r12;  bge- loc_0x2D4
  li r12, 0x0;  b loc_0x2F8		# No L or R pressed

loc_0x2C8:
  lwz r4, 0xA0(r29)				# LA-Float[40] (Previous Analog L)
  cmpw r4, r12;  
  blt- loc_0x2F4	

loc_0x2D4:
  lwz r3, 0x94(r29)				# LA-Float[37] (Analog R)
  lwz r4, 0xA4(r29)				# LA-Float[41] (Previous Analog R)
  cmpw r3, r12;  blt+ loc_0x2EC
  cmpw r4, r12;  blt- loc_0x2F4

loc_0x2EC:
  li r12, 0x2;  b loc_0x2F8		# No new L or R press BUT one of them is held
loc_0x2F4:
  li r12, 0x1					# New L or R press

loc_0x2F8:
  stw r12, 0x134(r28)			# Set LA-Basic[77]
  lfd f0, 0(r2);  lfd f1, 8(r2)
  lfd f2, 0x20(r2);  lmw r26, 8(r1)
  addi r1, r1, 0x20
}


###########################################################
Tap Jump Requirement Checks for C-Stick not Pressed [Magus]
###########################################################
HOOK @ $8085D01C
{
  and. r0, r3, r28;  beq+ loc_0x18
  lwz r3, 0x78(r30);  and. r0, r3, r28;  
  li r3, 0x0
  beq+ loc_0x1C		
loc_0x18:
  li r3, 0x1
loc_0x1C:
  cmpwi r3, 0x1
}
word 0x20000 @ $80FB991C

################################################
Platform Drop C-Stick Aerial Fastfalling [Magus]
################################################
HOOK @ $8085E238
{
  lwz r10, 0x7C(r29)
  lwz r9,  0x38(r10);  cmpwi r9, 0x33;             bne+ loc_0x2C
  lhz r8,  6(r10);     cmpwi r8, 0x72;             bne+ loc_0x2C
  lwz r7,  0x74(r28);  rlwinm. r6, r7, 0, 23, 23;  beq+ loc_0x2C
  lfs f1, -0x5BA0(r2)
loc_0x2C:
  fcmpo cr0, f1, f31
}

################################################################
C-Stick Set to Attack or Special Doesn't Also Input Jump [Magus]
################################################################
op beq- 0xE4 @ $80048ACC
op beq- 0x9C @ $80048B14

#############################################################################################
Up-B, Any Taunt, and Tap Jump Button Timers (tap-jump window fixed 0.715 -> 0.7) [Magus, Eon]
#############################################################################################
HOOK @ $80765380
{
                       cmpwi r7, 0x2;    bne+ loc_0x60
  lbz r10, 0x8A(r30);  cmplwi r10, 254;  bge- loc_0x1C
  addi r10, r10, 0x1
  stb r10, 0x8A(r30)

loc_0x1C:
  lbz r10, 0x8B(r30);  cmplwi r10, 0xFE; bge- loc_0x30
  addi r10, r10, 0x1
  stb r10, 0x8B(r30)

loc_0x30:
  lbz r10, 0x80(r30);  cmpwi r10, 0x3;   bgt- loc_0x60
  lis r9, 0x3F33
  ori r9, r9, 0x3333
  lwz r10, 0xC(r30);   cmpw r10, r9;  	 blt+ loc_0x60
  lwz r10, 0x14(r30);  cmpw r10, r9;  	 bge+ loc_0x60
  mr r0, r3

loc_0x60:
  and. r0, r0, r3
}
HOOK @ $80765388
{
  li r10, 0x1C02;  and. r10, r10, r3;  beq+ loc_0x54
  lwz r10, -4(r30);  lwz r10, 0x70(r10);  lwz r10, 0x20(r10)
  lwz r10, 0xC(r10);  cmpwi r3, 0x2;  beq+ loc_0x34
  lbz r9, 0x8A(r30)  
  stb r4, 0x8A(r30)
  stw r9, 0x148(r10)
  b loc_0x54
loc_0x34:
  lis r9, 0x3F0C;  ori r9, r9, 0xCCCD
  lwz r8, 0xC(r30);  cmpw r8, r9;  blt+ loc_0x54
  lbz r9, 0x8B(r30)  
  stb r4, 0x8B(r30)
  stw r9, 0x14C(r10)
loc_0x54:
  rlwinm r0, r7, 1, 23, 30
}

########################################################
Jump & Shield Timers Don't Reset on Button Clear [Magus]
########################################################
* 02764BE4 000B60A5