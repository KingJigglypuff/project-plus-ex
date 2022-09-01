# Moved Relative to PM
# 901A2000 -> 805454E0	NonTumble Hitstun Canceling v1.2
# 901A21B0 -> 80545648
# 
# 901A2288 -> 80545698	Store Variables into Hitstun CILs v1.1 
# 901A2500 -> 805457D0	Jab Reset Hitstun Linker
# 9019B000 -> 80545810	Jab Resets v8.4
#########################################
NonTumble Hitstun Canceling v1.2 [Shanus]
#########################################
.alias PSA_Off  = 0x805454E0
.alias PSA_Off2 = 0x80545648
CODE @ $805454E0
{
	#+0x0 If: Comparison Compare: IC-Basic[20003] >= 67.0   (If Prev Action between 0x43 and 0x45)
	word 6; word 7;
	word 5; IC_Basic 20003
	word 0; word 4
	word 1; scalar 67.0
	#+0x20 And: Comparison Compare: IC-Basic[20003] <= 69.0
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 1
	word 1; scalar 69.0
	#+0x40 Basic Variable Set: LA-Basic[25] = LA-Basic[30]
	word 5; LA_Basic 30
	word 5; LA_Basic 25
	#+0x50 Additional Action Requirement: Compare: LA-Float[25] > 0.0
	word 6; word 7
	word 5; LA_Basic 25
	word 0; word 5
	word 1; scalar 0.0
	#+0x70 Basic Variable Set: LA-Basic[30] = 0xA
	word 0; word 0xA
	word 5; LA_Basic 30
	#+0x80 Basic Variable Set: LA-Basic[25] = 0
	word 0; word 0
	word 5; LA_Basic 25
	#+0x90 Additional Action Requirement: Compare: LA-Float[7] <= -0.7
	word 6; word 7
	word 5; LA_Float 7
	word 0; word 1
	word 1; scalar -0.7
	#+0xB0 Additional Action Requirement: Comparison Compare: IC-Basic[0] <= 1.0
	word 6; word 7
	word 5; IC_Basic 0
	word 0; word 1
	word 1; scalar 1.0

	#+0xD0
	word 2; word PSA_Off+0xD8

	#+0xD8 Main Injection
	word 0x02010200; word 0x80FB3604 	#Change Action: Requirement: Action=0x16, Requirement=On Ground
	word 0x02040400; word PSA_Off+0xB0 	#Additional Action Requirement: Comparison Compare: IC-Basic[0] <= 1.0
	word 0x000A0400; word PSA_Off 		#If: Comparison Compare: IC-Basic[20003] >= 67.0
	word 0x000B0400; word PSA_Off+0x20 	#	And: Comparison Compare: IC-Basic[20003] <= 69.0
	word 0x12000200; word PSA_Off+0x40 	# 	Basic Variable Set: LA-Basic[25] = LA-Basic[30] 
	word 0x02010200; word 0x80FB3604 	#	Change Action: Requirement: Action=0x16, Requirement=On Ground
	word 0x02040400; word PSA_Off+0x50 	#	Additional Action Requirement: Compare: LA-Float[25] > 0.0
	word 0x02040400; word PSA_Off+0x90 	# 	Additional Action Requirement: Compare: LA-Float[7] <= -0.7
	word 0x000E0000; word 0 			#Else:
	word 0x12000200; word PSA_Off+0x80 	#	Basic Variable Set: LA-Basic[25] = 0
	word 0x02010200; word 0x80FB3604 	#	Change Action: Requirement: Action=0x16, Requirement=On Ground
	word 0x02040400; word PSA_Off+0x90 	# 	Additional Action Requirement: Compare: LA-Float[7] <= -0.7
	word 0x000F0000; word 0 			#End If:
	word 0x12000200; word PSA_Off+0x70 	#Basic Variable Set: LA-Basic[30] = 0xA
	word 0x02010200; word 0x80FB3604 	#Change Action: Requirement: Action=0x16, Requirement=On Ground
	word 0x02040100; word 0x80FB3614 	#Additional Action Requirement: Not Requirement 0x2723
	word 0x02040200; word 0x80FB361C 	#Additional Action Requirement: Bit is Set RA-Bit[17]
	word 0x00080000; word 0

	#If Grounded at start of hitstun: Land
	#If Previous action is in (GroundHit, AirHitLand, Hitstun)
	#	Store current Knockback addition Timer
	#	Land if Yspeed ignoring knockback <= -0.7 AND knockback addition DID NOT occur (timer at time of hit > 0)
	#Else
	#	Land if Yspeed ignoring Knockback <= -0.7
	#EndIf
	#Set Knockback Addition Timer to 10 frames
	#Land if Not Something (Looks to be something like "not in hitlag")
	#And bit is set Hitstun ended 
}

