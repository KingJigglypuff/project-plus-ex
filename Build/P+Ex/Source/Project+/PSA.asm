# 9019A850 -> 80540EB0	Can't ASDI offstage while buried + Animation Fix 
# 901A2998 -> 80540EE0	C-stick Functions Correctly During Crawl
# 901A29E8 -> 80540F20	Platdrop Momentum Forced through Knockback 
# 901A2A28 -> 80540F50	Shielddrop Same Frame as Hardshield doesnt waveland 
# 901A11C8 -> 80540FA8	Characters can Die while in Inhale 
# 901A1198 -> 80540FD0	RCO Airspeed Fix
# 901A1150 -> 80540FF8  Shield Button while Tripped goes into Get-up

#################################################################
[Project+] Can't ASDI offstage while buried + Animation Fix [Eon]
#################################################################
.alias PSA_Off = 0x80540EB0
CODE @ $80540EB0
{
	word 0x00000002; word PSA_Off+0x18
	word 0; word 2;
	word 1; scalar 0.0
	word 0x08000100; word PSA_Off+0x08
	word 0x04070100; word PSA_Off+0x10
	word 0x00080000; word 0;
}
CODE @ $80FBCBF4
{
	word 0x00070100; word PSA_Off
}

#############################################################
[Project+] C-stick Functions Correctly During Crawl 2.1 [Eon]
#############################################################
.alias PSA_Off = 0x80540EE0
CODE @ $80FAECFC
{
	word 0x00070100; word PSA_Off
}
CODE @ $80FAEE9C
{
	word 0x00070100; word PSA_Off
}
CODE @ $80540EE0
{
	word 0x00000002; word PSA_Off+0x28
	word 6; word 7
	word 5; IC_Basic 1018
	word 0; word 1
	word 5; IC_Basic 3133
	word 0x02040100; word 0x80FAEC5C
	word 0x02040400; word PSA_Off+0x08
	word 0x00080000; word 0
}

###########################################################
[Project+] Platdrop Momentum Forced through Knockback [Eon]
###########################################################
.alias PSA_Off = 0x80540F20
CODE @ $80FAB434
{
	word 0x00070100; word PSA_Off
}
CODE @ $80540F20
{
	word 0x00000002; word PSA_Off+0x10
	word 5; LA_Bit 57
	word 0x120A0100; word PSA_Off+0x08
	word 0x0E010200; word 0x80FAB40C
	word 0x120B0100; word PSA_Off+0x08
	word 0x00080000; word 0
}

####################################################################
[Project+] Shielddrop Same Frame as Hardshield doesnt waveland [Eon] 
####################################################################
.alias PSA_Off = 0x80540F50
CODE @ $80FB1964
{
	word 0x00070100; word PSA_Off
}
CODE @ $80540F50
{
	word 0x00000002; word PSA_Off+0x28
	word 6; word 7
	word 5; IC_Basic 0
	word 0; word 4
	word 1; scalar 1.0
	word 0x0D000200; word 0x80FB1934
	word 0x020B0100; word 0x80FADC74
	word 0x04020400; word PSA_Off+0x08
	word 0x01010000; word 0
	word 0x020A0100; word 0x80FADC74
	word 0x00080000; word 0
}

###################################################
[Project+] Characters can Die while in Inhale [Eon]
###################################################
.alias PSA_Off = 0x80540FA8
CODE @ $80540FA8
{
	word 5; LA_Bit 1
	word 0x00000002; word PSA_Off+0x10
	word 0x14050100; word 0x80FBD2F4
	word 0x120B0100; word PSA_Off
	word 0x00080000; word 0
}
CODE @ $80FBD314
{
	word 0x00070100; word PSA_Off+0x08
}
CODE @ $80FBD35C
{
	word 0x00070100; word PSA_Off+0x08
}

######################################
[Project+] RCO Airspeed Fix v1.2 [Eon]
######################################
.alias PSA_Off = 0x80540FD0
CODE @ $80540FD0
{
	word 1; scalar 1.0
	word 5; LA_Float 1
	word 0x00000002; word PSA_Off+0x18
	word 0x12060200; word PSA_Off
	word 0; word 0
}
CODE @ $80FC1CD8
{
	word 0x00090100; word PSA_Off+0x10
}
CODE @ $80FC2AC8
{
	word 0x00090100; word PSA_Off+0x10
}
CODE @ $80FB3694
{
	word 0x00090100; word PSA_Off+0x10
}
CODE @ $80FB3F74
{
	word 0x00090100; word PSA_Off+0x10
}

