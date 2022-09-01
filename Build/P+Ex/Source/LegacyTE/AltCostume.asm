##############################################################################
[Legacy TE] Restrict Special Character Selection to L [PyotrLuzhin, Yohan1044]
##############################################################################
op li r0, 0x40 @ $8068480C

###################################################################################################################
[Legacy TE] Hold Z for AltZ Characters, R for AltR Characters V2 [PyotrLuzhin, codes, ASF1nk, Yohan1044, DukeItOut]
###################################################################################################################
.macro sqAdvCheck()
{
	lis r12, 0x805B			# \
	lwz r12, 0x50AC(r12)	# | Retrieve the game mode name
	lwz r12, 0x10(r12)		# |
	lwz r12, 0x0(r12)		# /
	lis r3, 0x8070;	ori r3, r3, 0x2B60;	cmpw r3, r12;	# Skip the Dark/Fake check if this is "sqAdventure"
}
.macro AltCos(<arg1>)	// The argument is the address for the port
{	
	* 4A000000 <arg1>
	* 300436F8 00000001
	* 1000009D 0000003E
	* E2100000 00000000
	* 300436F8 00000002
	* 1000009D 0000003D
	* E0000000 80008000		# .RESET
}

HOOK @ $8068478C
{
  stw r9,  0x18(r2)
  stw r10, 0x1C(r2)
  mr r29, r3
  lwz r0, 0x1B4(r24);  cmpwi r0, 0x0;   beq- loc_0x74
  lwz r0, 0x1DC(r24);  cmpwi r0, 0x0;   blt- loc_0x88
					   cmpwi r0, 0xF0;  beq- loc_0x74
  li r9, 0x1
  lis r3, 0x805A
  lhz r10, 0x3A(r3)
  slw r9, r9, r0
  and. r10, r9, r10;  bne- loc_0x74
  lwz r3, 0x40(r3)
  rlwinm r10, r0, 6, 0, 25
  add r3, r3, r10
  lbz r0, 0x27C(r3)
  lwz r3, 0x244(r3);  extsb. r0, r0;  bne- loc_0x74
  li r0, 0x10;      and. r0, r3, r0;  beq- loc_0x74
  
  li r3, 0x1;  b loc_0x8C
loc_0x74:
  li r0, 0x20;  and. r0, r3, r0;  beq- loc_0x88
  li r3, 0x2;  b loc_0x8C
loc_0x88:
  li r3, 0x0

loc_0x8C:
  lis r15, 0x4
  ori r15, r15, 0x3AD8
  stwx r3, r15, r20
  lwz r9,  0x18(r2)
  lwz r10, 0x1C(r2)
  mr r3, r29
}

* 60000000 00000000		# BA = Next Code
%AltCos(90180F20)		# \
%AltCos(90180F7C)		# | Done for each character port
%AltCos(90180FD8)		# |
%AltCos(90181034)		# /

HOOK @ $8084CEE0
{
  %sqAdvCheck()
  bne+ notSSE  # if unequal, it can't be SSE
  cmplwi r23, 12;  b %END%	# is it Dark?
notSSE:
  cmplwi r23, 62			# is it AltZ?
}
HOOK @ $8084CF64
{
  %sqAdvCheck()
  bne+ notSSE  # if unequal, it can't be SSE
  cmplwi r23, 13;  b %END%	# is it Fake?
notSSE:
  cmplwi r23, 61			# is it AltR?
}
word[4] 0x4800001C, 0x416C7452, 0x00416C74, 0x5A000000 @ $8084CF38 # b 0x1C, "AltR", "AltZ"
op b 0x1C @ $8084CFBC
HOOK @ $8084CF54
{
  addi r4, r29, 0xAC0
  cmplwi r23, 62;  bne- %END%			// Check if it's AltZ 
  lis r6, 0x8084;  ori r6, r6, 0xCF41	// If it is, get a pointer to the string "AltZ" 
}
HOOK @ $8084CFD8
{
  addi r4, r29, 0xAC0
  cmplwi r23, 61;  bne- %END%			// Check if it's AltR
  lis r6, 0x8084;  ori r6, r6, 0xCF3C	// If it is, get a pointer to the string "AltR"
}
HOOK @ $8084CDDC
{
  %sqAdvCheck()
  bne+ notSSE  # if unequal, it can't be SSE
  cmplwi r23, 12;  b firstCheck	# check if it's Dark
notSSE:
  cmplwi r23, 61	# is it AltR?
firstCheck:
  beq- %END%
  cmplwi r23, 62	# is it AltZ?
}
op b 0x1C @ $8084CE34
HOOK @ $8084CE50
{
  addi r4, r29, 0xAC0
  cmplwi r23, 61;  beq- AltR
  cmplwi r23, 62;  bne+ %END%
AltZ:  
  lis r6, 0x8084;  ori r6, r6, 0xCF41;  b %END%	// Load the string "AltZ"
AltR:
  lis r6, 0x8084;  ori r6, r6, 0xCF3C			// Load the string "AltR"
}

####################
AltR/Z EX Fix [Desi]
####################
op lwz r7, 0x0A14 (r28) @ $8084CFB8
op lwz r6, 0x0A18 (r28) @ $8084CE28
op lwz r7, 0x0A14 (r28) @ $8084CE30

#############################################################################
[Legacy TE] Dark/Fake Kirby Fix v2.3 [PyotrLuzhin, Yohan1044, DukeItOut, Eon]
#############################################################################
HOOK @ $8084DF28
{
  addi r6, r1, 0x20		# original operation
  cmpwi r23, 62;  beq- AltZKirby
  cmpwi r23, 61;  beq- AltRKirby
  b %END%
AltZKirby:
  li r10, 0x5F5A;  b loc_0x24	# point to the "AltZ" string
AltRKirby:
  li r10, 0x5F52				# point to the "AltR" string
loc_0x24:
  sth r10, 0(r6)
}
HOOK @ $8084DE44
{
  lis r5, 0x805B     	# \
  lwz r5, 0x50AC(r5)  # | Retrieve the game mode name
  lwz r5, 0x10(r5)    # |
  lwz r5, 0x4(r5)     # |
  lwz r5, 0x15(r5)    # / And grab the 2nd-through-5th characters in the string (string starts at 0x14)
  lis r6, 0x7141      	# \
  ori r6, r6, 0x6476    # / "qAdv", as in "sqAdventure"
  cmpw r5, r6
  bne skip
#Dont load kirby Hat for costume 12
  cmpwi r8, 12
  b %end%
skip:
#Always load kirby hat
  cmpwi r8, -1
  
}

##############################################
[Legacy TE] Dark/Fake Solo Mode Fix [Fracture]
##############################################
HOOK @ $806CBFA8
{
  lis r4, 0x4;  ori r4, r4, 0x3A7C	// r4 = 0x43A7C
  lis r3, 0x805A;  lwz r3, 0xE0(r3);  lwz r3, 0x10(r3)
  add r3, r3, r4
  li r4, 0x0
  li r5, 0x0
  cmpwi r5, 0x4;  bge- skip
seekLoop:
  stwu r4, 92(r3)
  addi r5, r5, 0x1
  cmpwi r5, 0x4;  blt+ seekLoop
skip:
  li r0, 0x5
}