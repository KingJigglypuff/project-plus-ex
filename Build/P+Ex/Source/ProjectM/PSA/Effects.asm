# 9019DA00 -> 805409A0 Fire Effects Mod, Intensity Based On KB, & Hitlag Overlay Fix
# 9019DAA8 -> 80540A28
# 9019DBA0 -> 80540B18 Electric Effects Mod, Intensity Based On KB, & Hitlag Overlay Fix
# 9019DC20 -> 80540B90 Darkness Effects Mod, Intensity Based On KB, & Hitlag Overlay Fix 
# 9019DCC8 -> 80540C10
# 9019D660 -> 80540CA0 Aura Effects Mod, Intensity Based On KB, & Hitlag Overlay Fix
# 901B2110 -> 80540D30 Luigi Fire is Green
# 9019E0B0 -> 80540E10 Warioman Fart Overlay is Purple
######################################################
Generic Overlay Fix [camelot]
#############################
* 06FA16A4 00000008
* 21010400 80FA1534

############################################################################
Fire Effects Mod, Intensity Based On KB, & Hitlag Overlay Fix v1.5 [camelot]
############################################################################
.alias PSA_Off  = 0x805409A0
.alias PSA_Off2 = 0x80540A28
* 04FA1788 00000050
* 04FA17E0 00000050
* 04FA17E8 00000019
* 04FA17F8 0000008C
* 04FA1898 00000003
* 04FA1928 00000003
* 04FA1980 00000006
* 04FA1A10 00000006
* 04FA1A60 0000000C
* 04FA1AF0 0000000D
* 04FA1B40 00000012
* 04FA1BD0 00000014

CODE @ $805409A0
{
	word 0; word 0x40
	word 0; word -2
	word 1; scalar 0.0
	word 1; scalar 2.0
	word 1; scalar 0.0
	word 1; scalar 270.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.4
	word 1; scalar 5.0
	word 1; scalar 5.0
	word 1; scalar 5.0
	word 1; scalar 0.0
	word 1; scalar 360.0
	word 1; scalar 0.0
	word 3; word 0
	word 0; word 0xAF
}
CODE @ $80FA179C
{
	word 0x21010400; word 0x80FA173C
	word 0x00010100; word 0x80FA175C
	word 0x21010400; word 0x80FA176C
	word 0x00010100; word 0x80FA175C
	word 0x00020000; word 0
	word 0x00020000; word 0
}
CODE @ $80FA1854
{
	word 0x0A000100; word PSA_Off+0x80
	word 0x11001000; word PSA_Off
	word 0x21010400; word 0x80FA17DC
	word 0x00010100; word 0x80FA17FC
	word 0x00020000; word 0
	word 0x21010400; word 0x80FA1804
	word 0x00010100; word 0x80FA17FC
}

CODE @ $80540A28
{
	word 6; word 7
	word 5; word 0x26
	word 0; word 4
	word 1; scalar 120.0
	word 6; word 7
	word 5; word 0x26
	word 0; word 4
	word 1; scalar 80.0
	word 6; word 7
	word 5; word 0x26
	word 0; word 4
	word 1; scalar 40.0
	word 0x00000002; word 0x80FA1BDC
	word 0x00000002; word 0x80FA1AFC
	word 0x00000002; word 0x80FA1A1C
	word 0x00000002; word PSA_Off2+0x80
	word 0x000A0400; word PSA_Off2
	
	word 0x00090100; word PSA_Off2+0x60
	word 0x000D0400; word PSA_Off2+0x20
	word 0x00090100; word PSA_Off2+0x68
	word 0x000D0400; word PSA_Off2+0x40
	word 0x00090100; word PSA_Off2+0x70
	word 0x000F0000; word 0
	
	word 0x00040100; word 0x80FA1894
	word 0x11001000; word 0x80FA189C
	word 0x00070100; word 0x80FA191C
	word 0x00050000; word 0
	
	word 0x00040100; word 0x80FA1924
	word 0x00070100; word 0x80FA192C
	word 0x00050000; word 0
}
CODE @ $80FA1934
{
	word 0x00070100; word PSA_Off2+0x78
}
################################################################################
Electric Effects Mod, Intensity Based On KB, & Hitlag Overlay Fix v1.4 [camelot]
################################################################################
.alias PSA_Off  = 0x80540B18
.alias PSA_Off2 = 0x80540A28  # MUST MATCH PSA_OFF2 IN FIRE CODE, ABOVE!!!

