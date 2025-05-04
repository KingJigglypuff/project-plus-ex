#############################################################################################################
Boot Directly to CSS v5.4 (Hold Shield for Training, Z for Custom Mode) [PyotrLuzhin, SammiHusky, QuickLava]
# v5.2 - Added Hold Z to Boot to Target Smash!
#      - The port which triggers the code now properly controls the CSS upon arrival.
# v5.3 - Wiimote-based controllers properly get control of CSS when special inputs are activated.
#      - First comments pass.
# v5.4 - Made Z-Button input load the sequence pointed to by customLoadTarget for easier customizability.
#############################################################################################################
.alias loadVersus   = 0x1B54
.alias loadTitle    = 0x1C94
.alias loadTraining = 0x1870
.alias loadClassic  = 0x1804
.alias loadAllstar  = 0x1820
.alias loadBoss     = 0x1830
.alias loadEvents   = 0x1840
.alias loadTargets  = 0x1848
.alias loadHomerun  = 0x1858
.alias loadKumite   = 0x1864
.alias loadBuilder  = 0x187C
.alias loadReplays  = 0x1884
.alias customLoadTarget = loadReplays    # Set this equal to one of the above presets to control what mode you transition to when holding Z.
                                         # Note: The values here are relative to 0x80700000 to get the address of the relevant "sq______" string.
                                         #   To transition to a mode not listed, set customLoadTarget to the bottom half of its string's address!

HOOK @ $806DD5F8    # [0x168 bytes into symbol "setNext/[sqBoot]/sq_boot.o" @ 0x806DD490]
{
    li r11, 0                            # Initialize port ID iterator for coming loop.
    LOOP_START:
        lis r12, 0x805B                  # \ 
        ori r12, r12, 0xa684             # / Set up base pointer to pad data.
                                         
    GAMECUBE:                          
        li r10, 0x00                     # Set controller type offset to 0x00, for GCC.       
        rlwinm r4, r11, 6, 16, 25        # Multiply port ID by 0x40 to index to the desired input data.
        lwzux r0, r12, r4                # Load relevant port's GCC button mask, and bake port offset into r12.
        andi. r5, r0, 0x0060; bne boot_training;    # If R or L are pressed boot to Training.
        andi. r5, r0, 0x1000; bne boot_title;       # If Start is pressed boot to Title.
        andi. r5, r0, 0x0010; bne boot_custom;      # If Z is pressed boot to custom mode.
                                         
    WIIMOTE_CHECK_SUBTYPE:                          
        li r10, 0x04                     # Set controller type offset to 0x04, for Wiimote based controllers.   
        lwz r0, 0x100(r12)               # Look forward 0x100 bytes to this slot's Wiimote button mask...
        lwz r4, 0x13c(r12)               # ... as well as its controller type.
        cmpwi r4, 2                      # If controller type is 2 or 3...
        bge WIICHUCK                     # ... skip down to Wiimote section!
        
    CLASSIC:
        andi. r5, r0, 0x0060; bne boot_training;    # If R or L are pressed boot to Training.
        andi. r5, r0, 0x1000; bne boot_title;       # If + is pressed boot to Title.
        andi. r5, r0, 0x0010; bne boot_custom;      # If ZR or ZL are pressed boot to custom mode.
        b LOOP_BACK                                 # Otherwise, skip past the WiiChuck bit and prepare to loop again.
                                                    
    WIICHUCK:                                       
        andi. r5, r0, 0x0210;  bne boot_training;   # If Z or B are pressed boot to Training.
        andi. r5, r0, 0x1000;  bne boot_title;      # Otherwise, if + pressed boot to Title.
        andis. r5, r0, 0x000C; bne boot_custom;     # If C or - are pressed boot to custom mode.
        
    LOOP_BACK:                           
        addi r11, r11, 1                 # Add 1 to the current port number...
        cmpwi r11, 4                     # ... compare that against 4...
        blt LOOP_START                   # ... and if it's less than that there're still controllers to check, continue loop.
                                         
    boot_vs:                             # If we've checked every port and found no special mode input...
        addi r4, r21, loadVersus         # ... then redirect r4 to "sqVsMelee" @ $80701B54 instead of "sqPrizeCheck".
        li r5, 0                         # Set sequence parameter in r5 to 0...
        b %END%                          # ... and exit.
                                         
    boot_title:
        addi r4, r21, loadTitle          # Restore Original Instruction, point r4 to "sqPrizeCheck" @ $80701C94.
        li r5, 0x14                      # Also set r5 to transition correctly into sqTitle afterwards.
        b %END%
        
    boot_training:                       #
        addi r4, r21, loadTraining       # Redirect r4 to "sqTraining" @ $80701870 instead of "sqPrizeCheck".
        li r5, 0                         # Set sequence parameter in r5 to 0...
        b set_active_controller          # ... then skip down to setting active controller.
        
    boot_custom:
        addi r4, r21, customLoadTarget   # Redirect r4 to the specified target instead of "sqPrizeCheck".
        li r5, 0                         # Set sequence parameter! Zero is usually fine, but other values are sometimes necessary.
        b set_active_controller          # Skip down to setting active controller.
        
    set_active_controller:
        lwz r12, -0x4340(r13)            # Get pointer to g_GameGlobal...
        lwz r12, 0x1C(r12)               # ... then gmSetRule.
        add r10, r11, r10                # Add controller type offset to the current port ID so Wiimote Controller IDs line up correctly...
        stw r10, 0x24(r12)               # ... then write that ID over the spot read by gmGetMenuDecisionPad so it'll control CSS!
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