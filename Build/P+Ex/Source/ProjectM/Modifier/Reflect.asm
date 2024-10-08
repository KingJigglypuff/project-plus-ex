############################################################################
Powershield & Reflect Collision Modifier Engine V1.2a + SSE Exception[Magus]
############################################################################
HOOK @ $80751204
{
  cmpwi r0, 0x1;  bne- loc_0x110

  lis r6, 0x805B		# \
  lwz r6, 0x50AC(r6)	# | Retrieve the game mode name 
  lwz r6, 0x10(r6)		# |
  lwz r6, 0x0(r6)
  lwz r6, 0x1(r6)		# /
  lis r0, 0x7141		# qA
  ori r0, r0, 0x6476 	# dv   qAdv as in sqAdventure
  cmpw r6, r0 			# if current gamemode = sqAdventure, end
  beq loc_0x110

  lis r6, 0x8000;
  lis r0, 0x8139;  cmpw r7, r0;  bge- loc_0x110
  lwz r4, -0x1C(r7); cmplw r4, r6; blt loc_0x110
  lwz r4, -0x18(r4); cmplw r4, r6; blt loc_0x110
  lwz r6, 0x7C(r4)
  lhz r6, 0x36(r6);  cmpwi r6, 0x1A;  bne- loc_0xB4
  lwz r8, 0x30(r4)
  lwz r8, 0x20(r8);  addi r8, r8, 0xC;  cmpw r8, r11;  beq+ loc_0x110
  lwz r9, 0x70(r4)
  lwz r9, 0x20(r9)
  lwz r9, 0x14(r9)
  lwz r10, 0xD0(r4)
  lfs f0, 0xC(r9)
  lis r9, 0x80B8;  ori r9, r9, 0x8440
  lfs f2, 0x10(r9);  fadds f0, f0, f2
  lfs f2, 0(r9);  fdivs f0, f0, f2
  lfs f2, 0x38(r9);  fmuls f0, f0, f2
  stfs f0, 0x18(r2)
  lfs f2, 4(r9)
  lfs f0, -0x5BA8(r2);  fsubs f2, f0, f2
  lfs f0, 0x18(r2);  fmuls f0, f0, f2
  lfs f2, 4(r9);  fadds f0, f0, f2
  lfs f2, 0x40(r10);  fmuls f0, f0, f2
  lwz r9, 0x1C(r8)
  stfs f0, 0x18(r2)
  stw r9, 0x1C(r2)
  mr r11, r2
  mr r3, r8
  b loc_0x110

loc_0xB4:
  lis r12, 0x8120
  lis r8,  0x9380
  lwz r5, 0x70(r4)	# \
  lwz r5, 0x20(r5)	# |
  lwz r5, 0x0C(r5)	# | Access character ID
  lwz r5, 0x2D0(r5)	# |
  cmpw r5, r12;		blt- loc_0x110
  cmpw r5, r8;		bge- loc_0x110
  lwz r5, 0x08(r5)	# |
  cmpw r5, r12;		blt- loc_0x110
  cmpw r5, r8;		bge- loc_0x110  
  lwz r5, 0x110(r5)	# /
  cmpwi r5, 0x37;  bge- loc_0x110
  lwz r8, 0x14(r4)
  lwz r8, 0x58(r8)
  ori r8, r8, 0x8000
  lis r12, 0x8075			# \
  lwz r12, 0x120C(r12)		# | Pointer to reflect collision modifier data -0x18
  subi r12, r12, 0x28		# /
loc_0xDC:
  lwzu r10, 0x28(r12);  		cmpwi r10, 0x0;  blt- loc_0x110
  srawi r9, r10, 24;  			cmpw r9, r5;  bne+ loc_0xDC
  rlwinm r9, r10, 0, 16, 31;  	cmpw r9, r6;  beq+ loc_0x108
								cmpw r9, r8;  bne- loc_0xDC

loc_0x108:
  addi r3, r12, 0x4
  mr r11, r3

loc_0x110:
  lfs f0, 0(r3)
  li r0, 0			# \ Operations displaced by the below
  fmr r2, f1		# |
  mr r4, r31		# /
}
op b 0xC @ $80751208

* 4A000000 90000000
* 30FFA430 00000005
* 04751204 C0030000
* E0000000 80008000

	.BA<-ReflectModifierTable
	.BA->$8075120C
	.GOTO->SkipReflectTable
# Reflect Collision Modifier Data
ReflectModifierTable:
* 14000117 00000000
* C0E00000 00000000
* 00000000 41600000
* 00000000 40880000
* 22DD8678 11111111
* 26000113 00000000
* 00000000 00000000
* 00000000 00000000
* 00000000 40E00000
* 23474EC0 11111111
* FEEEEEED DEDEDEDE

SkipReflectTable:
	.RESET

################################################
Reflect Collision Multiplier Engine V2.1a [ds22]
################################################
HOOK @ $80753FA4
{
  lfs f1, 0xA0(r3)
  cmpwi r4, 0x1;  bne- loc_0x80
  lwz r11,0x1C(r31) # \
  lwz r3, 0x70(r11)	# |
  lwz r3, 0x20(r3)	# |
  lwz r3, 0x0C(r3)	# | Access character ID
  lwz r3, 0x2D0(r3)	# |
  lwz r3, 0x08(r3)	# |
  lwz r3, 0x110(r3)	# /
  cmpwi r3, 0x37;  bge- loc_0x80	# Bail if too high to be a normal character (modify this value if using BrawlEX)
  lwz r4, 0x7C(r11)
  lhz r4, 0x36(r4)
  lwz r7, 0x14(r11)
  lwz r7, 0x58(r7)
  ori r7, r7, 0x8000
  lis r12, 0x8075		# \
  lwz r12, 0x1210(r12)	# | Pointer to Reflect Collision Multiplier Data - 0xC
  subi r12, r12, 0xC	# /
loc_0x40:
  lwzu r8, 0xC(r12)
  cmpwi r8, 0x0;  blt- loc_0x80
  srawi r9, r8, 24
  cmpw r9, r3;  bne+ loc_0x40
  rlwinm r9, r8, 0, 16, 31
  cmpw r9, r4;  beq+ loc_0x6C
  cmpw r9, r7;  bne- loc_0x40

loc_0x6C:
  lfs f0, 8(r12)
  stfs f0, 0x30(r28)
  lfs f1, 4(r12)
  li r7, 0x1
  b %END%

loc_0x80:
  li r7, 0x0
}
HOOK @ $8076EBE8
{
  cmpwi r7, 0x1
  beq- %END%
  stfs f1, 0x30(r28)
}
	.BA<-ReflectMultiplierTable
	.BA->$80751210
	.GOTO->SkipReflectTable
	
#Reflect Collision Multiplier Data
ReflectMultiplierTable:
* 14000117 3F800000
* 3FC00000 26000113
* 3F800000 3F800000
* FEEEEEED DEDEDEDE

SkipReflectTable:
	.RESET