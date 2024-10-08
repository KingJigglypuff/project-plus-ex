#############################################################################
VBI -> AXNextFrame During Boot v1.0 [Sammi-Husky]
#############################################################################
* 20497ED0 00000000 # if not past strap screen
* 201E9A2C 4BE17E7C # if VBI

op b -0x1FF0DC @ $80200984
op blr @ $801E9A2C

* E2000002 80008000
* 20497ED0 00000001 # if past strap screen
* 20200984 4BE00F24 # if AXNextFrame

op b -0x1E8184    @ $801E9A2C
op blr	 	  @ $80200984
PULSE
{
	lis r3,0x8020
	ori r3,r3,0x0984
	icbi r0,r3
	lis r3,0x801E
	ori r3,r3,0x9A2C
	icbi r0,r3
	isync
	blr
}
    
*E0000000 80008000