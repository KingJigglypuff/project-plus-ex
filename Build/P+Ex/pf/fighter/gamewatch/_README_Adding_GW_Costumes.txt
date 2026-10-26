========================================
Guide for Mr. Game and Watch Costumes
========================================
A number of changes were made for Mr. Game and Watch's costume files to support alternate costume models.

Costumes 00 - 19 will use FitGameWatch00 (Default)
Costumes 20 - 29 will use FitGameWatch01 (Judge)
Costumes 30 - 39 will use FitGameWatch02
Costumes 40 and onward will use FitGameWatch03

If you wish to adjust these ranges for further customization, see the code Project+\Source\LegacyTE\LoadFlags.asm

========================================
Adding Mr. Game and Watch Recolors
========================================
All body & border colors are set through the Animation Data[10] and Animation Data [0] [Group 1] CLR entries in each pac.

Avoid using costume slots 12 and 13! They will not function correctly due to Brawl limitations, and are colored red to denote this.

========================================
Entry .pac file
========================================
FitGameWatchEntry.pac, a file loaded from the Brawl disc, was disabled due to coding limitations regarding separate entry files.

========================================
Additional Bones and VIS0
========================================
There are additional bones added, necessary for any new alternate costumes added to P+.

Each bone listed should have the Visible property set to False if adding to a pre-existing costume.

Bone 98 (HeadFront): Used for when Mr. Game and Watch faces the front. Can be used to get specific looks from the front versus the side. For any new costume creators, be sure to test HeadFront, and all the VIS0 animations in FitGameWatchMotionEtc that call it.

Bones 99 - 102 (Entry1, Entry2, Entry3, Entry4): These bones replace the entry file, and are set up based on the frames of the entry animation. The entry objects in FitGameWatch01 are the easest way to set this up, and new costume creators should review them in their modelling software of choice.

========================================
If you have any questions, please feel free to ask in the #modding-discussion channel of the Project+ Discord.
