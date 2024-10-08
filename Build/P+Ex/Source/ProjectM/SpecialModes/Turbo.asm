##################################################################################
Turbo Mode - On Hit Interrupts v2.3 [Magus, Dantarion, standardtoaster, DukeItOut]
#
# 1.2: Modified to work with P+
# 2.0: Makes it so that attacks can only cancel into attacks, mid-air jumps and 
# 		other grabs. Previously, it triggered ANY interruptable option
# 2.1: Grounded jump cancels given back to jab, tilts and specials.
# 2.2: Jabs, Dash Attacks and Taunts cancel into any grounded movement
##################################################################################
HOOK @ $807803A0
{
  stwu r1, -0x40(r1)
  stw r3, 0x30(r1)
  stw r4, 0x34(r1)
  stw r31, 0x3C(r1)
  mflr r0
  stw r0, 0x44(r1)
  
  lwz r12, 0x2C(r3)
  lwz r12, 4(r12)
  lhz r0, 8(r12);   cmpwi r0, 0x5;   bne- finish
  lwz r0, 0x34(r3); cmpwi r0, 0x3A;  beq- finish	# Don't allow pummels to cancel!
				    cmpwi r0, 0x3C;  beq- finish	# Don't allow throws to cancel!
  lwz r3, 0xCC(r3)
  lwz r4, 0x70(r3)
  lwz r5, 0x20(r4)
  lwz r5, 0x1C(r5)
  lwz r12, 0(r5);  andi. r12, r12, 0x400;  beq+ finish	# If Turbo status isn't enabled (item or mode), skip.
  lwz r5, 0x24(r4)
  lwz r5, 0x1C(r5)
  lwz r12, 4(r5);  rlwinm r12, r12, 9, 31, 31; cmpwi r12, 0x1;  beq- finish	


GiveBackMidairJumps:
  lwz r4, 0x20(r4) 		# \
  lwz r4, 0x0C(r4) 		# |
  lwz r12, 0x04(r4) 	# | On hit, restore all mid-air jumps!
  cmpwi r12, 1			# |
  ble NormalJumpCount	# |
  li r12, 1				# |
  stw r12, 0x04(r4)		# /		
NormalJumpCount:



  lis r4, 0x100		# \
  or r12, r12, r4	# | set bit ????
  stw r12, 4(r5)	# /
					cmpwi r0, 0x33;  bne+ aerialSkip		# Aerial attacks don't need the below?
  lis r4, 0x4000		# \
  lwz r12, 0(r5)		# | set bit if in the air????
  andc r12, r12, r4		# |
  stw r12, 0(r5)		# /
aerialSkip:
		
	
startCancels:
	li r4, 0
enableLoop:
	lwz r3, 0x30(r1)		# Restore pointer
	lwz r3, 0x2C(r3)		# Get pointer for interrupt information!
skipDodge:
	addi r4, r4, 1;		cmpwi r4, 0x6; beq- skipDodge	# \ Do not allow shield
						cmpwi r4, 0x9; beq- skipDodge	# | or landing (triggers for all grounded)
						cmpwi r4, 0xA; beq- skipDodge	# | or ledge grab
						cmpwi r4, 0xE; beq- skipDodge	# / or air dodge interrupts!
	
JumpCancelCheck:
	cmpwi r4, 0x7; bne+ JumpCancel  # \					
	cmpwi r0, 0x2A; blt+ JumpCancel # | Smashes can't jump cancel! 
	cmpwi r0, 0x32; ble- skipDodge	# /
JumpCancel:
DashCancelCheck:	
	cmpwi r4, 0x8; bne+ skipDashCheck	# \
	cmpwi r0, 0x10C; beq+ DashCancel	#  |Taunts can cancel into movement! 
	cmpwi r0, 0x26; bgt+ skipDodge		# / Jabs and Dash attacks can cancel into movement, but other attacks can not!		
DashCancel:
skipDashCheck:
	stw r4, 0x8(r1)
	stw r0, 0xC(r1)
	lwz r12, 0(r3)			# \
	lwz r12, 0x1C(r12)		# | Access 807816A4 for specific interrupts
	mtctr r12				# |
	bctrl					# /	
	lwz r4, 0x8(r1)
	lwz r0, 0xC(r1)
	
airCancel:
	cmpwi r4, 0x0F; bgt stop		# \ Air Attack is the next-to-last interrup to enable
					bne+ enableLoop	# / 
enableAirJump:
	li r4, 0x11; 	b enableLoop	# Air Jump 0x12 (0x11+1) is final interrupt addition desired					
stop:
	
finish:
  li r5, 0x1
  lwz r3, 0x30(r1)
  lwz r4, 0x34(r1)
  lwz r31, 0x3C(r1)
  lwz r0, 0x44(r1)
  mtlr r0
  addi r1, r1, 0x40
}

