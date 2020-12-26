//  Q's Lander
//
//
//
//
//

// PHASE 0: Variables and settings

//
//




SET SHIP_RADAR_HEIGHT TO 5.

// PHASE 1: Point the right way!

PRINT "SETTING SAS".
sas on.
WAIT 0.0001.
SET SASMODE TO "RETROGRADE".
WAIT 3.

// PHASE 2: Kill horizontal velocity (ground speed)

PRINT "KILLING HORIZONTAL VELOCITY".
UNTIL SHIP:GROUNDSPEED < 25 {
		LOCK THROTTLE TO 1.
		WAIT 0.01.
 }
 
 LOCK THROTTLE TO 0.
 
 
 // PHASE 3: Gentle landing (we hope)!
 
 PRINT "STARTING DESCENT LOGIC".
 SET DESIREDVEL TO 150.
 SET T TO 0.
 LOCK THROTTLE TO T.
 
 // Loop until we're 2 meters above the ground.
 UNTIL ALT:RADAR < SHIP_RADAR_HEIGHT +2 {
 
		if (ALT:RADAR < 25 ) {.
			SET DESIREDVEL TO 2.
			
			
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
 
  // CAN BE REPLACED WITH PID CONTROLLER
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
 