#################################################################################################################################################
Override RWSD WAVE ID via Info Index v1.8.0 [QuickLava]
#################################################################################################################################################                                
# Description:                                                  
#		Makes it possible to directly play WAVE entries by overriding the WAVE ID associated with a given Sound Info Index.
#		Sound Info Index values are essentially treated as follows:
#			A0BBCCCC
#			A: Activator nibble, set this to 0xF to trigger an override.
#			0: Reserved nibble, should be left as 0. 
#			BB: The WAVE ID to use in place of the ID normally associated with the specified Info Index. Supports range from 0-255 (0x00 - 0xFF).
#			CCCC: The Info Index of the sound whose WAVE ID you want to override.
#		For example, attempting to call Sound Info Index 0xF0082002, would override "snd_se_narration_characall_mario"'s
#		usual WAVE ID of 0x00 with 0x08, calling the WAVE entry associated with "snd_se_narration_characall_luigi" instead. 
#
#		Additionally, the code makes use of an internal table to track incoming Override requests. It begins with a header, formatted like so:
#			YYZZ0000
#			YY: Total number of requests currently in table.
#			ZZ: Slot capacity of table. Used as upper bounds.
#			0000: Reserved, left as 0.
#		Following that is an array of requests, formatted identically to the Info Index format outlined above! The number of request slots
#		in the table is defined below, with the ultimate length of the table directly reflecting the request count. Note that, because Gecko
#		codes are aligned to 0x8 byte blocks, having an even number of slots will leave an extra padding word at the table's end; so odd slot
#		counts are slightly more space-optimal.
#################################################################################################################################################

.BA <- RequestTableStart
.GOTO -> RequestTableEnd
RequestTableStart:					# Note: To change the slot count, change both the second byte of the Header AND the Request Slots line!
word 0x00070000						# Header Word
word[7] 0x00, 0x00, 0x00, 0x00, |	# Request Slots
		0x00, 0x00, 0x00
RequestTableEnd:
.PO <- CodeBody1					#
* 54010000 0000000C					# Store Base Address: Val @ $(po + 0x0000000C) = ba (Store table address in reseved word in Code Body 1).
.PO <- CodeBody2					#
* 54010000 0000000C					# Same as above, but for Code Body 2.
* E0000000 80008000					# And finally reset BA and PO.

CodeBody1:
HOOK @ $801cbfc8					# Hooks "detail_StartSound/[nw4r3snd14SoundStartableFPQ34nw4r3]/sn"
{
	bl 0x8								# Leave a space to store the table pointer...
	word 0xFFFFFFFF						# ... and bl past it, storing its location in LR!
	
	nor. r12, r5, r5					# Set r12 to the complement of the info index, so if r5 was 0xFFFFFFFF, r12 is now 0...
	beq+ code1Exit							# ... and IF r12 is now 0, we jump to the exit label!

	rlwinm. r12, r5, 0, 1, 1			# If the second bit of the Info Index (the activator bit) isn't set...
	beq+ code1Exit							# ... we jump to the exit, skipping the code.
										# Note: if we take either of the above branches, r12 is guaranteed to be 0x00000000.
	
										# ---- Request Store Routine! ----
	mflr r11							# Grab the pointer to the Table Pointer from LR...
	lwz r11, 0x00(r11)					# ... and dereference it to get the address of the working area!
	
	lbz r12, 0x00(r11)					# Grab current number of requests from header.
	lbz r31, 0x01(r11)					# Grab capacity of table from header.
	cmplw r12, r31						# Compare the two numbers...
	bge- storeFail						# ... and if there are no remaining slots to store a new override, we skip the store attempt.
	
	addi r12, r12, 0x1					# Otherwise, add 1 to the current request count...
	rlwinm r31, r12, 2, 0, 29			# ... and multiply it by 4, to get our offset to the slot we'll be writing our entry to.
	stwx r5, r11, r31					# Lastly, store our entry in the target slot...
	stb r12, 0x00(r11)					# Finally, store our incremented request count in the header of the table!
	
storeFail:
	andi. r5, r5, 0xFFFF				# And lastly, ensure the top 16 bits of the Info Index are unset.
	
code1Exit:
	mr r31, r4							# Restore Overwritten Instruction
}

CodeBody2:
HOOK @ $801ca67c					# Mode 0xF: WAVE ID Override (Hooks "GetWaveSoundData/[nw4r3snd18SoundArchivePlayer11WsdCallba")
{
	bl 0x8								# Leave a space to store the table pointer...
	word 0xFFFFFFFF						# ... and skip past it, storing its location in LR!
	
	mflr r11							# Grab the pointer to the Table Pointer from LR...
	lwz r11, 0x00(r11)					# ... and dereference it to get the address of the working area!
	
	lbz r12, 0x00(r11)					# Pull the number of stored requests...
	cmplwi r12, 0x00					# ... and if there are none...
	beq+ code2Exit						# ... skip our code!
	
	mtctr r12							# Move the number of requests to the count register, for use in the upcoming loop.
	addi r3, r11, 0x4					# Initialize r3 as our slot iterator, starting just past the header at the first entry. 
	
	lwz r4, 0x3C(r1)					# Pull the old r31 value off the stack...
	lwz r4, 0x04(r4)					# ... and use it to retrieve the sound's Info Index!
	
	li r6, 0x00							# We'll be using r6 as a flag to mark whether we reached and resolved an entry.
	
loopStart:
	cmplwi r6, 0x00						# Check if we've resolved our entry yet...
	bne- requestResolved				# ... and if we have, jump to the relevant block of the loop body.

requestNotResolved:					# If we haven't resolved a request yet, we need to check the current slot for a match.
	lbz r5, 0x00(r3)					# Load the mode byte from the entry in the current slot.
	srawi r5, r5, 4						# Shift the mode byte down by 4 bits, leaving just the proper mode nibble.
	cmplwi r5, 0x0F						# Check if the mode nibble is 0x0F (WAVE ID Override)...
	bne+ continueLoop					# ... and if it isn't, continue the loop.
	
	lhz r5, 0x02(r3)					# Grab the Info Index from the entry in the current slot.
	cmplw r5, r4						# Check if it matches the Info Index currently being evaluated...
	bne- continueLoop					# ... and if it doesn't, continue the loop.
	
	lbz r5, 0x01(r3)					# Otherwise, we've found a matching entry! Pull its replacement WAVE Index...
	stw r5, 0x00(r26)					# ... and store it in the wave data structure, overriding the WAVE index!
	subi r12, r12, 0x1					# Additionally, subtract 1 from our stored request count...
	stb r12, 0x00(r11)					# ... and store it in the table header!
	
	stw r6, 0x00(r3)					# Lastly, zero out the current request, now that it's been resolved...
	li r6, 0x01							# ... set our flag in r6 to mark that we've found a match...
	b continueLoop						# ... and jump to the continue portion of our loop body!

requestResolved:						# If we *have* already resolved a request, we need to shift any following requests backwards.
	lwz r5, 0x00(r3)					# Load the current request word...
	stw r5, -0x04(r3)					# ... and store it in the previous slot!
	li r5, 0x00							# And finally, load zero into r5...
	stw r5, 0x00(r3)					# ... and use it to zero out the current entry!
	
continueLoop:
	addi r3, r3, 0x04					# Increment address to next slot.
	bdnz loopStart						# If we still have slots to check, stay in the loop!
loopEnd: 

code2Exit:
	lwz r4, 0x00(r26)					# Restore Original Instruction
}