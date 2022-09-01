###########################################
CSS Selections Preserved in VS Mode [Magus]
###########################################
op b 0x3C @ $806DCA90

#############################
CSS Record Display Fix [ds22]
#############################
HOOK @ $8068DBCC
{
  cmpwi r29, 0x28
  beq- %END%
  cmpwi r29, 0x29
}
op beq- 0x3C @ $8068DBD0

###################################################################################################
BrawlEX Hold Shield Rewrite v4 Clone Fix [codes, ChaseMcDizzle, HyperL!nk, PyotrLuzhin, ds22, Desi]
###################################################################################################
#Changes from previous version:
#	1. Table no longer occupies memory outside the GCT
#	2. Go to SSS no longer users a counter
op nop @ $806847B8
op nop @ $806847BC
op b 0x8 @ $806847C0

HOOK @ $80685BE4        #Return to CSS (Restore the original CharacterID)
{
  li r12, 0x0           #Start Counter
  bl 0x4                #Set current code location in Link Register 
  mflr r4               #Move Link Register to R4
  addi r4, r4, 0x68     #Set r4 to Shield Rewrite Data Address
IDCheckLoop:
  lbz r3, 0(r4)         #Load Shield Rewrite Data
  cmpwi r12, 0x80       #If out of range, End the code
  beq- Hook
  cmpw r3, r5           #Compare Shield Rewrite ID to Counter ID
  beq- RestoreID        #If the Shield Rewrite Data matches the CharacterID, the Counter in r12 is used to restore
  addi r12, r12, 0x1    #Add 1 to Counter
  addi r4, r4, 0x1      #Add 1 to Shield Rewrite Data Address
  b IDCheckLoop

RestoreID:
  mr r5, r12

Hook:
  stw r5, 60(r1)        #Implied to be original function
}

HOOK @ $8068482C        #Go to SSS (This occurs only while holding L)
{
  cmpwi r29, 0x80       #Safety Check
  bge- %END%
  bl 0x4                #Set current code location in Link Register 
  mflr r4
  addi r4, r4, 0x1C     #Set r4 to Shield Rewrite Data Address
  lbzx r29, r29, r4     #Load Rewrite Data based on CharacterID
}
##########################################
#Shield Rewrite Data
#To use, replace the CSSSlot ID with the character you want to be shield loaded. 
#For example, Bowser (0xC) was replaced with Giga Bowser(0x30). 
#In the commented section, this is indicated by placing GKoopa in parenthesis behind bowser.
#Note that replacing an ID with one lower than it can cause issues with the L-Load CSP Code.
#http://opensa.dantarion.com/wiki/CSS_Slots
##########################################
.GOTO->Table_Skip
byte [128] |
0x00, 0x01, 0x02, 0x03,|    #Mario, Donkey, Link, Samus
0x04, 0x05, 0x06, 0x07,|    #SZerosuit, Yoshi, Kirby, Fox,
0x08, 0x09, 0x0A, 0x0B,|    #Pikachu, Luigi, Captain, Ness,
0x30, 0x0D, 0x0E, 0x0F,|    #Bowser (GKoopa), Peach, Zelda, Sheik
0x37, 0x11, 0x12, 0x13,|    #IceClimber (Sopo), Marth, G&W, Falco
0x14, 0x35, 0x16, 0x17,|    #Ganon, Wario (WarioMan), MetaKnight, Pit
0x18, 0x19, 0x1A, 0x1B,|    #Pikmin, Lucas, Diddy, Pokemon Trainer
0x1C, 0x1D, 0x1E, 0x1F,|    #Charizard, Squirtle, Ivysaur, Dedede
0x20, 0x21, 0x22, 0x23,|    #Lucario, Ike, Robot, Jigglypuff
0x24, 0x25, 0x26, 0x27,|    #ToonLink, Wolf, Snake, Sonic
0x28, 0x29, 0x2A, 0x2B,|    
0x2C, 0x2D, 0x2E, 0x2F,|    #????, Roy, Mewtwo, ????
0x30, 0x31, 0x32, 0x33,|
0x34, 0x35, 0x36, 0x37,|
0x38, 0x39, 0x3A, 0x3B,|    #ZakoBoy, ZakoGirl, ZakoChild, ZakoBall
0x3C, 0x3D, 0x3E, 0x3F,|
0x40, 0x41, 0x42, 0x43,|    #EX Characters
0x44, 0x45, 0x46, 0x47,|
0x48, 0x49, 0x4A, 0x4B,|
0x4C, 0x4D, 0x4E, 0x4F,|
0x50, 0x51, 0x52, 0x53,|
0x54, 0x55, 0x56, 0x57,|
0x58, 0x59, 0x5A, 0x5B,|
0x5C, 0x5D, 0x5E, 0x5F,|
0x60, 0x61, 0x62, 0x63,|
0x64, 0x65, 0x66, 0x67,|
0x68, 0x69, 0x6A, 0x6B,|
0x6C, 0x6D, 0x6E, 0x6F,|
0x70, 0x71, 0x72, 0x73,|
0x74, 0x75, 0x76, 0x77,|
0x78, 0x79, 0x7A, 0x7B,|
0x7C, 0x7D, 0x7E, 0x7F
Table_Skip: