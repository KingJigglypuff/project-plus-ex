########################################################
No Reverse Grabbing in Common Actions [Dantarion, Magus]
########################################################
HOOK @ $807357CC
{
  rlwinm r4, r0, 11, 29, 31
  cmpwi r27, 0x112;  bge- %END%	//only special moves can ledge grab backwards
  cmpwi r4, 0x2;  blt- %END%
  li r4, 0x1
}

##############################################################
Melee Edge Grab Box Offset Mechanics & Thin Ledges Fix v1.1 [Magus, Eon]
##############################################################
op lis r28, 0x0 	@ $80B883AC
HOOK @ $8013598C
{
loc_0x0:
  	stw r0, 0x84(r1)
	mfcr r6
	sub r4, r4, r3
	cmpwi r4, 28 #if offset from r3 is not looking at current frames positioning, look at previous frames positioning.

  	lwz r10, 0x64(r3)
  	lwz r10, 0x30(r10)
  	lwz r4, 0x18(r10)
  	addi r4, r4, 0x0C
  	lwz r9, 0x60(r3)

	#If not checking current, update lookup
	beq loc_0x38
  	addi r4, r4, 0xC
  	addi r9, r9, 0x3C

loc_0x38:
	mtcr r6
  	lfs f3, 0x90(r1)
  	lfs f4, 0x88(r1)
  	lfs f5, 0x80(r1)
  	lfs f6, 0x00(r4)
  	lfs f7, 0x1C(r9)
  	lfs f8, 0x24(r9)
  	fsubs f7, f6, f7;  fsubs f8, f8, f6
  	bne- loc_0x6C
  	fmr f0, f8
  	fmr f8, f7
  	fmr f7, f0
loc_0x6C:
  	fadds f4, f4, f8;  fadds f5, f5, f7
  	fsubs f4, f4, f3;  fadds f5, f5, f3
  	stfs f4, 0x88(r1);  stfs f5, 128(r1)
}

##########################################################
Slide Off Edges in Certain Actions v2.3 [Magus, DukeItOut]
##########################################################
HOOK @ $807357AC
{
  stwu r1, -0x10(r1)
  stmw r30, 8(r1)
	lis r5, 0x8100
  lis r6, 0x8000
  lis r30, 0x8180;     cmplw r4, r30;    bge- loc_0xB4		# \
                       cmplw r4, r6;     blt loc_0xB4     # |
  lwz r31, 0x64(r4);   cmplw r31, r30;   bge- loc_0xB4		# |
                       cmplw r31, r6;    blt loc_0xB4     # |
  lwz r31, 0x5C(r31);  cmplw r31, r30;   bge- loc_0xB4		# |
                       cmplw r31, r6;    blt loc_0xB4     # |
  lwz r31, 0x70(r31);  cmplw r31, r30;   bge- loc_0xB4		# |
                       cmplw r31, r6;    blt loc_0xB4     # |
	lwz r31, 0x20(r31);  cmplw r31, r5;	   blt- loc_0xB4		# |
	           					 cmplw r31, r30;	 bge- loc_0xB4		# |
	lwz r31, 0x0C(r31);	 									                  # |
                       cmplw r31, r6;    blt loc_0xB4     # |
	lis r5, 0x9380
	lwz r31, 0x2D0(r31); cmplw r31, r5;	   bge- loc_0xB4		# |
                       cmplw r31, r6;    blt loc_0xB4
	lwz r31, 0x00(r31);	 cmpwi r31, 0x502B; bne- loc_0xB4	#/ Make sure it is a character!
  	cmpwi r27, 0x13; beq- loc_0x64
  	cmpwi r27, 0x14; beq- loc_0x64
  	b loc_0x6C
loc_0x64:
  	li r4, 0x3
  	b loc_0xB8
loc_0x6C:
  	cmpwi r27, 0x0; beq- loc_0xAC
  	cmpwi r27, 0x3; beq- loc_0xAC
  	cmpwi r27, 0x6; beq- loc_0xAC
  	cmpwi r27, 0x7; beq- loc_0xAC
  	cmpwi r27, 0x11; blt+ loc_0xA0
  	cmpwi r27, 0x1D; bgt+ loc_0xA0
  	b loc_0xAC
loc_0xA0:
  	cmpwi r27, 0x86; beq- loc_0xAC
  	b loc_0xB4
loc_0xAC:
  	li r4, 0x1
  	b loc_0xB8
loc_0xB4:
  	rlwinm r4, r0, 8, 28, 31
loc_0xB8:
  	lmw r30, 8(r1)
  	addi r1, r1, 0x10
	mr r5, r31
}
# -Wait, Dash, Turns, Squats, Landings, Shields. Crawls are 3

