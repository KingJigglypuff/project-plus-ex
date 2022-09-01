![Project+] UCF with Melee threshold [Fracture]
* C283A31C 0000001F
* 9001FFFC 7C0802A6
* 90010004 7C0902A6
* 9001FFF8 9421FF7C
* BC610008 807C0068
* A0A30028 38A50001
* C0030038 C0430048
* FC00102A FC000210
* 3C803E8C 6084CCCD
* 9081FFF0 C041FFF0
* FC001000 41810008
* 38A00000 B0A30028
* 38E00000 2C050004
* 40810028 3C803F19
* 6084999A 9081FFF0
* C041FFF0 C0030038
* FC000210 FC001000
* 41800008 38E00001
* 80DC007C 80860034
* 2C04001A 41820010
* 2C04001B 41820008
* 38E00000 2C070001
* 4082002C 3C80BF4C
* 6084CCCD 3CA080B8
* 60A582EC 90850000
* 3C80BF2C 6084CCCD
* 3CA080B8 60A58388
* 90850000 B8610008
* 38210084 8001FFF8
* 7C0903A6 80010004
* 7C0803A6 8001FFFC
* 7F43D378 00000000
* C283A324 0000000D
* 9001FFFC 7C0802A6
* 90010004 7C0902A6
* 9001FFF8 9421FF7C
* BC610008 3C6080B8
* 606382EC 3C80BF40
* 90830000 3C60BF35
* 6063C28F 3C8080B8
* 60848388 90640000
* B8610008 38210084
* 8001FFF8 7C0903A6
* 80010004 7C0803A6
* 8001FFFC 3C6080B8
* 60000000 00000000

[Project+] UCF with Melee threshold 2.0 [Fracture, Eon]
#reworked to better match melees thresholds and mechanics 

#when doing an action override, use a subroutine pointing to 0x80FC2138, this is where the platdrop code that this code edits is found
#this can be used to add this UCF mechanic to other actions or just when you change functionality of the main shield
#PSA-C Copy-paste : E=00070100:0-80FC2138,

HOOK @ $8083A31C
{

start:
  lwz r3, 0x68(r28) #load data obj whatever it is
  lhz r5, 0x28(r3) #load current count for frames in range

checkXVal:
  lwz r4, 0x38(r3)  #load current x float 
  cmpwi r4, 0
  bne checkSameXDir #must be nonzero
  li r5, 0
  b checkNeutralTime
checkSameXDir:
  lwz r0, 0x40(r3)  #load prev x float
  xor r4, r4, r0    #xor's every bit of stick pos, highest value bit = pos or neg
  andis. r4, r4, 0x8000 #if bit is set, then that means changed from pos to neg or back again
  beq inc
  li r5, 0
  
inc:
  addi r5, r5, 0x1 #increment by 1

checkNeutralTime:
  sth r5, 0x28(r3)
  cmpwi r5, 0x4
  blt end

checkStickPos:
  lis r4, 0x3E00 #0.125
  stw r4, -0x10(r1)
  lfs f0, -0x10(r1)
  
  lfs f1, 0x38(r3) #get stick pos
  fabs f1, f1
  fadd f1, f1, f0   
  lfs f2, 0x3C(r3) #get stick pos
  fabs f2, f2
  fadd f2, f2, f0

  fadd f1, f1, f2

  lis r4, 0x3F80
  stw r4, -0x10(r1)
  lfs f0, -0x10(r1)

  fcmpu cr0, f0, f1
  bgt end #stick abs value >= 0.275 units


enableUCFShielddrop:
#modify shielddrop args to more leneint values, 
#these are PSA scalars so they are in reality the intended value * 60000
#changes them to scalars from variable
  li r0, 1
#-0.8 spotdodge sensitivity
  lis r4, 0xFFFF
  ori r4, r4, 0x4480

  lis r3, 0x80FB
  ori r3, r3, 0x0804

  stw r0, 0x0(r3)
  stw r4, 0x4(r3)

#-0.675 - plat drop sensitivity
  lis r4, 0xFFFF
  ori r4, r4, 0x61CC

  lis r3, 0x80FB
  ori r3, r3, 0x0A44

  stw r0, 0x0(r3)
  stw r4, 0x4(r3)

end:
  mr r3, r26
}
HOOK @ $8083A324
{

resetShielddropValues:
#revert shielddrop args to base values
#these are PSA scalars so they are in reality the intended value * 60000
#makes sure arg is read as a variable
  li r0, 0x5
#-0.75 spotdodge sensitivity - 0xC4C is Mem-map value of it
  li r4, 0xC4C
  lis r3, 0x80FB
  ori r3, r3, 0x0804
  stw r0, 0x0(r3)
  stw r4, 0x4(r3)
#-0.71 - plat drop sensitivity - 0xC73 is Mem-map value of it
  li r4, 0xC73
  lis r3, 0x80FB
  ori r3, r3, 0x0A44
  stw r0, 0x0(r3)
  stw r4, 0x4(r3)

  lis r3, 0x80B8 #original Command

}
