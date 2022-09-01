Custom RenderDebug Call [Eon]
.alias ProcessPosition = 0
HOOK @ $8002DD24
{
	ble %end%
	cmplwi r0, 8
	bgtlr 
	lwz r12, 0x3C(r3)
	lwz r12, 0x58(r12)
	mtctr r12
	bctr
}
op cmpwi r29, 17 @ $8002e684

HOOK @ $8002E62C
{
	cmplwi r29, ProcessPosition
	beq %end%
	rlwinm. r0, r0, 31,31,31
}
HOOK @ $8002E604
{
	cmplwi r29, ProcessPosition
	beq %end%
	rlwinm. r0, r3, 27,31,31
}

HOOK @ $8002e610
{
	cmplwi r29, ProcessPosition
	mr r4, r29
	blt %end%
	li r4, 16
	beq %end%
	subi r4, r29, 1
}
HOOK @ $8002e638
{
	cmplwi r29, ProcessPosition
	mr r4, r29
	blt %end%
	li r4, 16
	beq %end%
	subi r4, r29, 1
}
HOOK @ $8002E5B4
{
	subi r4, r29, 1
	rlwimi r3, r4, 16, 8, 15
}

Frame Advance Convert [Eon]
HOOK @ $8002E5C4
{
	cmpwi r0, 2
	bne original
DebugPause:
	cmpwi r29, 0
	beq %end%
original:
	slw. r0, r31, r29
}

drawQuadOutline [Eon]
.macro callfunc(<addr>) 
{
.alias temp_Hi = <addr> / 0x10000
.alias temp_Lo = <addr> & 0xFFFF
  lis r12, temp_Hi
  ori r12, r12, temp_Lo
  mtctr r12
  bctrl	
}
HOOK @ $80541FB4 
{
    stwu r1, -0x50(r1)
    mflr r0
    stw r0, 0x54(r1)
    stfd f31, 0x20(r1)
    stfd f30, 0x28(r1)
	word 0xf3e10030; //    psq_st p31, 0x30(r1), 0, qr0
	word 0xf3c10040; //    psq_st p30, 0x40(r1), 0, qr0
    fmr f30, f1
	fmr f31, f2
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

	#convert line width as double into line width as integer
	lfs f0, -0x7B68(r2)
	fmuls f0, f0, f30
	fctiwz f0, f0
	stfd f0, 0x8(r1)
	lwz r3, 0xC(r1)
	rlwinm r3, r3, 0, 24, 31
	
	li r4, 2
	%callfunc(0x801f12ac)

	 

    li r3, 0xB0 #line strip
    li r4, 1
    li r5, 5 #4 vertices
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
	
	#v0
	%drawVertex(0x00)
	#v1
	%drawVertex(0x8)
	#v2
	%drawVertex(0x10)
	#v3
	%drawVertex(0x18)
	#v0
	%drawVertex(0x00)

	#draws lines attaching each point

    lfd f31, 0x20(r1)
    lfd f30, 0x28(r1)
	word 0xe3e10030; //    psq_l p31, 0x30(r1), 0, qr0
	word 0xe3c10040; //    psq_l p30, 0x40(r1), 0, qr0

    lwz r0, 0x54(r1)
    lwz r31, 0x1C(r1)
    lwz r30, 0x18(r1)
    lwz r29, 0x14(r1)
    mtlr r0
    addi r1, r1, 0x50
    blr 
}
drawLine3D [Eon]
.macro callfunc(<addr>) 
{
.alias temp_Hi = <addr> / 0x10000
.alias temp_Lo = <addr> & 0xFFFF
  lis r12, temp_Hi
  ori r12, r12, temp_Lo
  mtctr r12
  bctrl	
}
HOOK @ $80541fb8 
{
    stwu r1, -0x50(r1)
    mflr r0
    stw r0, 0x54(r1)
    stfd f31, 0x20(r1)
	word 0xf3e10030; //    psq_st p31, 0x30(r1), 0, qr0
    fmr f31, f1



    stw r31, 0x1C(r1) #pos1
    mr r31, r3
    stw r30, 0x18(r1) #pos2
    mr r30, r4
    stw r29, 0x14(r1) #colour
	lwz r29, 0x0(r5)

	stw r28, 0x10(r1) #zmode
	mr r28, r6


    %callfunc(0x80019FA4)
    %callfunc(0x80018DE4)
    %callfunc(0x8001A5C0)

	#convert line width as double into line width as integer
	lfs f0, -0x7B68(r2)
	fmuls f0, f0, f31
	fctiwz f0, f0
	stfd f0, 0x8(r1)
	lwz r3, 0xC(r1)
	rlwinm r3, r3, 0, 24, 31
	
	li r4, 2
	%callfunc(0x801f12ac)

	 

    li r3, 0xA8 #line
    li r4, 1
    li r5, 2 #2 vertices
    %callfunc(0x801F1088)
    lis r3, 0xCC01 #gfx mem-loc

.macro drawVertex(<arg>) 
{
	lfs f0, 0x0(<arg>)
	lfs f1, 0x4(<arg>)
	lfs f2, 0x8(<arg>)
    stfs f0, -0x8000(r3) #x
    stfs f1, -0x8000(r3) #y
	stfs f2, -0x8000(r3)  #z

    stw r29, -0x8000(r3) #colour
}
	
	#v0
	%drawVertex(31)
	#v1
	%drawVertex(30)

	#draws line attaching each point

    lfd f31, 0x20(r1)
	word 0xe3e10030; //    psq_l p31, 0x30(r1), 0, qr0

    lwz r0, 0x54(r1)
    lwz r31, 0x1C(r1)
    lwz r30, 0x18(r1)
    lwz r29, 0x14(r1)
    lwz r28, 0x10(r1)
    mtlr r0
    addi r1, r1, 0x50
    blr 
}