* 04FA1C68 00000064
* 04FA1CC0 00000004
* 04FA1D78 00000008
* 04FA1E30 0000000D
* 04FA1EE8 00000012

CODE @ $80540B18
{
	word 0x00000002; word 0x80FA1F74
	word 0x00000002; word 0x80FA1EBC
	word 0x00000002; word 0x80FA1E04
	word 0x00000002; word PSA_Off+0x20
	word 0x000A0400; word PSA_Off2
	word 0x00090100; word PSA_Off
	word 0x000D0400; word PSA_Off2+0x20
	word 0x00090100; word PSA_Off+0x08
	word 0x000D0400; word PSA_Off2+0x40
	word 0x00090100; word PSA_Off+0x10
	word 0x000F0000; word 0
	
	word 0x00040100; word 0x80FA1CBC
	word 0x11001000; word 0x80FA1CC4
	word 0x00070100; word 0x80FA1D44
	word 0x00050000; word 0
}
CODE @ $80FA1D4C
{
	word 0x00090100; word PSA_Off+0x18
}
CODE @ $80FA1C7C
{
	word 0x0A000100; word 0x80FAB64C
	word 0x00040100; word 0x80FB274C
	word 0x21010400; word 0x80FA1C1C
	word 0x00010100; word 0x80FA1C3C
	word 0x21010400; word 0x80FA1C4C
	word 0x00010100; word 0x80FA1C3C
	word 0x00050000; word 0
}

################################################################################
Darkness Effects Mod, Intensity Based On KB, & Hitlag Overlay Fix v1.4 [camelot]
################################################################################
.alias PSA_Off  = 0x80540B90
.alias PSA_Off2 = 0x80540A28  # MUST MATCH PSA_OFF2 IN FIRE CODE, ABOVE!!!
.alias PSA_Off3 = 0x80540C10
.alias PSA_Off4 = 0x805409A0  # MUST MATCH PSA_OFF IN FIRE CODE, ABOVE!!!
* 04FA1FB8 0000008C
* 04FA1FE8 0000008C
* 04FA2058 0000008C
* 04FA2080 000000AA
* 04FA20D8 00000003
* 04FA2168 00000003
* 04FA21B8 00000006
* 04FA2248 00000006
* 04FA2298 0000000C
* 04FA2328 0000000D
* 04FA2378 00000012
* 04FA2408 00000014
* 04FA20E0 00000061
* 04FA21C0 00000061
* 04FA22A0 00000061
* 04FA2380 00000061

CODE @ $80540B90
{
	word 0; word 0x11
	word 0; word -2
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.7
	
	word 1; scalar 4.0
	word 1; scalar 4.0
	word 1; scalar 4.0
	
	word 1; scalar 360.0
	word 1; scalar 360.0
	word 1; scalar 360.0
	word 3; word 0
}
CODE @ $80FA1FFC
{
	word 0x21010400; word 0x80FA1F9C
	word 0x00010100; word 0x80FA205C
	word 0x21010400; word 0x80FA1FCC
	word 0x00010100; word 0x80FA1FBC
	word 0x00020000; word 0
}
CODE @ $80FA2094
{
	word 0x11001000; word PSA_Off4
	word 0x21010400; word 0x80FA203C
	word 0x00010100; word 0x80FA205C
	word 0x11001000; word PSA_Off
	word 0x21010400; word 0x80FA2064
	word 0x00010100; word 0x80FA205C
}

CODE @ $80540C10
{
	word 0x00000002; word 0x80FA2414
	word 0x00000002; word 0x80FA2334
	word 0x00000002; word 0x80FA2254
	word 0x00000002; word PSA_Off3+0x20
	word 0x000A0400; word PSA_Off2
	word 0x00090100; word PSA_Off3
	word 0x000D0400; word PSA_Off2+0x20
	word 0x00090100; word PSA_Off3+0x08
	word 0x000D0400; word PSA_Off2+0x40
	word 0x00090100; word PSA_Off3+0x10
	word 0x000F0000; word 0
	
	word 0x00040100; word 0x80FA20D4
	word 0x11001000; word 0x80FA20DC
	word 0x00070100; word 0x80FA215C
	word 0x00050000; word 0
	
	word 0x00040100; word 0x80FA2164
	word 0x00070100; word 0x80FA216C
	word 0x00050000; word 0
}
CODE @ $80FA2174
{
	word 0x00090100; word PSA_Off3+0x18
}

