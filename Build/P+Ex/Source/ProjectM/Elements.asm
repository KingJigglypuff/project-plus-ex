#########################################################
No Elemental Resistances or Weaknesses on Pokemon [Magus]
#########################################################
op b 0x24 @ $8076C33C

#########################################################################
Light Element is 13, Luigi Green Fire is 15, & Water has GFX v1.2 [Magus]
#########################################################################
address $8076BA38 @ $80AE5D1C
address $8076BA04 @ $80AE5D24
address $8076BA38 @ $80AE5D30
HOOK @ $8076BA18
{
  srawi r12, r0, 2
  cmpwi r12, 15;  bne+ redFire
  lis r4, 0x9;  addi r4, r4, 0x6;  b %END% // Load the fire effect from Luigi's graphic bank, ID 3
redFire:
  li r4, 0x3							   // Normal fire effect
}
HOOK @ $8076BA4C
{
  srawi r12, r0, 2
  cmpwi r12, 13;  beq- lightElement
  cmpwi r12, 18;  beq- waterElement
  
  li r4, 0x57		# effect ID 0x57 (Coin)
  b %END%
lightElement:
  li r4, 0x77		# effect ID 0x77 (Light Bloom)
  lis r12, 0x3F80	# \
  stw r12, 0x10(r2)	# | Load 1.0 into f1 for the scale of the effect
  lfs f1, 0x10(r2)	# /
  b %END%

waterElement:
  li r4, 0x7C		# effect ID 0x7C (Water Splash)
  lis r12, 0x3EC0	# \ 
  stw r12, 0x10(r2) # | Load 0.375 into f1 for the scale of the effect
  lfs f1, 0x10(r2)  # /
}

#######################
Green Fire Thaws [ds22]
#######################
HOOK @ $8088BA4C
{
  cmplwi r0, 5;  beq- %END%
  cmplwi r0, 15
}

################################
Luigi Fire is Green (1/2) [ds22]
################################
HOOK @ $8085BDD4
{
  mr r12, r3
  subi r0, r3, 0x3
}
HOOK @ $8085BE94
{
  cmpwi r12, 15;  bne+ notGreenFire
GreenFire:
  li r4, 0x13;  b %END%
notGreenFire:
  li r4, 0x2
}

###########################################################################
[Project+] Cape won't apply Super Armor to victim, for real this time [Eon]
###########################################################################
op nop @ $807BBFD0

############################################################
Reverse Effect doesn't deal Damage when Shielded V1.1 [ds22]
############################################################
HOOK @ $807451CC
{
  lis r12, 0x8125;    cmplw r25, r12;    blt+ loc_0x5C
                      cmplw r21, r12;    blt+ loc_0x5C
  lis r12, 0x813A;    cmplw r25, r12;    bgt- loc_0x5C
                      cmplw r25, r12;    bgt- loc_0x5C

  lwz r4, 0x30(r3)
  rlwinm r4, r4, 0, 27, 31
					  cmpwi r4, 0x7;    bne+ loc_0x5C
  lwz r4,  0x2C(r21); cmpw r4, r12;     bgt- loc_0x5C
  lwz r12, 0x7C(r4)
  lhz r12, 0x36(r12); cmpwi r12, 0x1A;  blt+ loc_0x5C	# \ if not shielding
					  cmpwi r12, 0x1D;  bgt+ loc_0x5C	# / 
					  cmpwi r12, 0x1C;  beq- loc_0x5C	# or if disengaging shield, let the damage connect
  li r4, 0x0;  
  xoris r0, r4, 0x8000
loc_0x5C:
  stw r0, 0xC(r1)
}