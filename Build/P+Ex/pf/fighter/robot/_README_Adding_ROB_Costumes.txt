=======================================================================================
Guide for Adding ROB Costumes
=======================================================================================

As per the LegacyTE_PSA_edits file, Kart ROB has specific effects in slots 20-29.

ROB uses individual Etc files for each costume. These files include a GFX bank, the "ef_robotX[..]" ARC, that stores his armtrail texture/model. When adding ROB costume slots, make sure to copy an existing RobotEtc file as well, and rename it to match the costume number.

Inside the RobotEtc file, rename the ef_robotX[..] ARC to match the new costume number, and make the proper adjustments to the texture inside. The spintrace texture should match ROB's arm color.