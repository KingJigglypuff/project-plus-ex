# Moved Relative to PM
# 9019E070 -> 80546CC8	MC Fail Window Fix 
# 9019D940 -> 80546D08	Run Off Aerial Ground Jump Requires Holding Up
# 9019D980 -> 80546D38
# 9019BDA0 -> 80546DB0	Grab During Jumpsquat (Jump-Canceled Grabs) 
# 9019BDD0 -> 80546DD8	Footstool Action Exit Clears Auto-Footstool Bit 
# 9019A600 -> 80546E00	Rebound Now has SFX
# 9019A650 -> 80546E38	Body Collisions Only Apply When Thrown 
# 9019E200 -> 80545000	Launch Speed Sound + Graphic Effects
# 9019A8A0 -> 80545150	Slide Off Edges During Wait1
# 9019A9C0 -> 80545220	Dash Cancel v3.0
# 9019C300 -> 80545268	Down on C-Stick does not Fastfall 
# 9019B200 -> 80545300	Grab Has Priority over Roll
# 9019B280 -> 80545350	Teching Now has SFX
# 9019B3F0 -> 80545390	WallJumps Require Smash Input Away Only and 0.8 Sensitivity, and WallCling is 0.945
# 9019B600 -> 80545498	Turn and Neutral-B out of SquatReverse
# 901A1100 -> 80546E90	Shield Button while Laying Down goes into Get-up
# 901B20B0 -> 80540478	Monkey Flip DamageFace Fix
# 9019F880 -> 805404C8	Dash Dancing & Dash Roll Window is 3 Frames
# 9019CA70 -> 80540530 	No Impact Landing Replaces Light Landing
# 9019D380 -> 805405B0	Wiggle Out of Tumble in Action 45
# 9019D440 -> 80540640	Tech Window Fixes, Floor Hit Delay Fix, & Tech in Certain Actions
# 9019D480 -> 80540660	Action Changes Allowed During Hitlag and Edgeteching
# 9019D680 -> 805407F0	Special Fall Depletes Jumps
# 9019BC00 -> 80540820	Z now triggers aerials instead of air dodge
# 9019D1A0 -> 80540850	F-Smash During Dash Window is 4 Frames and 1 in DD
# 9019D200 -> 805408A0

# 9019D300 -> 80540908	Shield Break Getup is 30 Frames and Ending Interruptible
# 901A1300 -> 80540970	Wakeup from Sleep is Interruptible Frame 10+

#####################################
MC Fail Window Fix V1.2 [ds22, Magus]
#####################################
.alias PSA_Off = 0x80546CC8
CODE @ $80546CC8
{
	word 2; word PSA_Off+0x10
	word 2; word PSA_Off+0x28
	word 0x02040400; word 0x80FB3A1C
	word 0x02040400; word 0x80FB3964
	word 0x00080000; word 0
	word 0x02040400; word 0x80FB3C04
	word 0x02040400; word 0x80FB3964
	word 0x00080000; word 0

}
CODE @ $80FB3CF4
{
	word 0x00070100; word PSA_Off
}
CODE @ $80FB3D84
{
	word 0x00070100; word PSA_Off+0x08
}
word 0x10000053 @ $80FB3888