###########################################################
Knockback doesn't Initiate Edge Grab Waiting Period [Magus]
###########################################################
op NOP @ $808758E0

###############################################
Ledge Possession Controlled by Variable [Magus]
###############################################
op NOP 		@ $8087AD9C
op li r0, 0xB	@ $8087AE00
HOOK @ $80112E60
{
loc_0x0:
  	stwu r1, -24(r1)
  	stmw r28, 8(r1)
  	lis r28, 0x8180;    cmpw r26, r28;  bge- loc_0x8C
  	lwz r29, 0x60(r26); cmpw r29, r28;  bge- loc_0x8C
  	lwz r30, 0x7C(r29); cmpw r30, r28;  bge- loc_0x8C
  	lhz r31, 0x36(r30); cmpwi r31, 0x76;blt- loc_0x8C
 			    cmpwi r31, 0x78;bgt- loc_0x8C
  	lhz r31, 0x3A(r30); cmpwi r31, 0x76;blt- loc_0x8C
  			    cmpwi r31, 0x78;bgt- loc_0x8C
  	lwz r30, 0x70(r29); cmpw r30, r28;  bge- loc_0x8C
  	lwz r30, 0x24(r30); cmpw r30, r28;  bge- loc_0x8C
  	lwz r30, 0x1C(r30); cmpw r30, r28;  bge- loc_0x8C
  	lbz r31,    3(r30); cmpwi r31, 0x4; beq- loc_0x8C
  	cmplw r2, r4
  	b loc_0x90
loc_0x8C:
 	cmplw r0, r4
loc_0x90:
  	lmw r28, 8(r1)
  	addi r1, r1, 0x18
}

###################################################################################################################################
[Project+] Tethers Can't Edgehog or Be Edgehogged v1.4 (P+ : Nana Occupies ledge during Up-b and ZSS/Ivysaur Up-b fix) [Magus, Eon]
###################################################################################################################################
HOOK @ $80112DBC
{
	stw r4, 0x10(r2)
	li r0, 0x8
}
op beq- 0x14	@ $80112DF4
HOOK @ $80112DF8
{
.alias PreviousAction = 25
.alias CurrentAction = 28
.alias OpponentPrevAction = 29
.alias OpponentAction = 31
.alias Character = 26
.alias OpponentCharacter = 22
.alias CurrentFrame = 23


  #store r22+ for end
  stwu r1, -0x30(r1)
  stmw r22, 8(r1)

  lis r24, 0x8180

  lwz r25, 0x10(r2);    cmpw r25, r24;  bge- default
  lwz r25, 0x64(r25);  cmpw r25, r24;  bge- default
  lwz r25, 0x5C(r25);   cmpw r25, r24;  bge- default

  lwz r26, 0x8(r25);    cmpw r26, r24;  bge- default

  lwz r26, 0x70(r25)		# \
  lwz r26, 0x20(r26)		# | Access LA-Bit and Character ID
  							# |
  lwz r27, 0x14(r26)		# |
  							# |
  lwz r26, 0x0C(r26)		# |
  lwz r26, 0x2D0(r26)		# |
  lwz r26, 0x08(r26)		# |
  lwz Character, 0x110(r26) # /


  lwz r28, 0x7C(r25);  cmpw r28, r24;  bge- default

  lwz r25, 0x14(r25);  cmpw r25, r24;  bge- default
  lfs CurrentFrame, 0x40(r25)

  lhz PreviousAction, 0x06(r28)

  lhz CurrentAction, 0x3A(r28)



  lwz r29, 0(r7);     cmpw r29, r24;  bge- default
  lwz r29, 0x64(r29);  cmpw r29, r24;  bge- default
  lwz r29, 0x5C(r29);   cmpw r29, r24;  bge- default
  lwz r30, 0x70(r29);  cmpw r30, r24;  bge- default
  lwz r30, 0x24(r30);   cmpw r30, r24;  bge- default
  lwz r30, 0x1C(r30);   cmpw r30, r24;  bge- default
  lwz r31, 0x7C(r29);  cmpw r31, r24;  bge- default

  lwz r22, 0x70(r29)
  lwz r22, 0x20(r22)
  lwz r22, 0x0C(r22)
  lwz r22, 0x2D0(r22)
  lwz r22, 0x8(r22)
  lwz OpponentCharacter, 0x110(r22)


  lhz OpponentPrevAction, 0x6(r31)
  lhz OpponentAction, 0x36(r31); 

SpecialCases:  
  cmpwi Character, 0x18;  beq- zssCheck
	cmpwi Character, 0x1F;  beq- ivysaurCheck
  b CommonActionsCheck

zssCheck:
	cmpwi CurrentAction, 0x113;  beq- LedgeFree
	cmpwi CurrentAction, 0x114;  beq- zssCheckUpbFrame
  b CommonActionsCheck

zssCheckUpbFrame:
  lis r24, 0x4140   // 12.0 float
  stw r24, 0x40(r1)
  lfs f17, 0x40(r1)
  fcmpu, 0, CurrentFrame, f17
  blt LedgeFree
  b CommonActionsCheck
  

ivysaurCheck:
	cmpwi CurrentAction, 0x114;  bne CommonActionsCheck
  	lis r24, 0x41A0   // 20.0 float
  	stw r24, 0x40(r1)
  	lfs f17, 0x40(r1)
  	fcmpu, 0, CurrentFrame, f17
  	blt LedgeFree

CommonActionsCheck:
	cmpwi CurrentAction, 0x7F;  blt- CommonActionsCheck2
	cmpwi CurrentAction, 0x82;  bgt- CommonActionsCheck2
  b LedgeFree
CommonActionsCheck2:
	cmpwi OpponentAction, 0x75;  bne- EnemyCheck1
	cmpwi OpponentPrevAction, 0x82;  bne- EnemyCheck1

  lbz r30, 2(r30);  cmpwi r30, 0x4;  beq- EnemyCheck1
  b LedgeFree

EnemyCheck1:
  cmpwi OpponentCharacter, 0x0F;  bne EnemyCheck2
  cmpwi OpponentAction, 0x11E;  beq ledgeHeld

EnemyCheck2:
	cmpwi OpponentAction, 0x73;   blt- LedgeFree
	cmpwi OpponentAction, 0x79;  bgt- LedgeFree

CommonActionsCheck3:
	cmpwi CurrentAction, 0x75;  bne- ledgeHeld3
	cmpwi PreviousAction, 0x82;  bne- ledgeHeld2

ledgeHeld:
  lis r24, 0xC040	// -3.0 float
  stw r24, 28(r27)
  b ledgeHeld3

ledgeHeld2:
  li r24, 0x0		// 0.0 float
  stw r24, 28(r27)

ledgeHeld3:
  cmplw r0, r6;  
  b end
LedgeFree:
  cmpwi CurrentAction, 0x75;  bne- LedgeFree2
  li r24, 0x0		// 0.0 float
  stw r24, 28(r27)

LedgeFree2:
  cmplw r6, r6;  
  b end
default:
  cmplw r0, r6
end:
  lmw r22, 8(r1)
  addi r1, r1, 0x30
}

