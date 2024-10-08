###################################
New Work Module Command Table [Eon]
###################################
#80543000 is a table of pointers to new commands
HOOK @ $807ace74
{
    extsb r0, r3
    cmpwi r0, 0x50
    blt _end

    stwu r1, -0x200(r1)
    stw r0, 0x10(r1)

    addi r3, r1, 0xa8
    mr r4, r29
    lwz r12, 0(r29)
    lwz r12, 0x1C(r12)
    mtctr r12
    bctrl
    lwz r3, 0xB0(r1)
    lis r4, 0x80AE
    addi r4, r4, 0x0e28
    lwz, r5, 0xAC(r1)
    mr r6, r31
    lwz r0, 0xB4(r1)
    stw r3, 0xD0(r1)
    stw r4, 0xC8(r1)
    stw r5, 0xCC(r1)
    stw r6, 0xD8(r1)
    stw r0, 0xD4(r1)
    cmpwi r3, 0
    li r0, 0
    stb r0, 0xDC(r1)
    bne 0x8
    stw r0, 0xD4(r1)


    lwz r3, 0x10(r1)
    subi r0, r3, 0x50
    lis r12, 0x8054
    ori r12, r12, 0x3000
    rlwinm r0, r0, 2, 0, 29
    lwzx r12, r12, r0
    mtctr r12
    bctrl 


	addi r1, r1, 0x200

    lis r12, 0x807a
    ori r12, r12, 0xde5c
    mtctr r12
    bctr
_end:
}

#########################################################################
Sin, Cos, aSin, aCos and aTan2 on Work Module 50, 51, 52, 53 and 54 [Eon]
#########################################################################
#Every function works in radians.
#Degrees to radians = degrees/180*pi 
#Radians to degrees = radians/pi*180

    .BA<-Cmd50
* 42100000 00000008 #BA+=8 to abuse Pulse command as an easy way to write a block of code
    .BA->$80543000  #12500200

    .BA<-Cmd51
* 42100000 00000008 #BA+=8 to abuse Pulse command as an easy way to write a block of code
    .BA->$80543004  #12510200

    .BA<-Cmd52
* 42100000 00000008 #BA+=8 to abuse Pulse command as an easy way to write a block of code
    .BA->$80543008  #12520200

    .BA<-Cmd53
* 42100000 00000008 #BA+=8 to abuse Pulse command as an easy way to write a block of code
    .BA->$8054300C  #12530200

    .BA<-Cmd54
* 42100000 00000008 #BA+=8 to abuse Pulse command as an easy way to write a block of code
    .BA->$80543010  #12540300

	.BA<-Cmd55
* 42100000 00000008 #BA+=8 to abuse Pulse command as an easy way to write a block of code
    .BA->$80543014  #12550300

	.BA<-Cmd56
* 42100000 00000008 #BA+=8 to abuse Pulse command as an easy way to write a block of code
    .BA->$80543018  #12560300

	.BA<-Cmd57
* 42100000 00000008 #BA+=8 to abuse Pulse command as an easy way to write a block of code
    .BA->$8054301C  #12570300


    .RESET
    .GOTO->end
.macro getFloat(<arg>) #places Result in f1
{
	addi r3, r1, 0xC8
    li r4, <arg>
    lis r12, 0x8077
    ori r12, r12, 0xE0CC
    mtctr r12
    bctrl
}
.macro writeFloat(<arg>) #writes from f1 to <arg>
{
	li r4, <arg>
	addi r3, r1, 0xC8
	lwz r12, 0(r3)	
	lwz r12, 0x10(r12)
	mtctr r12
	bctrl 
	lwz r4, 0x4(r3)
    mr  r3, r28
	lwz r12,0(r28)
    lwz r12, 0x003C (r12)
    mtctr r12
    bctrl	
}
Cmd50: #sin
PULSE
{
	mflr r0
	stw r0, 0x204(r1)
#getArg0Float
	%getFloat(0)
#sin
	lis r12, 0x8040
	ori r12, r12, 0x09E0
	mtctr r12
	bctrl
#WriteTo Arg 1
	%writeFloat(1)
	lwz r0, 0x204(r1)
	mtlr r0
	li r3, 1
    blr
}
Cmd51: #cos
PULSE
{
	mflr r0
	stw r0, 0x204(r1)
#getArg0Float
	%getFloat(0)
#cos
	lis r12, 0x8040
	ori r12, r12, 0x04D8
	mtctr r12
	bctrl
#WriteTo Arg 1
	%writeFloat(1)
	lwz r0, 0x204(r1)
	mtlr r0
	li r3, 1
    blr
}
Cmd52: #asin
PULSE
{
	mflr r0
	stw r0, 0x204(r1)
#getArg0Float
	%getFloat(0)
#asin
	lis r12, 0x8040
	ori r12, r12, 0x0B34
	mtctr r12
	bctrl
#WriteTo Arg 1
	%writeFloat(1)
	lwz r0, 0x204(r1)
	mtlr r0
	li r3, 1
    blr
}
Cmd53: #acos
PULSE
{
	mflr r0
	stw r0, 0x204(r1)
#getArg0Float
	%getFloat(0)
#asin
	lis r12, 0x8040
	ori r12, r12, 0x0B30
	mtctr r12
	bctrl
#WriteTo Arg 1
	%writeFloat(1)
	lwz r0, 0x204(r1)
	mtlr r0
	li r3, 1
    blr
}
Cmd54: #atan2
PULSE
{
	mflr r0
	stw r0, 0x204(r1)
#getArg0Float
	%getFloat(0)
	fmr f2, f1
#getArg1Float
	%getFloat(1)
#atan2
	lis r12, 0x8040
	ori r12, r12, 0x0B38
	mtctr r12
	bctrl
#WriteTo Arg 2
	%writeFloat(2)


	lwz r0, 0x204(r1)
	mtlr r0
	li r3, 1
    blr
}
CMD55: #sqrt
PULSE 
{
	mflr r0
	stw r0, 0x204(r1)
#getArg0Float
	%getFloat(0)
#sqrt
	lis r12, 0x8040
	ori r12, r12, 0x0D94
	mtctr r12
	bctrl
#WriteTo Arg 2
	%writeFloat(1)


	lwz r0, 0x204(r1)
	mtlr r0
	li r3, 1
    blr
}
CMD56: #power
PULSE
{
	mflr r0
	stw r0, 0x204(r1)
#getArg0Float
	%getFloat(0)
	fmr f2, f1
#getArg1Float
	%getFloat(1)
#pow
	lis r12, 0x8040
	ori r12, r12, 0x0B44
	mtctr r12
	bctrl
#WriteTo Arg 2
	%writeFloat(2)


	lwz r0, 0x204(r1)
	mtlr r0
	li r3, 1
    blr
}
CMD57: #getPI
PULSE
{
	mflr r0
	stw r0, 0x204(r1)
#getArg0Float
	lis r3, 0x4049
	ori r3, r3, 0x0FDB
	stw r3, 0x100(r1)
	lfs f1, 0x100(r1)
#WriteTo Arg 2
	%writeFloat(0)


	lwz r0, 0x204(r1)
	mtlr r0
	li r3, 1
    blr
}
end: