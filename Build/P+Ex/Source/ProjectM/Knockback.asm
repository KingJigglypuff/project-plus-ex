##################################################
Knockback Reduced 1/3 while Crouching v2.2 [Magus]
##################################################
# Normal Angles
HOOK @ $80769FCC
{
  lwz r3,  0x3C(r23)
  lwz r12, 0x7C(r3)
  lwz r12, 0x38(r12)
  cmpwi r12, 0x11;  blt+ %END%				# \ Only reduce knockback if in action 0x11 (entering crouch) or 0x12 (crouching) 
  cmpwi r12, 0x12;  bgt+ %END%				# /
  lis r12, 0x80B9;  						# \ An address that holds the value 2/3 in float format
  lfs f1, -0x7CB8(r12)						# /
  fmuls f27, f27, f1
}

/*
###############################################################
Knockback Altered while Crouching against Angle 365 [DukeItOut]
#
# Normal CC does not apply to Angle 365. This addresses that
###############################################################
# Angle 365
op stwu r1, -0x30(r1) @ $8076CACC
op stw r0, 0x34(r1) @ $8076CAD4
op lwz r0, 0x34(r1) @ $8076CBA88
op addi r1, r1, 0x30 @ $8076CBC0
HOOK @ $8076CB80 # Knockback
{ 
  lwz r12, 0x8(r29) # \
  lwz r12, 0x3C(r12)# |
  lwz r12, 0xA4(r12)# | Check if a fighter.
  mtctr r12			# |
  bctrl				# |
  cmpwi r3, 0		# |
  bne+ finish		# /
  
  lwz r0, 0x50(r30) # Attack Angle
  cmpwi r0, 365		# If it isn't the follow me angle skip all of this
  bne+ finish
  
  lfs f1, 0x8C(r30) # X component
  lfs f2, 0x90(r30) # Y component

  lwz r12, 0x7C(r29)	# Yes, this register is used in this function.
  lwz r12, 0x38(r12)
  
  cmpwi r12, 0x73; blt+ checkCrouch
  cmpwi r12, 0x81; beq- cliffHang
  cmpwi r12, 0x82; beq- cliffHang
  cmpwi r12, 0x75; bgt+ finish
  
cliffHang:
  li r3, 361			# Follow Me acts like Sakurai Angle 
  stw r3, 0x50(r30)		# at Ledge!
  b finish
  
checkCrouch:  
  cmpwi r12, 0x11;  blt+ finish				# \ Only reduce knockback if in action 0x11 (entering crouch) or 0x12 (crouching) 
  cmpwi r12, 0x12;  bgt+ finish				# /
  
  bla 0x400B38	# atan2(x/y) # relative to Y axis
  
  lfs f2, 0x8(r13)	# 0.0
  fcmpu cr0, f1, f2
  fabs f1, f1		# Make angle absolute relative to Y-axis
  
  lis r12, 0x4170	# \ 15.0
  stw r12, 0x20(r1)	# |
  lfs f2, 0x20(r1)  # /
  lfs f3, -0x9EC(r13) # π/180 # I'm doing this instead of a direct value
								# so it's easier for people to modify and understand
  fmuls f2, f2, f3	# Degrees->Radians
  fsubs f1, f1, f2	# Angle-15°
  
  bge+ Positive
  fneg f1, f1		# Make negative
Positive:
  lfs f3, -0x744(r13) # π/2
  fsubs f1, f1, f3	# Reorient the angle to the X axis
  stfs f1, 0x20(r1)	# Store angle. We'll need it in a moment
  
  lfs f1, 0x8C(r30) # X component
  lfs f2, 0x90(r30) # Y component
  fmuls f1, f1, f1	# X^2
  fmuls f2, f2, f2	# Y^2
  fadds f1, f1, f2	# (X^2)+(Y^2)
  bla 0x400D94		# sqrt of f1. Vector length of knockback.
  
  lis r12, 0x80B9
  lfs f2, -0x7CD4(r13)	# 0.25
  fmuls f1, f1, f2 	# Multiply by 1/4 instead of 2/3
  stfs f1, 0x24(r1) # Store vector length
  li r4, 4
  lwz r3, 0x54(r30) # \
  divw r3, r3, r4	# | KBG * 1/4
  stw r3, 0x54(r30) # /
  lwz r3, 0x5C(r30) # \
  divw r3, r3, r4	# | BKB * 1/4
  stw r3, 0x5C(r30) # / 
  
  
  lfs f1, 0x20(r1) # Angle
  bla 0x4004D8 # cos
  lfs f2, 0x24(r1) # Vector Length
  fmuls f1, f1, f2
  stfs f1, 0x8C(r30) # new X knockback
  lfs f1, 0x20(r1) # Angle
  bla 0x4009E0 # sin
  lfs f2, 0x24(r1) # Vector Length
  fmuls f1, f1, f2
  stfs f1, 0x90(r30) # new Y knockback  
  
finish:  
  lwz r12, 0(r28)	# Original operation
}
HOOK @ $8076D3FC # Hitstun
{
  fmuls f27, f28, f1	# Original operation
  lwz r12, 0x8(r18) # \
  lwz r12, 0x3C(r12)# |
  lwz r12, 0xA4(r12)# | Check if a fighter.
  mtctr r12			# |
  bctrl				# |
  cmpwi r3, 0		# |
  bne+ %END%		# /
  
  lwz r3, 0x7C(r18) # \ Check if crouching
  lwz r3, 0x38(r3)	# /
  cmpwi r3, 0x11;  blt+ %END%				# \ Only reduce knockback if in action 0x11 (entering crouch) or 0x12 (crouching) 
  cmpwi r3, 0x12;  bgt+ %END%				# /  
  
  lwz r3, 0x50(r19)	# \
  cmpwi r3, 365		# | Check if it is Angle 365
  bne+ %END%		# /  
  
  lis r3, 0x4080	# \ 4.0
  stw r3, 0x18(r1)	# |
  lfs f1, 0x18(r1)	# /
  fdivs f27, f27, f1 # Divide by 4!
  lfs f1, 0x18(r13)	# 1.0
  fcmpu cr0, f27, f1
  bge+ %END%
  fmr f27, f1		# Minimum of 1 frame of stun!
}
*/

