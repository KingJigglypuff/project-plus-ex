Airdodge Landing Lag allows use of LA-Float[0] and enters hard landing lag animation [Eon]
HOOK @ $808745F0
{

    lwz r3, 0xD8(r31)
    lwz r3, 0x70(r3)
    li r4, 0
    lwz r12, 0x0(r3)
    lwz r12, 0x88(r12)
    mtctr r12
    bctrl
    cmpwi r3, 0x21 #airdodge
    beq hardLanding
    cmpwi r3, 0x7F
    beq hardLanding
    cmpwi r3, 0xA #jumpquat #could add hardcoded momentum here
    bne specialLanding

hardLanding:
    li r30, 0x32
    b end 
specialLanding:
    li r30, 0x33
end:
    lwz r3, 0xD8(r31)
}
op mr r4, r30 @ $8087462C
op mr r3, r30 @ $80874654


Airdodge Momentum Calculated on Airdodge Entry v1.1 [Eon]

.macro getInt(<id>)
{
    %workModuleCmd(<id>, 0x18)
}
.macro setInt(<id>)
{
.alias arg_Hi = <id> / 0x10000
.alias arg_Lo = <id> & 0xFFFF
    lis r5, arg_Hi
    ori r5, r5, arg_Lo
	%ModuleCmd(0x64, 0x1C)
}

.macro enableBit(<id>)
{
    %workModuleCmd(<id>, 0x50)
}
.macro disableBit(<id>)
{
    %workModuleCmd(<id>, 0x54)
}

.macro workModuleCmd(<id>, <cmd>)
{
.alias arg_Hi = <id> / 0x10000
.alias arg_Lo = <id> & 0xFFFF
    lis r4, arg_Hi
    ori r4, r4, arg_Lo
	%ModuleCmd(0x64, <cmd>)
}

.macro ModuleCmd(<module>, <cmd>)
{
    lwz r3, 0xD8(r30)
    lwz r3, <module>(r3)
    lwz r12, 0x0(r3)
    lwz r12, <cmd>(r12)
    mtctr r12
    bctrl
}



