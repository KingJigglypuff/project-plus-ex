Move Hitbox And Hitbox Decleration allow Size and position to be specified with a variable [Eon]
* C274AC24 00000009
* C85F0010 80830000
* 2C040005 40820034
* 80830004 807B00D8
* 80630064 3D80807A
* 618CCBB4 7D8903A6
* 4E800421 FC000890
* 3D808074 618CAC44
* 7D8903A6 4E800420
* 60000000 00000000
* C274ACA4 00000009
* C85F0010 80830000
* 2C040005 40820034
* 80830004 807B00D8
* 80630064 3D80807A
* 618CCBB4 7D8903A6
* 4E800421 FC000890
* 3D808074 618CACC0
* 7D8903A6 4E800420
* 60000000 00000000
* C274AD20 00000009
* C85F0010 80830000
* 2C040005 40820034
* 80830004 807B00D8
* 80630064 3D80807A
* 618CCBB4 7D8903A6
* 4E800421 FC000890
* 3D808074 618CAD3C
* 7D8903A6 4E800420
* 60000000 00000000
* C274B6E8 00000009
* 80030004 80830000
* 2C040005 40820034
* 80830004 807D00D8
* 80630064 3D80807A
* 618CCBB4 7D8903A6
* 4E800421 FC000890
* 3D808074 618CB710
* 7D8903A6 4E800420
* 60000000 00000000
* C274B770 00000009
* 80030004 80830000
* 2C040005 40820034
* 80830004 807D00D8
* 80630064 3D80807A
* 618CCBB4 7D8903A6
* 4E800421 FC000890
* 3D808074 618CB798
* 7D8903A6 4E800420
* 60000000 00000000
* C274B7F8 00000009
* 80030004 80830000
* 2C040005 40820034
* 80830004 807D00D8
* 80630064 3D80807A
* 618CCBB4 7D8903A6
* 4E800421 FC000890
* 3D808074 618CB820
* 7D8903A6 4E800420
* 60000000 00000000
* C274B880 00000009
* 80030004 80830000
* 2C040005 40820034
* 80830004 807D00D8
* 80630064 3D80807A
* 618CCBB4 7D8903A6
* 4E800421 FC000890
* 3D808074 618CB8A8
* 7D8903A6 4E800420
* 60000000 00000000

Graphic effects accept variable arguments for rotation and rand elements [Eon]

.macro checkVariable(<argPointer>) 
{
    #make r3 the pointer to argument list
    addi r3, r1, <argPointer>
    #add variable accessor as part of passed arg
    lwz r4, 0x10(r3)
    stw r4, 0x14(r3)
    
    stw r31, 0x10(r3)
    #look at top of arg list
    li r4, 0
    #get Float, will auto handle scalars and variables
    lis r12, 0x8077
    ori r12, r12, 0xE0CC
    mtctr r12
    bctrl
    #puts result in correct place
    fmr f0,f1
    lwz r4, (0x14+<argPointer>)(r1)
    stw r4, (0x10+<argPointer>)(r1)

    #expects after it a break that takes you to the float write that the game usually performs
}
##########
#DETACHED# 0x111b1000
##########
#Zrot
CODE @ $807A5AE0
{
    %checkVariable(0x818)
}
#Yrot
CODE @ $807A5B5C
{
    %checkVariable(0x818)
}
#Xrot
CODE @ $807A5BD8
{
    %checkVariable(0x818)
}
#ZOffsetRand
CODE @ $807A5D8C
{
    %checkVariable(0x818)
}
#YOffsetRand
CODE @ $807A5E08
{
    %checkVariable(0x818)
}
#XOffsetRand
CODE @ $807A5E84
{
    %checkVariable(0x818)
}
#ZRotRand
CODE @ $807A5F00
{
    %checkVariable(0x818)
}
#YRotRand
CODE @ $807A5F7C
{
    %checkVariable(0x818)
}
#YRotRand
CODE @ $807A5FF8
{
    %checkVariable(0x818)
}

##########
#ATTACHED# 0x11010a00 
##########
#Zrot
CODE @ $807A74D0
{
    %checkVariable(0x798)
}
#Yrot
CODE @ $807A754C
{
    %checkVariable(0x798)
}
#Xrot
CODE @ $807A75C8
{
    %checkVariable(0x798)
}