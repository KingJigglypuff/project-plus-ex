# 
# 9019A6C0 -> 8054C130	Hold Up for Jump Grab Breaks & Held Damage Breaking
# 9019A540 -> 8054C0A8
# 9019C200 -> 8054C060	SFX on Grabbed and Yoshi nB Grabbed
# 9019C230 -> 8054C088
# 901A1200 -> 8054C000 	Action F1 Goes into Idle on ground
###################################################################################
Hold Up for Jump Grab Breaks & Held Damage Breaking v2.2 [Magus]
################################################################
.alias PSA_Off 	= 0x8054C130
.alias PSA_Off2	= 0x8054C0A8
CODE @ $8054C130
{
	word 6; word 7
	word 5; LA_Float 6
	word 0; word 2
	word 1; scalar -5.0
	word 0; word 0x41
	word 6; word 0xFF
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 2
	word 1; scalar 64.0
	word 5; IC_Basic 3023
	word 5; RA_Float 7
	word 1; scalar 6.0
	word 5; RA_Float 7
	word 1; scalar 0.48
	word 5; RA_Float 7
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 0; word 1
	word 1; scalar -2.0
	word 5; RA_Float 7
	
	word 2; word PSA_Off+0xD0
	word 2; word PSA_Off+0xE8
	word 2; word PSA_Off+0x118
	word 2; word PSA_Off+0x140
	
	word 0x00070100; word 0x80FB019C
	word 0x00070100; word 0x80FB0004
	word 0x00080000; word 0
	
	word 0x02010200; word 0x80FB011C
	word 0x02040400; word 0x80FB007C
	word 0x02040400; word PSA_Off
	word 0x02000300; word 0x80FB0364
	word 0x02040400; word PSA_Off
	word 0x00080000; word 0
	
	word 0x000A0400; word 0x80FB007C
	word 0x02010200; word PSA_Off+0x20
	word 0x000F0000; word 0
	word 0x04000100; word 0x80FB05A4
	word 0x00080000; word 0
	
	word 0x000A0400; word PSA_Off+0x30
	word 0x12060200; word PSA_Off+0x50
	word 0x120F0200; word PSA_Off+0x60
	word 0x12070200; word PSA_Off+0x70
	word 0x0E080400; word PSA_Off+0x80
	word 0x0E010200; word PSA_Off+0xA0
	word 0x000F0000; word 0
	word 0x04000100; word 0x80FB06AC
	word 0x00080000; word 0	
}
CODE @ $80FB0174
{
	word 0x02040400; word 0x80FB007C
	word 0x00020000; word 0
	word 0x00020000; word 0
}
op word PSA_Off+0xB0 @ $80FB0018
op word PSA_Off+0xB0 @ $80FB0030

CODE @ $80FB041C
{
	word 0x00070100; word PSA_Off+0xB8
}
CODE @ $80FB060C
{
	word 0x00070100; word PSA_Off+0xC0
}
CODE @ $80FB06CC
{
	word 0x00070100; word PSA_Off+0xC8
}
CODE @ $8054C0A8
{
	word 0; word 9
	word 2; word PSA_Off2+0x60
	word 6; word 7
	word 5; RA_Basic 9
	word 0; word 4
	word 1; scalar 20.0
	word 1; scalar -5.0
	word 5; LA_Float 6
	word 2; word PSA_Off2+0x48
	
	word 0x0D000200; word PSA_Off2
	word 0x00070100; word 0x80FB050C
	word 0x00080000; word 0
	
	word 0x12030100; word PSA_Off2+0x18
	word 0x000A0400; word PSA_Off2+0x10
	word 0x12060200; word PSA_Off2+0x30
	word 0x000F0000; word 0
	word 0; word 0
}
op word PSA_Off2+0x40 @ $80FB0520

#############################################
SFX on Grabbed and Yoshi nB Grabbed [camelot]
#############################################
.alias PSA_Off 	= 0x8054C060
.alias PSA_Off2 = 0x8054C088
CODE @ $8054C060
{
	word 0; word 0x53
	word 2; word PSA_Off+0x10
	
	word 0x12000200; word 0x80FAFE64
	word 0x0A000100; word PSA_Off
	word 0x00080000; word 0
}
CODE @ $80FAFF14
{
	word 0x00070100; word PSA_Off+0x08
}
CODE @ $8054C088
{
	word 2; word PSA_Off2+0x08
	
	word 0x14050100; word 0x80FBE2B4
	word 0x0A000100; word PSA_Off
	word 0x00080000; word 0
}
CODE @ $80FBE37C
{
	word 0x00070100; word PSA_Off2
}

#########################################
Action F1 Goes into Idle on ground [ds22]
#########################################
.alias PSA_Off = 0x8054C000
CODE @ $8054C000
{
	word 2; word PSA_Off+0x38
	word 0; word 0
	word 6; word 1
	word 6; word 3
	word 0; word 0xE
	word 6; word 1
	word 6; word 4
	
	word 0x02010200; word PSA_Off+0x08
	word 0x02040100; word PSA_Off+0x18
	word 0x02010200; word PSA_Off+0x20
	word 0x02040100; word PSA_Off+0x30
	word 0x00080000; word 0
}
CODE @ $80FAFE3C
{
	word 0x00070100; word PSA_Off
}

TurnGrab Doesn't Skip Animation Frames Out of TurnRun [Magus]
* 04FAF6D0 800000FF