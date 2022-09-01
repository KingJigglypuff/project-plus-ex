# Moved Relative to PM
# 9019CAF8 -> 80546640	No Grabbing with C-Stick v1.2 + No Gatling Grabs
# 9019B6A0 -> 80546838	Shield C-Stick Buffers v3.0 & GuardOn In Transition v1.2.1
# 9019B860 -> 80546978
# 9019B980 -> 80546A58
# 9019CD00 -> 80546A98  C-Stick Jump Shorthopping v1.2
# 9019CE00 -> 80546B40
# 9019CDC0 -> 80546C08	C-Stick Buffer Jump U-Smash Fix
# 9019D900 -> 80546C28	C-Stick Ledge Fix 
# 901A2600 -> 80546C38	C-stick Smash Fixes
# 901A2660 -> 80546C88
########################################################################
[Project+] No Grabbing with C-Stick v1.2 + No Gatling Grabs [Magus, Eon]
########################################################################
.alias C_Stick_Off = 0x80546640
CODE @ $80546640
{
	word 6; word 0x8000003D	# NOT 61
	word 6; word 0x80000030 # NOT 48
	word 0; word 0xF
	word 2; word C_Stick_Off+0x60
	word 2; word C_Stick_Off+0x88
	word 2; word C_Stick_Off+0xB0
	word 2; word C_Stick_Off+0xE0
	word 2; word C_Stick_Off+0x118
	word 2; word C_Stick_Off+0x140
	word 2; word C_Stick_Off+0x170
	word 2; word C_Stick_Off+0x198
	word 2; word C_Stick_Off+0x1C8
	
	word 0x02000401; word 0x80FA9704
	word 0x02040200; word 0x80FA9724
	word 0x02040100; word 0x80FA9734
	word 0x02040200; word C_Stick_Off+0x08
	word 0x00080000; word 0
	word 0x02000401; word 0x80FAC044
	word 0x02040200; word 0x80FAC064
	word 0x02040100; word 0x80FAC074
	word 0x02040200; word C_Stick_Off+0x08
	word 0x00080000; word 0
	
	word 0x02000601; word 0x80FABFEC
	word 0x02040200; word 0x80FAC01C
	word 0x02040200; word 0x80FAC02C
	word 0x02040100; word 0x80FAC03C
	word 0x02040200; word C_Stick_Off+0x08
	word 0x00080000; word 0
	word 0x02000601; word 0x80FAC71C
	word 0x02040400; word 0x80FAC74C
	word 0x02040200; word 0x80FAC76C
	word 0x02040200; word 0x80FAC77C
	word 0x02040100; word 0x80FAC78C
	word 0x02040200; word C_Stick_Off+0x08
	word 0x00080000; word 0
	
	word 0x02000401; word 0x80FB0924
	word 0x02040100; word 0x80FB0944
	word 0x02040100; word 0x80FB094C
	word 0x02040200; word C_Stick_Off+0x08
	word 0x00080000; word 0
	word 0x02000601; word 0x80FB078C
	word 0x02040200; word 0x80FB07BC
	word 0x02040100; word 0x80FB07CC
	word 0x02040100; word 0x80FB07D4
	word 0x02040200; word C_Stick_Off+0x08
	word 0x00080000; word 0
	
	word 0x02000401; word 0x80FB249C
	word 0x02040100; word 0x80FB24BC
	word 0x02040100; word 0x80FB24C4
	word 0x02040200; word C_Stick_Off+0x08
	word 0x00080000; word 0
	word 0x02000601; word 0x80FB244C
	word 0x02040200; word 0x80FB247C
	word 0x02040100; word 0x80FB248C
	word 0x02040100; word 0x80FB2494
	word 0x02040200; word C_Stick_Off+0x08
	word 0x00080000; word 0	

	word 0x02000401; word 0x80FAD43C
	word 0x02040200; word 0x80FAD45C
	word 0x02040100; word 0x80FAD46C
	word 0x02040100; word 0x80FAD474
	word 0x02040200; word C_Stick_Off+0x08
	word 0x00080000; word 0
}