############################################################
Turbo Mode - Turbo Cleared in Normal Allow Interrupt [Magus]
############################################################
HOOK @ $8084B6EC
{
  cmpwi r12, 0x2329
  beq- loc_0x28
  lwz r5, 0x2C(r3)
  lwz r5, 0x70(r5)
  lwz r5, 0x24(r5)
  lwz r5, 0x1C(r5)
  lis r27, 0x100
  lwz r26, 4(r5)
  andc r26, r26, r27
  stw r26, 4(r5)

loc_0x28:
  lbz r0, 0x39(r3)	# Original operation
}

##############################################################
Turbo Mode - Dash Cancel Range in Dodge Animations [DukeItOut]
##############################################################
.alias PSA_Off = 0x80540098

address $80540098 @ $80FB1320	# (Spot Dodge) Pointers that normally direct to 80FB12C4
address $80540098 @ $80FB1430	# (Roll)
CODE @ $80540098
{
word 0x12030100; word 0x80FB12BC	# RA-Basic[0]++

word 0x02000601; word 0x80FAC28C	# Change Action Status: ID 0x273C, Action 3, IC-Basic[1011] >= IC-Basic[3122]
word 0x02040400; word 0x80FAC2BC	# Additional Requirement: IC-Basic[21001] < IC-Basic[23031]
word 0x02040400; word PSA_Off+0x70	# Additional Requirement: IC-Basic[0] >= 6
word 0x02040400; word PSA_Off+0x90	# Additional Requirement: IC-Basic[0] <= 14
word 0x02040200; word PSA_Off+0xB0	# Additional Requirement: LA-Bit[10] is set
word 0x02040200; word PSA_Off+0xC0	# Additional Requirement: Shield buttons not held

word 0x02000601; word 0x80FAC21C	# Change Action Status: ID 0x2740, Action 7, IC-Basic[1012] >= IC-Basic[3122]
word 0x02040400; word 0x80FAC2BC	# Additional Requirement: IC-Basic[21001] < IC-Basic[23031]
word 0x02040400; word PSA_Off+0x70	# Additional Requirement: IC-Basic[0] >= 6
word 0x02040400; word PSA_Off+0x90	# Additional Requirement: IC-Basic[0] <= 14
word 0x02040200; word PSA_Off+0xB0	# Additional Requirement: LA-Bit[10] is set
word 0x02040200; word PSA_Off+0xC0	# Additional Requirement: Shield buttons not held

word 0; word 0						# End

word 6; word 7			# Compare
word 5; IC_Basic 0		# IC-Basic[0]
word 0; word 4			# >=
word 1; scalar 6		# 6.0

word 6; word 7			# Compare
word 5; IC_Basic 0		# IC-Basic[0]
word 0; word 1			# <=
word 1; scalar 14.0		# 14.0

word 6; word 8		# if LA-Bit[10] is set
word 5; LA_Bit 10	# 

word 6; word 0x33	# Shield Button in pressable state
word 0; word 3		#
}