############################################################################
Aura Effects Mod, Intensity Based On KB, & Hitlag Overlay Fix v1.4 [camelot]
############################################################################
.alias PSA_Off  = 0x80540CA0
.alias PSA_Off2 = 0x80540A28  # MUST MATCH PSA_OFF2 IN FIRE CODE, ABOVE!!!
* 04FA2478 0001D4C0
* 04FA24A8 0001D4C0
* 04FA24B0 00000000
* 04FA2518 0001D4C0
* 04FA2540 0000EA60
* 04FA2548 0000EA60
* 04FA2470 0000002D
* 04FA24A0 00000028
* 04FA2510 0000001E
* 04FA2538 0000001E
* 04FA2590 00000003
* 04FA2620 00000001
* 04FA2670 00000006
* 04FA2700 00000002
* 04FA2750 0000000C
* 04FA27E0 00000004
* 04FA2830 00000012
* 04FA28C0 00000006
* 04FA25D8 00008CA0
* 04FA26B8 00008CA0
* 04FA2798 00008CA0
* 04FA2878 00008CA0

CODE @ $80540CA0
{
	word 0x00000002; word 0x80FA28CC
	word 0x00000002; word 0x80FA27EC
	word 0x00000002; word 0x80FA270C
	word 0x00000002; word PSA_Off+0x20
	word 0x000A0400; word PSA_Off2
	word 0x00090100; word PSA_Off
	word 0x000D0400; word PSA_Off2+0x20
	word 0x00090100; word PSA_Off+0x08
	word 0x000D0400; word PSA_Off2+0x40
	word 0x00090100; word PSA_Off+0x10
	word 0x000F0000; word 0
	
	word 0x00040100; word 0x80FA258C
	word 0x11001000; word 0x80FA2594
	word 0x00070100; word 0x80FA2614
	word 0x00050000; word 0
	
	word 0x00040100; word 0x80FA261C
	word 0x00070100; word 0x80FA2624
	word 0x00050000; word 0
}
CODE @ $80FA262C
{
	word 0x00090100; word PSA_Off+0x18
}
CODE @ $80FA24C4
{
	word 0x21010400; word 0x80FA2484
}

Fire, Electric, Darkness, and Aura Use Intensity 1 [Magus]
* 06FA6340 00000040
* 80FA1934 80FA1934
* 80FA1934 80FA1934
* 80FA1D4C 80FA1D4C
* 80FA1D4C 80FA1D4C
* 80FA2174 80FA2174
* 80FA2174 80FA2174
* 80FA262C 80FA262C
* 80FA262C 80FA262C

Trace Eff-ID Modifiers [ds22]
int 0x20 @ $80407324 

#####################################
Luigi Fire is Green V1.2 (2/2) [ds22]
#####################################
.alias PSA_Off = 0x80540D30
CODE @ $80540D30
{
	word 0; word 0x10
	word 0; word 0x90007
	word 0; word -2
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 1.0
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 1; scalar 0.0
	word 3; word 0
	
	word 0x00000002; word 0x80FA179C
	word 0; word 8
	word 0x00000002; word 0x80FA1854
	word 0x00040100; word PSA_Off
	word 0x11001000; word PSA_Off+0x08
	word 0x00070100; word PSA_Off+0x88
	word 0x00050000; word 0
	word 0x00040100; word PSA_Off+0x90
	word 0x00070100; word PSA_Off+0x98
	word 0x00050000; word 0
	word 0x00080000; word 0
}
op word PSA_Off+0xA0 @ $80FA581C
op word PSA_Off+0xA0 @ $80FA6380

#############################################
Warioman Fart Overlay is Purple [ds22, Magus]
#############################################
.alias PSA_Off = 0x80540E10
CODE @ $80540E10
{
	word 0x000A0200; word PSA_Off+0x30
	word 0x21020500; word PSA_Off+0x40
	word 0x000E0000; word 0
	word 0x21020500; word 0x80FA3394
	word 0x000F0000; word 0
	word 0x00080000; word 0
	word 6; word 8
	word 5; LA_Bit 122
	word 0; word 8
	word 0; word 0x60
	word 0; word 0
	word 0; word 0xA0
	word 0; word 0x60
	word 0x00000002; word PSA_Off
}
CODE @ $80FA340C
{
	word 0x00070100; word PSA_Off+0x68
}