######################################################
Run Off Aerial Ground Jump Requires Holding Up [Magus]
######################################################
.alias PSA_Off  = 0x80546D08
.alias PSA_Off2 = 0x80546D38
CODE @ $80546D08
{
	word 2; word PSA_Off+0x08
	word 0x02000401; word 0x80FAE534
	word 0x02040200; word 0x80FAE554
	word 0x02040400; word 0x80FAE564
	word 0x02040400; word 0x80FAE594
	word 0x00080000; word 0
}
CODE @ $80FC1B00
{
	word 0x00070100; word PSA_Off
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80546D38
{
	word 6; word 7;
	word 5; IC_Basic 20003
	word 0; word 2
	word 1; scalar 14.0
	word 0; word 0x12
	word 1; scalar 1.0
	word 2; word PSA_Off2+0x38
	word 0x0D000200; word 0x80FADD84
	word 0x000A0400; word PSA_Off2
	word 0x07010000; word 0
	word 0x020B0100; word PSA_Off2+0x20
	word 0x00010100; word PSA_Off2+0x28
	word 0x020A0100; word PSA_Off2+0x20
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FC19A0
{
	word 0x00070100; word PSA_Off2+0x30
}

################################################################
Grab During Jumpsquat (Jump-Canceled Grabs) v3.0 [Shanus, Magus]
################################################################
.alias PSA_Off = 0x80546DB0
CODE @ $80546DB0
{
	word 2; word 0x80FA973C
	word 2; word PSA_Off+0x10
	word 0x00070100; word 0x80FAD96C
	word 0x00070100; word PSA_Off
	word 0x00080000; word 0
}
CODE @ $80FC1808
{
	word 0x00070100; word PSA_Off+0x08
}

######################################################
Footstool Action Exit Clears Auto-Footstool Bit [ds22]
######################################################
.alias PSA_Off = 0x80546DD8
CODE @ $80546DD8
{
	word 5; LA_Bit 5
	word 2; word PSA_Off+0x10
	word 0x12000200; word 0x80FB6334
	word 0x120B0100; word PSA_Off
	word 0x00080000; word 0
}
CODE @ $80FB6344
{
	word 0x00070100; word PSA_Off+0x08
}

#############################################
Rebound Now has SFX [Shanus, Standardtoaster]
#############################################
.alias PSA_Off = 0x80546E00
CODE @ $80546E00
{
	word 0; word 0xD9
	word 0; word 0x1EF1
	word 2; word PSA_Off+0x18
	word 0x0A000100; word PSA_Off
	word 0x0A000100; word PSA_Off+0x08
	word 0x04070100; word 0x80FB1984
	word 0x00080000; word 0
}
CODE @ $80FB19AC
{
	word 0x00070100; word PSA_Off+0x10
}

###############################################################
Body Collisions Only Apply When Thrown v1.2 [Shanus, DukeItOut]
###############################################################
.alias PSA_Off = 0x80546E38
CODE @ $80546E38
{
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 2
	word 1; scalar 66.0
	word 2; word PSA_Off+0x28
	word 0x000A0400; word PSA_Off
	word 0x00070100; word 0x80FB3F24
	word 0x00020100; word 0x80FB3F2C
	word 0x00070100; word 0x80FB3F34
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FB3F64
{
	word 0x00020000; word 0 # This line is different and bugged in PM and points to bad data there, dummied out, properly, now.
	word 0x00070100; word PSA_Off+0x20 
	word 0x00020000; word 0
}
CODE @ $80FB3FF4
{
	word 0x00020000; word 0
	word 0x00070100; word PSA_Off+0x20
	word 0x00020000; word 0
}

##############################################
Launch Speed Sound + Graphic Effects [camelot]
##############################################
.alias PSA_Off = 0x80545000
CODE @ $80545000
{
	word 6; word 7
	word 5; IC_Basic 1005
	word 0; word 5
	word 1; scalar 3.7
	word 6; word 7
	word 5; IC_Basic 1005
	word 0; word 5
	word 1; scalar 6.7
	word 0; word 0x45
	word 0; word 0x46
	word 0; word 0x2A
	word 0; word 0
	word 1; scalar 0.0
	word 1; scalar 5.0
	word 1; scalar 0.0
	word 1; scalar 90.0
	word 1; scalar 90.0
	word 1; scalar 0.0
	word 1; scalar 1.0
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 3; word 0
	word 0; word 0x2A
	word 0; word 0
	word 1; scalar 0.0
	word 1; scalar 5.0
	word 1; scalar 0.0
	word 1; scalar 270.0
	word 1; scalar 90.0
	word 1; scalar 0.0
	word 1; scalar 1.1
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 3; word 0
	
}
CODE @ $80FB3E6C
{
	word 0x000A0400; word PSA_Off+0x20
	word 0x0A000100; word PSA_Off+0x40
	word 0x11001000; word PSA_Off+0x50
	word 0x11001000; word PSA_Off+0xD0
	word 0x000D0400; word PSA_Off
	word 0x0A000100; word PSA_Off+0x48
	word 0x000F0000; word 0
}

#################################################
Slide Off Edges During Wait1 v4 [Shanus, Camelot]
#################################################
.alias PSA_Off = 0x80545150
CODE @ $80545150
{
	word 6; word 7
	word 5; IC_Basic 20001
	word 0; word 3
	word 1; scalar 190.0
	word 0; word 1
	word 2; word PSA_Off+0x50
	word 2; word PSA_Off+0x68
	word 2; word PSA_Off+0x80
	word 2; word PSA_Off+0x98
	word 2; word PSA_Off+0xB0
	word 0x00070100; word PSA_Off+0x48
	word 0x04000100; word 0x80FAB75C
	word 0x00080000; word 0
	word 0x00070100; word PSA_Off+0x48
	word 0x04000100; word 0x80FAB7AC
	word 0x00080000; word 0
	word 0x00070100; word PSA_Off+0x48
	word 0x04000100; word 0x80FAB804
	word 0x00080000; word 0
	word 0x00070100; word PSA_Off+0x48
	word 0x04000100; word 0x80FAB804
	word 0x00080000; word 0
	word 0x000A0400; word PSA_Off
	word 0x08000100; word PSA_Off+0x20
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FAB8BC
{
	word 0x00070100; word PSA_Off+0x28
}
CODE @ $80FAB8F4
{
	word 0x00070100; word PSA_Off+0x30
}
CODE @ $80FAB92C
{
	word 0x00070100; word PSA_Off+0x38
}
CODE @ $80FAB9BC
{
	word 0x00070100; word PSA_Off+0x40
}

#####################################################################################
Dash Cancel v3.1 [Yeroc, Shanus (Location Change), DukeItOut (Other Location Change)]
#####################################################################################
.alias PSA_Off = 0x80545220
CODE @ $80545220
{
	word 0; word 0x11
	word 6; word 7
	word 5; IC_Basic 1020
	word 0; word 4
	word 5; IC_Basic 3186
	word 2; word PSA_Off+0x30
	word 0x02010500; word PSA_Off
	word 0x02000401; word 0x80FACC84
	word 0x00080000; word 0
}
CODE @ $80FACE8C
{
	word 0x00070100; word PSA_Off+0x28
}

##############################################
Down on C-Stick does not Fastfall v2.1 [Magus]
##############################################
.alias PSA_Off = 0x80545268
CODE @ $80545268
{
	word 6; word 0x80000030 # NOT 0x30 
	word 0; word 0xF

	word 6; word 7
	word 5; IC_Basic 0
	word 0; word 4
	word 1; scalar 1.0

	word 6; word 7
	word 5; IC_Basic 20001
	word 0; word 3
	word 1; scalar 51.0
	
	word 2; word PSA_Off+0x58
	word 0x000A0100; word 0x80FAD9CC
	word 0x000B0200; word PSA_Off
	word 0x000A0400; word PSA_Off+0x10
	word 0x000C0400; word PSA_Off+0x30
	word 0x120A0100; word 0x80FAD9D4
	word 0x000F0000; word 0
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FAD9DC
{
	word 0x00070100; word PSA_Off+0x50
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}

#########################################
Grab Has Priority over Roll v1.2 [Shanus]
#########################################
.alias PSA_Off = 0x80545300
CODE @ $80545300
{
	word 2; word PSA_Off+0x08
	word 0x02010300; word 0x80FA970C
	word 0x02040200; word 0x80FA9724
	word 0x02040100; word 0x80FA9734
	word 0x02040100; word 0x80FAC03C
	word 0x02000401; word 0x80FACFEC
	word 0x02040400; word 0x80FAD00C
	word 0x02040400; word 0x80FAD02C
	word 0x02040100; word 0x80FAD04C
	word 0x00080000; word 0
}
CODE @ $80FAD14C		# offset D52C of 80F9FC20
{
	word 0x00070100; word PSA_Off
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}

############################################
Teching Now has SFX [Standardtoaster, Magus]
############################################
.alias PSA_Off = 0x80545350
CODE @ $80545350
{
	word 0; word 0x36
	word 0; word 0x7D
	word 2; word PSA_Off+0x18
	word 0x0A000100; word PSA_Off
	word 0x0A000100; word PSA_Off+0x08
	word 0x0A000100; word PSA_Off+0x08
#	this command sets combo counter to 0, removed to allow techchases to count in combo counter
#	word 0x0C2B0000; word 0 
	word 0x00080000; word 0
}
CODE @ $80FB5594
{
	word 0x00070100; word PSA_Off+0x10
}
CODE @ $80FB561C
{
	word 0x00070100; word PSA_Off+0x10
}
CODE @ $80FB57F4
{
	word 0x00070100; word PSA_Off+0x10
}
CODE @ $80FB5984
{
	word 0x00070100; word PSA_Off+0x10
}

###################################################################################################
WallJumps Require Smash Input Away Only and 0.8 Sensitivity, and WallCling is 0.945 [Magus, Shanus]
###################################################################################################
.alias PSA_Off = 0x80545390
CODE @ $80545390
{
	word 6; word 0x80000030 # NOT 0x30
	word 0; word 2
	word 6; word 7
	word 5; IC_Basic 1018
	word 0; word 0
	word 5; IC_Basic 3138
	word 6; word 7
	word 5; IC_Basic 1013
	word 0; word 4
	word 1; scalar 0.945
	word 6; word 7
	word 5; IC_Basic 21001
	word 0; word 0
	word 5; IC_Basic 23038
	word 6; word 7
	word 5; IC_Basic 1013
	word 0; word 4
	word 1; scalar 0.8
	word 2; word PSA_Off+0xA0
	word 2; word PSA_Off+0xD0
	word 0x02010200; word 0x80FAA974
	word 0x02040100; word 0x80FAA984
	word 0x02040200; word PSA_Off
	word 0x02040400; word PSA_Off+0x10
	word 0x02040400; word PSA_Off+0x30
	word 0x00080000; word 0
	word 0x02010200; word 0x80FAA9AC
	word 0x02040100; word 0x80FAA9BC
	word 0x02040200; word PSA_Off
	word 0x02040400; word PSA_Off+0x10
	word 0x02040400; word PSA_Off+0x50
	word 0x02040400; word PSA_Off+0x70
	word 0x00080000; word 0
}
CODE @ $80FC15A8
{
	word 0x00070100; word PSA_Off+0x90
	word 0x00020000; word 0
}
CODE @ $80FC15C8
{
	word 0x00070100; word PSA_Off+0x98
	word 0x00020000; word 0
}

###############################################
Turn and Neutral-B out of SquatReverse [Shanus]
###############################################
.alias PSA_Off = 0x80545498
CODE @ $80545498
{
	word 2; word PSA_Off+0x08
	word 0x02010200; word 0x80FAE92C
	word 0x02010500; word 0x80FAA064
	word 0x02040400; word 0x80FAA08C
	word 0x02010300; word 0x80FA9524
	word 0x02040400; word 0x80FA953C
	word 0x02040400; word 0x80FA955C
	word 0x02040100; word 0x80FA957C
	word 0x00080000; word 0
}
CODE @ $80FAEF1C
{
	word 0x00070100; word PSA_Off
}

##############################################################################
Shield Button while Laying Down goes into Get-up v5.1 [Standardtoaster, Magus]
##############################################################################
.alias PSA_Off = 0x80546E90
CODE @ $80546E90
{
	word 0; word 0x51
	word 6; word 0x4E 
	word 2; word PSA_Off+0x18
	word 0x02010300; word 0x80FB46DC
	word 0x02040100; word 0x80FB46F4
	word 0x02010200; word PSA_Off
	word 0x02040100; word 0x80FB46F4
	word 0x00080000; word 0
}
CODE @ $80FB480C
{
	word 0x00070100; word PSA_Off+0x10
	word 0x00020000; word 0
}

#################################
Monkey Flip DamageFace Fix [ds22]
#################################
.alias PSA_Off = 0x80540478
CODE @ $80540478
{
	word 2; word PSA_Off+0x08
	word 0x0C290000; word 0
	word 0x041A0100; word 0x80FBD634
	word 0x04000100; word 0x80FBD44C
	word 0x00080000; word 0
	word 2; word PSA_Off+0x30
	word 0x0C290000; word 0
	word 0x041A0100; word 0x80FBD634
	word 0x04000100; word 0x80FBD524
	word 0x00080000; word 0
}
CODE @ $80FBD4AC
{
	word 0x00070100; word PSA_Off
}
CODE @ $80FBD594
{
	word 0x00070100; word PSA_Off+0x28
}

########################################################
Shield Button Uses Any Shield Press Requirements [Magus]
########################################################
int 0x4F 		@ $80FAC058
int 0x4F 		@ $80FAC020
int 0x4F 		@ $80FAC770
int 0x4F 		@ $80FAD450
int 0x4F 		@ $80FA9EF8
int 0x4F 		@ $80FA9718
int 0x8000004F 	@ $80FB0DC0
int 0x4E 		@ $80FB24B0
int 0x4E		@ $80FB2480
int 0x4E 		@ $80FB66C8

##################################
Respawn Camera Zoom Refocus [ds22]
##################################
* 06FC3A60 00000008
* 1A070100 80FBF89C

###################################################
Swim Jump uses JumpSquat instead of JumpF [camelot]
###################################################
int 0x14 @ $80FBC518

Shield Endlag is now 15 frames [Shanus]
* 06FB0FFC 00000008
* 00000000 0000000F

DACUS Window Is 2 Frames v2 [standardtoaster]
* 06FB23B4 00000008
* 00000001 0003A980
* 06FB25D4 00000020
* 02000401 80FB24EC
* 00020000 00000000
* 02040400 80FB2514
* 02040100 80FB2534

Remove Dead Frame from Jump [Shanus]
* 06FC18F8 00000010
* 00020000 00000000
* 00020000 00000000

Shield during Dash 3.0 [Yeroc, Wind Owl]
* 06585EC0 00000028
* 00000002 80585ED0
* 00000000 00000006
* 020A0100 80585EC8
* 02000401 80FAC32C
* 00080000 00000000
* 06FAC5D4 00000008
* 00070100 80585EC0

#################################
Dash Dancing v2.3 [Shanus, Magus]
#################################
.alias PSA_Off = 0x805404C8
* 04B88E68 00000002
CODE @ $805404C8
{
	word 6; word 7
	word 5; IC_Basic 1018
	word 0; word 5
	word 1; scalar -0.7
	word 2; word PSA_Off+0x28
	word 0x02000601; word 0x80FAC28C
	word 0x02040400; word 0x80FAC2BC
	word 0x02040400; word 0x80FAC2DC
	word 0x02040400; word PSA_Off
#[Project+] Dash Roll Window is 3 Frames - removed
#	word 0x02000401; word 0x80FAC2FC
#	word 0x02040200; word 0x80FAC31C
#	word 0x02040400; word 0x80FAC26C
	word 0x00080000; word 0

}
CODE @ $80FAC5A4
{
	word 0x00070100; word PSA_Off+0x20
}
* 02FAC5AC 00130002

################################################
No Impact Landing Replaces Light Landing [Magus]
################################################
.alias PSA_Off = 0x80540530
CODE @ $80540530
{
	word 0; word 0x272B
	word 0; word 0
	word 6; word 3
	word 6; word 7
	word 5; IC_Basic 20001
	word 0; word 3
	word 1; scalar 51.0
	word 6; word 7
	word 5; word 0x17
	word 0; word 5
	word 1; scalar -1.0
	word 2; word PSA_Off+0x60
	word 0x02000300; word PSA_Off
	word 0x02040400; word PSA_Off+0x18
	word 0x02040400; word PSA_Off+0x38
	word 0x00080000; word 0
}
CODE @ $80FC1420
{
	word 0x00070100; word PSA_Off+0x58
	word 0x00020000; word 0
}	

##############################################
Wiggle Out of Tumble in Action 45 v1.2 [Magus]
##############################################
.alias PSA_Off = 0x805405B0
CODE @ $805405B0
{
	word 6; word 7
	word 5; LA_Basic 56
	word 0; word 1
	word 1; word 0
	word 6; word 7
	word 5; IC_Basic 20000
	word 0; word 3
	word 1; scalar 169.0
	word 2; word PSA_Off+0x48
	word 0x000A0200; word 0x80FB4194
	word 0x02010500; word 0x80FB41A4
	word 0x02040400; word 0x80FB41CC
	word 0x02040400; word PSA_Off
	word 0x02040200; word 0x80FB420C
	word 0x02040400; word PSA_Off+0x20
	word 0x000F0000; word 0
	word 0x00070100; word 0x80FB3F0C
	word 0x00080000; word 0
}
CODE @ $80FB3F4C
{
	word 0x00070100; word PSA_Off+0x40
}

##############################################################################
Tech Window Fixes, Floor Hit Delay Fix, & Tech in Certain Actions v1.2 [Magus]
##############################################################################
.alias PSA_Off = 0x80540640
CODE @ $80540640
{
	word 2; word PSA_Off+0x08
	word 0x00070100; word 0x80FAB0FC
	word 0x02000300; word 0x80FB4174
	word 0x00080000; word 0
}
* 04FAB000 00005A0C
* 04FAB080 00005A0C
* 04FAB308 00005A0C
* 04FAB180 00005A0C
* 04FAB210 00005A0C
* 04FAB3A8 00005A0C
* 04FAB250 00000C45
* 04FB5790 00000C45
* 04FB5758 00000005
* 04FB57A8 00000005
* 06FB3794 00000028
* 000A0200 80FB36AC
* 00070100 80FB36FC
* 120A0100 80FB3704
* 000F0000 00000000
* 00000000 00000000
CODE @ $80FC29E0
{
	word 0x00070100; word PSA_Off
}
CODE @ $80FB64E4
{
	word 0x00070100; word PSA_Off
}

############################################################
Action Changes Allowed During Hitlag and Edgeteching [Magus]
############################################################
.alias PSA_Off = 0x80540660
* 0483BD78 4800000C
CODE @ $80540660
{
	word 6; word 0x4D
	word 0; word 0x7724
	word 0; word 0x62
	word 6; word 0xC
	word 0; word 6
	word 0; word 0x7727
	word 0; word 0x64
	word 6; word 0xC
	word 0; word 1
	word 2; word PSA_Off+0x68
	word 2; word PSA_Off+0xC0
	word 2; word PSA_Off+0x118
	word 2; word PSA_Off+0x158
	word 0x02000400; word 0x80FAB2CC
	word 0x02040400; word 0x80FAB2EC
	word 0x02040400; word 0x80FAB30C
	word 0x02040100; word 0x80FAB32C
	word 0x02040100; word 0x80FAB334
	word 0x02000400; word PSA_Off+0x08
	word 0x02040400; word 0x80FAB2EC
	word 0x02040400; word 0x80FAB30C
	word 0x02040100; word PSA_Off
	word 0x02040100; word 0x80FAB334
	word 0x00080000; word 0
	
	word 0x02000400; word 0x80FAB36C
	word 0x02040400; word 0x80FAB38C
	word 0x02040400; word 0x80FAB3AC
	word 0x02040100; word 0x80FAB3CC
	word 0x02040100; word 0x80FAB3D4
	word 0x02000400; word PSA_Off+0x28
	word 0x02040400; word 0x80FAB38C
	word 0x02040400; word 0x80FAB3AC
	word 0x02040100; word PSA_Off
	word 0x02040100; word 0x80FAB3D4
	word 0x00080000; word 0
	
	word 0x02000300; word 0x80FAAD74
	word 0x02040200; word 0x80FAAD8C
	word 0x02040400; word 0x80FAAD9C
	word 0x02040400; word 0x80FAADBC
	word 0x02040400; word 0x80FAADDC
	word 0x02040400; word 0x80FAADFC
	word 0x02040100; word 0x80FAB32C
	word 0x00080000; word 0

	word 0x02000300; word 0x80FAAF14
	word 0x02040200; word 0x80FAAF2C
	word 0x02040400; word 0x80FAAF3C
	word 0x02040400; word 0x80FAAF5C
	word 0x02040400; word 0x80FAAF7C
	word 0x02040100; word 0x80FAB32C
	word 0x00080000; word 0
}
CODE @ $80FAB33C
{
	word 0x00070100; word PSA_Off+0x48
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FAB3DC
{
	word 0x00070100; word PSA_Off+0x50
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FAAE4C
{
	word 0x02040100; word 0x80FAB32C
	word 0x00070100; word PSA_Off+0x58
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FAAF9C
{
	word 0x00070100; word PSA_Off+0x60
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0	
}

###################################
Special Fall Depletes Jumps [Magus]
###################################
.alias PSA_Off = 0x805407F0
CODE @ $805407F0
{
	word 5; IC_Basic 23003
	word 5; LA_Basic 1
	word 2; word PSA_Off+0x18
	word 0x04000100; word 0x80FAE664
	word 0x12000200; word PSA_Off
	word 0x00080000; word 0
}
CODE @ $80FC1B88
{
	word 0x00070100; word PSA_Off+0x10
}

###################################################################
Z now triggers aerials instead of air dodge v1.2 [Shanus, Wind Owl]
###################################################################
.alias PSA_Off = 0x80540820
CODE @ $80540820
{
	word 6; word 0x80000030 # NOT 0x30 
	word 0; word 0
	word 0x02000401; word 0x80FAA76C
	word 0x02040100; word 0x80FAA78C
	word 0x02040200; word PSA_Off
	word 0; word 0
}
op word PSA_Off+0x10 @ $80FBFF20

###########################################################################
F-Smash During Dash Window is 4 Frames and 1 in DD [Standardtoaster, Magus]
###########################################################################
.alias PSA_Off  = 0x80540850
.alias PSA_Off2 = 0x805408A0
CODE @ $80540850
{
	word 6; word 7
	word 5; IC_Basic 0
	word 0; word 0
	word 1; scalar 4.0
	word 2; word PSA_Off+0x28
	word 0x02000401; word 0x80FAC11C
	word 0x02040400; word 0x80FAC13C
	word 0x02040200; word 0x80FAC15C
	word 0x02040400; word PSA_Off 
	word 0x00080000; word 0
}
CODE @ $80FAC534
{
	word 0x00070100; word PSA_Off+0x20
	word 0x00020000; word 0
	word 0x00020000; word 0
}

CODE @ $805408A0
{
	word 1; scalar 1.0
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 2
	word 1; scalar 7.0
	word 5; RA_Bit 16
	word 2; word PSA_Off2+0x38
	word 0x04000100; word 0x80FAC42C
	word 0x00010100; word PSA_Off2
	word 0x000A0400; word PSA_Off2+0x08
	word 0x120A0100; word PSA_Off2+0x28
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FAC624
{
	word 0x00070100; word PSA_Off2+0x30
}


################################################################
Shield Break Getup is 30 Frames and Ending Interruptible [Magus]
################################################################
.alias PSA_Off = 0x80540908
CODE @ $80540908
{
	word 1; scalar 1.6667
	word 2; word PSA_Off+0x18
	word 2; word PSA_Off+0x50
	word 0x000A0200; word 0x80FB524C
	word 0x04000100; word 0x80FB525C
	word 0x000E0000; word 0
	word 0x04000100; word 0x80FB5264
	word 0x000F0000; word 0
	word 0x04070100; word PSA_Off
	word 0x00080000; word 0
	word 0x04000100; word 0x80FB5334
	word 0x64000000; word 0
	word 0x00080000; word 0
}
CODE @ $80FB5284
{
	word 0x00070100; word PSA_Off+0x08
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FB5354
{
	word 0x00070100; word PSA_Off+0x10
}

##############################################################
Wakeup from Sleep is Interruptible Frame 10+ [standardtoaster]
##############################################################
.alias PSA_Off = 0x80540970
CODE @ $80540970
{
	word 1; scalar 25.0
	word 2; word PSA_Off+0x10
	word 0x04000100; word 0x80FB54D4
	word 0x00020100; word PSA_Off
	word 0x64000000; word 0
	word 0x00080000; word 0
}
CODE @ $80FB54F4
{
	word 0x00070100; word PSA_Off+0x08
}

##########################################################
Footstool with Only Taunt + Fail Window v1.3 [Magus, ds22]
##########################################################
* 02FC1528 00170002
* 06FC1558 00000010
* 02000301 80FAA8BC
* 02040400 80FAA844
* 06FAA850 00000014
* 10000052 00000000
* 00000004 00000001
* 00124F80 00000000
* 04FAA8D0 00000050
* 04FB62C4 000A0100
* 04FB6240 00000050
* 04FB61D4 000A0100
* 04FB6188 80000051