CODE @ $80FB3674	# 80F9FC20 + 13A54
{
	word 0x00070100; word PSA_Off+0xD0 	#Sub Routine: Main Injection
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80545648
{
	#Pointer to injection 2
	word 2; word PSA_Off2+0x10
	#Pointer to injection 3
	word 2; word PSA_Off2+0x30

	#Injection2
	word 0x12000200; word PSA_Off+0x70 	#Basic Variable Set: LA-Basic[30] = 0xA
	word 0x02010200; word 0x80FB32C4 	#Change Action: Requirement: Action=0x7E, Requirement=On Ground
	word 0x02040100; word 0x80FB32D4 	#Additional Action Requirement: Has Passed Over Ledge (Backwards)
	word 0x00080000; word 0

	#Injection3
	word 0x12000200; word PSA_Off+0x70 	#Basic Variable Set: LA-Basic[30] = 0xA
	word 0x02000300; word 0x80FB3EE4 	#Change Action Status: Requirement: ID=2715, Action=0x49, Requirement=Animation End
	word 0x02040200; word 0x80FB3EFC 	#Additional Action Requirement: Requirement Bit Is Set: RA-Bit[17]
	word 0x00080000; word 0
}
CODE @ $80FB33D4 # 80F9FC20 + 137B4
{
	word 0x00070100; word PSA_Off2 		#Sub Routine: Injection2
	word 0x00020000; word 0				#nop
}
CODE @ $80FB3F3C # 80F9FC20 + 1431C
{
	word 0x00070100; word PSA_Off2+0x08 #Sub Routine: Injection3
	word 0x00020000; word 0 			#nop
}

###############################################
Store Variables into Hitstun CILs v1.1 [Shanus]
###############################################
.alias PSA_Off = 0x80545698
CODE @ $80545698
{
	#0x0 If Requirement: Not Is in Hitlag
	word 5; LA_Basic 30
	#0x8 IF Requirement: Not On Ground
	word 6; word 0x80000003 # NOT 3
	#Float Variable Set: LA-Float[7] = IC-Basic[23] (Y-velocity ignoring knockback)
	#Note, i think this is meant to be so they can include Knockback in calculations, but it ends up ignoring knockback, meaning fast fallers are greatly benefitted
	word 5; IC_Basic 23
	word 5; LA_Float 7
	#0x20 If Requirement: Not Is in Hitlag
	word 6; word 0x80000014 # NOT 0x14

	#0x28
	word 2; word PSA_Off+0x38
	#0x30
	word 2; word PSA_Off+0x88

	#0x38 Injection1
	word 0x000A0400; word PSA_Off+0x20 	#If Requirement: Not Is in Hitlag
	word 0x12040100; word PSA_Off 		#	Basic Variable Decrement: LA-Basic[30]--
	word 0x000F0000; word 0 			#End If
	word 0x000A0200; word 0x80FB3264 	#If Requirement Value: Bit is Set RA-Bit[17] 
	word 0x000A0200; word 0x80FB3274 	#	If Requirement Value: Not Bit is Set RA-Bit[16] 
	word 0x64000000; word 0 			#		Allow Interupt
	word 0x120A0100; word 0x80FB3284 	#		Bit Variable Set: RA-Bit[16]
	word 0x000F0000; word 0 			#	End If
	word 0x000F0000; word 0				#End If
	word 0x00080000; word 0 			#Return
	#0x88 Injection2
	word 0x000A0400; word PSA_Off+0x20 	#If Requirement: Not Is in Hitlag
	word 0x12040100; word PSA_Off 		#	Basic Variable Decrement: LA-Basic[30]--
	word 0x000F0000; word 0 			#Endif
	word 0x000A0100; word 0x80FB344C 	#If Requirement: Not 2723
	word 0x000A0200; word 0x80FB3454 	#	If Requirement Value: Bit is Set RA-Bit[17]
	word 0x000B0200; word 0x80FB3464 	# 		And: Requirement Not Bit is Set LA-Bit[11]
	word 0x000A0200; word 0x80FB3474 	#		If Requirement: Not Bit is Set RA-Bit[16]
	word 0x64000000; word 0				#			Allow Interupt
	word 0x0E000100; word 0x80FB3484	#			Set Air/Ground: In Air
	word 0x020A0100; word 0x80FB348C 	#			Allow Specific Interrupt: Air Special
	word 0x0C090100; word 0x80FB3494	#			Allow/Disallow Ledgegrab: Cannot
	word 0x120A0100; word 0x80FB349C 	#			Bit Variable Set: RA-Bit[16]
	word 0x000F0000; word 0				#		End If
	word 0x000A0400; word 0x80FB34A4	#		If: Comparison Compare: IC-Basic[1008] <= 0.0 #If Y-velocity negative
	word 0x020A0100; word 0x80FB34C4 	#			Allow Specific Interrupt: Footstool
	word 0x020A0100; word 0x80FB34CC	#			Allow Specific Interrupt: Wall Jump
	word 0x020A0100; word 0x80FB34D4 	#			Allow Specific Interrupt: Air Jump
	word 0x000F0000; word 0 			#		End If
	word 0x00070100; word 0x80FB34DC 	#		Sub Routine: 0x80FC1840
	word 0x000F0000; word 0				#	End If
	word 0x000F0000; word 0				#End If
	word 0x00080000; word 0				#Return
}


CODE @ $80FB328C
{
	word 0x000A0100; word PSA_Off+0x08 	#If: Requirement Value Not On Ground
	word 0x12060200; word PSA_Off+0x10 	#	Float Variable Set: LA-Float[7] = IC-Basic[23] (Vertical Character Velocity) 
	word 0x000F0000; word 0				#Endif
	word 0x00070100; word PSA_Off+0x28 	#Sub Routine: Injection1
	word 0x00020000; word 0 			#nop
	word 0x00020000; word 0				#nop
}
CODE @ $80FB34E4
{
	word 0x000A0100; word PSA_Off+0x08 	#If: Requirement Value Not On Ground
	word 0x12060200; word PSA_Off+0x10 	#	Float Variable Set: LA-Float[7] = IC-Basic[23] (Vertical Character Velocity)
	word 0x000F0000; word 0				#Endif
	word 0x00070100; word PSA_Off+0x30 	#Sub Routine: Injection2
}
#nop 14 commands starting at 80FB3504
* 02FB3504 00370002

#####################################################
Jab Reset Hitstun Linker and Jab Resets v8.4 [Shanus]
#####################################################
.alias PSA_Off  = 0x805457D0
.alias PSA_Off2 = 0x80545810
CODE @ $805457D0
{
	word 2; word PSA_Off+0x10
	word 2; word PSA_Off+0x28
	#Injection1
	word 0x00070100; word PSA_Off2+0xE0 #Sub Routine: InjectionMain
	word 0x0D000200; word 0x80FB33C4 	#Default CIL
	word 0x00080000; word 0
	#Injection2
	word 0x00070100; word PSA_Off2+0xE0 #Sub Routine: InjectionMain
	word 0x0D000200; word 0x80FB362C 	#Default CIL
	word 0x00080000; word 0
}
CODE @ $80FB343C
{
	word 0x00070100; word PSA_Off 		#Sub Routine: Injection1
}
CODE @ $80FB368C
{
	word 0x00070100; word PSA_Off+0x08 	#Sub Routine: Injection2
}

CODE @ $80545810
{
	#0x00 Change Action: Comparison: Action=54, Requirement=Compare: IC-Basic[20003] == 74.0
	word 0; word 0x54
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 2
	word 1; scalar 74.0
	#0x28 Additional Action Requirement: Comparison: Compare: IC-Basic[23] < 7.0
	word 6; word 7
	word 5; IC_Basic 23
	word 0; word 0
	word 1; scalar 7.0
	#0x48 Change Action: Comparison: Action=54, Requirement=Compare: IC-Basic[20003] >= 77.0
	word 0; word 0x54
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 4
	word 1; scalar 77.0
	#0x70 Additional Action Requirement: Comparison: Compare: IC-Basic[20003] <= 80.0
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 1
	word 1; scalar 80.0
	#0x90 If: Comparison Compare: LA-Basic[56] >= 14.0
	word 6; word 7
	word 5; LA_Basic 56
	word 0; word 4
	word 1; scalar 14.0
	#0xB0 Change Action: Requirement Value: Action=0x53, Requirement=Button is Held Down: Attack
	word 0; word 0x53
	word 6; word 0x32
	word 0; word 0
	#0xC8 Change Action: Requirement Value: Action=0x53, Requirement=Button is Held Down: Attack
	word 0; word 0x53
	word 6; word 0x32
	word 0; word 1

	word 2; word PSA_Off2+0xE8
	word 0x02010500; word PSA_Off2		#Change Action: Comparison: Action=54, Requirement=Compare: IC-Basic[20003] == 74.0
	word 0x02040400; word PSA_Off2+0x28	#Additional Action Requirement: Comparison: Compare: IC-Basic[23] < 7.0
	word 0x02010500; word PSA_Off2+0x48	#Change Action: Comparison: Action=54, Requirement=Compare: IC-Basic[20003] >= 77.0
	word 0x02040400; word PSA_Off2+0x70	#Additional Action Requirement: Comparison: Compare: IC-Basic[20003] <= 80.0
	word 0x02040400; word PSA_Off2+0x28	#Additional Action Requirement: Comparison: Compare: IC-Basic[23] < 7.0
	word 0x00080000; word 0				#Return
}
CODE @ $80FB4EB4
{
	word 0x02010200; word 0x80FBF254 	#Change Action: Requirement: Action=E, Requirement=In Air 
	word 0x02040100; word 0x80FB4D8C 	#Additional Action Requirement: Requirement: Animation End,
	word 0x000A0400; word PSA_Off2+0x90	#If: Comparison Compare: LA-Basic[56] >= 14.0		#If Hitstun Frames >=14.0, allow buffering options other than neutral getup
	word 0x02010300; word PSA_Off2+0xB0	#	Change Action: Requirement Value: Action=0x53, Requirement=Button is Held Down: Attack
	word 0x02040100; word 0x80FB46F4	#	Additional Action Requirement: Requirement: On Ground,
	word 0x02040100; word 0x80FB4D8C	#	Additional Action Requirement: Requirement: Animation End,
	word 0x02010300; word PSA_Off2+0xC8	#	Change Action: Requirement Value: Action=0x53, Requirement=Button is Held Down: Special
	word 0x02040100; word 0x80FB46F4	#	Additional Action Requirement: Requirement: On Ground,
	word 0x02040100; word 0x80FB4D8C	#	Additional Action Requirement: Requirement: Animation End,
	word 0x02010500; word 0x80FB46FC	#	Change Action: Comparison: Action=52, Requirement=Compare: IC-Basic[1013] >= IC-Basic[3181]
	word 0x02040100; word 0x80FB46F4	#	Additional Action Requirement: Requirement: On Ground,
	word 0x02040100; word 0x80FB4D8C	#	Additional Action Requirement: Requirement: Animation End,
	word 0x000F0000; word 0				#EndIf
	word 0x02010200; word 0x80FB4D7C	#Change Action: Requirement: Action=51, Requirement=On Ground
	word 0x02040100; word 0x80FB4D8C	#Additional Action Requirement: Requirement: Animation End,
}
#Nopping lots of commands
* 02FB4F2C 00130002
* 06FB4F7C 00000008
* 00020000 00000000