#####################################
[CM: Code Menu] FPS Code [UnclePunch]
#####################################
HOOK @ $80023D5C                # Address = $(ba + 0x00023D5C)
{
	lbz r3, -0x3bcc(r13)
	addi r3, r3, 0x1
	stb r3, -0x3bcc(r13)
	lbz r0, 0x8(r31)
	nop
}
HOOK @ $80023D7C                # Address = $(ba + 0x00023D7C)
{
	lbz r3, -0x3bcb(r13)
	addi r3, r3, 0x1
	stb r3, -0x3bcb(r13)
	cmpwi r3, 0x3c
	blt loc_0x00A
	lbz r3, -0x3bcc(r13)
	sth r3, -0x3bca(r13)
	li r3, 0x0
	stb r3, -0x3bcc(r13)
	stb r3, -0x3bcb(r13)
loc_0x00A:
	lwz r0, 0x14(r1)
}

###############################
[CM: Code Menu] Print Code Menu
###############################
HOOK @ $80017928                # Address = $(ba + 0x00017928)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	bl 0x387c
	stwu r1, -0xf4(r1)
	stmw r3, 0x8(r1)
	lis r31, 0x804e
	lwz r31, 0x34(r31)
	lis r28, 0x804e
	lwzu r30, 0x74(r28)
	or r29, r31, r30
	cmpwi r29, 0x4
	blt loc_0x055
	lis r29, 0x805b
	ori r29, r29, 0x6d20
	lis r5, 0x804e
	lwzu r4, 0x298(r5)
	cmpwi r4, 0x0
	bne loc_0x01E
	li r6, 0x1
	stw r6, 0x0(r5)
	lis r30, 0x804e
	ori r30, r30, 0x268
	li r6, 0x30
	addi r3, r30, 0x0
	addi r4, r29, 0x0
	addi r5, r6, 0x0
	bla 0x3f602c
loc_0x01E:
	lis r4, 0x3f80
	stw r4, 0x0(r29)
	li r4, 0x0
	stw r4, 0x4(r29)
	li r4, 0x0
	stw r4, 0x8(r29)
	li r4, 0x0
	stw r4, 0xc(r29)
	li r4, 0x0
	stw r4, 0x10(r29)
	lis r4, 0x3f80
	stw r4, 0x14(r29)
	li r4, 0x0
	stw r4, 0x18(r29)
	li r4, 0x0
	stw r4, 0x1c(r29)
	li r4, 0x0
	stw r4, 0x20(r29)
	li r4, 0x0
	stw r4, 0x24(r29)
	lis r4, 0x3f80
	stw r4, 0x28(r29)
	lis r4, 0xc280
	stw r4, 0x2c(r29)
	bla 0x19fa4
	bla 0x18de4
	bla 0x1a5c0
	li r3, 0x80
	li r4, 0x1
	li r5, 0x4
	bla 0x1f1088
	lis r3, 0xcc01
	lis r6, 0x3f00
	lis r4, 0xc580
	lis r5, 0x4580
	li r7, 0xff
	stw r4, -0x8000(r3)
	stw r5, -0x8000(r3)
	stw r6, -0x8000(r3)
	stw r7, -0x8000(r3)
	lis r4, 0x4580
	stw r4, -0x8000(r3)
	stw r5, -0x8000(r3)
	stw r6, -0x8000(r3)
	stw r7, -0x8000(r3)
	lis r5, 0xc580
	stw r4, -0x8000(r3)
	stw r5, -0x8000(r3)
	stw r6, -0x8000(r3)
	stw r7, -0x8000(r3)
	lis r4, 0xc580
	stw r4, -0x8000(r3)
	stw r5, -0x8000(r3)
	stw r6, -0x8000(r3)
	stw r7, -0x8000(r3)
loc_0x055:
	cmpwi r31, 0x4
	bne loc_0x0E6
	lis r30, 0x805b
	ori r30, r30, 0x6df8
	lis r31, 0x3eb2
	ori r31, r31, 0xb8c2
	stw r31, 0x0(r30)
	lis r31, 0x804e
	lwz r31, 0x0(r31)
	lis r30, 0x804e
	ori r30, r30, 0x320
	addi r3, r30, 0x0
	li r4, 0x0
	li r5, 0x9
	bla 0x6a964
	bla 0x19fa4
	bla 0x18de4
	lis r3, 0x804e
	ori r3, r3, 0x368
	lis r4, 0x8049
	ori r4, r4, 0x7e44
	stw r4, 0x0(r3)
	lis r25, 0x804e
	ori r25, r25, 0x7b4
	lis r29, 0xc348
	lis r28, 0xc316
	lwz r26, 0xc(r31)
	lwz r24, 0x0(r31)
	add r24, r31, r24
	lbz r24, 0x7(r24)
	cmpw r24, r26
	ble loc_0x077
	mr r26, r24
	b loc_0x07B
loc_0x077:
	addi r27, r24, 0xa
	cmpw r27, r26
	bge loc_0x07B
	mr r26, r27
loc_0x07B:
	stw r26, 0xc(r31)
	cmpwi r26, 0xf
	ble loc_0x098
	subi r27, r26, 0xf
	mulli r27, r27, -0x12
	li r24, 0x0
	cmpwi r27, 0x0
	beq loc_0x08F
	cmpwi r27, 0x0
	bge loc_0x087
	lis r24, 0x8000
	neg r27, r27
loc_0x087:
	cntlzw r26, r27
	subi r26, r26, 0x8
	rlwnm r27, r27, r26, 9, 31      # (Mask: 0x007fffff)
	or r24, r24, r27
	subi r26, r26, 0x96
	neg r26, r26
	rlwinm r26, r26, 23, 1, 0       # (Mask: 0xffffffff)
	or r24, r24, r26
loc_0x08F:
	lis r27, 0x804e
	ori r27, r27, 0x648
	stw r24, 0x0(r27)
	lfs f0, 0x0(r27)
	stw r28, 0x0(r27)
	lfs f1, 0x0(r27)
	fadds f0, f0, f1
	stfs f0, 0x0(r27)
	lwz r28, 0x0(r27)
loc_0x098:
	stw r29, 0x2c(r30)
	stw r28, 0x30(r30)
	lis r29, 0x3d75
	ori r29, r29, 0xc28f
	stw r29, 0x50(r30)
	addi r28, r31, 0x14
	li r3, 0x1
	cmpwi r3, 0x0
	beq loc_0x0E5
loc_0x0A1:
	lbz r26, 0x3(r28)
	andi. r26, r26, 0x2
	bne loc_0x0E1
	lbz r26, 0x2(r28)
	lbz r27, 0x4(r28)
	lwzx r27, r25, r27
	stw r27, 0x8(r30)
	stw r27, 0xc(r30)
	stw r27, 0x10(r30)
	stw r27, 0x14(r30)
	lhz r4, 0x5(r28)
	add r4, r4, r28
	cmpwi r26, 0x5
	bne loc_0x0BA
	lwz r27, 0xc(r28)
	lhz r26, 0x0(r28)
	mulli r27, r27, 0x4
	subf r26, r27, r26
	mtxer r27
	lswx r5, r26, r28
	lis r3, 0x804e
	ori r3, r3, 0x648
	crxor 6, 6, 6
	bla 0x3f89fc
	b loc_0x0CE
loc_0x0BA:
	cmpwi r26, 0x2
	bne loc_0x0C2
	lfs f1, 0x8(r28)
	lis r3, 0x804e
	ori r3, r3, 0x648
	cmpw cr1, r1, r1
	bla 0x3f89fc
	b loc_0x0CE
loc_0x0C2:
	lwz r5, 0x8(r28)
	cmpwi r26, 0x0
	bne loc_0x0CA
	lwz r26, 0x18(r28)
	addi r27, r26, 0x1c
	rlwinm r5, r5, 2, 0, 31         # (Mask: 0xffffffff)
	lhzx r5, r27, r5
	add r5, r5, r26
loc_0x0CA:
	lis r3, 0x804e
	ori r3, r3, 0x648
	crxor 6, 6, 6
	bla 0x3f89fc
loc_0x0CE:
	mr r26, r3
	lis r27, 0x804e
	ori r27, r27, 0x647
	cmpwi r26, 0x0
	ble loc_0x0D9
loc_0x0D3:
	lbzu r4, 0x1(r27)
	addi r3, r30, 0x0
	bla 0x6fe50
	subi r26, r26, 0x1
	cmpwi r26, 0x0
	bgt+ loc_0x0D3
loc_0x0D9:
	lis r3, 0xc348
	lfs f0, 0x30(r30)
	lis r4, 0x4190
	stw r4, -0x10(r1)
	lfs f1, -0x10(r1)
	fadd f0, f0, f1
	stw r3, 0x2c(r30)
	stfs f0, 0x30(r30)
loc_0x0E1:
	lhz r3, 0x0(r28)
	lhzux r3, r28, r3
	cmpwi r3, 0x0
	bne+ loc_0x0A1
loc_0x0E5:
	b loc_0x14D
loc_0x0E6:
	cmpwi r30, 0x0
	beq loc_0x0F9
	lis r29, 0x805b
	ori r29, r29, 0x6df8
	li r31, 0x0
	stw r30, 0x0(r29)
	stw r31, 0x0(r28)
	lis r3, 0x805b
	ori r3, r3, 0x6d20
	lis r4, 0x804e
	ori r4, r4, 0x268
	li r30, 0x30
	addi r5, r30, 0x0
	bla 0x3f602c
	li r3, 0x0
	lis r4, 0x804e
	ori r4, r4, 0x298
	stw r3, 0x0(r4)
	b loc_0x14D
loc_0x0F9:
	bla 0x2e844
	lis r31, 0x804e
	lwz r31, 0xe94(r31)
	cmpwi r31, 0x1
	bne loc_0x14D
	li r31, 0x0
	lwz r23, -0x42ac(r13)
	lwz r22, -0x42a8(r13)
	stw r31, -0x42ac(r13)
	stw r31, -0x42a8(r13)
	lis r31, 0x804e
	ori r31, r31, 0x6c8
	lis r4, 0x4650
	ori r4, r4, 0x533a
	stw r4, 0x0(r31)
	lis r4, 0x2025
	ori r4, r4, 0x3264
	stw r4, 0x4(r31)
	li r4, 0x0
	stw r4, 0x8(r31)
	lis r30, 0x805a
	lhz r30, 0x856(r30)
	lis r3, 0x804e
	ori r3, r3, 0x648
	addi r4, r31, 0x0
	addi r5, r30, 0x0
	crxor 6, 6, 6
	bla 0x3f89fc
	lis r31, 0x804e
	ori r31, r31, 0x647
	mr r26, r3
	lis r29, 0x804e
	ori r29, r29, 0x320
	addi r3, r29, 0x0
	li r4, 0x0
	li r5, 0x9
	bla 0x6a964
	bla 0x19fa4
	bla 0x18de4
	lis r3, 0x804e
	ori r3, r3, 0x368
	lis r4, 0x8049
	ori r4, r4, 0x7e44
	stw r4, 0x0(r3)
	lis r3, 0x805b
	ori r3, r3, 0x71f0
	li r4, 0x0
	bla 0x1f51dc
	lis r28, 0x805b
	ori r28, r28, 0x6df8
	lfs f1, 0x0(r28)
	lis r28, 0x3ea8
	ori r28, r28, 0xf5c3
	stw r28, -0x10(r1)
	lfs f2, -0x10(r1)
	fmuls f2, f2, f1
	stfs f2, 0x50(r29)
	lis r28, 0xc325
	lis r27, 0xc2e6
	stw r28, 0x2c(r29)
	stw r27, 0x30(r29)
	lis r28, 0x805a
	lhz r28, 0x856(r28)
	cmpwi r30, 0x3c
	bge loc_0x13D
	lis r30, 0xff00
	ori r30, r30, 0xff
	b loc_0x13F
loc_0x13D:
	lis r30, 0x66
	ori r30, r30, 0xffff
loc_0x13F:
	stw r30, 0x8(r29)
	stw r30, 0xc(r29)
	stw r30, 0x10(r29)
	stw r30, 0x14(r29)
	stw r23, -0x42ac(r13)
	stw r22, -0x42a8(r13)
	cmpwi r26, 0x0
	ble loc_0x14D
loc_0x147:
	lbzu r4, 0x1(r31)
	addi r3, r29, 0x0
	bla 0x6fe50
	subi r26, r26, 0x1
	cmpwi r26, 0x0
	bgt+ loc_0x147
loc_0x14D:
	lmw r3, 0x8(r1)
	addi r1, r1, 0xf4
	bl 0x33d0
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
}

#################################
[CM: Code Menu] Control Code Menu
#################################
HOOK @ $80029574                # Address = $(ba + 0x00029574)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	bl 0x331c
	stwu r1, -0xf4(r1)
	stmw r3, 0x8(r1)
	lis r3, 0x2530
	ori r3, r3, 0x3258
	lis r28, 0x804e
	ori r28, r28, 0x6c8
	stw r3, 0x0(r28)
	li r3, 0x0
	stw r3, 0x4(r28)
	lis r25, 0x804e
	ori r25, r25, 0x1e1
	lis r26, 0x8058
	ori r26, r26, 0x82dc
	mr r31, r25
	lwzu r27, 0x4(r26)
	cmpwi r27, 0x0
	beq loc_0x037
	addi r27, r27, 0x1fc
	lwz r3, 0x44(r27)
	subi r3, r3, 0x1
	cmplwi r3, 0x78
	bge loc_0x037
	mulli r3, r3, 0x2
	addi r3, r3, 0x70
	lhzx r3, r27, r3
	cmplwi r3, 0x78
	bge loc_0x037
	mulli r3, r3, 0x124
	lis r30, 0x9017
	ori r30, r30, 0x2e20
	add r30, r30, r3
	li r24, 0x0
	lhz r29, 0x0(r30)
	cmpwi r29, 0x0
	beq loc_0x037
loc_0x029:
	cmpwi r24, 0x4
	bgt loc_0x034
	lbz r29, 0x0(r30)
	mr r3, r31
	mr r4, r28
	mr r5, r29
	crxor 6, 6, 6
	bla 0x3f89fc
	add r31, r31, r3
	lhzu r29, 0x1(r30)
	b loc_0x035
loc_0x034:
	li r29, 0x0
loc_0x035:
	cmpwi r29, 0x0
	bne+ loc_0x029
loc_0x037:
	li r3, 0x0
	stb r3, 0x0(r31)
	lis r3, 0x804e
	ori r3, r3, 0x1424
	subi r4, r25, 0x1
	stw r4, 0x0(r3)
	addi r25, r25, 0x18
	mr r31, r25
	lwzu r27, 0x4(r26)
	cmpwi r27, 0x0
	beq loc_0x062
	addi r27, r27, 0x1fc
	lwz r3, 0x44(r27)
	subi r3, r3, 0x1
	cmplwi r3, 0x78
	bge loc_0x062
	mulli r3, r3, 0x2
	addi r3, r3, 0x70
	lhzx r3, r27, r3
	cmplwi r3, 0x78
	bge loc_0x062
	mulli r3, r3, 0x124
	lis r30, 0x9017
	ori r30, r30, 0x2e20
	add r30, r30, r3
	li r24, 0x0
	lhz r29, 0x0(r30)
	cmpwi r29, 0x0
	beq loc_0x062
loc_0x054:
	cmpwi r24, 0x4
	bgt loc_0x05F
	lbz r29, 0x0(r30)
	mr r3, r31
	mr r4, r28
	mr r5, r29
	crxor 6, 6, 6
	bla 0x3f89fc
	add r31, r31, r3
	lhzu r29, 0x1(r30)
	b loc_0x060
loc_0x05F:
	li r29, 0x0
loc_0x060:
	cmpwi r29, 0x0
	bne+ loc_0x054
loc_0x062:
	li r3, 0x0
	stb r3, 0x0(r31)
	lis r3, 0x804e
	ori r3, r3, 0x1688
	subi r4, r25, 0x1
	stw r4, 0x0(r3)
	addi r25, r25, 0x18
	mr r31, r25
	lwzu r27, 0x4(r26)
	cmpwi r27, 0x0
	beq loc_0x08D
	addi r27, r27, 0x1fc
	lwz r3, 0x44(r27)
	subi r3, r3, 0x1
	cmplwi r3, 0x78
	bge loc_0x08D
	mulli r3, r3, 0x2
	addi r3, r3, 0x70
	lhzx r3, r27, r3
	cmplwi r3, 0x78
	bge loc_0x08D
	mulli r3, r3, 0x124
	lis r30, 0x9017
	ori r30, r30, 0x2e20
	add r30, r30, r3
	li r24, 0x0
	lhz r29, 0x0(r30)
	cmpwi r29, 0x0
	beq loc_0x08D
loc_0x07F:
	cmpwi r24, 0x4
	bgt loc_0x08A
	lbz r29, 0x0(r30)
	mr r3, r31
	mr r4, r28
	mr r5, r29
	crxor 6, 6, 6
	bla 0x3f89fc
	add r31, r31, r3
	lhzu r29, 0x1(r30)
	b loc_0x08B
loc_0x08A:
	li r29, 0x0
loc_0x08B:
	cmpwi r29, 0x0
	bne+ loc_0x07F
loc_0x08D:
	li r3, 0x0
	stb r3, 0x0(r31)
	lis r3, 0x804e
	ori r3, r3, 0x18ec
	subi r4, r25, 0x1
	stw r4, 0x0(r3)
	addi r25, r25, 0x18
	mr r31, r25
	lwzu r27, 0x4(r26)
	cmpwi r27, 0x0
	beq loc_0x0B8
	addi r27, r27, 0x1fc
	lwz r3, 0x44(r27)
	subi r3, r3, 0x1
	cmplwi r3, 0x78
	bge loc_0x0B8
	mulli r3, r3, 0x2
	addi r3, r3, 0x70
	lhzx r3, r27, r3
	cmplwi r3, 0x78
	bge loc_0x0B8
	mulli r3, r3, 0x124
	lis r30, 0x9017
	ori r30, r30, 0x2e20
	add r30, r30, r3
	li r24, 0x0
	lhz r29, 0x0(r30)
	cmpwi r29, 0x0
	beq loc_0x0B8
loc_0x0AA:
	cmpwi r24, 0x4
	bgt loc_0x0B5
	lbz r29, 0x0(r30)
	mr r3, r31
	mr r4, r28
	mr r5, r29
	crxor 6, 6, 6
	bla 0x3f89fc
	add r31, r31, r3
	lhzu r29, 0x1(r30)
	b loc_0x0B6
loc_0x0B5:
	li r29, 0x0
loc_0x0B6:
	cmpwi r29, 0x0
	bne+ loc_0x0AA
loc_0x0B8:
	li r3, 0x0
	stb r3, 0x0(r31)
	lis r3, 0x804e
	ori r3, r3, 0x1b50
	subi r4, r25, 0x1
	stw r4, 0x0(r3)
	addi r25, r25, 0x18
	lis r31, 0x804e
	lwz r28, 0x4(r31)
	addi r31, r31, 0x7d8
	cmplw r31, r28
	bne loc_0x44B
	lis r28, 0x804e
	lwz r28, 0xec4(r28)
	cmpwi r28, 0x0
	bne loc_0x0D2
	lis r28, 0x804e
	ori r28, r28, 0x29c
	li r31, 0x1
	stw r31, 0x0(r28)
	lis r3, 0x8067
	ori r3, r3, 0x2f40
	li r4, 0x8
	li r5, 0x0
	bla 0xd234
	b loc_0x0DD
