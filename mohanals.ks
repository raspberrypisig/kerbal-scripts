clearscreen.

set throttle to 1.
set steering to R(0,0,0)*UP.
stage.

local lastDisplay to time:seconds.

list engines in elist.

when time:seconds - lastDisplay > 0.1 then {
    print "Stage " + stage:number at (0,0).
    print "Solid Fuel:" + stage:solidfuel at (0,1).
    print "Liquid Fuel:" + stage:liquidfuel at (0,2).
    
    set lastDisplay to time:seconds.
    return true.
}

UNTIL stage:number = 1 {
    PRINT "Stage: " + STAGE:NUMBER AT (0,0).
    FOR e IN elist {
        IF e:FLAMEOUT {
            STAGE.
            PRINT "STAGING!" AT (0,0).

            UNTIL STAGE:READY {
                WAIT 0.
            }

            LIST ENGINES IN elist.
            CLEARSCREEN.
            BREAK.
        }
    }
}

