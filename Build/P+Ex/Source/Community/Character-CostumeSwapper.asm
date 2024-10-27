###########################################
Character/Costume Swapper REVAMP [MarioDox]
###########################################
# Revamp hooks into actual file requesting, previous version only worked on CSS transition
.macro single(<ftKind>,<costumeId>,<newftKind>,<newcostumeId>)
{
    cmpwi     r4, <ftKind>
    bne-     0x14
    cmpwi     r5, <costumeId>
    bne-     0xC
    li      r4, <newftKind>
    li      r5, <newcostumeId>
}

.macro rangeSameCostume(<ftKind>,<costumeIdStart>,<costumeIdEnd>,<newftKind>)
{
    cmpwi     r4, <ftKind>
    bne-     0x18
    cmpwi     r5, <costumeIdStart>
    blt-     0x10
    cmpwi     r5, <costumeIdEnd>
    bgt-     0x8
    li      r4, <newftKind>
}


HOOK @ $80946174 #processBegin/[stLoaderPlayer]
{
    lbz r4,0x0(r31)        # Original op, keep it at the top
    %rangeSameCostume(0x61,7,10,0x82) # Female Corrin > Male Corrin, example usage
    %rangeSameCostume(0x6E,7,10,0x81) # Male Robin > Female Robin, example usage
end:
    stb r4,0x0(r31)        # store the new id, otherwise it will crash
}