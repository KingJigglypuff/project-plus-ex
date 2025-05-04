# Moved Relative to PM
# 9019AA10 -> 80545928	No Powershield Buffering and Powershield Reflect v4.1
# 9019BEA0 -> 80545A28
# 9019D780 -> 80545B58	Powershield Drop Allows Shield & Powershield SFX
# 9019D7D0 -> 80545B98
# 9019D840 -> 80545BF0
#####################################################################
No Powershield Buffering and Powershield Reflect v4.1 [Shanus, Magus]
#####################################################################
.alias PSA_Off  = 0x80545928
.alias PSA_Off2 = 0x80545A28
CODE @ $80545928
{
	word 6; word 7
	word 5; IC_Basic 0
	word 0; word 1
	word 1; scalar 1.0
	word 6; word 0x30		# Button Press Occurs
	word 0; word 3			# Shield
	word 0; word 3			# Type: Reflect
	word 0; word 0			# Defensive Collision 0
	word 0; word 1			# Bubble ID 1
	word 6; word 7
	word 5; RA_Basic 1
	word 0; word 0
	word 1; scalar 2.0
	word 6; word 7			# If Comparison
	word 5; IC_Basic 20001
	word 0; word 1			# <=
	word 1; scalar 26.0	
	word 2; word PSA_Off+0x90
	word 0x000A0400; word PSA_Off+0x68		# If IC-Basic 20001 <= 0.26		# If Guard ON
	word 0x000A0400; word PSA_Off			#	If IC-Basic 0 <= 1.0		# If the first two frames
	word 0x000B0400; word PSA_Off+0x20		#	AND Shield Button Press Occurs
	word 0x12000200; word 0x80FB0BDC		#		 Basic Variable Set: RA-Basic 1 = IC-Basic 23078
	word 0x06170300; word PSA_Off+0x30		#		 Defensive Collision: Enable Reflect	 
	word 0x000E0000; word 0					# Else
	word 0x000A0400; word PSA_Off+0x48		# 	If RA-Basic 1 < 2.0
	word 0x06180300; word PSA_Off+0x30		# 		 Defensive Collision: Enable Reflect
	word 0x000F0000; word 0					# 	End If
	word 0x000F0000; word 0					# End If
	word 0x000F0000; word 0					# End If(?)
	word 0x12080200; word 0x80FB0A74		# Float Variable Subtract  LA-Float 3 (Shield Size) - IC-Basic 3237
	word 0x00070100; word PSA_Off2+0xE8		# Do function below
	word 0x00080000; word 0
}
CODE @ $80FC2158 # 80F9FC20 + 22538
{
	word 0x00070100; word PSA_Off+0x88
}
CODE @ $80FB0C5C # 80F9FC20 + 1103C
{
	word 0x00020000; word 0
}

CODE @ $80545A28
{
	word 6; word 8
	word 5; RA_Bit 10
	word 5; RA_Bit 10
	
	word 0; word 0x6A	# Graphic 6A
	word 0; word 0x12C	# Bone 0x12C?
	
	word 1; scalar 0.0
	word 1; scalar 0.0	# 0.0, 0.0, 0.0 Offset
	word 1; scalar 0.0
	
	word 1; scalar 0.0
	word 1; scalar 0.0 # 0.0, 0.0, 0.0 Rotation
	word 1; scalar 0.0
	
	word 1; scalar 0.115 # 0.115 Size
	word 3; word 0		 # Bool False 
	word 0; word 0		  #  0
	word 5; IC_Basic 21029 # Shield Color = IC-Basic 21029
	
	word 0; word 0x35	# Graphic 0x35
	word 0; word 0x12C	# Bone 0x12C?
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.3
	word 3; word 0
	word 0; word 0
	word 5; IC_Basic 21029
	
	word 0; word 0x1EF6
	word 0; word 0x1F81
	word 2; word PSA_Off2+0xF0
	word 0x000A0200; word PSA_Off2			# If RA-Bit 10 is Set
	word 0x120B0100; word PSA_Off2+0x10		#	Clear RA-Bit 10
	word 0x11010C00; word PSA_Off2+0x18		#	Graphic Effect
	word 0x11010C00; word PSA_Off2+0x78		#	Graphic Effect
	word 0x0A000100; word PSA_Off2+0xD8		#	Sound Effect 0x1EF6
	word 0x0A000100; word PSA_Off2+0xE0		#	Sound Effect 0x1F81
	word 0x000F0000; word 0					# EndIf
	word 0x00080000; word 0					# Return
}

########################################################
Powershield Drop Allows Shield & Powershield SFX [Magus]
########################################################
.alias PSA_Off  = 0x80545B58
.alias PSA_Off2 = 0x80545B98
.alias PSA_Off3 = 0x80545BF0
CODE @ $80545B58
{
	word 0; word 0x2738
	word 0; word 0x1A
	word 6; word 0x4E
	word 2; word PSA_Off+0x20
	word 0x020A0100; word 0x80FB0FF4		# Allow Specific Interrupt: Ground Attack
	word 0x02000300; word PSA_Off			# Change Action Status Requirement 0x2738: 
											#	Action 0x1A, Requirement: Any Shield Input Occurs 
	word 0x02040100; word 0x80FA9F04		# Additional Action Requirement: On Ground
	word 0x00080000; word 0					# Return
}
CODE @ $80FB1094
{
	word 0x00070100; word PSA_Off+0x18
}

CODE @ $80545B98
{
	word 6; word 8
	word 5; LA_Bit 96
	word 0; word 0xD0
	word 2; word PSA_Off2+0x20
	word 0x000A0200; word PSA_Off2			# If LA-Bit 96 is Set
	word 0x0A000100; word PSA_Off2+0x10		# 	Sound Effect 0xD0
	word 0x000E0000; word 0					# Else
	word 0x0A000100; word 0x80FB1184		# 	Sound Effect 0xD9
	word 0x120A0100; word PSA_Off2+0x08		# 	Bit Variable Set LA-Bit 96
	word 0x000F0000; word 0					# End If
	word 0x00080000; word 0					# Return
}
CODE @ $80FB123C
{
	word 0x00070100; word PSA_Off2+0x18
}
CODE @ $80545BF0
{
	word 2; word PSA_Off3+0x08
	word 0x120B0100; word PSA_Off2+0x08		# Bit Variable Clear LA-Bit 96
	word 0x12000200; word 0x80FB0BCC		# Basic Variable Set RA-Basic 0 = IC-Basic 23076
	word 0x00080000; word 0					# Return
}
CODE @ $80FB0C54
{
	word 0x00070100; word PSA_Off3
}