#############################################################
Turbo Mode - Repeat Action Change v1.2 [Magus]
#
# r6 will contain the current action being transitioned from
# r12 contains the one attempted to be transitioned to
#############################################################
HOOK @ $8077F184
{
					cmpwi r0,    -1;  beq+ finish		# Jump to end if already interruptable
  lwz r12, 0x10(r1);cmpwi r12, 0x24;  blt+ finish		# Skip non-attack action options to transition to
  lis r11, 0x8180										# \
  lwz r5, 8(r31);  	cmpw r5, r11;  bge- finish			# / Bail if not a character!
  lwz r5, 0x70(r31)										# \
  lwz r6, 0x24(r5)										# |
  lwz r6, 0x1C(r6)										# | 
  lwz r6, 4(r6)											# |
  rlwinm r6, r6, 8, 31, 31								# |
					cmpwi r6, 0x1;  bne+ finish  		# /
  lwz r6, 0x7C(r31)
  lhz r6, 0x36(r6); cmpwi r6, 0x2A;  blt+ notSmash		# \ All Smash attacks
					cmpwi r6, 0x32;  bgt+ notSmash		# /
Smash:					
					cmpwi r6, 0x2D;  bge+ UD_Smash		# If a down or up smash, branch.
F_Smash:
					cmpwi r12, 0x2A;  beq- noCancel	# Side Smash startup
					b finish
UD_Smash:
					cmpwi r6, 0x30;  bge- U_Smash		# If an up smash, branch
D_Smash:
					cmpwi r12, 0x2D;  beq- noCancel;  b finish
U_Smash:
					cmpwi r12, 0x30;  beq- noCancel;  b finish

notSmash:
					cmpw r6, r12;  bne+ finish
					cmpwi r12, 0x33;  bne+ noCancel
aerialAttack:
  lwz r3, 0x68(r31)
  lis r12, 0x8076
  ori r12, r12, 0x41AC
  mtctr r12
  bctrl 
  
  li r0, 0x0				# Default to 0
  lwz r12, 0x68(r31)		# \ Get control stick positions
  lfs f2, 0x38(r12)			# | Stick X 
  lfs f3, 0x3C(r12)			# / Stick Y
  lwz r12, 0x18(r31)		# \ Character Direction (-1 if left, 1 if right)
  lfs f4, 0x40(r12)			# /
  fmuls f2, f2, f4			# Flip if facing left 

  lis r12, 0x80B9				#
  lfs  f4, -0x7CD4(r12)			# load 0.25 to f4 (controller stick sensitivity)
  fsubs f5, f5, f5				# set f5 to 0.0 
  fabs f6, f2;  fcmpo cr0, f6, f4;  bge- FAirCompare	# Was the stick tilted further than 0.25 horizontally?
  fabs f6, f3;  fcmpo cr0, f6, f4;  bge- FAirCompare	# Was the stick tilted further than 0.25 vertically?
  
NAirCompare:  
  li r11, 0x62;  b AerialTest	# Neutral Aerial
FAirCompare: 
				cmpwi r3, 0x1;     bne- UAirCompare		# 1 if stick was more horizontal than vertical?
				fcmpo cr0, f2, f5; blt- BAirCompare
  li r11, 0x63;  b AerialTest	# Forward Aerial
BAirCompare: loc_0x134:
  li r11, 0x64;  b AerialTest	# Back Aerial
UAirCompare: loc_0x13C:
				fcmpo cr0, f3, f5;  blt- DAirCompare
  li r11, 0x65;  b AerialTest	# Up Aerial
DAirCompare:
  li r11, 0x66					# Down Aerial
AerialTest:
  lwz r12, 0x14(r31)								# Check if current subaction is 0x62-0x66 (aerial)
  lhz r12, 0x5A(r12);  cmpw r11, r12;  bne+ finish	# If it is not the same one that was used previously, it's okay to cancel into!

noCancel:
  li r0, -1				# No interrupts! Pretend that the animation is invalid!
finish:
  cntlzw r0, r0			# Original operation
}



###############################################
Turbo Mode - Disable Curry Wait and Run [Magus]
###############################################
op lwz	r0, 0xFF (r0) @ $80FAC8F0
op lwz	r0, 0xFF (r0) @ $80FAB728
op lwz	r0, 0xFF (r0) @ $80FABB88

########################################################
Turbo Mode - Curry Special Brawl Uses Curry Aura [Magus]
########################################################
op nop @ $808434D4

#############################################################
Turbo Mode - Curry Special Brawl Doesn't Exclude Nana [Magus]
#############################################################
op nop @ $808377C8

##############################################
Super Spicy Curry has no SFX [standardtoaster]
##############################################
op nop @ $80843540

###########################################################
Turbo Boost makes Power Up Noise on Acquisition [DukeItOut]
###########################################################
HOOK @ $80845E98
{
	lwz r3, 0xD8(r29)
	li r4, 0x1EFB		# Sound effect to play (Getting something from WiFi spectator mode)
	li r5, 0
	li r6, 0
	lwz r3, 0x50(r3)
	li r7, 0
	lwz r12, 0(r3)		# \
	lwz r12, 0x1C(r12)	# | Play sound!
	mtctr r12			# |
	bctrl				# /
	mr r3, r23			# Original operation
}


