#######################################################################################
[Legacy TE] Unbounded Team Color Engine EX Variant v1.3 [DukeItOut, DesiacX, QuickLava]
#
# v1.1 - Adjusted to accomodate Mdl+Tex splitting
# v1.2 - Reimplemented findCharTeamColorNo override to not affect teamSet.
#      - Split iterating and wrapping teamSet into incTeamColor and decTeamColor hooks.
# v1.3 - Additional code optimization and cleanup.
#######################################################################################
.alias maxTeamIndex = 0x2
.alias CharDataTable_Hi = 0x817D
.alias CharDataTable_Lo = 0x52A0
.alias CharDataTable_CostAddrOff = CharDataTable_Lo + 0x8

# Skip Wario-specific findCharTeamColorNo call (setToGlobal).
op b 0x24 @ $80684978             # lands 0x298 bytes into symbol "setToGlobal/[muSelCharTask]/mu_selchar.o" @ 0x806846E0
# Properly load teamSet before findCharTeamColorNo call.
op lbz r5, 0x1C4(r24) @ $806849A4 # lands 0x2C4 bytes into symbol "setToGlobal/[muSelCharTask]/mu_selchar.o" @ 0x806846E0
# Skip Wario-specific findCharTeamColorNo call (setCharPic).
op b 0x1C @ $806974F8             # lands 0xCC bytes into symbol "setCharPic/[muSelCharPlayerArea]/mu_selchar_player_area_o" @ 0x8069742C
# Disable Wario-specific Team color coding that conflicts with system.
op b 0x2C0 @ $80698B74            # lands 0x158 bytes into symbol "updateMeleeKind/[muSelCharPlayerArea]/mu_selchar_player_a" @ 0x80698A1C

# Handle TeamSet Wrap Around in incTeamColor Case
op b 0xC @ $806998D0 # lands 0x54 bytes into symbol "incTeamColor/[muSelCharPlayerArea]/mu_selchar_player_area" @ 0x8069987C
HOOK @ $806998DC     # lands 0x60 bytes into symbol "incTeamColor/[muSelCharPlayerArea]/mu_selchar_player_area" @ 0x8069987C
{
    addi r28, r28, 0x1                         # Increment teamSet in r28
    lis r11, CharDataTable_Hi                  # Initialize the upper half of r11 with the top half of the charData table address...
    rlwimi r11, r0, 4, 20, 27                  # ... shift and mask charKind to multiply it by 0x10 and add it to r11...
    lwz r11, CharDataTable_CostAddrOff(r11)    # ... then use the lower half of our address to load their costume array address directly.
    lbz r12, -0x7130(r2)                       # Get the Color Code for Team 0 (guranteed to want 0, cuz we're in wrap case)
    li r10, 0x00                               # Init Match Counter to 0x00
    subi r11, r11, 0x2                         # Prepare r11 for lbzu'ing in the below loop.
loopStart:
    lbzu r0, 0x02(r11)                         # Fetch next costume entry's color code.
    cmplw r0, r12                              # Compare it against the desired color code.
    bne+ notMatch                              # ... and if it they don't match, skip to noMatch.
    addi r10, r10, 0x1                         # Otherwise, increment our match counter...
    cmplw r10, r28                             # ... and check if match count is higher than target teamSet.
    bgt- success                               # If it is, we don't need to roll back to 0, and can exit.
notMatch:
    cmplwi r0, 0xC                             # If we need to keep looking, compare the loaded color code to the terminator code (0xC)...
    bne+ loopStart                             # ... and if it was not the terminator, restart the loop.
noMatchFound:
    li r28, 0x00                               # If it instead was the terminator, and we didn't find enough matches, then reset r28 back to 0.
success:
}

# Handle TeamSet Wrap Around in decTeamColor Case
op b 0xC @ $80699C14 # lands 0x50 bytes into symbol "decTeamColor/[muSelCharPlayerArea]/mu_selchar_player_area" @ 0x80699BC4
HOOK @ $80699C20     # lands 0x5C bytes into symbol "decTeamColor/[muSelCharPlayerArea]/mu_selchar_player_area" @ 0x80699BC4
{
    subi r28, r28, 0x1                         # Decrement teamSet in r28
    cmpwi r28, 0x00                            # Compare it against 0x00...
    bge+ %END%                                 # ... and if it's still above 0x00, then exit, no change necessary.
    lis r11, CharDataTable_Hi                  # Initialize the upper half of r11 with the top half of the charData table address...
    rlwimi r11, r0, 4, 20, 27                  # ... shift and mask charKind to multiply it by 0x10 and add it to r11...
    lwz r11, CharDataTable_CostAddrOff(r11)    # ... then use the lower half of our address to load their costume array address directly.
    addi r12, r2, maxTeamIndex                 # \
    lbz r12, -0x7130(r12)                      # / Get the Color Code for Last Team (guranteed to want last, cuz we're in wrap case)
    subi r11, r11, 0x2                         # Prepare r11 for lbzu'ing in the below loop.
loopStart:
    lbzu r0, 0x02(r11)                         # Fetch next costume entry's color code.
    cmplw r0, r12                              # Compare it against the desired color code.
    bne+ notMatch                              # ... and if it they don't match, skip to noMatch.
    addi r28, r28, 0x1                         # Otherwise, increment our match counter...
notMatch:
    cmplwi r0, 0xC                             # If we need to keep looking, compare the loaded color code to the terminator code (0xC)...
    bne+ loopStart                             # ... and if it was not the terminator, restart the loop.
}

