# 9019F690 -> removed
# 9019F800 -> 80540260
#
# Need to also modify inside each PSA if moved!
# In PSAs, replace 	9019F6E8 with 805402B8
################################################
Moonwalking v1.2 [Magus]
########################
.alias PSA_Off  = 0x80540260
op NOP @ $8086759C

CODE @ $80540260
{
#0x0
	word 6; word 7
	word 5; IC_Basic 1018
	word 0; word 5
	word 1; scalar -0.375
#0x20
	word 6; word 7
	word 5; RA_Basic 8
	word 0; word 4
	word 1; scalar 5.0
#0x40
#if prevAction = 7
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 2
	word 1; scalar 7.0
#set raBasic[8] = 5	
	word 0; word 5
#decrement RA_basic 8
	word 5; RA_Basic 8

	word 2; word PSA_Off+0x78
	word 0x02000601; word 0x80FAC21C
	word 0x02040400; word 0x80FAC24C
	word 0x02040400; word PSA_Off
	word 0x02040400; word PSA_Off+0x20

	word 0x000A0400; word PSA_Off+0x40
	word 0x12000200; word PSA_Off+0x60
	#word 0x000E0000; word 0
	#word 0x12000200; word PSA_Off+0x30
	word 0x000F0000; word 0
	word 0x00080000; word 0
	
	word 0; word 9
	word 2; word PSA_Off+0xC8
	word 0x12030100; word PSA_Off+0x68
	word 0; word 0
}
CODE @ $80FAC594
{
	word 0x00070100; word PSA_Off+0x70
	word 0x0D000200; word PSA_Off+0xB8
}