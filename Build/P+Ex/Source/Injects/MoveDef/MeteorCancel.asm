# 9019CFB0 -> 80540400 Meteor Canceling Below Tumble
#
#####################################
Meteor Canceling Below Tumble [Magus]
#####################################
.alias PSA_Off = 0x80540400
CODE @ $80540400
{
	word 0x00000002; word PSA_Off+0x08
	word 0x02000300; word 0x80FB35AC
	word 0x02040400; word 0x80FB35C4
	word 0x02040100; word 0x80FB35E4
	word 0x02040200; word 0x80FB35EC
	word 0x000A0200; word 0x80FB3E2C
	word 0x00070100; word 0x80FB3E3C
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FB3654
{
	word 0x00070100; word PSA_Off
	word 0x00020000; word 0
	word 0x00020000; word 0
	word 0x00020000; word 0
}

Meteor Cancel Multijump Fix [Magus, standardtoaster]
* 06FB3AF0 0000000C
* 00000000 00000005
* 000059DB 00000000
* 06FB3BB8 0000000C
* 00000000 00000005
* 000059DB 00000000