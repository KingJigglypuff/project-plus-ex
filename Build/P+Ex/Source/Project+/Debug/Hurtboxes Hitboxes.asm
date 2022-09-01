renderDebug/[soCollisionAttackModuleImpl] [Eon]
.macro callFunc(<addr>) 
{
.alias temp_Hi = <addr> / 0x10000
.alias temp_Lo = <addr> & 0xFFFF
  lis r12, temp_Hi
  ori r12, r12, temp_Lo
  mtctr r12
  bctrl	
}
.macro loadFileLoc(<reg>) 
{
	lis <reg>, 0x8054
	ori <reg>, <reg>, 0x8400 
}

HOOK @ $8074BDB0
{
	stwu r1, -0x50(r1)
	mflr r0
	stw r0, 0x54(r1)
	stw r31, 0x4C(r1)
	stw r30, 0x48(r1)
	stw r29, 0x44(r1)
	stw r28, 0x40(r1)
	mr r28, r3

#getCameraMatrix	
	lis r12, 0x8001
	ori r12, r12, 0x9FA4
	mtctr r12
	bctrl
	lwz r4, 0(r3)
	li r30, 0
	lwz r0, 0x4(r3)
	stw r4, 0x8(r1)
	stw r0, 0xC(r1)
	lwz r4, 0x8(r3)
	lwz r0, 0xC(r3)
	stw r4, 0x10(r1)
	stw r0, 0x14(r1)
	lwz r4, 0x10(r3)
	lwz r0, 0x14(r3)
	stw r4, 0x18(r1)
	stw r0, 0x1C(r1)
	lwz r4, 0x18(r3)
	lwz r0, 0x1C(r3)
	stw r4, 0x20(r1)
	stw r0, 0x24(r1)
	lwz r4, 0x20(r3)
	lwz r0, 0x24(r3)
	stw r4, 0x28(r1)
	stw r0, 0x2C(r1)
	lwz r4, 0x28(r3)
	lwz r0, 0x2C(r3)
	stw r4, 0x30(r1)
	stw r0, 0x34(r1)

	b checkLoop
loop:
	lwz r3, 0x30(r28)
	mr r4, r30
	lwz r12, 0(r3)
	lwz r12, 0xC(r12)
	mtctr r12
	bctrl 
	lwz r0, 0(r3)
	cmpwi r0, 0
	beq iterate
	mr r29, r3
	mr r4, r30
	lwz r5, 0x88(r3)
	addi r3, r28, 0x68 
	lis r12, 0x8074
	ori r12, r12, 0x0A3C
	mtctr r12
	bctrl

	mr r6, r29
	mr r5, r3
	mr r3, r31
	addi r4, r1, 8
	mr r7, r30
	%callFunc(0x80541fa4)
	
iterate:
	addi r30, r30, 1
checkLoop:
	lwz r3, 0x30(r28)
	lwz r12, 0(r3)
	lwz r12, 0x14(r12)
	mtctr r12
	bctrl 
	cmpw r30, r3
	blt loop

end:
	lwz r0, 0x54(r1)
	lwz r31, 0x4C(r1)
	lwz r30, 0x48(r1)
	lwz r29, 0x44(r1)
	lwz r28, 0x40(r1)
	mtlr r0
	addi r1, r1, 80
	blr 
}

.alias hitboxList = 0x64
.alias hitboxListLength = 8
.macro storeColourSet(<primary>, <secondary>, <fileReg>)
{
	
	%storeColour(<primary>+0, <secondary>+0, <fileReg>, 0)
	%storeColour(<primary>+1, <secondary>+1, <fileReg>, 1)
	%storeColour(<primary>+2, <secondary>+2, <fileReg>, 2)
	%storeAlpha(<primary>+3, <secondary>+3,  <fileReg>, 3)
}
.macro storeColour(<primary>, <secondary>, <fileReg>, <offset>)
{
	lbz r0, <offset>(<fileReg>)
	stb r0, <primary>(r1)
	srwi r0, r0, 1
	stb r0, <secondary>(r1)
}
.macro storeAlpha(<primary>, <secondary>, <fileReg>, <offset>)
{
	lbz r0, <offset>(<fileReg>)
	stb r0, <primary>(r1)
	stb r0, <secondary>(r1)	
}

