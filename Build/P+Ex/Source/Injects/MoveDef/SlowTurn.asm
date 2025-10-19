# 9019FB40 -> 80540168
# 9019FD00 -> 805401F8
#############################################################
Slow Turn is Able to Trigger a Fast Turn on 2nd Frame [Magus]
#############################################################
.alias PSA_Off = 0x80540168
CODE @ $80540168
{
	word 1; scalar 0.5
	word 6; word 7
	word 5; IC_Basic 1011
	word 0; word 4
	word 1; scalar 0.475
	word 1; scalar 0.0
	word 5; RA_Float 5
	word 0x00000002; word PSA_Off+0x40
	word 0x02000401; word 0x80FAD1A4
	word 0x02040200; word 0x80FAD1C4
	word 0x02040400; word 0x80FAD1D4
	word 0x02040100; word 0x80FAD1F4
	word 0x00010100; word PSA_Off
	word 0x000A0400; word PSA_Off+0x08
	word 0x000B0400; word 0x80FAC2BC
	word 0x12060200; word PSA_Off+0x28
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FAD204 # 80F9FC20 + D5E4
{
	word 0x00070100; word PSA_Off+0x38
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}

###################################################
Slow Turn Timer Used for JumpSquat and Fall [Magus]
###################################################
.alias PSA_Off = 0x805401F8
CODE @ $805401F8
{
	word 6; word 7
	word 5; IC_Basic 20001
	word 0; word 2
	word 1; scalar 14.0
	word 6; word 0x3A
	word 0x00000002; word PSA_Off+0x30
	word 0x000A0400; word PSA_Off
	word 0x000B0100; word PSA_Off+0x20
	word 0x000C0400; word 0x80FAD30C
	word 0x05000000; word 0
	word 0x05040000; word 0
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FAD35C
{
	word 0x00070100; word PSA_Off+0x28
}
* 02FAD364 000B0002