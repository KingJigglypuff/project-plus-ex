# Moved Relative to PM
# 9019AD50 -> Common3	Link and Toon Link's Bombs Are now Collidable on Hit v2.0
# 9019AD80 -> Common3	Turnip Hitbox Refreshes on Shield Hit
# 901A1400 -> Common3	Bob-omb timer doesn't run when held
# 9019B500 -> 80545ED8	Naner Tripping is now Techable v4
# 9019CF00 -> 80545F68	Item Throws are FastFallable
# 9019E000 -> Common3	Toon Link Bomb Physics
# 901A1280 -> 80545FA8  WaitItem Subaction Check
##########################################
Naner Tripping is now Techable v4 [Shanus]
##########################################
.alias Item_Off = 0x80545ED8
CODE @ $80545ED8
{
	word 6; word 7
	word 5; IC_Basic 0
	word 0; word 4
	word 1; scalar 20.0
	word 0x00000002; word Item_Off+0x28
	word 0x00070100; word 0x80FB72E4
	word 0x02010200; word 0x80FAAFD4
	word 0x02040400; word 0x80FAAFE4
	word 0x02040400; word 0x80FAB004
	word 0x02040400; word 0x80FAB024
	word 0x02040400; word Item_Off
	word 0x02010200; word 0x80FAB054
	word 0x02040400; word 0x80FAB064
	word 0x02040400; word 0x80FAB084
	word 0x02040400; word Item_Off
	word 0x00080000; word 0
}
CODE @ $80FB72F4
{
	word 0x00070100; word Item_Off+0x20
}
CODE @ $80FB735C
{
	word 0x00070100; word Item_Off+0x20
}
####################################
Item Throws are FastFallable [Magus]
####################################
.alias Item_Off = 0x80545F68
CODE @ $80545F68
{
	word 0; word 9
	word 0x00000002; word 0x80FAD9DC
	word 0x00000002; word Item_Off+0x18
	word 0x07020000; word 0
	word 0x0D000200; word Item_Off
	word 0x00080000; word 0
}
CODE @ $80FC3060
{
	word 0x00070100; word Item_Off+0x10
}

###############################
WaitItem Subaction Check [ds22]
###############################
.alias PSA_Off = 0x80545FA8
CODE @ $80545FA8
{
	word 0x00000002; word PSA_Off+0x18
	word 6; word 0x2C
	word 0; word 5
	word 0x04020200; word 0x80FAB76C
	word 0x04020100; word 0x80FAB77C
	word 0x00080000; word 0
}
CODE @ $80FAB8D4
{
	word 0x00070100; word PSA_Off
	word 0x000D0100; word 0x80FAB784
	word 0x000B0200; word PSA_Off+0x08
}

Disable item pickup from a dash attack [Shanus]
* 06FB240C 00000008
* 00020000 00000000

Trophy Throws are Smash Throws [Standardtoaster]
* 04FB8980 00000105
* 04FB8990 0000010E
* 04FB89C0 00000106
* 04FB89D0 0000010F
* 04FB8A50 00000103
* 04FB8A60 0000010C
* 04FB8A70 00000104
* 04FB8A80 0000010D
* 04FB8B88 0000010C
* 04FB8B98 00000103
* 04FB8BD0 0000010C
* 04FB8BE0 00000103
* 04FB8BF0 0000010D
* 04FB8C00 00000104
* 04FB8C40 0000010E
* 04FB8C50 00000105
* 04FB8C60 0000010F
* 04FB8C70 00000106
* 04FB9830 00000107