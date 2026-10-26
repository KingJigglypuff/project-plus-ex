========================================
Guide for Adding ROB Costumes
========================================
As per the LegacyTE_PSA_edits file, Kart ROB has specific effects in slots 20-29.

ROB uses individual Etc files for each costume. 
When adding ROB costume slots, make sure to copy an existing RobotEtc file as well, and rename it to match the costume number.

The Etc files include a GFX bank located in the "ef_robotX[..]" ARC that stores his armtrail texture/model.
Inside the RobotEtc file, rename the ef_robotX ARC so it matches the new costume number, and make the proper adjustments to the texture inside.
The spintrace texture should match ROB's arm color.