# Reimplement muMenu::findCharTeamColorNo to read from the BrawlEx CSSSlot config, and use r5 as TeamSet!
# r3 == CharKind, r4 == TeamColor, r5 == TeamSet
HOOK @ $800AF520    # lands 0x00 bytes into symbol "findCharTeamColorNo/[muMenu]/menu.o" @ 0x800AF520
{
    lis r11, CharDataTable_Hi                  # Initialize the upper half of r11 with the top half of the charData table address...
    rlwimi r11, r3, 4, 20, 27                  # ... shift and mask charKind to multiply it by 0x10 and add it to r11...
    lwz r11, CharDataTable_CostAddrOff(r11)    # ... then use the lower half of our address to load their costume array address directly.
    add r12, r2, r4                            # \
    lbz r12, -0x7130(r12)                      # / Get the Color Code for the requested Team.
    li r3, 0x00                                # Initialize index counter/result to 0x00.
    li r10, 0x00                               # Init Match Counter to 0x00
    subi r11, r11, 0x2                         # Prepare r11 for lbzu'ing in the below loop.
loopStart:
    lbzu r0, 0x02(r11)                         # Fetch next costume entry's color code.
    cmplw r0, r12                              # Compare it against the desired color code.
    bne+ notMatch                              # ... and if it they don't match, skip to noMatch.
    addi r10, r10, 0x1                         # Otherwise, if we did match, increment our match counter...
    cmplw r10, r5                              # ... and check if match count is higher than target teamSet.
    bgt- success                               # If it is, we don't need to roll back to 0, and can exit.
notMatch:
    addi r3, r3, 0x01                          # If we need to keep looking, increment r3...
    cmplwi r0, 0xC                             # ... compare the loaded color code to the terminator code (0xC)...
    bne+ loopStart                             # ... and if it was not the terminator, restart the loop.
failure:
    li r3, 0x00                                # Lastly, if we found no match, reset r3 to 0x00.
success:
    blr                                        # Return!
}

# Handle Fetching Team Costume Index in 
CODE @ $8069661C    # lands 0xAC bytes into symbol "sendSystemCharKind/[muSelCharPlayerArea]/mu_selchar_playe" @ 0x80696570
{
    mr r3, r28                                 # Prepare to call findCharTeamColorNo. Copy charKind into r3...
    lwz r4, 0x1C0(r30)                         # ... teamNo into r4...
    lbz r5, 0x1C4(r30)                         # ... and teamSet int r5.
    bl -0x5E7108                               # Call findCharTeamColorNo!
}

# Skip Wario-specific findCharTeamColorNo call (initPlayerArea).
op mr r5, r0    @ $80685C08    # lands 0x584 bytes into symbol "initPlayerArea/[muSelCharTask]/mu_selchar.o" @ 0x80685684
op NOP          @ $80685C18    # lands 0x594 bytes into symbol "initPlayerArea/[muSelCharTask]/mu_selchar.o" @ 0x80685684
# Retainment of team color upon reentering CSS. r0 == Costume Index to Restore, r4 == Team ID, r5 == Incoming charKind
HOOK @ $80685C14    # lands 0x590 bytes into symbol "initPlayerArea/[muSelCharTask]/mu_selchar.o" @ 0x80685684
{
    lis r11, CharDataTable_Hi                  # Initialize the upper half of r11 with the top half of the charData table address...
    rlwimi r11, r5, 4, 20, 27                  # ... shift and mask charKind to multiply it by 0x10 and add it to r11...
    lwz r11, CharDataTable_CostAddrOff(r11)    # ... then use the lower half of our address to load their costume array address directly.
    cmpwi r11, -1                              # Compare the loaded address with -1...
    beq- %END%                                 # ... and if it was, skip down to the end of the code.
    add r12, r2, r4                            # \
    lbz r12, -0x7130(r12)                      # / Get the Color Code for Last Team (guranteed to want last, cuz we're in wrap case
    subi r11, r11, 0x2                         # Prepare r11 for lbzu'ing in the below loop.
    addic. r0, r0, 0x1                         # Add 1 to r0 to prepare it for use as loop counter...
    mtctr r0                                   # ... and then move it to count register.
    li r0, -1                                  # Initialize r0 to 0x00, as what will be out match counter.
loopStart:
    lbzu r10, 0x02(r11)                        # Fetch next costume entry's color code.
    cmplw r10, r12                             # Compare it against the desired color code.
    bne+ notMatch                              # ... and if it they don't match, skip to noMatch.
    addic. r0, r0, 0x1                         # Otherwise, increment our match counter...
notMatch:
    cmplwi r10, 0xC                            # If we need to keep looking, compare the loaded color code to the terminator code (0xC)...
    bc+ 0, 2 loopStart                         # ... and if it was not the terminator, restart the loop.
}
