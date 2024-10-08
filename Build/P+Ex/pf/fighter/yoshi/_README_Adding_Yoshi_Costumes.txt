=======================================================================================
Guide for Adding Yoshi Costumes
=======================================================================================

Yoshi uses a new GFX animation-based system for the egg break GFX, When adding slots, open the FitYoshi.pac file, open the ef_yoshi ARC archive, then inside the Model Data [0] BRRES archive, you'll see the AnmClr and AnmTexPat nodes. Those contain color and texture pattern animations respectively, with the frame being dependent on Yoshi's current costume.

Under the CLR animation, there's two material nodes, egg_spot, and egg.
egg_spot is used for the spots, which supports up to two colors. Default egg spots only use Color 1, while the Dorrie alts use both Colors 0 and 1. If you look at the Yoshi_Eff and Yoshi_Egg_20 textures (inside the Texture Data [0] BRRES archive), you'll see Color 0 affects the red portion of the texture, while Color 1 affects the blue portion of the texture.

egg is used for the shell itself, which supports a single color (controlled by Color 0).

Under the PAT animation,  there's just one material node, egg_spot.
This'll change the texture the egg spot uses for defined costume ranges.

By default, both CLR and PAT animations are pre-configured to support all 50 available costumes slots (+hidden alts). Heed no mind to everything between Frames 51 and 60, as those are filler frames to get to the hidden alts (Costume IDs 61 and 62 respectively).

The PAT animation is pre-configured to change to the Yoshi_Egg_2 texture for costumes 20 - 29. If you want to include your own texture for your own costume range, right click on the Texture0 node (under the egg_spot material node inside the PAT animation), click New Entry (or press Ctrl + H). There, you'll apply your custom texture (make sure to set the palette as well) and the Costume ID to start changing it on. Make sure to add another PAT entry to set the end point for your texture change, in which it'll change back to using the original texture (this must be done manually).