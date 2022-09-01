Collision Debug Function [Arthur, Eon] #draws collision that is stood on and its normal
#setIgnoreDepth
op li r5, 0 @ $80137860
op li r5, 0 @ $8013789C
op li r5, 0 @ $801378d8
op li r5, 0 @ $80137914
op li r5, 0 @ $80137b34
op li r5, 0 @ $80137bf0
op li r5, 0 @ $80137CF8
op li r5, 0 @ $80137e3c
op li r5, 0 @ $80137eec

op b 0xEC @ $80137850
#set ECBChange to transparent for now
word 0x000000FF @ $805A2A5C

draw/[clRhombus2D] [Eon]
#r3 = 4 positions, x1,y1, x2, y2, x3,y3, x4,y4
#r4 = colour
#r5 = Zmode
#f1 = z (probably originally line width but fuck them, this is now a full shape with no outline)
.macro callfunc(<addr>) 
{
.alias temp_Hi = <addr> / 0x10000
.alias temp_Lo = <addr> & 0xFFFF
  lis r12, temp_Hi
  ori r12, r12, temp_Lo
  mtctr r12
  bctrl	
}
HOOK @ $800437DC 
{
    stwu r1, -0x30(r1)
    mflr r0
    stw r0, 0x34(r1)
    stfd f31, 0x20(r1)
	word 0xf3e10028; //    psq_st p31, 40(r1), 0, qr0
    fmr f31, f1
    stw r31, 0x1C(r1)
    mr r31, r4
    stw r30, 0x18(r1)
    mr r30, r5
    stw r29, 0x14(r1)
    mr r29, r3
    %callfunc(0x80019FA4)
    %callfunc(0x80018DE4)
    lwz r31, 0(r31)
    %callfunc(0x8001A5C0)
    li r3, 0 
    %callfunc(0x801f136C)
    cmpwi r30, 0
    beq zmode0
zmode1:
    li r3, 1
    li r4, 3
    li r5, 1
    %callfunc(0x801F4774)
    b zmodeset
zmode0:
    li r3, 0
    li r4, 3
    li r5, 1
    %callfunc(0x801F4774)
zmodeset:
    li r3, 7
    li r4, 0
    li r5, 1
    li r6, 7
    li r7, 0
    %callfunc(0x801F3FD8)

    li r3, 0x80 #triangle strip
    li r4, 1
    li r5, 4 #4 vertices
    %callfunc(0x801F1088)
    lis r3, 0xCC01 #gfx mem-loc

.macro drawVertex(<offset>) 
{
	lfs f0, <offset>(r29)
	lfs f1, <offset>+0x4(r29)
	
    stfs f0, -0x8000(r3) #x
    stfs f1, -0x8000(r3) #y
	stfs f31, -0x8000(r3)  #z

    stw r31, -0x8000(r3) #colour
}

	#0x0 = centre
	#0x8 = top
	#0x10 = bottom
	#0x18 = left
	#0x20 = right
	#0x28 = bottom left bound
	#0x30 = top right bound
	
	#v0
	%drawVertex(0x08)
	#v1
	%drawVertex(0x18)
	#v2
	%drawVertex(0x10)
	#v3
	%drawVertex(0x20)

	#draws triangle v0,v1,v2, then triangle v1,v3,v2


	word 0xe3e10028 //    psq_l p31, 40(r1), 0, qr0
    lwz r0, 0x34(r1)
    lfd f31, 0x20(r1)
    lwz r31, 0x1C(r1)
    lwz r30, 0x18(r1)
    lwz r29, 0x14(r1)
    mtlr r0
    addi r1, r1, 48
    blr 
}

Draw ECB adjustments [Eon]
op li r5, 1 @ $801377b8 #set zmode to true, take depth into account.
HOOK @ $801377AC #set z-pos of previous frame to -1
{
	lis r4, 0xBF80
	stw r4, 0x64(r1)
	lfs f1, 0x64(r1)
}
HOOK @ $801377C8 #set z-pos of current frame to 0
{
	lis r4, 0xBD00 #-0.03125 to make it not match gnw on the plane 
	stw r4, 0x60(r1)
	lfs f1, 0x60(r1)
}
word 0xFF6020FF @ $805A2A5C #previous frame colour
word 0xFFA030FF @ $805A2A64 #current frame colour

Draw Ledgegrab [Eon]
.macro callfunc(<addr>) 
{
.alias temp_Hi = <addr> / 0x10000
.alias temp_Lo = <addr> & 0xFFFF
  lis r12, temp_Hi
  ori r12, r12, temp_Lo
  mtctr r12
  bctrl	
}

HOOK @ $80137F44
{

    lis r0, 0x4000
    stw r0, 0x18(r1)
    lfs f1, 0x18(r1)

    lis r0, 0x0000
    stw r0, 0x18(r1)
    lfs f2, 0x18(r1)

	lwz r3, 0x08(r1)
	lwz r4, 0x0C(r1)
	lwz r5, 0x10(r1)
	lwz r6, 0x14(r1)


	stw r3, 0x20(r1)
	stw r4, 0x24(r1)

	stw r5, 0x28(r1)
	stw r4, 0x2C(r1)

	stw r5, 0x30(r1)
	stw r6, 0x34(r1)

	stw r3, 0x38(r1)
	stw r6, 0x3C(r1)
	

	lis r0, 0x00FF
	ori r0, r0, 0x10FF
	stw r0, 0x18(r1)

    addi r3, r1, 0x20 #positions
    addi r4, r1, 0x18 #colour


	%callfunc(0x80541fb4)
    lwz r0, 0x3A4(r1)
    mtlr r0
    addi r1, r1, 0x3A0
    blr
}

