renderDebug/[Stage] [Eon]
.macro drawPart(<a>, <b>, <c>, <d>, <r>)
{

	lfs f2, <a>(<r>)
	lfs f3, <b>(<r>)
	lfs f4, <c>(<r>)
	lfs f5, <d>(<r>)
	stfs f2, 0x10(r1)
	stfs f3, 0x14(r1)
	stfs f4, 0x18(r1)
	stfs f5, 0x1C(r1)

	lfs f1, -0x68CC(r2)
	addi r3, r1, 0x10
	addi r4, r1, 0x08
	li r5, 0
	#0x80041104
	lis r12, 0x8004
	ori r12, r12, 0x1104
	mtctr r12
	bctrl

}


HOOK @ $8092d4bc
{
	stwu r1, -0x0040(r1)
	mflr r0
	stw r0, 0x0044(r1)
	stw r31, 0x0040(r1)
	stw r30, 0x003C(r1)


	mr r31, r3
	lis r3, 0x8058
    ori r3, r3, 0x3ff9
    lbz r3, 0x0(r3)
    cmpwi r3, 0
	beq end
	mr r3, r31
	lwz r30, 0x78(r31)
	
	lwz r0, 0x0090(r3)
	cmpwi r0, 0
	beq end
	#Blastzones render 
	#red
	lis r0, 0xFF00
	ori r0, r0, 0x00FF
	stw r0, 0x8(r1)

	lfs f1, 0x58(r31)
	lfs f2, 0x20(r30)
	fadds f1, f1, f2
	stfs f1, 0x20(r1)
	lfs f1, 0x5C(r31)
	lfs f2, 0x20(r30)
	fadds f1, f1, f2
	stfs f1, 0x24(r1)
	lfs f1, 0x60(r31)
	lfs f2, 0x24(r30)
	fadds f1, f1, f2
	stfs f1, 0x28(r1)
	lfs f1, 0x64(r31)
	lfs f2, 0x24(r30)
	fadds f1, f1, f2
	stfs f1, 0x2C(r1)



	
	%drawPart(0x20, 0x28, 0x20, 0x2C, 1)
	%drawPart(0x20, 0x2C, 0x24, 0x2C, 1)
	%drawPart(0x24, 0x2C, 0x24, 0x28, 1)
	%drawPart(0x24, 0x28, 0x20, 0x28, 1)
	#Camera Boundary render 
	#blue 
	lis r0, 0x0000
	ori r0, r0, 0xFFFF
	stw r0, 0x8(r1)

	lfs f1, 0x0(r30)
	lfs f2, 0x20(r30)
	fadds f1, f1, f2
	stfs f1, 0x20(r1)
	lfs f1, 0x4(r30)
	lfs f2, 0x20(r30)
	fadds f1, f1, f2
	stfs f1, 0x24(r1)
	lfs f1, 0x8(r30)
	lfs f2, 0x24(r30)
	fadds f1, f1, f2
	stfs f1, 0x28(r1)
	lfs f1, 0xC(r30)
	lfs f2, 0x24(r30)
	fadds f1, f1, f2
	stfs f1, 0x2C(r1)

	%drawPart(0x20, 0x28, 0x20, 0x2C, 1)
	%drawPart(0x20, 0x2C, 0x24, 0x2C, 1)
	%drawPart(0x24, 0x2C, 0x24, 0x28, 1)
	%drawPart(0x24, 0x28, 0x20, 0x28, 1)

end:
	lwz r0, 0x0044(r1)
	lwz r31, 0x0040(r1)
	lwz r30, 0x003C(r1)
	mtlr r0
	addi r1, r1, 0x40
	blr 

}

renderDebug/[grGimmick] [Eon]
#points to renderDebug/[Ground], the parent class's function
HOOK @ $80978840
{
	stwu r1, -0x0010 (r1)
	mflr r0
	stw r0, 0x14(r1)
	stw r31, 0x0C(r1)
	mr r31, r3
	lis r12, 0x8096
	ori r12, r12, 0xB334
	mtctr 12 
	bctrl
	lwz r0, 0x14(r1)
	lwz r31, 0x0C(r1)
	mtlr r0
	addi r1, r1, 16
	blr	

}

