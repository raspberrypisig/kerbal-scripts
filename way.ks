
FUNCTION drawArrowWaypoint {
    PARAMETER wp.
    clearvecdraws().
    vecdraw({ return V(0,0,0). }, {return wp:position.}, Red, currentWaypointValue:text, 1.0, TRUE).
    vecdraw({ {return wp:position.}. }, {return wp:position + up:forevector * 20000000.} , Yellow, currentWaypointValue:text, 0.2, TRUE, 0.2, FALSE).
    vecdraw({ {return wp:position.}. }, {return wp:position + up:topvector * 20000000.} , Green, currentWaypointValue:text, 0.2, TRUE, 0.2, FALSE).
}

FUNCTION drawArrowVector {
    PARAMETER v.
    clearvecdraws().
    vecdraw({ return V(0,0,0). }, {return v.}, Red, currentWaypointValue:text, 1.0, TRUE).
    vecdraw({ {return v.}. }, {return v + up:forevector * 20000000.} , Yellow, currentWaypointValue:text, 0.2, TRUE, 0.2, FALSE).
    vecdraw({ {return v.}. }, {return v + up:topvector * 20000000.} , Green, currentWaypointValue:text, 0.2, TRUE, 0.2, FALSE).
}

FUNCTION waypointClickHandler {
    PARAMETER p.
    return {
        SET currentWaypointValue:text TO p.
        LOCAL wp IS waypoint(p).
        SET currentWaypointLatValue:text to wp:geoposition:lat:tostring.
        SET currentWaypointLongValue:text to wp:geoposition:lng:tostring.
        SET currentWaypointAltValue:text to wp:altitude:tostring.
        SET currentWaypointBearingValue:text to wp:geoposition:bearing:tostring.
        SET currentWaypointHeadingValue:text to wp:geoposition:heading:tostring.
        drawArrowWaypoint(wp).
        targetVlayout:show().
        guiWP:hide().   

    }.
}


FUNCTION waypointCustomClickHandler {
    PARAMETER name.
    PARAMETER lat.
    PARAMETER long.
    PARAMETER alt.

    return {
        SET currentWaypointValue:text TO name.
        SET currentWaypointLatValue:text to lat.
        SET currentWaypointLongValue:text to long.
        SET currentWaypointAltValue:text to alt.
        LOCAL bearing IS  BODY:GEOPOSITIONOF(latlng(lat:tonumber,long:tonumber):altitudeposition(alt:tonumber)):bearing.
        LOCAL heading IS  BODY:GEOPOSITIONOF(latlng(lat:tonumber,long:tonumber):altitudeposition(alt:tonumber)):heading.
        SET currentWaypointBearingValue:text to bearing:tostring.
        SET currentWaypointHeadingValue:text to heading:tostring.
        drawArrowVector(latlng(currentWaypointLatValue:text:tonumber, currentWaypointLongValue:text:tonumber):altitudeposition(currentWaypointAltValue:text:tonumber)).
        targetVlayout:show().   
        guiFly:hide(). 

    }.
}


FUNCTION MissionWaypoints {
    // Mission Waypoint Selection screen
    SET guiWP TO GUI(200).
    SET guiWP:x TO 580.
    SET guiWP:y TO 100.
    LOCAL labelSelectWaypoint IS guiWP:addlabel("<size=20><b>Select waypoint:</b></size>").
    SET labelSelectWaypoint:style:align TO "CENTER".
    SET labelSelectWaypoint:style:hstretch TO True. 

    LOCAL waypoints IS allwaypoints().
    LOCAL vboxWP IS guiWP:addvbox().
    FOR nextwaypoint IN waypoints {
      //PRINT nextwaypoint:name.
      //PRINT nextwaypoint:geoposition:lat.
      //PRINT nextwaypoint:geoposition:lng.
      //PRINT nextwaypoint:altitude.
      SET vboxWP:addbutton(nextwaypoint:name):onclick TO waypointClickHandler(nextwaypoint:name).
    }.


    guiWP:show().    
    
}

