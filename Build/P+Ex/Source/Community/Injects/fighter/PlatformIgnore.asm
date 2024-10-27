##############################################################
Toggle Platform Interaction When Grabbed [KingJigglypuff, Eon]
##############################################################
.alias PSA_Offset = 0x8054A668
.alias PSA_Offset2 = 0x8054A6A0
.alias PSA_Offset3 = 0x8054A790
.alias PSA_Offset4 = 0x8054A7C8
.alias PSA_Offset5 = 0x8054A840
#Disable platform interaction if LA-Basic[150] is set to 1 and enable it if it's set to 0. If set to 2, disables all stage interaction entirely.
CODE @ $8054A668
{
	word 2; word PSA_Offset+0x20					#Pointer: 0x80546C50
	#Concurrent Infinite Loop: Thread: 0x9: Offset: 0x80546C88
	word 0; word 9									#Value: 9
	word 2; word PSA_Offset2+0x78					#Pointer: 0x80546CD8
	#Sub Routine
	word 2; word 0x8054C1E0							#Pointer: 0x8054C1E0
	
	
	word 0x0D000200; word PSA_Offset+0x08			#(Concurrent Infinite Loop) Param Offset: 0x80546C38
	word 0x00070100; word PSA_Offset+0x18			#(Sub Routine) Param Offset: 0x80546C48
	word 0; word 0									#Return
}
CODE @ $8054A6A0
{
	word 2; word PSA_Offset2+0x78					#Pointer: 0x80546C50

	#If Compare: LA-Basic[150] == 2.0
	word 6; word 0x7								#Requirement: 7 (Compare)
	word 5; LA_Basic 150							#Variable: LA-Basic[150]
	word 0; word 2									#Value: 2 (Equals)
	word 1; scalar 2								#Scalar: 2.0
	
	#Set Aerial/Onstage State: 0 (No-Clip)
	word 0; word 0									#Value: 0
	
	#If Compare: LA-Basic[150] == 1.0
	word 6; word 0x7								#Requirement: 7 (Compare)
	word 5; LA_Basic 150							#Variable: LA-Basic[150]
	word 0; word 2									#Value: 2 (Equals)
	word 1; scalar 1								#Scalar: 1.0
	
	#Edge Interaction 04: false (Disables platform interaction)
	word 3; word 0									#Boolean: 0 (False)
	
	#Edge Interaction 04: true (Enables platform interaction)
	word 3; word 1									#Boolean: 1 (True)
	#If On Ground
	word 6; word 0x3								#Requirement: 3 (On Ground)
	#Set Aerial/Onstage State: 3 (Can drop off side of stage)
	word 0; word 1									#Value: 1
	#Set Aerial/Onstage State: 5 (In Air: Can leave stage vertically)
	word 0; word 5									#Value: 5
	
	
	word 0x000A0400; word PSA_Offset2+0x08				#If Compare
	word 0x08000100; word PSA_Offset2+0x28			#Set Aerial/Onstage State
	word 0x000E0000; word 0							#Else
	word 0x000A0400; word PSA_Offset2+0x30			#If Compare	
	word 0x08040100; word PSA_Offset2+0x50			#Edge Interaction
	word 0x000E0000; word 0							#Else
	word 0x08040100; word PSA_Offset2+0x58			#Edge Interaction
	word 0x000F0000; word 0							#EndIf
	word 0x000A0100; word PSA_Offset2+0x60			#If
	word 0x08000100; word PSA_Offset2+0x68			#Set Aerial/Onstage State	
	word 0x000E0000; word 0							#Else
	word 0x08000100; word PSA_Offset2+0x70			#Set Aerial/Onstage State
	word 0x000F0000; word 0							#EndIf
	word 0x000F0000; word 0							#EndIf	
	word 0; word 0									#Return
}
CODE @ $8054A790
{
	word 0; word 9									#Value: 9
	word 2; word PSA_Offset3+0x20					#Pointer: 0x80546EEC
	#Sub Routine
	word 2; word PSA_Offset2+0x70					#Pointer: 0x80546CD8
	#Sub Routine
	word 2; word 0x80FB00C4
	
	
	word 0x00070100; word PSA_Offset3+0x10			#(Sub Routine) Param Offset: 0x80546EDC
	word 0x00070100; word PSA_Offset3+0x18			#(Sub Routine) Param Offset: 0x80546EE4
	word 0; word 0									#Return
}
CODE @ $8054A7C8
{
	#If Compare: IC-Basic[20001] != 63.0 [If current action does not equal 63.0 (CaptureDamage)]
	word 6; word 0x7								#Requirement: 7 (Compare)
	word 5; IC_Basic 20001							#Variable: IC-Basic[20001]
	word 0; word 0x3								#Value: 3 (Does not Equal)
	word 1; scalar 63								#Scalar: 63.0
	#If Compare: IC-Basic[20001] != 62.0 [If current action does not equal 62.0 (CaptureWait)]
	word 6; word 0x7								#Requirement: 7 (Compare)
	word 5; IC_Basic 20001							#Variable: IC-Basic[20001]
	word 0; word 0x3								#Value: 3 (Does not Equal)
	word 1; scalar 62								#Scalar: 62.0
	#Basic Variable Set: LA-Basic[150] = 0
	word 0; word 0x0								#Value: 0
	word 5; LA_Basic 150							#Variable: LA-Basic[150]
	
	
	word 0x000A0400; word PSA_Offset4				#(If Compare) Param Offset: 0x80546F04
	word 0x000B0400; word PSA_Offset4+0x20			#And Compare
	word 0x12000200; word PSA_Offset4+0x40			#(Basic Variable Set) Param Offset: 0x80546F24
	word 0x000F0000; word 0							#EndIf
	word 0; word 0									#Return
}
CODE @ $8054A840
{
	word 0; word 9									#Value: 9
	word 2; word PSA_Offset5+0x20					#Pointer: 0x80546EEC
	#Sub Routine
	word 2; word 0x8054C108
	#Sub Routine
	word 2; word 0x8054A710
	
	
	word 0x00070100; word PSA_Offset5+0x10			#(Sub Routine) Param Offset: 0x80546EDC
	word 0x00070100; word PSA_Offset5+0x18			#(Sub Routine) Param Offset: 0x80546EE4
	word 0; word 0									#Return
}
word 0x8054A818 @ $80FC04C8							#CapturePulled (Exit)
word 0x8054A818 @ $80FC04CC							#CaptureWait (Exit)
word 0x8054A818 @ $80FC04D0							#CaptureDamage (Exit)
CODE @ $80FB0014 #CapturePulled (Entry): 0x80F9FC20 + 0x103F4, replaces top command.
{
	word 0x00070100; word PSA_Offset				#Sub Routine
}
CODE @ $80FB0274 #CaptureWait (Entry): 0x80F9FC20 + 0x10654, replaces top command.
{
	word 0x0D000200; word PSA_Offset3				#Concurrent Infinite Loop
}
CODE @ $8054C0F0									#Action 3F Concurrent Infinite Loop Replacement
{
	word 0x0D000200; word PSA_Offset5
}
CODE @ $80FAFF44									#Action 0x3D Ground State
{
	word 0x00070100; word PSA_Offset2				#Sub Routine
}
CODE @ $80FAFF8C									#Action 0x3D Air State
{
	word 0x00070100; word PSA_Offset2				#Sub Routine
}
CODE @ $80FB028C									#Action 0x3E Ground State
{
	word 0x00070100; word PSA_Offset2				#Sub Routine
}
CODE @ $80FB02D4									#Action 0x3E Air State
{
	word 0x00070100; word PSA_Offset2				#Sub Routine
}
CODE @ $80FB044C									#Action 0x3F Ground State
{
	word 0x00070100; word PSA_Offset2				#Sub Routine
}
CODE @ $80FB0494									#Action 0x3F Air State
{
	word 0x00070100; word PSA_Offset2				#Sub Routine
}