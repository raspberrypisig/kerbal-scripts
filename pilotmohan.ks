set EAST_VES_USER_SELECTION to 0.
set WEST_VES_USER_SELECTION to 0.
set RUNWAY_ALT_USER_SELECTION to 0.

//--------------------------Start Lat Long Dialog Box--------------------------------------------
FUNCTION STARTDIALOG {
  LOCAL gui is GUI(500).
  LOCAL labelIntro IS gui:ADDLABEL("<size=20><b>Enter Details below. </b></size>").
  SET labelIntro:STYLE:ALIGN TO "CENTER".
  SET labelIntro:STYLE:HSTRETCH TO True. 
  LOCAL vbox to gui:ADDVBOX().
  LOCAL firsthlayout to vbox:ADDHLAYOUT().
  LOCAL eastlatlabel to firsthlayout:ADDLABEL("Lat").
  LOCAL eastlattextfield to firsthlayout:ADDTEXTFIELD("").
  LOCAL eastlonglabel to firsthlayout:ADDLABEL("Long").
  LOCAL eastlongtextfield to firsthlayout:ADDTEXTFIELD("").
  LOCAL ok TO gui:ADDBUTTON("OK").
  SET ok:ONCLICK TO {
    LOCAL la IS eastlattextfield:TEXT:TONUMBER().
    LOCAL lo IS eastlongtextfield:TEXT:TONUMBER().
    SET EAST_VES_USER_SELECTION to latlng(la, lo).
    SET WEST_VES_USER_SELECTION to 0.
    SET RUNWAY_ALT_USER_SELECTION to 0.
    SET isdone to true.
  }.
  gui:SHOW().
  SET isdone to false.
  WAIT UNTIL isdone.
}

STARTDIALOG().

//--------------------------End Lat Long Dialog Box--------------------------------------------



// pilot control.

run lib_pid.

set yokePull to 0.
set yokeRoll to 0.
set shipRoll to 0.
set shipCompass to 0.

//set east_ves to vessel("VASI east").
//set west_ves to vessel("VASI west").
//set runway_alt to body:altitudeof(west_ves:position).

//set east_ves to V(-0.0499832,-74.496929,69.162401). // Angie RWY 09
//set west_ves to V(-0.0485339,-74.718264,69.466402). // Angie RWY 09
//set runway_alt to 69.4664022 + 0.5. // Angie RWY 09

//set east_ves_pos to V(-0.0499832,-74.496929,69.162401). // Angie RWY 09
//set west_ves_pos to V(-0.0485339,-74.718264,69.466402). // Angie RWY 09
//LOCAL east_ves_spot IS BODY:GEOPOSITIONOF(east_ves_pos). 
//LOCAL west_ves_spot IS BODY:GEOPOSITIONOF(west_ves_pos). 

//set runway_alt to 69.4664022 + 0.5. // Angie RWY 09


//set east_ves to latlng(-0.0499832,-74.496929). // Angie RWY 09
//set west_ves to latlng(-0.0485339,-74.718264). // Angie RWY 09
//set runway_alt to 69.4664022 + 0.5. // Angie RWY 09

set east_ves to EAST_VES_USER_SELECTION.
set west_ves to WEST_VES_USER_SELECTION.
set runway_alt to RUNWAY_ALT_USER_SELECTION.

lock runway_vect to (east_ves:position - west_ves:position):normalized.
//lock runway_vect to (east_ves_pos - west_ves_pos):normalized. // Angie


// make a list of aiming waypoints:
set i to 0.
set arith_series to 0. // A counter that goes 1,3,6,10,15, etc.
set aim_geo_list to list().
set aim_alt_list to list().
set aim_spd_list to list().

// Seed a final waypoint which is on the runway, at ground altitude, with 80% of runway left:
//local aim_pos is east_ves:geoposition:altitudeposition(0).
//local aim_pos is east_ves_pos. //ANGIE
local aim_pos is east_ves:altitudeposition(0).
aim_geo_list:add(ship:body:geopositionof(aim_pos)).
aim_alt_list:add(0).
//aim_spd_list:add(65). Angie
aim_spd_list:add(42).