#r3 = soCollisionAttack
#r4 = camera obj
#r5 = clCapsule/clSphere
#r6 = hitbox data
#r7 = hitbox ID
HOOK @ $80541fa4
{
debugDisplaySoCollisionAttackPart:
	stwu r1, -0xA0(r1)
	mflr r0
	stw r0, 0xA4(r1)
	stw r31, 0x1C(r1)
	stw r30, 0x18(r1)
	stw r29, 0x14(r1)
	mr r30, r5
	mr r29, r6
	mr r31, r4
	lwz r0, 0(r3)
	cmpwi r0, 1
	beq skip


	cmpwi r7, hitboxListLength
	blt 0x8
	li r7, hitboxListLength
	mulli r3, r7, 4
	addi r3, r3, hitboxList

	%loadFileLoc(7)
	add r7, r7, r3
	%storeColourSet(0x8, 0xC, 7)

	mr r3, r30
	mr r4, r31
	#r4 from input = camera matrix
	addi r5, r1, 0x8
	addi r6, r1, 0xC
	lwz r12, 0x30(r3)
	lwz r12, 0x24(r12)
	mtctr r12
	bctrl 
skip:
	lwz r0, 0xA4(r1)
	
	lwz r31, 0x1C(r1)
	lwz r30, 0x18(r1)
	lwz r29, 0x14(r1)
	mtlr r0
	addi r1, r1, 0xA0
	blr 
}

renderDebug/[soCollisionHitModuleImpl]
.macro callFunc(<addr>) 
{
.alias temp_Hi = <addr> / 0x10000
.alias temp_Lo = <addr> & 0xFFFF
  lis r12, temp_Hi
  ori r12, r12, temp_Lo
  mtctr r12
  bctrl	
}
.macro loadFileLoc(<reg>) 
{
	lis <reg>, 0x8054
	ori <reg>, <reg>, 0x8400 
}

.macro storeColourSet(<primary>, <secondary>, <fileReg>, <offset>)
{
	%storeColour(<primary>+0, <secondary>+0, <fileReg>, <offset>+0)
	%storeColour(<primary>+1, <secondary>+1, <fileReg>, <offset>+1)
	%storeColour(<primary>+2, <secondary>+2, <fileReg>, <offset>+2)
	%storeAlpha(<primary>+3, <secondary>+3, <fileReg>, <offset>+3)
}
.macro storeColour(<primary>, <secondary>, <fileReg>, <offset>)
{
	lbz r0, <offset>(<fileReg>)
	stb r0, <primary>(r1)
	srwi r0, r0, 1
	stb r0, <secondary>(r1)
}
.macro storeAlpha(<primary>, <secondary>, <fileReg>, <offset>)
{
	lbz r0, <offset>(<fileReg>)
	stb r0, <primary>(r1)
	stb r0, <secondary>(r1)	
}
.alias vulnerable 			= 0x40
.alias grabInvulnerable     = 0x44
.alias invincible 			= 0x48
.alias intangible 			= 0x4C


