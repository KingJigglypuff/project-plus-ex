###############################################################
Grab and Special Grab Single Jump Return [Phantom Wings, Magus]
###############################################################
HOOK @ $809131B0
{
  lwz r4, 0x7C(r21)
  lwz r4, 0x38(r4)
  cmpwi r4, 0x3D;  beq-  Grabbed	// Normal
  cmpwi r4, 0xCC;  beq-  Grabbed	// Chomp (Wario)
  cmpwi r4, 0xCF;  beq-  Grabbed	// Falcon Dive
  cmpwi r4, 0xD0;  beq-  Grabbed	// Inhale
  cmpwi r4, 0xD6;  beq-  Grabbed	// Monkey Flip
  cmpwi r4, 0xE6;  beq-  Grabbed	// Dark Dive
  cmpwi r4, 0xE8;  beq-  Grabbed	// Flame Choke (Air)
  cmpwi r4, 0xEA;  beq-  Grabbed	// Flame Choke (Ground)
  cmpwi r4, 0xEB;  beq-  Grabbed	// Egg Lay
  cmpwi r4, 0xEE;  beq-  Grabbed	// Koopa Klaw/Flying Slam
  cmpwi r4, 0x107;  beq- Grabbed	// Yoshi (Regular Grab)
  b notGrabbed
Grabbed:
  lwz r4, 0x70(r21);
  lwz r4, 0x20(r4)
  lwz r4, 0xC(r4)
  lwz r5, 4(r4)
  cmpwi r5, 0x2;  blt+ noJumpChange
  lwz r18, 0xD0(r21)
  lwz r18, 0x3B0(r18)
  cmpw r5, r18;  blt- noJumpChange
  subi r5, r18, 0x1	// subtract one from jump count
  stw r5, 4(r4)
finishJumpChange:
noJumpChange:
notGrabbed:
  lwz r4, 0xAC(r25)	// original operation
}

#######################################
Weight Dependent Grab Hold Time [Magus] (char id fix fix)
#######################################
HOOK @ $8076303C
{
  stfs f29, 0(r3)
  stwu r1, -0x18(r1)
  stmw r28, 8(r1)
  stfd f30, 0x20(r2)
  lis r4, 0x8180
  lis r12, 0x9380
  lwz r28, 0x54(r3);  cmpw r28, r4;  bge- loc_0x110

  lwz r29, 0x70(r28);  cmpw r29, r4;  bge- loc_0x110
  lwz r29, 0x20(r29);  cmpw r29, r4;  bge- loc_0x110
  lwz r29,0x0C(r29);   cmpw r29, r12; bge- loc_0x110		# Don't allow Pikmin to modify this
  lwz r29,0x2D0(r29);  cmpw r29, r4;  bge- loc_0x110
  lwz r29, 0x08(r29);  cmpw r29, r4;  bge- loc_0x110
  lwz r29,0x110(r29);  cmpwi r29, 0x80;  bge- loc_0x110		# ID of person being grabbed

  lwz r30, 0x64(r28);  cmpw r30, r4;  bge- loc_0x110
  lwz r30, -0xC(r30);  cmpw r30, r4;  bge- loc_0x110
  lwz r30, 0x38(r30);  cmpw r30, r4;  bge- loc_0x110
  lwz r30, 0x44(r30);  cmpw r30, r4;  bge- loc_0x110

  lwz r31, 0x08(r30)
  lwz r31, 0x60(r31)
  lwz r31, 0x70(r31);  cmpw r31, r4;  bge- loc_0x110
  lwz r31, 0x20(r31);  cmpw r31, r4;  bge- loc_0x110
  lwz r31,0x0C(r31);
  lwz r31,0x2D0(r31);  cmpw r31, r4;  bge- loc_0x110
  lwz r31, 0x08(r31);  cmpw r31, r4;  bge- loc_0x110
  lwz r31,0x110(r31);  cmpwi r31, 0x80;  bge- loc_0x110		# ID of person grabbing

  lwz r29, 0xD0(r28);  cmpw r29, r4;  bge- loc_0x110
  lwz r31, 0xD0(r30);  cmpw r31, r4;  bge- loc_0x110
  lfs f29, 0xB8(r29)
  lfs f30, 0xB8(r31)
  fsubs f29, f29, f30
  lis r12, 0x4316		# \
  stw r12, 0x10(r2)		# | Load 150.0 into f30
  lfs f30, 0x10(r2);  	# / 
					fcmpo cr0, f29, f30;  ble+ loc_0xD4
  fmr f29, f30

loc_0xD4:
  fneg f30, f30;    fcmpo cr0, f29, f30;  bge+ loc_0xE4
  fmr f29, f30

loc_0xE4:
  lis r12, 0x4396	# \
  stw r12, 0x10(r2)	# | Load 300.0 into f30
  lfs f30, 0x10(r2)	# /
  fdivs f29, f29, f30
  lis r12, 0x3F80	# \
  stw r12, 0x10(r2)	# | Load 1.0 into f30
  lfs f30, 0x10(r2) # /
  fsubs f30, f30, f29
  lfs f29, 0(r3)
  fmuls f29, f29, f30
  stfs f29, 0(r3)

loc_0x110:
  lfs f29, 0(r3)
  lfd f30, 0x20(r2)
  lmw r28, 8(r1)
  addi r1, r1, 0x18
}

