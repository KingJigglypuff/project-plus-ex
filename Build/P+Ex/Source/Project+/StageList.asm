############################################################
[Project+] Disable Stage Builder Splash Previews [DukeItOut]
############################################################
op NOP @ $806B6A5C 

#####################################################################################
[Project+] Custom Stage Lists for Each Stage [DukeItOut]
# Disables A on the SSS for selecting a stage. Instead, it loads a list, if available
#####################################################################################
	.BA<-Phrase
	.BA->$8003AF60
	.GOTO->SkipPhrase
	.RESET
Phrase:
string "/pf/stage/custom/st_%02X"
SkipPhrase:
HOOK @ $8003AF54
{
	rlwinm r0, r24, 2, 0, 29	# \
	addi r4, r4, 0x3560			# |
	addi r3, r1, 0x50			# | Original operations
	lwzx r4, r4, r0 			# / places pointer to "/st" in the name to access stage list
	lis r5, 0x8003				# \ 
	ori r5, r5, 0xAF5C			# | Access last selected stage 
	lwz r5, 0x0(r5)				# /
	cmplwi r5, 0x100			# \ If it is -1 or uninitialized, then a stage isn't highlighted, right now
	bge+ %END%					# /

	stwu r1, -0x80(r1)
	stw r3, 0x08(r1)

	addi r3, r1, 0x10
	lis r4, 0x8003		# \
	ori r4, r4, 0xAF60	# | Access pointer to above string
	lwz r4, 0(r4)		# /

	lis r12, 0x803F			# \
	ori r12, r12, 0x89FC	# | Merge strings
	mtctr r12				# |
	bctrl					# /
	
	addi r4, r1, 0x10
	lwz r3, 0x08(r1)
	lwz r1, 0(r1)
}
HOOK @ $8003B980
{
	lwzx r4, r4, r25		# Original operation
    lis r5, 0x8059			# 
	ori r5, r5, 0xC6D0		# See if it wants to load "/st"
	cmpw r4, r5
	bne+ %END%
	lis r6, 0x8003
	ori r6, r6, 0xAF60
	lwz r5, -4(r6)
	cmplwi r5, 0x100
	bge+ %END%
	lwz r4, 0(r6)
	subi r3, r1, 0x78
	
	lis r12, 0x803F			# \
	ori r12, r12, 0x89FC	# | Merge strings
	mtctr r12				# |
	bctrl					# /
	
	subi r4, r1, 0x78		# Address to string
	addi r3, r1, 0x48 		# Original r3 address
}
op b 0xC @ $8003AF58		# Allows to safely write to 8003AF5C and 8003AF60
op NOP @ $806B593C			# Allow stage lists to load, even if the game expects there to be no contents. 
op NOP @ $806B842C			# Forces the game to reload on request
HOOK @ $806B8C0C
{
	li r4, 1				# Original operation
	lwz r6, 0x6060(r24)		# Load the frame timer for the stage
	cmplwi r6, 5			# Give 5 frames of leniency for bootup to behave normally
	ble+ startingSSS		#
	stb r4, 0x398(r27)		# Make it stop after this pass, but only if this isn't the first attempt.
	b %END%
startingSSS:
	lis r6, 0x803F			# \
	ori r6, r6, 0xAF60		# | Make it an impossible value so that it knows to default to the normal custom SSS if you somehow get to it fast enough.
	stw r6, -4(r6)			# /
}
HOOK @ $806B5864			# Facilitates contextual understanding of when to load a stage's custom list
{
	andi. r0, r3, 0x20		# \
	beq+ NormalBehavior		# |
	andi. r0, r3, 0x40		# | Check if L and R are both held (0x60)
	beq+ NormalBehavior		# / Don't bother with any of this if L+R aren't even pressed.
	andi. r0, r3, 0x100		# \ A button has priority (not relevant, currently, since this is not hold-based at the moment)
	bne+ NormalBehavior		# /
	lis r30, 0x805B			# \
	lwz r30, 0x50AC(r30)	# |
	lwz r30, 0x10(r30)		# |
	lwz r30, 0x08(r30)		# | Don't run during My Music! It will crash the game!
	cmpwi r30, 1			# |
	beq- NormalBehavior		# /
	lis r30, 0x8152			# \
	ori r30, r30, 0xC5E0	# |
	lwz r30, 0x10(r30)		# | Load current button ID  float value
	lwz r30, 0x130(r30)		# |
	lfs f1, 0x18(r30)		# /
	fctiwz f1, f1			# \
	stfd f1, -0x8(r1)		# | and convert it to an integer
	lwz r0,  -0x4(r1)		# /
	cmpwi r0,  0;	beq- NormalBehavior		# 00 = Executed, below
	cmpwi r0, 80;   beq- NormalBehavior		# 80 = Random 
	cmpwi r0, 81;	beq- NormalBehavior		# 81 = Back
	cmpwi r0, 84;	beq- NormalBehavior		# 84 = Page 1
	cmpwi r0, 82;	bge- ForceReset			# 82 = Page 2, 83 = Page CUSTOM, expansion stages
	li r0, 0				# \  Reset the custom stage list
	stw r0, 0x18(r30)		# |  and stage splash art (Normally a float, but this is being set to 0, anyway)
	lis r30, 0x815E			# |
	lwz r4, 0x25C8(r30)		# | Load stage SSS page ID selected
	ori r30,  r30, 0x83E0	# | Pointer to custom stage list refresh value
	stw r0, 0(r30)			# /
	lwz r12, 0x08(r29)		# \ Request the list to be refreshed
	stb r0, 0x398(r12)		# /	
	lwz r3, 0x228(r29)		# Get the SSS page ID
	lis r12, 0x806B			# \
	ori r12, r12, 0x8F50	# |
	mtctr r12				# | Convert to stage ID
	bctrl					# |
	lis r12, 0x800A			# |
	ori r12, r12, 0xF614	# |
	mtctr r12				# |
	bctrl					# /
	lis r12, 0x8003			# \ 
	ori r12, r12, 0xAF5C	# | Force it to check for a new list
	stw r3, 0(r12)			# /

	li r4, 2				# \
	stw r4, 0x228(r29)		# / Force it onto the custom stage page
	lis r12, 0x806B			# \
	ori r12, r12, 0x5928	# | Force it to attempt a stage page change
	mtctr r12				# |
	bctr					# /
ForceReset:
	li r0, 0				# \
	lis r30, 0x815E			# |\
	ori r30, r30, 0x83E0	# |/ Pointer to custom stage list refresh value
	stw r0, 0(r30)			# /
	lwz r30, 0x08(r29)		# \ Request the list to be refreshed
	stb r0, 0x398(r30)		# /	
	lis r30, 0x8003			# \ Force to reload default custom stage list.
	ori r30, r30, 0xAF5C	# |
	stw r30, 0(r30)			# /
NormalBehavior:
	rlwinm. r0, r3, 0, 23, 23	# Check A button (0x100), original operation
}