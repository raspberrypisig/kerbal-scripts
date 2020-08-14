local orbitHeight to 85000.
local twr to 2.0.

//Clear screen
clearscreen.

// Ignite main engine, max throttle and point up
local throt to 1.
lock throttle to throt.
set steering to R(0,0,0)*UP.
stage.

// Define some local variables
local tgain to 0.1 - (0.1005 / twr).
local gain to 1/-(orbitHeight+1)^2.
local pitch to 0.


// Define some more local variables
local lastDisplay to time:seconds.
local checkpoint to "".
list engines in elist.




// Some constants related to Kerbin
local kerbinRadius to body:radius.
local kerbinAtmosphereAltitude to body:atm:height.

// This stages the liquid fuel engines
when maxthrust = 0 then {
   stage.
   wait until stage:ready.
   return true.
}

// This stages the solid fuel engines
when stage:solidfuel < 0.1 and stage:liquidfuel = 0 then {
    stage.
	wait until stage:ready.
	return true.
}

// Runs every 0.1 seconds
when time:seconds - lastDisplay > 0.1 then {
    print "==================================================" at (0,0).
    print "                  STAGE " + stage:number + "     " at (0,1).
    print "Solid Fuel:       " + round(stage:solidfuel,2) + "     " at (0,3).
    print "Liquid Fuel:      " + round(stage:liquidfuel,2) + "     " at (0,4).
    print "==================================================" at (0,6).
    print "                  SPACECRAFT" at (0,7).
	print "Max. Thrust:      " + round(maxthrust,2) + "     "  at (0,9).
	print "Mass:             " + round(ship:mass,2) + "     " at (0,10).
	print "Ship Apoapsis:    " + round(ship:apoapsis) + "     " at (0,11).
	print "Ship Periapsis:   " + round(ship:periapsis) + "     " at (0,12).
    print "==================================================" at (0,14).
	print "                  TARGET" + "     " at (0,15).
	print "Orbit height:     " + orbitHeight + "     " at (0,17).
	print "ETA to Apoapsis:  " + round(eta:apoapsis) + "     " at (0,18).
    print "==================================================" at (0,20).	
	print "                  CHECKPOINT" at (0,21).
	print checkpoint + "                                            " at (0,23).
	
	set lastDisplay to time:seconds.
	return true.
}

wait until ship:altitude > 147.

set checkpoint to "Checkpoint 1 : Altitude of 147m reached.                    ".

until ship:altitude > 30000 and pitch <= -90 {
	    set salt to ship:altitude.
	    set tta to eta:apoapsis.
	    set pitch to -sqrt(0.170283 * salt) + 5.
	    set teta to (-1 * pitch) + tgain * (pitch + 90).
	    //if pitch < -90 {
		//  set pitch to -90.
	    //}
	    lock steering to r(0,pitch,0)*up.
	    set tmoid to -1/(1+5^(teta - tta))+1.
		set throt to tmoid.
}
	
lock steering to r(0,-90,0)*up.

set checkpoint to "Checkpoint 2: Pitch of 90 degrees achieved.                   ".

until eta:apoapsis < 15  {
	set apo to ship:apoapsis.
	set pthrot to gain*apo^2+1.
	if pthrot < 0	{
			lock throttle to 0.
		}
	if pthrot < 0.005	{
			lock throttle to 0.005.
		}
	else {
			lock throttle to pthrot.
		}
}

set checkpoint to "Checkpoint 2: 30 seconds from apoapsis.                       ".

stage.
wait until stage:ready.

set checkpoint to "Checkpoint 3:  Starting Burn.                                  ".

lock throttle to 0.
lock steering to prograde.

until ship:periapsis / ship:apoapsis > 0.9999 {
	set tta to -1 * eta:apoapsis.
	set pthrot to -1/(1+5^(tta+3))+1.
	lock throttle to pthrot.
}
lock throttle to 0.

set checkpoint to "Checkpoint 4: Burn complete.                                    ". 

clearscreen.
print "MohanALS Done.".
