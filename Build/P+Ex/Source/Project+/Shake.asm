############################################################
[Project+] Disable stun shake in certain actions [DukeItOut]
############################################################
HOOK @ $808386F4
{
	mr r29, r3			# Original operation
	
	lwz r3, 0x60(r3)	# \
	lwz r12, 0x7C(r3)	# | Get action
	lhz r12, 0x3A(r12)	# /

	cmpwi r12, 0x46; blt+ finish		# If action 46-4C (tumble)
	cmpwi r12, 0x4C; ble forceShakeStop	# then cease shaking!

	cmpwi r12, 0x60; blt finish			# If action 60-64 (teching)
	cmpwi r12, 0x64; bgt finish			# then cease shaking!
forceShakeStop:
	li r12, -1			# \ Disable shake
	lwz r3,  0xD8(r3)	# |\ Get shake status location
	lwz r3,  0x4C(r3)	# |/
	stw r12, 0x18(r3)	# /
finish:
}

################################################################
[Project+] Custom Shake Vibration Table [DukeItOut]
#
# Dials back shaking to make the character less hectic in motion
################################################################
float[10] |
 0.0, 0.0,|
-1.2, 0.0,|
-0.5, 0.0,|
 1.2, 0.0,|
 0.5, 0.0,|
@ $80F9FCF0


##########################################################################
[Project+] Screen Shake Type 2 Intensity Multiplier 0.5 -> 0.2 [DukeItOut]
##########################################################################
# This screen shake type is used on Dream Land in PM
#
# It uses the camera animation of Type 3 / Screenshake 0, 
# but with reduced intensity. This does not affect
# character PSAs, which use different shake IDs.
#
# This also does not affect knockback screen shake or the screen shake
# from crossing a blast zone
##########################################################################
float 0.2 @ $805A1DDC