DebugFileLoader [Eon]
HOOK @ $800B08A0
{
	stwu r1, -0xB4(r1)
	mflr r0
	stw r0, 0xB8(r1)
	

	lis r5, 0x8054
	ori r5, r5, 0x8400
	lbz r0, -1(r5)
	cmpwi r0, 1
	beq end

	li r0, 1
	stb r0, -1(r5)


	addi r3, r1, 0x10	
	bl data
	mflr r4
	addi r4, r4, 0x10 			#has to be adjusted appropriately if size of HOOK is odd or even

	li r6, 0x0
	li r7, 0x0
	lis r12, 0x8002				# \
	ori r12, r12, 0x239C		# | Set up the read parameter block
	mtctr r12					# |
	bctrl 						# /

	addi r3, r1, 0x10

	lis r12, 0x8001    	#readFile
	ori r12, r12, 0xBF0C
	mtctr r12          
	bctrl

end:
	lwz r0, 0xB8(r1)
	mtlr r0
	addi r1, r1, 0xB4
	blr
data:
	blrl
}
	.GOTO->skip
    string "/menu3/data.debug"
skip:
	.RESET


renderDebug/[StageObject] [Eon]
HOOK @ $80710AE4
{
	stwu r1, -0x40(r1)
	mflr r0
	stw r0, 0x44(r1)
	stw r31, 0x3C(r1)
	lwz r31, 0x60(r3)

hurthitetcdraw:
	lis r3, 0x8058
	ori r3, r3, 0x3FFC
	lhz r3, 0x0(r3)
	cmpwi r3, 0
	beq ecbDraw

	#collisionHit
	lwz r3, 0xD8(r31)
	lwz r3, 0x20(r3)
	lwz r12, 0x0(r3)
	lwz r12, 0xD8(r12)
	mtctr r12
	bctrl
	#collisionAttack
	lwz r3, 0xD8(r31)
	lwz r3, 0x1C(r3)
	lwz r12, 0x0(r3)
	lwz r12, 0x120(r12)
	mtctr r12
	bctrl
	#collisionShield
	lwz r3, 0xD8(r31)
	lwz r3, 0x24(r3)
	lwz r12, 0x0(r3)
	lwz r12, 0x88(r12)
	mtctr r12
	bctrl
	#collisionShield
	lwz r3, 0xD8(r31)
	lwz r3, 0x28(r3)
	lwz r12, 0x0(r3)
	lwz r12, 0x88(r12)
	mtctr r12
	bctrl
	#collisionShield
	lwz r3, 0xD8(r31)
	lwz r3, 0x2C(r3)
	lwz r12, 0x0(r3)
	lwz r12, 0x88(r12)
	mtctr r12
	bctrl
	#collisionCatch
	lwz r3, 0xD8(r31)
	lwz r3, 0x30(r3)
	lwz r12, 0x0(r3)
	lwz r12, 0x48(r12)
	mtctr r12
	bctrl
	#collisionSearch
	lwz r3, 0xD8(r31)
	lwz r3, 0x34(r3)
	lwz r12, 0x0(r3)
	lwz r12, 0x50(r12)
	mtctr r12
	bctrl
ecbDraw:
	lis r3, 0x8058
	ori r3, r3, 0x3FF7
	lhz r3, 0x0(r3)
	cmpwi r3, 0
	beq end 
	lwz r3, 0xD8(r31)
	lwz r3, 0x10(r3)
	lwz r12, 0x8(r3)
	lwz r12, 0x21C(r12)
	mtctr r12
	bctrl
    #get node id for bone 2
	lwz r3, 0xD8(r31)
	lwz r3, 0x4(r3)
	li r4, 0
	lwz r12, 0x8(r3)
	lwz r12, 0x8C(r12)
	mtctr r12
	bctrl
	mr r5, r3
	addi r3, r1, 0x10
	lwz r4, 0xD8(r31)
	lwz r4, 0x4(r4)
	li r6, 1
	lwz r12, 0x8(r4)
	lwz r12, 0x98(r12)
	mtctr r12
	bctrl
	lfs f1, 0x10(r1)
	lfs f2, 0x14(r1)
	lis r0, 0x3F00
	stw r0, 0x10(r1)
	lis r0, 0xBF00
	stw r0, 0x14(r1)
	lfs f3, 0x10(r1)
	lfs f4, 0x14(r1)

	#top/bottom
	stfs f1, 0x10(r1)
	fadds f0, f2, f3
	stfs f0, 0x14(r1)
	stfs f1, 0x18(r1)
	fadds f0, f2, f4
	stfs f0, 0x1C(r1)

	#left/right
	fadds f0, f1, f3
	stfs f0, 0x20(r1)
	stfs f2, 0x24(r1)
	fadds f0, f1, f4
	stfs f0, 0x28(r1)
	stfs f2, 0x2C(r1)


	lis r3, 0xC060
	ori r3, r3, 0x20FF
	stw r3, 0xC(r1)

	addi r3, r1, 0x8 #positions
	addi r4, r1, 0xC #colour
	li r5, 0

	fsubs f1, f1, f1

	lis r12, 0x8004
	ori r12, r12, 0x37DC
	mtctr r12
	bctrl 


end:
	lwz r31, 0x3C(r1)
	lwz r0, 0x44(r1)
	mtlr r0 
	addi r1, r1, 0x40
	blr
}

renderDebug/[Yakumono] [Eon]
#points Yakumono renderDebug into the StageObject renderDebug
HOOK @ $8096e040
{
	lis r12, 0x8071 
	ori r12, r12, 0x0AE4
	mtctr r12
	bctr
}