until i >= 5 {
  local aim_alt is runway_alt+5+arith_series*150.
  //local aim_pos is west_ves:geoposition:altitudeposition(aim_alt) - (120 + 1500*arith_series)*runway_vect.
  //local aim_pos is BODY:geoposition:altitudeposition(aim_alt) - (120 + 1500*arith_series)*runway_vect. // Angie
  local aim_pos is west_ves:altitudeposition(aim_alt) - (120 + 1500*arith_series)*runway_vect.// Angie
  local aim_geo is ship:body:geopositionof(aim_pos).
  aim_geo_list:add(aim_geo).
  aim_alt_list:add(aim_alt).
  if i = 0 { 
    aim_spd_list:add(75).
  } else if i = 1{
    aim_spd_list:add(80).
  } else {
    aim_spd_list:add(120).
  }
  set i to i+1.
  set arith_series to arith_series+i.
}

function displayPitch {
  parameter col,row.

  print "Want Vspd = " + round(wantClimb,1) + "   " at (col,row).
  print "     Vspd = " + round(ship:verticalspeed,1) + " m/s   " at (col,row+1).
  print "yoke pull = " + round(yokePull,2) + "   " at (col,row+2).
}

function displayRoll {
  parameter col,row.

  print "Want Bank = " + round(wantBank,1) + "   " at (col,row).
  print "     Bank = " + round(shipRoll,1) + " m/s   " at (col,row+1).
  print "yoke Roll = " + round(yokeRoll,3) + "    " at (col,row+2).
}

function displayCompass {
  parameter col,row.

  print "Want Comp = " + round(wantCompass,0) + " deg  " at (col,row).
  print "     Comp = " + round(shipCompass,0) + " deg  " at (col,row+1).
}

function displaySpeed {
  parameter col,row.

  print "Want Spd = " + round(wantSpeed,0) + " m/s  " at (col,row).
  print "airSpeed = " + round(ship:airspeed,0) + " m/s  " at (col,row+1).
  print "curthrot = " + round(scriptThrottle,2) + "   " at (col,row+2).
}

function displayOffset {
  parameter col,row,off.

  print "line offset angle = " + round(off,0) + " deg  " at (col,row).
}

function displayProgress {
  parameter geo, alti, col,row.

  print "Aiming at LAT=" + round(geo:lat,2) + " LNG=" + round(geo:lng,2) + ", ALT " + round(alti,0) + "m" at (col,row).
  local d is geo:altitudeposition(alti+geo:terrainheight):mag.
  print "Dist To aim point " + round(d,0) + "m" at (col,row+1).
  print "          Cur ALT " + round(ship:altitude,0) + "m" at (col,row+2).
}

function roll_for {
  parameter ves.

  local raw is vang(ves:up:vector, - ves:facing:starvector).
  if vang(ves:up:vector, ves:facing:topvector) > 90 {
    if raw > 90 {
      return raw - 270.
    } else {
      return raw + 90.
    }
  } else {
    return 90 - raw.
  }
}.

function east_for {
  parameter ves.

  return vcrs(ves:up:vector, ves:north:vector).
}

function compass_for {
  parameter ves.
  parameter mode. // 0,1,2 for 0=facing, 1=orbital vel, 2 = srf vel.

  local pointing is 0.
  if mode = 0 {
    set pointing to ves:facing:forevector.
  } else if mode = 1 {
    set pointing to ves:velocity:orbit.
  } else if mode = 2 {
    set pointing to ves:velocity:surface.
  } else {
    PRINT "ARRGG.. Compass_for was called incorrectly.".
  }

  local east is east_for(ves).

  local trig_x is vdot(ves:north:vector, pointing).
  local trig_y is vdot(east, pointing).

  local result is arctan2(trig_y, trig_x).

  if result < 0 { 
    return 360 + result.
  } else {
    return result.
  }
}.

