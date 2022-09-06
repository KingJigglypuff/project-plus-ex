##################################################
Costume PAC files can be compressed V2 [DukeItOut]
##################################################
HOOK @ $8084CB10
{
	li r26, 1			# Force it to think there is compression
	li r15, -0xC0DE 	# Act as an identifier
}
HOOK @ $800453F0
{
	mr r5, r22			# Original operation
	cmpwi r15, -0xC0DE 	# Identifier check for costumes
	bne+ %END%
	li r15, -1
	lis r3, 0x8004		# \
	ori r3, r3, 0x5448	# | Force costume file to not clone.
	mtctr r3			# | This avoids a bug where uncompressed costumes can freeze when cloning. 
	bctr				# / 
}
op b 0x20 	@ $8084D068
half 0x6163	@ $80B0A652
HOOK @ $80015CAC
{
  mr r22, r3
  cmplwi r22, 0x4352
  bne+ %END%
Decompress:
  lis r12, 0x8001
  ori r12, r12, 0x5D0C
  mtctr r12
  bctr 
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
#word 0 @ $80AD8028 #Commented out, as P+Ex uses FighterConfig files to determine if Kirby Hat files are loaded.

###############################################################
Only New Characters Need a Spy Costume Added [DukeItOut]
#
# Disables alt Clear Brawl skins for Pika, Jigglypuff and Sonic
###############################################################
op li r5, 0 @ $8084CB6C