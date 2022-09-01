###############################################################
[Project+] Tiebreaker v2.0 - Enforces Sudden Death Clause [Eon]
###############################################################
HOOK @ $8095617c 
{
	#original command
	stw r0, 0x27C(r3)

	#if staling enabled = if singleplayer mode, dont enable
	lis r7, 0x80b8
	lwz r7, 0x7C28(r7)
	lwz r7, 0x6E(r7)
	andi. r7, r7, 0x8
	beq %end%
	#if items enabled = casuals, dont enable
	lis r7, 0x805A
	lwz r7, 0xE0(r7)
	lwz r7, 0x08(r7)
	lbz r7, 0x16(r7)
	cmpwi r7, 0
	bne %end%

    sth r0, 0x27C(r3) #stores stockcount in top half of victory condition word
    lhz r0, 0x2C(r3)  #loads percentage 
    li r7, 1000
    sub r0, r7, r0
    sth r0, 0x27E(r3) #stores 1000 - percentage into bottom half so that a player at 0 has a higher value than a player at 100.
}

HOOK @ $809559d4
{
    mr r3, r19         #calls function to recieve players current damage
    lwz r12, 0xC(r19)
    lwz r12, 0x14(r12)
    mtctr r12
    bctrl
    fctiwz f1, f1         #converts float result to int
    stfd f1, 0x8(r1)
    lwz r0, 0xC(r1)

    sth r0, 0x8(r20)     #stores percentage into unused space near results stockcount 
originalcommand:
    subi    r3, r27, 1
    cmpw r0, r3
}

#######################################################################################################
[Project+] RoA Overtime v2.1 - Timer resets to 10 seconds if there is more than 1 assigned winner [Eon]
#######################################################################################################

HOOK @ $80953d54
{
	#if staling enabled = if singleplayer mode, dont enable
	lis r5, 0x80b8
	lwz r5, 0x7C28(r5)
	lwz r5, 0x6E(r5)
	andi. r5, r5, 0x8
	beq time
	#if items enabled = casuals, dont enable
	lis r5, 0x805A
	lwz r5, 0xE0(r5)
	lwz r5, 0x08(r5)
	lbz r5, 0x16(r5)
	cmpwi r5, 0
	bne time

    lwz r5, 0xCC(r31)
    lbz r0, 0x1(r5) #gametype must be stock (added in v2.1)
	cmpwi r0, 1
    bne time

    lbz r5, 0xF(r5) #loads current game winner count
    cmpwi r5, 1
    beq time              #if only one winner, end as normal
    li r5, 600   #10*60frames = 10 seconds
    stw r5, 0xE0(r31)     #store into in game timer
    li r5, 0x12E         
    stw r5, 0xF0(r31)     #resets announcer voice so he can say countdown again

    li r6, 0	#load "not the end" just in case
    b end
time:
    li r6, 1
end:

}
