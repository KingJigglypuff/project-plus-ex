####################################################
Costume PAC files can be compressed V3.1 [DukeItOut]
####################################################
# V3: Made the check for if an archive is 
# compressed more robust, as it could trigger 
# false negatives before.
#
# (This fixes an issue where active costumes 
# could not clone before in V2 of the code)
#
# V3.1: Added support for Kirby hat costumes.
####################################################
op li r26, 1 @ $8084CB10	# Force it to think there is compression
op li r0, 1  @ $8084DF9C 	# Force it to enable Kirby hat compression
op b 0x20 	@ $8084D068
half 0x6163	@ $80B0A652		# ".pcs" -> ".pac"

HOOK @ $80015CAC
{
  mr r22, r3			# Original operation. SHOULD be the filesize of the decompressed file.
  lis r12, 0x4152		# \ "ARC"
  ori r12, r12, 0x4300	# /
  lwz r3, 0x0(r24)		# Pointer to first four bytes of archive file we're trying to decompress.
  cmplw r3, r12			# Compressed archives don't start instantly with uncompressed file formatting.
  bne+ %END%
Decompress:
  mr r22, r21			# File size (regardless of if compressed or not)		
  lis r12, 0x8001		# 
  ori r12, r12, 0x5D24	# Act like it is uncompressed because it is!
  mtctr r12				#
  bctr 					#
}
###############################################
!Extremely Aggressive Decompression [DukeItOut]
###############################################
#
# Forces it to decompress the pac the moment
# that the file is acquired IF it is a pac
# file anticipated to be used on a fighter.
#
# Might be unstable. Disabled for now.
#
# In theory makes model+texture file splitting
# easier but also, more insanely....
#
# consider decompressing in the heap you
# are trying to utilize Motion and Etc files!
#
###############################################

HOOK @ $8001C100
{
	stw r0, 0xC(r30)	# Original operation. Places address written.
		
	addi r3, r30, 0x24 # filename
	lis r4, 0x80B0	   # \ ".pac"
	ori r4, r4, 0xA648 # /
	bla 0x3fa798	   # strstr
	cmpwi r3, 0			# \
	beq %END%			# / only trying if it has ".pac"!
	
	addi r11, r1, 0x60	# confident this part of the stack is already discarded
	bla 0x3F12FC 		# store r18-r31

	lwz r31, 0x20(r30)
	cmpwi r31, 0
	beq abortArcaneProcess
	lwz r19, 0x08(r31) # same r19 as in normal decompression
	
	lis r12, 0x80B0
	ori r12, r12, 0xA674	
	
	
	addi r3, r30, 0x24  # filename
	mr r4, r12			# "Motion"
	bla 0x3fa798	    # strstr
	cmpwi r3, 0					# \
	bne- confidentlyAFighter	# /
	
	addi r3, r30, 0x24  # filename
	addi r4, r12, 8		# "Etc"
	bla 0x3fa798	   	# strstr
	cmpwi r3, 0					# \
	bne- confidentlyAFighter	# /	
	
	li r3, 6		# Network
	bla 0x0249CC	# get the heap address
	lwz r4, 0x18(r19) # Get heap used for decompression
	cmpw r3, r4		# Only exploit with fighters!
	bne+ abortArcaneProcess # They're set to use the network to decompress!

confidentlyAFighter:	
	lwz r18, 0x14(r19)
	cmpwi r18, 0
	bne- hasPool
	
	addi r3, r19, 0x6C	#
	bla 0x021FA0		# get the pool
	mr r18, r3			#

hasPool:	
	addi r3, r19, 0x6C	#
	bla 0x021F94		# get the buffer
	mr r24, r3			# has the file loaded
	
	addi r3, r19, 0x6C	#
	bla 0x021F88		# get the size
	mr r21, r3			#
	
	mr r3, r24			# using the buffer...
	bla 0x205FD8		# get the uncompressed size
	mr r22, r3			# 
	
  lis r12, 0x4152		# \ "ARC"
  ori r12, r12, 0x4300	# /
  lwz r3, 0x0(r24)		# Pointer to first four bytes of archive file we're trying to decompress.
  cmplw r3, r12			# Compressed archives don't start instantly with uncompressed file formatting.
  beq+ abortArcaneProcess
	stw r22, 0x8(r30)	# Redo the size assumed!
	
	/*
	lwz r3, 0x18(r19)	# Get the [network] heap again
	mr r4, r21
	li r5, 32
	bla 0x025C58	# alloc in the network heap!
	mr r23, r3
	mr r4, r24
	mr r5, r21
	bla 0x004338 # copy the compressed file
	*/
	mr r23, r24 # We're pointing from the compressed file.
	mr r3, r24
	bla 0x024A4C # free the compressed file in the fighter heap
	mr r3, r18
	
	addi r4, r22, 0x20 # Give 0x20 of leeway!
	li r5, 32
	bla 0x025C58 # alloc in the fighter heap!
	mr r24, r3
	mr r3, r23
	mr r4, r24
	bla 0x206018 # Decompress from the network to the fighter!
	mr r3, r24
	mr r4, r22
	bla 0x1D76E8 # Flush
	/*
	mr r3, r23
	bla 0x024A4C # free
	*/
	stw r24, 0x0C(r30) # Redo the address it is assumed to be!
abortArcaneProcess:	
	addi r11, r1, 0x60
	bla 0x3F1348 # restore r14-r31
}

#############################################################################
Character Costumes are decompressed in the Network Heap [Kapedani, DukeItOut]
#
# This avoids a conflict where final smashes and compressed costumes
# attempted to use the same memory allocation, causing crashes.
#############################################################################
op li r9, 6 @ $8084FE2C
# The following gets rid of the pause/endgame buffer
# The game can allocate a new one when it needs to. 
HOOK @ $8084FDB8			
{
	lis r3, 0x805A
	lwz r3, 0x90(r3)
	lis r12, 0x8003			
	ori r12, r12, 0x7BE4
	mtctr r12				
	bctrl					
	mr r3, r26		# Original operation
}

####################################################
Bowser and Giga Bowser Can Be Compressed [DukeItOut]
####################################################
op NOP @ $808275B4
byte 0x4C @ $8081DF63	# Used by Bowser
byte 0x6C @ $8081DF87	# Used by Giga Bowser!
word 0 @ $80AD8028
HOOK @ $80828F08		# Force Bowser and Giga Bowser to load their costume normally.
{
	cmplwi r0, 0x100	# Original operation
	beq- %END%
	lwz r0, 0x8(r22)	# Get character instance ID
	cmpwi r0, 0xB		# \ Check if Bowser
	beq- %END%			# /
	cmpwi r0, 0x30		# \ Check if Giga Bowser
	beq- %END%			# /
}

###############################################################
Only New Characters Need a Spy Costume Added [DukeItOut]
#
# Disables alt Clear Brawl skins for Pika, Jigglypuff and Sonic
###############################################################
op li r5, 0 @ $8084CB6C