CODE @ $80FA973C
{
	word 0x00070100; word C_Stick_Off+0x18
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FAC4E4
{
	word 0x00070100; word C_Stick_Off+0x20
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FAC4C4
{
	word 0x00070100; word C_Stick_Off+0x28
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FAC9EC
{
	word 0x00070100; word C_Stick_Off+0x20
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FAC9C4
{
	word 0x00070100; word C_Stick_Off+0x30
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FC20F0
{
	word 0x00070100; word C_Stick_Off+0x18
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FC20C0
{
	word 0x00070100; word C_Stick_Off+0x38
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FC2038
{
	word 0x00070100; word C_Stick_Off+0x40
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FB25FC
{
	word 0x00070100; word C_Stick_Off+0x48
	word 0x02040100; word C_Stick_Off
	word 0x00020000; word 0
	word 0x12000200; word 0x80FB24CC
}
CODE @ $80FB25B4
{
	word 0x00070100; word C_Stick_Off+0x50
	word 0x02040100; word C_Stick_Off
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FAD624
{
	word 0x00070100; word C_Stick_Off+0x58
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0	
}

################################################################################
Shield C-Stick Buffers v3.0 & GuardOn In Transition v1.2.1 [Magus, Shanus, ds22]
################################################################################
.alias C_Stick_Off  = 0x80546838
.alias C_Stick_Off2 = 0x80546978
.alias C_Stick_Off3 = 0x80546A58
CODE @ $80546838
{
	#00
	word 0; word 0xA 
	word 6; word 7;
	word 5; LA_Float 35
	word 0; word 4
	word 1; scalar 0.6
	#0x28
	word 0; word 0x1E
	word 6; word 7
	word 5; LA_Float 35
	word 0; word 1
	word 1; scalar -0.6
	#0x50
	word 0; word 0x1F
	word 6; word 7
	word 5; LA_Float 34
	word 0; word 4
	word 1; scalar 0.6
	#0x78
	word 0; word 0x20
	word 6; word 7
	word 5; LA_Float 34
	word 0; word 1
	word 1; scalar -0.6
	#0xA0
	word 1; scalar 1.00

	#0xA8
	word 2; word C_Stick_Off+0x108
	#0xB0
	word 2; word C_Stick_Off+0x128
	#0xB8
	word 2; word C_Stick_Off+0x0C0

	#0xC0
	word 0x02010500; word C_Stick_Off 		#Change action 0xA if C-stick Y > 0.6
	word 0x02040100; word 0x80FB0884 		#Additional action requirement On Ground
	word 0x02010500; word C_Stick_Off+0x28 	#Change action 0x1E if C-stick Y < -0.6
	word 0x02040100; word 0x80FB0884		#Additional action requirement On Ground
	word 0x02010500; word C_Stick_Off+0x50 	#Change action 0x1F if C-stick X > 0.6
	word 0x02040100; word 0x80FB0884		#Additional action requirement On Ground
	word 0x02010500; word C_Stick_Off+0x78 	#Change action 0x20 if C-stick X < 0.6
	word 0x02040100; word 0x80FB0884		#Additional action requirement On Ground
	word 0x00080000; word 0
	#0x108
	word 0x00070100; word 0x80FB0C14 		#sub routine
	word 0x00010100; word C_Stick_Off+0xA0 	#synchronous timer 1 frame
	word 0x00070100; word C_Stick_Off2+0x38 #sub routine C_Stick_Off2
	word 0x00080000; word 0
	#0x128
	word 0x0D000200; word 0x80FB0DF4 		#concurrent infinite loop default
	word 0x00070100; word C_Stick_Off+0xB8 	#sub routine 0xC0
	word 0x00080000; word 0					#return
}
CODE @ $80FB0C84
{
	word 0x00070100; word C_Stick_Off+0xA8
}
CODE @ $80FC22A0
{
	word 0x00070100; word C_Stick_Off+0xB0
}
#C_Stick_Off2
CODE @ $80546978
{
	#0x0
	word 1; scalar 3.0
	#0x8
	word 0; word 0x14B
	#0x10
	word 1; scalar 4.0
	#0x18
	word 1; scalar 0.0
	word 5; RA_Float 4
	#0x28
	word 1; scalar 0.0
	word 5; RA_Float 5
	#0x38
	word 2; word C_Stick_Off2+0x80
	#0x40
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 4
	word 1; scalar 17.0
	#0x60
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 0
	word 1; scalar 26.0
	#0x80
	word 0x00070100; word C_Stick_Off+0xB8 	#sub routine cstick options
	word 0x00010100; word C_Stick_Off2		#synch timer 3 frames
	word 0x000A0400; word C_Stick_Off2+0x40 #if prev action = 17.0
	word 0x000B0400; word C_Stick_Off2+0x60 #or prev action = 26.0
	word 0x04000100; word 0x80FB0BEC 		#subroutine
	word 0x04060100; word C_Stick_Off2+0x10 #set animation frame 4.0
	word 0x000F0000; word 0 				#endif
	word 0x12060200; word C_Stick_Off2+0x18 #float set RA-Float[4] = 0
	word 0x12060200; word C_Stick_Off2+0x28 #float set RA-Float[5] = 0
	word 0x040A0100; word 0x80FB0BF4 		#Change action if 
	word 0x040B0100; word 0x80FB0BFC 		#additional action requirement 
	word 0x00080000; word 0					#return
}

CODE @ $80546A58
{
	word 2; word C_Stick_Off3+0x08
	word 0x000A0400; word C_Stick_Off2+0x40 #if prev action = 17.0
	word 0x000B0400; word C_Stick_Off2+0x60 #or prev action = 26.0
	word 0x04000100; word C_Stick_Off2+0x08 #change sub action 0x14B
	word 0x000E0000; word 0					#else
	word 0x04000100; word 0x80FB0BEC		#default sub action 
	word 0x000F0000; word 0					#endif
	word 0x00080000; word 0

}

CODE @ $80FB0C64
{
	word 0x00070100; word C_Stick_Off3
	word 0x00020000; word 0
	word 0x00020000; word 0
}

######################################
C-Stick Jump Shorthopping v1.2 [Magus]
######################################
.alias C_Stick_Off  = 0x80546A98
.alias C_Stick_Off2 = 0x80546B40
CODE @ $80546A98
{
	word 6; word 0x4F
	word 6; word 7
	word 5; LA_Float 35
	wprd 0; word 4
	word 1; scalar 0.6
	word 6; word 0x80000030 # NOT 0x30
	word 0; word 2
	word 5; RA_Bit 15
	word 0x00000002; word C_Stick_Off+0x48
	word 0x000A0400; word 0x80FAD8B4
	word 0x000C0400; word 0x80FAD8D4
	word 0x000C0200; word 0x80FAD49C
	word 0x120A0100; word 0x80FAD8F4
	word 0x000F0000; word 0
	word 0x000A0100; word C_Stick_Off
	word 0x000B0400; word C_Stick_Off+0x08
	word 0x000B0200; word C_Stick_Off+0x28
	word 0x120B0100; word 0x80FAD8F4
	word 0x120A0100; word C_Stick_Off+0x38
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FC17C0
{
	word 0x00070100; word C_Stick_Off+0x40
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80546B40
{
	word 6; word 8
	word 5; RA_Float 15
	word 6; word 7
	word 5; LA_Float 35
	word 0; word 0
	word 5; IC_Basic 0xC44
	word 6; word 0x80000008 # NOT 8
	word 5; RA_Bit 16
	word 6; word 0x80000008
	word 5; RA_Bit 15
	word 0x00000002; word C_Stick_Off2+0x58
	word 0x000A0200; word 0x80FAD814
	word 0x000B0200; word 0x80FAD824
	word 0x120A0100; word 0x80FAD834
	word 0x000F0000; word 0
	word 0x000A0200; word C_Stick_Off2
	word 0x000B0200; word C_Stick_Off2+0x10
	word 0x120A0100; word 0x80FAD834
	word 0x000F0000; word 0
	word 0x000A0200; word C_Stick_Off2+0x30
	word 0x000B0200; word C_Stick_Off2+0x40
	word 0x000B0400; word 0x80FAD83C
	word 0x120A0100; word 0x80FAD834
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FAD864
{
	word 0x00070100; word C_Stick_Off2+0x50
}
* 02FAD86C 001F0002

#######################################
C-Stick Buffer Jump U-Smash Fix [Magus]
#######################################
.alias C_Stick_Off = 0x80546C08
CODE @ $80546C08
{
	word 0x00000002; word C_Stick_Off+0x08
	word 0x07010000; word 0
	word 0x07020000; word 0
	word 0x00080000; word 0
}
CODE @ $80FC1810
{
	word 0x00070100; word C_Stick_Off
}

#############################
C-Stick Ledge Fix [Dantarion]
#############################
.alias C_Stick_Off = 0x80546C28
CODE @ $80546C28 
{
	word 0x07020000; word 0x80F9FC20
	word 0; word 0
}
op word C_Stick_Off @ $80FC05A8
CODE @ $80FB6774
{
	word 0x02000301; word 0x80FB66AC
	word 0x02040200; word 0x80FB66C4
	word 0x02000301; word 0x80FB66D4
	word 0x02040200; word 0x80FB66EC
	word 0x02000301; word 0x80FB66FC
	word 0x02040200; word 0x80FB6714
	word 0x02000301; word 0x80FB665C
	word 0x02040200; word 0x80FB6674
	word 0x02000301; word 0x80FB6684
	word 0x02040200; word 0x80FB669C
}


##############################
!C-stick Smash Fixes [camelot]
##############################
.alias C_Stick_Off  = 0x80546C38
.alias C_Stick_Off2 = 0x80546C88
CODE @ $80546C38
{
	word 6; word 0x30
	word 0; word 0xF
	word 0; word 0x30
	word 6; word 0xFF
	word 0x00000002; word C_Stick_Off+0x28
	word 0x02010200; word 0x80FABAF4
	word 0x000A0200; word C_Stick_Off
	word 0x02010200; word C_Stick_Off+0x10
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FB29CC
{
	word 0x00070100; word C_Stick_Off+0x20
}
CODE @ $80546C88
{
	word 0; word 0x2D
	word 6; word 0xFF
	word 0x00000002; word C_Stick_Off2+0x18
	word 0x02010200; word 0x80FABAF4
	word 0x000A0200; word C_Stick_Off
	word 0x02010200; word C_Stick_Off2
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FC2498
{
	word 0x00070100; word C_Stick_Off2+0x10
}

############################################
!C-Stick Throws [Dantarion, standardtoaster]
############################################
CODE @ $80FAF85C
{
	word 0x02000600; word 0x80FAF754
	word 0x02040400; word 0x80FAF784
	word 0x02040100; word 0x80FAF7A4
	word 0x02000600; word 0x80FAF7AC
	word 0x02040400; word 0x80FAF7DC
	word 0x02040100; word 0x80FAF7FC
	word 0x02000600; word 0x80FAF804
	word 0x02040400; word 0x80FAF834
	word 0x02040100; word 0x80FAF854
	word 0x02010300; word 0x80FAF734
	word 0x02040100; word 0x80FAF74C
}