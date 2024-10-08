#######################################################################
[Legacy TE] Unbounded Team Color Engine EX Variant [DukeItOut, DesiacX]
#
# 1.1: Adjusted to accomodate Mdl+Tex splitting
#######################################################################
CODE @ $806998D0
{
	addi r28, r28, 0x1; 	nop; nop; nop;
}
CODE @ $80699C14
{
	subi r28, r28, 0x1; 	nop; nop; nop;
}
op b 0x1C 	@ $806974F8
op b 0x24       @ $80684978
op NOP 		@ $80699B8C
op NOP		@ $80699ED0
HOOK @ $800AF520			# team color implementation
{
  	stwu r1, -0x20(r1)		# on entry: r24 = 1 if forwards seek, -1 if backwards seek
  	stw r27,  0x0C(r1)		
  	stw r26,  0x08(r1)		
  	stw r28,  0x10(r1)		
  	li r26, -1			# r26 = most-recent match
  	li r27, 0x0			# r27 = first match
  	li r28, 0x0			# r28 = incrementing counter
  	li r5, 0x0
  	lis r6, 0x817D			# previously 80455458 (PM/Vbrawl), 80585B00 (LTE/P+)
  	ori r6, r6, 0x52A0		# table of characters
  	subi r7, r2, 0x7130
  	rlwinm r0, r3, 4, 0, 27
  	rlwinm r8, r5, 1, 0, 30
  	lbzx r9, r7, r4
	andi. r9, r9, 0xF		# Lower nybble
  	add r3, r6, r0
  	lwz r7, 8(r3)
  	add r3, r7, r8
  	mr r6, r7
  	cmpwi r25, 0x0; 	bge+ continue
  	li r25, -1
get_last:
  	lbz r0, 0(r3); 
	andi. r0, r0, 0xF		# Lower nybble
	cmpw r0, r9; 		bne- not_a_match
  	addi r25, r25, 0x1
  	mr r27, r5
not_a_match:
  	cmplwi r0, 0xC
  	addi r3, r3, 2
  	addi r5, r5, 1
  	bne+ get_last
  	mr r3, r27
  	b end_t
continue_b:
  	addi r3, r3, 2
 	addi r5, r5, 1
continue:
  	lbz r0, 0(r3)
  	cmplwi r0, 0xC;		beq+ end
	andi. r0, r0, 0xF		# Lower nybble
  	cmpw r0, r9;		beq+ found_match
  	b continue_b			# Loop if not found
end:
	li r25, 0
	mr r3, r26
	b end_t
found_match:
  	cmpwi r26, 0;	bge+ not_first
  	mr r26, r5			# r26 = first match, used for wraparound case
not_first:
  	mr r27, r5			# r27 = most recent match
  	cmpw r25, r28			# check if current team subcolor
  	addi r28, r28, 0x1; 	blt- end
  			        bne+ continue_b
  	mr r3, r5
end_t:
  	lwz r27, 0x0C(r1)
  	lwz r26, 0x08(r1)
  	lwz r28, 0x10(r1)
  	addi r1, r1, 0x20
  	stb r25, 0x1C4(r30)	# store team subcolor to reobtain
  	blr 
}
HOOK @ $80696628
{
  	stwu r1, -0x20(r1); stw r30, 0x1C(r1);  stw r29, 0x18(r1)
  	stw r28, 0x14(r1);  stw r27, 0x10(r1);  stw r26, 0x0C(r1)
  	lbz r31, 0x1C4(r30)				# get team subcolor
  	mr r26, r0			//r0 has "team color"
  	cmpwi r26, 0x2; bne- notGreen	//if trying to find green team
  	li r26, 0x3			//it's 3, not 2
notGreen:
  	li r27, 0x0; li r28, 0x0; li r29, 0x0; li r30, 0x0
  	lis r5, 0x817D; addi r5, r5, 0x52A0	//access costume data
  	rlwinm r0, r3, 4, 21, 27		//r3 = character instance ID, used as an index
  	li r6, 0x0
  	add r5, r5, r0
  	lwz r3, 8(r5)
  	b start
loop:
  	addi r3, r3, 0x2
  	addi r6, r6, 0x1
start:
 	lbz r30, 0(r3)
  	cmpwi r30, 0xC;  beq- abort	//came across the footer for the data table, terminate attempt to go past
  	andi. r30, r30, 0xF		# Lower nybble
	cmpw r26, r30;   bne+ loop	//but the code can still wrap around
  	mr r29, r6
  	cmpw r28, r31; 
	addi r28, r28, 0x1; 
	blt+ loop
abort:
 	mr r3, r29
  	lwz r30, 0x1C(r1); lwz r29, 0x18(r1); lwz r28, 0x14(r1)
  	lwz r27, 0x10(r1); lwz r26, 0x0C(r1); addi r1, r1, 0x20
}
op bl -0x5D5484 @ $806849A8 //find character team color
HOOK @ $800AF524		//team color preservation on SSS
{
  	stwu r1, -0x30(r1); stw r30, 0x1C(r1); stw r29, 0x18(r1)
  	stw r28, 0x14(r1);  stw r27, 0x10(r1); stw r26, 0x0C(r1); stw r0,  0x20(r1)
  	lwz r0,  0x1C0(r24)
  	lbz r31, 0x1C4(r24)
  	mr r26, r0
  	cmpwi r0, 0x2
  	bne- notGreen
  	li r26, 0x3
notGreen:
 	li r27, 0x0; li r28, 0x0; li r29, 0x0; li r30, 0x0
  	lis r5, 0x817D; addi r5, r5, 0x52A0
  	rlwinm r0, r3, 4, 21, 27
  	li r6, 0x0
  	add r5, r5, r0
 	lwz r3, 8(r5)
 	b start
loop:
  	addi r3, r3, 0x2
  	addi r6, r6, 0x1
start:
  	lbz r30, 0(r3);		
	cmpwi r30, 0xC;		beq- abort
	andi. r30, r30, 0xF		# Lower nybble
  	cmpw r26, r30;		bne+ loop
  	mr r29, r6
  	cmpw r28, r31; 
  	addi r28, r28, 0x1
  	blt+ loop
abort:
  	mr r3, r29
  	lwz r0, 0x20(r1); lwz r30, 0x1C(r1); lwz r29, 0x18(r1)
  	lwz r28, 0x14(r1); lwz r27, 0x10(r1); lwz r26, 0xC(r1)
  	addi r1, r1, 0x30
  	blr 
}
op NOP 			@ $80685C18
op mr r5, r0	@ $80685C08
HOOK @ $80685C10 # Retainment of team color upon reentering CSS
{
  	lwz r3, 0x50(r1)
  	stwu r1, -0x20(r1); stw r30, 0xC(r1);  stw r29, 8(r1);  stw r28, 4(r1)
  	stw r5,  0x14(r1);  stw r26, 0x18(r1); stw r27, 0x1C(r1)
  	rlwinm r28, r5, 4, 21, 27
  	lis r29, 0x817D
  	ori r29, r29, 0x52A0
  	add r29, r29, r28
  	li r28, -1
  	lwz r29, 8(r29)
  	cmplw r29, r28;	beq- alreadyMatched
 	mr r26, r3
  	li r30, 0x0
  	li r28, 0x0
  	li r27, 0x0
  	cmpwi r26, 0x2; bne- notGreen
  	li r26, 0x3
notGreen:
  	b start
loop:
  	addi r29, r29, 0x2
  	addi r28, r28, 0x1
start:
  	lbz r30, 0(r29)
  	cmpwi r30, 0xC; beq- abort
	andi. r30, r30, 0xF		# Lower nybble
  	cmpw r30, r26;  bne+ loop
  	lbz r30, 1(r29)
 	cmpw r28, r0;	beq- abort
 	addi r27, r27, 0x1
  	b loop
abort:
  	mr r0, r27
alreadyMatched:
  	lwz r27, 0x1C(r1);  lwz r26,0x18(r1); lwz r5, 0x14(r1)
  	lwz r28, 0x4(r1);   lwz r29, 0x8(r1); lwz r30, 0xC(r1)
  	addi r1, r1, 0x20
}

op b 0x2C0 @ $80698b74 #disables wario specific team colour coding that conflicts with system 