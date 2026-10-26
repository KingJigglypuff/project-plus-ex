========================================
Guide for Adding Yoshi Costumes
========================================
Yoshi uses a new color animation-based system for the egg break GFX.
Costume colors and textures are tied to animation frames inside the FitYoshi.pac file > ef_yoshi ARC > Model Data [0].
The CLR and PAT groups contain color and texture pattern animations respectively, with the frame matching Yoshi's costume ID.

========================================
Changing Egg Shell Patterns
========================================
The PAT animation entry for egg_spot controls which texture the egg spots use for defined costume ranges.
By default, this is pre-configured to change to the Yoshi_Egg_20 texture for costumes 20 - 29.

To add a custom texture for a different costume range, right-click the Texture0 node and click New Entry (or press Ctrl + H). Apply the custom texture name (and its palette) and the starting Costume ID. Then, add another PAT entry to set the end point for your texture change, in which it'll change back to using the original Yoshi_Egg texture.

========================================
Changing Egg Shell Colors
========================================

Inside the EffYoshiTamagoKakeraA CLR animation, egg_spot supports up to two colors. Standard costumes use only ColorRegister1, while the Dorrie alts use ColorRegister0 and ColorRegister1.
Inside Texture Data [0], the red portion of the egg textures are controlled by Color 0, while Color 1 affects the blue portion of the texture.

The egg (shell) texture supports only a single color (controlled by ColorRegister0 in the CLR animation).

========================================
By default, both CLR and PAT animations are pre-configured to support all 50 available costumes slots (+hidden alts). Heed no mind to everything between Frames 51 and 60, as those are filler frames to get to the hidden alts (Costume IDs 61 and 62 respectively).

If you have any questions, please feel free to ask in the #modding-discussion channel of the Project+ Discord.