op beq- 0xC @ $80112DFC
HOOK @ $80112E10
{
  	stwu r1, -0x18(r1)
  	stmw r28, 8(r1)
  	lis r28, 0x8180
  	lwz r29, 0x10(r2);   cmpw r29, r28; bge- RETURN
  	lwz r29, 0x64(r29);  cmpw r29, r28; bge- RETURN
  	lwz r29, 0x5C(r29);  cmpw r29, r28; bge- RETURN
  	lwz r30, 0x70(r29);  cmpw r30, r28; bge- RETURN
  	lwz r30, 0x24(r30);  cmpw r30, r28; bge- RETURN
  	lwz r30, 0x1C(r30);  cmpw r30, r28; bge- RETURN
  	lwz r31, 0x7C(r29);  cmpw r31, r28; bge- RETURN
  	lhz r29,  0x6(r31)
  	lhz r31, 0x36(r31);  cmpwi r31, 0x75; bne- RETURN
 			             cmpwi r29, 0x82; bne- RETURN
 	li r28, 0x4
  	stb r28, 2(r30)
RETURN:
  	lmw r28, 8(r1)
  	addi r1, r1, 0x18
  	blr 
}

####################################################################################
Ledge Invinicibility Is Zero after 5 Ledge Grabs V2.2 [standardtoaster, ds22, Magus]
####################################################################################
HOOK @ $8074D070
{
  cmpwi r27, 0x75
  bne- ledgeGrabs		//skip if not in the ledge hang action
  lwz r5, 0x2C(r28);  lwz r5, 0x70(r5)
  lwz r5, 0x20(r5);  lwz r5, 0xC(r5)
  lwz r27, 0x13C(r5)
  addi r27, r27, 0x1		//increment ledge counter
  stw r27, 0x13C(r5)
  cmpwi r27, 0x5		//if consecutive grab count is >5
  bgt- tooManyLedgeGrabs	//don't grant invuln
  b ledgeGrabs
tooManyLedgeGrabs:
  li r4, 0x0
ledgeGrabs:
  stw r4, 0x24(r3)
}

