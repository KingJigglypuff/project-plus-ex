# 901A1350 -> 80545CA0 Tether Aiming Stores Jump Count
# 9019C800 -> 80545CD0 Occupied Edge Tether Hopping v1.4.1
# 9019C850 -> 80545D10
# 9019C900 -> 80545DA0 
# 9019C980 -> 80545E20
# 9019A340 -> 80545E88 Zair Goes into Special Fall and Wavedash endlag v5.3
# 9019AE20 -> 80544000 Aerial Glide Toss & Air Dodge -> Zair Momentum Decay
#################################################
Tether Aiming Stores Jump Count [standardtoaster]
#################################################
.alias PSA_Off = 0x80545CA0
CODE @ $80545CA0
{
	word 5; LA_Basic 1
	word 5; LA_Basic 80
	word 0x00000002; word PSA_Off+0x18
	word 0x12000200; word PSA_Off
	word 0x02010200; word 0x80FB6F5C
	word 0x00080000; word 0
}
CODE @ $80FC2BA0
{
	word 0x00070100; word PSA_Off+0x10
}

##################################################
Occupied Edge Tether Hopping v1.4.1 [Magus, Yeroc]
##################################################
.alias PSA_Off  = 0x80545CD0
.alias PSA_Off2 = 0x80545D10
.alias PSA_Off3 = 0x80545DA0
.alias PSA_Off4 = 0x80545E20
CODE @ $80545CD0
{
	word 1; scalar 1.0
	word 1; word 0
	word 5; LA_Float 7
	word 0x00000002; word PSA_Off+0x20
	word 0x04000100; word 0x80FB6724
	word 0x00010100; word PSA_Off
	word 0x12060200; word PSA_Off+0x08
	word 0x00080000; word 0
}
CODE @ $80FB67C4
{
	word 0x00070100; word PSA_Off+0x18
}

CODE @ $80545D10
{
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 2
	word 1; scalar 117.0
	word 6; word 7
	word 5; LA_Float 7
	word 0; word 2
	word 1; scalar -3.0
	word 0; word 0x7A
	word 6; word 0xFF
	word 0x00000002; word PSA_Off2+0x58
	word 0x000A0400; word PSA_Off2
	word 0x000B0400; word PSA_Off2+0x20
	word 0x12060200; word PSA_Off+0x08
	word 0x02010200; word PSA_Off2+0x40
	word 0x000F0000; word 0
	word 0x00070100; word 0x80FAE60C
	word 0x00080000; word 0
}
CODE @ $80FC1B40
{
	word 0x00070100; word PSA_Off2+0x50
}

CODE @ $80545DA0
{
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 2
	word 1; scalar 14.0
	word 0; word 0x19
	word 6; word 3
	word 1; scalar 30.0
	word 5; LA_Float 0
	word 0x00000002; word PSA_Off3+0x48
	word 0x000A0400; word PSA_Off3
	word 0x02010200; word PSA_Off3+0x20
	word 0x12060200; word PSA_Off3+0x30
	word 0x000E0000; word 0
	word 0x00070100; word 0x80FB6BA4
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FB6C24
{
	word 0x00070100; word PSA_Off3+0x40
}

CODE @ $80545E20
{
	word 0; word 0xE0
	word 5; LA_Basic 80
	word 5; LA_Basic 1
	word 0; word 0x3C
	word 5; RA_Basic 1
	word 0x00000002; word PSA_Off4+0x30
	word 0x0D000200; word 0x80FB6C0C
	word 0x000A0400; word PSA_Off3
	word 0x04000100; word PSA_Off4
	word 0x12000200; word PSA_Off4+0x08
	word 0x12000200; word PSA_Off4+0x18
	word 0x000F0000; word 0
	word 0x00080000; word 0
}
CODE @ $80FB6C7C
{
	word 0x00070100; word PSA_Off4+0x28
}
#############################################################
Zair Goes into Special Fall and Wavedash endlag v5.3 [Shanus]
#############################################################
.alias PSA_Off = 0x80545E88
.alias AGT_Off = 0x80544000 # SYNC WITH CODE BELOW!!!
CODE @ $80545E88
{
	word 0; word 0x19
	word 6; word 3
	word 0; word 0x10
	word 6; word 1
	word 0x00000002; word PSA_Off+0x28
	word 0x00070100; word AGT_Off+0xB0
	word 0x02010200; word PSA_Off
	word 0x02010200; word PSA_Off+0x10
	word 0x00080000; word 0
}
CODE @ $80FC2B10
{
	word 0x00070100; word PSA_Off+0x20
	word 0x00020000; word 0
}
CODE @ $80FC2CF0
{
	word 0x00070100; word PSA_Off+0x20
	word 0x00020000; word 0
}

###################################################################################
Aerial Glide Toss & Air Dodge -> Zair Momentum Decay v5.2 [Shanus, standardtoaster]
###################################################################################
.alias AGT_Off = 0x80544000 # SYNC WITH CODE ABOVE!!!
CODE @ $80544000
{
	word 6; word 7
	word 5; IC_Basic 20003
	word 0; word 2
	word 1; scalar 33.0
	word 5; word 0x17
	word 5; RA_Float 9
	word 0; word -1
	word 6; word 7
	word 5; RA_Basic 7
	word 0; word 2
	word 5; LA_Basic 81
	word 1; scalar 0.9
	word 5; RA_Float 9
	word 5; RA_Float 7
	word 5; LA_Float 81
	word 5; IC_Basic 28
	word 5; RA_Float 7
	word 1; scalar -0.75
	word 5; RA_Float 7
	word 5; LA_Bit 57
	word 5; RA_Float 7
	word 5; RA_Float 9
	word 0x00000002; word AGT_Off+0x128
	word 0x00000002; word AGT_Off+0xC0
	word 0x12060200; word 0x80FB9654
	word 0x000A0400; word AGT_Off
	word 0x12030100; word AGT_Off+0x70
	word 0x12060200; word AGT_Off+0x20
	word 0x00040100; word AGT_Off+0x30
	word 0x000A0400; word AGT_Off+0x38
	word 0x00060000; word 0
	word 0x000F0000; word 0
	word 0x120F0200; word AGT_Off+0x58
	word 0x12030100; word AGT_Off+0x68
	word 0x00050000; word 0
	word 0x12080200; word AGT_Off+0x20
	word 0x000F0000; word 0
	word 0x000A0400; word AGT_Off
	word 0x12060200; word AGT_Off+0x78
	word 0x120F0200; word AGT_Off+0x88
	word 0x120A0100; word AGT_Off+0x98
	word 0x0E010200; word AGT_Off+0xA0
	word 0x120B0100; word AGT_Off+0x98
	word 0x000F0000; word 0
	word 0; word 0
}


CODE @ $80FC2FB8 # 80F9FC20 + 23398
{
	word 0x00070100; word AGT_Off+0xB8
}

##########################################
Disable Tether Canceling [standardtoaster]
##########################################
* 04FC2C70 00020000
* 04FC2C78 00020000