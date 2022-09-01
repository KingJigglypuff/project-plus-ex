
##########################################
Multi Attack Sequence Input System [Magus, Eon] #does not need to exist
##########################################
#original psa as follows : 
#E=120B0100:5-22000022,E=120B0100:5-22000002,E=00040100:0-FFFFFFFF,E=000A0100:6-00000014,E=000B0200:6-80000032,0-00000000,E=120A0100:5-22000022,E=000F0000:E=000A0200:6-00000032,0-00000000,E=000B0200:6-00000008,5-22000022,E=120A0100:5-22000002,E=000F0000:E=000A0200:6-00000030,0-00000000,E=000B0200:6-80000030,0-0000000F,E=120A0100:5-22000002,E=000F0000:E=00010100:1-00001770,E=00050000:
#copy paste above line into psa-c if you have a two part smash or tilt that you want to change to the system
#multi attack system was offset 0x80546270 or offset 9019FA90

###################################
Jab Input System (originally at 9019D080) 2.0 [Magus, Eon]
###################################
#pointer to this no longer needed within files.

#on enterring hitlag
HOOK @ $8083FC2C
{    
    #getStatusKind()
    lwz r3, 0xD8(r31)
    lwz r3, 0x70(r3)
    lwz r12, 0x0(r3)
    lwz r12, 0x48(r12)
    mtctr r12
    bctrl
    cmpwi r3, 0x24 #if jabs, do jab thingy
    blt end
    cmpwi r3, 0x26
    bge end
jabSystem:
    #getButtons
    lwz r3, 0xD8(r31)
    lwz r3, 0x5C(r3)
    lwz r12, 0x0(r3)
    lwz r12, 0xAC(r12)
    mtctr r12
    bctrl
    andi. r3, r3, 0x0001 #if attack input not pressed
    bne end

    #if attack not pressed, enable bit RA-Bit[22]
    lwz r3, 0xD8(r31)
    lwz r3, 0x64(r3)
    lis r4, 0x2200
    ori r4, r4, 0x0016
    lwz r12, 0x0(r3)
    lwz r12, 0x50(r12)
    mtctr r12
    bctrl


end:
    cmpwi r27, 0
}

#leftover psa for jab system
.alias Jab_Loc = 0x805462F8
CODE @ $805462F8
{
    word 0; word 0x25
    word 6; word 8
    word 5; RA_Bit 21
    word 6; word 0x80000008 # Not 8
    word 5; RA_Bit 17
    word 0; word 0x2761
    word 0; word 0x24
    word 6; word 8
    word 5; RA_Bit 21
    
    word 6; word 0x33
    word 0; word 0
    word 6; word 0x80000030 # Not 48
    word 0; word 0xF
    word 5; RA_Basic 2
}
uint32_t 0x22000013 @ $80FB2038
CODE @ $80FB205C
{
    word 0x02010300; word Jab_Loc
    word 0x02040200; word 0x80FB1DEC
    word 0x02040200; word Jab_Loc+0x18
    word 0x02040100; word 0x80FB1E3C
    word 0x000F0000; word 0
    word 0x02000400; word Jab_Loc+0x28
    word 0x02040200; word 0x80FB1ED4
    word 0x02040100; word 0x80FB1E3C
    word 0x00020000; word 0
    word 0x00020000; word 0
}
CODE @ $80FB20D4
{
    word 0x00020000; word 0
    word 0x0D000200; word 0x80FB1F1C
    word 0x00110100; word 0x80FB1EF4
    word 0x00020000; word 0
}
CODE @ $80FB1A94
{
    word 0x000A0200; word 0x80FB1DFC
    word 0x12030100; word Jab_Loc+0x68
    word 0x000F0000; word 0
}
CODE @ $80FB1CDC
{
    word 0x000A0200; word Jab_Loc+0x48
    word 0x120A0100; word 0x80FB1F74
    word 0x000F0000; word 0
    word 0x000A0200; word 0x80FB1E2C
    word 0x000A0200; word 0x80FB1DFC
    word 0x000B0200; word 0x80FB1C8C
    word 0x000B0200; word Jab_Loc+0x58
    word 0x120A0100; word 0x80FB1F4C
    word 0x000F0000; word 0
    word 0x000A0200; word 0x80FB1C34
    word 0x000B0200; word Jab_Loc+0x58
    word 0x120A0100; word 0x80FB1F4C
    word 0x000F0000; word 0
    word 0x000F0000; word 0
    word 0x000A0200; word 0x80FB1CB4
    word 0x000B0200; word Jab_Loc+0x08
    word 0x120A0100; word 0x80FB1F6C
    word 0x000F0000; word 0
    word 0x00020000; word 0
    word 0x00020000; word 0
    word 0x00020000; word 0
    word 0x00020000; word 0
}