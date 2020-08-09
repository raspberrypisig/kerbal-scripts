clearscreen.

set throttle to 1.
set steering to R(0,0,0)*UP.
stage.

local orbitHeight to 85000.
local lastDisplay to time:seconds.
local twr to 2.0.
local tgain to 0.1 - (0.1005 / twr).
local gain to 1/-(orbitHeight+1)^2.

local message to "".

list engines in elist.

when maxthrust = 0 then {
   stage.
   wait until stage:ready.
   return true.
}

when stage:solidfuel < 0.1 and stage:liquidfuel = 0 then {
    stage.
	wait until stage:ready.
	return true.
}

when time:seconds - lastDisplay > 0.1 then {
    print "==================================================" at (0,0).
    print "                  STAGE " + stage:number at (0,1).
    print "Solid Fuel:       " + stage:solidfuel at (0,3).
    print "Liquid Fuel:      " + stage:liquidfuel at (0,4).
    print "==================================================" at (0,6).
    print "                  SPACECRAFT" at (0,7).
	print "Max. Thrust:      " + maxthrust  at (0,9).
	print "Mass:             " + ship:mass at (0,10).
	print "Ship Apoapsis:    " + ship:apoapsis at (0,11).
	print "Ship Periapsis:   " + ship:periapsis at (0,12).
    print "==================================================" at (0,14).
	print "                  TARGET" at (0,15).
	print "Orbit height:     " + orbitHeight at (0,17).
	print "ETA to Apoapsis:  " + eta:apoapsis at (0,18).
    print "==================================================" at (0,20).	
	print "                  PROGRESS" at (0,21).
	print "Status Report:    " + message at (0,23).
	
	set lastDisplay to time:seconds.
	return true.
}

wait until ship:altitude > 147.

set message to "Altitude of 147m reached.".

until ship:altitude >= 53000 {
	    set salt to ship:altitude.
	    set tta to eta:apoapsis.
	    set pitch to -sqrt(0.170283 * salt) + 5.
	    set teta to (-1 * pitch) + tgain * (pitch + 90).
	    if pitch < -90 {
		  set pitch to -90.
	    }
	    lock steering to r(0,pitch,0)*up.
	    set tmoid to -1/(1+5^(teta - tta))+1.
	    lock throttle to tmoid.
}
	
lock steering to r(0,-90,0)*up.

set message to "Altitude of 53000 reached. Coasting at 25% throttle.".

until ship:apoapsis >= 0.9 * orbitHeight {
	lock throttle to 0.25.
}

set message to "About to reach apoapsis".


//until ship:apoapsis >= orbitHeight  {
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

set message to "Starting Burn.".

lock throttle to 0.
until ship:periapsis / ship:apoapsis > 0.9999 {
	set tta to -1 * eta:apoapsis.
	set pthrot to -1/(1+5^(tta+3))+1.
	lock throttle to pthrot.
}
lock throttle to 0.


clearscreen.
print "MohanALS Done.".