########################################
Subtractive Knockback Armor v1.1 [Magus]
########################################
HOOK @ $8076A4A0
{
  cmpwi r30, 0x4; beq- %END%
  cmpwi r30, 0x2
}
HOOK @ $80769FD0
{
  lwz r12, 0x44(r3)
  lwz r11, 0x48(r12)
  cmpwi r11, 0x4;  bne+ loc_0x30
  lfs f1, 0x4C(r12)
  fsubs f27, f27, f1
  lis r12, 0x80		# \
  stw r12, 0x10(r2)	# | 
  lfs f1, 0x10(r2)	# /
  fcmpo cr0, f27, f1;  bge- loc_0x30
  fmr f27, f1
loc_0x30:
  lwz r3, 216(r3)
}
HOOK @ $807BBED4
{
  cmpwi r0, 0x4;  beq- %END%
  cmpwi r0, 0x2
}
HOOK @ $807BBF04
{
  cmpwi r0, 0x4;  bne+ loc_0x18
  lis r12, 0x80			# \
  stw r12, 0x10(r2)		# |
  lfs f3, 0x10(r2)		# /
  b %END%
loc_0x18:
  lfs f3, 8(r3)
}

###########################################################################
Melee KB Stacking and Stacks After 10th Frame of KB v1.3b [Magus, DukeItOut]
#
# 1.1: made it so the Char ID check doesn't cause a memory leak
# 1.2: made knockback stacking not randomly fail to apply to high knockback
# 1.3: made a more robust character check that isn't dependent on char ID
###########################################################################

op b 0x1AC @ $8085C8D4
HOOK @ $8076D3B0
{
  mfcr r12
  stw r12, 0x14(r2)
  stw r4,  0x18(r2)
  
  lfs f4,  0x24(r1)

  lwz r12, 0x8(r18)
  lwz r12, 0x3C(r12)
  lwz r12, 0xA4(r12)
  mtctr r12
  mr r4, r3
  bctrl
  cmpwi r3, 0; mr r3, r4; bne- loc_0x118 # check if the object hit is a character. Other objects don't get knockback stacking!

  lwz r12, 0x70(r18)
  lwz r12, 0x20(r12)
  lwz r12, 0xC(r12)
  lwz r4, 0x138(r12)
  cmpwi r4, 0x9
  li r4, 0x1
  stw r4, 0x138(r12)
					ble- loc_0x118
  cmpwi r28, 0x4;  beq+ loc_0x74
  cmpwi r28, 0x7;  beq+ loc_0x74
  cmpwi r28, 0xF;  beq- loc_0x74
  b loc_0x118

loc_0x74:
  lwz r12, 0x88(r18)
  lwz r12, 0x14(r12)
  lwz r12, 0x4C(r12)
  li r4, 0x0		# \
  stw r4, 0x10(r2)	# | Force f1 to be zero
  lfs f1, 0x10(r2)	# / 
  lfs f2, 0x8(r12)
  lfs f3, 0xC(r12)
  fcmpo cr0, f2, f1;  beq+ loc_0xD4
					  blt- loc_0xB8
  fcmpo cr0, f0, f1;  ble- loc_0xD0
  fcmpo cr0, f2, f0;  ble+ loc_0xD4
  fmr f0, f2
  b loc_0xD4

loc_0xB8:
  fcmpo cr0, f0, f1;  bge- loc_0xD0
  fcmpo cr0, f2, f0;  bge+ loc_0xD4
  fmr f0, f2
  b loc_0xD4

loc_0xD0:
  fadds f0, f0, f2

loc_0xD4:
  fcmpo cr0, f3, f1;  beq+ loc_0x114
					  blt- loc_0xF8
  fcmpo cr0, f4, f1;  ble- loc_0x110
  fcmpo cr0, f3, f4;  ble+ loc_0x114
  fmr f4, f3
  b loc_0x114

loc_0xF8:
  fcmpo cr0, f4, f1;  bge- loc_0x110
  fcmpo cr0, f3, f4;  bge+ loc_0x114
  fmr f4, f3
  b loc_0x114

loc_0x110:
  fadds f4, f4, f3

loc_0x114:
  stfs f0, 0xC(r20)

loc_0x118:
  lwz r12, 0x14(r2)
  mtcr r12
  lwz r4, 0x18(r2)
}
HOOK @ $80913194
{
  lwz r12, 0x50(r21);  lbz r12, 0x1C(r12)
  rlwinm r12, r12, 25, 31, 31
  cmpwi r12, 0x1;  beq- loc_0x3C
  lwz r12, 0x14(r21);  lhz r12, 0x5A(r12)
  cmpwi r12, 0xA9;  beq- loc_0x3C
  lwz r12, 0x70(r21);  lwz r12, 0x20(r12)
  lwz r12, 0xC(r12)
  lwz r4, 0x138(r12)
  addi r4, r4, 0x1
  stw r4, 0x138(r12)
loc_0x3C:
  lis r4, 0x1000
}