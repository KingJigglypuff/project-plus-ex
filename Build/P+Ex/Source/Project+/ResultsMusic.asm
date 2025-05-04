
## TODO: Make victory themes just use 0xFF00 + Fighter id instead of table for new version of BrawlEx
# Handled in ifVsResultTask::processAnim

##################################################################################
Classic and All-Star Results Music Id Is Based On Fighter Id [DukeItOut, Kapedani]
##################################################################################
.alias ftKindConversion__convertKind = 0x808545ec

.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro call(<addr>)
{
  %lwi(r12, <addr>)
  mtctr r12
  bctrl    
}

HOOK @ $806e0988		# Classic Mode
{
	stwu r1,-0x20(r1)
    mflr r0
    stw r0,0x24(r1)
	stw r6, 0x1C(r1)
	lbz	r3, 0x33(r15)	# get characterKind
    addi r4, r1, 0x8
	%call(ftKindConversion__convertKind)
    lwz r3, 0x8(r1)		# \ 
    ori r3, r3, 0xff00	# | bgmId = 0xFF00FF00 | ftKind
	lwz r6, 0x1C(r1)
    lwz r0,0x24(r1)
    mtlr r0
    addi r1,r1,0x20
	oris r0, r3, 0xFF00	# /
	addi r4, r20, 752
}
HOOK @ $806E3650		# All-Star Mode
{
	stwu r1,-0x20(r1)
    mflr r0
    stw r0,0x24(r1)
	stw r6, 0x1C(r1)
	lbz	r3, 0x98(r6)	# get characterKind
    addi r4, r1, 0x8
	%call(ftKindConversion__convertKind)
    lwz r3, 0x8(r1)		# \ 
    ori r3, r3, 0xff00	# | bgmId = 0xFF00FF00 | ftKind
	lwz r6, 0x1C(r1)
    lwz r0,0x24(r1)
    mtlr r0
    addi r1,r1,0x20
    oris r0, r3, 0xFF00	# /
	addi r4, r23, 136
}