loc_0x0D2:
	lis r28, 0x804e
	lwzu r31, 0x29c(r28)
	cmpwi r31, 0x1
	bne loc_0x0DD
	lis r3, 0x8067
	ori r3, r3, 0x2f40
	li r4, 0x8
	li r5, 0x1
	bla 0xd234
	li r31, 0x0
	stw r31, 0x0(r28)
loc_0x0DD:
	lis r28, 0x804e
	lwzu r19, 0x34(r28)
	lis r31, 0x805b
	ori r31, r31, 0xacc4
	lis r25, 0x804d
	ori r25, r25, 0xe4a8
	li r15, 0x0
	li r18, 0x0
	li r17, 0x0
	li r16, 0x0
	cmpwi r16, 0x4
	bge loc_0x100
loc_0x0E9:
	lhzu r24, 0x8(r25)
	lwzu r30, 0x40(r31)
	cmplwi r24, 0x2000
	blt loc_0x0EE
	li r24, 0x0
loc_0x0EE:
	andi. r24, r24, 0x1000
	or r15, r15, r30
	or r15, r15, r24
	andi. r24, r30, 0x64
	cmpwi r24, 0x60
	ble loc_0x0F7
	cmpwi r19, 0x4
	beq loc_0x0F7
	li r19, 0x2
loc_0x0F7:
	lbz r30, 0x2c(r31)
	extsb r30, r30
	add r18, r18, r30
	lbz r30, 0x2d(r31)
	extsb r30, r30
	add r17, r17, r30
	addi r16, r16, 0x1
	cmpwi r16, 0x4
	blt+ loc_0x0E9
loc_0x100:
	li r16, 0x0
	cmpwi r16, 0x4
	bge loc_0x10D
loc_0x103:
	addi r31, r31, 0x40
	lbz r30, 0x2c(r31)
	extsb r30, r30
	add r18, r18, r30
	lbz r30, 0x2d(r31)
	extsb r30, r30
	add r17, r17, r30
	addi r16, r16, 0x1
	cmpwi r16, 0x4
	blt+ loc_0x103
loc_0x10D:
	lis r31, 0x804f
	ori r31, r31, 0x6ee0
	li r29, 0x1
	li r24, 0x0
	cmpwi r24, 0x4
	bge loc_0x13B
loc_0x113:
	lhzu r27, 0x9a0(r31)
	lis r26, 0x804e
	ori r26, r26, 0x1b0
	lbz r25, 0x28(r31)
	cmpwi r25, 0x2
	bne loc_0x124
	lhz r27, 0x2a(r31)
	andi. r23, r27, 0xc003
	cmpwi r23, 0x0
	beq loc_0x123
	andi. r23, r27, 0x2200
	cmpwi r23, 0x2200
	bne loc_0x123
	cmpwi r19, 0x4
	beq loc_0x123
	li r19, 0x2
loc_0x123:
	b loc_0x12A
loc_0x124:
	andi. r23, r27, 0x1900
	cmpwi r23, 0x1900
	bne loc_0x12A
	cmpwi r19, 0x4
	beq loc_0x12A
	li r19, 0x2
loc_0x12A:
	mulli r25, r25, 0x10
	add r26, r26, r25
	cmpwi r27, 0x0
	ble loc_0x138
loc_0x12E:
	andi. r25, r27, 0x1
	cmpwi r25, 0x0
	beq loc_0x134
	lbz r25, 0x0(r26)
	rlwnm r25, r29, r25, 15, 31     # (Mask: 0x0001ffff)
	or r15, r15, r25
loc_0x134:
	addi r26, r26, 0x1
	rlwinm r27, r27, 31, 15, 31     # (Mask: 0x0003fffe)
	cmpwi r27, 0x0
	bgt+ loc_0x12E
loc_0x138:
	addi r24, r24, 0x1
	cmpwi r24, 0x4
	blt+ loc_0x113
loc_0x13B:
	lis r27, 0x805c
	lwzu r29, -0x75f8(r27)
	cmpwi r19, 0x1
	bne loc_0x145
	li r19, 0x0
	andi. r24, r15, 0x1100
	cmpwi r24, 0x0
	beq loc_0x144
	li r19, 0x2
loc_0x144:
	b loc_0x151
loc_0x145:
	cmpwi r19, 0x2
	bne loc_0x151
	lis r30, 0x804e
	lwz r30, 0xc30(r30)
	cmplwi cr1, r30, 0x1
	blt cr1, loc_0x151
	lis r30, 0x804e
	lwz r30, 0x758(r30)
	cmplwi r30, 0x1
	word 0x4C461102                 # crandc 2, 6, 2
	beq loc_0x151
	li r19, 0x0
loc_0x151:
	cmpwi r19, 0x2
	bne loc_0x161
	lis r30, 0x804e
	ori r30, r30, 0x6c
	li r19, 0x4
	stw r29, 0x0(r30)
	lis r29, 0x804e
	ori r29, r29, 0x74
	lis r31, 0x805b
	lwz r31, 0x6df8(r31)
	stw r31, 0x0(r29)
	lis r30, 0x804e
	ori r30, r30, 0x44
	stw r15, 0x0(r30)
	li r4, 0x5
	bl 0x2e68
loc_0x161:
	lis r29, 0x804e
	lwzu r30, 0x44(r29)
	ori r23, r30, 0xffe0
	and r23, r15, r23
	stw r23, 0x0(r29)
	andc r15, r15, r30
	stw r19, 0x0(r28)
	cmpwi r19, 0x4
	bne loc_0x248
	lis r30, 0xffff
	ori r30, r30, 0xffff
	lis r29, 0x804e
	ori r29, r29, 0x48
	li r16, 0x0
	cmpwi r16, 0x8
	bge loc_0x175
loc_0x171:
	stwu r30, 0x4(r29)
	addi r16, r16, 0x1
	cmpwi r16, 0x8
	blt+ loc_0x171
loc_0x175:
	lis r31, 0x805b
	ori r31, r31, 0xacf0
	li r30, 0x0
	li r16, 0x0
	cmpwi r16, 0x8
	bge loc_0x17F
loc_0x17B:
	sthu r30, 0x40(r31)
	addi r16, r16, 0x1
	cmpwi r16, 0x8
	blt+ loc_0x17B
loc_0x17F:
	li r31, 0x1
	stw r31, 0x0(r27)
	li r14, 0x0
	andi. r4, r15, 0x10
	beq loc_0x18F
	lis r7, 0x804e
	lwzu r4, 0x24(r7)
	lis r8, 0x804e
	lwzu r6, 0x28(r8)
	li r5, 0x3
	cmpw r4, r5
	ble loc_0x18C
	stw r5, 0x0(r7)
loc_0x18C:
	cmpw r6, r5
	ble loc_0x18F
	stw r5, 0x0(r8)
loc_0x18F:
	andi. r4, r15, 0x8
	beq loc_0x192
	li r17, 0x41
loc_0x192:
	andi. r4, r15, 0x4
	beq loc_0x195
	li r17, 0xffbf
loc_0x195:
	lis r7, 0x804e
	lwzu r6, 0x24(r7)
	srawi r3, r17, 31
	add r8, r17, r3
	xor r8, r8, r3
	subi r6, r6, 0x1
	cmpwi r8, 0x41
	blt loc_0x1A8
	cmpwi r6, 0x0
	bgt loc_0x1A7
	cmpwi r6, 0x0
	bge loc_0x1A2
	li r6, 0xa
loc_0x1A2:
	addi r6, r6, 0x6
	li r14, 0x2
	cmpwi r17, 0x41
	blt loc_0x1A7
	li r14, 0x1
loc_0x1A7:
	b loc_0x1A9
loc_0x1A8:
	li r6, 0x0
loc_0x1A9:
	stw r6, 0x0(r7)
	andi. r4, r15, 0x2
	beq loc_0x1AD
	li r18, 0x32
loc_0x1AD:
	andi. r4, r15, 0x1
	beq loc_0x1B0
	li r18, 0xffce
loc_0x1B0:
	lis r7, 0x804e
	lwzu r6, 0x28(r7)
	srawi r3, r18, 31
	add r8, r18, r3
	xor r8, r8, r3
	subi r6, r6, 0x1
	cmpwi r8, 0x32
	blt loc_0x1C3
	cmpwi r6, 0x0
	bgt loc_0x1C2
	cmpwi r6, 0x0
	bge loc_0x1BD
	li r6, 0xa
loc_0x1BD:
	addi r6, r6, 0x6
	li r14, 0x6
	cmpwi r18, 0x32
	blt loc_0x1C2
	li r14, 0x5
loc_0x1C2:
	b loc_0x1C4
loc_0x1C3:
	li r6, 0x0
loc_0x1C4:
	stw r6, 0x0(r7)
	andi. r4, r15, 0x400
	beq loc_0x1C8
	li r14, 0x8
loc_0x1C8:
	andi. r4, r15, 0x800
	beq loc_0x1CB
	li r14, 0x9
loc_0x1CB:
	andi. r4, r15, 0x100
	beq loc_0x1CE
	li r14, 0x3
loc_0x1CE:
	andi. r4, r15, 0x200
	beq loc_0x1D6
	li r14, 0x4
	lis r4, 0x804e
	lwz r5, 0x0(r4)
	lwz r4, 0x4(r4)
	cmplw r4, r5
	beq loc_0x1D8
loc_0x1D6:
	andi. r4, r15, 0x1000
	beq loc_0x1D9
loc_0x1D8:
	li r14, 0x7
loc_0x1D9:
	lis r5, 0x804e
	lwz r5, 0x0(r5)
	lwz r3, 0x0(r5)
	add r3, r3, r5
	lbz r4, 0x2(r3)
	cmpwi r14, 0x1
	bne loc_0x1E2
	lhz r6, 0xc(r3)
	b loc_0x1E5
loc_0x1E2:
	cmpwi r14, 0x2
	bne loc_0x1EF
	lhz r6, 0xe(r3)
loc_0x1E5:
	lbz r8, 0x4(r3)
	xori r8, r8, 0x4
	stb r8, 0x4(r3)
	stw r6, 0x0(r5)
	add r7, r6, r5
	lbz r8, 0x4(r7)
	xori r8, r8, 0x4
	stb r8, 0x4(r7)
	li r4, 0x0
	bl 0x2c30
loc_0x1EF:
	li r6, 0x0
	cmplwi r14, 0x5
	cmplwi cr1, r14, 0x3
	word 0x4C423382
	beql loc_0x454
	li r6, 0x1
	cmplwi r14, 0x6
	beql loc_0x454
	cmpwi r14, 0x3
	bne loc_0x203
	cmpwi r4, 0x3
	bne loc_0x203
	lhz r6, 0x10(r3)
	add r7, r5, r6
	neg r6, r6
	stw r6, 0x4(r7)
	lis r6, 0x804e
	stw r7, 0x0(r6)
	li r4, 0x23
	bl 0x2be0
loc_0x203:
	cmpwi r14, 0x4
	bne loc_0x21C
	lwz r6, 0x4(r5)
	add r7, r5, r6
	lis r6, 0x804e
	stw r7, 0x0(r6)
	lwz r6, 0x0(r7)
	add r6, r6, r7
	lbz r8, 0x4(r6)
	rlwinm r9, r8, 29, 31, 31       # (Mask: 0x00000008)
	lwz r10, 0x8(r7)
	andi. r8, r8, 0xfff7
	subf r10, r9, r10
	lwz r9, 0x8(r5)
	li r11, 0x0
	andi. r9, r9, 0x1f
	beq loc_0x215
	li r11, 0x1
loc_0x215:
	add r10, r10, r11
	rlwinm r11, r11, 3, 0, 31       # (Mask: 0xffffffff)
	stw r10, 0x8(r7)
	or r8, r8, r11
	stb r8, 0x4(r6)
	li r4, 0x14
	bl 0x2b7c
loc_0x21C:
	cmpwi r14, 0x7
	bne loc_0x229
	li r6, 0x3
	lis r7, 0x804e
	ori r7, r7, 0x34
	stw r6, 0x0(r7)
	lis r3, 0x804e
	lwz r3, 0x6c(r3)
	lis r4, 0x805b
	ori r4, r4, 0x8a08
	stw r3, 0x0(r4)
	li r4, 0x8
	bl 0x2b48
loc_0x229:
	lis r7, 0x804e
	ori r7, r7, 0x94
	li r31, 0x0
	cmplwi r14, 0x8
	li r6, 0x0
	beql loc_0x48A
	cmpwi r14, 0x9
	bne loc_0x234
	lwz r8, 0x0(r7)
	stwu r5, 0x4(r8)
	stw r8, 0x0(r7)
loc_0x234:
	li r6, 0x1
loc_0x235:
	lwz r12, 0x0(r7)
	lwz r5, 0x0(r12)
	cmpw r12, r7
	beq loc_0x245
	subi r12, r12, 0x4
	stw r12, 0x0(r7)
	addi r3, r5, 0x14
	lhz r12, 0x0(r3)
	cmpwi r12, 0x0
	beq loc_0x244
loc_0x23F:
	lbz r4, 0x2(r3)
	bl loc_0x48A
	lhzux r12, r3, r12
	cmpwi r12, 0x0
	bne+ loc_0x23F
loc_0x244:
	b loc_0x235
loc_0x245:
	cmplwi r31, 0x0
	li r4, 0x2
	bnel 0x2acc
loc_0x248:
	lis r31, 0x805b
	ori r31, r31, 0xacc4
	lis r30, 0x804e
	ori r30, r30, 0x48
	li r16, 0x0
	cmpwi r16, 0x8
	bge loc_0x258
loc_0x24F:
	lwzu r29, 0x4(r30)
	lwzu r28, 0x40(r31)
	and r27, r28, r29
	stw r27, 0x0(r30)
	andc r28, r28, r29
	stw r28, 0x0(r31)
	addi r16, r16, 0x1
	cmpwi r16, 0x8
	blt+ loc_0x24F
loc_0x258:
	li r26, 0x0
	cmpwi r26, 0x1
	bne loc_0x268
	lis r31, 0x805b
	ori r31, r31, 0xacc4
	lis r30, 0xffff
	ori r30, r30, 0xeeff
	li r16, 0x0
	cmpwi r16, 0x8
	bge loc_0x268
loc_0x262:
	lwzu r28, 0x40(r31)
	and r28, r28, r30
	stw r28, 0x0(r31)
	addi r16, r16, 0x1
	cmpwi r16, 0x8
	blt+ loc_0x262
loc_0x268:
	lis r30, 0x804e
	lwz r30, 0x758(r30)
	cmpwi r30, 0x1
	bne loc_0x275
	lis r30, 0x804e
	lwz r30, 0xc30(r30)
	cmpwi r30, 0x1
	bne loc_0x275
	lis r30, 0x804e
	lwz r30, 0x34(r30)
	cmpwi r30, 0x0
	bne loc_0x275
	b loc_0x2BD
loc_0x275:
	lis r29, 0x8058
	lwzu r31, 0x4000(r29)
	lis r30, 0x804e
	lwz r30, 0x34(r30)
	andi. r26, r15, 0x10
	cmpwi r30, 0x4
	bne loc_0x27D
	li r26, 0x0
loc_0x27D:
	lis r27, 0x804e
	lwzu r28, 0x2c(r27)
	lis r30, 0xefef
	ori r30, r30, 0xffff
	cmpwi r26, 0x0
	beq loc_0x295
	subi r28, r28, 0x1
	cmpwi r28, 0x0
	bgt loc_0x294
	cmpwi r28, 0x0
	bge loc_0x289
	li r28, 0xc
loc_0x289:
	andis. r31, r31, 0xffef
	addi r28, r28, 0x4
	li r25, 0x0
	cmpwi r25, 0x20
	bge loc_0x294
loc_0x28E:
	lhzx r24, r29, r25
	andi. r24, r24, 0xffef
	sthx r24, r29, r25
	addi r25, r25, 0x8
	cmpwi r25, 0x20
	blt+ loc_0x28E
loc_0x294:
	b loc_0x296
loc_0x295:
	li r28, 0x0
loc_0x296:
	stw r28, 0x0(r27)
	cmpwi r19, 0x4
	bne loc_0x29B
	lis r30, 0xffff
	ori r30, r30, 0xffff
loc_0x29B:
	li r28, 0x0
	cmpwi r28, 0x20
	beq loc_0x2A4
loc_0x29E:
	lwzx r31, r29, r28
	or r31, r30, r31
	stwx r31, r29, r28
	addi r28, r28, 0x8
	cmpwi r28, 0x20
	bne+ loc_0x29E
loc_0x2A4:
	lis r31, 0x804e
	lwz r31, 0xd34(r31)
	lis r30, 0x8058
	ori r30, r30, 0x3fff
	stb r31, 0x0(r30)
	lis r31, 0x804e
	lwz r31, 0xd60(r31)
	lis r30, 0x8058
	ori r30, r30, 0x3ffd
	stb r31, 0x0(r30)
	lis r31, 0x804e
	lwz r31, 0xde4(r31)
	lis r30, 0x8058
	ori r30, r30, 0x3ff9
	stb r31, 0x0(r30)
	lis r31, 0x804e
	lwz r31, 0xdb0(r31)
	lis r30, 0x8058
	ori r30, r30, 0x3ff7
	stb r31, 0x0(r30)
	lis r31, 0x804e
	lwz r31, 0xe38(r31)
	lis r30, 0x8058
	ori r30, r30, 0x3ffb
	stb r31, 0x0(r30)
loc_0x2BD:
	lis r19, 0x804e
	lwz r19, 0x34(r19)
	lis r25, 0x804e
	lwz r25, 0x758(r25)
	cmpwi r19, 0x4
	beq loc_0x33D
	cmpwi r25, 0x1
	bne loc_0x33D
	lis r20, 0x804e
	lwz r20, 0x644(r20)
	lwzu r21, 0x4(r20)
	cmpwi r21, 0x0
	beq loc_0x33D
loc_0x2CA:
	lwz r24, 0x38(r21)
	lwz r30, 0x34(r21)
	cmpwi r24, 0x3
	bgt loc_0x2DE
	cmpwi r24, 0x0
	blt loc_0x2DE
	rlwinm r4, r24, 2, 0, 31        # (Mask: 0xffffffff)
	lis r3, 0x804e
	ori r3, r3, 0x12c
	lwzx r3, r3, r4
	lwz r5, 0x8(r3)
	cmpwi r5, 0x1
	bne loc_0x2DE
	lbz r30, 0x7(r30)
	lis r29, 0x805b
	ori r29, r29, 0xacc4
	mulli r30, r30, 0x40
	lwzux r30, r29, r30
	andi. r30, r30, 0xfff0
	stw r30, 0x0(r29)
loc_0x2DE:
	cmpwi r24, 0x3
	bgt loc_0x30B
	cmpwi r24, 0x0
	blt loc_0x30B
	rlwinm r4, r24, 2, 0, 31        # (Mask: 0xffffffff)
	lis r3, 0x804e
	ori r3, r3, 0x11c
	lwzx r3, r3, r4
	lwz r5, 0x8(r3)
	lwz r30, 0x34(r21)
	cmpwi r5, 0x1
	bne loc_0x30B
	andi. r31, r15, 0xf
	cmpwi r31, 0x0
	beq loc_0x30B
	cmpwi r24, 0x3
	bgt loc_0x30B
	cmpwi r24, 0x0
	blt loc_0x30B
	rlwinm r4, r24, 2, 0, 31        # (Mask: 0xffffffff)
	lis r3, 0x804e
	ori r3, r3, 0x10c
	lwzx r3, r3, r4
	lfs f1, 0x8(r3)
	lis r29, 0x8061
	ori r29, r29, 0x5520
	rlwinm r28, r24, 2, 0, 31       # (Mask: 0xffffffff)
	add r29, r29, r28
	lwz r29, 0x4c(r29)
	fctiwz f0, f1
	stfd f0, -0x30(r1)
	lwz r28, -0x2c(r1)
	stw r28, 0x18(r29)
	addi r31, r28, 0x1
	stw r31, 0x1c(r29)
	lwz r29, 0x3c(r21)
	lwz r29, 0x60(r29)
	lwz r29, 0xd8(r29)
	lwz r29, 0x38(r29)
	lwz r29, 0x40(r29)
	stfs f1, 0xc(r29)
	lwz r3, 0x3c(r21)
	bla 0x83ae24
	lwz r3, 0x0(r3)
	stfs f1, 0x24(r3)
