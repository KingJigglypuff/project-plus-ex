#
# 9019FC00 -> 80540370 Missfoot is FFable, can grab edges, has air control, and goes into tumble or hard landing
# 9019BD50 -> 805403D8 Slide Off Edges During Hard/Light Landing
#################################################

#################################################
Edge Grabs Disabled During Damage Actions [Magus]
#################################################
word 0x0 @ $80FB3498

Ledgedrop/Grab Speedup [Yeroc]
* 06FB656C 00000008
* 00000001 00030D44

##############################################################################################################
Missfoot is FFable, can grab edges, has air control, and goes into tumble or hard landing v3.1 [Shanus, Magus]
##############################################################################################################
.alias PSA_Off = 0x80540370

word 0x00020000 @ $80FC2AD0
CODE @ $80540370
{
	word 0; word 0x16
	word 6; word 3
	word 0; word 0
	word 5; LA_Basic 56
	word 0; word 1
	word 0; word 9
	word 0x00000002; word 0x80FAD9DC
	word 0x00000002; word PSA_Off+0x40
	word 0x02010200; word PSA_Off
	word 0x12000200; word PSA_Off+0x10
	word 0x0C090100; word PSA_Off+0x20
	word 0x0D000200; word PSA_Off+0x28
	word 0x00080000; word 0
}
CODE @ $80FC2AF0 # 80F9FC20 + 22ED0
{
	word 0x00070100; word PSA_Off+0x38
}

###################################
No Autosweetspot Ledges v2.2 [Eon]
#
# converted to PSA
###################################
.alias PSA_Off = 0x80546EE8
CODE @ $80546EE8
{
    word 2; word PSA_Off+0x28
    word 6; word 7               #if compare
    word 5; IC_Basic 23          #vertical character velocity
    word 0; word 1               #<=
    word 1; scalar -0.0001       #-0.0001
    word 0x02040400; word PSA_Off+0x8
    word 0x02040400; word 0x80FAA3DC
    word 0; word 0
}
CODE @ $80FC1458
{
    word 0x00070100; word PSA_Off
}

#############################################
Special Landing is Teeter-Capable [DukeItOut]
#############################################
#
# 1.1: Made more customizable and fixed Assist Trophies!
#
# Set RA-Basic 10 to 1 (edge cancel) or 2 (don't) in action override 0x19 and then
#  set up an external pointer in the override to "statusAnimCmd_LandingFallSpecial"
# You can do this by setting a subroutine to go to a pointer 0xFFFFFFFF in PSA Compressor (it will render as 2xFFFFFFFF)
# After, right-click, click Set External and then use "statusAnimCmd_LandingFallSpecial"
# If not found, add to the Data -> External Subroutines tab
#
# For context on setting RA-Basic 10, use IC-Basic 20003 to get the previous action and set accordingly!
# You do not need to set it for default behavior.
#
# 1.2: Migrated 
#############################################
.alias PSA_Off = 0x8053FF00
.alias Teeter_Loc = PSA_Off

CODE @ $8053FF00
{
	word 2; word PSA_Off+8
	word 0x02010200; word 0x80FAF454	# Change Action E (Fall). Requirement: In Air (adddress for the original that was overwritten below.)
	word 0x000A0400; word PSA_Off+0x80	# If IC-Basic 20009 == 0 (Holding Item of Type 0: Assist Trophy)
	word 0x000C0400; word PSA_Off+0xE0	# Or IC_Basic 1102 <= 0.05 (Relative X Force Speed Movement)
	word 0x000C0400; word PSA_Off+0xA0	# Or RA-Basic 10 == 1
	word 0x08000100; word PSA_Off+0x78  #	 Air/Ground State: Go off ledges
	word 0x000D0400; word PSA_Off+0xC0	# Else If RA-Basic 10 == 2
	word 0x08000100; word PSA_Off+0x70  #	 Air/Ground State: Don't go off ledges
	word 0x000E0000; word 0				# Else
	word 0x08000100; word PSA_Off+0x68	# 	Air/Ground State: Can't go off ledges moving forwards.
	word 0x00070100; word 0x80FABBB4	# 	Subroutine in walking that determines if the stick position allows teetering.
	word 0x000F0000; word 0				# End If
	word 0x00080000; word 0				# Return
	
	word 0; word 8						# Collision Type 8 (Don't go off ledges while moving forwards)
	word 0; word 2						# Collision Type 2 (Don't go off ledges)
	word 0; word 1						# Collision Type 1 (Do go off ledges)
	
	word 6; word 7	# Comparison
	word 5; IC_Basic 20009  # Held Item (should be -1 if none)
	word 0; word 2 			#
	word 0; word 0			# Type 0: Assist Trophy
	
	word 6; word 7	# Comparison
	word 5; RA_Basic 10 	# RA Basic 10 = 1
	word 0; word 2 			#
	word 0; word 1			#

	word 6; word 7	# Comparison
	word 5; RA_Basic 10 	# RA Basic 10 = 2
	word 0; word 2 			#
	word 0; word 2			#
	
	word 6; word 7	# Comparison
	word 5; IC_Basic 1102 	# IC Basic 1102 (Relative X Force Speed Movement) <= 0.05
	word 0; word 1			#
	word 1; scalar 0.05		#
	
}
CODE @ $80FC1CA0 # 80F9FC20 + 22080 # Action 19: Special Landing
{
	word 0x00070100; word Teeter_Loc # Go to the above
}
#############################################################
# Merged in the following two codes:
# Teeter Cancelling [Shanus, Yeroc, Dantarion, Wind Owl, Magus]
# Merged Slide Off Edges During Hard/Light Landing v1.3 [Shanus]
#
# Now they teeter with the above rules, too.
############################################################
CODE @ $80FC1C58 # 80F9FC20 + 22038 # Action 18: Aerial Landing (i.e. L-Cancel. Already teetered in PM.)
{
  word 0x00070100; word Teeter_Loc
}
CODE @ $80FC1BC0 # 80F9FC20 + 21FA0 # Action 16: Heavy Landing (i.e. Auto-Cancel, Empty)
{
	word 0x00070100; word Teeter_Loc
}
CODE @ $80FC1C08	# 80F9FC20 + 21FE8 # Action 17: Light Landing (mostly unused in PM)
{
	word 0x00070100; word Teeter_Loc
}