renderDebug/[grCollisionManager] [Eon]
#based heavily on game loops in update/[grCollisionManager]
.macro callFunc(<addr>) 
{
.alias temp_Hi = <addr> / 0x10000
.alias temp_Lo = <addr> & 0xFFFF
  lis r12, temp_Hi
  ori r12, r12, temp_Lo
  mtctr r12
  bctrl	
}

HOOK @ $80112c94
{
	stwu r1, -0x0020 (r1)
	mflr r0
	stw r0, 0x0024 (r1)
	stw r31, 0x10(r1)
	stw r30, 0x14(r1)
	stw r29, 0x18(r1)
	stw r28, 0x1C(r1)

	mr r30, r3
	#if stage render enabled, draw stuff, else end
	lis r3, 0x8058
    ori r3, r3, 0x3ff9
    lbz r3, 0x0(r3)
    cmpwi r3, 0
	beq end

	#lots of specific checks for if the collision is in use.
	lwz r0, 0x40(r30)
	rlwinm. r0, r0, 25, 31, 31
	beq end

	lis r29, 0x804A
	subi r29, r29, 6788
	lwz r31, 0x0004 (r29)
	addi r29, r29, 4
	b checkLoop
loopStart:
	lbz r3, -0x4(r31)
	rlwinm. r0, r3, 25, 31, 31
	beq next
	rlwinm. r0, r3, 31, 31, 31
	#bne next

	subi r28, r31, 48
	mr r3, r28
	%callFunc(0x80541F90)
next:
	lwz r31, 0(r31)
checkLoop:
	cmplw r31, r29
	bne loopStart
end:
	lwz r31, 0x10(r1)
	lwz r30, 0x14(r1)
	lwz r29, 0x18(r1)
	lwz r28, 0x1C(r1)

	lwz r0, 0x24(r1)
	mtlr r0 
	addi r1, r1, 0x20
	blr

}
#drawCollisionList 
HOOK @ $80541F90
{
.alias input = 23
	stwu r1, -0x0050 (r1)
	mflr r0
	stw r0, 0x0054 (r1)
	stmw r23, 0x2C(r1)

	mr input, r3

	lbz r5, 0x002C (r3)

	rlwinm. r0, r5, 25, 31, 31
	beq end

loopInit:
	li r24, 0
	li r30, 0
	b loopNext

loop:
	lwz r0, 0x0018(input)
	add r31, r0, r30
	lbz r0, 0x54(r31)
	rlwinm. r0, r0, 26, 31, 31
	beq loopIterate
	li r25, 0
	lhz r26, 0x2(r31)
	b innerLoopCheck
innerLoopStart:
	mr r3, r31
	mr r4, r25
	%callFunc(0x80112EA0) #getLine/[grCollisionJoint]
	mr r27, r3
	mr r3, input
	addi r4, r1, 0x18
	mr r5, r27
	li r6, 0
	%callFunc(0x80111968) #getSegment

	addi r3, r1, 0x18
	mr r4, r27
	%callFunc(0x80541F94) #drawCollision

	addi r25, r25, 1


innerLoopCheck:
	cmplw r25, r26
	blt innerLoopStart
loopIterate:
	addi r30, r30, 96
	addi r24, r24, 1
loopNext:
	lhz r0, 0x0006 (input)
	cmplw r24, r0
	blt loop
end:
	lmw r23, 0x2C(r1)
	lwz r0, 0x0054(r1)
	mtlr r0
	addi r1, r1, 80
	blr	
}
DrawCollision(SegmentData, CollisionData) [Eon]
HOOK @ $80541F94
{
.alias SegmentData = 31
.alias CollisionData = 30
.alias dataBlock = 29
.alias flags = 3
.alias type = 4

.macro callFunc(<addr>) 
{
.alias temp_Hi = <addr> / 0x10000
.alias temp_Lo = <addr> & 0xFFFF
  lis r12, temp_Hi
  ori r12, r12, temp_Lo
  mtctr r12
  bctrl	
}

.macro storeColour(<offset>)
{
	lbz r0, <offset>(dataBlock)
	stb r0, 0x8(r1)
	lbz r0, <offset>+1(dataBlock)
	stb r0, 0x9(r1)
	lbz r0, <offset>+2(dataBlock)
	stb r0, 0xA(r1)
}
.macro storeAlpha(<offset>)
{
	lbz r0, <offset>(dataBlock)
	stb r0, 0xB(r1)
}
.alias notCollidableAlpha  = 0x90
.alias superSoftAlpha      = 0x91
.alias normalAlpha         = 0x92

.alias passableFloorColour       = 0x94
.alias solidFloorColour          = 0x98
.alias ledgeColour               = 0x9C
.alias ceilingColour             = 0xA0
.alias nonWalljumpableWallColour = 0xA4
.alias walljumpableWallColour    = 0xA8

.macro isntAssigned()
{
	andi. r0, type, 0xF
}
.macro isFloor()
{
	andi. r0, type, 0x01
}
.macro isCeiling()
{
	andi. r0, type, 0x02
}
.macro isRightWall()
{
	andi. r0, type, 0x04
}
.macro isLeftWall()
{
	andi. r0, type, 0x08
}

.macro isDropThrough()
{
	andi. r0, flags, 0x01
}
.macro isRotating()
{
	andi. r0, flags, 0x04
}
.macro isSuperSoft()
{
	andi. r0, flags, 0x08
}
.macro isLeftLedge()
{
	andi. r0, flags, 0x20
}
.macro isRightLedge()
{
	andi. r0, flags, 0x40
}
.macro isNonWalljump()
{
	andi. r0, flags, 0x80
}
.macro isPlayerCollidable()
{
	andi. r0, type, 0x10
}
.macro isItemCollidable()
{
	andi. r0, type, 0x20
}
.macro isPTCollidable()
{
	andi. r0, type, 0x40
}
.macro isSSECollidable()
{
	andi. r0, type, 0x80
}

	stwu r1, -0x0030 (r1)
	mflr r0
	stw r0, 0x0034(r1)
	stw r31, 0x30(r1)
	stw r30, 0x2C(r1)
	stw r29, 0x28(r1)

	mr SegmentData, r3 
	mr CollisionData, r4	
	#mem location of debug.bin
	lis dataBlock, 0x8054
	ori dataBlock, dataBlock, 0x8400
	

	lbz flags, 0x10(CollisionData)
	lbz type, 0xF(CollisionData)
	%isntAssigned()
	beq end #unassigned
assigned:
	%isPlayerCollidable()
	bne playerCollidable
notCollidable:
	%setAlpha(notCollidableAlpha)
	b startColours
playerCollidable:
	%isSuperSoft()
	bne superSoft
normal:
	%storeAlpha(normalAlpha)
	b startColours
superSoft:
	%storeAlpha(superSoftAlpha)
	b startColours

startColours:

testFloor:
	%isFloor()
	beq testCeiling 
Floor:
	%isLeftLedge()
	beq checkRightLedge
#is a ledge, so calc positions to draw
	lfs f3, -0x68DC(r2)
	lfs f2, 0x0(SegmentData)
	fadds f1, f2, f3
	stfs f1, 0x10(r1)
	fsubs f1, f2, f3
	stfs f1, 0x18(r1)
	lfs f2, 0x4(SegmentData)
	fadds f1, f2, f3
	stfs f1, 0x14(r1)
	fsubs f1, f2, f3
	stfs f1, 0x1C(r1)

	b drawLedge
checkRightLedge:
	%isRightLedge()
	beq drawFloor
#is a ledge, so calc positions to draw
	lfs f3, -0x68DC(r2)
	lfs f2, 0x8(SegmentData)
	fsubs f1, f2, f3
	stfs f1, 0x10(r1)
	fadds f1, f2, f3
	stfs f1, 0x18(r1)
	lfs f2, 0xC(SegmentData)
	fadds f1, f2, f3
	stfs f1, 0x14(r1)
	fsubs f1, f2, f3
	stfs f1, 0x1C(r1)

drawLedge:
	%storeColour(ledgeColour)
	lfs f1, -0x68CC(r2)
	fadds f1, f1, f1
	addi r3, r1, 0x10
	addi r4, r1, 0x08
	li r5, 0
	%callFunc(0x80041104)

	lbz flags, 0x10(CollisionData)
	lbz type, 0xF(CollisionData)
drawFloor:
	%isDropThrough()
	beq solid 
passable: 
	%storeColour(passableFloorColour)
	b draw
solid:
	%storeColour(solidFloorColour)
	b draw

testCeiling:
	%isCeiling()
	beq testWall 
ceiling:
	%storeColour(ceilingColour)
	b draw

testWall:
	%isLeftWall()
	bne wall
	%isRightWall()
	beq draw
wall:
	%isNonWalljump()
	beq walljumpableWall
nonWalljumpableWall:
	%storeColour(nonWalljumpableWallColour)
	b draw
walljumpableWall:
	%storeColour(walljumpableWallColour)
draw:
	lfs f1, -0x68CC(r2)
	mr r3, SegmentData
	addi r4, r1, 8
	li r5, 0
	
	%callFunc(0x80041104)
	
end:
	lwz r31, 0x30(r1)
	lwz r30, 0x2C(r1)
	lwz r29, 0x28(r1)
	lwz	r0, 0x34 (r1)
	mtlr r0
	addi r1, r1, 0x30
	blr	
}

