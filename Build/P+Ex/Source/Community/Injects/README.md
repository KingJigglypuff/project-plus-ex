## Injection GCT System (lavaInjectLoader)
This folder contains the source files for the injection .GCT files found in "pf/injects/"!
These injection .GCTs are special, in that rather than being included traditionally through RSBE01/BOOST.GCT, they're loaded through the lavaInjectLoader Syriinge plugin found in "pf/plugins/". The plugin works by iterating through and temporarily loading each group of .GCT files found in the "pf/injects/" folder, running the Gecko Codehandler over each file *a single time* before discarding it and loading the next. Very importantly, this means that Gecko codetypes which rely on remaining in memory (eg. C2/HOOK codes, C0/PULSE codes which expect to run every frame, etc.) *will not function correctly*, and thus should not be included in injection .GCT files! Instead, the system is intended for use with codetypes which do their work in a single round of the Codehandler, the most notable of which being the standard Memory Write codetypes (which are the meat of all of the Fighter.pac injection .GCTs in the "pf/injects/fighter/" folder). 

### Creating or Updating Inject .GCTs
To create or update an injection .GCT, simply compile the corresponding .ASM file using GCTRM, then place the resulting .GCT file into one of the subfolders within "pf/injects/". The loader plugin will detect it automatically and load it along with the rest of the .GCTs in that folder!

### Inject Groups
Each subfolder within the "pf/injects/" folder represents an "Inject Group": a group of injects that are all applied after some event happens in-game. Currently, the only subfolder is the "pf/injects/fighter/" folder, whose contents are applied a single time immediately after the game finishes loading and resolving the common Fighter.pac file. This makes it most appropriate for Fighter.pac injects, though technically other unrelated injects may be placed in this group as well. 

### The Fighter.pac Inject Group
Many .asm files previously compiled and linked in to either RSBE01.GCT or BOOST.GCT have been converted into inject .GCTs to save space in the main .GCTs. These can be found in the "pf/injects/fighter/" folder, and include the following:

| Injection .GCT ("injects/fighter/") | Original Source File                     |
|-------------------------------------|------------------------------------------|
| "Constants.GCT"                     | "Source/ProjectM/Constants.asm"          |
| "Effects.GCT"                       | "Source/ProjectM/PSA/Effects.asm"        |
| "Misc.GCT"                          | "Source/ProjectM/PSA/Misc.asm" ***\****  |
| "Tethers.GCT"                       | "Source/ProjectM/PSA/Tethers.asm"        |
| "TauntCancel.GCT"                   | "Source/ProjectM/PSA/TauntCancel.asm"    |
| "PowerShield.GCT"                   | "Source/ProjectM/PSA/PowerShield.asm"    |
| "Items.GCT"                         | "Source/ProjectM/PSA/Items.asm"          |
| "Hitstun.GCT"                       | "Source/ProjectM/PSA/Hitstun.asm"        |
| "C-Stick.GCT"                       | "Source/ProjectM/PSA/C-Stick.asm"        |
| "MeteorCancel.GCT"                  | "Source/ProjectM/PSA/MeteorCancel.asm"   |
| "WallCling.GCT"                     | "Source/ProjectM/PSA/WallCling.asm"      |
| "Glide.GCT"                         | "Source/ProjectM/PSA/Glide.asm"          |
| "Grabs.GCT"                         | "Source/ProjectM/PSA/Grabs.asm"          |
| "SlowTurn.GCT"                      | "Source/ProjectM/PSA/SlowTurn.asm"       |
| "Edge.GCT"                          | "Source/ProjectM/PSA/Edge.asm"           |
| "Moonwalk.GCT"                      | "Source/Project+/Moonwalk.asm"           |
| "PlatformIgnore.GCT"                | "Source/P+Ex/PlatformIgnore.asm"         |

***\**** *Note: This file contained a single non-Fighter.pac Injection code which was moved to a different .ASM, while the rest of the code was converted to an inject.*

### lavaInjectLoader Source Code
The annotated source code for the lavaInjectLoader plugin can be found [here](https://github.com/QuickLava/lavaSyriingePlugins/tree/main/lavaInjectLoader)!
