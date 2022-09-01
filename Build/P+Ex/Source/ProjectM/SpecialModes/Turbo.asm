##################################################################################
Turbo Mode - On Hit Interrupts v1.2 [Magus, Dantarion, standardtoaster, DukeItOut]
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
  lhz r0, 8(r12);  cmpwi r0, 0x5;   bne- loc_0x100
  lwz r0, 0x34(r3);  cmpwi r0, 0x3A;  beq- loc_0x100
				   cmpwi r0, 0x3C;  beq- loc_0x100
  lwz r3, 0xCC(r3)
  lwz r4, 0x70(r3)
  lwz r5, 0x20(r4)
  lwz r5, 0x1C(r5)
  lwz r12, 0(r5);  andi. r12, r12, 0x400;  beq+ loc_0x100
  lwz r5, 0x24(r4)
  lwz r5, 0x1C(r5)
  lwz r12, 4(r5)
  rlwinm r4, r12, 9, 31, 31
					cmpwi r4, 0x1;  beq- loc_0x100
  lis r4, 0x100
  or r12, r12, r4
  stw r12, 4(r5)
					cmpwi r0, 0x33;  bne+ loc_0x8C
  lis r4, 0x4000
  lwz r12, 0(r5)
  andc r12, r12, r4
  stw r12, 0(r5)

loc_0x8C:
  lwz r4, 0x20(r3)
  lwz r4, 0x30(r4)
  lwz r3, 0x78(r3)
  lwz r3, 0xE0(r3)
  addi r3, r3, 0x50
  lis r12, 0x8084;  ori r12, r12, 0xB6D8;  mtctr r12;  li r12, 0x2329;  bctrl 

  addi r31, r1, 0x8 
  li r5, 8
  sth r5, 0(r31)
  sth r5, 4(r31)
  sth r5, 8(r31)
  li r5, 0x273E		# \ Turn (Slow)
  sth r5, 2(r31)	# /
  li r5, 0x2743 	# \ Enter Crouch 
  sth r5, 6(r31)	# /
  li r5, 0x274B 	# \ Walk
  sth r5, 0xA(r31)	# /
  li r5, 0x7FFF 
  sth r5, 0xC(r31) 	# Terminator 
 
loc_0xC8:
  lhzu r5, 4(r31)
  cmpwi r5, 0x7FFF
  beq- loc_0x100
  lhz r4, 2(r31)
  lwz r3, 0x30(r1)
  lwz r3, 0x2C(r3)
  lis r12, 0x8078;  ori r12, r12, 0x15C0;  mtctr r12;  bctrl 
  b loc_0xC8

loc_0x100:
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
  lbz r0, 0x39(r3)
}

##############################################
Turbo Mode - Repeat Action Change v1.2 [Magus]
##############################################
HOOK @ $8077F184
{
					cmpwi r0,    -1;  beq+ loc_0x164
  lwz r12, 0x10(r1);cmpwi r12, 0x24;  blt+ loc_0x164
  lis r11, 0x8180
  lwz r5, 8(r31);  	cmpw r5, r11;  bge- loc_0x164
  lwz r5, 0x70(r31)
  lwz r6, 0x24(r5)
  lwz r6, 0x1C(r6)
  lwz r6, 4(r6)
  rlwinm r6, r6, 8, 31, 31
					cmpwi r6, 0x1;  bne+ loc_0x164
  lwz r6, 0x7C(r31)
  lhz r6, 0x36(r6); cmpwi r6, 0x2A;  blt+ loc_0xA4		# \ All Smash attacks
					cmpwi r6, 0x32;  bgt+ loc_0xA4		# /
					cmpwi r6, 0x2D;  bge+ loc_0x84
					cmpwi r12, 0x2A;  beq- loc_0x160	# Side Smash startup
  b loc_0x164

loc_0x84:
					cmpwi r6, 0x30;  bge- loc_0x98
					cmpwi r12, 0x2D;  beq- loc_0x160
  b loc_0x164

loc_0x98:
					cmpwi r12, 0x30;  beq- loc_0x160
  b loc_0x164

loc_0xA4:
					cmpw r6, r12;  bne+ loc_0x164
					cmpwi r12, 0x33;  bne+ loc_0x160
  lwz r3, 0x68(r31)
  lis r12, 0x8076
  ori r12, r12, 0x41AC
  mtctr r12
  bctrl 
  li r0, 0x0
  lwz r12, 0x68(r31)
  lfs f2, 0x38(r12)
  lfs f3, 0x3C(r12)
  lwz r12, 0x18(r31)
  lfs f4, 0x40(r12)
  fmuls f2, f2, f4
  lis r11, 0x3E80	# 0.25
  li r12, 0x0
  stw r11, 0x10(r2)
  stw r12, 0x14(r2)
  lfs f4, 0x10(r2)
  lfs f5, 0x14(r2)
  fabs f6, f2;  fcmpo cr0, f6, f4;  bge- loc_0x11C
  fabs f6, f3;  fcmpo cr0, f6, f4;  bge- loc_0x11C
  li r11, 0x62
  b loc_0x150

loc_0x11C:
				cmpwi r3, 0x1;  bne- loc_0x13C
				fcmpo cr0, f2, f5;  blt- loc_0x134
  li r11, 0x63
  b loc_0x150

loc_0x134:
  li r11, 0x64
  b loc_0x150

loc_0x13C:
				fcmpo cr0, f3, f5;  blt- loc_0x14C
  li r11, 0x65
  b loc_0x150

loc_0x14C:
  li r11, 0x66

loc_0x150:
  lwz r12, 0x14(r31)
  lhz r12, 0x5A(r12);  cmpw r11, r12;  bne+ loc_0x164

loc_0x160:
  li r0, -1

loc_0x164:
  cntlzw r0, r0
}


Turbo Mode - Disable Curry Wait and Run [Magus]
* 04FAC8F0 800000FF
* 04FAB728 800000FF
* 04FABB88 800000FF

Turbo Mode - Curry Special Brawl Uses Curry Aura [Magus]
* 048434D4 60000000

Turbo Mode - Curry Special Brawl Doesn't Exclude Nana [Magus]
* 048377C8 60000000

Super Spicy Curry has no SFX [standardtoaster]
* 04843540 60000000