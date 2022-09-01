#####################################################################
Victory Camera Modifier Engine [DukeItOut]
#
# Allows custom victory cameras on a per-character, per-victory basis
#
# Place custom victory animations in the matching Scene Data ID within STGRESULT.PAC!!!
#######################################################################################
	.BA<-VICTORYTABLE
	.BA->$80936890			# Making the code block this is at get ignored, so it is safe to write pointers to
	.GOTO->VICTORYTABLE_SKIP	
VICTORYTABLE:					# Character Slot, Win ID, Scene ID 1, Scene ID 2
# Size of below table in 4-byte blocks (i.e. 16 bytes = 4)
	int 5						# Make sure to update this when adding entries!
#################################
								# Win1/Up = 0, Win2/Left = 1, Win3/Right = 2	
	byte[4] 0x15, 1, 13, 14		# Falco, 	Win2, 	[13] StgResult_A_falco2, 		[14] StgResult_B_falco2
	byte[4] 0x04, 1, 15, 16		# ZSS, 		Win2, 	[15] StgResult_A_SZerosuit2, 	[16] StgResult_B_SZerosuit2
	byte[4] 0x25, 2, 17, 18		# Ike, 		Win3, 	[17] StgResult_A_Ike3, 			[18] StgResult_B_Ike3
	byte[4] 0x2A, 2, 19, 20		# Snake, 	Win3, 	[19] StgResult_A_Snake3,		[20] StgResult_B_Snake3
	byte[4] 0x22, 2,  4, 10		# Ivysaur, 	Win3		# Forces it to use only one of the 6 pairs available to most victories.
#################################	
# Default cameras: Characters normally choose randomly from 5 different pairs, and then choose one from the pair.
# 1/7  - Zooms out slowly
# 2/8  - Sweeps to the right
# 3/9  - Multiple different shots
# 4/10 - Zooms in slowly
# 5/11 - Pans to the left and out
# 6/12 - Zooms in quickly from a long distance away
#
# If adding cameras, use IDs 25 or higher because they are not used!
###################################################

VICTORYTABLE_SKIP:
	.RESET

HOOK @ $80936888
{
	lis r12, 0x8093					# \
	lwz r12, 0x6890(r12)			# /
	lwz r4, 0(r12)					# \ Get amount of table entries
	mtctr r4						# /
victoryLoop:
	lwz  r0, 0x268(r29)				# Obtain character slot ID
	lbzu r4, 4(r12)					# Check with the current slot ID of the table entry
	cmpw r0, r4;	bne+ notSame

	lwz  r0, 0x26C(r29)				# Obtain the win ID
	lbz r4, 1(r12)					# Check the victory ID of the table entry
	cmpw r0, r4;	bne+ notSame

aMatch:
	addi r12, r12, 2
	lbzx r5, r12, r30				# Get the camera scene ID, replace the randomly generated one.
	b finished
notSame:
	bdnz+ victoryLoop				
finished:
}
op b 0xB4 @ $8093688C				# Skip block below this address because the engine covers those cases.