#####################################################################################
[Project+] Shield Button while Tripped goes into Get-up [Standardtoaster, Magus, Eon]
#####################################################################################
.alias PSA_Off = 0x80540FF8
CODE @ $80540FF8
{
	word 0; word 0x8E
	word 6; word 0x4E
	word 0x00000002; word PSA_Off+0x18
	word 0x02010500; word 0x80FB750C
	word 0x02040100; word 0x80FB7504
	word 0x02010200; word PSA_Off
	word 0x02040100; word 0x80FB7504
	word 0x00080000; word 0
}
CODE @ $80FB75CC
{
	word 0x00070100; word PSA_Off+0x10
	word 0x00020000; word 0
}

####################################################
[Project+] All momentum removed upon ledgegrab [Eon]
####################################################
.alias PSA_Off = 0x80541040
CODE @ $80541040
{
	word 2; word PSA_Off+0x20
	word 5; LA_Bit 57
	word 1; word 0;
	word 1; word 0;
	word 0x02010200; word 0x80FB65A4
	word 0x120A0100; word PSA_Off+0x8
	word 0x0E080200; word PSA_Off+0x10
	word 0x120B0100; word PSA_Off+0x8
	word 0x00080000; word 0
}
CODE @ $80FC2AC0 
{
	word 0x00070100; word PSA_Off
}

#######################################################
[Project+] Doublejump doesnt reset stick position [Eon]
#######################################################
word 0x00020000 @ $80FC19F0

#########################################################################
![Project+] Jump Lockout for Doublejump Doesnt Reset Stick Position [Eon]
#########################################################################
#Disabled since it breaks Peach/Mewtwo instant float. 
#Breaks Chars with multiple normal doublejump's, which is only Warioman in vPM. See Action override C in warioman for how to do this code in psa 
.alias PSA_Off = 0x80541200
CODE @ $80541200
{
	word 2; word PSA_Off+0x18
	word 0; word 0x12
	word 1; scalar 1.0
	word 0x0D000200; word 0x80FADF34 	#original command 
	word 0x020B0100; word PSA_Off+0x8 	#prevent specific interupt jump 
	word 0x00010100; word PSA_Off+0x10  #wait one frame 
	word 0x020A0100; word PSA_Off+0x8  	#allow specific interupt jump
}
CODE @ $80FC1A88
{
	word 0x00070100; word PSA_Off
}

##################################################################
[Project+] Aerial During knockback doesn't cause missed tech [Eon]
##################################################################
CODE @ $80fc27d0
{
    word 0x00020000; word 0
    word 0x00020000; word 0
}


#following codes all based on removal of Animation Engine
CaptureJump FSM in PSA [Eon]
.alias PSA_Off 	= 0x8054C2D0
CODE @ $8054C2D0
{
	word 2; word PSA_Off+0x10
	word 1; scalar 1.66666
	
	word 0x04070200; word PSA_Off+0x8 #multiply frame speed by 1.6666
	word 0x00000000; word 0
}
CODE @ $80FB06D4
{
	word 0x00090100; word PSA_Off 
}
PassiveCeil FSM in PSA [Eon]
.alias PSA_Off 	= 0x8054C2F0
CODE @ $8054C2F0
{
	word 2; word PSA_Off+0x10
	word 1; scalar 1.3
	
	word 0x04070200; word PSA_Off+0x8 #multiply frame speed by 1.6666
	word 0x00000000; word 0
}
CODE @ $80FB599C
{
	word 0x00090100; word PSA_Off 
}
SmashSwingItemWindup FSM in PSA [Eon]
.alias PSA_Off 	= 0x8054C310
CODE @ $8054C310
{
	word 2; word PSA_Off+0x10
	word 1; scalar 1.4137932
	
	word 0x04070200; word PSA_Off+0x8 #multiply frame speed by 1.6666
	word 0x00000000; word 0
}
CODE @ $80FC2E50
{
	word 0x00090100; word PSA_Off 
}
Unknown Special Jump FSM in PSA [Eon]
.alias PSA_Off 	= 0x8054C330
CODE @ $8054C330
{
	word 2; word PSA_Off+0x10
	word 1; scalar 1.5
	
	word 0x04070200; word PSA_Off+0x8 #multiply frame speed by 1.6666
	word 0x00000000; word 0
}
CODE @ $80FBCDD4
{
	word 0x00090100; word PSA_Off 
}

Tether fail passes frame but dont pass FSM [Eon]
.alias PSA_Off 	= 0x8054C360
CODE @ $80FC2D10
{
	word 0x04000300; word PSA_Off
}
CODE @ $8054C360
{
	word 5; RA_Basic 2
	word 3; word 1
	word 1; scalar 1.0
}