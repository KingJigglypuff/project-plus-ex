Holding start on game end screen clears everyone (after 1 second) [Eon]
HOOK @ $800ED340
{
    lwz r0, 0x218(r1)
    rlwinm. r0, r0, 0, 19, 19 # check if start held
    add r3, r27, r28
    bne inc
reset: #reset counter to 0
    li r4, 0
    stb r4, 0x68(r3)
    b end
inc: #count frames
    lbz r4, 0x68(r3)
    addi r4, r4, 1
    stb r4, 0x68(r3)
    cmpwi r4, 60
    blt end
playSelectSound:
    lwz r3, -0x4250(r13)
    li r4, 1
    li r5, -1
    li r6, 0
    li r7, 0
    li r8, -1
    lis r12, 0x8007
    ori r12, r12, 0x42B0
    mtctr r12 
    bctrl 
closeAllPlayers:
    li r28, 0
    lis r29, 0x800E
    ori r29, r29, 0x8040
loop:
    mr r3, r27
    mr r4, r28
    li r5, 1
    mtctr r29
    bctrl 
    addi r28, r28, 1
    cmpwi r28, 0x4
    blt loop
exit:
    lis r12, 0x800E
    ori r12, r12, 0xD43C
    mtctr r12 
    bctr
end:
    lwz r0, 0x21C(r1) #original command = check if B button pressed
}