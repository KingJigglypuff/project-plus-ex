###################################################################
New Motion Animation Commands [DukeItOut]
###################################################################
# 041B0000	# Reset animation
#
#	Used to fix a bug with Kirby's eyes.
#	In Brawl, he stops blinking if he obtains a Falco, Snake, 
#		Donkey Kong, Olimar or Jigglypuff copy ability
#
# 041C0000 # Fix Position
#
#	Relates to the positioning in the world.
###################################################################
HOOK @ $80724084
{
	li r3, 0		# Original operation
	# this goes through if higher than 26 (1A) is found, 
	# indicating that the slots above are unused.
	
	cmpwi r0, 28; beq- forceCorrection	# command 28 (1C)	Force collision recalc
	cmpwi r0, 27; bne+ %END%			# command 27 (1B)	reset animations

	############
	# 041B0000 # Reset model and animation connection
	############	
	lwz r31, 0x10(r26)
	lwz r3, 0x28(r31)
	lwz r12, 0(r3)
	li r4, 0 	# Index to motion info (color is in 3)
	lwz r12, 0x10(r12)
	mtctr r12
	bctrl
	lwz r3, 0(r3)
	li r4, 0	# Set to 1 if newly constructed to allocate memory.
	lwz r5, 0xC8(r31)
	lwz r12, 0(r3)
	lwz r12, 0xC(r12)
	mtctr r12
	bctrl	
		
	b finish
	############
	# 041C0000 # Fix position of model relative to the world
	############
resetAnimInfo:
	mr r3, r24			# \
	lwz r12, 0x0(r3)	# | get motion info
	lwz r12, 0x84(r12)	# | position fix function
	mtctr r12			# |
	bctrl				# /

finish:
	li r3, 1		# Set successful
}