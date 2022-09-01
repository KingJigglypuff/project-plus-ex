##################################################
Knockback Reduced 1/3 while Crouching v2.2 [Magus]
##################################################
HOOK @ $80769FCC
{
  lwz r3,  0x3C(r23)
  lwz r12, 0x7C(r3)
  lwz r12, 0x38(r12)
  cmpwi r12, 0x11;  blt+ %END%				# \ Only reduce knockback if in action 0x11 (entering crouch) or 0x12 (crouching) 
  cmpwi r12, 0x12;  bgt+ %END%				# /
  lis r12, 0x80B8;  ori r12, r12, 0x8348	# \ An address that holds the value 1/3 in float format
  lfs f1, 0(r12)							# /
  fmuls f27, f27, f1
}

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

################################################################
Melee KB Stacking and Stacks After 10th Frame of KB v1.1 [Magus] (char id fix fix)
################################################################
op b 0x1AC @ $8085C8D4
HOOK @ $8076D3B0
{
  mfcr r12
  stw r12, 0x14(r2)
  stw r4,  0x18(r2)
  lis r4, 0x9380
  lfs f4,  0x24(r1)
  lwz r12, 0x70(r18)
  lwz r12, 0x20(r12)
  lwz r12,0x0C(r12)
  lwz r12,0x2D0(r12);	cmpw r12, r4;	bge- loc_0x118
  lwz r12, 0x08(r12);  	cmpw r12, r4; 	bge- loc_0x118
  lwz r12,0x110(r12);	cmpwi r12, 0x80;  bge- loc_0x118

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