=======================================================================================
Guide for Adding Sonic Costumes
=======================================================================================

Sonic uses individual Etc files for each costume. These files include a GFX bank, the "ef_sonicX[..]" ARC, that stores his runtrail texture/model.

When adding Sonic costume slots, make sure to copy an existing SonicEtc file as well, and rename it to match the costume number.
Inside the SonicEtc file, rename the ef_sonicX[..] ARC to match the new costume number, and make the proper adjustments to the textures inside.

The two "zanzo" texture colors should match the top of the shoe color.
eff_sonic_runtrace stripes should always match the corresponding costume, and follow this color scheme (from top to bottom):
1) Leg
2) Top of shoe
3) Middle of shoe
4) Bottom of shoe