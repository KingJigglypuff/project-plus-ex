#
# 9019FC00 -> 80540370 Missfoot is FFable, can grab edges, has air control, and goes into tumble or hard landing
# 9019BD50 -> 805403D8 Slide Off Edges During Hard/Light Landing
#################################################
Edge Grabs Disabled During Damage Actions [Magus]
* 04FB3498 00000000

Ledgedrop/Grab Speedup [Yeroc]
* 06FB656C 00000008
* 00000001 00030D44

##############################################################################################################
Missfoot is FFable, can grab edges, has air control, and goes into tumble or hard landing v3.1 [Shanus, Magus]
##############################################################################################################
.alias PSA_Off = 0x80540370

word 0x00020000 @ $80FC2AD0
CODE @ $80540370
{
	word 0; word 0x16
	word 6; word 3
	word 0; word 0
	word 5; LA_Basic 56
	word 0; word 1
	word 0; word 9
	word 0x00000002; word 0x80FAD9DC
	word 0x00000002; word PSA_Off+0x40
	word 0x02010200; word PSA_Off
	word 0x12000200; word PSA_Off+0x10
	word 0x0C090100; word PSA_Off+0x20
	word 0x0D000200; word PSA_Off+0x28
	word 0x00080000; word 0
}
CODE @ $80FC2AF0 # 80F9FC20 + 22ED0
{
	word 0x00070100; word PSA_Off+0x38
}

#######################################################
Slide Off Edges During Hard/Light Landing v1.3 [Shanus]
#######################################################
.alias PSA_Off = 0x805403D8
CODE @ $805403D8
{
	word 0; word 1
	word 0x00000002; word PSA_Off+0x10
	word 0x08000100; word PSA_Off
	word 0x02010200; word 0x80FAF314
	word 0x00080000; word 0
}
CODE @ $80FC1BC0
{
	word 0x00070100; word PSA_Off+0x08
}
CODE @ $80FC1C08
{
	word 0x00070100; word PSA_Off+0x08
}