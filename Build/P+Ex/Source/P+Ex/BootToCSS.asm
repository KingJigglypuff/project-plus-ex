###############################################################################
Boot Directly to CSS v5.1  (Hold Shield for training) [PyotrLuzhin, SammiHusky]
###############################################################################
HOOK @ $806DD5F8
{
    li r11, 0
    LOOP_START:
        lis r12, 0x805B
        ori r12, r12, 0xa684
        
    GAMECUBE:
        mulli r4, r11, 0x40
        lwzx r0, r12, r4
        rlwinm. r0, r0, 0, 25, 26
        bne boot_training
        
    WIIMOTE_CHECK_SUBTYPE:
        addi r12, r12, 0x100
        lwz r4, 0x3c(r12)
        cmpwi r4, 3
        beq WIICHUCK
        mulli r4, r11, 0x40
        lwzx r0, r12, r4
        rlwinm. r0, r0, 0, 25, 26
        bne boot_training
        b LOOP_BACK
    WIICHUCK:
        mulli r4, r11, 0x40
        lwzx r0, r12, r4
        rlwinm. r0, r0, 0, 27, 27
        bne boot_training
    LOOP_BACK:
        addi r11, r11, 1
        cmpwi r11, 4
        blt LOOP_START
    
    boot_vs:
        addi r4, r21, 0x1B54
        li r5, 0
        b %END%
        
    boot_training:
        addi r4, r20, -0x3f0
        li r5, 0
}
HOOK @ $8002D3A0
{
  mr r4, r27
  lis r5, 0x8042;    ori r5, r5, 0xA40
  cmpw r4, r5;        bne- %END%
  li r5, 0x3
  stb r5, 0x2A5(r28);    stb r5, 0x2B1(r28)
  li r30, 0x0
}
op b 0x10 @ $80078E14
op nop    @ $806DD5FC