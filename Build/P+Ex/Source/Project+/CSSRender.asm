###################################################################
CSS Has Extensively Enlarged Slots Engine [DukeItOut]
###################################################################
# This makes it so that the CSS render
# requirements are as follows:
#
# -The fighter costume file ID is used instead of an offset
# -Each set of 10 costumes gets its own group ID number
#
# This combination of properties lets you fit more on the CSS!
# The bottleneck is related to having too many in a single bres 
# archive. This gets around that by making characters use multiple.
###################################################################
HOOK @ $80697560
{
	mr r3, r31				# character instance ID
	mr r4, r24				# costume offset
	bla 0x0AF93C			# get the fighter color number as understood by the file load code
	mr r24, r3				# what we will use as a number index now
	mr r3, r31				# character instance ID (original operation)
}
op li r25, 0 @ $806975A0	# normally loads character cosmetic slot ID * 10 + 1
HOOK @ $80693960
{
	mr r5, r24				# costume ID based on previous edit
	li r4, 0				# counter used for the bres group ID
hex2decLoop:
	subi r5, r5, 10
	cmpwi r5, 0
	blt gotGroup
	addi r4, r4, 1
	b hex2decLoop
gotGroup:
	lis r5, 1				# using r5 instead of r4
}
CODE @ $80693964
{
	lis r7, 0x806A
	mr r6, r3
	lwz r3, 0x3968(r7)			# where the archive is to use
	subi r0, r5, 2
	li r5, 1					# type 1 (MiscData)
	rlwinm r7, r0, 0, 16, 31	# instead of r6
	bl -0x67DBC8				# use a different getData function
}
string "02d" @ $806A1C18		# reduce to 2 digits from 3