function angle_off {
  parameter a1, a2. // how far off is a2 from a1.

  local ret_val is a2 - a1.
  if ret_val < -180 {
    set ret_val to ret_val + 360.
  } else if ret_val > 180 {
    set ret_val to ret_val - 360.
  }
  return ret_val.
}

function compass_between_latlngs {
  parameter p1, p2. // latlngs for current and desired position.

  return
    arctan2( sin( p2:lng - p1:lng ) * cos( p2:lat ),
             cos( p1:lat )*sin( p2:lat ) - sin( p1:lat )*cos( p2:lat )*cos( p2:lng - p1:lng ) ).
}

function circle_distance {
 parameter
  p1,     //...this point, as a latlng...
  p2,     //...to this point, as a latlng...
  radius. //...around a body of this radius plus altitude.

 local A is sin((p1:lat-p2:lat)/2)^2 + cos(p1:lat)*cos(p2:lat)*sin((p1:lng-p2:lng)/2)^2.
 
 return radius*constant():PI*arctan2(sqrt(A),sqrt(1-A))/90.
}.

function get_want_climb {
  parameter ves, // vessel that's doing the climb
            ap. // aim pos.

  local alt_diff is ves:body:altitudeof(ap) - ves:altitude.
  local dist is circle_distance( ves:geoposition, ves:body:geopositionof(ap), ves:body:radius+ves:altitude).
  local time_to_dest is dist / ves:groundspeed.

  return alt_diff / time_to_dest.
}

// Adds an additional waypoints just off to the left side, so the plane will navigate to it.
function create_go_around_points {
  local old_len is aim_geo_list:length.
  // Remove lastmost "fake" waypoint that only existed to get vector direction:
  aim_spd_list:remove(old_len-1).
  aim_geo_list:remove(old_len-1).
  aim_alt_list:remove(old_len-1).

  // Add a new waypoint 4km to my left of the last one:
  aim_spd_list:add( aim_spd_list[old_len-2] ).
  aim_alt_list:add( aim_alt_list[old_len-2] ).
  local new_pos is aim_geo_list[old_len-2]:altitudeposition(aim_alt_list[old_len-2]) - 4000*ship:facing:starvector.
  aim_geo_list:add( ship:body:geopositionof(new_pos) ).

  // Add a new waypoint 2 km in front of me, 200m up, high spd, to force go-around throttle up:
  aim_spd_list:add( aim_spd_list[old_len-2] * 2 ).
  aim_alt_list:add( ship:altitude + 300 ).
  set new_pos to ship:position + 2000*ship:facing:forevector.
  aim_geo_list:add( ship:body:geopositionof(new_pos) ).

  // Add a new waypoint at my current position, to start from:
  aim_spd_list:add( 0 ).
  aim_alt_list:add( ship:altitude ).
  aim_geo_list:add( ship:body:geopositionof(ship:position) ).
}

function remove_go_around_points {
  until aim_geo_list:length <= 6 {
     aim_geo_list:remove(aim_geo_list:length-1).
     aim_alt_list:remove(aim_alt_list:length-1).
     aim_spd_list:remove(aim_spd_list:length-1).
  }
}

// Made into a separate function calls so that it's possible to re-init them later
// with the same PID gains - used below in the part called "PANIC MODE".
function init_pitch_pid {
  return PID_init(0.01, 0.005, 0.003, -1, 1).
}
function init_roll_pid {
  return PID_init(0.005, 0.00005, 0.001, -1, 1).
}
function init_bank_pid {
  return PID_init(3, 0.00, 5, -45, 45).
}
function init_throt_pid {
  return PID_init(0.1, 0.001, 0.05, 0, 1).
}

set pitchPid to init_pitch_pid().
set bankPid to init_bank_pid().
set rollPid to init_roll_pid().
set throtPid to init_throt_pid().



set wantClimb to 0.
set wantBank to 0.
set wantSpeed to 0.

