2034 - Total Outside Damage in Grab to Cause a Grab Break [10->6]
	float 6.0   @ $80B87B28
3120 - Walk Maximum Animation Speed [3->4]
	float 4.0    @ $80B8827C
3122 - Dash, Pivot, & F-Smash Sensitivity [0.8->0.73]
	float 0.73   @ $80B88284
3125 - Dash Exit Momentum Multiplier [0.3->0.225]
	float 0.225  @ $80B88290
3126 - Run Sensitivity [0.625->0.62]
	float 0.62   @ $80B88294
3133 - Crouch & Tether Drop Sensitivity [-0.66->-0.625]
	float -0.625 @ $80B882B0
3138 - Tap Jump Sensitivity [0.6625->0.7]
	float 0.7    @ $80B882C4
3141 - Dash/Run Tap Jump Sensitivity [0.5625->0.635]
	float 0.635  @ $80B882D0
3148 - Spotdodge Sensitivity [-0.7->-0.75]
	float -0.75  @ $80B882EC
3149 - Roll Sensitivity [0.7->0.75]
	float  0.75  @ $80B882F0
3158 - U-Smash Sensitivity [0.6625->0.73]
	float  0.73  @ $80B88314
3160 - D-Smash Sensitivity [-0.6625->-0.73]
	float -0.73  @ $80B8831C
3162 - Fully Charged Smash Multiplier [1.4->1.3667]
	float 1.3666667 @ $80B88324
3167 - Fastfall Sensitivity [-0.6625->-0.665]
	float -0.665 @ $80B88338
3187 - Platform Drop Sensitivity [-0.6875->-0.71]
	float -0.71  @ $80B88388

3200 - Base Disabled Time on Shield Break [400->490]
	float 490.0	 @ $80B883BC
3232 - Aerial Attack Landing Lag Modifier [0.35->0.1]
	float 0.1	 @ $80B8843C
3233 - Max Shield Strength [50->60]
	float 60.0	 @ $80B88440
3242 - Shield Pushback Multiplier 1 [1.15->0.35]
	float 0.35	 @ $80B88464
3243 - Shield Pushback Addition Constant [2->0.1]
	float 0.1	 @ $80B88468
3245 - Maximum Shield Pushback [1.6->70]
	float 70.0	 @ $80B88470
3249 - Shield Pushback ratio [0.7->0]
	float 0.0	 @ $80B88480

3251 - Powershield Pushback Multiplier [0.15 -> 0.7]
	float 0.7	 @ $80B88488
3252 - Attacker Shield Pushback Multiplier [0.04->0.07]
	float 0.07	 @ $80B8848C
3253 - Attacker Shield Pushback Minimum [0.025->0.02]
	float 0.02	 @ $80B88490
3256 - Franklin Badge Reflected Damage Multiplier [1.3->0.75->1.0] (0.75 in PM, 1.0 in P+)
	float 1.0 	 @ $80B8849C
3257 - Franklin Badge Reflected Speed Multiplier [1.3->1.0]
	float 1.0	 @ $80B884A0
3266 - Multiplier for Grab Held Time Added from Total Damage [1.7->2.2]
	float 2.2	 @ $80B884C4
#3285 - Knockback Multiplier on Wall/Ceiling Bounce [0.85->0.80] #Knockback mult written by code menu so disabled here
#	float 0.8	 @ $80B88510
3299 - Tumble Wiggle Sensitivity [0.8->0.75]
	float 0.75	 @ $80B88548
3300 - Ceiling Corner Blast KO X Range Multiplier [0.2->0.01]
	float 0.01 	 @ $80B8854C

3305 - Launch Distance Needed for Low KB SFX [80 -> infinity]
	float Infinity @ $80B88560
3306 - Launch Distance Needed for Mid KB SFX [80 -> infinity]
	float Infinity @ $80B88564
3307 - Launch Distance Needed for High KB SFX [80 -> infinity]
	float Infinity @ $80B88568

3312 - Base Sleep Time [10 -> 3]
	float 3.0	   @ $80B8857C
3313 - Base Sleep Time*3 [10 -> 7]
	float 7.0	   @ $80B88580
3315 - Multiplier for sleep time added from KB [25 -> 15]
	float 15.0	   @ $80B88588

3386 - Kirby Inhale Time Reduced per Input [10->12]
	float 12.0	   @ $80B886A4
3389 - Kirby Inhale Star reduction per Input [10 -> 0] # added from vanilla
	float 0.0	   @ $80B886B0
3400 - DK Cargo Hold Base Time [100->90]
	float 90.0	   @ $80B886DC
3401 - DK Cargo Hold Increase per Damage [5->2.5 (was 0.592 in 2.0)]
	float 2.5	   @ $80B886E0
3402 - DK Cargo Hold Reduction per Input [10->8]
	float 8.0	   @ $80B886E4
3412 - Dedede Inhale Star Reduction per Input [12 -> 3 -> 0] # changed from vanilla
	float 0.0	   @ $80B8870C
3466 - Curry Run Animation Speed Multiplier [2->1]
	float 1.0	   @ $80B887E4

22001 - Lower Angle Threshold for Meteor Smash Range [230->260]
	int 260 @ $80B87BE8
22002 - Upper Angle Threshold for Meteor Smash Range [310->280]
	int 280 @ $80B87BEC
23033 - Frames between Consecutive Dashes [15->17]
	int 17 @ $80B88E6C
23037 - SpotDodge Input Window [4->3]
	int 3  @ $80B88E7C
23038 - Roll Input Window [4->3]
	int 3  @ $80B88E80
23043 - Reversal Window (B Reversals) [3->4]
	int 4  @ $80B88E94
23047 - Ledgesnap Duration [3->0]
	int 0  @ $80B88EA4
23050 - Frames between Ledgegrabs [30->29]
	int 29 @ $80B88EB0
23051 - Ledge Invincibility [23->31]
	int 31 @ $80B88EB4
23052 - Tech Window [16->20]
	int 20 @ $80B88EB8
23069 - WallJump Timer [130->20]
	int 20 @ $80B88EFC

23075 - Frames Between Consecutive Wallclings [60->n/a]
	float NaN @ $80B88F14

23078 - Powershield Window [4(3)->3(2)]
	int 3 @ $80B88F20
23079 - Powershield Drop Window to be Interruptible [4->5]
	int 5 @ $80B88F24
23082 - Grab->TurnGrab Window [3->4]
	int 4 @ $80B88F30

23085 - Base Held Time in Grabs [90->76]
	int 76 @ $80B88F3C

23087 - Frames After Landing Until KO Ownership is Lost [10800->60]
	int 60 @ $80B88F44
23148 - Curry Effect Duration [780->1200]
	int 1200 @ $80B89038

23149 - Frames Between Curry Flames [5->n/a]
	float NaN @ $80B8903C

F-Smash Sensitivity uses IC-Basic 3220 [0.8->0.8]
	int 3220 @ $80FA97F8
Pivot Sensitivity [0.8->0.475]
	int[2] 1, 28500 @ $80FAC244 // The latter is divided by 5000
Dash within Dash Uses Run Sensitivity [0.80->0.62]
	int 3126 @ $80FAC2B8 // This is divded by 5000


Threshold to begin tracking distance vs time on stick movements [0.25->0.35]
	float  0.35 @ $80AD7528
	float -0.35 @ $80AD752C
D-Pad acceleration threshold for solo Wiimote movement [30->23.999]
	float 23.999 @ $805A182C
Item Ground Smash U-Throw Velocity [4.1->4.34]
	float 4.34 @ $80F9FDBC