loc_0x30B:
	cmpwi r19, 0x3
	bne loc_0x32C
	cmpwi r24, 0x3
	bgt loc_0x32C
	cmpwi r24, 0x0
	blt loc_0x32C
	rlwinm r4, r24, 2, 0, 31        # (Mask: 0xffffffff)
	lis r3, 0x804e
	ori r3, r3, 0xec
	lwzx r3, r3, r4
	lwz r5, 0x8(r3)
	stw r5, 0x10(r3)
	lwz r30, 0x34(r21)
	rlwinm r5, r5, 2, 0, 31         # (Mask: 0xffffffff)
	lbz r4, 0x0(r30)
	addi r5, r5, 0x1e
	lwz r31, 0x18(r3)
	lhzx r5, r31, r5
	cmpw r4, r5
	beq loc_0x32C
	li r31, 0x0
	stb r5, 0x0(r30)
	lis r29, 0x4
	ori r29, r29, 0x3ad8
	lis r28, 0x805a
	lwz r28, 0xe0(r28)
	lwz r28, 0x10(r28)
	add r28, r28, r29
	lwz r29, 0x38(r21)
	mulli r29, r29, 0x5c
	stwx r31, r28, r29
	stb r31, 0x5(r30)
	stb r31, 0x6(r30)
loc_0x32C:
	cmpwi r24, 0x3
	bgt loc_0x33A
	cmpwi r24, 0x0
	blt loc_0x33A
	rlwinm r4, r24, 2, 0, 31        # (Mask: 0xffffffff)
	lis r3, 0x804e
	ori r3, r3, 0xfc
	lwzx r3, r3, r4
	lwz r3, 0x8(r3)
	cmpwi r3, 0x1
	bne loc_0x33A
	lwz r31, 0x0(r21)
	lis r30, 0x4270
	stw r30, 0x19c(r31)
loc_0x33A:
	lwzu r21, 0x8(r20)
	cmpwi r21, 0x0
	bne+ loc_0x2CA
loc_0x33D:
	cmpwi r19, 0x3
	bne loc_0x342
	lis r4, 0x804e
	lwzu r3, 0x30(r4)
	stw r3, 0x4(r4)
loc_0x342:
	lis r29, 0x805c
	lwz r29, -0x4040(r29)
	lis r30, 0x804e
	ori r30, r30, 0x3c
	cmpwi r29, 0x2
	bne loc_0x349
	stw r29, 0x0(r30)
loc_0x349:
	lis r31, 0x804e
	lwz r31, 0xa6c(r31)
	cmpwi r31, 0x1
	beq loc_0x34F
	li r31, 0x0
	stw r31, 0x0(r30)
loc_0x34F:
	cmpwi r19, 0x3
	bne loc_0x41C
	lis r30, 0x804e
	ori r30, r30, 0xa98
	lwz r31, 0x8(r30)
	cmpwi r31, 0x1
	bne loc_0x41C
	li r31, 0x0
	lbz r29, 0x4(r30)
	stw r31, 0x8(r30)
	andi. r29, r29, 0xfff7
	stb r29, 0x4(r30)
	lis r3, 0x804e
	lwz r3, 0x758(r3)
	cmpwi r3, 0x0
	bne loc_0x41C
	lis r21, 0x804e
	ori r21, r21, 0x648
	lis r4, 0x6e61
	ori r4, r4, 0x6e64
	stw r4, 0x0(r21)
	lis r4, 0x3a2f
	ori r4, r4, 0x636f
	stw r4, 0x4(r21)
	lis r4, 0x6c6c
	ori r4, r4, 0x6563
	stw r4, 0x8(r21)
	lis r4, 0x742e
	ori r4, r4, 0x7666
	stw r4, 0xc(r21)
	lis r4, 0x6600
	stw r4, 0x10(r21)
	lis r3, 0x804e
	ori r3, r3, 0x264
	li r4, 0x0
	lis r5, 0x804e
	ori r5, r5, 0x648
	bla 0x20f90
	li r3, 0x0
	lis r4, 0x1b
	ori r4, r4, 0xcf24
	bla 0x1e1a80
	lis r31, 0x804e
	ori r31, r31, 0x164
	lis r30, 0x804e
	ori r30, r30, 0x178
	lis r27, 0x804e
	ori r27, r27, 0x180
	li r3, 0x0
	stw r3, 0x0(r30)
	stw r3, 0x4(r30)
	lis r4, 0x4e03
	ori r4, r4, 0x41de
	stw r4, 0x0(r27)
	lis r4, 0xe6bb
	ori r4, r4, 0xaa41
	stw r4, 0x4(r27)
	lis r4, 0x6419
	ori r4, r4, 0xb3ea
	stw r4, 0x8(r27)
	lis r4, 0xe8f5
	ori r4, r4, 0x3bd9
	stw r4, 0xc(r27)
	li r3, 0x2a
	li r4, 0x1
	stw r3, 0x18(r27)
	stw r4, 0x1c(r27)
	bla 0x1e1b34
	mr r29, r3
	mr r28, r4
	lis r3, 0x804e
	ori r3, r3, 0x164
	li r4, 0x2a
	bla 0x152b5c
	lis r4, 0x804e
	lwz r4, 0x7cc(r4)
	addi r4, r4, 0x100
	bla 0x152c4c
	addi r3, r30, 0x0
	addi r4, r31, 0x0
	addi r5, r29, 0x0
	addi r6, r28, 0x0
	li r7, 0x2a
	li r8, 0x0
	li r9, 0x0
	bla 0x153610
	lwz r3, 0x0(r30)
	stw r3, 0x10(r27)
	lwz r3, 0x1c(r3)
	addi r3, r3, 0x20
	stw r3, 0x14(r27)
	subi r3, r27, 0x340
	lis r26, 0x804e
	ori r26, r26, 0x6e8
	lis r25, 0x804e
	ori r25, r25, 0x648
	addi r3, r29, 0x0
	addi r4, r28, 0x0
	addi r5, r25, 0x0
	bla 0x1e1d80
	lwz r19, 0x0(r25)
	lwz r24, 0x4(r25)
	lwz r23, 0x8(r25)
	lwz r22, 0xc(r25)
	lwz r21, 0x10(r25)
	lwz r20, 0x14(r25)
	addi r21, r21, 0x1
	li r3, 0x64
	mr r4, r20
	divwu r20, r4, r3
	mullw r20, r20, r3
	subf r20, r20, r4
	lis r4, 0x2f72
	ori r4, r4, 0x702f
	stw r4, 0x0(r26)
	lis r4, 0x7270
	ori r4, r4, 0x5f25
	stw r4, 0x4(r26)
	lis r4, 0x3032
	ori r4, r4, 0x6425
	stw r4, 0x8(r26)
	lis r4, 0x3032
	ori r4, r4, 0x6425
	stw r4, 0xc(r26)
	lis r4, 0x3032
	ori r4, r4, 0x645f
	stw r4, 0x10(r26)
	lis r4, 0x2530
	ori r4, r4, 0x3264
	stw r4, 0x14(r26)
	lis r4, 0x2530
	ori r4, r4, 0x3264
	stw r4, 0x18(r26)
	lis r4, 0x5f25
	ori r4, r4, 0x3032
	stw r4, 0x1c(r26)
	lis r4, 0x642e
	ori r4, r4, 0x6269
	stw r4, 0x20(r26)
	lis r4, 0x6e00
	stw r4, 0x24(r26)
	lis r3, 0x804e
	ori r3, r3, 0x648
	addi r4, r26, 0x0
	addi r5, r20, 0x0
	addi r6, r21, 0x0
	addi r7, r22, 0x0
	addi r8, r23, 0x0
	addi r9, r24, 0x0
	addi r10, r19, 0x0
	crxor 6, 6, 6
	bla 0x3f89fc
	lis r26, 0x804e
	ori r26, r26, 0x648
	lwz r24, 0x0(r30)
	lwz r25, 0x1c(r24)
	addi r25, r25, 0x20
	li r23, 0x2000
	li r3, 0x2a
	bla 0x24430
	addi r4, r23, 0x0
	bla 0x204e5c
	mr r23, r1
	addi r1, r3, 0x1f00
	mr r22, r3
	li r19, 0x8
loc_0x3F5:
	li r4, 0x0
	lis r3, 0x804e
	ori r3, r3, 0x75c
	stw r26, 0x0(r3)
	stw r4, 0x4(r3)
	stw r25, 0x8(r3)
	stw r24, 0xc(r3)
	stw r4, 0x10(r3)
	stw r4, 0x14(r3)
	bla 0x1d5a8
	cmplwi r3, 0x0
	beq loc_0x408
	addic. r19, r19, -0x1
	blt loc_0x408
	li r3, 0x0
	lis r4, 0x1b
	ori r4, r4, 0xcf24
	bla 0x1e1a80
	b loc_0x3F5
loc_0x408:
	lis r3, 0x804e
	ori r3, r3, 0x264
	li r4, 0x0
	bla 0x21038
	li r25, 0x0
	lis r24, 0x804e
	ori r24, r24, 0x264
	stw r25, 0x0(r24)
	mr r1, r23
	addi r3, r22, 0x0
	bla 0x2632c
	mr r3, r31
	li r4, 0x0
	bla 0x152bdc
	lwz r25, 0x28(r27)
	addi r3, r25, 0x0
	bla 0x2632c
	lwz r25, 0x0(r30)
	addi r3, r25, 0x0
	bla 0x2632c
loc_0x41C:
	lis r31, 0x8058
	lbz r31, 0x3ff9(r31)
	cmpwi r31, 0x2
	bne loc_0x425
	li r30, 0x1
	lis r29, 0x804e
	ori r29, r29, 0x2a4
	stw r30, 0x0(r29)
	b loc_0x431
loc_0x425:
	lis r29, 0x804e
	lwzu r30, 0x2a4(r29)
	cmpwi r30, 0x1
	bne loc_0x431
	li r30, 0x0
	stw r30, 0x0(r29)
	lis r3, 0x8067
	ori r3, r3, 0x2f40
	li r4, 0x0
	li r5, 0x1
	bla 0xd234
	addi r31, r31, 0x1
loc_0x431:
	lis r31, 0x8058
	lbz r31, 0x3ffd(r31)
	cmpwi r31, 0x2
	bne loc_0x43A
	li r30, 0x1
	lis r29, 0x804e
	ori r29, r29, 0x2a0
	stw r30, 0x0(r29)
	b loc_0x44B
loc_0x43A:
	lis r29, 0x804e
	lwzu r30, 0x2a0(r29)
	cmpwi r30, 0x1
	bne loc_0x44B
	li r30, 0x0
	stw r30, 0x0(r29)
	li r31, 0x1
	cmpwi r31, 0x5
	bgt loc_0x44B
loc_0x443:
	lis r3, 0x8067
	ori r3, r3, 0x2f40
	mr r4, r31
	li r5, 0x1
	bla 0xd234
	addi r31, r31, 0x1
	cmpwi r31, 0x5
	ble+ loc_0x443
loc_0x44B:
	lmw r3, 0x8(r1)
	addi r1, r1, 0xf4
	bl 0x2278
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	blr
loc_0x454:
	cmplwi r4, 0x2
	bgt loc_0x489
	cmplwi cr7, r6, 0x0
	cmpwi r4, 0x2
	bne loc_0x468
	lfs f1, 0x8(r3)
	lfs f2, 0x1c(r3)
	beq cr7, loc_0x45D
	fneg f2, f2
loc_0x45D:
	fadds f3, f1, f2
	lfs f1, 0x18(r3)
	lfs f2, 0x14(r3)
	fcmpu cr1, f3, f1
	bge cr1, loc_0x463
	fmr f3, f2
loc_0x463:
	fcmpu cr1, f3, f2
	ble cr1, loc_0x466
	fmr f3, f1
loc_0x466:
	stfs f3, 0x8(r3)
	b loc_0x47A
loc_0x468:
	lwz r12, 0x8(r3)
	li r11, 0x1
	li r10, 0x0
	cmplwi r4, 0x0
	beq loc_0x46F
	lwz r11, 0x1c(r3)
	lwz r10, 0x18(r3)
loc_0x46F:
	beq cr7, loc_0x471
	neg r11, r11
loc_0x471:
	add r12, r12, r11
	lwz r11, 0x14(r3)
	cmpw r12, r10
	bge loc_0x476
	mr r12, r11
loc_0x476:
	cmpw r12, r11
	ble loc_0x479
	mr r12, r10
loc_0x479:
	stw r12, 0x8(r3)
loc_0x47A:
	lwz r12, 0x8(r3)
	lbz r11, 0x4(r3)
	lwz r10, 0x10(r3)
	lwz r8, 0x8(r5)
	rlwinm r9, r11, 29, 31, 31      # (Mask: 0x00000008)
	andi. r11, r11, 0xfff7
	cmpw r12, r10
	beq loc_0x484
	addi r8, r8, 0x1
	ori r11, r11, 0x8
loc_0x484:
	subf r8, r9, r8
	stb r11, 0x4(r3)
	stw r8, 0x8(r5)
	li r4, 0x25
	b 0x21c8
loc_0x489:
	blr
loc_0x48A:
	lbz r9, 0x4(r3)
	cmplwi r6, 0x1
	bne loc_0x490
	lbz r10, 0x3(r3)
	andi. r10, r10, 0x1
	bne loc_0x4A3
loc_0x490:
	lwz r8, 0x8(r5)
	rlwinm r10, r9, 29, 31, 31      # (Mask: 0x00000008)
	andi. r9, r9, 0xfff7
	subf r8, r10, r8
	stb r9, 0x4(r3)
	stw r8, 0x8(r5)
	cmpwi r4, 0x2
	bgt loc_0x49C
	add r31, r31, r10
	lwz r8, 0x10(r3)
	stw r8, 0x8(r3)
	b loc_0x4A3
loc_0x49C:
	cmpwi r4, 0x3
	bne loc_0x4A3
	lhz r8, 0x10(r3)
	add r8, r8, r5
	lwz r10, 0x0(r7)
	stwu r8, 0x4(r10)
	stw r10, 0x0(r7)
loc_0x4A3:
	lwz r10, 0x10(r5)
	cmpwi r10, -0x1
	beqlr
	lbz r8, 0x4(r10)
	andi. r9, r9, 0x8
	or r8, r8, r9
	stb r8, 0x4(r10)
	blr
}

##############################
[CM: Code Menu] Stop Announcer
##############################
HOOK @ $809580B4                # Address = $(ba + 0x009580B4)
{
	lis r4, 0x804e
	lwz r4, 0x908(r4)
	cmpwi r4, 0x2
	blt loc_0x005
	blr
loc_0x005:
	stwu r1, -0x20(r1)
	nop
}

##################################
[CM: Code Menu] Endless Friendlies
##################################
HOOK @ $809489EC                # Address = $(ba + 0x009489EC)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	lis r25, 0xffff
	ori r25, r25, 0xffff
	lis r31, 0x804e
	lwz r31, 0x908(r31)
	cmpwi r31, 0x2
	blt loc_0x02E
	lis r31, 0x804e
	lwzu r30, 0x13c(r31)
	cmpwi r30, 0x0
	beq loc_0x022
	li r25, 0x1
	lwz r29, 0x48(r3)
	addi r29, r29, 0x1
	lis r28, 0x804e
	ori r28, r28, 0x23c
	mulli r27, r29, 0x4
	addi r26, r3, 0x5d
	stwx r26, r28, r27
	rlwinm r28, r30, 8, 24, 31      # (Mask: 0xff000000)
	cmpw r28, r29
	bne loc_0x01D
	li r25, 0x0
loc_0x01D:
	rlwinm r28, r30, 16, 24, 31     # (Mask: 0x00ff0000)
	cmpw r28, r29
	bne loc_0x021
	li r25, 0x0
loc_0x021:
	b loc_0x02E
loc_0x022:
	lis r29, 0x805b
	lwz r29, 0x50ac(r29)
	lwz r29, 0x10(r29)
	cmpwi r29, 0x0
	beq loc_0x029
	lwz r29, 0x8(r29)
	b loc_0x02B
loc_0x029:
	lis r29, 0xffff
	ori r29, r29, 0xffff
loc_0x02B:
	cmpwi r29, 0xa
	bne loc_0x02E
	li r25, 0x0
loc_0x02E:
	cmpwi r25, 0x0
	bne loc_0x033
	lbz r29, 0x5d(r3)
	andi. r29, r29, 0xfff7
	stb r29, 0x5d(r3)
loc_0x033:
	cmpwi r25, 0x1
	bne loc_0x038
	lbz r29, 0x5d(r3)
	ori r29, r29, 0x8
	stb r29, 0x5d(r3)
loc_0x038:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	lbz r0, 0x5d(r3)
	nop
}

##########################
[CM: DrawDI] Set Hit Start
##########################
HOOK @ $808761E8                # Address = $(ba + 0x008761E8)
{
	bctrl
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	li r14, 0x1
	lis r3, 0x804e
	lwz r3, 0x644(r3)
	rlwinm r4, r3, 16, 16, 31       # (Mask: 0xffff0000)
	cmplwi r4, 0xcccc
	bne loc_0x00F
	li r14, 0x0
loc_0x00F:
	cmpwi r14, 0x0
	beq loc_0x01A
	lwz r14, 0x0(r3)
	cmpw r14, r30
	beq loc_0x019
loc_0x014:
	lwzu r14, 0x8(r3)
	cmplwi r14, 0x0
	beq loc_0x01A
	cmpw r14, r30
	bne+ loc_0x014
loc_0x019:
	lwz r14, 0x4(r3)
loc_0x01A:
	cmpwi r14, 0x0
	beq loc_0x055
	lwz r29, 0x8(r14)
	lwz r29, 0x0(r29)
	stw r29, 0x4(r14)
	lwz r29, 0xc(r14)
	lwz r28, 0xc(r29)
	lwz r27, 0x10(r29)
	stw r28, 0x24(r14)
	stw r27, 0x28(r14)
	lwz r29, 0xc(r31)
	stw r29, 0x1c(r14)
	lwz r29, 0x10(r31)
	stw r29, 0x20(r14)
	lwz r15, 0x64(r14)
	lwz r29, 0x0(r15)
	li r3, 0x0
	stw r3, 0xc(r29)
	stw r3, 0x14(r29)
	addi r3, r29, 0x14
	stw r3, 0x0(r29)
	lwz r28, 0x24(r14)
	lwz r27, 0x28(r14)
	lwz r4, 0x10(r29)
	lwz r3, 0x0(r29)
	subf r3, r29, r3
	cmplw r3, r4
	bge loc_0x03D
	lwz r3, 0xc(r29)
	addi r3, r3, 0x1
	stw r3, 0xc(r29)
	lwz r3, 0x0(r29)
	stwu r28, 0x4(r3)
	stwu r27, 0x4(r3)
	stw r3, 0x0(r29)
loc_0x03D:
	lwz r29, 0x4(r15)
	li r3, 0x0
	stw r3, 0xc(r29)
	stw r3, 0x14(r29)
	addi r3, r29, 0x14
	stw r3, 0x0(r29)
	lwz r29, 0x8(r15)
	lis r3, 0x66
	ori r3, r3, 0xffff
	stw r3, 0x8(r29)
	li r3, 0x0
	stw r3, 0xc(r29)
	stw r3, 0x14(r29)
	addi r3, r29, 0x14
	stw r3, 0x0(r29)
	lwz r29, 0xc(r15)
	lis r3, 0xffff
	ori r3, r3, 0xff
	stw r3, 0x8(r29)
	li r3, 0x0
	stw r3, 0xc(r29)
	stw r3, 0x14(r29)
	addi r3, r29, 0x14
	stw r3, 0x0(r29)
loc_0x055:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	nop
}