on ag1 {
  set aim_spd_list[0] to aim_spd_list[0] - 1.
  set aim_spd_list[1] to aim_spd_list[0] * 1.1.
  set aim_spd_list[2] to aim_spd_list[0] * 1.2.
  preserve.
}
on ag2 {
  set aim_spd_list[0] to aim_spd_list[0] + 1.
  set aim_spd_list[1] to aim_spd_list[0] * 1.1.
  set aim_spd_list[2] to aim_spd_list[0] * 1.2.
  preserve.
}
on ag3 {
  set aim_spd_list[3] to aim_spd_list[3] - 1.
  set aim_spd_list[4] to aim_spd_list[4] - 1.
  preserve.
}
on ag4 {
  set aim_spd_list[3] to aim_spd_list[3] + 1.
  set aim_spd_list[4] to aim_spd_list[4] + 1.
  preserve.
}
on ag5 {
  set vd_aimline:show to not vd_aimline:show.
  set vd_aimpos:show to not vd_aimpos:show.
  preserve.
}.


// If you begin the script already landed, then insert
// the goaround points to cause a takeoff:
if status = "LANDED" {
  create_go_around_points().
  print "PLEASE TAKE OFF - once you are in air, I will take over.".
  wait until status <> "LANDED".
}

clearscreen.
print "Action groups:".
print "  AG 1,2 = raise/lower final speed:".
print "  AG 3,4 = raise/lower approach speed:".
print "  AG 5   = toggle hide/show aim vectors.".
print "  Abort = quit script and give control to player.".
sas off.
brakes off.

// Start one position back from the end of the waypoint list, so there is
// a phantom "prev" waypoint to help give info how to align the first turn.
set cur_aim_i to aim_geo_list:length-2.

set vd_aimline to vecdraw(v(0,0,0),v(1,0,0),RGBA(1,0,0,2),"waypoint line",1,true).
set vd_aimpos to vecdraw(v(0,0,0),v(1,0,0),RGBA(1,1,0,2),"aimpoint",1,true).

set user_quit to false.
set need_pid_reinit to false.

on abort set user_quit to true.

when alt:radar < 200 then {
  if not gear {
    gear on.
    hudtext( "DEPLOYING GEAR DOWN", 8, 2, 32, WHITE, false).
  }
  preserve.
}
when alt:radar > 200 then {
  if gear {
    gear off.
    hudtext( "RETRACTING GEAR UP", 8, 2, 32, WHITE, false).
  }
  preserve.
}