#initStatus
HOOK @ $80884F14
{
	mr r30, r4
	mr r31, r3
}
HOOK @ $80884F38
{
    stwu r1, -0x30(r1)
    
    li r0, 0
    stw r0, 0x10(r1)
    stw r0, 0x14(r1)
	%ModuleCmd(0x5C, 0x48) #ftControllerModule.getStickX
	lfs f2, 0x10(r1) #load 0 into f2
    fcmpo cr0, f1, f2
    bne calcTotalSpeed
	%ModuleCmd(0x5C, 0x50) #ftControllerModule.getStickY
	lfs f2, 0x10(r1)
    fcmpo cr0, f1, f2
    beq storeSpeed
calcTotalSpeed:
    %ModuleCmd(0x5C, 0x58) #ftControllerModule.getStickAngle
    stfs f1, 0x18(r1)
    
    %ModuleCmd(0x5C, 0x48) #ftControllerModule.getStickX
    stfs f1, 0x1C(r1)
    %ModuleCmd(0x5C, 0x50) ##ftControllerModule.getStickX
    lfs f2, 0x1C(r1)
    fmuls f1, f1, f1
    fmuls f2, f2, f2
    fadds f1, f1, f2 #f1 = x^2 + y^2
    stfs f1, 0x1C(r1)
    #rsqrte(f1) = 1/sqrt(mag^2)
    lis r12, 0x8003
    ori r12, r12, 0xDB58
    mtctr r12
    bctrl
    lfs f2, 0x1C(r1)
    fmuls f1, f1, f2 #mag^2/sqrt(mag^2) = mag
    #1.12
    lis r0, 0x3FA3
    ori r0, r0, 0xD70A
    stw r0, 0x1C(r1)
    lfs f2, 0x1C(r1)
    fmuls f1, f1, f2 #mag = mag*1.12

    #1.0
    lis r0, 0x3F80
    stw r0, 0x1C(r1)
    lfs f2, 0x1C(r1) 
    fcmpo cr0, f1, f2 #if mag < 1, continue
    blt 0x8
clamp:
    fmr f1, f2 #else clamp mag to 1
setSpeed:
    #3.1
	lis r0, 0x4046
	ori r0, r0, 0x6666
    stw r0, 0x1C(r1)
    lfs f2, 0x1C(r1)
    fmuls f1, f1, f2 #mag = mag*3.1
    stfs f1, 0x1C(r1)
#    blt calcSpeeds #test purposes, plays a sound effect if max distance airdodge is performed
#    li r5, 1
#    li r6, 1
#    li r7, 0
#    li r4, 0x1f92 
#    %ModuleCmd(0x50, 0x1C)
calcSpeeds:
    #3.1*cos(theta) = x component
    lfs f1, 0x18(r1)
    lis r12, 0x8040
    ori r12, r12, 0x04D8
    mtctr r12 
    bctrl 

    lfs f2, 0x1C(r1)
    fmuls f1, f1, f2
    stfs f1, 0x10(r1)
    #get facing dir and mul
    %ModuleCmd(0xC, 0x2C)
    lfs f2, 0x10(r1)
    fmuls f1, f1, f2
    stfs f1, 0x10(r1)

    #3.1*sin(theta) = y component
    lfs f1, 0x18(r1)
    lis r12, 0x8040
    ori r12, r12, 0x09E0
    mtctr r12 
    bctrl
    lfs f2, 0x1C(r1)
    fmuls f1, f1, f2
    stfs f1, 0x14(r1)
storeSpeed:	
    
    #set Air/Ground state : 0x12, disables air resistance and speed cap, overrides any action state flag there would have been, sorry
    li r4, 0x12
    mr r5, r30
    %ModuleCmd(0x7C, 0x5c)

	%enableBit(0x12000039)
    #clearSpeed
    li r0, 1
    sth r0, 0x18(r1)

    lwz r3, 0xD8(r30)
    lwz r3, 0x7C(r3)
    addi r4, r1, 0x18
    lis r12, 0x8079
    ori r12, r12, 0x227C
    mtctr r12
    bctrl
    
    #addSpeed
    li r0, 0
    stw r0, 0x18(r1)
    addi r4, r1, 0x10
    mr r5, r30
    %ModuleCmd(0x7C, 0x64)

	%disableBit(0x12000039)

    
    #sets default airdodge length to 28 frames
    #to customise a chars specific airdodge time, set ra-basic[1] to time intended in the airdodge
    li r4, 28
    %setInt(0x20000001)


	addi r1, r1, 0x30


end:
    lwz r3, 0xD8(r30)
}
#execStatus
HOOK @ $8088503C
{
    stwu r1, -0x30(r1)
	mflr r0
	stw r0, 0x34(r1)
	stw r31, 0x0C(r1)
	stw r30, 0x08(r1)
	stw r29, 0x10(r1)
    #fighter object
    mr r30, r4
	mr r31, r3
    #r3 = the uniqprocess thing
    #check action = airdodge 
    %ModuleCmd(0x70, 0x48)
    cmpwi r3, 0x21 #has to be airdodge action
    bne end

    %getInt(0x20000001) #get counter
    subi r29, r3, 1
    cmpwi r29, 0
    blt end

    #checks that air/ground state is 0x12 for backwards compatability reasons. 
    #all vbrawl airdodges set air/ground to 0 to start falling. this isnt the recommended way to stop the airdodge but it works
    %ModuleCmd(0x7C, 0x60)
    cmpwi r3, 0x12
    beq decCounter
    li r29, 0

decCounter:
    mr r4, r29
    %setInt(0x20000001)
    cmpwi r29, 0
    bne mullSpeed

setFinished:
    %enableBit(0x22000010) #set RA-Bit[16]
    b end

mullSpeed:
    #mullspeed
    #0.9 every frame
    lis r0, 0x3F66
    ori r0, r0, 0x6666
    stw r0, 0x20(r1)
    stw r0, 0x24(r1)
    stw r0, 0x28(r1)
    addi r4, r1, 0x20

    li r0, 1
    sth r0, 0x2C(r1)
    addi r5, r1, 0x2C
    %ModuleCmd(0x7C, 0x4C)

end:
	lwz r0, 0x34(r1)
	lwz r31, 0x0C(r1)
	lwz r30, 0x08(r1)
	lwz r29, 0x10(r1)
    mtlr r0
	addi r1, r1, 0x30
	blr	
}


#Point DJC based airdodge to not djc airdodge
op blr @ $8089D670 #execFixPos nop'ed
op b -0x1860C @ $8089D50C #initStatus points to generic initStatus


#PSA-Portion of airdodge rework
.alias AirDodge_Loc  = 0x805463B0
CODE @ $805463B0
{
	#+0x00	Float Variable Set: LA-Float[0] = 10.0
	word 1; scalar 10.0
	word 5; LA_Float 0
	#+0x10 	Change Action: Requirement: Action=10, Requirement=Animation End
	word 0; word 0x10
	word 6; word 1
	#+0x20 	Change Action: Requirement: Action=0x19, Requirement=On Ground
	word 0; word 0x19
	word 6; word 3
    #+0x34  Disallow/Reallow Certain Movements: 0x1
    word 0; word 0x1
    #+0x38
    word 2; word AirDodge_Loc+0x40

    word 0x12060200; word AirDodge_Loc		#Float Variable Set: LA-Float[0] = 10.0 (Special Landing Lag = 10 frames)
	word 0x02010200; word AirDodge_Loc+0x10 #Change Action: Requirement: Action=0x10, Requirement=Animation End
	word 0x02010200; word AirDodge_Loc+0x20	#Change Action: Requirement: Action=0x19, Requirement=On Ground
	word 0x00070100; word 0x80FB18E4		#Sub Routine: 0x80FB18E4->80FC2390
	word 0x0E060100; word AirDodge_Loc+0x34	#Disallow Certain Movements: 0x1
}

CODE @ $80FB18F4 	#In Airdodge Action 
{
	word 0x00070100; word AirDodge_Loc+0x38 #Sub Routine: Injection
}

CODE @ $80FB15DC 
{
    word 0x0E070100; word AirDodge_Loc+0x34 #reallow Certain Movements: 0x1 #(deletes enabling ledgegrab), ran when RA-Bit[16] set
}