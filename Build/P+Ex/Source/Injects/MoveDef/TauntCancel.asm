# 9019A500 -> 80545C10 Runstop & Taunts Go into Teeter (Taunt Canceling v2.2) [Shanus, Camelot, Wind Owl]
# 901A1000 -> 80545C30 Taunt IASA While Running/Dashing & Slide off Edges while Dashing v2.0 [Wind Owl]
##################################################################################
Runstop & Taunts Go into Teeter (Taunt Canceling v2.2) [Shanus, Camelot, Wind Owl]
##################################################################################
.alias PSA_Off = 0x80545C10
# Teeter if over ledge
CODE @ $80545C10
{
	word 2; word PSA_Off+0x08
	word 0x02010200; word 0x80FBF254	#Change Action: Requirement: Action=E, Requirement=In Air 
	word 0x02010200; word 0x80FAB64C 	#Change Action: Requirement: Action=7C, Requirement=Has Passed Over an Edge (Forward)
	word 0x00080000; word 0 			#return
}
CODE @ $80FC3708
{
	word 0x00070100; word PSA_Off 		#Sub routine: Teeter if over ledge
}
CODE @ $80FACDEC
{
	word 0x00070100; word PSA_Off 		#Sub routine: Teeter if over ledge
}

################################################################################
Taunt IASA While Running/Dashing & Slide off Edges while Dashing v3.0 [Wind Owl, Eon]
################################################################################
.alias PSA_Off = 0x80545C30

CODE @ $80FAC60C #0x80F9FC20+0xC9F4
{
	word 0x02010300; word PSA_Off 		#Change Action to taunt if taunt pressed
	word 0x08000100; word 0x80FA1520 	#Set Aerial/Onstage State: Can drop off side of stage
}

CODE @ $80FAC974 #0x80F9FC20+0xCD54
{
	word 0x02010300; word PSA_Off 	#Change Action to taunt if taunt pressed
	word 0x00020000; word 0
	word 0x00020000; word 0
}

CODE @ $80545C30
{
	#change action to 0x10C if any taunt button pressed
	word 0; word 0x10C
	word 6; word 0x50
				
}