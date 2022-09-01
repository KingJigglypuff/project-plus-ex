
#######################################################################################
Stage Striking & Page Switch (Requires Custom SSS) [Magus, InternetExplorer, DukeItOut]
#######################################################################################
# address 9017BE70: Random Stage Switch block for Melee+Custom
# address 9017BE74: Random Stage Switch block for Brawl
# address 8053E570: Stage Strike Block for Melee
# address 8053E574: Stage Strike Block for Brawl
# address 8053E578: Stage Strike Block for Extra
# address 8053E57C: Stage Strike Block for Extra2 (Unused)
HOOK @ $806B586C
{
 	lwz r12, -0x43C0(r13)
  	lwz r12, 0x284(r12);  	cmpwi r12, 1;  bne- skipStageStrike	# Skip if SSS is not active
	lwz r12, 0x250(r29);	cmpwi r12, 10; ble- clearTable		# Skip if SSS has not been present for more than 10 frames
	mr r4, r12
	stwu r1, -0x50(r1)
  	stmw r18, 0x18(r1)
	lis r12, 0x8049
	lwz r12, 0x6000(r12)
	stw r12, 0x8(r1)
  	lis r26, 0x9017;  ori r26, r26, 0xBE70		# Pointer to Stage Switch table.
												# 9017BE70 = 00 07 FF 00 if Custom Stages and Melee Stages are all enabled
												# 9017BE70 = 00 03 FF 00 if Melee Stages are all enabled
												# 9017BE74 = 7F FF FF FF if Brawl stages are all enabled	
	lis r25, 0x8053; ori r25, r25, 0xE570		# 10-byte block used for stage strikes, now.
	mr r28, r3
	lwz r3, 0xC(r25)
	cmpwi r3, 0;	beq+ noSecondBell
	cmpw  r4, r3;	blt- noSecondBell
	li r5, 0				# \ Only play once.
	stw r5, 0xC(r25)		# /
	lis r3, 0x805A			# \
	li r4, 0x1EEC				# | Play SFX 1EEC (Menu 44)
	lis r12, 0x806A			# |
	ori r12, r12, 0x83F4	# |
	mtctr r12				# |
	bctrl					# /	

	
noSecondBell:
	mr r3, r28
	lbz r4, -0x1(r25) 		# previously processed page 
	lis r5, 0x8049 			# current viewing page on the sss
	ori r5, r5, 0x6000
	lbz r5, 0x0(r5)
	cmpw r4, r5;	beq dontRefresh

	stb r5, -0x1(r25)
	li r24, 0x2				# Set that we are striking all stages not on this page or 
	lbz r23, 0x230(r29)
	b clearLoopStart		# Go up to deal with the BG and cursor	
dontRefresh:
	cmpwi r5, 4;	beq noStageStrike	# Custom stage page?
  	rlwinm. r0, r3, 0, 13, 13;  bne- noStageStrike				# 0x00400000	# Classic Controller B?		(0040)
  	rlwinm. r0, r3, 0, 20, 20;  bne- StrikeAllOffInStageSwitch	# 0x00000800	# \ GameCube Controller Y	(0800)
  	rlwinm. r0, r3, 0, 14, 14;  bne- StrikeAllOffInStageSwitch	# 0x00020000	# / Classic Controller Y	(0020)
  	rlwinm. r0, r3, 0, 21, 21;  bne- PrepareToStrikeStage		# 0x00000400	# \ GameCube Controller X	(0400)
  	rlwinm. r0, r3, 0, 12, 12;  bne- PrepareToStrikeStage		# 0x00080000	# / Classic Controller X	(0008)
  	rlwinm. r0, r3, 0, 27, 27;  bne- clearAllStrikes			# 0x00000010	# \ GameCube Controller Z	(0010)
  	rlwinm. r0, r3, 0, 10, 10;  bne- clearAllStrikes			# 0x00200000	# / Classic Controller ZL/ZR
	li r23, 1				# \ Passive mode
	li r24, 0x3				# /
	lwz r28, 0x248(r29)		# Current selection on the stage selection screen
	cmpwi r28, -1
	beq- noStageStrike
	b setLoopStart
# This part of the code is how it will now strike stages.
# r23 modes: 	0 = Clearing
# 			 	1 = Striking One Stage
#				2 = Striking All Stages
#				3 = Passive
PrepareToStrikeStage:	

	lwz r28, 0x248(r29)		# Current selection on the stage selection screen
	cmpwi r28, -1			# \ But if we already disabled it . . . . . no point in doing so again
	beq- dontRestrike		# /
	lis r3, 0x805A			# \
	li r4, 0x24 			# | Play SFX 24 (Menu 15)
	lis r12, 0x806A			# |
	ori r12, r12, 0x83F4	# |
	mtctr r12				# |
	bctrl					# /
	li r23, 1				# We are only striking one stage!
	li r24, 0x1				# Set that we are striking
	b setLoopStart
StrikeAllOffInStageSwitch:	
	li r8, 0
	lwz r4, 0x0(r26)		# \ Copy Melee stage switch settings
	lwz r5, 0x0(r25)		# |
	mr r7, r5 				# | 
	li r6, -1				# | \ But invert them!
	xor r4, r4, r6			# | /
	or r4, r4, r5			# |
	oris r4, r4, 4			# | but always set custom stages to be struck
	stw r4, 0x0(r25)		# / 
	oris r7, r7, 4 			# \if bans changed, remember it
	cmpw r4, r7 			# |
	beq 0x8 				# |
	li r8, 1				# /

	lwz r4, 0x4(r26)		# \ Copy Brawl stage switch settings
	lwz r5, 0x4(r25)		# |
	mr r7, r5 				# |
	xor r4, r4, r6			# |
	or r4, r4, r5 			# |
	stw r4, 0x4(r25)		# /
	cmpw r4,r7 				# \if bans changed, remember it 
	beq 0x8  				# |
	li r8, 1 				# /

	lhz r5, 0xA(r25) 		# \if bans changed, remember it 
	lis r6, 0				# |
	ori r6, r6, 0xFFFF 		# |
	cmpw r5, r6				# |
	beq 0x8  				# |
	li r8, 1 				# /

	li r4, -1
	stw r4, 0x8(r25)		# Just strike all custom stage slots since they aren't accessible from the Stage Switch

	cmpwi r8, 1				# \if no bans changed, skip sfx 
	bne 0x1C 				# / 
	lis r3, 0x805A			# \
	li r4, 0x1EEC			# | Play SFX 1EEC (Menu 44)
	lis r12, 0x806A			# |
	ori r12, r12, 0x83F4	# |
	mtctr r12				# |
	bctrl					# /	
	
	li r24, 0x2				# Set that we are striking all stages not on this page or 
	lbz r23, 0x230(r29)
	b clearLoopStart		# Go up to deal with the BG and cursor	
	
clearAllStrikes:
	lwz r24, 0x0(r25);	cmpwi r24, 0;	bne+ needToClear	# \
	lwz r24, 0x4(r25);	cmpwi r24, 0;	bne+ needToClear 	# | Don't do this if there is nothing to clear!
	lwz r24, 0x8(r25);	cmpwi r24, 0;	beq- noStageStrike	# /
needToClear:
	lis r3, 0x805A			# \
	li r4, 0x1EEA			# | Play SFX 1EEA (Menu 42)
	lis r12, 0x806A			# |
	ori r12, r12, 0x83F4	# |
	mtctr r12				# |
	bctrl					# /		
	lbz r23, 0x230(r29)		# Stage count on page.	
	li r24, 0				# Set that we are clearing
	stw r24, 0x0(r25)		# \
	stw r24, 0x4(r25)		# | Clear all stage strikes from the table
	stw r24, 0x8(r25)		# |
	stw r24, 0xC(r25)		# |
	stb r24, -0x1(r25)		# /
	
###
clearLoopStart:
	li r28, 0
setLoopStart:
	stw r28, 0x10(r1)
	stw r23, 0x0C(r1)
clearLoop:
	mr r4, r28				#
# prerequisite: r3 = page as observed by Brawl, r4 = stage on page (i.e. the 21st is 0x14. The first is 0x00)
	mulli r12, r28, 4		# \
	addi r12, r12, 0x8C		# | Access pointer to stage icons. To get the frame, pull 0x98 from r31.
	lwzx r31, r29, r12		# /
	stw r31, 0x14(r1)
	cmpwi r24, 3
	bne notIdle
	lwz r12, 0x14(r31)		# \
	lwz r12, 0x10(r12)		# | Get the current frame.
	lwz r12, 0x18(r12)		# /
	lis r0, 0x43C8
	cmpw r12, r0
	bge dontRestrike
	b noStageStrike
notIdle:
	lis r12, 0x806B			# \
	ori r12, r12, 0x8F50	# | Obtain the stage slot in this location
	mtctr r12				# |
	bctrl					# /
	cmpwi r24, 0			# \ The table was already cleared if this is 0, so don't strike it, then!
	beq notStrikingSlot		# /
	lis r4, 0x8000				# Bit to set
	li r5, 0
	addi r12, r25, 4
	addi r6, r26, 4
	mr r30, r3	
	cmpwi r3, 31;	blt+ BrawlSlot
	cmpwi r3, 43;	bge- CustomSlot	
MeleeSlot:
	subi r12, r25, 1		# Move to Melee's slots
	subi r6, r26, 1
	subi r30, r3, 31		# Melee table
	b BrawlSlot
CustomSlot:	
	addi r6, r26, 8
	addi r12, r25, 8
	subi r30, r3, 43
BrawlSlot:
	addi r30, r30, 1
	mtctr r30
StrikeCheckLoop:
	rlwinm r4, r4, 1, 0, 31	# Rotate bit left
	bdnz+ StrikeCheckLoop
	lwz r5, 0x0(r12)	
	lwz r6, 0x0(r6)
	cmpwi r24, 2;	beq- blanketStrikeCheck
	cmpwi r24, 3;	beq+ dontRestrike
	b setStrikeStatus
blanketStrikeCheck:
	and. r0, r4, r5			# \ Don't mess with this slot if it is set to appear in random!
	beq+ skipSet			# /
	b doneStrikingSlot
setStrikeStatus:
	or r4, r4, r5			# Make sure to include bits set, before!
strikeBehavior:
	stw r4, 0(r12)			#
copyStrikes:	
doneStrikingSlot:
notStrikingSlot:
	
	
	lis r12, 0x800A			# \
	ori r12, r12, 0xF6A0	# | Access the float for this stage number's icon
	mtctr r12				# |
	bctrl					# /
	cmpwi r24, 0			# \ Only apply the strike mark if it is requested
	beq clearing			# /
	stwu r1, -0x10(r1)		# \
	lis r0, 0x43C8			# | 400.0
	stw r0, 0x8(r1)			# |
	lfs f0, 0x8(r1)			# | Add 400.0 to the stage texture that is being increased so it goes to the set with strike imagery
	fadds f1, f0, f1		# |
	addi r1, r1, 0x10		# /
clearing:
	lwz r3, 0x14(r1)		# \
	lis r12, 0x800B			# |
	ori r12, r12, 0x7900	# | Set the frame
	mtctr r12				# |
	bctrl					# /
skipSet:	
	lwz r28, 0x10(r1)
	lwz r23, 0x0C(r1)
	addi r28, r28, 1
	stw r28, 0x10(r1)
	cmpw r28, r23
	blt+ clearLoop
	

	
dontRestrike:
clearSplash:
	li r0, -1				# \ Invalidate current stage selection
	stw r0, 0x248(r29)		# /
	stwu r1, -0x10(r1)		# \
	lis r0, 0x42A0			# |
	stw r0, 0x8(r1)			# | Set the background image to 80.0 (blank)
	lfs f1, 0x8(r1)			# |
	addi r1, r1, 0x10		# /
	lwz r3, 0x80(r29)		# Pointer to background image
	lis r12, 0x800B			# \
	ori r12, r12, 0x7900	# | Set the frame
	mtctr r12				# |
	bctrl					# /	
	lwz r3, 0x214(r29)		# \
	lwz r4, 0x204(r29)		# | Make the highlight cursor disappear
	lwz r12, 0(r3)			# |
	lwz r4, 0x10(r4)		# |
	lwz r12, 0x3C(r12)		# |
	mtctr r12				# |
	bctrl					# /
	
noStageStrike:	
finishStageStrike:	
	lmw r18, 0x18(r1)
	lwz r3, 0x8(r1)
	lis r12, 0x8049
	stw r3, 0x6000(r12)	
  	addi r1, r1, 0x50
	b doneStageStrike
clearTable:
	li r0, 0				# \
	lis r12, 0x8053			# |
	ori r12, r12, 0xE570	# | If the SSS is booting up, clear the stage strike table.
	stw r0, 0x0(r12)		# |
	stw r0, 0x4(r12)		# |
	stw r0, 0x8(r12)		# |
	stw r0, 0xC(r12)		# |
	stb r0, -0x1(r12)		# /
doneStageStrike:
	lwz r3, 0x13C(r1)				# Retrieve input and floats, again
skipStageStrike:
  	rlwinm. r0, r3, 0, 19, 19		# Start button check
}
HOOK @ $806B7A5C
{
	lis r11, 0x8053;  ori r11, r11, 0xE570	# \
	li r6, -1								# |	Prepare the table of strikable stages
	lwz r12, 0(r11);  xor r12, r12, r6		# /
	and r5, r5, r12							# Filter them out from the accessible stages
	lwz r12, 4(r11);  xor r12, r12, r6		# Omit the stages already eliminated
	lwz r6, 0x24(r21);  and r6, r6, r12
	cmpwi r5, 0x0;  bne+ %END%				# Skip if no stages removed????
	cmpwi r6, 0x0;  bne+ %END%				# Skip if no strikes?
	lwz r5, 0x20(r21);  lwz r6, 0x24(r21)
}

################################################################
L+R+A during Stage Select goes to CSS V2 (GC & CC) [ds22, Magus]
################################################################
HOOK @ $806DCC9C
{
 	cmpwi r0, 0x1
  	bne- %END%		//skip if not on SSS
  	li r0, 0x0
  	li r11, 0x0		//used to track loop count
  	lis r12, 0x805C
  	subi r12, r12, 0x5340
controllerLoop:
  	lwzu r3, 0x40(r12)	//checking button presses, assumes GC hex format
  	rlwinm. r0, r3, 0, 23, 23	//0x100 (A)
  	beq- checkCtrlrTally
  	rlwinm. r0, r3, 0, 25, 25	//0x40 (L)
  	beq- checkCtrlrTally
  	rlwinm. r0, r3, 0, 26, 26	//0x20 (R)
  	bne- LRApressed
checkCtrlrTally:
  	addi r11, r11, 0x1	//increment once per loop
  	cmpwi r11, 0x8		//
  	bne- controllerLoop	//checks all 8 controller ports
 	li r0, 0x1		// 1 if L+R+A not pressed
  	b done
LRApressed:
  	li r0, 0x0		//clear r0 if the combination is pressed!
done:
  	cmpwi r0, 0x2		
}