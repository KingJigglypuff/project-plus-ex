##############################################
2P Co-Op Defaults to First Costume [DukeItOut]
##############################################
# If a costume index wasn't present for a
# character or their shared equivalent and
# it saved, you could be locked out of that
# menu.
#
# This negates that by making it only show
# the first costume used in that mode.
#
# This was one of the few areas that PM could
# mess up a Brawl save file so is necessary
# even though the issue was reversible.
#
# If PM is given its own save file one day, 
# this entire text should be possible 
# to remove.
##############################################
# Related to reading.
op mr r5, r0 @ $80692DE0	# normally adds r0 (char slot * 50) and r25 (costume index). Which to display on the CSS.
# Related to writing..... a lot of it.
op li r0, 0 @ $8095973C		# Co-Op P1 costume index in Home Run Contest
op li r0, 0 @ $8095974C		# Co-Op P2 costume index in Home Run Contest
op li r0, 0 @ $8095D900		# Co-Op P1 costume index in Break the Targets
op li r0, 0 @ $8095D934		# Co-Op P2 costume index in Break the Targets
op li r0, 0 @ $806E43CC		# Co-Op P1 costume index in All-Star
op li r0, 0 @ $806E43D8		# Co-Op P2 costume index in All-Star

HOOK @ $806E53DC			# Co-Op Boss Battle Save
{
	li r30, 0				# r27 = P1 character, r30 = P1 costume index
	li r31, 0				# r26 = P2 character, r31 = P2 costume index
	stb r30, 0x3529(r28)	# Original operation. Save to Co-Op P1 costume index
}
op li r0, 0 @ $8095E66C		# Co-Op P1 costume index in 10-Man Brawl
op li r0, 0 @ $8095E688		# Co-Op P2 costume index in 10-Man Brawl
op li r0, 0 @ $8095E74C		# Co-Op P1 costume index in 100-Man Brawl
op li r0, 0 @ $8095E768		# Co-Op P2 costume index in 100-Man Brawl
op li r0, 0 @ $8095E7D4		# Co-Op P1 costume index in 3-Minute Brawl
op li r0, 0 @ $8095E7F0		# Co-Op P2 costume index in 3-Minute Brawl
op li r0, 0 @ $8095E85C		# Co-Op P1 costume index in 15-Minute Brawl
op li r0, 0 @ $8095E878		# Co-Op P2 costume index in 15-Minute Brawl
op li r0, 0 @ $8095E8C4		# Co-Op P1 costume index in Endless Brawl
op li r0, 0 @ $8095E8E0		# Co-Op P2 costume index in Endless Brawl
op li r0, 0 @ $8095E92C		# Co-Op P1 costume index in Cruel Brawl
op li r0, 0 @ $8095E948		# Co-Op P2 costume index in Cruel Brawl

/*
# The following are the WiFi equivalents of the above.
# Since WiFi is not functional with P+. This is commented out but present for if it somehow
# is made functional so people don't have to look for the code locations.

# Discovered by following the pattern seen elsewhere:
# "lbz r0, 0x9E(r3)" P1 
# "lbz r0, 0xFA(r3)" P2

op li r0, 0 @ $809597AC		# Co-Op P1 costume index in WiFi Home Run Contest
op li r0, 0 @ $809597BC		# Co-Op P2 costume index in WiFi Home Run Contest

op li r0, 0 @ $8095EA64		# Co-Op P1 costume index in WiFi 10-Man Brawl
op li r0, 0 @ $8095EA80		# Co-Op P2 costume index in WiFi 10-Man Brawl
op li r0, 0 @ $8095EB1C		# Co-Op P1 costume index in WiFi 100-Man Brawl
op li r0, 0 @ $8095EB38		# Co-Op P2 costume index in WiFi 100-Man Brawl
op li r0, 0 @ $8095EBA4		# Co-Op P1 costume index in WiFi 3-Minute Brawl
op li r0, 0 @ $8095EBC0		# Co-Op P2 costume index in WiFi 3-Minute Brawl
op li r0, 0 @ $8095EC2C		# Co-Op P1 costume index in WiFi 15-Minute Brawl
op li r0, 0 @ $8095EC48		# Co-Op P2 costume index in WiFi 15-Minute Brawl
op li r0, 0 @ $8095EC94		# Co-Op P1 costume index in WiFi Endless Brawl
op li r0, 0 @ $8095ECB0		# Co-Op P2 costume index in WiFi Endless Brawl
op li r0, 0 @ $8095ECFC		# Co-Op P1 costume index in WiFi Cruel Brawl
op li r0, 0 @ $8095ED18		# Co-Op P2 costume index in WiFi Cruel Brawl

*/