##############################
[CM: DrawDI] Add to SDI Buffer
##############################
HOOK @ $80876C84                # Address = $(ba + 0x00876C84)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	li r12, 0x1
	lis r3, 0x804e
	lwz r3, 0x644(r3)
	rlwinm r4, r3, 16, 16, 31       # (Mask: 0xffff0000)
	cmplwi r4, 0xcccc
	bne loc_0x00E
	li r12, 0x0
loc_0x00E:
	cmpwi r12, 0x0
	beq loc_0x019
	lwz r12, 0x0(r3)
	cmpw r12, r30
	beq loc_0x018
loc_0x013:
	lwzu r12, 0x8(r3)
	cmplwi r12, 0x0
	beq loc_0x019
	cmpw r12, r30
	bne+ loc_0x013
loc_0x018:
	lwz r12, 0x4(r3)
loc_0x019:
	cmpwi r12, 0x0
	beq loc_0x02D
	stfs f0, 0x24(r12)
	stfs f2, 0x28(r12)
	lwz r12, 0x64(r12)
	lwz r12, 0x0(r12)
	lwz r4, 0x10(r12)
	lwz r3, 0x0(r12)
	subf r3, r12, r3
	cmplw r3, r4
	bge loc_0x02B
	lwz r3, 0xc(r12)
	addi r3, r3, 0x1
	stw r3, 0xc(r12)
	lwz r3, 0x0(r12)
	stfsu f0, 0x4(r3)
	stfsu f2, 0x4(r3)
	stw r3, 0x0(r12)
loc_0x02B:
	li r3, 0x1
	stw r3, 0x14(r12)
loc_0x02D:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	stfs f2, 0x14(r1)
}

###############################
[CM: DrawDI] Add To ASDI Buffer
###############################
HOOK @ $80876FEC                # Address = $(ba + 0x00876FEC)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	li r15, 0x1
	lis r3, 0x804e
	lwz r3, 0x644(r3)
	rlwinm r4, r3, 16, 16, 31       # (Mask: 0xffff0000)
	cmplwi r4, 0xcccc
	bne loc_0x00E
	li r15, 0x0
loc_0x00E:
	cmpwi r15, 0x0
	beq loc_0x019
	lwz r15, 0x0(r3)
	cmpw r15, r31
	beq loc_0x018
loc_0x013:
	lwzu r15, 0x8(r3)
	cmplwi r15, 0x0
	beq loc_0x019
	cmpw r15, r31
	bne+ loc_0x013
loc_0x018:
	lwz r15, 0x4(r3)
loc_0x019:
	cmpwi r15, 0x0
	beq loc_0x03A
	lwz r14, 0x64(r15)
	lwz r30, 0x4(r14)
	lwz r4, 0x10(r30)
	lwz r3, 0x0(r30)
	subf r3, r30, r3
	cmplw r3, r4
	bge loc_0x029
	lwz r3, 0xc(r30)
	addi r3, r3, 0x1
	stw r3, 0xc(r30)
	lwz r3, 0x0(r30)
	stfsu f1, 0x4(r3)
	stfsu f3, 0x4(r3)
	stw r3, 0x0(r30)
loc_0x029:
	li r3, 0x1
	stw r3, 0x14(r30)
	fadds f3, f0, f1
	stfs f3, 0x24(r15)
	stfs f2, 0x28(r15)
	lwz r4, 0x10(r30)
	lwz r3, 0x0(r30)
	subf r3, r30, r3
	cmplw r3, r4
	bge loc_0x03A
	lwz r3, 0xc(r30)
	addi r3, r3, 0x1
	stw r3, 0xc(r30)
	lwz r3, 0x0(r30)
	stfsu f3, 0x4(r3)
	stfsu f2, 0x4(r3)
	stw r3, 0x0(r30)
loc_0x03A:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	lfs f3, 0x18(r1)
	nop
}

###################################
[CM: DrawDI] Set Trajectory Buffers
###################################
HOOK @ $80877B48                # Address = $(ba + 0x00877B48)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	bl 0x1b74
	stwu r1, -0x174(r1)
	stmw r3, 0x8(r1)
	li r14, 0x1
	lis r3, 0x804e
	lwz r3, 0x644(r3)
	rlwinm r4, r3, 16, 16, 31       # (Mask: 0xffff0000)
	cmplwi r4, 0xcccc
	bne loc_0x00F
	li r14, 0x0
loc_0x00F:
	cmpwi r14, 0x0
	beq loc_0x01A
	lwz r14, 0x0(r3)
	cmpw r14, r29
	beq loc_0x019
loc_0x014:
	lwzu r14, 0x8(r3)
	cmplwi r14, 0x0
	beq loc_0x01A
	cmpw r14, r29
	bne+ loc_0x014
loc_0x019:
	lwz r14, 0x4(r3)
loc_0x01A:
	cmpwi r14, 0x0
	beq loc_0x09E
	lis r28, 0x805c
	lbz r28, -0x75f5(r28)
	lfs f7, 0x2c(r14)
	lfs f9, 0x30(r14)
	lfs f10, 0x1c(r14)
	lfs f11, 0x20(r14)
	lwz r15, 0x64(r14)
	lwz r31, 0x8(r15)
	lis r3, 0x66
	ori r3, r3, 0xffff
	stw r3, 0x8(r31)
	li r3, 0x0
	stw r3, 0xc(r31)
	stw r3, 0x14(r31)
	addi r3, r31, 0x14
	stw r3, 0x0(r31)
	li r25, 0x0
	cmpwi r25, 0x2
	bge loc_0x09E
loc_0x02F:
	lfs f5, 0x24(r14)
	lfs f6, 0x28(r14)
	lwz r30, 0x4(r14)
	li r3, 0x0
	stw r3, -0x10(r1)
	lfs f8, -0x10(r1)
	lwz r3, -0x41a8(r13)
	lfs f19, 0x158(r3)
	lfs f20, 0x15c(r3)
	lfs f17, 0x160(r3)
	lfs f18, 0x164(r3)
	cmpwi r30, 0x1f4
	ble loc_0x03D
	li r30, 0x1f4
loc_0x03D:
	cmpwi r30, 0x0
	ble loc_0x07E
loc_0x03F:
	lwz r4, 0x10(r31)
	lwz r3, 0x0(r31)
	subf r3, r31, r3
	cmplw r3, r4
	bge loc_0x04B
	lwz r3, 0xc(r31)
	addi r3, r3, 0x1
	stw r3, 0xc(r31)
	lwz r3, 0x0(r31)
	stfsu f5, 0x4(r3)
	stfsu f6, 0x4(r3)
	stw r3, 0x0(r31)
loc_0x04B:
	fmuls f0, f10, f10
	fmuls f2, f11, f11
	fadds f12, f0, f2
	fmr f1, f12
	bla 0x3db58
	fmuls f0, f1, f12
	lis r3, 0xbd50
	ori r3, r3, 0xe560
	stw r3, -0x10(r1)
	lfs f2, -0x10(r1)
	fadds f2, f0, f2
	fdivs f0, f2, f0
	lis r3, 0xbf80
	stw r3, -0x10(r1)
	lfs f2, -0x10(r1)
	fadds f0, f0, f2
	fmuls f12, f10, f0
	fmuls f13, f11, f0
	fadds f10, f10, f12
	fadds f11, f11, f13
	fadds f5, f5, f10
	fadds f6, f6, f8
	fadds f6, f6, f11
	fadds f8, f8, f7
	fcmpu cr0, f8, f9
	bge loc_0x066
	fmr f8, f9
loc_0x066:
	li r3, 0x1
	fcmpu cr0, f6, f17
	ble loc_0x06F
	lis r4, 0x4019
	ori r4, r4, 0x999a
	stw r4, -0x10(r1)
	lfs f12, -0x10(r1)
	fcmpu cr0, f11, f12
	bgt loc_0x076
loc_0x06F:
	fcmpu cr0, f5, f19
	blt loc_0x076
	fcmpu cr0, f5, f20
	bgt loc_0x076
	fcmpu cr0, f6, f18
	blt loc_0x076
	li r3, 0x0
loc_0x076:
	cmpwi r3, 0x1
	bne loc_0x07B
	lis r3, 0xff00
	ori r3, r3, 0xff
	stw r3, 0x8(r31)
loc_0x07B:
	subi r30, r30, 0x1
	cmpwi r30, 0x0
	bgt+ loc_0x03F
loc_0x07E:
	li r3, 0x1
	stw r3, 0x14(r31)
	lwz r31, 0x10(r14)
	lfs f10, 0x8(r31)
	lfs f11, 0xc(r31)
	cmpwi r28, 0x0
	beq loc_0x090
	lwz r31, 0x10(r15)
	lis r3, 0x6e00
	ori r3, r3, 0x94ff
	stw r3, 0x8(r31)
	li r3, 0x0
	stw r3, 0xc(r31)
	stw r3, 0x14(r31)
	addi r3, r31, 0x14
	stw r3, 0x0(r31)
	li r28, 0x0
	b loc_0x09B
loc_0x090:
	cmpwi r25, 0x0
	bne loc_0x09B
	lwz r31, 0xc(r15)
	lis r3, 0xffff
	ori r3, r3, 0xff
	stw r3, 0x8(r31)
	li r3, 0x0
	stw r3, 0xc(r31)
	stw r3, 0x14(r31)
	addi r3, r31, 0x14
	stw r3, 0x0(r31)
loc_0x09B:
	addi r25, r25, 0x1
	cmpwi r25, 0x2
	blt+ loc_0x02F
loc_0x09E:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x174
	bl 0x1984
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	psq_l f31, 0x88(r1), 0, 0
}

####################################################################
[CM: Code Menu] Constant Overrides + Run PSCC Color Update Callbacks
####################################################################
HOOK @ $80023D60                # Address = $(ba + 0x00023D60)
{
	lis r11, 0x804e
	lwz r10, 0x2068(r11)
	lis r12, 0x80b8
	stw r10, 0x7aa8(r12)
	lwz r10, 0x20a4(r11)
	stw r10, 0x7aec(r12)
	lwz r10, 0x20e0(r11)
	stw r10, 0x7ae8(r12)
	lwz r10, 0x2118(r11)
	stw r10, 0x7b10(r12)
	lwz r10, 0x215c(r11)
	lis r12, 0x80b9
	stw r10, -0x7cac(r12)
	lwz r10, 0x2190(r11)
	stw r10, -0x7ca8(r12)
	lwz r10, 0x21c8(r11)
	stw r10, -0x7be0(r12)
	lwz r10, 0x2210(r11)
	stw r10, -0x7bbc(r12)
	lwz r10, 0x2254(r11)
	stw r10, -0x7ba4(r12)
	lwz r10, 0x2294(r11)
	stw r10, -0x7ba0(r12)
	lwz r10, 0x22d0(r11)
	stw r10, -0x7b88(r12)
	lwz r10, 0x2310(r11)
	stw r10, -0x7b7c(r12)
	lwz r10, 0x2350(r11)
	stw r10, -0x7af0(r12)
	lwz r10, 0x2398(r11)
	stw r10, -0x7acc(r12)
	lwz r12, 0x4(r11)
	addi r10, r11, 0x7d8
	cmplw r10, r12
	bne loc_0x03E
	lwz r12, 0x31c(r11)
	stwu r1, -0x60(r1)
	stw r0, 0x8(r1)
	mflr r0
	stw r0, 0x4(r1)
	stmw r14, 0xc(r1)
	mr r31, r12
	li r29, 0x0
	lwz r30, 0x308(r11)
loc_0x02C:
	add r3, r30, r29
	lbz r12, 0x7(r3)
	cmplwi r12, 0x8
	bge loc_0x036
	rlwinm r12, r12, 2, 0, 29       # (Mask: 0x3fffffff)
	lwzx r12, r31, r12
	cmplwi r12, 0x0
	beq loc_0x036
	mtctr r12
	bctrl
loc_0x036:
	addi r29, r29, 0x8
	cmplwi r29, 0x88
	blt loc_0x02C
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, 0x8(r1)
	lmw r14, 0xc(r1)
	addi r1, r1, 0x60
loc_0x03E:
	cmpwi r0, 0x0
}

######################
[CM: DBZMode] DBZ Mode
######################
HOOK @ $807C1A20                # Address = $(ba + 0x007C1A20)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	bl 0x1830
	stwu r1, -0x9c(r1)
	stmw r3, 0x8(r1)
	lis r31, 0x804e
	lwz r31, 0x25fc(r31)
	cmpwi r31, 0x1
	bne loc_0x038
	lwz r27, 0xd8(r27)
	lwz r3, 0x64(r27)
	lis r4, 0x2200
	ori r4, r4, 0x2
	bla 0x7acd44
	lwz r27, 0x5c(r27)
	lfs f1, 0x38(r27)
	lwz r31, 0x64(r26)
	lfs f2, 0x8(r31)
	lis r30, 0x804e
	ori r30, r30, 0x26d8
	lfs f0, 0x8(r30)
	fmuls f1, f1, f0
	fadds f1, f1, f2
	lis r30, 0x804e
	ori r30, r30, 0x2624
	lfs f2, 0x8(r30)
	fneg f0, f2
	fcmpu cr0, f1, f0
	bge loc_0x021
	fmr f1, f0
loc_0x021:
	fcmpu cr0, f1, f2
	ble loc_0x024
	fmr f1, f2
loc_0x024:
	stfs f1, 0x8(r31)
	lfs f1, 0x3c(r27)
	lwz r31, 0x58(r26)
	lfs f2, 0xc(r31)
	lis r30, 0x804e
	ori r30, r30, 0x2718
	lfs f0, 0x8(r30)
	fmuls f1, f1, f0
	fadds f1, f1, f2
	lis r30, 0x804e
	ori r30, r30, 0x2660
	lfs f2, 0x8(r30)
	fneg f0, f2
	fcmpu cr0, f1, f0
	bge loc_0x034
	fmr f1, f0
loc_0x034:
	fcmpu cr0, f1, f2
	ble loc_0x037
	fmr f1, f2
loc_0x037:
	stfs f1, 0xc(r31)
loc_0x038:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x9c
	bl 0x17d8
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	addi r11, r1, 0x30
}

#################################
[CM: DBZMode] Force Death Off Top
#################################
HOOK @ $8083ADE0                # Address = $(ba + 0x0083ADE0)
{
	lis r4, 0x804e
	lwz r4, 0x25fc(r4)
	cmpwi r4, 0x1
	bne loc_0x01C
	cmpwi r3, -0x1
	bne loc_0x01C
	lwz r3, 0x70(r31)
	lis r4, 0x1200
	ori r4, r4, 0x1
	bla 0x7accdc
	cmpwi r3, 0x0
	bne loc_0x01A
	lwz r3, 0x20(r31)
	bla 0x740628
	cmpwi r3, 0x5
	beq loc_0x01A
	lis r3, 0x804e
	ori r3, r3, 0x648
	lwz r4, 0x18(r31)
	bla 0x72fa9c
	li r5, 0x0
	stw r5, -0x10(r1)
	lfs f1, -0x10(r1)
	fmr f2, f1
	bla 0x73b8dc
	b loc_0x01C
loc_0x01A:
	lis r3, 0xffff
	ori r3, r3, 0xffff
loc_0x01C:
	cmpwi r3, -0x1
}

##################################
[CM: Code Menu] Alt Stage Behavior
##################################
HOOK @ $8010F990                # Address = $(ba + 0x0010F990)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	lis r3, 0x804e
	lwz r3, 0x9dc(r3)
	cmpwi r3, 0x2
	bne loc_0x013
	li r3, 0x0
	lis r4, 0x800b
	ori r4, r4, 0x9ea2
	sth r3, 0x0(r4)
	lis r4, 0x815e
	ori r4, r4, 0x8422
	sth r3, 0x0(r4)
	b loc_0x03B
loc_0x013:
	cmpwi r3, 0x1
	bne loc_0x03B
	lis r4, 0x804e
	lwzu r3, 0x254(r4)
	cmpwi r3, 0x1
	bne loc_0x024
	lis r6, 0x805a
	lwz r6, 0xbc(r6)
	li r5, 0x5
	divwu r3, r6, r5
	mullw r3, r3, r5
	subf r3, r3, r6
	lis r5, 0x804e
	ori r5, r5, 0x250
	stw r3, 0x0(r5)
	li r3, 0x0
	stw r3, 0x0(r4)
loc_0x024:
	lis r5, 0x804e
	lwz r5, 0x250(r5)
	cmpwi r5, 0x0
	bne loc_0x029
	li r6, 0x0
loc_0x029:
	cmpwi r5, 0x1
	bne loc_0x02C
	li r6, 0x40
loc_0x02C:
	cmpwi r5, 0x2
	bne loc_0x02F
	li r6, 0x20
loc_0x02F:
	cmpwi r5, 0x3
	bne loc_0x032
	li r6, 0x10
loc_0x032:
	cmpwi r5, 0x4
	bne loc_0x035
	li r6, 0x800
loc_0x035:
	lis r4, 0x800b
	ori r4, r4, 0x9ea2
	sth r6, 0x0(r4)
	lis r4, 0x815e
	ori r4, r4, 0x8422
	sth r6, 0x0(r4)
loc_0x03B:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	mr r29, r5
}

##################################
[CM: Code Menu] Crowd Cheer Toggle
##################################
HOOK @ $8081AD54                # Address = $(ba + 0x0081AD54)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	lis r31, 0x804e
	lwz r31, 0xc00(r31)
	cmpwi r31, 0x0
	bne loc_0x014
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	li r3, 0x0
	blr
loc_0x014:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	stwu r1, -0x30(r1)
	nop
}

##############################
[CM: Code Menu] Staling Toggle
##############################
HOOK @ $808E00A4                # Address = $(ba + 0x008E00A4)
{
	lis r6, 0x804e
	lwz r6, 0x23d4(r6)
	cmpwi r6, 0x1
	bne loc_0x005
	li r0, 0x8
loc_0x005:
	cmpwi r6, 0x2
	bne loc_0x008
	li r0, 0x0
loc_0x008:
	lis r6, 0x808e
	rlwinm. r0, r0, 29, 31, 31      # (Mask: 0x00000008)
	nop
}

##################################################
[CM: Control Codes] Save Rotation Queue For Replay
##################################################
HOOK @ $806D1770                # Address = $(ba + 0x006D1770)
{
	lis r3, 0x805b
	lwz r3, 0x50ac(r3)
	lwz r3, 0x10(r3)
	cmpwi r3, 0x0
	beq loc_0x007
	lwz r3, 0x8(r3)
	b loc_0x009
loc_0x007:
	lis r3, 0xffff
	ori r3, r3, 0xffff
loc_0x009:
	cmpwi r3, 0xa
	bne loc_0x010
	lis r3, 0x804e
	lwz r3, 0x13c(r3)
	lis r4, 0x804e
	lwz r4, 0x7cc(r4)
	stw r3, 0x454(r4)
loc_0x010:
	blr
}

