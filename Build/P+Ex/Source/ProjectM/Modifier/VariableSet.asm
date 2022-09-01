#######################################################################
Variable Set on Air/Ground State Change Engine v1.2b [Magus, DukeItOut]
#######################################################################
HOOK @ $80762694
{
  lwz r10, 0x70(r6)		# \
  lwz r10, 0x20(r10)	# |
  lwz r10, 0x0C(r10)	# | Access character ID
  lwz r10, 0x2D0(r10)	# |
  lis r9, 0x9380		#\|
  cmpw r10, r9			#||
  bge+ loc_0xD8			#||
  lwz r8, 0x00(r10)		#||
  cmpwi r8, 0x502B		#||
  bne- loc_0xD8			#/|
  lwz r10, 0x08(r10)	#\|
  blt+ loc_0xD8			#||
  lis r8, 0x8141		#||
  cmpw r10, r8			#||
  bge+ loc_0xD8			#/|
  lwz r10, 0x110(r10)	# /
  mulli r8, r4, 0x2
  cmpwi r8, 0x0
  bne- loc_0x1C
  li r8, 0x1

loc_0x1C:
  mulli r9, r5, 0x2
  cmpwi r9, 0x0
  bne- loc_0x2C
  li r9, 0x1

loc_0x2C:
  lis r12, 0x8076			# \ Address of table . . . minus eight.
  lwz r12, 0x26AC(r12)		# |
  subi r12, r12, 8			# /
loc_0x34:
  lwzu r11, 8(r12);  cmpwi r11, 0xFFFF;  beq- loc_0xD8
  srawi r0, r11, 24;  cmpw r0, r10;  beq- loc_0x54
					cmpwi r0, 0xFFFF;  bne+ loc_0x34

loc_0x54:
  rlwinm r0, r11, 12, 28, 31;  and. r0, r0, r8;  beq+ loc_0x34
  rlwinm r0, r11, 16, 28, 31;  and. r0, r0, r9;  beq+ loc_0x34
  lwz r7, 0x70(r6)
  rlwinm r0, r11, 22, 26, 29
  add r7, r7, r0
  lwz r7, 0x1C(r7)
  rlwinm r0, r11, 27, 25, 28
  add r7, r7, r0
  lwz r7, 0xC(r7)
  cmpwi r0, 0x10
  beq+ loc_0xA0
  lwz r0, 4(r12)
  rlwinm r11, r11, 2, 22, 29
  stwx r0, r7, r11
  b loc_0x34

loc_0xA0:
  rlwinm r0, r11, 29, 27, 29
  add r7, r7, r0
  rlwinm r0, r11, 0, 27, 31
  li r11, 0x1
  slw r11, r11, r0
  lwz r0, 4(r12)
  cmpwi r0, 0x0
  lwz r0, 0(r7)
  beq- loc_0xCC
  or r0, r0, r11
  b loc_0xD0

loc_0xCC:
  andc r0, r0, r11

loc_0xD0:
  stw r0, 0(r7)
  b loc_0x34

loc_0xD8:
  subi r3, r3, 0x28		# original operation
}
HOOK @ $807626A4
{
	stw r0, 0x24(r1)
	stw r31, 0x1C(r1)
	stw r30, 0x18(r1)
}
op b 0x8 @ $807626A8

	.BA<-VariableTable
	.BA->$807626AC
	.GOTO->VariableTableSkip
# Variable Set on Air/Ground State Change Data
VariableTable:
* 00171271 00000000
* 00171274 00000000
* 04171270 00000000
* 04171271 00000000
* 08171273 00000000
* 0D17127E 00000000
* 11171273 00000001
* 12171272 00000000
* 14171273 00000000
* 14171278 00000001
* 14171062 00000000
* 16371273 00000000
* 17171271 00000000
* 17171272 00000001
* 18171271 00000000
* 1917127A 00000001
* 1E171273 00000000
* 1F17104B 00000000
* 21171242 00000000
* 2217105B 00000001
* 23171272 00000000
* 2317104B 00000003
* 2417123D 00000000
* 24171271 00000000
* 24171272 00000000
* 26171272 00000000
* 26171273 00000000
* 26371275 00000000
* 26171276 00000000
* 26171062 00000000
* 27171273 00000001
* 2D17105B 00000000
* 2D17105C 00000000
* 2D17105D 00000000
* 2E171134 00000000
* 2E371271 00000000
* 2F341271 00000000
* 2F341272 00000000
* 2F34123D 00000000
* FF371051 00000000
* FFFFFFFF FFFFFFFF
VariableTableSkip:
	.RESET
