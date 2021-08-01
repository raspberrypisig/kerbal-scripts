
//FUNCTION waypointClickHandler {
//    PARAMETER p.
//    return {
//        PRINT p.
//        SET currentWaypointValue:text TO p.
//        guiWP:hide().    
//    }.
//}


FUNCTION MissionWaypoints {
    //Waypoint Selection screen
    LOCAL guiWP IS GUI(200).
    SET guiWP:x TO 580.
    SET guiWP:y TO 100.
    LOCAL labelSelectWaypoint IS guiWP:addlabel("<size=20><b>Select waypoint:</b></size>").
    SET labelSelectWaypoint:style:align TO "CENTER".
    SET labelSelectWaypoint:style:hstretch TO True. 

    LOCAL waypoints IS allwaypoints().
    LOCAL vboxWP IS guiWP:addvbox().
    SET nameList TO list().
    SET latCollection TO lexicon().
    SET lngCollection TO lexicon().
    SET altCollection TO lexicon().
    FOR nextwaypoint IN waypoints {
      //PRINT nextwaypoint:name.
      //PRINT nextwaypoint:geoposition:lat.
      //PRINT nextwaypoint:geoposition:lng.
      //PRINT nextwaypoint:altitude.
      nameList:add(nextwaypoint).
      latCollection:add(nextwaypoint:name, nextwaypoint:geoposition:lat).
      lngCollection:add(nextwaypoint:name, nextwaypoint:geoposition:lng).
      altCollection:add(nextwaypoint:name, nextwaypoint:altitude).
      // get out of jail
      // https://ksp-kos.github.io/KOS/language/anonymous.html#anonymous-functions
      // https://ksp-kos.github.io/KOS/language/delegates.html
      // SET vboxWP:addbutton(nextwaypoint:name):onclick TO waypointClickHandler(nextwaypoint:name).
      SET vboxWP:addbutton(nextwaypoint:name):onclick TO {
        PARAMETER p IS nextwaypoint:name.
        PRINT p.
        SET currentWaypointValue:text TO p.
        guiWP:hide().
      }.
    }.


    guiWP:show().    
    
}

FUNCTION MainGUI { 
    SET gui TO GUI(500). 
    SET gui:x TO 60.
    SET gui:y TO 100.    
    LOCAL labelIntro IS gui:addlabel("<size=20><b>Select waypoint</b></size>").
    SET labelIntro:style:align TO "CENTER".
    SET labelIntro:style:hstretch TO True. 
    LOCAL vbox IS gui:addvbox().
    SET currentwaypointLabel TO vbox:addlabel("CURRENT SELECTION").
    LOCAL hbox1 IS vbox:addhlayout().
    SET currentWaypointNameLabel TO hbox1:addlabel("NAME:").
    SET currentWaypointValue TO hbox1:addlabel("").

    LOCAL buttonWaypoint IS vbox:addbutton("Select a Mission Waypoint").
    SET buttonWaypoint:onclick TO {
        MissionWaypoints().
    }.
    LOCAL ok IS gui:addbutton("OK").
    SET ok:onclick TO {
        SET isdone to true.
    }.
    gui:show().
    SET isdone to false.
    WAIT UNTIL isdone.
}


MainGUI().
clearguis().