Draw Touching Planes [Eon]
.macro callfunc(<addr>) 
{
.alias temp_Hi = <addr> / 0x10000
.alias temp_Lo = <addr> & 0xFFFF
  lis r12, temp_Hi
  ori r12, r12, temp_Lo
  mtctr r12
  bctrl	
}
HOOK @ $80137B5C
{
    #805A2A5C (prev ECB colour) should probably move this to inside of the debug.bin
    lis r3, 0x805A
    lwz r0, 0x2A5C(r3)
    stw r0, 0x1C(r1)
leftWall:
    lbz r0, 0x75(r29)
    andi. r0, r0, 0x20
    beq rightWall

    lwz r5, 0xE4(r29)
    cmpwi r5, 0
    beq rightWall
    lwz r3, 0xE8(r29)
    cmpwi r3, 0
    beq rightWall
    lwz r3, 0xEC(r29)
    cmpwi r3, 0
    beq rightWall
    addi r4, r1, 0x180
    li r6, 0
    %callfunc(0x80111968)
    #slight offset from actual position
    lfs f0, -0x68D0(r2)
    lfs f1, 0x180(r1)
    lfs f2, 0x188(r1)
    fadds f1, f1, f0
    fadds f2, f2, f0
    stfs f1, 0x180(r1)
    stfs f2, 0x188(r1)
    #thickness
    lfs f1, -0x68A8(r2)
    addi r3, r1, 0x180
    addi r4, r1, 0x1C
    li r5, 0
    %callfunc(0x80041104)

rightWall:
    lbz r0, 0x75(r29)
    andi. r0, r0, 0x10
    beq ciel
    #0xF4 start
    lwz r5, 0xF4(r29)
    cmpwi r5, 0
    beq ciel
    lwz r3, 0xF8(r29)
    cmpwi r3, 0
    beq ciel
    lwz r3, 0xFC(r29)
    cmpwi r3, 0
    beq ciel
    addi r4, r1, 0x180
    li r6, 0
    %callfunc(0x80111968)
    #slight offset from actual position
    lfs f0, -0x68D0(r2)
    lfs f1, 0x180(r1)
    lfs f2, 0x188(r1)
    fsubs f1, f1, f0
    fsubs f2, f2, f0
    stfs f1, 0x180(r1)
    stfs f2, 0x188(r1)
    #thickness
    lfs f1, -0x68A8(r2)
    addi r3, r1, 0x180
    addi r4, r1, 0x1C
    li r5, 0
    %callfunc(0x80041104)
ciel:
    lbz r0, 0x75(r29)
    andi. r0, r0, 0x40
    beq floor
    #0xD4
    lwz r5, 0xD4(r29)
    cmpwi r5, 0
    beq floor
    lwz r3, 0xD8(r29)
    cmpwi r3, 0
    beq floor
    lwz r3, 0xDC(r29)
    cmpwi r3, 0
    beq floor
    addi r4, r1, 0x180
    li r6, 0
    %callfunc(0x80111968)
    #slight offset from actual position
    lfs f0, -0x68D0(r2)
    lfs f1, 0x184(r1)
    lfs f2, 0x18C(r1)
    fsubs f1, f1, f0
    fsubs f2, f2, f0
    stfs f1, 0x184(r1)
    stfs f2, 0x18C(r1)
    #thickness
    lfs f1, -0x68A8(r2)
    addi r3, r1, 0x180
    addi r4, r1, 0x1C
    li r5, 0
    %callfunc(0x80041104)

floor:
    lbz r0, 0x75(r29)
    andi. r0, r0, 0x80
    beq end
    #0xD4
    lwz r5, 0x104(r29)
    cmpwi r5, 0
    beq end
    lwz r3, 0x108(r29)
    cmpwi r3, 0
    beq end
    lwz r3, 0x10C(r29)
    cmpwi r3, 0
    beq end
    addi r4, r1, 0x180
    li r6, 0
    %callfunc(0x80111968)
    #slight offset from actual position
    lfs f0, -0x68D0(r2)
    lfs f1, 0x184(r1)
    lfs f2, 0x18C(r1)
    fadds f1, f1, f0
    fadds f2, f2, f0
    stfs f1, 0x184(r1)
    stfs f2, 0x18C(r1)
    #thickness
    lfs f1, -0x68A8(r2)
    addi r3, r1, 0x180
    addi r4, r1, 0x1C
    li r5, 0
    %callfunc(0x80041104)
end:
    li r0, 0
}
#0x150

#the red "disabled collision"? 
HOOK @ $80137D98
{
    li r3, 0xFF
}
#the blue "passed through"
HOOK @ $80137EAC
{
    li r5, 48
}