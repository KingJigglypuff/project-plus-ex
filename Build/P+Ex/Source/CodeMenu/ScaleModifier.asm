#####################
Scale Modifier [Desi]
#####################

.alias CodeMenuStart = 0x804E
.alias CodeMenuHeader = 0x02D4

HOOK @ $80776D80
{
    lis r3, CodeMenuStart
    ori r3, r3, CodeMenuHeader
    lwz r3, 0 (r3)
    lbz r31, 0xB (r3)
    cmpwi r31, 0x1
    bne HookPoint
    lhz r31, 0 (r3)
    add r3, r31, r3
    lfs f1, 0x8 (r3)
    lis r3, 0x80AD
    b %END%

HookPoint:
    lis r3, 0x80AD
    lfs f1, 0x76C0 (r3)
}