###############################
[CM: Control Codes] Start Match
###############################
HOOK @ $806CF15C                # Address = $(ba + 0x006CF15C)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	lis r31, 0x805b
	lwz r31, 0x50ac(r31)
	lwz r31, 0x10(r31)
	cmpwi r31, 0x0
	beq loc_0x00E
	lwz r31, 0x8(r31)
	b loc_0x010
loc_0x00E:
	lis r31, 0xffff
	ori r31, r31, 0xffff
loc_0x010:
	cmpwi r31, 0x6
	bne loc_0x019
	lis r31, 0x804e
	lwz r31, 0x7cc(r31)
	lwz r31, 0x454(r31)
	lis r30, 0x804e
	ori r30, r30, 0x13c
	stw r31, 0x0(r30)
	b loc_0x051
loc_0x019:
	lis r31, 0x804e
	lwz r31, 0x908(r31)
	cmpwi r31, 0x1
	blt loc_0x04D
	lis r14, 0x9018
	ori r14, r14, 0xfbc
	li r15, 0x1
	cmpwi r15, 0x5
	bge loc_0x04C
loc_0x022:
	lbz r31, 0x0(r14)
	lis r30, 0x804e
	ori r30, r30, 0x13c
	li r29, 0x0
	lbz r28, 0x0(r30)
	cmpwi r29, 0x4
	bge loc_0x030
loc_0x029:
	cmpw r28, r15
	bne loc_0x02C
	b loc_0x032
loc_0x02C:
	lbzu r28, 0x1(r30)
	addi r29, r29, 0x1
	cmpwi r29, 0x4
	blt+ loc_0x029
loc_0x030:
	lis r29, 0xffff
	ori r29, r29, 0xffff
loc_0x032:
	cmpwi r31, 0x0
	beq loc_0x041
	cmpwi r29, 0x0
	bge loc_0x041
	lis r30, 0x804e
	ori r30, r30, 0x13c
	lbz r28, 0x0(r30)
	cmpwi r28, 0x0
	bne loc_0x03D
	stb r15, 0x0(r30)
	b loc_0x041
loc_0x03D:
	lwz r28, 0x1(r30)
	rlwinm r28, r28, 24, 8, 24      # (Mask: 0xffff8000)
	stw r28, 0x1(r30)
	stb r15, 0x1(r30)
loc_0x041:
	cmpwi r31, 0x0
	bne loc_0x048
	cmpwi r29, 0x0
	blt loc_0x048
	lwz r28, 0x0(r30)
	rlwinm r28, r28, 8, 0, 24       # (Mask: 0x80ffffff)
	stw r28, 0x0(r30)
loc_0x048:
	addi r14, r14, 0x5c
	addi r15, r15, 0x1
	cmpwi r15, 0x5
	blt+ loc_0x022
loc_0x04C:
	b loc_0x051
loc_0x04D:
	li r31, 0x0
	lis r30, 0x804e
	ori r30, r30, 0x13c
	stw r31, 0x0(r30)
loc_0x051:
	li r31, 0x48
	li r3, 0x2a
	bla 0x24430
	addi r4, r31, 0x0
	bla 0x204e5c
	lis r31, 0x804e
	ori r31, r31, 0x644
	stw r3, 0x0(r31)
	li r31, 0x0
	stw r31, 0x0(r3)
	stw r31, 0x4(r3)
	lis r30, 0x804e
	lwzu r31, 0x38(r30)
	cmpwi r31, 0x1
	bne loc_0x08C
	li r31, 0x0
	stw r31, 0x0(r30)
	lis r30, 0x805a
	lwz r30, 0xe0(r30)
	lwz r30, 0x8(r30)
	lis r31, 0x804e
	lwz r31, 0x984(r31)
	cmpwi r31, 0x0
	bne loc_0x087
	lis r26, 0x806b
	lbz r26, -0x11e8(r26)
	andi. r0, r26, 0x20
	bne loc_0x081
	stwu r1, -0x20(r1)
	addi r3, r1, 0x8
	li r4, 0x0
	andi. r0, r26, 0x8
	beq loc_0x073
	li r4, 0x1
loc_0x073:
	bla 0x6b7618
	lwz r3, 0x10(r1)
	sth r3, 0x1a(r30)
	srawi r3, r26, 7
	andi. r0, r26, 0xc0
	bne loc_0x07D
	lis r4, 0x8049
	lbz r4, 0x6000(r4)
	lwz r3, 0xc(r1)
	bla 0x6b74f0
loc_0x07D:
	lbz r28, 0x29(r30)
	rlwimi r28, r3, 5, 26, 26       # (Mask: 0x00000001)
	stb r28, 0x29(r30)
	addi r1, r1, 0x20
loc_0x081:
	andi. r26, r26, 0xef
	lis r29, 0x806b
	stb r26, -0x11e8(r29)
	li r28, 0x21
	lis r29, 0x8054
	stb r28, -0xffd(r29)
loc_0x087:
	lhz r3, 0x1a(r30)
	addi r4, r30, 0x1c
	addi r5, r30, 0x5c
	li r6, 0x0
	bla 0x10f960
loc_0x08C:
	li r31, 0x1
	lis r30, 0x804e
	ori r30, r30, 0x758
	stw r31, 0x0(r30)
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	lis r29, 0x8070
	nop
}

#########################################################
[CM: Control Codes] Order Rotation Queue By Match Placing
#########################################################
HOOK @ $806D4C14                # Address = $(ba + 0x006D4C14)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stfd f1, -0x10(r1)
	stwu r1, -0x8c(r1)
	stmw r3, 0x8(r1)
	lis r31, 0x805b
	lwz r31, 0x50ac(r31)
	lwz r31, 0x10(r31)
	cmpwi r31, 0x0
	beq loc_0x00F
	lwz r31, 0x8(r31)
	b loc_0x011
loc_0x00F:
	lis r31, 0xffff
	ori r31, r31, 0xffff
loc_0x011:
	cmpwi r31, 0xa
	bne loc_0x092
	lis r31, 0x804e
	lwz r31, 0x908(r31)
	cmpwi r31, 0x4
	bne loc_0x02F
	li r30, 0x0
	lis r14, 0x804e
	ori r14, r14, 0x13c
	li r31, 0x0
	lbz r29, 0x0(r14)
	cmpwi r31, 0x4
	bge loc_0x025
loc_0x01E:
	cmpw r29, r30
	bne loc_0x021
	b loc_0x027
loc_0x021:
	lbzu r29, 0x1(r14)
	addi r31, r31, 0x1
	cmpwi r31, 0x4
	blt+ loc_0x01E
loc_0x025:
	lis r31, 0xffff
	ori r31, r31, 0xffff
loc_0x027:
	lis r31, 0x804e
	ori r31, r31, 0x13c
	lbz r29, 0x0(r31)
	lwz r30, 0x0(r31)
	rlwinm r30, r30, 8, 0, 24       # (Mask: 0x80ffffff)
	stw r30, 0x0(r31)
	stb r29, -0x1(r14)
	b loc_0x092
loc_0x02F:
	cmpwi r31, 0x2
	blt loc_0x092
	lis r18, 0x804e
	ori r18, r18, 0x144
	li r15, 0x1
	cmpwi r15, 0x5
	bge loc_0x069
loc_0x036:
	lis r3, 0x8062
	ori r3, r3, 0x9a00
	subi r4, r15, 0x1
	bla 0x815c40
	cmpwi r3, -0x1
	ble loc_0x066
	mr r22, r3
	mr r4, r3
	lis r3, 0x8062
	ori r3, r3, 0x9a00
	lis r5, 0xffff
	ori r5, r5, 0xffff
	bla 0x814f20
	lwz r21, 0x60(r3)
	lwz r21, 0xd8(r21)
	lwz r3, 0x38(r21)
	li r4, 0x0
	bla 0x769cb8
	fctiwz f1, f1
	stfd f1, -0x30(r1)
	lwz r17, -0x2c(r1)
	lis r3, 0x8062
	ori r3, r3, 0x9a00
	mr r4, r22
	bla 0x8159e4
	bla 0x81c540
	neg r16, r3
	lis r31, 0x804e
	lwz r31, 0x908(r31)
	cmpwi r31, 0x2
	bne loc_0x05B
	stb r16, 0x0(r18)
	sth r17, 0x1(r18)
	stb r15, 0x3(r18)
	addi r18, r18, 0x4
	addi r19, r19, 0x1
	b loc_0x066
loc_0x05B:
	cmpwi r31, 0x3
	bne loc_0x066
	subi r16, r16, 0x7f
	neg r16, r16
	subi r17, r17, 0x7d0
	neg r17, r17
	stb r16, 0x0(r18)
	sth r17, 0x1(r18)
	stb r15, 0x3(r18)
	addi r18, r18, 0x4
	addi r19, r19, 0x1
loc_0x066:
	addi r15, r15, 0x1
	cmpwi r15, 0x5
	blt+ loc_0x036
loc_0x069:
	lis r3, 0x804e
	ori r3, r3, 0x144
	mr r4, r19
	li r5, 0x4
	lis r6, 0x804e
	ori r6, r6, 0x154
	bla 0x3f8acc
	lis r14, 0x804e
	ori r14, r14, 0x13b
	lis r18, 0x804e
	ori r18, r18, 0x143
	cmpwi r19, 0x0
	ble loc_0x07B
loc_0x076:
	lbzu r31, 0x4(r18)
	stbu r31, 0x1(r14)
	subi r19, r19, 0x1
	cmpwi r19, 0x0
	bgt+ loc_0x076
loc_0x07B:
	li r30, 0x0
	lis r14, 0x804e
	ori r14, r14, 0x13c
	li r31, 0x0
	lbz r29, 0x0(r14)
	cmpwi r31, 0x4
	bge loc_0x089
loc_0x082:
	cmpw r29, r30
	bne loc_0x085
	b loc_0x08B
loc_0x085:
	lbzu r29, 0x1(r14)
	addi r31, r31, 0x1
	cmpwi r31, 0x4
	blt+ loc_0x082
loc_0x089:
	lis r31, 0xffff
	ori r31, r31, 0xffff
loc_0x08B:
	lis r31, 0x804e
	ori r31, r31, 0x13c
	lbz r29, 0x1(r31)
	lwz r30, 0x1(r31)
	rlwinm r30, r30, 8, 0, 24       # (Mask: 0x80ffffff)
	stw r30, 0x1(r31)
	stb r29, -0x1(r14)
loc_0x092:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x8c
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	li r18, 0x0
	nop
}

#############################
[CM: Control Codes] End Match
#############################
HOOK @ $806D4850                # Address = $(ba + 0x006D4850)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	li r31, 0x0
	lis r30, 0x804e
	ori r30, r30, 0x758
	stw r31, 0x0(r30)
	lis r26, 0x804e
	ori r26, r26, 0x254
	li r23, 0x1
	stw r23, 0x0(r26)
	li r26, 0x0
	lis r23, 0x804e
	ori r23, r23, 0x240
	lwz r24, 0x0(r23)
	cmpwi r24, 0x0
	beq loc_0x019
	lbz r25, 0x0(r24)
	andi. r25, r25, 0xfff7
	stb r25, 0x0(r24)
	stw r26, 0x0(r23)
loc_0x019:
	lwz r24, 0x4(r23)
	cmpwi r24, 0x0
	beq loc_0x020
	lbz r25, 0x0(r24)
	andi. r25, r25, 0xfff7
	stb r25, 0x0(r24)
	stw r26, 0x4(r23)
loc_0x020:
	lwz r24, 0x8(r23)
	cmpwi r24, 0x0
	beq loc_0x027
	lbz r25, 0x0(r24)
	andi. r25, r25, 0xfff7
	stb r25, 0x0(r24)
	stw r26, 0x8(r23)
loc_0x027:
	lwz r24, 0xc(r23)
	cmpwi r24, 0x0
	beq loc_0x02E
	lbz r25, 0x0(r24)
	andi. r25, r25, 0xfff7
	stb r25, 0x0(r24)
	stw r26, 0xc(r23)
loc_0x02E:
	lis r14, 0x805b
	lwz r14, 0x50ac(r14)
	lwz r14, 0x10(r14)
	cmpwi r14, 0x0
	beq loc_0x035
	lwz r14, 0x8(r14)
	b loc_0x037
loc_0x035:
	lis r14, 0xffff
	ori r14, r14, 0xffff
loc_0x037:
	cmpwi r14, 0xa
	bne loc_0x094
	mr r16, r14
	lis r29, 0x8058
	lwzu r28, 0x4084(r29)
	lis r31, 0x804e
	lwz r31, 0xa30(r31)
	cmpwi r31, 0x1
	bne loc_0x042
	li r28, 0x0
	li r16, 0xd
loc_0x042:
	lis r31, 0x804e
	lwz r31, 0x908(r31)
	cmpwi r31, 0x0
	ble loc_0x054
	lwz r31, 0x24(r3)
	lwz r31, 0x8c(r31)
	cmpwi r31, 0x13
	bne loc_0x04B
	b loc_0x054
loc_0x04B:
	cmpwi r31, 0x19
	bne loc_0x04E
	b loc_0x054
loc_0x04E:
	lwz r28, 0x0(r29)
	li r31, 0x1
	lis r30, 0x804e
	ori r30, r30, 0x38
	stw r31, 0x0(r30)
	li r16, 0x1
loc_0x054:
	lis r30, 0x805b
	ori r30, r30, 0xacc4
	lis r26, 0x804e
	lhz r26, 0xa(r26)
	lis r25, 0x804e
	lhz r25, 0xe(r25)
	li r23, 0x0
	li r31, 0x0
	cmpwi r31, 0x8
	bge loc_0x06A
loc_0x05E:
	lwzu r27, 0x40(r30)
	and r24, r27, r26
	cmpw r24, r26
	bne loc_0x063
	li r23, 0x10
loc_0x063:
	and r24, r27, r25
	cmpw r24, r25
	bne loc_0x067
	li r23, 0x20
loc_0x067:
	addi r31, r31, 0x1
	cmpwi r31, 0x8
	blt+ loc_0x05E
loc_0x06A:
	lis r27, 0x804e
	ori r27, r27, 0x38
	li r26, 0x0
	lis r31, 0x804e
	lbz r31, 0xc(r31)
	rlwinm r31, r31, 1, 0, 31       # (Mask: 0xffffffff)
	xor r31, r31, r23
	cmpwi r31, 0x20
	bne loc_0x076
	li r16, 0xd
	li r28, 0x0
	stw r26, 0x0(r27)
loc_0x076:
	lis r31, 0x804e
	lbz r31, 0x8(r31)
	xor r31, r31, r23
	cmpwi r31, 0x10
	bne loc_0x07E
	li r16, 0x1
	lwz r28, 0x0(r29)
	stw r26, 0x0(r27)
loc_0x07E:
	lis r31, 0x805b
	lwz r31, 0x50ac(r31)
	lwz r31, 0x10(r31)
	stw r16, 0x8(r31)
	cmpw r14, r16
	beq loc_0x093
	li r30, 0x0
	lis r27, 0x8058
	ori r27, r27, 0x8003
	lis r26, 0x8058
	ori r26, r26, 0x8300
	li r31, 0x0
	cmpwi r31, 0x4
	bge loc_0x093
loc_0x08C:
	stw r30, 0x99(r27)
	stw r30, 0x68(r26)
	addi r27, r27, 0xa0
	addi r26, r26, 0x70
	addi r31, r31, 0x1
	cmpwi r31, 0x4
	blt+ loc_0x08C
loc_0x093:
	stw r28, 0x0(r29)
loc_0x094:
	lis r15, 0x804e
	lwz r15, 0x644(r15)
	addi r3, r15, 0x0
	bla 0x2632c
	cmpwi r14, 0xa
	bne loc_0x15D
	li r29, 0x0
	lis r30, 0x804e
	lwzu r31, 0x3c(r30)
	stw r29, 0x0(r30)
	cmpwi r31, 0x2
	bne loc_0x15D
	lis r21, 0x804e
	ori r21, r21, 0x648
	lis r4, 0x6e61
	ori r4, r4, 0x6e64
	stw r4, 0x0(r21)
	lis r4, 0x3a2f
	ori r4, r4, 0x636f
	stw r4, 0x4(r21)
	lis r4, 0x6c6c
	ori r4, r4, 0x6563
	stw r4, 0x8(r21)
	lis r4, 0x742e
	ori r4, r4, 0x7666
	stw r4, 0xc(r21)
	lis r4, 0x6600
	stw r4, 0x10(r21)
	lis r3, 0x804e
	ori r3, r3, 0x264
	li r4, 0x0
	lis r5, 0x804e
	ori r5, r5, 0x648
	bla 0x20f90
	li r3, 0x0
	lis r4, 0x1b
	ori r4, r4, 0xcf24
	bla 0x1e1a80
	lis r31, 0x804e
	ori r31, r31, 0x164
	lis r30, 0x804e
	ori r30, r30, 0x178
	lis r27, 0x804e
	ori r27, r27, 0x180
	li r3, 0x0
	stw r3, 0x0(r30)
	stw r3, 0x4(r30)
	lis r4, 0x4e03
	ori r4, r4, 0x41de
	stw r4, 0x0(r27)
	lis r4, 0xe6bb
	ori r4, r4, 0xaa41
	stw r4, 0x4(r27)
	lis r4, 0x6419
	ori r4, r4, 0xb3ea
	stw r4, 0x8(r27)
	lis r4, 0xe8f5
	ori r4, r4, 0x3bd9
	stw r4, 0xc(r27)
	li r3, 0x2a
	li r4, 0x1
	stw r3, 0x18(r27)
	stw r4, 0x1c(r27)
	bla 0x1e1b34
	mr r29, r3
	mr r28, r4
	lis r3, 0x804e
	ori r3, r3, 0x164
	li r4, 0x2a
	bla 0x152b5c
	lis r4, 0x804e
	lwz r4, 0x7cc(r4)
	addi r4, r4, 0x100
	bla 0x152c4c
	addi r3, r30, 0x0
	addi r4, r31, 0x0
	addi r5, r29, 0x0
	addi r6, r28, 0x0
	li r7, 0x2a
	li r8, 0x0
	li r9, 0x0
	bla 0x153610
	lwz r3, 0x0(r30)
	stw r3, 0x10(r27)
	lwz r3, 0x1c(r3)
	addi r3, r3, 0x20
	stw r3, 0x14(r27)
	subi r3, r27, 0x340
	lis r26, 0x804e
	ori r26, r26, 0x6e8
	lis r25, 0x804e
	ori r25, r25, 0x648
	addi r3, r29, 0x0
	addi r4, r28, 0x0
	addi r5, r25, 0x0
	bla 0x1e1d80
	lwz r19, 0x0(r25)
	lwz r24, 0x4(r25)
	lwz r23, 0x8(r25)
	lwz r22, 0xc(r25)
	lwz r21, 0x10(r25)
	lwz r20, 0x14(r25)
	addi r21, r21, 0x1
	li r3, 0x64
	mr r4, r20
	divwu r20, r4, r3
	mullw r20, r20, r3
	subf r20, r20, r4
	lis r4, 0x2f72
	ori r4, r4, 0x702f
	stw r4, 0x0(r26)
	lis r4, 0x7270
	ori r4, r4, 0x5f25
	stw r4, 0x4(r26)
	lis r4, 0x3032
	ori r4, r4, 0x6425
	stw r4, 0x8(r26)
	lis r4, 0x3032
	ori r4, r4, 0x6425
	stw r4, 0xc(r26)
	lis r4, 0x3032
	ori r4, r4, 0x645f
	stw r4, 0x10(r26)
	lis r4, 0x2530
	ori r4, r4, 0x3264
	stw r4, 0x14(r26)
	lis r4, 0x2530
	ori r4, r4, 0x3264
	stw r4, 0x18(r26)
	lis r4, 0x5f25
	ori r4, r4, 0x3032
	stw r4, 0x1c(r26)
	lis r4, 0x642e
	ori r4, r4, 0x6269
	stw r4, 0x20(r26)
	lis r4, 0x6e00
	stw r4, 0x24(r26)
	lis r3, 0x804e
	ori r3, r3, 0x648
	addi r4, r26, 0x0
	addi r5, r20, 0x0
	addi r6, r21, 0x0
	addi r7, r22, 0x0
	addi r8, r23, 0x0
	addi r9, r24, 0x0
	addi r10, r19, 0x0
	crxor 6, 6, 6
	bla 0x3f89fc
	lis r26, 0x804e
	ori r26, r26, 0x648
	lwz r24, 0x0(r30)
	lwz r25, 0x1c(r24)
	addi r25, r25, 0x20
	li r23, 0x2000
	li r3, 0x2a
	bla 0x24430
	addi r4, r23, 0x0
	bla 0x204e5c
	mr r23, r1
	addi r1, r3, 0x1f00
	mr r22, r3
	li r19, 0x8
