#######################################################################
Force "PassiveAnim" Texture Animations To Play Indefinitely [DukeItOut]
#######################################################################
#
# If the SRT animation named "PassiveAnim" exists 
# and was the last animation played, it will continue playing
# and will refuse to update when the CHR animation changes
#
# You can use this to make looping aesthetic animations! This is 
# incompatible with models with texture movement on eyes, however.
# You have to choose between eye movement and this as they both
# involve texture animation.
#
# To make them exclusive to a particular costume for a character,
# make only the desired costume ID range for that character
# play "PassiveAnim" upon loading into the game within a modified
# module. 
#
# In modded modules, this is often set using subaction 3 within 
# the PSA, which is where it will be getting the animation 
# name from normally.
#
# Please, only exploit this code with characters!
############################################################
	.BA<-AnimationName
	.BA->$80723E4C
	.GOTO->AnimationCheck
AnimationName:
	string "PassiveAnim"
AnimationCheck:	
	.RESET
op b 0x16C @ $80723E48			# Makes room for above string pointer
HOOK @ $8072A6FC
{
	mr r3, r28			# Motion animation brres
	lis r4, 0x8072		# \ "PassiveAnim"
	lwz r4, 0x3E4C(r4)	# / 
	
	lis r12, 0x8018			# \
	ori r12, r12, 0xDDF4	# |
	mtctr r12				# | Get pointer to animation "PassiveAnim" if present
	bctrl					# /
	cmpwi r3, 0				# \ Give up if it doesn't exist.
	beq- ActNormal			# /
	
	lwz r12, 0x90(r21)		# \
	lwz r12, 0x18(r12)		# / Get initialized SRT0 animation	(0x10 for CLR0 if you want to lock that too elsewhere) 
	cmpwi r12, 0			# \ Check if it exists!
	beq ActNormal			# /
	lwz r4, 0x2C(r12)		# Get pointer to SRT0 data for looping aesthetic animation
	cmpw r3, r4				# \ if the two addresses don't match in location, it isn't ColorAnim
	bne+ ActNormal			# /	
			
	lis r12, 0x8072			# \
	ori r12, r12, 0xA770	# |
	mtctr r12				# | skip setting up an SRT0 animation if PassiveAnim is playing!
	bctr					# /
	
ActNormal:
	mr r3, r28		# Original operation, gets animation name from r30
}