until user_quit or status="LANDED" or cur_aim_i < 0 {
  wait 0.001.
  local cur_aim_geo is aim_geo_list[cur_aim_i].
  local cur_aim_alt is aim_alt_list[cur_aim_i].
  local cur_spd_want is aim_spd_list[cur_aim_i].

  // Get the previous geo point, or use current ship coord for it
  // if there is no prev geo point yet:
  local prev_aim_geo is 0.
  local prev_aim_alt is 0.
  if cur_aim_i < aim_geo_list:length - 1 {
    set prev_aim_geo to aim_geo_list[cur_aim_i+1].
    set prev_aim_alt to aim_alt_list[cur_aim_i+1].
  } else {
    set prev_aim_geo to ship:geoposition.
    set prev_aim_alt to ship:altitude.
  }
  local prev_aim_pos is prev_aim_geo:altitudeposition(prev_aim_alt).

  local cur_aim_line_pos is cur_aim_geo:altitudeposition(cur_aim_alt).

  // Change the cur_aim_geo to a point partway between point i+1 and i,
  // a fraction of the distance from ship to point i, along the line backward from
  // point i to point i+1.  This aims at the line between i+1 and i.
  local dist_to_aim is (cur_aim_line_pos - ship:position):mag.
  local unit_vec_backward is (prev_aim_pos - cur_aim_line_pos):normalized.
  local offset_angle is vang(cur_aim_line_pos-ship:position, -1*unit_vec_backward). // the more off it is, the less to move it.
  local fraction is offset_angle/60. // the more off it is, the less to move it.
  set cur_aim_pos to cur_aim_line_pos + fraction*dist_to_aim*unit_vec_backward.
  set cur_aim_geo to ship:body:geopositionof(cur_aim_pos).

  set vd_aimline:start to prev_aim_pos.
  set vd_aimline:vec to cur_aim_line_pos - prev_aim_pos.
  set vd_aimpos:start to ship:position.
  set vd_aimpos:vec to cur_aim_pos - ship:position.

  set wantCompass to compass_between_latlngs(ship:geoposition, cur_aim_geo).
  set wantSpeed to cur_spd_want.

  if cur_aim_i > 0 {
    set wantClimb to get_want_climb(ship, cur_aim_pos).
  } else {
   //Angie if (east_ves:position - ship:position):mag < (west_ves:position - ship:position):mag {
   //if (east_ves - ship:position):mag < (west_ves - ship:position):mag {
   if (east_ves:position - ship:position):mag < (west_ves:position - ship:position):mag {
      hudtext( "**ABORT! GO_AROUND! LESS THAN HALF OF RUNWAY LEFT**", 8, 2, 32, yellow, false).
      remove_go_around_points(). // just in case this isn't the first go-around.
      create_go_around_points().
      set cur_aim_i to aim_geo_list:length-2.
    }
    else if alt:radar > 5 {
      set wantClimb to -1.5.
    } else {
      set wantClimb to -0.5. // flare out at 5m or lower.
    }
  }

  if (cur_aim_line_pos - ship:position):mag < 500 {
    set cur_aim_i to cur_aim_i - 1.
    if cur_aim_i < 0 {
       
    }
  }


  set shipSpd to ship:airspeed.
  set scriptThrottle to PID_seek( throtPID, wantSpeed, shipSpd).
  lock throttle to scriptThrottle.

  set shipRoll to roll_for(ship).
  set shipCompass to compass_for(ship,2). // srf vel mode

  set yokePull to PID_seek( pitchPid, wantClimb, ship:verticalspeed ).
  set ship:control:pitch to yokePull.

  // normal desired bank when things are going well:
  set wantBank to PID_seek( bankPid, 0, angle_off(wantCompass, shipCompass) ).
  // override that with a sanity-seeking flat bank when things aren't going well:
  if abs(wantClimb-ship:verticalspeed) > 50 {
    set wantBank to 0.
    if not need_pid_reinit { // first time this happened.
      hudtext( "PANIC MODE - IGNORING COMPASS - JUST LEVELLING", 8, 2, 32, yellow, false).
    }
    set need_pid_reinit to true.
  } else {
    // When we have been overriding the bank this way, need to reinit the PID
    // controller for it so it doesn't "learn" incorrectly from what was happening
    // in the past while its suggested inputs weren't actually being used:
    if need_pid_reinit {
      hudtext( "PANIC MODE OVER - RESUMING NORMAL FLIGHT", 8, 2, 32, white, false).
      set bankPid to init_bank_pid().
      set throtPid to init_throt_pid().
      set rollPid to init_roll_pid().
      set pitchPid to init_pitch_pid().
      set need_pid_reinit to false.
    }
  }
  
  set yokeRoll to PID_seek( rollPid, wantBank, shipRoll ).
  set ship:control:roll to yokeRoll.

  displayCompass(5,8).
  displayRoll(5,12).
  displayPitch(5,16).
  displaySpeed(5,20).
  displayOffset(5,24,offset_angle).
  displayProgress(aim_geo_list[cur_aim_i], cur_aim_alt, 3,27).
  print round(aim_spd_list[0],0) + " m/s " at (39,1).
  print round(aim_spd_list[3],0) + " m/s " at (39,2).
}

if user_quit {
  sas on.
  print "QUITTING.. USER ABORT".
} else {
  brakes on.
  print "QUITTING.. BRAKES ON.".
  lock throttle to 0.
  wait until status="LANDED".
}
set vd_aimpos to 0.
set vd_aimline to 0.
set ship:control:pilotmainthrottle to 0.
set ship:control:neutralize to true.

