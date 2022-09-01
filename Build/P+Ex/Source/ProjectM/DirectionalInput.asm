#################################################
Directional Input Capped at Distance of 1 [Magus]
#################################################
HOOK @ $8004819C
{
  lfs f0, 0(r3)
  lfs f1, 4(r3)
  fmuls f2, f0, f0
  fmuls f3, f1, f1
  fadds f2, f2, f3
  lis r12, 0x461C		# \
  ori r12, r12, 0x4000	# | Loads 10000.0 into f3
  stw r12, 0x10(r2)		# |
  lfs f3, 0x10(r2)	    # /
  fcmpo cr0, f2, f3;  ble+ %END%
  frsqrte f2, f2
  lfs f3, -0x5BA8(r2);  fdivs f2, f3, f2
  lfs f3, -0x6634(r2);  fdivs f2, f3, f2
  fmuls f4, f0, f2
  fmuls f1, f1, f2
  li r10, 0x0
  lfd f3, -0x7B90(r2)
  lis r11, 0x4330

loc_0x54:
  fctiwz f4, f4
  stfd f4, 0x10(r2)
  lwz r12, 0x14(r2)
  stw r11, 0x10(r2)
  xoris r12, r12, 0x8000
  stw r12, 0x14(r2)
  lfd f4, 0x10(r2)
  fsub f4, f4, f3;
  cmpwi r10, 0x1;  beq- loc_0x8C
  addi r10, r10, 0x1
  fmr f0, f4
  fmr f4, f1
  b loc_0x54

loc_0x8C:
  stfs f0, 0(r3)
  stfs f4, 4(r3)

}

General Directional Input Multiplier 0.012500 -> 0.010325 [Magus]
	float 0.010325 @ $805A17FC
C-Stick Function Directional Input Multiplier 82 -> 100 [Magus]
	float 100.0    @ $805A1818

################################
Controller Input Lag Fix [Magus]
################################
HOOK @ $8002AD8C
{
  add r3, r3, r0
  subi r3, r3, 0x404
}
