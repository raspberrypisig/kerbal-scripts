// Beep.ks
//   Make noise first
//   Make a noise on program end

lock throttle to 0.
print "Program Ended.".

SET V0 TO GETVOICE(0). // Gets a reference to the zero-th voice in the chip.
V0:PLAY( NOTE(400, 1.0) ).  // Starts a note at 400 Hz for 2.5 seconds.
                            // The note will play while the program continues.
PRINT "The note is still playing".
PRINT "when this prints out.".

//wait until FALSE.      //false.   *******

//At this point, our apoapsis is above 100km and our main loop has ended. Next
//we'll make sure our throttle is zero and that we're pointed prograde
LOCK THROTTLE TO 0.

//This sets the user's throttle setting to zero to prevent the throttle
//from returning to the position it was at before the script was run.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
