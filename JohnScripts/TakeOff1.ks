//hellolaunch

//First, we'll clear the terminal screen to make it look nice

//switch to 0.

CLEARSCREEN.

BRAKES ON.
//SAS ON.    // Fights against "LOCK STEERING"
//THROTTLE ON.
lock throttle to 1.
STAGE.
WAIT 1.
BRAKES OFF.

//very crude takeoff procedure

//Keep Straight on runway 90 deg

LOCK STEERING TO HEADING(90,2).
if airspeed > 60.
//wait until airspeed > 60.
	print "Rotate!".
LOCK STEERING TO HEADING(90,5).
WAIT 4.
LOCK STEERING TO HEADING(90,8).
wait until  ALT:RADAR>50.

GEAR OFF.
print "GEAR UP!".

wait until altitude > 250.


unlock steering.
unlock throttle.
SET VO TO GETVOICE(0). //Get a reference to the 0th voice in the chip
VO: PLAY( NOTE(400,1.0)). //Starts a note at 400 Hz for 1 second
print "Program Complete".

//SET SHIP CONTROL PILOT MAIN THROTTLE TO 0.