loc_0x136:
	li r4, 0x0
	lis r3, 0x804e
	ori r3, r3, 0x75c
	stw r26, 0x0(r3)
	stw r4, 0x4(r3)
	stw r25, 0x8(r3)
	stw r24, 0xc(r3)
	stw r4, 0x10(r3)
	stw r4, 0x14(r3)
	bla 0x1d5a8
	cmplwi r3, 0x0
	beq loc_0x149
	addic. r19, r19, -0x1
	blt loc_0x149
	li r3, 0x0
	lis r4, 0x1b
	ori r4, r4, 0xcf24
	bla 0x1e1a80
	b loc_0x136
loc_0x149:
	lis r3, 0x804e
	ori r3, r3, 0x264
	li r4, 0x0
	bla 0x21038
	li r25, 0x0
	lis r24, 0x804e
	ori r24, r24, 0x264
	stw r25, 0x0(r24)
	mr r1, r23
	addi r3, r22, 0x0
	bla 0x2632c
	mr r3, r31
	li r4, 0x0
	bla 0x152bdc
	lwz r25, 0x28(r27)
	addi r3, r25, 0x0
	bla 0x2632c
	lwz r25, 0x0(r30)
	addi r3, r25, 0x0
	bla 0x2632c
loc_0x15D:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	mr r31, r3
}

########################
[CM: Control Codes] Draw
########################
HOOK @ $8000E588                # Address = $(ba + 0x0000E588)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	bl 0x9b0
	stwu r1, -0x12c(r1)
	stmw r3, 0x8(r1)
	lis r31, 0x804e
	lwz r31, 0x758(r31)
	cmpwi r31, 0x1
	bne loc_0x09E
	lis r31, 0x804e
	lwz r31, 0xe68(r31)
	cmpwi r31, 0x1
	bne loc_0x09E
	li r31, 0x14
	bla 0x19fa4
	bla 0x18de4
	bla 0x1a5c0
	li r3, 0x1
	li r4, 0x3
	li r5, 0x0
	bla 0x1f4774
	li r3, 0x7
	li r4, 0x0
	li r5, 0x1
	li r6, 0x7
	li r7, 0x0
	bla 0x1f3fd8
	li r4, 0x0
	addi r3, r31, 0x0
	bla 0x1f12ac
	lis r30, 0x805c
	lwz r30, -0x75f8(r30)
	lis r20, 0x804e
	lwz r20, 0x644(r20)
	lwzu r21, 0x4(r20)
	cmpwi r21, 0x0
	beq loc_0x09E
loc_0x028:
	lwz r31, 0x8(r21)
	lwz r31, 0x0(r31)
	or r31, r31, r30
	cmpwi r31, 0x0
	ble loc_0x09B
	lwz r24, 0x64(r21)
	cmpwi r30, 0x0
	beq loc_0x05F
	lwz r31, 0x8(r24)
	lis r3, 0x66
	ori r3, r3, 0xffff
	stw r3, 0x8(r31)
	li r3, 0x0
	stw r3, 0xc(r31)
	stw r3, 0x14(r31)
	addi r3, r31, 0x14
	stw r3, 0x0(r31)
	lwz r31, 0x34(r21)
	lwz r29, 0x38(r21)
	bla 0x4a750
	lbz r31, 0x7(r31)
	mulli r29, r29, 0x4
	mulli r31, r31, 0x40
	lis r27, 0x805b
	ori r27, r27, 0xacf0
	addi r29, r29, 0xa
	lhzx r31, r27, r31
	sthx r31, r3, r29
	lwz r31, 0x18(r21)
	mr r3, r31
	bla 0x48250
	lfs f12, 0x10(r31)
	lfs f13, 0x14(r31)
	lwz r25, 0x14(r21)
	lfs f14, 0x8(r25)
	lfs f15, 0xc(r25)
	stfs f12, 0x8(r25)
	stfs f13, 0xc(r25)
	lwz r31, 0x10(r21)
	lwz r26, 0x1c(r21)
	lwz r29, 0x8(r31)
	stw r26, 0x8(r31)
	lwz r26, 0x20(r21)
	lwz r27, 0xc(r31)
	stw r26, 0xc(r31)
	lis r3, 0x80b8
	ori r3, r3, 0x97bc
	lwz r4, -0x4(r20)
	li r18, 0xc0de
	andi. r18, r18, 0xffff
	bla 0x8778d8
	stw r29, 0x8(r31)
	stw r27, 0xc(r31)
	stfs f14, 0x8(r25)
	stfs f15, 0xc(r25)
loc_0x05F:
	lwzu r22, 0x0(r24)
	li r23, 0x0
	cmpwi r23, 0x4
	bge loc_0x080
loc_0x063:
	lwz r5, 0x14(r22)
	cmpwi r5, 0x1
	bne loc_0x07C
	lwz r5, 0xc(r22)
	cmpwi r5, 0x2
	blt loc_0x07C
	lwz r3, 0x4(r22)
	li r4, 0x1
	bla 0x1f1088
	lwz r3, 0xc(r22)
	lwz r4, 0x8(r22)
	lis r5, 0xcc01
	li r6, 0x0
	addi r8, r22, 0x14
	cmpwi r3, 0x0
	ble loc_0x07C
loc_0x073:
	lwzu r7, 0x4(r8)
	stw r7, -0x8000(r5)
	lwzu r7, 0x4(r8)
	stw r7, -0x8000(r5)
	stw r6, -0x8000(r5)
	stw r4, -0x8000(r5)
	subi r3, r3, 0x1
	cmpwi r3, 0x0
	bgt+ loc_0x073
loc_0x07C:
	lwzu r22, 0x4(r24)
	addi r23, r23, 0x1
	cmpwi r23, 0x4
	blt+ loc_0x063
loc_0x080:
	cmpwi r30, 0x0
	beq loc_0x09B
	lwz r5, 0x14(r22)
	cmpwi r5, 0x1
	bne loc_0x09B
	lwz r5, 0xc(r22)
	cmpwi r5, 0x2
	blt loc_0x09B
	lwz r3, 0x4(r22)
	li r4, 0x1
	bla 0x1f1088
	lwz r3, 0xc(r22)
	lwz r4, 0x8(r22)
	lis r5, 0xcc01
	li r6, 0x0
	addi r8, r22, 0x14
	cmpwi r3, 0x0
	ble loc_0x09B
loc_0x092:
	lwzu r7, 0x4(r8)
	stw r7, -0x8000(r5)
	lwzu r7, 0x4(r8)
	stw r7, -0x8000(r5)
	stw r6, -0x8000(r5)
	stw r4, -0x8000(r5)
	subi r3, r3, 0x1
	cmpwi r3, 0x0
	bgt+ loc_0x092
loc_0x09B:
	lwzu r21, 0x8(r20)
	cmpwi r21, 0x0
	bne+ loc_0x028
loc_0x09E:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x12c
	bl 0x7c0
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	addi r1, r1, 0x30
}

##################################
[CM: Control Codes] Load Code Menu
##################################
HOOK @ $8002D4F4                # Address = $(ba + 0x0002D4F4)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	lis r31, 0x804e
	ori r31, r31, 0x648
	lis r30, 0x804e
	ori r30, r30, 0x660
	stw r30, 0x0(r31)
	li r30, 0x0
	stw r30, 0x4(r31)
	stw r30, 0x8(r31)
	stw r30, 0x10(r31)
	lis r30, 0x804e
	stw r30, 0xc(r31)
	lis r30, 0xffff
	ori r30, r30, 0xffff
	stw r30, 0x14(r31)
	addi r30, r31, 0x18
	lis r4, 0x502b
	ori r4, r4, 0x4558
	stw r4, 0x0(r30)
	lis r4, 0x2f2e
	ori r4, r4, 0x2f2e
	stw r4, 0x4(r30)
	lis r4, 0x2f70
	ori r4, r4, 0x662f
	stw r4, 0x8(r30)
	lis r4, 0x6d65
	ori r4, r4, 0x6e75
	stw r4, 0xc(r30)
	lis r4, 0x332f
	ori r4, r4, 0x646e
	stw r4, 0x10(r30)
	lis r4, 0x6574
	ori r4, r4, 0x2e63
	stw r4, 0x14(r30)
	lis r4, 0x6d6e
	ori r4, r4, 0x7500
	stw r4, 0x18(r30)
	mr r3, r31
	bla 0x1cbf4
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	stwu r1, -0x20(r1)
}

#####################################################################################
[CM: Control Codes] Update Heap Address Cache
# Updates the Code Menu's Heap Address Cache whenever a memory layout change happens.
#####################################################################################
HOOK @ $806BE080                # Address = $(ba + 0x006BE080)
{
	lis r11, 0x804e
	ori r11, r11, 0x7cc
	li r12, 0x4
	addi r10, r11, 0x5
loc_0x004:
	addic. r12, r12, -0x4
	lbzu r3, -0x1(r10)
	bla 0x249cc
	stwx r3, r11, r12
	bne loc_0x004
	bla 0x6caa8
	nop
}

############################################
[CM: Control Codes] Add New Character Buffer
############################################
HOOK @ $8081F4B4                # Address = $(ba + 0x0081F4B4)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	bl 0x60c
	stwu r1, -0xf4(r1)
	stmw r3, 0x8(r1)
	lis r28, 0x804e
	lwz r28, 0x758(r28)
	mr r22, r31
	cmpwi r28, 0x1
	bne loc_0x0F4
	lbz r30, 0xa(r22)
	addi r29, r22, 0x34
	rlwinm r30, r30, 3, 0, 31       # (Mask: 0xffffffff)
	lwzx r3, r29, r30
	li r14, 0x10
loc_0x012:
	lwz r31, 0x60(r3)
	lis r30, 0x804e
	lwz r30, 0x644(r30)
	lwz r23, 0x0(r30)
	cmpwi r23, 0x0
	beq loc_0x01D
loc_0x018:
	cmplw r23, r31
	beq loc_0x0F4
	lwzu r23, 0x8(r30)
	cmpwi r23, 0x0
	bne+ loc_0x018
loc_0x01D:
	mr r24, r3
	lwz r25, 0xd8(r31)
	li r30, 0x0
	lis r29, 0x804e
	lwz r29, 0x644(r29)
	lwz r3, 0x0(r29)
	cmpw r3, r30
	beq loc_0x028
loc_0x025:
	lwzu r3, 0x8(r29)
	cmpw r3, r30
	bne+ loc_0x025
loc_0x028:
	stw r31, 0x0(r29)
	stw r30, 0x8(r29)
	stw r30, 0xc(r29)
	li r30, 0x88
	li r3, 0x2a
	bla 0x24430
	addi r4, r30, 0x0
	bla 0x204e5c
	stw r3, 0x4(r29)
	mr r23, r3
	mr r3, r24
	bla 0x83ae38
	stw r3, 0x18(r23)
	lis r3, 0x8062
	ori r3, r3, 0x9a00
	bla 0x815ad0
	stw r3, 0x38(r23)
	stw r24, 0x3c(r23)
	mulli r29, r3, 0x5c
	lis r30, 0x9018
	ori r30, r30, 0xfb8
	add r30, r30, r29
	stw r30, 0x34(r23)
	cmpwi r3, 0x3
	bgt loc_0x059
	cmpwi r3, 0x0
	blt loc_0x059
	rlwinm r4, r3, 2, 0, 31         # (Mask: 0xffffffff)
	lis r29, 0x804e
	ori r29, r29, 0xec
	lwzx r29, r29, r4
	lbz r30, 0x0(r30)
	lwz r3, 0x18(r29)
	addi r26, r3, 0x1f
	li r28, 0x0
	lbz r27, 0x0(r26)
	cmpwi r28, 0x34
	bge loc_0x055
loc_0x04E:
	cmpw r27, r30
	bne loc_0x051
	b loc_0x057
loc_0x051:
	lbzu r27, 0x4(r26)
	addi r28, r28, 0x1
	cmpwi r28, 0x34
	blt+ loc_0x04E
loc_0x055:
	lis r28, 0xffff
	ori r28, r28, 0xffff
loc_0x057:
	stw r28, 0x8(r29)
	stw r28, 0x10(r29)
loc_0x059:
	mr r3, r31
	li r4, 0xbcf
	li r5, 0x0
	bla 0x796c6c
	fneg f1, f1
	stfs f1, 0x2c(r23)
	mr r3, r31
	li r4, 0xbd0
	li r5, 0x0
	bla 0x796c6c
	fneg f1, f1
	stfs f1, 0x30(r23)
	lwz r29, 0x64(r25)
	lwz r29, 0x20(r29)
	lwz r29, 0xc(r29)
	stw r29, 0x0(r23)
	lwzu r28, 0xe0(r29)
	stw r28, 0x4(r23)
	stw r29, 0x8(r23)
	lwz r29, 0xc(r25)
	stw r29, 0xc(r23)
	lwz r28, 0x7c(r25)
	lwz r29, 0x7c(r28)
	stw r29, 0x10(r23)
	lwz r29, 0x5c(r25)
	lwz r29, 0x14c(r29)
	stw r29, 0x14(r23)
	li r29, 0x24
	li r3, 0x2a
	bla 0x24430
	addi r4, r29, 0x0
	bla 0x204e5c
	stw r3, 0x64(r23)
	mr r29, r3
	addi r28, r29, 0x4
	li r27, 0x30
	li r3, 0x2a
	bla 0x24430
	addi r4, r27, 0x0
	bla 0x204e5c
	stw r3, 0x0(r28)
	li r4, 0x0
	li r5, 0xb0
	lis r6, 0x33cc
	ori r6, r6, 0x33ff
	stw r5, 0x4(r3)
	subi r5, r27, 0x8
	stw r5, 0x10(r3)
	stw r6, 0x8(r3)
	stw r4, 0xc(r3)
	stw r4, 0x14(r3)
	addi r4, r3, 0x14
	stw r4, 0x0(r3)
	lis r27, 0x805b
	lwz r27, 0x50ac(r27)
	lwz r27, 0x10(r27)
	lwz r27, 0x0(r27)
	lis r28, 0x8070
	ori r28, r28, 0x2b60
	cmpw r27, r28
	bne loc_0x098
	li r27, 0x298
	b loc_0x099
loc_0x098:
	li r27, 0x1018
loc_0x099:
	addi r28, r29, 0x0
	li r3, 0x2a
	bla 0x24430
	addi r4, r27, 0x0
	bla 0x204e5c
	stw r3, 0x0(r28)
	li r4, 0x0
	li r5, 0xb0
	lis r6, 0xff99
	ori r6, r6, 0xff
	stw r5, 0x4(r3)
	subi r5, r27, 0x8
	stw r5, 0x10(r3)
	stw r6, 0x8(r3)
	stw r4, 0xc(r3)
	stw r4, 0x14(r3)
	addi r4, r3, 0x14
	stw r4, 0x0(r3)
	lis r27, 0x805b
	lwz r27, 0x50ac(r27)
	lwz r27, 0x10(r27)
	lwz r27, 0x0(r27)
	lis r28, 0x8070
	ori r28, r28, 0x2b60
	cmpw r27, r28
	bne loc_0x0B5
	li r27, 0x298
	b loc_0x0B6
loc_0x0B5:
	li r27, 0x1018
loc_0x0B6:
	addi r28, r29, 0x8
	li r3, 0x2a
	bla 0x24430
	addi r4, r27, 0x0
	bla 0x204e5c
	stw r3, 0x0(r28)
	li r4, 0x0
	li r5, 0xb0
	lis r6, 0x66
	ori r6, r6, 0xffff
	stw r5, 0x4(r3)
	subi r5, r27, 0x8
	stw r5, 0x10(r3)
	stw r6, 0x8(r3)
	stw r4, 0xc(r3)
	stw r4, 0x14(r3)
	addi r4, r3, 0x14
	stw r4, 0x0(r3)
	addi r28, r29, 0xc
	li r3, 0x2a
	bla 0x24430
	addi r4, r27, 0x0
	bla 0x204e5c
	stw r3, 0x0(r28)
	li r4, 0x0
	li r5, 0xb0
	lis r6, 0xffff
	ori r6, r6, 0xff
	stw r5, 0x4(r3)
	subi r5, r27, 0x8
	stw r5, 0x10(r3)
	stw r6, 0x8(r3)
	stw r4, 0xc(r3)
	stw r4, 0x14(r3)
	addi r4, r3, 0x14
	stw r4, 0x0(r3)
	addi r28, r29, 0x10
	li r3, 0x2a
	bla 0x24430
	addi r4, r27, 0x0
	bla 0x204e5c
	stw r3, 0x0(r28)
	li r4, 0x0
	li r5, 0xb0
	lis r6, 0x6e00
	ori r6, r6, 0x94ff
	stw r5, 0x4(r3)
	subi r5, r27, 0x8
	stw r5, 0x10(r3)
	stw r6, 0x8(r3)
	stw r4, 0xc(r3)
	stw r4, 0x14(r3)
	addi r4, r3, 0x14
	stw r4, 0x0(r3)
	li r28, 0x0
	stw r28, 0x14(r29)
	lwz r30, 0x5c(r22)
	cmpw r30, r14
	bne loc_0x0F4
	lwz r3, 0x3c(r22)
	li r14, 0x0
	b loc_0x012
loc_0x0F4:
	lmw r3, 0x8(r1)
	addi r1, r1, 0xf4
	bl 0x2c4
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	lfd f31, 0x58(r1)
}

