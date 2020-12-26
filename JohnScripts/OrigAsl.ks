//Adaptive Launch Script for Kerbal Operating System
//By /u/supreme_blorgon
//
//To run, type into terminal " run als(<target orbit height>). ",
//replace everything between and including <> with your desired
//orbit height in METERS (e.g.: 150000). This script will automatically
//determine the throttle control based on the number you pass into the program.
//
//Once the spacecraft is out of the atmosphere, the script
//will automatically trigger action group 1. I've set all my
//rockets up to either deploy their fairings or jettison
//their escape towers on AG1. You will need to change that line if you
//don't want to use it.
//
//Please give credit when using or modifying!
//
//kOS was originally created by Nivekk. It is under active development by
//the kOS Team and is licensed under terms of GNU General Public License
//Version 3, 29 June 2007, Copyright © 2007 Free Software Foundation, Inc.
//
parameter orbitheight.

when stage:liquidfuel < 0.1 then {
    stage.
    return true.
}
set gain to 1/-(orbitHeight+1)^2.
lock steering to r(0,0,0)*up.
lock throttle to 1.
stage.
set twr to ship:maxthrustat(ship:sensors:pres / 100) / ship:mass * ship:sensors:grav:mag.
set tgain to 0.1 - (0.1005 / twr).
wait until ship:altitude > 147.
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
    if ship:apoapsis > orbitHeight - (orbitHeight*0.1) {
        lock throttle to 0.
        break.
    }
}
lock steering to r(0,-90,0)*up.
until ship:apoapsis > orbitHeight - (orbitHeight*0.1) {
    lock throttle to 0.25.
}
lock throttle to 0.
wait until ship:altitude >= 70000.
toggle AG1.
rcs on.
until ship:apoapsis >= orbitHeight {
    set apo to ship:apoapsis.
    set pthrot to gain*apo^2+1.
    if pthrot < 0   {
            lock throttle to 0.
        }
    if pthrot < 0.005   {
            lock throttle to 0.005.
        }
    else {
            lock throttle to pthrot.
        }
}
lock throttle to 0.
until ship:periapsis / ship:apoapsis > 0.9999 {
    set tta to -1 * eta:apoapsis.
    set pthrot to -1/(1+5^(tta+3))+1.
    lock throttle to pthrot.
}
lock throttle to 0.
print "Program Ended.".
wait until false.