Fully transparent Shapes are not attempted to be drawn [Eon]
#clSegment
HOOK @ $80041130
{
	mr r29, r3
	lbz r0, 0x3(r4)
	cmpwi r0, 0
	bne %end%
	lis r12, 0x8004
	ori r12, r12, 0x11F4
	mtctr r12
	bctr
}
#clRect
HOOK @ $80041F80
{
	#if transparent, skip to end
	mr r31, r3
	lbz r0, 0x3(r4)
	cmpwi r0, 0
	bne %end%
end:
	lis r12, 0x8004
	ori r12, r12, 0x2020
	mtctr r12
	bctr
}
#clCircle
HOOK @ $80041634
{
	mr r27, r5
	lbz r0, 0x3(r4)
	cmpwi r0, 0
	bne %end%
	lis r12, 0x8004
	ori r12, r12, 0x183C
	mtctr r12
	bctr
}
#clTriangle
HOOK @ $800428F8
{
	#if transparent, skip to end
	mr r31, r3
	lbz r0, 0x3(r4)
	cmpwi r0, 0
	bne %end%
end:
	lis r12, 0x8004
	ori r12, r12, 0x2984
	mtctr r12
	bctr
}

clRectangle and gfAreaTriangle draws correct [Eon]
.macro drawPart(<a>, <b>, <c>, <d>, <r>)
{

	lfs f2, <a>(<r>)
	lfs f3, <b>(<r>)
	lfs f4, <c>(<r>)
	lfs f5, <d>(<r>)
	stfs f2, 0x20(r1)
	stfs f3, 0x24(r1)
	stfs f4, 0x28(r1)
	stfs f5, 0x2C(r1)

	lfs f1, -0x68CC(r2)
	addi r3, r1, 0x20
	addi r4, r1, 0x10
	li r5, 0
	
	lis r12, 0x8004
	ori r12, r12, 0x1104
	mtctr r12
	bctrl

}
HOOK @ $80041F84
{
	
	lwz r0, 0x0(r4)
	stw r0, 0x10(r1)
	%drawPart(0x0, 0x4, 0x0, 0xC, 31)
	%drawPart(0x0, 0xC, 0x8, 0xC, 31)
	%drawPart(0x8, 0xC, 0x8, 0x4, 31)
	%drawPart(0x8, 0x4, 0x0, 0x4, 31)
	lis r12, 0x8004
	ori r12, r12, 0x2020
	mtctr r12
	bctr
}
HOOK @ $800428FC
{
	lwz r0, 0x0(r4)
	stw r0, 0x10(r1)
	%drawPart(0x0, 0x4, 0x8, 0xC, 31)
	%drawPart(0x8, 0xC, 0x10, 0x14, 31)
	%drawPart(0x10, 0x14, 0x0, 0x4, 31)
	lis r12, 0x8004
	ori r12, r12, 0x2984
	mtctr r12
	bctr	
}