###########################################
[CM: Control Codes] Delete Character Buffer
###########################################
HOOK @ $8082F3F4                # Address = $(ba + 0x0082F3F4)
{
	lis r31, 0x804e
	lwz r31, 0x758(r31)
	cmpwi r31, 0x1
	bne loc_0x034
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	lwz r4, 0x60(r4)
	lis r28, 0x804e
	lwz r28, 0x644(r28)
	lwz r31, 0x0(r28)
	cmpw r31, r4
	beq loc_0x016
loc_0x011:
	lwzu r31, 0x8(r28)
	cmplwi r31, 0x0
	beq loc_0x02D
	cmpw r31, r4
	bne+ loc_0x011
loc_0x016:
	lwz r31, 0x4(r28)
	lwz r30, 0x64(r31)
	subi r29, r30, 0x4
	lwzu r3, 0x4(r29)
	cmpwi r3, 0x0
	beq loc_0x020
loc_0x01C:
	bla 0x2632c
	lwzu r3, 0x4(r29)
	cmpwi r3, 0x0
	bne+ loc_0x01C
loc_0x020:
	addi r3, r30, 0x0
	bla 0x2632c
	addi r3, r31, 0x0
	bla 0x2632c
	li r30, 0x1
	cmpwi r30, 0x0
	beq loc_0x02D
loc_0x027:
	lwzu r30, 0x8(r28)
	lwz r29, 0x4(r28)
	stw r30, -0x8(r28)
	stw r29, -0x4(r28)
	cmpwi r30, 0x0
	bne+ loc_0x027
loc_0x02D:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
loc_0x034:
	li r31, 0x0
}

########################################################
[CM: Control Codes] Delete Character Buffer on Transform
########################################################
HOOK @ $808205BC                # Address = $(ba + 0x008205BC)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	bl 0x12c
	stwu r1, -0xf4(r1)
	stmw r3, 0x8(r1)
	mr r22, r4
	lbz r28, 0xa(r3)
	addi r30, r3, 0x34
	rlwinm r29, r4, 3, 0, 31        # (Mask: 0xffffffff)
	rlwinm r28, r28, 3, 0, 31       # (Mask: 0xffffffff)
	lwzx r3, r30, r29
	lwzx r4, r30, r28
	lwz r31, 0x60(r3)
	mr r24, r3
	lwz r4, 0x60(r4)
	lis r28, 0x804e
	lwz r28, 0x644(r28)
	lwz r23, 0x0(r28)
	cmpw r23, r4
	beq loc_0x01C
loc_0x017:
	lwzu r23, 0x8(r28)
	cmplwi r23, 0x0
	beq loc_0x033
	cmpw r23, r4
	bne+ loc_0x017
loc_0x01C:
	lwz r23, 0x4(r28)
	lwz r30, 0x64(r23)
	subi r29, r30, 0x4
	lwzu r3, 0x4(r29)
	cmpwi r3, 0x0
	beq loc_0x026
loc_0x022:
	bla 0x2632c
	lwzu r3, 0x4(r29)
	cmpwi r3, 0x0
	bne+ loc_0x022
loc_0x026:
	addi r3, r30, 0x0
	bla 0x2632c
	addi r3, r23, 0x0
	bla 0x2632c
	li r30, 0x1
	cmpwi r30, 0x0
	beq loc_0x033
loc_0x02D:
	lwzu r30, 0x8(r28)
	lwz r29, 0x4(r28)
	stw r30, -0x8(r28)
	stw r29, -0x4(r28)
	cmpwi r30, 0x0
	bne+ loc_0x02D
loc_0x033:
	lmw r3, 0x8(r1)
	addi r1, r1, 0xf4
	bl 0xe8
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	stb r4, 0xb(r3)
	nop
}

#############################################
[CM: _UtilitySubroutines v1.0.0]  [QuickLava]
#############################################
HOOK @ $804E07D4                # Address = $(ba + 0x004E07D4)
{
	stfd f29, -0xf8(r1)
	stfd f28, -0xf0(r1)
	stfd f27, -0xe8(r1)
	stfd f26, -0xe0(r1)
	stfd f25, -0xd8(r1)
	stfd f24, -0xd0(r1)
	stfd f23, -0xc8(r1)
	stfd f22, -0xc0(r1)
	stfd f21, -0xb8(r1)
	stfd f20, -0xb0(r1)
	stfd f19, -0xa8(r1)
	stfd f18, -0xa0(r1)
	stfd f17, -0x98(r1)
	stfd f16, -0x90(r1)
	stfd f15, -0x88(r1)
	stfd f14, -0x80(r1)
	stfd f13, -0x78(r1)
	stfd f12, -0x70(r1)
	stfd f11, -0x68(r1)
	stfd f10, -0x60(r1)
	stfd f9, -0x58(r1)
	stfd f8, -0x50(r1)
	stfd f7, -0x48(r1)
	stfd f6, -0x40(r1)
	stfd f5, -0x38(r1)
	stfd f4, -0x30(r1)
	stfd f3, -0x28(r1)
	stfd f2, -0x20(r1)
	stfd f1, -0x18(r1)
	stfd f0, -0x10(r1)
	blr
	lfd f29, -0xf8(r1)
	lfd f28, -0xf0(r1)
	lfd f27, -0xe8(r1)
	lfd f26, -0xe0(r1)
	lfd f25, -0xd8(r1)
	lfd f24, -0xd0(r1)
	lfd f23, -0xc8(r1)
	lfd f22, -0xc0(r1)
	lfd f21, -0xb8(r1)
	lfd f20, -0xb0(r1)
	lfd f19, -0xa8(r1)
	lfd f18, -0xa0(r1)
	lfd f17, -0x98(r1)
	lfd f16, -0x90(r1)
	lfd f15, -0x88(r1)
	lfd f14, -0x80(r1)
	lfd f13, -0x78(r1)
	lfd f12, -0x70(r1)
	lfd f11, -0x68(r1)
	lfd f10, -0x60(r1)
	lfd f9, -0x58(r1)
	lfd f8, -0x50(r1)
	lfd f7, -0x48(r1)
	lfd f6, -0x40(r1)
	lfd f5, -0x38(r1)
	lfd f4, -0x30(r1)
	lfd f3, -0x28(r1)
	lfd f2, -0x20(r1)
	lfd f1, -0x18(r1)
	lfd f0, -0x10(r1)
	blr
	lis r3, 0x805a
	lwz r3, 0x1d0(r3)
	lfs f1, 0x18(r13)
	ba 0x74ecc
	nop
}

####################
Unattested Code 0
####################
* 064E0778 00000010             # String Write (16 characters) @ $(ba + 0x004E0778):
* 30313233 34353637             # 	   "01234567 ...
* 38394142 43444546             # 	... 89ABCDEF" (Note: Not Null-Terminated!)

#########################################
[CM: Tag Based Costumes] recordActiveTags
#########################################
HOOK @ $806A0718                # Address = $(ba + 0x006A0718)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	lwz r30, -0x34(r3)
	lbz r29, 0x57(r3)
	lis r28, 0x804e
	ori r28, r28, 0x773
	andi. r29, r29, 0x7
	stbx r30, r28, r29
	lis r30, 0x804e
	ori r30, r30, 0x25b
	li r28, 0x1
	stbx r28, r30, r29
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	mflr r0
}

######################################
[CM: Tag Based Costumes] setTagCostume
######################################
HOOK @ $8084D0D4                # Address = $(ba + 0x0084D0D4)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	lis r31, 0x804e
	lwz r31, 0xad8(r31)
	cmpwi r31, 0x2
	beq loc_0x07A
	cmpwi r31, 0x0
	bne loc_0x018
	lis r30, 0x804e
	lbz r30, 0x258(r30)
	lis r29, 0x804e
	lbz r29, 0x25b(r29)
	cmpwi r30, 0x1
	bne loc_0x017
	cmpwi r29, 0x1
	bne loc_0x016
	li r31, 0x1
loc_0x016:
	b loc_0x018
loc_0x017:
	li r31, 0x1
loc_0x018:
	lis r30, 0x805b
	lwz r30, 0x50ac(r30)
	lwz r30, 0x10(r30)
	lwz r30, 0x0(r30)
	lis r29, 0x8070
	ori r29, r29, 0x2b60
	cmpw r30, r29
	bne loc_0x021
	li r31, 0x0
loc_0x021:
	cmpwi r31, 0x1
	bne loc_0x072
	lis r31, 0x804e
	ori r31, r31, 0x788
	stw r4, 0x0(r31)
	lis r29, 0x804e
	ori r29, r29, 0x774
	lbzx r29, r29, r8
	cmpwi r29, 0x78
	bge loc_0x068
	mr r30, r4
	lis r31, 0x804e
	ori r31, r31, 0x648
	lis r4, 0x413a
	ori r4, r4, 0x2f50
	stw r4, 0x0(r31)
	lis r4, 0x2b45
	ori r4, r4, 0x582f
	stw r4, 0x4(r31)
	lis r4, 0x2e2f
	ori r4, r4, 0x2e2f
	stw r4, 0x8(r31)
	lis r4, 0x7066
	stw r4, 0xc(r31)
	lis r3, 0x804e
	ori r3, r3, 0x656
	mr r4, r30
	bla 0x3fa280
	subi r20, r7, 0x7
	mulli r31, r29, 0x124
	lis r30, 0x9017
	ori r30, r30, 0x2e20
	lhzux r31, r30, r31
	li r27, 0x24
	stbu r27, 0x1(r20)
	lis r27, 0x804e
	ori r27, r27, 0x778
	cmpwi r31, 0x0
	beq loc_0x054
loc_0x048:
	li r29, 0x14
	cmpwi r29, 0x21
	bge loc_0x051
loc_0x04B:
	rlwnm r28, r31, r29, 28, 31     # (Mask: 0x0000000f)
	lbzx r28, r27, r28
	stbu r28, 0x1(r20)
	addi r29, r29, 0x4
	cmpwi r29, 0x21
	blt+ loc_0x04B
loc_0x051:
	lhzu r31, 0x2(r30)
	cmpwi r31, 0x0
	bne+ loc_0x048
loc_0x054:
	lis r31, 0x2e70
	ori r31, r31, 0x6163
	stw r31, 0x1(r20)
	li r31, 0x0
	stw r31, 0x5(r20)
	lis r4, 0x804e
	ori r4, r4, 0x6f8
	lis r29, 0x7200
	lis r3, 0x804e
	ori r3, r3, 0x648
	stw r29, 0x0(r4)
	bla 0x3ebeb8
	cmpwi r3, 0x0
	beq loc_0x068
	bla 0x3ebe8c
	lis r31, 0x804e
	ori r31, r31, 0x788
	lis r30, 0x804e
	ori r30, r30, 0x656
	stw r30, 0x0(r31)
loc_0x068:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	lis r4, 0x804e
	lwz r4, 0x788(r4)
	b loc_0x079
loc_0x072:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
loc_0x079:
	b loc_0x081
loc_0x07A:
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
loc_0x081:
	li r9, 0xff
	nop
}

####################################################
[CM: Tag Based Costumes] reloadCostumeAfterTagSelect
####################################################
HOOK @ $8094641C                # Address = $(ba + 0x0094641C)
{
	lbz r3, 0x2(r31)
	lis r4, 0x804e
	ori r4, r4, 0x25c
	lbzx r6, r3, r4
	cmpwi r6, 0x1
	bne loc_0x010
	li r6, 0x0
	stbx r6, r4, r3
	lis r6, 0x804e
	lwz r6, 0x758(r6)
	cmpwi r6, 0x1
	beq loc_0x00E
	li r3, 0x7f
	b loc_0x00F
loc_0x00E:
	lbz r3, 0x5b(r30)
loc_0x00F:
	b %END%
loc_0x010:
	lbz r3, 0x5b(r30)
}

############################################
[CM: Tag Based Costumes] teamBattleTagReload
############################################
HOOK @ $8068A4A0                # Address = $(ba + 0x0068A4A0)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	lis r28, 0x804e
	ori r28, r28, 0x258
	lwz r27, 0x5c8(r31)
	stw r27, 0x0(r28)
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	mr r3, r31
}

####################################################
[CM: Tag Based Costumes] updateTagsWhenOptionChanged
####################################################
HOOK @ $8001735C                # Address = $(ba + 0x0001735C)
{
	stw r0, -0x4(r1)
	mflr r0
	stw r0, 0x4(r1)
	mfctr r0
	stw r0, -0x8(r1)
	stwu r1, -0x84(r1)
	stmw r3, 0x8(r1)
	lis r28, 0x804e
	lwz r28, 0x260(r28)
	lis r27, 0x804e
	lwz r27, 0xad8(r27)
	cmpw r28, r27
	beq loc_0x014
	lis r30, 0x804e
	ori r30, r30, 0x25c
	li r29, 0x1
	stb r29, 0x0(r30)
	stb r29, 0x1(r30)
	stb r29, 0x2(r30)
	stb r29, 0x3(r30)
loc_0x014:
	lis r28, 0x804e
	ori r28, r28, 0x260
	lis r27, 0x804e
	lwz r27, 0xad8(r27)
	stw r27, 0x0(r28)
	lmw r3, 0x8(r1)
	addi r1, r1, 0x84
	lwz r0, -0x8(r1)
	mtctr r0
	lwz r0, 0x4(r1)
	mtlr r0
	lwz r0, -0x4(r1)
	cmpwi r24, 0x1
}

#######################################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Incr and Decr Slot Color with L/R, Reset with Z on Player Kind Button [QuickLava]
#######################################################################################################################
HOOK @ $8068B168                # Address = $(ba + 0x0068B168)
{
	rlwinm. r12, r0, 24, 31, 31     # (Mask: 0x00000100)
	bne loc_0x046
	rlwinm r12, r0, 29, 30, 30      # (Mask: 0x00000010)
	rlwimi r12, r0, 29, 28, 28      # (Mask: 0x00000040)
	rlwimi r12, r0, 29, 29, 29      # (Mask: 0x00000020)
	word 0x7D801120                 # mtcrf 0x1, r12
	lis r11, 0x804e
	lbz r12, 0x305(r11)
	li r10, 0x0
	li r30, 0x1
	rlwnm r30, r30, r28, 24, 31     # (Mask: 0x000000ff)
	lbz r0, 0x34(r25)
	cmplwi r0, 0x60
	word 0x4C00E102                 # crandc 0, 0, 28
	blt loc_0x014
	and. r0, r12, r30
	bne loc_0x013
	or r12, r12, r30
	subi r10, r10, 0x1
loc_0x013:
	b loc_0x017
loc_0x014:
	cmplwi r0, 0x30
	bgt loc_0x017
	andc r12, r12, r30
loc_0x017:
	rlwinm. r30, r30, 4, 24, 31     # (Mask: 0xf000000f)
	lbz r0, 0x35(r25)
	cmplwi r0, 0x60
	word 0x4C00E902                 # crandc 0, 0, 29
	blt loc_0x021
	and. r0, r12, r30
	bne loc_0x020
	or r12, r12, r30
	addi r10, r10, 0x1
loc_0x020:
	b loc_0x024
loc_0x021:
	cmplwi r0, 0x30
	bgt loc_0x024
	andc r12, r12, r30
loc_0x024:
	stb r12, 0x305(r11)
	li r0, 0x0
	cmplwi r10, 0x0
	word 0x4C42F102                 # crandc 2, 2, 30
	beq loc_0x046
	subi r12, r3, 0x1c
	cmplwi r12, 0x2
	bge loc_0x046
	li r3, 0x1d
	mr r26, r3
	lwz r12, 0x44(r4)
	lwz r12, 0x1b4(r12)
	cmplwi r12, 0x1
	bne loc_0x046
	lbz r12, 0x304(r11)
	cmpwi r12, 0x10
	beq loc_0x046
	rlwimi r11, r29, 2, 16, 29      # (Mask: 0x00003fff)
	lwz r11, 0x2f4(r11)
	lwz r12, 0x8(r11)
	add r10, r12, r10
	cmpwi r10, 0xc
	ble loc_0x03C
	li r10, 0x0
loc_0x03C:
	cmpwi r10, 0x0
	bge loc_0x03F
	li r10, 0xc
loc_0x03F:
	bne cr7, loc_0x041
	lwz r10, 0x10(r11)
loc_0x041:
	stw r10, 0x8(r11)
	lwz r11, 0x44(r4)
	li r12, 0x0
	stw r12, 0x1b4(r11)
	li r0, 0x100
loc_0x046:
	rlwinm. r0, r0, 0, 23, 23       # (Mask: 0x00000100)
}

HOOK @ $806828CC                # Address = $(ba + 0x006828CC)
{
	li r12, 0xffff
	lis r11, 0x804e
	stb r12, 0x305(r11)
	li r4, 0x2a
	nop
}

#############################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Results Screen Player Names are Transparent [QuickLava]
#############################################################################################
* 040EA724 3D60804E             # 32-Bit Write @ $(ba + 0x000EA724):  0x3D60804E

HOOK @ $800EA73C                # Address = $(ba + 0x000EA73C)
{
	lwz r5, 0xc(r3)
	mulli r12, r4, 0x48
	stbx r11, r5, r12
	addi r11, r11, 0x7a4
	lswi r5, r11, 16
}

HOOK @ $800EA8C0                # Address = $(ba + 0x000EA8C0)
{
	lwz r5, 0xc(r3)
	mulli r12, r4, 0x48
	lis r11, 0x804e
	stbx r11, r5, r12
	addi r11, r11, 0x7a4
	lswi r5, r11, 16
	nop
}

##################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] CSS Player Names are Transparent [QuickLava]
##################################################################################
HOOK @ $8069B268                # Address = $(ba + 0x0069B268)
{
	lis r11, 0x804e
	addi r11, r11, 0x7a4
	lswi r5, r11, 16
}

##################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Cache SelChar Team Battle Status [QuickLava]
##################################################################################
HOOK @ $8068EDA8                # Address = $(ba + 0x0068EDA8)
{
	rlwinm r12, r4, 3, 0, 28        # (Mask: 0x1fffffff)
	addi r12, r12, 0x8
	lis r11, 0x804e
	stb r12, 0x304(r11)
	mr r28, r3
}

#######################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Cache In-game Mode Team Battle Status [QuickLava]
#######################################################################################
HOOK @ $800E0A44                # Address = $(ba + 0x000E0A44)
{
	rlwinm r12, r0, 3, 0, 28        # (Mask: 0x1fffffff)
	addi r12, r12, 0x8
	lis r11, 0x804e
	stb r12, 0x304(r11)
	cmpwi r0, 0x0
}

##########################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Only 2P Stadium Boss Battles Are Considered Team Battles [QuickLava]
##########################################################################################################
HOOK @ $806E5F08                # Address = $(ba + 0x006E5F08)
{
	stb r23, 0x13(r30)
	stb r31, 0x99(r25)
	nop
}

################################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Disable Franchise Icon Color 10-Frame Offset in Results Screen [QuickLava]
################################################################################################################
* C60EBB98 800EBBB8             # Create Branch @ $(ba + 0x000EBB98): b 0x800EBBB8
* C60EBDE4 800EBE00             # Create Branch @ $(ba + 0x000EBDE4): b 0x800EBE00

###############################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Hand Color Fix [QuickLava]
# Fixes a conflict with Eon's Roster-Size-Based Hand Resizing code, which could
# in some cases cause CSS hands to wind up the wrong color.
###############################################################################
* 0469CA2C C0031014             # 32-Bit Write @ $(ba + 0x0069CA2C):  0xC0031014

#######################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Re-Enable Material Recalc on Certain In-Game Elements [QuickLava]
# Prevents skipping the material recalc on certain in-game HUD elements, specifically
# including the blastzone magnifying glass (and accompanying arrow) and the nametag arrow elements.
# Re-enabling the recalc ensures that their colors update every frame, allowing animated color support!
#######################################################################################################
* 040E083C 60000000             # 32-Bit Write @ $(ba + 0x000E083C):  0x60000000