HOOK @ $80750F58
{
	stwu r1, -0x50(r1)
	mflr r0
	stw r0, 0x54(r1)
	stw r31, 0x4C(r1)
	stw r30, 0x48(r1)
	stw r29, 0x44(r1)
	stw r28, 0x40(r1)
	mr r28, r3
	mr r29, r4

	lhz r0, 0x0066(r3)
	rlwinm. r0, r0, 18, 31, 31
	bne end

#getCameraMatrix
	lis r12, 0x8001
	ori r12, r12, 0x9FA4
	mtctr r12
	bctrl
	
	lwz r4, 0(r3)
	li r30, 0
	lwz r0, 0x4(r3)
	stw r4, 0x8(r1)
	stw r0, 0xC(r1)
	lwz r4, 0x8(r3)
	lwz r0, 0xC(r3)
	stw r4, 0x10(r1)
	stw r0, 0x14(r1)
	lwz r4, 0x10(r3)
	lwz r0, 0x14(r3)
	stw r4, 0x18(r1)
	stw r0, 0x1C(r1)
	lwz r4, 0x18(r3)
	lwz r0, 0x1C(r3)
	stw r4, 0x20(r1)
	stw r0, 0x24(r1)
	lwz r4, 0x20(r3)
	lwz r0, 0x24(r3)
	stw r4, 0x28(r1)
	stw r0, 0x2C(r1)
	lwz r4, 0x28(r3)
	lwz r0, 0x2C(r3)
	stw r4, 0x30(r1)
	stw r0, 0x34(r1)
start:
	#getGroupNumber
	mr r3, r28
	lwz r12, 0x0(r28)
	lwz r12, 0xBC(r12)
	mtctr r12
	bctrl 

	mr r31, r3
	li r30, 0
	b checkLoop
loop:
	mr r3, r28
	mr r4, r29
	mr r5, r30
	addi r6, r1, 0x8
	%callFunc(0x80541fa8)
iterate:
	addi r30, r30, 1
checkLoop:
	cmpw r30, r31
	blt loop
end:
	lwz r0, 0x54(r1)
	lwz r31, 0x4C(r1)
	lwz r30, 0x48(r1)
	lwz r29, 0x44(r1)
	lwz r28, 0x40(r1)
	mtlr r0
	addi r1, r1, 0x50
	blr 
}
HOOK @ $80541fa8
{
renderDebugSoCollisionHitGroup:
	stwu r1, -0x30(r1)
	mflr r0
	stw r0, 0x34(r1)
	stw r31, 0x2C(r1)
	stw r30, 0x28(r1)
	stw r29, 0x24(r1)
	stw r28, 0x20(r1)
	stw r27, 0x16(r1)
	mr r29, r3
	mr r30, r4
	mr r31, r5
	mr r28, r6
	
	lhz r0, 0x66(r3)
	rlwinm r0, r0, 18, 31, 31
	cmpwi r0, 1
	beq endInner

	lwz r6, 0x2C(r3)
	mr r4, r5
	lwz r3, 0x58(r3)
	lwz r5, 0xD8(r6)
	lwz r12, 0(r3)
	lwz r31, 0x4(r5)
	lwz r12, 0xC(r12)
	mtctr r12
	bctrl 


	addi	r4, r29, 56
	lwz	r5, 0x30(r29)
	mr	r6, r31
	mr r7, r28

	%callFunc(0x80541fac)
	
endInner:
	lwz r0, 0x34(r1)
	lwz r31, 0x2C(r1)
	lwz r30, 0x28(r1)
	lwz r29, 0x24(r1)
	lwz r28, 0x20(r1)
	mtlr r0
	addi r1, r1, 0x30
	blr 
}
HOOK @ $80541fac
{
renderDebugSoCollisionHitGroupInner:
	stwu r1, -0x40(r1)
	mflr r0
	stw r0, 0x44(r1)
	addi r11, r1, 0x40
	lis r12, 0x803F
	ori r12, r12, 0x130C
	mtctr r12
	bctrl
	
	lwz r0, 0(r3)
	cmpwi r0, -1
	beq renderDebugSoCollisionHitGroupEnd
	mr r28, r3
	mr r29, r4
	mr r30, r5
	mr r31, r6 
	mr r26, r7

renderDebugSoCollisionHitGroupLoopStart:
	li r22, 0
	b renderDebugSoCollisionHitGroupLoopCheck
renderDebugSoCollisionHitGroupLoop:
	lwz r12, 0(r30)
	mr r3, r30
	lha r0, 0x4(r28)
	lwz r12, 0xC(r12)
	add r4, r0, r22
	mtctr r12
	bctrl 
	lwz r5, 0(r28)
	mr r27, r3
	mr r3, r29
	mr r4, r22
	lis r12, 0x8074
	ori r12, r12 0x0A3C 
	mtctr r12
	bctrl

	mr r5, r3
	mr r3, r31
	mr r4, r26
	mr r6, r27
	mr r7, r28
	%callFunc(0x80541fb0)
renderDebugSoCollisionHitGroupIterate:
	addi r22, r22, 1
renderDebugSoCollisionHitGroupLoopCheck:
	lha r0, 0x6(r28)
	cmpw r22, r0
	blt renderDebugSoCollisionHitGrouploop
renderDebugSoCollisionHitGroupEnd:
	addi r11, r1, 0x40
	lis r12, 0x803F
	ori r12, r12, 0x1358
	mtctr r12
	bctrl
	
	lwz r0, 0x44(r1)
	mtlr r0
	addi r1, r1, 0x40
	blr 
}
HOOK @ $80541fb0
{
debugDisplaySoCollisionHitPart:
	stwu r1, -0x40(r1)
	mflr r0
	stw r0, 0x44(r1)
	stw r31, 0x3C(r1)
	stw r30, 0x38(r1)
	stw r29, 0x34(r1)
	stw r28, 0x30(r1)
	stw r27, 0x2C(r1)
	mr r28, r3 
	mr r29, r4 #camera data?
	mr r30, r5 #hurtbox location
	mr r31, r6 #specific hurtbox pointer
	mr r27, r7 #overarching hurtbox container



	lwz r0, 0(r31)
	cmpwi r0, 3
	beq skip

	lwz r0, 0x1C(r27)
	cmpwi r0, 3
	beq skip
	cmpwi r0, 0
	bne checkStates

	lwz r3, 0x54(r31)
	subi r0, r3, 1
	cmplwi r0, 0
	bgt checkStates
	lwz r0, 0(r31)

checkStates:
	%loadFileLoc(4)
	cmpwi r0, 0
	beq normal
	cmpwi r0, 1
	beq invince
	cmpwi r0, 2
	beq intang 
	cmpwi r0, 3
	beq intang 
	cmpwi r0, 4
	beq intang 
	b skip 
normal:
	lwz r3, 0x24(r31)
	rlwinm r3, r3, 11, 30, 31 #and 0x00600000 and shift so 0x00200000 = 1
	cmpwi r3, 1
	beq ungrabbable
	cmpwi r3, 2
	beq ungrabbable
grabbable:
	%storeColourSet(0x8, 0xC, 4, vulnerable)
	b drawHurtbox
ungrabbable:
	%storeColourSet(0x8, 0xC, 4, grabInvulnerable)
	b drawHurtbox
invince:
	%storeColourSet(0x8, 0xC, 4, invincible)
	b drawHurtbox
intang: 

	%storeColourSet(0x8, 0xC, 4, intangible)
	b drawHurtbox
drawHurtbox:
	addi r5, r1, 0x8
	addi r6, r1, 0xC
	mr r3, r30
	mr r4, r29
	lwz r12, 0x30(r3)
	lwz r12, 0x24(r12)
	mtctr r12
	bctrl 
skip:
	lwz r0, 0x44(r1)
	lwz r31, 0x3C(r1)
	lwz r30, 0x38(r1)
	lwz r29, 0x34(r1)
	lwz r28, 0x30(r1)
	lwz r27, 0x2C(r1)
	
	mtlr r0
	addi r1, r1, 0x40
	blr 
}

