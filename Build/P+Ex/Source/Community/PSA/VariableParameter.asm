#######################################################################
Variable 10xxxx range gets and sets projectile creator data [DukeItOut]
#######################################################################
# Allows objects created by fighters to access the fighter's
# variables without the fighter needing to copy into arbitrary
# offsets to achieve this.
#
# Example:
#
# LA-Basic 100054 gets LA-Basic 54 (costume ID) from a fighter if
# 	the item or projectile was created by them!
#
# Works with if statements, setting and getting variables.
# Does not work for indicating a sum, difference, product or quotient.
#
# Dependent on Heritage.asm!
# 80003FF0 is a custom function for getting the fighter!
#######################################################################
.macro GetCreatorLogic()
{
	lwz r3, 0x8(r3)
	lwz r12 0x90(r3)
	lwz r12, 0xC4(r12)
	mtctr r12
	bctrl
	mr r4, r3				#
	li r5, 0				# r5 will be a pointer to write to if non-zero!
	lis r6, 0x80B8			# \ Fighter Manager
	lwz r3, 0x7C28(r6) 		# /
	bla 0x815CB0			# Get the fighter entry	
	mr r4, r3				# /
	lwz r3, 0x7C28(r6) 		# Fighter Manager
	li r5, -1				# \
	bla 0x814F20			# / Get the fighter pointer	
	lwz r3, 0x60(r3) 		# Get the module accessor!
}
.macro GetCreatorVar()
{
	mr r29, r3 			# Original operation
	andis. r6, r4, 0x0F # we want the second byte to control this (0x80 here is used for negative)
	beq+ normal			# if zero, it's normal!
	lis r6, 0x1			# \ 100,000
	ori r6, r6, 0x86A0	# /
	sub r4, r4, r6		# remove 100,000 so that the game can get the right one!
	mr r30, r4			# modify to be something more easily understood!
	bla 0x3FF0			# Get fighter of origin!
	mr r4, r30  # Restore
	mr r5, r31	# Restore
normal:
	rlwinm. r6, r4, 4, 28, 31	# condition that was overwritten by above code
}
.macro GetCreatorSetVar()
{
	lwz r30, 4(r3)	# Get LA/RA/IC variable. Original operation
	andis. r5, r30, 0x0F # we want the second byte to control this (0x80 here is used for negative)
	beq+ %END%
	lwz r3, 0x30(r29)	
	bla 0x3FF0			# Get fighter of origin!
	lwz r28, 0x70(r3)	# work variable manager
	lis r6, 0x1			# \ 100,000
	ori r6, r6, 0x86A0	# /
	sub r30, r30, r6	# - 100,000
}
HOOK @ $80796F3C # Get Float
{
	%GetCreatorVar()
}
HOOK @ $8079712C # Get Int
{
	%GetCreatorVar()
}
HOOK @ $807AD01C # Commands (to allow setting ints from PSA)
{ 
	%GetCreatorSetVar()
}
HOOK @ $807AD42C # Commands (to allow setting floats from PSA)
{
	%GetCreatorSetVar()
}