##############################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Color Choice Resets on Controller Disconnect [QuickLava]
# Ensures that colors are reset when players unplug their controllers.
##############################################################################################
HOOK @ $806971C0                # Address = $(ba + 0x006971C0)
{
	cmpwi r4, -0x1
	bne loc_0x008
	lwz r12, 0x1b0(r3)
	lis r11, 0x804e
	rlwimi r11, r12, 2, 16, 29      # (Mask: 0x00003fff)
	lwz r11, 0x2f4(r11)
	lwz r12, 0x10(r11)
	stw r12, 0x8(r11)
loc_0x008:
	xori r0, r4, 0x8
}

##########################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Port-Specific Stocks Set CLR0 Frame [QuickLava]
# Has stock icons set their texture using the SetFrame function instead of SetFameTex, which ensures
# the CLR0 frame is set properly in addition to the texture itself; to make sure CPUs don't activate PSCC.
##########################################################################################################
* 040E2188 4BFD53B5             # 32-Bit Write @ $(ba + 0x000E2188):  0x4BFD53B5

###############################################################################
[CM: _PlayerSlotColorChangers v3.1.2] CSS Random Always Uses P1 CSP [QuickLava]
###############################################################################
HOOK @ $80697558                # Address = $(ba + 0x00697558)
{
	li r24, 0x0
	li r25, 0x1f5
	nop
}

############################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Random Franchise Icon uses Unique CLR0 Frame (setCharKind) [QuickLava]
############################################################################################################
HOOK @ $80697074                # Address = $(ba + 0x00697074)
{
	mr r25, r3
	lwz r12, 0x1b4(r30)
	cmplwi cr7, r12, 0x1
	bne cr7, %END%
	lis r11, 0x804e
	lbz r12, 0x304(r11)
	cmplwi cr7, r12, 0x8
	lwz r12, 0x1b0(r30)
	beq cr7, loc_0x00C
	lwz r12, 0x1c0(r30)
	rlwinm r0, r12, 31, 31, 31      # (Mask: 0x00000002)
	add r12, r12, r0
loc_0x00C:
	bne loc_0x00E
	addi r12, r12, 0x4
loc_0x00E:
	addi r12, r12, 0x1
	sth r12, 0x1c(r11)
	psq_l f1, 0x1c(r11), 1, 3
	lwz r3, 0xb8(r30)
	bla 0xb7a18
	mr r3, r25
	cmplwi r3, 0x29
}

#############################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Random Franchise Icon uses Unique CLR0 Frame (incTeamColor) [QuickLava]
# Note: Serves as a subroutine for the following codes as well, to avoid redundancy.
#############################################################################################################
HOOK @ $80699A2C                # Address = $(ba + 0x00699A2C)
{
	lwz r12, 0x1b8(r27)
	bl loc_0x003
	b %END%
loc_0x003:
	lfs f0, 0x18(r13)
	cmplwi r12, 0x29
	bne loc_0x007
	lfs f0, 0x5f4(r13)
loc_0x007:
	cmpwi r3, 0x0
	blr
}

#############################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Random Franchise Icon uses Unique CLR0 Frame (decTeamColor) [QuickLava]
#############################################################################################################
HOOK @ $80699D70                # Address = $(ba + 0x00699D70)
{
	lwz r12, 0x1b8(r27)
	bl -0x28
	nop
}

##############################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Random Franchise Icon uses Unique CLR0 Frame (setPlayerKind) [QuickLava]
##############################################################################################################
HOOK @ $80698690                # Address = $(ba + 0x00698690)
{
	lwz r12, 0x1b8(r28)
	bl -0x40
	nop
}

################################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Random Franchise Icon uses Unique CLR0 Frame (updateMeleeKind) [QuickLava]
################################################################################################################
HOOK @ $80698F18                # Address = $(ba + 0x00698F18)
{
	lwz r12, 0x1b8(r26)
	bl -0x58
	nop
}

###########################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Random Franchise Icon uses Unique CLR0 Frame (NOP Writes) [QuickLava]
###########################################################################################################
* 04699A40 60000000             # 32-Bit Write @ $(ba + 0x00699A40):  0x60000000
* 04699D84 60000000             # 32-Bit Write @ $(ba + 0x00699D84):  0x60000000
* 046986A4 60000000             # 32-Bit Write @ $(ba + 0x006986A4):  0x60000000
* 046986CC 60000000             # 32-Bit Write @ $(ba + 0x006986CC):  0x60000000
* 04698F2C 60000000             # 32-Bit Write @ $(ba + 0x00698F2C):  0x60000000
* 04698F54 60000000             # 32-Bit Write @ $(ba + 0x00698F54):  0x60000000

#####################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] SSS Random Stocks Use CLR0 Coloring [QuickLava]
#####################################################################################
* 046B2FB0 7C18C040             # 32-Bit Write @ $(ba + 0x006B2FB0):  0x7C18C040

HOOK @ $806B2FE8                # Address = $(ba + 0x006B2FE8)
{
	bl data_0x005
	word 0x4D656E53                 # MenS      | DATA_EMBED (0x10 bytes)
	word 0x656C6D61                 # elma
	word 0x70466163                 # pFac
	word 0x65525F00                 # eR_.
data_0x005:
	mflr r4
	addi r12, r23, 0x30
	rlwimi r12, r24, 2, 29, 29      # (Mask: 0x00000001)
	cmplwi r27, 0x1
	bne loc_0x00D
	addi r12, r30, 0x190
	lbzx r12, r12, r28
	addi r12, r12, 0x30
loc_0x00D:
	stb r12, 0xe(r4)
	mr r3, r29
	bla 0xb51f4
	lfs f31, 0x19c(r30)
}

#################################################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Bootleg CLR0 v4 Support Patch [QuickLava]
# Fakes CLR0 v4 support by rearranging the contents of the v4 header such that they match the orientation
# found in v3 files, just with the UserData pointer stuck to the end. This ensures that we maintain compatibility
# with the game's assumptions about where the struct's fields should be, while keeping access to UserData!
#################################################################################################################
HOOK @ $80197DC4                # Address = $(ba + 0x00197DC4)
{
	lwz r11, 0x0(r5)
	lwz r12, 0x8(r11)
	cmplwi r12, 0x4
	bne loc_0x00A
	lmw r28, 0x18(r11)
	lwz r12, 0x14(r11)
	stmw r28, 0x14(r11)
	stw r12, 0x24(r11)
	li r12, 0x3
	stw r12, 0x8(r11)
loc_0x00A:
	lwz r8, 0x0(r5)
}

###############################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Embed Color and Scheme Tables [QuickLava]
###############################################################################
* 46000008 00000000             # Put Next Code Loc in BA: ba = (Next Code Address) + 8
* 66200018 00000000             # Goto: Jump to Next Line, then forward 24 more Line(s) Regardless of Execution Status
* 00000000 147A3CFF             # .....z<.      | DATA_EMBED (0xC0 bytes)
* 00000000 00003CFF             # ......<.
* 7554FFFF 7FFF00FF             # uT......
* 00000000 7FFF0CFF             # ........
* 00000000 A6650CFF             # .....e..
* 17ADFFFF 851E00FF             # ........
* E1C6FFFF 8CCC00FF             # ........
* C60AD998 733202FF             # ....s2..
* 00000000 FFFF0CFF             # ........
* 00A3F332 7AE000FF             # ...2z...
* 9332FFFF 666600FF             # .2..ff..
* A665BFFF 7AE000FF             # .e..z...
* 9DDDE665 7FFF00FF             # ...e....
* 26669999 733202FF             # &f..s2..
* 23D6FFFF 7FFF00FF             # #.......
* 5B17DC28 51EB02FF             # [..(Q...
* 0000FFFF 7FFF0200             # ........
* 09090909 0B0C0C0A             # ........
* 0E0E0D0D 0F0F0F0F             # ........
* 06060606 07070707             # ........
* 05050505 02020202             # ........
* 03040304 00080108             # ........
* 08080808 10101010             # ........
* 00100110 00000000             # ........
* 44000000 004E0308             # Store Base Address: Val @ $(0x004E0308) = ba
* E0000000 80008000             # Full Terminator: ba = 0x80000000, po = 0x80000000

############################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Embed Color Callback Table [QuickLava]
# 8 Slots Long, First is Reserved for RGB Strobe!
############################################################################
* 46000008 00000000             # Put Next Code Loc in BA: ba = (Next Code Address) + 8
* 66200004 00000000             # Goto: Jump to Next Line, then forward 4 more Line(s) Regardless of Execution Status
* FFFFFFFF 00000000             # ........      | DATA_EMBED (0x20 bytes)
* 00000000 00000000             # ........
* 00000000 00000000             # ........
* 00000000 00000000             # ........
* 44000000 004E031C             # Store Base Address: Val @ $(0x004E031C) = ba
* E0000000 80008000             # Full Terminator: ba = 0x80000000, po = 0x80000000

#####################################################################
[CM: _PlayerSlotColorChangers v3.1.2] RGB Strobe Callback [QuickLava]
#####################################################################
* 46000008 00000000             # Put Next Code Loc in BA: ba = (Next Code Address) + 8
* 66200002 00000000             # Goto: Jump to Next Line, then forward 2 more Line(s) Regardless of Execution Status
* A1830000 398C0080             # ....9...      | DATA_EMBED (0x10 bytes)
* B1830000 4E800020             # ....N.. 
* 48000000 804E031C             # Load Pointer Offset: po = Val @ $(0x804E031C)
* 54010000 00000000             # Store Base Address: Val @ $(po + 0x00000000) = ba
* E0000000 80008000             # Full Terminator: ba = 0x80000000, po = 0x80000000

#########################################################################################
[CM: _PlayerSlotColorChangers v3.1.2] Borrow Stack Space [QuickLava]
# Consolidates two stack locations the game uses for float conversions into just one,
# allowing us to use the newly freed one as storage for some of the variables we'll need!
#########################################################################################
* 04193494 9061000C             # 32-Bit Write @ $(ba + 0x00193494):  0x9061000C
* 04193498 90010008             # 32-Bit Write @ $(ba + 0x00193498):  0x90010008
* 0419349C C8010008             # 32-Bit Write @ $(ba + 0x0019349C):  0xC8010008

###########################################################
[CM: _PlayerSlotColorChangers v3.1.2] Prep Code [QuickLava]
###########################################################
HOOK @ $80193410                # Address = $(ba + 0x00193410)
{
	lwz r28, 0x10(r6)
	cmplwi r28, 0x28
	bne loc_0x029
	lwz r28, 0x18(r6)
	lwzx r28, r6, r28
	subis r28, r28, 0x6c42
	subi r28, r28, 0x4330
	cmplwi r28, 0x8
	bge loc_0x029
	cmplwi r28, 0x4
	bge loc_0x00D
	sth r28, 0x16(r1)
	b loc_0x018
loc_0x00D:
	fmr f13, f1
	frsp f13, f13
	psq_st f13, 0x14(r1), 0, 3
	lhz r11, 0x16(r1)
	andi. r12, r28, 0x1
	beq loc_0x014
	subi r11, r11, 0x1
loc_0x014:
	andi. r12, r28, 0x2
	beq loc_0x017
	andi. r11, r11, 0xfffb
loc_0x017:
	sth r11, 0x16(r1)
loc_0x018:
	li r12, 0x0
	stw r12, 0x10(r1)
	lwz r11, 0x24(r6)
	cmplwi r11, 0x0
	beq loc_0x02B
	add r11, r6, r11
	lwzu r12, 0x4(r11)
	add r11, r11, r12
	lwz r12, 0x8(r11)
	cmplw r5, r12
	bge loc_0x02B
	lwz r12, 0x4(r11)
	add r11, r11, r12
	rlwinm r12, r5, 2, 0, 29        # (Mask: 0x3fffffff)
	lwzx r12, r11, r12
	stw r12, 0x10(r1)
	b loc_0x02B
loc_0x029:
	orc r28, r28, r28
	stw r28, 0x10(r1)
loc_0x02B:
	addi r5, r5, 0x1
	nop
}

###########################################################
[CM: _PlayerSlotColorChangers v3.1.2] Main Code [QuickLava]
###########################################################
HOOK @ $801934FC                # Address = $(ba + 0x001934FC)
{
	stw r3, 0x4(r28)
	lwz r12, 0x10(r1)
	subfic r3, r26, 0x20
	rlwnm. r3, r12, r3, 31, 31      # (Mask: 0x00000001)
	bne %END%
	lhz r0, 0x16(r1)
	cmplwi r0, 0x3
	bgt %END%
	lis r3, 0x804e
	word 0x7D35E2A6                 # mfspr 917, r9
	word 0x7D56E2A6                 # mfspr 918, r10
	lis r12, 0x704
	ori r12, r12, 0x804
	word 0x7D95E3A6                 # mtspr 917, r12
	lis r12, 0x1005
	word 0x7D96E3A6                 # mtspr 918, r12
	psq_l f11, 0x4(r28), 1, 5
	psq_l f12, 0x5(r28), 0, 5
	lfs f9, -0x6168(r2)
	fmuls f11, f11, f9
	lis r11, 0x804e
	lbz r12, 0x304(r11)
	rlwimi r11, r0, 2, 16, 29       # (Mask: 0x00003fff)
	lwz r11, 0x2f4(r11)
	lwzx r12, r11, r12
	rlwinm r12, r12, 2, 0, 29       # (Mask: 0x3fffffff)
	addi r12, r12, 0x88
	lbz r0, 0x11(r1)
	add r12, r12, r0
	lwz r11, 0x308(r3)
	lbzx r12, r11, r12
	rlwinm r0, r12, 3, 0, 28        # (Mask: 0x1fffffff)
	word 0x10EB074C                 # psq_lux f7, r11, r0, 1, 6
	lbz r12, 0x6(r11)
	lfs f10, -0x62fc(r2)
	fmuls f7, f7, f10
	andi. r0, r12, 0x1
	beq loc_0x027
	fsubs f11, f10, f11
loc_0x027:
	andi. r0, r12, 0x2
	beq loc_0x02A
	fsubs f11, f11, f11
loc_0x02A:
	fadds f11, f11, f7
	fsubs f7, f11, f10
	fsel f11, f7, f7, f11
	lfs f9, -0x6170(r2)
	fadds f10, f9, f9
	fsubs f7, f9, f9
	ps_merge01 f8, f10, f10
	andi. r0, r12, 0x8
	beq loc_0x034
	ps_merge01 f7, f9, f7
loc_0x034:
	andi. r0, r12, 0x20
	beq loc_0x037
	ps_merge01 f7, f7, f9
loc_0x037:
	andi. r0, r12, 0x4
	beq loc_0x03A
	ps_merge01 f8, f9, f8
loc_0x03A:
	andi. r0, r12, 0x10
	beq loc_0x03D
	ps_merge01 f8, f8, f9
loc_0x03D:
	ps_sub f13, f12, f7
	ps_sel f12, f13, f12, f7
	ps_sub f13, f8, f12
	ps_sel f12, f13, f12, f8
	fsubs f13, f9, f9
	psq_l f7, 0x2(r11), 0, 6
	ps_sub f8, f12, f9
	ps_sel f12, f8, f8, f12
	ps_sel f13, f8, f7, f13
	ps_sub f10, f9, f7
	ps_sel f8, f8, f10, f7
	ps_madd f12, f12, f8, f13
	ps_merge11 f13, f12, f12
	fadds f10, f9, f9
	fmsubs f7, f13, f10, f9
	fabs f7, f7
	fnmsubs f7, f12, f7, f12
	psq_st f11, 0x1c(r3), 1, 3
	lhz r12, 0x1c(r3)
	b loc_0x052
loc_0x051:
	fsubs f11, f11, f10
loc_0x052:
	fcmpu cr1, f11, f10
	bge cr1, loc_0x051
	fsubs f11, f11, f9
	fabs f8, f11
	fnmsubs f8, f7, f8, f7
	fdivs f10, f7, f10
	fsubs f10, f13, f10
	cmplwi r12, 0x2
	bge loc_0x05F
	fsel f12, f11, f7, f8
	fsel f11, f11, f8, f7
	fsubs f13, f13, f13
	b loc_0x068
loc_0x05F:
	cmplwi r12, 0x4
	bge loc_0x065
	fsel f12, f11, f8, f7
	fsel f13, f11, f7, f8
	fsubs f11, f13, f13
	b loc_0x068
loc_0x065:
	fsel f13, f11, f8, f7
	fsel f11, f11, f7, f8
	fsubs f12, f13, f13
loc_0x068:
	fadds f11, f11, f10
	ps_merge00 f12, f12, f13
	ps_add f12, f12, f10
	psq_st f11, 0x4(r28), 1, 5
	psq_st f12, 0x5(r28), 0, 5
	word 0x7D35E3A6                 # mtspr 917, r9
	word 0x7D56E3A6                 # mtspr 918, r10
}

################################################################################
[CM: _DashAttackItemGrab] vBrawl Item Grab Restoration Toggle v1.0.0 [QuickLava]
################################################################################
HOOK @ $808E0094                # Address = $(ba + 0x008E0094)
{
	bl data_0x00D
	word 0x80FB240C                 # ..$.      | DATA_EMBED (0x30 bytes)
	word 0x00070100                 # ....
	word 0x80FB2394                 # ..#.
	word 0x80FC2798                 # ..'.
	word 0x000A0400                 # ....
	word 0x80FB2DE4                 # ..-.
	word 0x80FC27A0                 # ..'.
	word 0x00070100                 # ....
	word 0x80FADAC4                 # ....
	word 0x80FC27A8                 # ..'.
	word 0x000F0000                 # ....
	word 0x00000000                 # ....
data_0x00D:
	lis r30, 0x804e
	lwz r30, 0x2420(r30)
	cmplwi r30, 0x0
	lis r11, 0x2
	li r12, 0x0
	li r30, 0xc
	bne loc_0x015
	li r30, 0x4
loc_0x015:
	mtxer r30
	mflr r30
	li r31, 0x0
loc_0x018:
	lswx r10, r30, r31
	stswi r11, r10, 8
	addi r31, r31, 0xc
	cmplwi r31, 0x30
	blt loc_0x018
	mr r30, r3
	nop
}

##################################################
[CM: _JumpsquatOverride] Jumpsquat Length Modifier
##################################################
HOOK @ $808734F8                # Address = $(ba + 0x008734F8)
{
	lis r11, 0x804e
	lwz r12, 0x2468(r11)
	cmplwi r12, 0x0
	beq loc_0x022
	mtctr r12
	lwz r11, 0x2518(r11)
	mr r0, r11
	bdz loc_0x018
	add r0, r11, r3
	bdz loc_0x018
	subf r0, r11, r3
	bdz loc_0x018
	mullw r0, r11, r3
	bdz loc_0x018
	divwu r0, r3, r11
	bdz loc_0x018
	subf. r0, r3, r11
	bge loc_0x013
	neg r0, r0
loc_0x013:
	bdz loc_0x018
	lwz r3, -0x4364(r13)
	divwu r0, r3, r11
	mullw r0, r0, r11
	subf r0, r0, r3
loc_0x018:
	lis r11, 0x804e
	lwz r12, 0x2558(r11)
	cmpw r0, r12
	bge loc_0x01D
	mr r0, r12
loc_0x01D:
	lwz r12, 0x25a0(r11)
	cmpw r0, r12
	ble loc_0x021
	mr r0, r12
loc_0x021:
	mr r3, r0
loc_0x022:
	xoris r3, r3, 0x8000
}

####################################
[CM_Addons] Code Menu Addon Includes
####################################
.include "Source/CM_Addons/WIPMHTFL/Source.asm"
.include "Source/CM_Addons/MLEEFREZ/Source.asm"
.include "Source/CM_Addons/RAYDEBUG/Source.asm"
.include "Source/CM_Addons/PRYTAUNT/Source.asm"
.include "Source/CM_Addons/UNVWLJMP/Source.asm"
