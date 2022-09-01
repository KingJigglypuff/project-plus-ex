###############################
New SSS Random Code [DukeItOut]
###############################
HOOK @ $806B4B30
{
	stwu r1, -0x120(r1)		# We'll just make a table of all of the stage IDs in byte format because the code will be shorter and more effective, though
							# will use more stack
	stw r5, 0x8(r1)
	stw r6, 0xC(r1)
	stw r28, 0x10(r1)
	stw r29, 0x14(r1)
	stw r30, 0x18(r1)
	lis r28, 0x8053; ori r28, r28, 0xE570	# Pointer to stage strike table
	lis r29, 0x9017; ori r29, r29, 0xBE70	# Pointer to random stage switch table
	lis r30, 0x8049; lwz r30, 0x5D00(r30)	# Pointer to stage ID table
	addi r12, r1, 0x1F		# Where to write the table into the stack, minus 1
	li r7, 0		# Amount of active slots
	
	li r3, 10		# \
	mtctr r3		# / amount of Melee stages
	lhz r5, 1(r28)
	lhz r6, 1(r29)
	li r3, -1
	xor r5, r5, r3	# Invert the strike table
	li r3, 1
	li r8, 31		# Offset to Melee stage slots
meleeLoop:	
	and  r4, r3, r5
	and. r4, r4, r6
	beq notSet_m
	addi r7, r7, 1
	stbu r8, 0x1(r12)	# Add to the table
notSet_m:
	mulli r3, r3, 2
	addi r8, r8, 1
	bdnz+ meleeLoop
	
customCheck:
	and.  r4, r3, r6; 	beq noCustom		# \ Check if custom stages are enabled
	
	lis r3, 0x8049			# \ We're only checking page 3. Page 4 and 5 would theoretically need additional checks.
	lbz r3, 0x6002(r3)		# /
	cmpwi r3, 0;		beq noCustom
	mtctr r3			# Amount of custom stage slots (max of 32 (including OTR) in this check possible, code alterations needed, otherwise)
	li r8, 44			# Offset to custom stage slots
	lwz r5, 8(r28)
	li r3, -1
	xor r5, r5, r3	# Invert the strike table
	li r3, 2		# We're leaving Training Room out of the random selection on purpose because it's too unorthodox for casual gameplay purposes
customLoop:	
	and. r4, r3, r5
	beq notSet_c
	addi r7, r7, 1
	stbu r8, 0x1(r12)
notSet_c:
	mulli r3, r3, 2
	addi r8, r8, 1
	bdnz+ customLoop
noCustom:	

	li r3, 31	# 31 Brawl slots 
	mtctr r3
	li r8, 0
	lwz r5, 4(r28)
	lwz r6, 4(r29)
	li r3, -1
	xor r5, r5, r3
	li r3, 1
brawlLoop:	
	and  r4, r3, r5
	and. r4, r4, r6
	beq notSet_b
	addi r7, r7, 1
	stbu r8, 0x1(r12)
notSet_b:
	mulli r3, r3, 2
	addi r8, r8, 1
	bdnz+ brawlLoop	
	cmpwi r7, 0
	bne valid
trainingDefault:
	li r3, 43					# Default to training room as a failsafe, also makes it clear that something went wrongly with the striking/stage list
	b prepareStageSlot
valid:
	mr r8, r7
randStage:
	mr r3, r8					# The range to randomize with. (0-to-[val-1])
	lis r12, 0x8003				# |
	ori r12, r12, 0xFC7C		# | Randi seeding to get a substage value
	mtctr r12					# |
	bctrl						# /
	mflr r5 					# gets address of this command into r5
	b checkStage
prevStage:
word 0xFF 						# assigned memory for previous random stage chosen.
checkStage:
	addi r12, r1, 0x20			# Go back to compiled slot table	
	lbzx r3, r12, r3			# Get the stage slot!
	lwz r4, 0x8(r5) 			# Loads Prev random stage
	stw r3, 0x8(r5)  			# Saves Current random stage as previous
	cmpwi r8, 1					# if only one available choice, always use it
	beq prepareStageSlot
	cmpw r3, r4 				# if choice was same as previous random stage, try again.
	beq randStage
prepareStageSlot:
	li r7, 0					# Page counter	
	lis r12, 0x8049
	ori r12, r12, 0x5D00
pageChecks:
	li r5, 0
	cmpwi r7, 0;	beq page1
	cmpwi r7, 1; 	beq page2
	lis r4, 0x8049				# \
	ori r4, r4, 0x6000			# | Convenient way to get page 3-5
	lbzx r4, r4, r7				# /
	cmpwi r4, 0; beq checkNext	# skip if empty
	b setPageAmount
page1:
	lis r4, 0x806C				# \ Get page 1's table size
	lbz r4, -0x6D64(r4)			# /
	b setPageAmount
page2:
	lis r4, 0x806C				# \ Get page 2's table size
	lbz r4, -0x6D5C(r4)			# /
setPageAmount:
	lis r6, 0x8049		# \ Set page
	stb r7, 0x6000(r6)	# /	
	stb r4, 0x230(r27)	# Stage count
	mtctr r4
	lwzu r6, 4(r12)
stageTableLoop:
	lbzx r0, r6, r5
	cmpw r3, r0;	beq foundStage
	addi r5, r5, 1
	bdnz stageTableLoop
checkNext:
	addi r7, r7, 1
	cmpwi r7, 3; bgt trainingDefault
	b pageChecks
foundStage:
	mr r4, r5
	mr r0, r7
	lwz r5, 0x8(r1)
	lwz r6, 0xC(r1)
	lwz r28, 0x10(r1)
	lwz r29, 0x14(r1)
	lwz r30, 0x18(r1)
	addi r1, r1, 0x120	
}
CODE @ $806B4B34
{
	cmpwi r0, 2
	blt normal
	li r0, 0			# Extra pages are clones of page 1!
normal:
	stw r0, 0x20(r1)	#\  <- page
	stw r0, 0x2C(r1) 	#/
    stw r3, 0x28(r1)	#\ <- offset for stage location
	stw r3, 0x34(r1)	#/
	stw r4, 0x24(r1)	#\ <- offset as seen on stage page
	stw r4, 0x30(r1)	#/
	mulli r3, r3, 2		# Offset in stage table
	lis r12, 0x8049		# Get stage table
	lwz r12, 0x5D00(r12)#
	lbzx r3, r3, r12    # Get the stage ID
	li r0, 1			# This code is exactly the size it needs to be. Increasing this code's size will overwrite things, BADLY!
	stw r3, 0x258(r27)	#
}