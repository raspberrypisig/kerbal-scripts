lock steering to r(0,0,90)+up.
lock throttle to 1.
wait until stage:ready.
stage.

set running to true.
when maxthrust = 0 and running = true then {
//  lock throttle to 0.
  stage.
  print "stage number:" + stage:number.
//  set running to false.
}

wait until running = false.
//stage.
//wait until stage:ready.



SET V0 TO GETVOICE(0). // Gets a reference to the zero-th voice in the chip.
V0:PLAY( NOTE(400, 1.0) ).  // Starts a note at 400 Hz for 2.5 seconds.