####################################################################
Conditional Grab Mash Multiplier & Paralyze is Mashable v1.2 [Magus]
####################################################################
op NOP @ $80762F10
CODE @ $80585604
{
  stwu r1, -0x20(r1)
  stmw r26, 8(r1)
  lis r0, 0x8180
  lwz r28, 0x54(r27);  	cmpw r28, r0;  	bge- loc_0x13C					#
  lwz r29, 0x7C(r28); 	cmpw r29, r0;  	bge- loc_0x13C					# 
  lhz r29, 0x36(r29);  	cmpwi r29, 0xD9;  	beq- noMashMultiplier		# Beginning of cargo hold
						cmpwi r29, 0x107;  beq- noMashMultiplier		# Yoshi standard grab
  lwz r29, 0x50(r28);  	cmpw r29, r0;  	bge- loc_0x13C					# \
  lbz r29, 0x1C(r29)													# | If NOT in hitlag . . . .
  rlwinm r29, r29, 25, 31, 31											# |
						cmpwi r29, 0x1;  bne- loc_0x64					# /

noMashMultiplier:				//-DK cargo startup, Yoshi grabbed pull, and hitlag use 0
  li r29, 0x0		# \	
  stw r29, 0x10(r2)	# | Load 0.0 into f0
  lfs f0, 0x10(r2)	# /
  b finish

loc_0x64:
  lwz r29, 0x14(r28);  	cmpw r29, r0;  bge- loc_0x13C
  lhz r29, 0x5A(r29);  	cmpwi r29, 0xA9;  bne+ loc_0x13C		# If NOT using DamageElec animation . . . . .

  lwz r31, 0x70(r28);  	cmpw r31, r0;  bge- loc_0x13C
  lwz r31, 0x24(r31);  	cmpw r31, r0;  bge- loc_0x13C
  lwz r26, 0x1C(r31);  	cmpw r26, r0;  bge- loc_0x13C
  lwz r29, 0x48(r28);  	cmpw r29, r0;  bge- loc_0x13C
  lwz r30, -0x18(r29)
  lwz r29, -0x24(r29);  cmpwi r29, 0x14;  bne- loc_0xD4
						cmpwi r30, 0x0;  bne+ loc_0xD4
  lwz r29, 0(r26)
  lis r30, 0x1000
  or r29, r29, r30
  stw r29, 0(r26)

loc_0xD4:
  lwz r29, 0(r26)
  lis r30, 0x1000
  and r30, r30, r29
  subic r29, r30, 1
  subfe r30, r29, r30
						cmplwi r30, 1;  beq- loc_0x13C
  lwz r30, 0xC(r31);  	cmpw r30, r0;  bge- loc_0x13C
  lwz r29, 8(r30);  	cmpwi r29, 0x0;  ble- loc_0x110
  subi r29, r29, 0x1
  stw r29, 8(r30)

loc_0x110:
  lwz r30, 0x58(r28);  cmpw r30, r0;  bge- loc_0x13C
  lwz r30, 0x14(r30);  cmpw r30, r0;  bge- loc_0x13C
  lwz r29, 0x30(r30);  cmpwi r29, 0x1;  ble- loc_0x13C
  subi r29, r29, 0x1
  stw r29, 0x30(r30)

loc_0x13C:
  lfs f0, 8(r27)

finish:
  lmw r26, 8(r1)
  addi r1, r1, 0x20
  blr 
}
HOOK @ $80765690
{
  lis r0, 0x8058		# \
  ori r0, r0, 0x5604	# |
  mtctr r0				# | Jump to the above.
  bctrl 				# /
}
HOOK @ $807656C8
{
  mr r3, r0
  lis r0, 0x8058		# \
  ori r0, r0, 0x5604	# |
  mtctr r0				# | Jump to the above.
  bctrl 				# /
  mr r0, r3
}

###########################################
Grab Mash X Axis Initialization Fix [Magus]
###########################################
op sth r31, 0xC(r30) @ $807630DC

#########################
DK Cargo Mash Fix [Magus]
#########################
op NOP @ $80891774