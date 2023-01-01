######################################################################
B while holding A + paused will re-roll stage music (P+ version) [Eon]
######################################################################
HOOK @ $800F1680 #if B pressed in pause screen
{
    lwz r0, 0x8(r1)
    andi. r0, r0, 0x100 #if A is already held 
    beq original
    #getSceneManager
    lis r12, 0x8002
    ori r12, r12, 0xD018
    mtctr r12 
    bctrl 
    lwz r4, 0x4(r3)
    lwz r4, 0x40(r4) #stOperatorBgm
    lwz r31, 0x44(r4) #song ID pointer thing

    #sndBgmRateSystem.prepareBGM(stageId, 0, 0)
    lis r3, 0x805A 
    lwz r3, 0x1D8(r3) #sndBgmRateSystem
    lwz r4, 0x48(r4) #stageId 
    li r5, 0 #unsure 
    li r6, 0 #song ID, if 0 it picks a new random one 
    lis r12, 0x8007
    ori r12, r12, 0x8DAC	#9104 in original code
    mtctr r12 
    bctrl 
    #store selected song in appropriate place 
    lbz r4, 0x5C(r31)
    stw r3, 0x5C(r31)
    stb r4, 0x5C(r31)


    #songMessageObj.printIndex(0, songIndex, 0)
    lis r3, 0x805A
    lwz r3, 0x2D0(r3)
    lwz r3, 0x44(r3)
    lwz r3, 0x164(r3)
    li r4, 0
    li r5, -2
    li r6, 0
    lis r12, 0x800B
    ori r12, r12, 0x91B8
    mtctr 12 
    bctrl 
    #sndBgmRateSystem.startBGM(0)
    lis r3, 0x805A
    lwz r3, 0x1D8(r3)
    li r4, 0
    lis r12, 0x8007
    ori r12, r12, 0x91D4
    mtctr r12 
    bctrl 
exit:
    #restore original r31
    mr r3, r29
    lis r12, 0x800F
    ori r12, r12, 0x00AC
    mtctr r12 
    bctrl 
    mr r31, r3
    #exit
    lis r12, 0x800f
    ori r12, r12, 0x1698
    mtctr r12 
    bctr 
original:
    lbz r0, 0x64(r29)
}

#########################################
Song Title Displays On Pause Screen [Eon]
#########################################
HOOK @ $800F0938
{
    bctrl
    lis r3, 0x805A
    lwz r3, 0x2D0(r3)
    lwz r3, 0x44(r3)
    lwz r5, 0x40(r3)
    lwz r5, 0x10(r5)

    lwz r3, 0x0(r31)
    lwz r4, 0xE4(r3)
    lwz r12, 0x0(r3)
    lwz r12, 0x34(r12)
    mtctr r12
    bctrl 
}