FUNCTION WaypointsFromFlyKS {
    PARAMETER filename.

    // Fly.ks waypoints selection screen
    SET guiFly TO GUI(200).
    SET guiFly:x TO 580.
    SET guiFly:y TO 100.
    LOCAL labelSelectWaypoint IS guiFly:addlabel("<size=20><b>Select waypoint:</b></size>").
    SET labelSelectWaypoint:style:align TO "CENTER".
    SET labelSelectWaypoint:style:hstretch TO True. 

    LOCAL wayfromfly to open(filename).

    LOCAL vboxFly IS guiFly:addvbox().
    FOR line IN wayfromfly:readall {
      LOCAL nextwaypoint IS line:split(",").
      SET vboxFly:addbutton(nextwaypoint[0]):onclick TO waypointCustomClickHandler(nextwaypoint[0], nextwaypoint[1], nextwaypoint[2], nextwaypoint[3]).
    }.


    guiFly:show().   
}.

FUNCTION targetClickHandler {
  
  LOCAL targetNumber IS targetNumberTextField:text:tonumber.    
  LIST targets in alltargets.
  PRINT alltargets[targetNumber]:name.
  targetVlayout:show().
  
     
  SET currentWaypointValue:text TO alltargets[targetNumber]:name.
  SET currentWaypointLatValue:text to alltargets[targetNumber]:geoposition:lat:tostring.
  SET currentWaypointLongValue:text to alltargets[targetNumber]:geoposition:lng:tostring.
  SET currentWaypointAltValue:text to alltargets[targetNumber]:altitude:tostring.
  drawArrowWaypoint(alltargets[targetNumber]).
  
}.

FUNCTION MainGUI { 
    SET gui TO GUI(500). 
    SET gui:x TO 60.
    SET gui:y TO 100.    
    LOCAL labelIntro IS gui:addlabel("<size=20><b>Select waypoint</b></size>").
    SET labelIntro:style:align TO "CENTER".
    SET labelIntro:style:hstretch TO True. 
    LOCAL vbox IS gui:addvlayout().
    LOCAL buttonWaypoint IS vbox:addbutton("MISSION WAYPOINTS").
    LOCAL buttonWaypointFly IS vbox:addbutton("WAYPOINTS FROM FLY.KS").
     LOCAL buttonWaypointCustom IS vbox:addbutton("CUSTOM WAYPOINTS").
    LOCAL hboxTarget IS gui:addhlayout().
    LOCAL targetLabel IS hboxTarget:addlabel("<color=orange> or enter TARGET NUMBER</color>").
    SET targetNumberTextField TO hboxTarget:addTextField().
    LOCAL targetButton IS hboxTarget:addbutton("OK").
    SET targetVlayout TO gui:addvlayout().
    SET currentwaypointLabel TO targetVlayout:addlabel("CURRENT SELECTION").
    LOCAL hbox1 IS targetVlayout:addhlayout().
    SET currentWaypointNameLabel TO hbox1:addlabel("NAME:").
    SET currentWaypointValue TO hbox1:addlabel("").
    LOCAL hbox2 IS targetVlayout:addhlayout().
    SET currentWaypointLatLabel TO hbox2:addlabel("LAT:").
    SET currentWaypointLatValue TO hbox2:addlabel(""). 
    LOCAL hbox3 IS targetVlayout:addhlayout().
    SET currentWaypointLongLabel TO hbox3:addlabel("LONG:").
    SET currentWaypointLongValue TO hbox3:addlabel("").    
    LOCAL hbox4 IS targetVlayout:addhlayout().
    SET currentWaypointAltLabel TO hbox4:addlabel("ALTITUDE:").
    SET currentWaypointAltValue TO hbox4:addlabel("").   
    LOCAL hbox5 IS targetVlayout:addhlayout().
    SET currentWaypointBearingLabel TO hbox5:addlabel("BEARING:").
    SET currentWaypointBearingValue TO hbox5:addlabel("").   
    LOCAL hbox6 IS targetVlayout:addhlayout().
    SET currentWaypointHeadingLabel TO hbox6:addlabel("HEADING:").
    SET currentWaypointHeadingValue TO hbox6:addlabel("").             
    
    targetVlayout:hide().


    SET buttonWaypoint:onclick TO {
        MissionWaypoints().

    }.
    SET buttonWaypointFly:onclick TO {
        WaypointsFromFlyKS("wayfromfly.txt").
    }.
    SET buttonWaypointCustom:onclick TO {
        WaypointsFromFlyKS("waycustom.txt").
    }.
    LOCAL ok IS targetVlayout:addbutton("OK").
    SET ok:onclick TO {
        SET isdone to true.
    }.

    SET targetButton:onclick TO {
       targetClickHandler().
    }.

    gui:show().
    SET isdone to false.
    WAIT UNTIL isdone.
}


MainGUI().
clearguis().
