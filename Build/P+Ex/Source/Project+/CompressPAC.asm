##################################################
Costume PAC files can be compressed V3 [DukeItOut]
#
# V3: Made the check for if an archive is 
# compressed more robust, as it could trigger 
# false negatives before.
#
# (This fixes an issue where active costumes 
# could not clone before in V2 of the code)
##################################################
op li r26, 1 @ $8084CB10	# Force it to think there is compression
op b 0x20 	@ $8084D068
half 0x6163	@ $80B0A652
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