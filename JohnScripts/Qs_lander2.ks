//  Lander.ks -- An automated landing script
//		for a ship of 12.7t with 2.9 TWR
// A script for the KOS mod for KSP
//   by Quill18   (http://youtube.com/quill18)
// I have edited this version here: https://gist.github.com/quill18/bbddb8135cdd84479132
//   to accept GROUNDSPEED not SURFACESPEED
// 
// PHASE 0: Variables and settings

// The altitude radar reading is from the center of mass (I think), and not
// from the base of your landing gear. You need to give the script a hint
// as to the height offset so it correctly cuts the engines just before
// touch down.
// Recommended that you test your lander on the ground with a script that
// just prints ALT:RADAR to the terminal.
SET SHIP_RADAR_HEIGHT TO 3.

// PHASE 1: Point the right way!

PRINT "SETTING SAS". 
sas on.
WAIT 0.0001.
SET SASMODE TO "RETROGRADE".
WAIT 5 .

// PHASE 2: Kill horizontal velocity (ground speed)

PRINT "KILLING HORIZONTAL VELOCITY".
UNTIL SHIP:GROUNDSPEED < 25 {
		LOCK THROTTLE TO 1.
		WAIT 0.01.
 }
 
 LOCK THROTTLE TO 0.
   if GEAR OFF.
		GEAR ON.
 // PHASE 3: Gentle landing (we hope)!
 
 PRINT "STARTING DESCENT LOGIC".
 SET DESIREDVEL TO 200.
 SET T TO 0.
 LOCK THROTTLE TO T.
 
 // Loop until we're 2 meters above the ground.
 UNTIL ALT:RADAR < SHIP_RADAR_HEIGHT +2 {
 
   // This part can be replaced with a formula  ( V = 2 * SQRT(h) - 8, where h >=16 )
		if (ALT:RADAR < 25 ) {
			SET DESIREDVEL TO 1.
			// Change SAS mode so it behaves at touchdown			
			SET SASMODE TO "STABILITYASSIST".
		}
		else if (ALT:RADAR < 50 ) {
				SET DESIREDVEL TO 3.
		}
		else if (ALT:RADAR < 100 ) {
				SET DESIREDVEL TO 5.
		}
		else if (ALT:RADAR < 500 ) {
				SET DESIREDVEL TO 10.
		}
		else if (ALT:RADAR < 1000 ) {
				SET DESIREDVEL TO 25.
		}
		else if (ALT:RADAR < 3000 ) {
				SET DESIREDVEL TO 50.
		}
 
  // Can be replaced with a Pid controller
		if (SHIP:VELOCITY:SURFACE:MAG > DESIREDVEL ) {
				SET T TO MIN(1, T + 0.1).
			}
			else {
				 set t to MAX(0, T - 0.1).
			}
			
 // Kill throttle
		if (SHIP:VERTICALSPEED > 0 ) {
			SET T TO 0.
		}
		WAIT 0.001.
		
}

 PRINT "KILLING ENGINES".
 LOCK THROTTLE TO 0.
 WAIT 3.
 UNLOCK STEERING.
 UNLOCK THROTTLE.
 
 SET V0 TO GETVOICE(0). // Gets a reference to the zero-th voice in the chip.
V0:PLAY( NOTE(400, 1.0) ).  // Starts a note at 400 Hz for 1.0 (2.5) seconds.
 