lock steering to r(0,0,0)*up.
lock throttle to 1.

set running to true.

when (terminal:input:haschar) then {
  set char to terminal:input:getchar().
  if char = "x" {
    lock throttle to 0.
  }
  
  if char = "z" {
    lock throttle to 1.
  }
  
  if char = "q" {
    set running to false.
    return false.
  }
  
  return true.
}

wait until running = false.
