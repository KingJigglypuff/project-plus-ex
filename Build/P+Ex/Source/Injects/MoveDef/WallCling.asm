# 9019BE50 -> 80540448
#
############################################################################
WallCling Can now enter Fall from Neutral Joystick [Shanus, Standardtoaster]
############################################################################
.alias PSA_Off = 0x80540448
CODE @ $80540448
{
	word 0x00000002; word PSA_Off+0x08
	word 0x02010200; word 0x80FB5CAC
	word 0x02010200; word 0x80FAF5EC
	word 0x02040400; word 0x80FB2E7C
	word 0x02040400; word 0x80FB2E9C
	word 0x00080000; word 0
}
CODE @ $80FB603C
{
	word 0x00070100; word PSA_Off
}

Wallcling Jump Is Walljump and up Does Nothing [standardtoaster]
* 04FB5F68 00000067
* 04FB606C 00020000