Bubble Colour Modifiers
.macro loadFileLoc(<reg>) 
{
	lis <reg>, 0x8054
	ori <reg>, <reg>, 0x8400 
}
.macro storeColourSet(<primary>, <secondary>, <fileReg>, <offset>)
{
	%storeColour(<primary>+0, <secondary>+0, <fileReg>, <offset>+0)
	%storeColour(<primary>+1, <secondary>+1, <fileReg>, <offset>+1)
	%storeColour(<primary>+2, <secondary>+2, <fileReg>, <offset>+2)
	%storeAlpha(<primary>+3, <secondary>+3, <fileReg>, <offset>+3)
}
.macro storeColour(<primary>, <secondary>, <fileReg>, <offset>)
{
	lbz r0, <offset>(<fileReg>)
	stb r0, <primary>(r1)
	srwi r0, r0, 1
	stb r0, <secondary>(r1)
}
.macro storeAlpha(<primary>, <secondary>, <fileReg>, <offset>)
{
	lbz r0, <offset>(<fileReg>)
	stb r0, <primary>(r1)
	stb r0, <secondary>(r1)	
}
.alias grabbox 				= 0x50
.alias shieldbox 			= 0x54
.alias reflectorbox			= 0x58
.alias absorberbox 			= 0x5C
.alias searchbox			= 0x60

#Shields etc
HOOK @ $807513F4
{	
	%loadFileLoc(5)

	#0x1C Shield Main / Reflector
	#0x18 Shield Secondary
	%storeColourSet(0x1C, 0x18, 5, shieldbox)

	#0x14 Reflector Main
	#0x10 Reflector Secondary
	%storeColourSet(0x14, 0x10, 5, reflectorbox)

	#0x0C Absorber Main
	#0x08 Absorber Secondary
	%storeColourSet(0x0C, 0x08, 5, absorberbox)
}
#Grab
HOOK @ $80755B6C
{
	%loadFileLoc(7)
	#0x08 #Grab Main
	#0x0C #Grab Secondary
	%storeColourSet(0xC, 0x8, 7, grabbox)
}
#Search
HOOK @ $8075868C
{
	%loadFileLoc(7)
	#0x08 #Search Main
	#0x0C #Search Secondary
	%storeColourSet(0xC, 0x8, 7, searchbox)
}
