##############################################
DI All Trajectories (Above Tumble) [Dantarion]
##############################################
op NOP @ $80877A78

#########################################
Enable Trajectory DI Below Tumble [Magus]
#########################################
op b 0x440 @ $808772A0

########################################
Allow ASDI on Shield Damage v2.0 [Magus]
########################################
op NOP @ $80874D6C
HOOK @ $80874E00
{
  lis r10, 0x80B8
  ori r10, r10, 0x835C
  lfs f0, 0(r10)
  fmuls f1, f1, f0
  fmuls f1, f30, f1
}

########################################################################################
Trajectory DI limited to 18 degree change, & DI Input is Squared v2.0 [Magus, DukeItOut]
########################################################################################
HOOK @ $80877B10
{
  stwu r1, -0x10(r1)
  lis r12, 0x3F80 	# \ 1.0
  stw r12, 0x8(r1)	# /
  lfs f28, 0x8(r1);  fcmpo cr0, f3, f28;  ble- loc_0x18		// compare with 1.0
  fmr f3, f28
loc_0x18:
  fneg f28, f28;  fcmpo cr0, f3, f28;  bge- loc_0x28		// compare with -1.0
  fmr f3, f28
loc_0x28:
  fsubs f28, f28, f28;  fcmpo cr0, f3, f28;  bge- loc_0x44	// compare with 0.0
  fmuls f3, f3, f3
  fneg f3, f3
  b loc_0x48
loc_0x44:
  fmuls f3, f3, f3
loc_0x48:
  fmuls f0, f31, f3
  addi r1, r1, 0x10 
}

################################################################################
ASDI with C-Stick & DI/SDI/ASDI Inputs Scaled within a 1.0025/1/1 Radius [Magus]
################################################################################
CODE @ $80585750
{
  cmpwi r0, 0x3;  bne+ loc_0x48 // branch if not ASDI
  lwz r3, 0x70(r12)
  lwz r3, 0x20(r3)
  lwz r3, 0x14(r3)
  lfs f0, 0x88(r3)
  lfs f2, 0x8C(r3)
  fmuls f0, f0, f0
  fmuls f2, f2, f2
  fadds f0, f0, f2
  fmuls f2, f1, f1;  fcmpo cr0, f0, f2;  blt- loc_0x48
  lfs f29, 0x88(r3)
  lfs f30, 0x8C(r3)
  lwz r4, 0x18(r12)
  lfs f0, 0x40(r4)
  fmuls f29, f29, f0
loc_0x48:
  cmpwi r0, 0x1
  lis r12, 0x3F80			# 1.0
  bne- loc_0x58				// branch if not DI
  ori r12, r12, 0x51EC		# 1.0 -> 1.0025
loc_0x58:
  stw r12, 0x20(r2)
  fmuls f0, f29, f29
  fmuls f2, f30, f30
  fadds f0, f0, f2
  frsqrte f0, f0
  fres f0, f0
  lfs f2, 0x20(r2);  fcmpo cr0, f0, f2;  ble- loc_0x88
  fdivs f2, f2, f0
  fmuls f29, f29, f2
  fmuls f30, f30, f2
loc_0x88:
  fmuls f0, f30, f30
  blr 
}
HOOK @ $80877950
{
  stfd f2,  0x10(r2)
  stfd f30, 0x18(r2)
  fmr f29, f28
  fmr f30, f1
  lis r0, 0x8058		# \
  ori r0, r0, 0x5750	# |
  mtctr r0				# | Go to routine placed above
  li r0, 0x1			# | Mode 1 = DI
  bctrl 				# /
  fmr f28, f29
  fmr f1, f30
  lfd f2,  0x10(r2)
  lfd f30, 0x18(r2)
  lfs f0, 0xC(r31)
}
HOOK @ $80876BA8
{
  lis r0, 0x8058		# \
  ori r0, r0, 0x5750	# |
  mtctr r0				# |
  li r0, 0x2			# | Mode 2 = SDI
  bctrl 				# /
}
HOOK @ $808768DC
{
  lis r0, 0x8058		# \
  ori r0, r0, 0x5750	# |
  mtctr r0				# | Identical to the above except for hook point
  li r0, 0x2			# | Mode 2 = SDI
  bctrl 				# /
}
HOOK @ $80876F18
{
  mr r12, r31			
  lis r0, 0x8058		# \
  ori r0, r0, 0x5750	# |
  mtctr r0				# |
  li r0, 0x3			# | Mode 3 = ASDI
  bctrl 				# /
}
HOOK @ $80876628
{
  stfd f29, 0x10(r2)
  fmr f29, f31
  mr r12, r30
  lis r0, 0x8058		# \
  ori r0, r0, 0x5750	# |
  mtctr r0				# |
  li r0, 0x3			# | Mode 3 = ASDI
  bctrl 				# /
  fmr f31, f29
  lfd f29, 0x10(r2)
}

#################################################
Enable ASDI Downwards while Grounded v1.1 [Magus]
#################################################
op b 0x4C @ $80876F88
op b 0x4C @ $80876698
