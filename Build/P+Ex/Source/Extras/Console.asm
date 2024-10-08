# Place codes that are not to be used on Dolphin within here
############################################################

480p Pixel Fix Patch [leseratte, Eon]
#    fix for a Nintendo Revolution SDK bug found by Extrems affecting early Wii console when using 480p video mode.
#    https://shmups.system11.org/viewtopic.php?p=1361158#p1361158
#    https://github.com/ExtremsCorner/libogc-rice/commit/941d687e271fada68c359bbed98bed1fbb454448
# Origianl patch by leseratte
# Ported to Brawl by Eon
HOOK @ $801EBD74
{
    li r3, 3 
    stb r3, 25(r1)
}