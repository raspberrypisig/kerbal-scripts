// AUTOPILOT BY KK #3.07
// [[[RELEASE VERSION 2.0]]]
// You are free to use any part of the script, if you decide to publish it, I'd be grateful if you gave credits to me for it. I've really spent a load of time working // on this! :)

//-------------------------------------------------------------------------------------------------------------
//__ G L O B A L   U S E R   V A R I A B L E S __

global vTimestep is 0.0025.
global vAP_BoundPitchAngle is 15.	// autopilot never goes above or below a +-15deg pitch angle when trying to maintain an altitude / climbrate
global vAP_boundRollAngle is 40.	// max. / min. roll angle
global height is 8.0.			// radar altitude the kOS unit is reading when on ground with TO/LND pitch facing angle
global thrreverse is 1.			// 1 = vessel has thrust reverse, 0 = no: Action Group for thrust reversers must be AG4 !!
global vTakeOffSpeed is 60.		// start pitching up at this speed, shouldn't be too low to prevent holdpitch i runaway
global vTakeOffAngle is 8.		// maintain this pitch angle at takeoff to prevent tailstrike
global vAfterTakeOffSpeed is 150.	// maintain this speed after takeoff
global vAfterTakeOffAngle is 15.	// maintain this pitch angle after takeoff
global maxAltitude is 5000.		// max altitude the ap maintains (nav mode)
global glideslopetarget is -5.		// Glide slope angle which the plane will try to maintain during it's approach; MUST BE >vAP_BoundPitchAngle !!
global flaredistance is 5000.		// when to start flaring for landing; the smaller the distance the more rapid and inaccurate the flare manuever is !!
global minSpeed is 110.			// min speed to maintain (at landing), should be reached at 5km grounddistance to runway
global maxSpeed is 200.			// max speed the ap will maintain during approach
global approachdec is -2.0.		// deccalaration to maintain during approach
global appr_final_verticalspeed is -1.	// verticalspeed to maintain during final approach until touchdown
global gearDeployDistance is 7500.	// when to deploy gear for landing
global landingabort_allow is 1.		// allow landing abort if too low on the glideslope, not enough runway for braking left


clearscreen.
clearguis().
switch to 0.
run once database.
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------
// U S E R   I N T E R F A C E
// - MAIN

set g_minimized to false.
set vfuel_lqf_rangeavg to 0.
set vfuel_lqf_fuelmass to 0.

function APmodeButton
{
	parameter button.	// GUI internal-name of button

	set button:toggle to true.
	set button:style:textcolor to rgb(0.8,0.8,0.8).
	set button:style:fontsize to 10.
	set button:style:on:textcolor to rgb(0.1,0.9,0.1).
	set button:style:hover:textcolor to rgb(1.0,0.8,0.0).
	set button:style:hover_on:textcolor to rgb(1.0,0.8,0.0).
	set button:style:active:textcolor to rgb(0.1,0.9,0.1).
	set button:style:active_on:textcolor to rgb(0.1,0.9,0.1).
	set button:style:width to 35.//46.
	set button:style:height to 24.//30.
	set button:style:bg to "KK_ap/button_empty_std.png".
	set button:style:on:bg to "KK_ap/button_empty_pushed.png".
	set button:style:hover:bg to "KK_ap/button_empty_hover.png".
	set button:style:hover_on:bg to "KK_ap/button_empty_hover.png".
	set button:style:active:bg to "KK_ap/button_empty_pushed.png".
	set button:style:active_on:bg to "KK_ap/button_empty_pushed.png".
}

function APprmField
{
	parameter field.
	set field:style:width to 50.
	set field:style:height to 18.
	set field:style:margin:top to 7.
	set field:style:margin:bottom to 10.
	set field:style:textcolor to rgb(0.8,0.64,0). // text entered and confirmed
	set field:style:hover:textcolor to rgb(0.6,0.48,0). // hover
	set field:style:fontsize to 12.
}


set g_main to gui(0).	// main gui name
set g_main:x to 50.	// main gui start position x
set g_main:y to 50.	// main gui start position y
set g_main:style:padding:h to 5.
set g_main:style:padding:v to 5.
set g_main:style:bg to "KK_ap/g3_bg.png".

// Box containing ap logo, vessel name, buttons for settings, minimizing, closing etc.
set g_main_xTitle to g_main:addhbox().	// x = box
set g_main_xTitle:style:margin:bottom to 3.

	// Autopilot logo
	set g_main_xTitle_logo to g_main_xTitle:addlabel("").
	set g_main_xTitle_logo:image to "KK_ap/logo2.png".
	set g_main_xTitle_logo:style:width to 34.

	// Vessel name
	set g_main_xTitle_name to g_main_xTitle:addlabel("<b>" + ship:name + "</b>").
	set g_main_xTitle_name:style:width to 150.
	set g_main_xTitle_name:style:height to 34.
	set g_main_xTitle_name:style:align to "left".
	set g_main_xTitle_name_scale to min(120*2.0 / (ship:name:length),24).
	set g_main_xTitle_name:style:fontsize to round(g_main_xTitle_name_scale).
	set g_main_xTitle_name:style:textcolor to rgb(1.0,0.8,0.0).

	// Minimize button
	set g_main_xTitle_bMin to g_main_xTitle:addbutton("").
	set g_main_xTitle_bMin:style:bg to "KK_ap/g3_button_min.png".
	set g_main_xTitle_bMin:style:on:bg to "KK_ap/g3_button_min.png".
	set g_main_xTitle_bMin:style:hover:bg to "KK_ap/g3_button_min.png".
	set g_main_xTitle_bMin:style:hover_on:bg to "KK_ap/g3_button_min.png".
	set g_main_xTitle_bMin:style:active:bg to "KK_ap/g3_button_min.png".
	set g_main_xTitle_bMin:style:active_on:bg to "KK_ap/g3_button_min.png".
	set g_main_xTitle_bMin:style:width to 25.
	set g_main_xTitle_bMin:style:height to 25.
	set g_main_xTitle_bMin:style:margin:top to 11.
	set g_main_xTitle_bMin:onclick to
	{
		toggle g_minimized.
		if g_minimized = true
		{
			g_main_xMain:hide().
			g_main_xRange:hide().
		}
		else
		{
			g_main_xMain:show().
			g_main_xRange:show().
		}
	}.

	// Close button
	set g_main_xTitle_bClose to g_main_xTitle:addbutton("").
	set g_main_xTitle_bClose:style:bg to "KK_ap/g3_button_close.png".
	set g_main_xTitle_bClose:style:on:bg to "KK_ap/g3_button_close.png".
	set g_main_xTitle_bClose:style:hover:bg to "KK_ap/g3_button_close.png".
	set g_main_xTitle_bClose:style:hover_on:bg to "KK_ap/g3_button_close.png".
	set g_main_xTitle_bClose:style:active:bg to "KK_ap/g3_button_close.png".
	set g_main_xTitle_bClose:style:active_on:bg to "KK_ap/g3_button_close.png".
	set g_main_xTitle_bClose:style:width to 25.
	set g_main_xTitle_bClose:style:height to 25.
	set g_main_xTitle_bClose:style:margin:top to 11.
	set g_main_xTitle_bClose:onclick to { set running to false.}.

// Main box containing all the modes toggles and input fields, as well as settings on the right
set g_main_xMain to g_main:addhbox().
set g_main_xMain:style:padding:top to 10.
set g_main_xMain:style:padding:bottom to 10.
set g_main_xMain:style:padding:left to 10.
set g_main_xMain:style:padding:right to 10.

	// MODES
	set g_main_xMain_modes to g_main_xMain:addhbox().
	set g_main_xMain_modes:style:width to 195.
	
		set g_main_xMain_modes_tgl to g_main_xMain_modes:addvlayout().
		set g_main_xMain_modes_tgl:style:width to 45.
	
			set b_spd to g_main_xMain_modes_tgl:addbutton("SPD"). // speed
			APmodeButton(b_spd).
			set b_alt to g_main_xMain_modes_tgl:addbutton("ALT"). // altitude
			APmodeButton(b_alt).
			set b_pit to g_main_xMain_modes_tgl:addbutton("V/S"). // verticalspeed / pitch
			APmodeButton(b_pit).
			set b_hdg to g_main_xMain_modes_tgl:addbutton("HDG"). // heading
			APmodeButton(b_hdg).
			set b_tof to g_main_xMain_modes_tgl:addbutton("T/O"). // takeoff
			APmodeButton(b_tof).
			set b_lnd to g_main_xMain_modes_tgl:addbutton("LND"). // autoland
			APmodeButton(b_lnd).
			set b_nav to g_main_xMain_modes_tgl:addbutton("NAV"). // navigate route
			APmodeButton(b_nav).
			set b_way to g_main_xMain_modes_tgl:addbutton("WAY"). // fly to waypoint
			APmodeButton(b_way).

		set g_main_xMain_modes_prm to g_main_xMain_modes:addvlayout().
			
			set prm_top to g_main_xMain_modes_prm:addhlayout().

				set prm_top_fields to prm_top:addvlayout().
				set prm_top_fields:style:width to 60.

					set t_spd to prm_top_fields:addtextfield("0").
					APprmField(t_spd).
					set t_alt to prm_top_fields:addtextfield("0").
					APprmField(t_alt).
					set t_pit to prm_top_fields:addtextfield("0").
					APprmField(t_pit).
					set t_hdg to prm_top_fields:addtextfield("0").
					APprmField(t_hdg).

				set g_units to prm_top:addvlayout().

					set t_spd_unit to g_units:addlabel("[m/s]").
					set t_spd_unit:style:textcolor to rgb(0.7,0.7,0.7).
					set t_spd_unit:style:fontsize to 13.
					set t_spd_unit:style:margin:top to 5.
					set t_spd_unit:style:margin:bottom to 9.

					set t_alt_unit to g_units:addlabel("[m]").
					set t_alt_unit:style:textcolor to rgb(0.7,0.7,0.7).
					set t_alt_unit:style:fontsize to 13.
					set t_alt_unit:style:margin:top to 5.
					set t_alt_unit:style:margin:bottom to 9.

					set t_pit_unit to g_units:addlabel("[m/s]").
					set t_pit_unit:style:textcolor to rgb(0.7,0.7,0.7).
					set t_pit_unit:style:fontsize to 13.
					set t_pit_unit:style:margin:top to 5.
					set t_pit_unit:style:margin:bottom to 9.

					set t_hdg_unit to g_units:addlabel("[deg]").
					set t_hdg_unit:style:textcolor to rgb(0.7,0.7,0.7).
					set t_hdg_unit:style:fontsize to 13.
					set t_hdg_unit:style:margin:top to 5.
					set t_hdg_unit:style:margin:bottom to 9.


			set prm_bot to g_main_xMain_modes_prm:addvlayout().

				set t_tof to prm_bot:addlabel("<Auto>").
				set t_tof:style:textcolor to rgb(0.8,0.8,0.8).
				set t_tof:style:fontsize to 13.
				set t_tof:style:margin:top to 0.
				set t_tof:style:height to 18.	
				set t_tof:style:margin:bottom to 10.

				// Popupmenu landing
				set runwaynames to list().
				print "loading runways from database.".
				set a to 0. until a > runway_database:length-1
				{
					runwaynames:add(runway_database[a][0]).
					print "- added " + runway_database[a][0] + ".".
					set a to a + 1.
				}
				print "runway loading completed.".
				set pop_lnd to prm_bot:addpopupmenu().
				set pop_lnd:index to -1.
				set pop_lnd:options to runwaynames.
				set pop_lnd:style:width to 140.
				set pop_lnd:style:height to 22.
				set pop_lnd:style:margin:top to 2.
				set pop_lnd:style:textcolor to rgb(0.8,0.64,0).
				set pop_lnd:style:hover:textcolor to rgb(0.6,0.48,0).
				set pop_lnd:style:fontsize to 9.

				// POPUPMENU ROUTE
				set pop_nav to prm_bot:addpopupmenu().
				set routenames to list().
				print "loading routes from database.".
				set a to 0. until a > routes:length-1
				{
					routenames:add(routes[a][0]).
					print "- added " + routes[a][0] + ".".
					set a to a + 1.
				}
				set pop_nav:index to -1.
				print "route loading completed.".
				set pop_nav:options to routenames.
				set pop_nav:style:width to 140.
				set pop_nav:style:height to 22.
				set pop_nav:style:margin:top to 0.
				set pop_nav:style:textcolor to rgb(0.8,0.64,0).
				set pop_nav:style:hover:textcolor to rgb(0.6,0.48,0).
				set pop_nav:style:fontsize to 9.

				// POPUPMENU WAYPOINT
				set pop_way to prm_bot:addpopupmenu().
				set pop_way:index to -1.
				set waypointnames to list().
				print "loading waypoints from database.".
				set a to 0. until a > waypoint_database:length-1
				{
					waypointnames:add(waypoint_database[a][0]).
					print "- added " + waypoint_database[a][0] + ".".
					set a to a + 1.
				}
				print "waypoint loading completed.".
				set pop_way:options to waypointnames.
				set pop_way:style:width to 140.
				set pop_way:style:height to 22.
				set pop_way:style:margin:top to 0.
				set pop_way:style:textcolor to rgb(0.8,0.64,0).
				set pop_way:style:hover:textcolor to rgb(0.6,0.48,0).
				set pop_way:style:fontsize to 9.

	// SETTINGS / TOOLS
	set toolbar to g_main_xMain:addvlayout().
	
		// airplane configuration
		set g_main_planeconfig to toolbar:addbutton("").
		set g_main_planeconfig:style:bg to "KK_ap/g3_airplaneConfig.png".
		set g_main_planeconfig:style:on:bg to "KK_ap/g3_airplaneConfig.png".
		set g_main_planeconfig:style:active:bg to "KK_ap/g3_airplaneConfig.png".
		set g_main_planeconfig:style:active_on:bg to "KK_ap/g3_airplaneConfig.png".
		set g_main_planeconfig:style:hover:bg to "KK_ap/g3_airplaneConfig.png".
		set g_main_planeconfig:style:hover_on:bg to "KK_ap/g3_airplaneConfig.png".
		set g_main_planeconfig:style:width to 25.
		set g_main_planeconfig:style:margin:bottom to 20.	
		set g_planeconfig_show to false.
		set g_main_planeconfig:onclick to 
		{	
			toggle g_planeconfig_show.
			if g_planeconfig_show = true
			{
				g_planeconfig:show().
			}
			else
			{
				g_planeconfig:hide().
			}
		}.

// BOX for range information
set g_main_xRange to g_main:addvbox().
set g_main_xRange:style:margin:top to 3.

	set xRange_line1 to g_main_xRange:addhlayout().
	set xRange_line1:style:height to 20.

		set xRange_lRange to xRange_line1:addlabel("<b>Range, Time</b>").
		set xRange_lRange:style:textcolor to rgb(1.0,0.8,0.0).
		set xRange_lRange:style:width to 90.
		set xRange_lRange:style:fontsize to 12.
		set xRange_nRange to xRange_line1:addlabel("0").
		set xRange_nRange:style:textcolor to rgb(0.9,0.9,0.9).
		set xRange_nRange:style:fontsize to 12.
		set xRange_nRange:style:width to 60.
		set xRange_nTime to xRange_line1:addlabel("0").
		set xRange_nTime:style:textcolor to rgb(0.9,0.9,0.9).
		set xRange_nTime:style:fontsize to 12.
	
	set xRange_line2 to g_main_xRange:addhlayout().
		
		set xRange_lCons to xRange_line2:addlabel("<b>Rate, Tons</b>").
		set xRange_lCons:style:textcolor to rgb(1.0,0.8,0.0).
		set xRange_lCons:style:width to 90.
		set xRange_lCons:style:fontsize to 12.
		set xRange_nCons to xRange_line2:addlabel("0").
		set xRange_nCons:style:textcolor to rgb(0.9,0.9,0.9).
		set xRange_nCons:style:fontsize to 12.
		set xRange_nCons:style:width to 60.
		set xRange_nTons to xRange_line2:addlabel("0").
		set xRange_nTons:style:textcolor to rgb(0.9,0.9,0.9).
		set xRange_nTons:style:fontsize to 12.

// GUI FOR LANDING INFORMATION
set g_main_xland to g_main:addvbox().
set g_main_xland:style:margin:top to 3.

	set xland_header to g_main_xland:addhlayout().
	set xland_header:style:height to 20.
	
		set xland_title to xland_header:addlabel("<b>AUTOLAND</b>").
		set xland_title:style:fontsize to 14.
		set xland_title:style:textcolor to rgb(1.0,0.8,0.0).

	set xland_line1 to g_main_xland:addhlayout().
	set xland_line1:style:height to 15.

		set xland1_runway to xland_line1:addlabel("<b>Runway</b>").
		set xland1_runway:style:fontsize to 12.
		set xland1_runway:style:textcolor to rgb(1.0,0.8,0.0).
		set xland1_runway:style:width to 80.
		set xland1_runway_t to xland_line1:addlabel("KSC Runway 09").
		set xland1_runway_t:style:fontsize to 12.
		set xland1_runway_t:style:textcolor to rgb(0.9,0.9,0.9).

	set xland_line2 to g_main_xland:addhlayout().
	set xland_line2:style:height to 15.

		set xland2_info to xland_line2:addlabel("<b>Heading</b>").
		set xland2_info:style:fontsize to 12.
		set xland2_info:style:textcolor to rgb(1.0,0.8,0.0).
		set xland2_info:style:width to 80.
		set xland2_info_hdg to xland_line2:addlabel("090deg").
		set xland2_info_hdg:style:fontsize to 12.
		set xland2_info_hdg:style:textcolor to rgb(0.9,0.9,0.9).
		set xland2_info_hdg:style:width to 70.

	set xland_line3 to g_main_xland:addhlayout().
	set xland_line3:style:height to 15.

		set xland3_distance to xland_line3:addlabel("<b>Distance</b>").
		set xland3_distance:style:fontsize to 12.
		set xland3_distance:style:textcolor to rgb(1.0,0.8,0.0).
		set xland3_distance:style:width to 80.
		set xland3_distance_t to xland_line3:addlabel("103km").
		set xland3_distance_t:style:fontsize to 12.
		set xland3_distance_t:style:textcolor to rgb(0.9,0.9,0.9).

	set xland_line4 to g_main_xland:addhlayout().
	set xland_line4:style:height to 15.
	set xland_line4:style:margin:bottom to 10.

		set xland4_approach to xland_line4:addlabel("<b>Approach</b>").
		set xland4_approach:style:fontsize to 12.
		set xland4_approach:style:textcolor to rgb(1.0,0.8,0.0).
		set xland4_approach:style:width to 80.
		set xland4_pit to xland_line4:addlabel("-3000m").
		set xland4_pit:style:fontsize to 12.
		set xland4_pit:style:textcolor to rgb(0.9,0.9,0.9).
		set xland4_pit:style:width to 70.
		set xland4_hdg to xland_line4:addlabel("+137.5deg").
		set xland4_hdg:style:fontsize to 12.
		set xland4_hdg:style:textcolor to rgb(0.9,0.9,0.9).
		//set xland4_hdg:style:width to 50.

g_main_xland:hide().


// GUI FOR NAV INFORMATION
set g_main_xnav to g_main:addvbox().
set g_main_xnav:style:margin:top to 3.

	set xnav_header to g_main_xnav:addhlayout().
	set xnav_header:style:height to 20.
	
		set xnav_title to xnav_header:addlabel("<b>NAVIGATION</b>").
		set xnav_title:style:fontsize to 14.
		set xnav_title:style:textcolor to rgb(1.0,0.8,0.0).

	set xnav_line1 to g_main_xnav:addhlayout().
	set xnav_line1:style:height to 15.

		set xnav1_route to xnav_line1:addlabel("<b>Route</b>").
		set xnav1_route:style:fontsize to 12.
		set xnav1_route:style:textcolor to rgb(1.0,0.8,0.0).
		set xnav1_route:style:width to 80.
		set xnav1_route_t to xnav_line1:addlabel("KSC to Island Airfield").
		set xnav1_route_t:style:fontsize to 12.
		set xnav1_route_t:style:textcolor to rgb(0.9,0.9,0.9).

	set xnav_line2 to g_main_xnav:addhlayout().
	set xnav_line2:style:height to 15.

		set xnav2_distance to xnav_line2:addlabel("<b>Distance</b>").
		set xnav2_distance:style:fontsize to 12.
		set xnav2_distance:style:textcolor to rgb(1.0,0.8,0.0).
		set xnav2_distance:style:width to 80.
		set xnav2_distance_t to xnav_line2:addlabel("103km").
		set xnav2_distance_t:style:fontsize to 12.
		set xnav2_distance_t:style:textcolor to rgb(0.9,0.9,0.9).

	set xnav_line3 to g_main_xnav:addhlayout().
	set xnav_line3:style:height to 15.
	set xnav_line3:style:margin:bottom to 10.

		set xnav3_time to xnav_line3:addlabel("<b>ETA</b>").
		set xnav3_time:style:fontsize to 12.
		set xnav3_time:style:textcolor to rgb(1.0,0.8,0.0).
		set xnav3_time:style:width to 80.
		set xnav3_time_t to xnav_line3:addlabel("11h 58min 17s").
		set xnav3_time_t:style:fontsize to 12.
		set xnav3_time_t:style:textcolor to rgb(0.9,0.9,0.9).

g_main_xnav:hide().




// GUI For editing aircraft load parameters
set g_planeconfig to gui(0).
set g_planeconfig:x to 320.
set g_planeconfig:y to 50.
set g_planeconfig:style:padding:h to 5.
set g_planeconfig:style:padding:v to 5.
set g_planeconfig:style:bg to "KK_ap/g3_bg.png".

set planecfg_xhead to g_planeconfig:addhbox().
		
	// route editor logo
	set planecfg_logo to planecfg_xhead:addlabel("").
	set planecfg_logo:style:bg to "KK_ap/g3_airplaneConfig.png".
	set planecfg_logo:style:width to 25.

	// route editor label
	set planecfg_lHead to planecfg_xhead:addlabel("<b>Airplane Config</b>").
	set planecfg_lHead:style:textcolor to rgb(1.0,0.8,0.0).
	set planecfg_lHead:style:width to 105.	
	set planecfg_lHead:style:height to 25.
	set planecfg_lHead:style:align to "center".
	set planecfg_lHead:style:fontsize to 13.

	// exit button
	set planecfg_bExit to planecfg_xhead:addbutton("").
	set planecfg_bExit:style:bg to "KK_ap/g3_button_close.png".
	set planecfg_bExit:style:on:bg to "KK_ap/g3_button_close.png".
	set planecfg_bExit:style:hover:bg to "KK_ap/g3_button_close.png".
	set planecfg_bExit:style:hover_on:bg to "KK_ap/g3_button_close.png".
	set planecfg_bExit:style:active:bg to "KK_ap/g3_button_close.png".
	set planecfg_bExit:style:active_on:bg to "KK_ap/g3_button_close.png".
	set planecfg_bExit:style:width to 25.
	set planecfg_bExit:style:height to 25.
	//set planecfg_bExit:style:margin:top to 11.
	set planecfg_bExit:onclick to { g_planeconfig:hide(). set g_planeconfig_show to false.}.

clearscreen.
set planecfg_xMain to g_planeconfig:addvbox().
set planecfg_xMain:style:margin:top to 3.

	set planecfg_xMain_top to planecfg_xMain:addhlayout().

		set planecfg_l to planecfg_xMain_top:addvlayout().
		set planecfg_l:style:width to 120.
			
			set planecfg_lHeight to planecfg_l:addlabel("<b>Height [m]</b>").
			set planecfg_lHeight:style:fontsize to 11.
			set planecfg_lHeight:style:textcolor to rgb(0.9,0.9,0.9).
			set planecfg_lHeight:style:height to 14.

			set planecfg_lThrrev to planecfg_l:addlabel("<b>Thrust Reverse</b>").
			set planecfg_lThrrev:style:fontsize to 11.
			set planecfg_lThrrev:style:textcolor to rgb(0.9,0.9,0.9).
			set planecfg_lThrrev:style:height to 14.

			set planecfg_lVMin to planecfg_l:addlabel("<b>Min Speed [m/s]</b>").
			set planecfg_lVMin:style:fontsize to 11.
			set planecfg_lVMin:style:textcolor to rgb(0.9,0.9,0.9).
			set planecfg_lVMin:style:height to 14.

			set planecfg_lVMax to planecfg_l:addlabel("<b>Max Speed [m/s]</b>").
			set planecfg_lVMax:style:fontsize to 11.
			set planecfg_lVMax:style:textcolor to rgb(0.9,0.9,0.9).
			set planecfg_lVMax:style:height to 14.

			set planecfg_lPit to planecfg_l:addlabel("<b>Pitch Limit (+-) [deg]</b>").
			set planecfg_lPit:style:fontsize to 11.
			set planecfg_lPit:style:textcolor to rgb(0.9,0.9,0.9).
			set planecfg_lPit:style:height to 14.

			set planecfg_lRol to planecfg_l:addlabel("<b>Roll Limit (+-) [deg]</b>").
			set planecfg_lRol:style:fontsize to 11.
			set planecfg_lRol:style:textcolor to rgb(0.9,0.9,0.9).
			set planecfg_lRol:style:height to 14.

			set planecfg_lTang to planecfg_l:addlabel("<b>Takeoff Angle [deg]</b>").
			set planecfg_lTang:style:fontsize to 11.
			set planecfg_lTang:style:textcolor to rgb(0.9,0.9,0.9).
			set planecfg_lTang:style:height to 14.

			set planecfg_lTang2 to planecfg_l:addlabel("<b>Takeoff Climb [deg]</b>").
			set planecfg_lTang2:style:fontsize to 11.
			set planecfg_lTang2:style:textcolor to rgb(0.9,0.9,0.9).
			set planecfg_lTang2:style:height to 14.		

		set planecfg_t to planecfg_xMain_top:addvlayout().

			set planecfg_tHeight to planecfg_t:addtextfield("0").
			set planecfg_tHeight:style:height to 14.
			set planecfg_tHeight:style:width to 50.
			set planecfg_tHeight:style:fontsize to 9.
			set planecfg_tHeight:style:margin:bottom to 0.
			set planecfg_tHeight:onconfirm to { parameter val. set height to val:tonumber(0).}.

			set planecfg_tThrrev to planecfg_t:addpopupmenu().
			set planecfg_tThrrev:options to list("Yes","No").
			set planecfg_tThrrev:index to 0.
			set planecfg_tThrrev:style:height to 14.
			set planecfg_tThrrev:style:width to 50.	
			set planecfg_tThrrev:style:fontsize to 9.
			set planecfg_tThrrev:onchange to 
			{
				parameter val. 
				if planecfg_tThrrev:index = 0
				{
					set thrreverse to 1.
				}
				else
				{
					set thrreverse to 0.
				}
			}.

			set planecfg_tVMin to planecfg_t:addtextfield("0").
			set planecfg_tVMin:style:height to 14.
			set planecfg_tVMin:style:width to 50.
			set planecfg_tVMin:style:fontsize to 9.
			set planecfg_tVMin:style:margin:bottom to 0.
			set planecfg_tVMin:onconfirm to { parameter val. set minspeed to val:tonumber(0).}.

			set planecfg_tVMax to planecfg_t:addtextfield("0").
			set planecfg_tVMax:style:height to 15.
			set planecfg_tVMax:style:width to 50.
			set planecfg_tVMax:style:fontsize to 9.
			set planecfg_tVMax:style:margin:bottom to 0.
			set planecfg_tVMax:onconfirm to { parameter val. set maxspeed to val:tonumber(0).}.

			set planecfg_tPit to planecfg_t:addtextfield("0").
			set planecfg_tPit:style:height to 15.
			set planecfg_tPit:style:width to 50.
			set planecfg_tPit:style:fontsize to 9.
			set planecfg_tPit:style:margin:bottom to 0.
			set planecfg_tPit:onconfirm to { parameter val. set vAP_BoundPitchAngle to val:tonumber(0).}.

			set planecfg_tRol to planecfg_t:addtextfield("0").
			set planecfg_tRol:style:height to 14.
			set planecfg_tRol:style:width to 50.
			set planecfg_tRol:style:fontsize to 9.
			set planecfg_tRol:style:margin:bottom to 0.
			set planecfg_tRol:onconfirm to { parameter val. set vAP_boundRollAngle to val:tonumber(0).}.

			set planecfg_tTang to planecfg_t:addtextfield("0").
			set planecfg_tTang:style:height to 14.
			set planecfg_tTang:style:width to 50.
			set planecfg_tTang:style:fontsize to 9.
			set planecfg_tTang:style:margin:bottom to 0.
			set planecfg_tTang:onconfirm to { parameter val. set vTakeOffAngle to val:tonumber(0).}.

			set planecfg_tTang2 to planecfg_t:addtextfield("0").
			set planecfg_tTang2:style:height to 14.
			set planecfg_tTang2:style:width to 50.
			set planecfg_tTang2:style:fontsize to 9.
			set planecfg_tTang2:style:margin:bottom to 0.
			set planecfg_tTang2:onconfirm to { parameter val. set vAfterTakeOffAngle to val:tonumber(0).}.
	

g_main:show().


//-------------------------------------------------------------------------------------------------------------
//__ F U N C T I O N S __

// Determines and calculates all the required values for the AP to work
set deltaT to 0.
set last_airspeed to 0.
set last_vPitch to 0.
set last_vFacingPitch to 0.
set last_vAngleOfAttack to 0.
set last_vFacingHeading to 0.
set last_vFacingRoll to 0.
set last_verticalspeed to 0.
set last_liquidfuel to 0.
set last_vVelHeading to 0.
set last_latitude to 0.
set last_longitude to 0.
set last_altitude to 0.

set last_time to time:seconds.
set deltaT to 1.

set acceleration_settime to 0.
set vPitchRate_settime to 0.
set vFacingPitch_settime to 0.
set vAngleOfAttack_settime to 0.
set vFacingHeading_settime to 0.
set vFacingRoll_settime to 0.
set vVerticalSpeed_settime to 0.
set vLqf_settime to 0.
set vVelHeading_settime to 0.
function INPUT
{
	local t0 is time:seconds.

	global vAcceleration is (airspeed - last_airspeed) / (time:seconds - acceleration_settime).
	set acceleration_settime to time:seconds.
	global vPitch is arcsin( verticalspeed / airspeed ).
	global vPitchRate is (vPitch - last_vPitch) / (time:seconds - vPitchRate_settime).
	set vPitchRate_settime to time:seconds.
	global vFacingPitch is 90 - vectorangle( up:forevector, facing:forevector ).	// DEG
	global vFacingPitchRate is (vFacingPitch - last_vFacingPitch) / (time:seconds - vFacingPitch_settime).
	set vFacingPitch_settime to time:seconds.
	global vAngleOfAttack is vFacingPitch - vPitch.
	global vAngleOfAttackRate is (vAngleOfAttack - last_vAngleOfAttack) / (time:seconds - vAngleOfAttack_settime).
	set vAngleOfAttack_settime to time:seconds.
	global vFacingHeading is mod(360 - latlng(90,0):bearing,360).
	global vFacingHeadingRate is (vFacingHeading - last_vFacingHeading) / (time:seconds - vFacingHeading_settime).
	set vFacingHeading_settime to time:seconds.
	if round(vFacingHeadingRate,1) = 0 { global vTurnRadius is 0. global vTurnAcceleration is 0.}
	else { global vTurnRadius is airspeed * (360 / abs(vFacingHeadingRate)) / 2 * constant:pi / 8. global vTurnAcceleration is airspeed^2 / vTurnRadius.}
	global vFacingRoll is arctan2( ship:facing:upvector:normalized * vxcl( vxcl( ship:facing:vector,ship:up:vector ):normalized,vcrs( vxcl( ship:facing:vector,ship:up:vector ):normalized,ship:facing:vector ) ):normalized, ship:facing:upvector:normalized * vxcl( ship:facing:vector,ship:up:vector ):normalized:normalized ).
	global vFacingRollRate is (vFacingRoll - last_vFacingRoll) / (time:seconds - vFacingRoll_settime).
	set vFacingRoll_settime to time:seconds.
	global vVerticalSpeedRate is (verticalspeed - last_verticalspeed) / (time:seconds - vVerticalSpeed_settime).
	set vVerticalSpeed_settime to time:seconds.
	global vGroundSpeed is abs((airspeed^2-abs(verticalspeed)^2)^0.5).	// m/s
	global vVelHeading is getVelHeading().
	global vVelHeadingRate is (vVelHeading - last_vVelHeading) / (time:seconds - vVelHeading_settime).
	set vVelHeading_settime to time:seconds.
	global dGeoLat is (latitude - last_latitude) / deltaT.
	global dGeoLng is (longitude - last_longitude) / deltaT.

	set last_airspeed to airspeed.
	set last_vPitch to vPitch.
	set last_vFacingPitch to vFacingPitch.
	set last_vAngleOfAttack to vAngleOfAttack.
	set last_vFacingHeading to vFacingHeading.
	set last_vFacingRoll to vFacingRoll.
	set last_verticalspeed to verticalspeed.
	set last_vVelHeading to vVelHeading.
	set last_latitude to latitude.
	set last_longitude to longitude.

	//print "INPUT Update Time: " + round(time:seconds-t0,3) + "s     " at (0,2).
}

function getVelHeading	// found on reddit
{
	local north_ is SHIP:NORTH:VECTOR.  
	local up_ is SHIP:UP:VECTOR.  
	local east_ is VECTORCROSSPRODUCT(up_, north_):NORMALIZED.  
	local northVel_ is VECTORDOTPRODUCT(SHIP:VELOCITY:SURFACE, north_).  
	local eastVel_ is VECTORDOTPRODUCT(SHIP:VELOCITY:SURFACE, east_).  
	local velHeading_ is ARCTAN2(eastVel_, northVel_). //-180 to 180 deg. 0 deg = north.  
	local velHeading2_ is MOD(velHeading_ + 360, 360). //0 to 360 deg. 0 deg = north. 
	
	return velHeading2_. 	
}

set vMaintainClimbRate_totalerror to 0.
set vMaintainClimbRate_lastFacingPitchRate to 0.
set last_error to 0.
set vMaintainClimbRate_OscDamper to 1.0.
set vMaintainClimbRate_OscDamper_lastSpeed to 0.
set vMaintainClimbRate_OscDamper_lastValue to vMaintainClimbRate_OscDamper.
// Maintains a given pitch velocity vector
function MAINTAINVP
{
	parameter pTarget.	// target velocity pitch [deg]

	local t0 is time:seconds.
	IF vPitch >= 2 and alt:radar-height > 500 { SET modifier to min(max(airspeed / (minSpeed*1.25),0.1),1).}
	ELSE set modifier to 1.
	local error is pTarget * modifier - vPitch.
	set t_pit:text to (round(sin(pTarget * modifier)*airspeed*60/100)*100):tostring().

	local AoA_multiplier is 1.0.
	local Pitch_multiplier is 1.0.

	local vAoA_p is vAngleOfAttack * (-0.05) * AoA_multiplier.
	local vAOA_d to vAngleOfAttackRate * (-0.01) * AoA_multiplier.

	local vPitch_p is error * 0.02 * Pitch_multiplier.
	local vPitch_d is vPitchRate * (-0.002) * Pitch_multiplier.
	local vPitch_i is vMaintainClimbRate_totalerror * 0.00005 * Pitch_multiplier.


	// + ERROR: We need to pitch up! + vPITCHRATE: Pitching up!
	local base is 0.4. // 0.4
	local bound is 0.01. // 0.025
	if vPitchRate <= error * (base-bound)
	{
		set vMaintainClimbRate_totalerror to vMaintainClimbRate_totalerror + min(max(24000 * abs(vPitch_p) * vMaintainClimbRate_OscDamper,-1600),1600).	// 8000
	}
	else if vPitchRate >= error * (base+bound)
	{
		set vMaintainClimbRate_totalerror to vMaintainClimbRate_totalerror - min(max(24000 * abs(vPitch_p) * vMaintainClimbRate_OscDamper,-1600),1600).
	}


	if vFacingPitchRate > 0.5 and vMaintainClimbRate_lastFacingPitchRate < -0.5 or vFacingPitchRate < - 0.5 and vMaintainClimbRate_lastFacingPitchRate > 0.5
	{
		set vMaintainClimbRate_OscDamper to max(vMaintainClimbRate_OscDamper - 0.04,0.05).
		set vMaintainClimbRate_OscDamper_lastSpeed to airspeed.
		set vMaintainClimbRate_OscDamper_lastValue to vMaintainClimbRate_OscDamper.
	}
	else
	{
		if vMaintainClimbRate_OscDamper_lastSpeed > 5
		{
			//set vMaintainClimbRate_OscDamper to max(min(vMaintainClimbRate_OscDamper + 0.0005,1.25*(vMaintainClimbRate_OscDamper_lastSpeed / max(airspeed,1) * vMaintainClimbRate_oscDamper_lastValue)),0.05).
			set vMaintainClimbRate_OscDamper to min(vMaintainClimbRate_OscDamper + 0.001,1).
		}
	}

	local out is (vPitch_p*vMaintainClimbRate_OscDamper+vPitch_d*vMaintainClimbRate_OscDamper+vPitch_i)+(vAoA_p+vAoA_d)*vMaintainClimbRate_OscDamper.

	set vMainTainClimbRate_totalerror to min(max(vMainTainClimbRate_totalerror + error,-20000),20000).
	set vMaintainClimbRate_lastFacingPitchRate to vFacingPitchRate.
	set last_error to error.

	print "Pitch Osc Damper: " + round(vMaintainClimbRate_OscDamper,2) + "     " at (0,25).

	if SAS = 0 { set ship:control:pitch to out.}
	else set ship:control:neutralize to true.

	//print "MAINTAINCLIMBRATE Update Time: " + round(time:seconds - t0,3) + "s     " at (0,3).
}

set vMaintainClimbRate_OscFrequency to 0.
set vMaintainClimbRate_OscCount to 0.
// Maintains a given facing pitch velocity vector
function MAINTAINFP
{
	parameter pTarget.	// target pitch facing [deg]
	local error is pTarget - vFacingPitch.

	local AoA_multiplier is 0.0.
	local Pitch_multiplier is 1.0.
	local vAoA_p is vAngleOfAttack * (-0.02) * AoA_multiplier.
	local vAOA_d to vAngleOfAttackRate * (-0.002) * AoA_multiplier.
	local vPitch_p is error * 0.02 * Pitch_multiplier.
	local vPitch_d is vFacingPitchRate * (-0.002) * Pitch_multiplier.
	local vPitch_i is vMaintainClimbRate_totalerror * 0.00005.
	
	// + ERROR: We need to pitch up! + vPITCHRATE: Pitching up!
	local base is 0.4.
	local bound is 0.01.
	if vPitchRate <= error * (base-bound)
	{
		set vMaintainClimbRate_totalerror to vMaintainClimbRate_totalerror + min(max(24000 * abs(vPitch_p),-400),400).	// 8000
	}
	else if vPitchRate >= error * (base+bound)
	{
		set vMaintainClimbRate_totalerror to vMaintainClimbRate_totalerror - min(max(24000 * abs(vPitch_p),-400),400).
	}

	if vFacingPitchRate > 1.0 and vMaintainClimbRate_lastFacingPitchRate < -1.0 or vFacingPitchRate < -1.0 and vMaintainClimbRate_lastFacingPitchRate > 1.0
	{
		set vMaintainClimbRate_OscCount to vMaintainClimbRate_OscCount + 1.	
	}
	set vMaintainClimbRate_OscFrequency to vMaintainClimbRate_OscCount / (time:seconds - starttime).
	set vMaintainClimbRate_OscDamper to 1 / (vMaintainCLimbRate_OscFrequency+1).

	local vPitchOut is min(max(vPitch_p + vPitch_d + vPitch_i,-2),2).
	local vAoAOut is (vAoA_p + vAoA_d) * vMaintainClimbRate_OscDamper.
	local out is vPitchOut + vAoAOut.

	set vMainTainClimbRate_totalerror to min(max(vMainTainClimbRate_totalerror + error,-20000),20000).
	set vMaintainClimbRate_lastFacingPitchRate to vFacingPitchRate.

	if SAS = 0 { set ship:control:pitch to out.}
	else set ship:control:neutralize to true.
}

// Outputs a pitch angle for MAINTAINVP to hold to reach the target altitude
set p to 0.
function HOLDALTITUDE
{
	parameter pTarget.	// in m above sea level
	local mode is 0. // 0 = normal altitude, 1 = srf altitude
	if mode = 0
	{
		set p to (pTarget - altitude) * 0.05.
	}
	else
	{
		set p to (pTarget - alt:radar) * 0.1.
	}
	local angle is arcsin(min(max(p/airspeed,-1),1)).
	local out is min(max(angle,-vAP_BoundPitchAngle),vAP_BoundPitchAngle).
	
	MAINTAINVP(out).
}


set last_R_rateError to 0.
set last_R_rateError_settime to 0.
set rollP_total to 0.
//set last_vFacingRollRate to 0.
set last_degError to 0.
set roll_oscDamper to 1.0.
set roll_oscDamper_lastSpeed to 0.
set roll_oscDamper_lastValue to roll_oscDamper.
set holdhdg_p_total to 0.
function MAINTAINHEADING
{
	parameter pTarget.	// Heading target [deg]
	local hdg_error is pTarget - vVelHeading.
	if hdg_error > 180
	{
		set hdg_error to hdg_error - 360.
	}
	else if hdg_error < -180
	{
		set hdg_error to hdg_error + 360.
	}
	local hdg_p is hdg_error * 5.0.
	local hdg_d is vVelHeadingRate * (-5.0).
	local hdg_i is holdhdg_p_total * 0.01.
	local hdg_angle is max(min(hdg_p + hdg_d + hdg_i,vAP_boundRollAngle),-vAP_boundRollAngle).
	if vVelHeadingRate > -0.2 and vVelHeadingRate < 0.2 and abs(hdg_angle-vFacingRoll) < 5
	{
		set holdhdg_p_total to holdhdg_p_total + hdg_p.
	}
	set holdhdg_p_total to holdhdg_p_total * 0.998.
	local hdg_rollTarget is hdg_angle.


	local pTarget_rollMultiply is max(min((alt:radar-height) * 0.05,1.0),0.0).
	local yawMultiply is 1 - pTarget_rollMultiply.

	local R_degError is hdg_rollTarget * pTarget_rollMultiply - vFacingRoll.
	local R_targetRollRate is R_degError * 1.0.
	local R_rateError is R_targetRollRate - vFacingRollRate.
	if (time:seconds - last_R_rateError_settime) > 0
	{
		set R_rateError_change to (R_rateError - last_R_rateError) / (time:seconds - last_R_rateError_settime).
	}
	else
	{
		set R_rateError_change to 0.
	}
	local roll_p is R_rateError * 0.02.
	local roll_d is R_rateError_change * 0.0005 * 0.0.
	local roll_i is rollP_total * 0.01.
	// I
	if vFacingRollRate > -1 and vFacingRollRate < 1
	{
		set rollP_total to max(min(rollP_total + roll_p,100),-100).
	}
	if R_degError > -0.2 and R_degError < 0.2
	{
		set rollP_total to rollP_total * 0.999.
	}
	// OSC DAMPER
	//if vFacingRollRate > 0.4 and last_vFacingRollRate < -0.4 or vFacingRollRate < -0.4 and last_vFacingRollRate > 0.4
	if R_rateError > 0.5 and last_R_rateError < -0.5 or R_rateError < -0.5 and last_R_rateError > 0.5
	{
		set roll_oscDamper to max(roll_oscDamper - 0.04,0.025).
		set roll_oscDamper_lastSpeed to airspeed.
		set roll_oscDamper_lastValue to roll_oscDamper.
	}
	else
	{
		if roll_oscDamper_lastSpeed > 5
		{
			set roll_oscDamper to min(roll_oscDamper + 0.00025,1).
		}
	}
	
	print "Roll Osc Damper: " + round(roll_oscDamper,3) + "     " at (0,26).


	SET roll_output to roll_p * roll_oscDamper + roll_d * roll_oscDamper + roll_i.


	set last_R_rateError to R_rateError.
	set last_R_rateError_settime to time:seconds.
	set last_R_degError to R_degError.
	

	local Y_error is pTarget - vVelHeading.
	if Y_error > 180
	{
		set Y_error to Y_error - 360.
	}
	else if Y_error < -180
	{
		set Y_error to Y_error + 360.
	}
	local Y_p is Y_error * 0.04.
	local Y_d is (-0.0125) * vVelHeadingRate.
	local Y_out is max(min(Y_p + Y_d,1),-1) * yawMultiply.
	
	
	

	if sas = 0 
	{ 
		set ship:control:roll to roll_output.
		set ship:control:yaw to (Y_out + 2*ship:control:pilotyaw) * 2.0.	// + is r, - is l
		set ship:control:wheelsteer to (Y_out + 2*ship:control:pilotyaw) * (-0.5).	// + is l, - is r
	}
	if sas = 1 { set ship:control:neutralize to true.}
}


// RETURNS pitch angle for the plane to maintain
// NOTE that this function already uses runwayterrainheight and plane height, no need to add that in the offset parameters!
set autoland_glideslope_lastError_settime to 0.
set altitudeError_total to 0.
function autoland_glideslope
{
	parameter pDeg.	// Glideslope target in degrees (sign "-" = descending, sign "+" = ascending)
	parameter pO_x.	// Ground distance from runway in m (sign "+" = "behind" the runway (from plane), sign "+" = "before" runway (from plane))
	parameter pO_y.	// Altitude offset from runway in m (sign "-" = above runway, sign "-" = below runway

	local x is 0.
	local glideslopeAltitude is -tan(pDeg) * (max(grounddistance+x - pO_x,0)) + runwaypos:terrainheight + height + pO_y.
	global altitudeError is glideslopeAltitude - altitude.	// global to show it on the screen (in the textfield)
	local altitudeError_p is altitudeError * 0.04. // 0.04
	local altitudeError_d is (altitudeError - autoland_glideslope_lastError) / (time:seconds - autoland_glideslope_lastError_settime) * 0.05.
	local altitudeError_i is altitudeError_total * 0.004.
	set autoland_glideslope_lastError to altitudeError.
	set autoland_glideslope_lastError_settime to time:seconds.
	if altitudeError > - 20 and altitudeError < 20 and grounddistance < flareDistance/2
	{
		set altitudeError_total to max(min(altitudeError_total + altitudeError,1/0.005),-1/0.0005).
	}
	if altitudeError > -1 and altitudeError < 1
	{
		set altitudeError_total to altitudeError_total * 0.99.
	}
	if altitudeError > 2 and altitudeError_total < 0
	{
		set altitudeError_total to altitudeError_total * 0.5.
	}

	local autoland_glideslope_out is altitudeError_p + altitudeError_d + altitudeError_i.
	local angle_out is max(min(pDeg + min(max(autoland_glideslope_out,-25),25),vAP_BoundPitchAngle),-vAP_boundPitchAngle).

	return angle_out.
}



set lnd_touchdowntime to 0.
set lnd_touchdowntime_set to false.
set landingabort to false.
set runway_reached to false.
function autoland
{
	parameter p.
	set runway_number to p.
	SET targetrunway to runway_database[p].
	SET p2 to p + (-1)^p.
	SET counterrunway to runway_database[p2].
	
	SET runwayheading to targetrunway[2].
	SET runwaypos to targetrunway[1].

	if autoland_targetmode = "wp"
	{
		set wp_centerline_offset to 0.25.
		set wp_centerline_lat to runwaypos:lat - cos(runwayheading) * wp_centerline_offset.
		set wp_centerline_lng to runwaypos:lng - sin(runwayheading) * wp_centerline_offset.
		set wp_centerline to latlng(wp_centerline_lat,wp_centerline_lng).

		set autoland_target_lat to wp_centerline_lat.
		set autoland_target_lng to wp_centerline_lng.

		if (wp_centerline:distance^2-altitude^2)^0.5 < 1000
		{
			set autoland_targetmode to "rnw".
		}
	}
	else if autoland_targetmode = "rnw"
	{
		set autoland_target_lat to runwaypos:lat.
		set autoland_target_lng to runwaypos:lng.
	}
	
	SET grounddistance to max(runwaypos:distance^2 - (altitude - runwaypos:terrainheight)^2,0.0001)^0.5.
	local grounddistance_settime is time:seconds.

	set dlat to latitude - autoland_target_lat.
	set dlng to longitude - autoland_target_lng.
	if dlng < 0 { set alpha to 90 - arctan(dlat / dlng).}	// alpha is the absolute heading the plane needs to fly to reach the runway
	else  { set alpha to 270 - arctan(dlat / dlng).}
	set beta to alpha-runwayheading.	// beta is the difference in heading between alpha and the runwayheading
	set headingtarget to alpha + beta.
	if headingtarget < 0 {set headingtarget to headingtarget + 360.}
	
	//set flareDistance to 5000. // Distance in m from runway where plane should start the flaring; 5000
	set appr_final_pitch to arcsin(appr_final_verticalspeed/max(airspeed,0.001)).
	set flare_multiplier to max(min(grounddistance/flareDistance,1.0),0.0).
	set lnd_glideslope to min(flare_multiplier*glideslopetarget,appr_final_pitch).
	set offsetFactor_x to (-1) * (-5/glideslopetarget)*(flareDistance/10).
	set lnd_offset_x to min((lnd_glideslope - appr_final_pitch) * offsetFactor_x,flareDistance/2).

	set targetangle to autoland_glideslope(lnd_glideslope,lnd_offset_x,0).

	set distance_d to (lastdistance - grounddistance) / lag.
	set distance_eta to grounddistance / distance_d.	// min
	set avg_eta to grounddistance / ( (distance_d + airspeed + minSpeed) / 3).
	set lastdistance to grounddistance.
	set lastdistance_settime to time:seconds.

	local speed_established is 4000.	// distance from runway where touchdown velocity should be reached
	set approachspeed to min( ( 1 + max((grounddistance-speed_established)/10000,0) ) * minspeed,maxSpeed).
	

	if grounddistance < 100 and runway_reached = false
	{
		set runway_reached to true.
	}
	if (alt:radar-height) < 1 and autoland_mode <> "landed" and runway_reached = true
	{
		set autoland_mode to "landed".
		if thrreverse = 1
		{		
			ag4 on.	
			lock throttle to 1.
		}
		else
		{
			lock throttle to 0.
			brakes on.
		}
	}

	if autoland_mode = "landed"
	{
		set targetangle to -2.
		if lnd_touchdowntime_set = false
		{
			set lnd_touchdowntime to time:seconds.
			set lnd_touchdowntime_set to true.
		}
		if (time:seconds - lnd_touchdowntime) > 5
		{
			local stop_brakeTime is airspeed / abs(vAcceleration).
			local stop_distance is abs(vAcceleration)/2 * stop_brakeTime^2.
			local stop_timeToRunwayEnd is (2*counterrunway[1]:distance/abs(vAcceleration))^0.5.
			local final_speed is airspeed - abs(vAcceleration) * stop_timeToRunwayEnd.

			local acc_time is (minSpeed - airspeed) / 2.
			local acc_distance is 2/2 * acc_time^2.
			print "Brake distance: " + round(stop_distance) + "m     " at (0,30).
			print "Remaining Runway: " + round(counterrunway[1]:distance) + "m     " at (0,31).
			print "Diff: " + round(counterrunway[1]:distance - stop_distance) + "m     " at (0,32).
			print "final_speed: " + round(final_speed) + "m/s     " at (0,33).
			print "acc_distance: " + round(acc_distance) + "m     " at (0,34).
			if (counterrunway[1]:distance - stop_distance) < 0 and final_speed > 30 and (counterrunway[1]:distance - (2/2 * ((minSpeed - airspeed) / 2)^2)) > 0
			{
				set abortreason2_count to abortreason2_count + 1.
				if abortreason2_count < 3	// if this would be the third abort at the same runway due to the same reason
				{
					set landingabort to true.
				}
				else
				{
					HUDTEXT("<AP> Ignoring Go Around Trigger", 3, 2, 18, red, false).
				}
				set abortreason to 2.	// 2 = not enough runway remaining, too high landing speed?
			}
		}

		MAINTAINHEADING(targetWP_hdg).
		if airspeed < 15
		{
			lock throttle to 0.
			brakes on.
			if airspeed < 5
			{
				if ag4 = true
				{
					ag4 off.
				}
			}
		}
		
	}

	// WARP CONTROL
	if warp > 0
	{
		if grounddistance < 10000 and grounddistance >= 6000 and warp > 2
		{
			set warp to 2.
		}
		else if grounddistance < 6000 and grounddistance >= 3000 and warp > 1
		{
			set warp to 1.
		}
		else if grounddistance < 3000 and warp > 0
		{
			set warp to 0.
		}
	}
	

	if grounddistance < 750 and autoland_headingmode <> 1
	{
		set autoland_headingmode to 1.
	}


	set targetWP to list(counterrunway[0],counterrunway[1]).
	set targetWP_hdg to FLYTOWAYPOINT(targetWP).

	if autoland_mode <> "flare" and autoland_mode <> "landed"
	{
		AUTOTHROTTLE(approachspeed).
	}
	if autoland_headingmode = 0
	{
		MAINTAINHEADING(headingtarget).
	}
	else if autoland_headingmode = 1
	{
		MAINTAINHEADING(targetWP_hdg).
	}
	if grounddistance <= gearDeployDistance
	{
		if gear = false
		{
			toggle gear.
		}
	}
	
	// L A N D I N G   A B O R T   T R I G G E R S

	
	set low to max( ((grounddistance/100) ^1.5)*0.25,1).
		print "low: " + round(low,1) + "m     " at (0,0).
		print "error: " + round(altitudeError,1) + "m     " at (0,1).
	if altitudeError > low and grounddistance < 4000 and runway_reached = false
	{
		set landingabort to true.
		set abortreason to 1.	// 1 = too low on the glideslope in the final 4km, too low speed?
	}
	if abs(vVelHeading - runwayheading) > 5 and grounddistance < 2000 and runway_reached = false
	{
		set abortreason to 3.	// too high heading error, maybe too fast to align?
		set landingabort to true.
	}

	if counterrunway[1]:distance < (1.0) * (airspeed/5)^2 and autoland_mode <> "landed"
	{
		set abortreason2_count to abortreason2_count + 1.
		if abortreason2_count < 3	// if this would be the third abort at the same runway due to the same reason
		{
			set landingabort to true.
		}
		else
		{
			HUDTEXT("<AP> Ignoring Go Around Trigger", 3, 2, 18, red, false).
		}
		set abortreason to 2.	// Missed touchdown point and flying above the runway, too high speed?; NAH: Same abortreason as for no2
	}

	if landingabort = true and landingabort_allow = 1
	{
		autoland_abort().
	}

	// Show proper values in gui
	set t_spd:text to round(approachspeed):tostring().
	set t_hdg:text to round(headingtarget):tostring().
	set t_pit:text to ( round(sin(targetangle)*airspeed*60/100)*100 ):tostring().


	MAINTAINVP(targetangle).
	
	//logDescent().
}

set logDescent_lastLog to 0.
function logDescent
{
	if (time:seconds - logDescent_lastLog) > 1
	{
		log round(grounddistance/1000,2) + "," + round(altitude-height - targetrunway[1]:terrainheight) + "," + round(altitudeError,1) + "," + round(verticalspeed,1) + "," + round(vVerticalSpeedRate,1) to log_descent.txt.
		set logDescent_lastLog to time:seconds.
	}
}

function autoland_abort
{
	if abortreason = 1
	{
		HUDTEXT("<AP> [GO AROUND] - Too low on the glideslope during final approach", 3, 2, 18, red, false).
	}
	else if abortreason = 2
	{
		HUDTEXT("<AP> [GO AROUND] - Not enough runway remaining", 3, 2, 18, red, false).
	}	
	else if abortreason = 3
	{
		HUDTEXT("<AP> [GO AROUND] - Heading misaligned during final approach", 3, 2, 18, red, false).
	}
	else if abortreason = 4
	{
		HUDTEXT("<AP> [GO AROUND] - Touchdown zone has been missed", 3, 2, 18, red, false).
	}
	set b_lnd:pressed to false.
	set autoland_abort_hdgTarget to vVelHeading.

	if ag4 = true
	{
		ag4 off.
	}
	if brakes = true
	{
		brakes off.
	}
	set flyGoAround to true.
	set TO_runway to targetrunway.
	set TO_override to true.
	set mode_tof_allow to true.
	set TO_pitchTarget to 0.
	set TO_targetWP to counterrunway.
	set TO_targetWP_hdg to vVelHeading.
	set b_tof:pressed to true.
}

function TAKEOFF
{
	if alt:radar - height < 25 and TO_targetWP[1]:distance > 200
	{
		set TO_targetWP_hdg to FLYTOWAYPOINT(TO_targetWP).
	}


	if SAS = true
	{
		SAS off.
	}
	if availablethrust = 0
	{
		stage.
		wait 0.5.
	}
	if airspeed >= vTakeOffSpeed
	{
		if alt:radar - height < 25
		{
			MAINTAINFP(vTakeOffAngle * max( ((alt:radar-height) * 0.01 + 1),1 )).
		}
		else 
		{
			MAINTAINVP(vAfterTakeOffAngle).
		}
	}
	else
	{
		MAINTAINFP(TO_pitchTarget).	
	}
	if alt:radar - height > 50 and GEAR = true
	{
		GEAR off.
	}

	MAINTAINHEADING(TO_targetWP_hdg).
	AUTOTHROTTLE(vAfterTakeOffSpeed).

	// Show correct values in gui
	set t_spd:text to round(vAfterTakeOffSpeed):tostring().
	set t_hdg:text to round(TO_targetWP_hdg):tostring().
	set t_pit:text to (round( (sin(vAfterTakeOffAngle)*airspeed*60)/100 )*100):tostring().
}


function autothrottle
{
	parameter vtarget.
	SET p to (vtarget - airspeed) * 0.2.
	SET d to vAcceleration * (-0.5).
	SET thr to min(max(p + d,0),1).

	if SAS = 0 { LOCK throttle to thr.}
	else unlock throttle.
}

function flytowaypoint
{
	parameter targetwaypoint.

	SET dlat to latitude - targetwaypoint[1]:lat.
	SET dlng to longitude - targetwaypoint[1]:lng.
	set wp_distance to max(targetwaypoint[1]:distance^2-(altitude-targetwaypoint[1]:terrainheight)^2,0.0001)^0.5.
	IF dlng < 0 { SET outputhdg to 90 - arctan(dlat / dlng).}
	ELSE  { SET outputhdg to 270 - arctan(dlat / dlng).}

	if wp_distance < 4000
	{
		set b_way:pressed to false.
		colourButton(b_hdg,0).
	}

	// Show value in gui
	set t_hdg:text to round(outputhdg):tostring().
	return outputhdg.
}

// function to find runway by it's name
function findRunwayByName
{
	parameter name.
	SET a to 0.
	UNTIL a > runway_database:length-1
	{
		IF name = runway_database[a][0]
		{
			return a.
		}
		SET a to a + 1.
	}	
}

// function to find route by it's name
function findRouteByName
{
	parameter name.
	set a to 0.
	set done to false.
	until done = true
	{
		if routes[a][0] = name
		{
			set done to true.
		}
		else
		{
			set a to a + 1.
		}
	}
	return a.
}
// function to find waypoint by it's name
function findWaypointByName
{
	parameter name.
	set a to 0.
	set done to false.
	until done = true
	{
		if waypoint_database[a][0] = name
		{
			set done to true.
		}
		else
		{
			set a to a + 1.
		}
	}
	return a.
}

// Finds the next best-suited runway to land on and returns its position in the runway_database list
function FINDRUNWAY
{
	set closestRnw to 0.
	set closestDist to runway_database[0][1]:distance.
	set i to 1.
	until i >= runway_database:length - 1
	{
		if runway_database[i][1]:distance < closestDist
		{
			set closestRnw to i.
			set closestDist to runway_database[i][1]:distance.
		}
		set i to i + 1.
	}
	return closestRnw.
}

// Checks if any suitable runway is near, if yes: 
// 	- Return true and set all variables required for takeoff
// - If no:
//	- Return false
function CHECKTAKEOFF
{
	local p is FINDRUNWAY().
	set TO_runway to runway_database[p].
	local p2 is p + (-1)^p.
	local targetRNW is runway_database[p2].
	set TO_targetWP to list(targetRNW[0],targetRNW[1]).

	if TO_runway[1]:distance < 300
	{
		set TO_headingTarget to mod(360 - latlng(90,0):bearing,360).
		set TO_pitchTarget to 90 - vectorangle( up:forevector, facing:forevector ).
		return true.	
	}
	else
	{
		return false.
	}
}

function flyroute
{
	parameter route.

	set navroute to route.
	SET dist_destination to max(route[1][route[1]:length-1][1]:distance^2-(altitude-route[1][route[1]:length-1][1]:terrainheight)^2,0.0001)^0.5.

	set nav_distance_d to (nav_lastdistance - dist_destination) / lag.
	set nav_distance_eta to dist_destination / nav_distance_d.	// s
	set nav_lastdistance to dist_destination.
	set nav_lastdistance_settime to time:seconds.

	IF mode_nav_doTakeoff = true
	{
		set b_tof:pressed to true.
		set mode_nav_doTakeoff to false.
	}

	ELSE IF route[1]:length > 1 AND flyroute_a < route[1]:length-1 // min. 1 wp & runway
	{
		SET nextwaypoint to route[1][flyroute_a].
		if flyGoAround = false
		{
			set pop_way:index to findWaypointByName(nextwaypoint[0]). // print current target waypoint as way mode parameter
		}
		MAINTAINHEADING(flytowaypoint(nextwaypoint)).
		IF wp_distance < 4000
		{
			SET flyroute_a to flyroute_a+1.
		}
	}

	ELSE // only runway (remaining)
	{
		g_main_xland:show().
		SET runwayname to route[1][route[1]:length-1][0].
		SET lnd_param to findRunwayByName(runwayname). // pass name of the runway to the function
		SET pop_lnd:index to lnd_param.
		if b_spd:pressed { set b_spd:pressed to false.}
		if b_alt:pressed { set b_alt:pressed to false.}
		if b_pit:pressed { set b_pit:pressed to false.}
		set b_lnd:pressed to true.
	}

}

// Colours the dots on the terrain radar
function terrainRadar
{
	local terrRad_distance is 2.0.
	local terrRad_width is 2.0.
	local sensitivity is 100.	// If there is less than 100m between terrainheight and your altitude, 100% RED
	local f_sens is 0.001.//(1/sensitivity)

	local t1 is time:seconds.
	//clearscreen.
	local l is terrAlt_mainscreen_layoutlabels:widgets:length.
	local c is terrAlt_mainscreen_layoutlabels:widgets[0]:widgets:length.
	local i is 0.
	until i >= l	// lines (dotrows)
	{
		local line is terrAlt_mainscreen_layoutlabels:widgets[i].
		local dot_distance is 1 - i/(l-1).
		local j is 0.
		until j >= c
		{
			local dot_width is (0.5 - j/(c-1)) * 2.
			local r is 1 - (altitude - latlng(latitude + sin(vVelHeading) * dot_width * terrRad_width + cos(vVelHeading) * dot_distance * terrRad_distance,longitude - cos(vVelHeading) * dot_width * terrRad_width + sin(vVelHeading) * dot_distance * terrRad_distance):terrainheight - sensitivity) * f_sens. // bounds are apparently not needed for rgb input
			set line:widgets[j]:style:textcolor to rgb(r,1-r,0).
			set j to j + 1.
		}
		set i to i + 1.
	}
	//print "Radar Update Time: " + round(time:seconds - t1,5) + "s     " at (0,20).
}

function colourButton
{
	parameter b.
	parameter c.

	if c = 0	// Standard
	{
		set b:style:textcolor to rgb(0.8,0.8,0.8).
		set b:style:on:textcolor to rgb(0.1,0.9,0.1).
		set b:style:hover:textcolor to rgb(1.0,0.8,0.0).
		set b:style:hover_on:textcolor to rgb(1.0,0.8,0.0).
		set b:style:active:textcolor to rgb(0.1,0.9,0.1).
		set b:style:active_on:textcolor to rgb(0.1,0.9,0.1).
		set b:style:bg to "KK_ap/button_empty_std.png".
		set b:style:on:bg to "KK_ap/button_empty_pushed.png".
		set b:style:hover:bg to "KK_ap/button_empty_hover.png".
		set b:style:hover_on:bg to "KK_ap/button_empty_hover.png".
		set b:style:active:bg to "KK_ap/button_empty_pushed.png".
		set b:style:active_on:bg to "KK_ap/button_empty_pushed.png".
	}
	if c = 1	// Disabled
	{
		set b:style:textcolor to rgb(0.6745,0.031,0).
		set b:style:on:textcolor to rgb(0.6745,0.031,0).
		set b:style:hover:textcolor to rgb(1.0,0.8,0.0).
		set b:style:hover_on:textcolor to rgb(1.0,0.8,0.0).
		set b:style:active:textcolor to rgb(0.6745,0.031,0).
		set b:style:active_on:textcolor to rgb(0.6745,0.031,0).
		set b:style:bg to "KK_ap/button_empty_disabled.png".
		set b:style:on:bg to "KK_ap/button_empty_disabled.png".
		set b:style:hover:bg to "KK_ap/button_empty_hover.png".
		set b:style:hover_on:bg to "KK_ap/button_empty_hover.png".
		set b:style:active:bg to "KK_ap/button_empty_disabled.png".
		set b:style:active_on:bg to "KK_ap/button_empty_disabled.png".
	}
	if c = 2		// Used by another function
	{
		set b:style:textcolor to rgb(0.0392,0,0.6549).
		set b:style:on:textcolor to rgb(0.0392,0,0.6549).
		set b:style:hover:textcolor to rgb(1.0,0.8,0.0).
		set b:style:hover_on:textcolor to rgb(1.0,0.8,0.0).
		set b:style:active:textcolor to rgb(0.0392,0,0.6549).
		set b:style:active_on:textcolor to rgb(0.0392,0,0.6549).
		set b:style:bg to "KK_ap/button_empty_used.png".
		set b:style:on:bg to "KK_ap/button_empty_used.png".
		set b:style:hover:bg to "KK_ap/button_empty_hover.png".
		set b:style:hover_on:bg to "KK_ap/button_empty_hover.png".
		set b:style:active:bg to "KK_ap/button_empty_used.png".
		set b:style:active_on:bg to "KK_ap/button_empty_used.png".
	}	
}
















//-------------------------------------------------------------------------------------------------------------
//__ M A I N   L O O P __

CLEARSCREEN.

set vMaintainRoll_totalerror to 0.
set vMaintainRoll_lastFacingRollRate to 0.
set vMaintainRoll_OscCount to 0.
set vMaintainRoll_OscFrequency to 0.
set vMaintainRoll_OscDamper to 0.

SET autolAND_mode to "descend".
set landingabort to 0.
set runway_reached to 0.
set holdpitch_param to 0.
set ang_totalerror to 0.
set autoland_appr_decc to 0.
set touchdowned to 0.
set autoland_phase to "       ".
set autoland_targetmode to "wp".
set autoland_headingmode to 0.
set TO_override to false.

set lastdistance to 0.
set lastdistance_settime to 1.

set autoland_mode_maintain_tAlt to -1.
set AUTO_holdroll to false.
set AUTO_holdpitch to false.

set AUTOFLY_rollTarget to 0.
set AUTOFLY_pitchTarget to 0.
set AUTOFLY_hdgTarget to 0.
set autoland_glideslope_lastError to 0.

set wp_distance to 0.
set flyroute_a to 0.
set dist_destination to 0.001.
set flyroute_landing to false.
set interface_lnd_active to false.
set nav_lastdistance to 0.
set nav_distance_eta to 0.
set flighttime_avg to 0.
set flighttime_a to 0.
set vVelHeading to 0.

set vFuel_lqf_start to ship:liquidfuel.
set vFuel_lqf_startmass to ship:mass.
set vFuel_lqf_last to ship:liquidfuel.
set vFuel_lqf_lasttime to time:seconds.
set vFuel_lqf_rate to 0.
set vFuel_lqf_time to 0.
set vFuel_lqf_time_h to 0.
set vFuel_lqf_time_min to 0.
set vFuel_lqf_time_s to 0.
set vFuel_lqf_range to 0.
set flyGoAround to false.
set abortreason2_count to 0.

set lag to 1.

set terminal:width to 50.
set terminal:height to 36.

set route to routes[0].
set navroute to routes[0].

print "Loading Aircraft Data:".
print " ".
set datLoaded to false.
set i to 0.
until i > airplaneData:length - 1 or datLoaded = true
{
	if ship:name = airplaneData[i][0]
	{
		set height to airplanedata[i][1].
		set thrreverse to airplanedata[i][2].
		set minSpeed to airplanedata[i][3].
		set maxSpeed to airplanedata[i][4].
		set approachdec to airplanedata[i][5].
		set vTakeOffSpeed to airplanedata[i][6].
		set vTakeOffAngle to airplanedata[i][7].
		set vAfterTakeOffSpeed to airplanedata[i][8].
		set vAfterTakeOffAngle to airplanedata[i][9].

		set datLoaded to true.

		print "-- Matching Data found!".
		print "-- Loading Data for " + airplaneData[i][0] + ".".
		print " ".
	}
	else set i to i + 1.
}

if datLoaded = false
{
	print "No Matching Data found!".
}

set planecfg_tHeight:text to height:tostring().
if thrreverse = 1
{
	set planecfg_tThrrev:index to 1.
}
else
{
	set planecfg_tThrrev:index to 0.
}
set planecfg_tVMin:text to minSpeed:tostring().
set planecfg_tVMax:text to maxSpeed:tostring().
//set planecfg_tApprdec:text to approachdec:tostring().
//set t_set_tospeed:text to vTakeOffSpeed:tostring().
set planecfg_tTang:text to vTakeOffAngle:tostring().
set planecfg_tTang2:text to vAfterTakeOffAngle:tostring().
//set t_set_afttospeed:text to vAfterTakeOffSpeed:tostring().
set planecfg_tPit:text to vAP_boundpitchangle:tostring().
set planecfg_tRol:text to vAP_boundrollangle:tostring().
//set t_set_gldslopetgt:text to glideslopetarget:tostring().
//set t_set_flaredistance:text to flaredistance:tostring().
//set t_set_allowlndabort:text to landingabort_allow:tostring().
//set t_set_maxalt:text to maxaltitude:tostring().
//set t_set_geardeploy:text to geardeploydistance:tostring().

print "height = " + height.
print "thrreverse = " + thrreverse.
print "minSpeed = " + minSpeed.
print "maxSpeed = " + maxSpeed.
print "approachdec = " + approachdec.
print "vTakeOffSpeed = " + vTakeOffSpeed.
print "vTakeOffAngle = " + vTakeOffAngle.
print "vAfterTakeOffSpeed = " + vAfterTakeOffSpeed.
print "vAfterTakeOffAngle = " + vAfterTakeOffAngle.
clearscreen.



set mode_spd to false.
set mode_alt to false.
set mode_hdg to false.
set mode_pit to false.
set mode_tof to false.
set mode_lnd to false.
set mode_nav to false.
set mode_way to false.
set mode_fbw to false.

set spd_param to 0.
set alt_param to 0.
set hdg_param to 0.
set pit_param to 0.
set tof_param to 0.
set lnd_param to 0.
set nav_param to 0.
set way_param to 0.


set mode_tof_allow to true.
set mode_lnd_allow to true.
set mode_nav_doTakeoff to false.
set mode_tof_enableLaterNav to false.


set b_spd:onclick to 
{ 
	toggle mode_spd. 
	if mode_spd = false	// required because if left out, controls will be locked
	{
		set ship:control:neutralize to true.
		unlock all.
	}
}.
set t_spd:onconfirm to { parameter val. set spd_param to val:tonumber(0).}.

set b_alt:onclick to 
{ 
	toggle mode_alt. 
	if mode_alt = true
	{
		if b_pit:pressed
		{
			set b_pit:pressed to false.
		}
		if b_tof:pressed
		{
			set b_tof:pressed to false.
		}
		colourButton(b_pit,2).
		if b_lnd:pressed = true
		{
			set b_lnd:pressed to false.
		}
	}
	else	// required because if left out, controls will be locked
	{
		colourButton(b_pit,0).
		set ship:control:neutralize to true.
		unlock all.
	}
}.
set t_alt:onconfirm to { parameter val. set alt_param to val:tonumber(0).}.

set b_hdg:onclick to 
{ 
	toggle mode_hdg. 
	if mode_hdg = true
	{
		if b_tof:pressed
		{
			set b_tof:pressed to false.
		}
		if b_lnd:pressed
		{
			set b_lnd:pressed to false.
		}
		if b_nav:pressed
		{
			set b_nav:pressed to false.
		}
		if b_way:pressed
		{
			set b_way:pressed to false.
		}
	}
	else	// required because if left out, controls will be locked
	{
		set ship:control:neutralize to true.
		unlock all.
	}
}.
set t_hdg:onconfirm to { parameter val. set hdg_param to val:tonumber(0).}.

set b_pit:onclick to 
{ 
	toggle mode_pit. 
	if mode_pit = true
	{
		if b_alt:pressed
		{
			set b_alt:pressed to false.
		}
		if b_tof:pressed
		{
			set b_tof:pressed to false.
		}
		if b_lnd:pressed
		{
			set b_lnd:pressed to false.
		}
	}
	else	// required because if left out, controls will be locked
	{
		set ship:control:neutralize to true.
		unlock all.
	}
}.
set t_pit:onconfirm to { parameter val. set pit_param to val:tonumber(0).}.

set b_tof:onclick to 
{
	toggle mode_tof.
	if mode_tof = true
	{
		if CHECKTAKEOFF = false and TO_override = false
		{
			set mode_tof to false.
			set b_tof:pressed to false.
			if mode_tof_allow { HUDTEXT("<AP> No available runway found", 6, 2, 18, red, false).}
			else { HUDTEXT("<AP> Auto takeoff not available", 6, 2, 18, red, false).}
		}
		else
		{
			HUDTEXT("<AP> Takeoff from " + TO_runway[0], 6, 2, 18, yellow, false).
			set mode_tof_initAlt to altitude.
			if b_spd:pressed
			{
				set b_spd:pressed to false.
			}
			if b_alt:pressed
			{
				set b_alt:pressed to false.
			}
			if b_hdg:pressed
			{
				set b_hdg:pressed to false.
			}
			if b_pit:pressed
			{
				set b_pit:pressed to false.
			}
			if b_lnd:pressed
			{
				set b_lnd:pressed to false.
			}
			if b_way:pressed
			{
				set b_way:pressed to false.
			}
			if b_nav:pressed
			{
				set b_nav:pressed to false.
				set mode_tof_enableLaterNav to true.
			}

			// COLOUR THE USED FUNCTIONS IN GUI
			colourButton(b_spd,2).
			colourButton(b_hdg,2).
			colourButton(b_pit,2).

			set TO_override to false.	// reset for the next launch if override was used
		}
	}
	if mode_tof = false
	{
		set ship:control:neutralize to true.
		unlock all.

		set TO_pitchTarget to 0.
		if mode_tof_enableLaterNav = true
		{
			set mode_tof_enableLaterNav to false.
			colourButton(b_way,2).
			colourButton(b_hdg,2).
			colourButton(b_pit,2).
			colourButton(b_spd,2).
			colourButton(b_alt,2).
			set b_nav:pressed to true.
		}	

		// COLOUR THE USED FUNCTIONS IN GUI
		colourButton(b_spd,0).
		colourButton(b_hdg,0).
		colourButton(b_pit,0).
	}
}.

set b_lnd:onclick to 
{ 
	toggle mode_lnd. 
	if mode_lnd and mode_lnd_allow
	{
		set flyGoAround to false.
		set autoland_targetmode to "wp".
		set autoland_appr_decc to 0.
		set autoland_mode to "descend".
		set landingabort to false.
		set lnd_touchdowntime_set to false.
		set autoland_headingmode to 0.
		set autoland_abort_mode to 0.
		set runway_reached to false.
		set autoland_appr_decc to 0.

		HUDTEXT("<AP> Landing on " + runway_database[lnd_param][0], 6, 2, 18, yellow, false).
		
		if b_spd:pressed
		{
			set b_spd:pressed to false.
		}
		if b_alt:pressed
		{
			set b_alt:pressed to false.
		}
		if b_hdg:pressed
		{
			set b_hdg:pressed to false.
		}
		if b_pit:pressed
		{
			set b_pit:pressed to false.
		}
		if b_tof:pressed
		{
			set b_tof:pressed to false.
		}
		if b_way:pressed
		{
			set b_way:pressed to false.
		}
		if b_nav:pressed
		{
			set b_nav:pressed to false.
		}

		g_main_xland:show().

		// COLOUR THE USED FUNCTIONS IN GUI
		colourButton(b_spd,2).
		colourButton(b_hdg,2).
		colourButton(b_pit,2).
	}
	else if mode_lnd_allow = false
	{
		HUDTEXT("<AP> Autoland not available", 6, 2, 18, red, false).
	}
	if mode_lnd = false	// required because if left out, controls will be locked
	{
		set ship:control:neutralize to true.
		unlock all.

		// COLOUR THE USED FUNCTIONS IN GUI
		colourButton(b_spd,0).
		colourButton(b_hdg,0).
		colourButton(b_pit,0).

		g_main_xland:hide().
	}
}.
set pop_lnd:onchange to
{ 
	parameter val.
	set lnd_param to findRunwayByName(val).
	if mode_lnd { HUDTEXT("<AP> Runway changed to " + runway_database[lnd_param][0], 6, 2, 18, yellow, false).}
}.

set b_nav:onclick to 
{
	toggle mode_nav.
	if mode_nav
	{
		if flyGoAround = false
		{
			flyroute(routes[nav_param]).
			set nav_altitude to round( min((dist_destination / 30000 * 1500),maxAltitude) / 100)*100.	
			set nav_speed to maxSpeed.
			HUDTEXT("<AP> Flying route " + routes[nav_param][0], 6, 2, 18, yellow, false).
		}
		else
		{
			flyroute(route_goAround).
			set nav_altitude to round( (runwaypos:terrainheight + 2000) / 100) * 100.
			set nav_speed to maxSpeed.
		}
		
		set alt_param to nav_altitude.
		set t_alt:text to nav_altitude:tostring().
		set b_alt:pressed to true.
		set b_spd:pressed to true.
		set spd_param to nav_speed.
		set t_spd:text to nav_speed:tostring().
		if (alt:radar - height) < 10 and airspeed < 20
		{
			set mode_nav_doTakeoff to true.
		}
		if b_hdg:pressed
		{
			set b_hdg:pressed to false.
		}
		if b_tof:pressed
		{
			set b_tof:pressed to false.
		}
		if b_way:pressed
		{
			set b_way:pressed to false.
		}
		g_main_xnav:show().	
		colourButton(b_way,2).
		colourButton(b_hdg,2).
		colourButton(b_pit,2).
		colourButton(b_alt,0).
	}
	if mode_nav = false
	{
		set ship:control:neutralize to true.
		unlock all.
		g_main_xnav:hide().
		colourButton(b_spd,0).
		colourButton(b_hdg,0).	
		colourButton(b_pit,0).
		colourButton(b_lnd,0).
		colourButton(b_way,0).	

		set wp_distance to 0.
		set flyroute_a to 0.
		set dist_destination to 0.001.
		set flyroute_landing to false.
		set interface_lnd_active to false.
		set nav_lastdistance to 0.
		set nav_distance_eta to 0.
		set flighttime_avg to 0.
		set flighttime_a to 0.
	}
}.
set pop_nav:onchange to 
{ 
	parameter val. 
	set nav_param to findRouteByName(val).
	flyroute(routes[nav_param]).
	set nav_altitude to round( min((dist_destination / 30000 * 1500),maxAltitude) / 100)*100.	
	set alt_param to nav_altitude.
	set t_alt:text to nav_altitude:tostring().
}.

set b_way:onclick to 
{
	toggle mode_way.
	if mode_way = true
	{
		if b_hdg:pressed
		{
			set b_hdg:pressed to false.
		}
		if b_tof:pressed
		{
			set b_tof:pressed to false.
		}
		if b_nav:pressed
		{
			set b_way:pressed to false.
		}
		HUDTEXT("<AP> Flying to " + waypoint_database[way_param][0] + ", distance is " + round(waypoint_database[way_param][1]:distance/1000) + "km", 6, 2, 18, yellow, false).
		colourButton(b_hdg,2).
	}
	if mode_way = false
	{
		set ship:control:neutralize to true.
		unlock all.
		colourButton(b_hdg,0).

		set wp_distance to 0.
		set flyroute_a to 0.
		set dist_destination to 0.001.
		set flyroute_landing to false.
		set interface_lnd_active to false.
		set nav_lastdistance to 0.
		set nav_distance_eta to 0.
		set flighttime_avg to 0.
		set flighttime_a to 0.
	}
}.
set pop_way:onchange to 
{ 
	parameter val. 
	set way_param to findWaypointByName(val).
	if mode_nav = true
	{
		HUDTEXT("<AP> Flying to " + waypoint_database[way_param][0] + ", distance is " + round(waypoint_database[way_param][1]:distance/1000) + "km", 6, 2, 18, yellow, false).
	}
}.

global running is true.
global starttime is time:seconds.

until running = false
{
	local vTime0 is time:seconds.

	INPUT().


	if mode_spd
	{
		AUTOTHROTTLE(spd_param).
	}
	if mode_alt
	{
		HOLDALTITUDE(alt_param).
	}
	if mode_hdg
	{
		MAINTAINHEADING(hdg_param).
	}
	if mode_pit
	{
		MAINTAINVP(arcsin(pit_param/60/airspeed)).
	}
	if mode_tof and mode_tof_allow
	{
		TAKEOFF().
		if flyGoAround = false
		{
			if alt:radar > mode_tof_initAlt  + 1000
			{
				set b_tof:pressed to false.
				set ship:control:neutralize to true.
				unlock all.
				HUDTEXT("<AP> You have control", 6, 2, 18, yellow, false).
			}
		}
		else
		{
			if alt:radar > mode_tof_initAlt + 500
			{
				set b_tof:pressed to false.
				set wp1 to list("WP1",latlng(runwaypos:lat + 1.25*sin(runwayheading),runwaypos:lng - 1.0*sin(runwayheading))).
				set route_goAround to list("Go Around",
					list(wp1,runway_database[runway_number])
				).
				if abortreason = 1
				{
					set minSpeed to round(minSpeed * 1.1).
					HUDTEXT("<AP> [AP] - MinSpeed has been increased to " + round(minSpeed) + "m/s", 3, 2, 18, yellow, false).
					set planecfg_tVMin:text to minSpeed:tostring().
				}
				else if abortreason = 2
				{
					set minSpeed to round(minSpeed * 0.925).
					HUDTEXT("<AP> [AP] - MinSpeed has been decreased to " + round(minSpeed) + "m/s", 3, 2, 18, yellow, false).
					set planecfg_tVMin:text to minSpeed:tostring().
				}	
				else if abortreason = 3
				{
					set minSpeed to round(minSpeed * 0.925).
					HUDTEXT("<AP> [AP] - MinSpeed has been decreased to " + round(minSpeed) + "m/s", 3, 2, 18, yellow, false).
					set planecfg_tVMin:text to minSpeed:tostring().
				}
				else if abortreason = 4
				{					
					set minSpeed to round(minSpeed * 0.925).
					HUDTEXT("<AP> [AP] - MinSpeed has been decreased to " + round(minSpeed) + "m/s", 3, 2, 18, yellow, false).
					set planecfg_tVMin:text to minSpeed:tostring().
				}
		
				set b_nav:pressed to true.
			}
		}
	}
	// CONDITION FOR mode_tof_allow
	if alt:radar-height < 10 and airspeed < 20 and mode_tof_allow = false or TO_override = true
	{
		set mode_tof_allow to true.
		if b_tof:style:bg <> "KK_ap/button_empty_std.png" 
		{
			colourButton(b_tof,0).
		}
	}
	else if alt:radar-height > 10 and mode_tof_allow = true and mode_tof = false and TO_override = false
	{
		set mode_tof_allow to false.
		if b_tof:style:bg <> "KK_ap/button_empty_disabled.png"
		{
			colourButton(b_tof,1).
		}
		if b_tof:pressed { set b_tof:pressed to false.}
	}


	if mode_lnd and mode_lnd_allow
	{
		AUTOLAND(lnd_param).
		set xland1_runway_t:text to targetrunway[0].
		set xland2_info_hdg:text to round(targetrunway[2],1) + "deg".
		set xland3_distance_t:text to round(grounddistance/1000,1) + "km".

		if altitudeError > 0 { set xland4_pit:text to "<b>" + "+" + round(altitudeError) + "m" + "</b>".}
		else {set xland4_pit:text to "<b>" + round(altitudeError) + "m" + "</b>".}
			
			if abs(altitudeError) >= 500
			{
				set xland4_pit:style:textcolor to rgb(0.9,0,0).
			}
			else if abs(altitudeError) < 500 and abs(altitudeError) >= 50
			{
				set xland4_pit:style:textcolor to rgb(1.0,0.8,0.0).
			}
			else if abs(altitudeError) < 50
			{
				set xland4_pit:style:textcolor to rgb(0.1,0.9,0.1).
			}

		SET lnd_hdgerror to headingtarget - vVelHeading.
		if lnd_hdgerror > 180
		{
			set lnd_hdgerror to lnd_hdgerror - 360.
		}
		else if lnd_hdgerror < -180
		{
			set lnd_hdgerror to lnd_hdgerror + 360.
		}
		if lnd_hdgerror > 0 { set xland4_hdg:text to "<b>" + "+" + round(lnd_hdgerror,1) + "deg" + "</b>".}
		else {set xland4_hdg:text to "<b>" + round(lnd_hdgerror,1) + "deg" + "</b>".}

			if abs(lnd_hdgerror) >= 10
			{
				set xland4_hdg:style:textcolor to rgb(0.9,0,0).
			}
			else if abs(lnd_hdgerror) < 10 and abs(lnd_hdgerror) >= 2
			{
				set xland4_hdg:style:textcolor to rgb(1.0,0.8,0.0).
			}
			else if abs(lnd_hdgerror) < 2
			{
				set xland4_hdg:style:textcolor to rgb(0.1,0.9,0.1).
			}
		if airspeed <= 5
		{
			set b_lnd:pressed to false.
			set ship:control:neutralize to true.
			unlock all.
			set abortreason2_count to 0.
		}
	}

	// CONDITION FOR mode_lnd_allow
	if alt:radar-height > 100 and mode_lnd_allow = false and mode_tof = false
	{
		set mode_lnd_allow to true.
		if b_lnd:style:bg <> "KK_ap/button_empty_std.png" 
		{
			colourButton(b_lnd,0).
		}
	}
	else if alt:radar-height < 100 and mode_lnd_allow = true and mode_lnd = false or mode_tof = true and mode_lnd_allow = true
	{
		set mode_lnd_allow to false.
		if b_lnd:style:bg <> "KK_ap/button_empty_disabled.png"
		{
			colourButton(b_lnd,1).
		}
		if b_lnd:pressed { set b_lnd:pressed to false.}
	}

	if mode_nav
	{
		set xnav1_route_t:text to navroute[0].
		set xnav2_distance_t:text to round(dist_destination/1000):tostring() + "km".
		local time1 is dist_destination / airspeed.
		if nav_distance_eta < 0
		{
			set flighttime to time1.	// raw distance / airspeed calculation
		}
		else
		{
			set flighttime to (time1 + nav_distance_eta) / 2.	// avg of time1, rate of change of distance based eta
		}
		local h is floor(flighttime/3600).
		local min is floor(flighttime/60-h*60).
		local s is flighttime-h*3600-min*60.
		set requiredFuel to 0.
		if vFuel_lqf_timeAvg > 0
		{
			set requiredfuel to flighttime / vFuel_lqf_timeAvg * vFuel_lqf_fuelMass.
		}
		print "requiredFuel: " + round(requiredFuel,2) + "t     " at (0,10).

		set xnav3_time_t:text to h + "h " + min + "min " + round(s) + "s".
		if flyGoAround = false
		{
			flyroute(routes[nav_param]).
		}
		else
		{
			flyroute(route_goAround).
		}
	}

	if mode_way
	{
		MAINTAINHEADING(flytowaypoint(waypoint_database[way_param])).
	}

	// FUEL CALCULATION
	if vFuel_lqf_start > 0 set vFuel_percentage to ship:liquidfuel / vFuel_lqf_start.	// How much fuel is remaining in %
	else set vFuel_percentage to 0.

	if time:seconds - vFuel_lqf_lasttime > 0.1
	{
		set vFuel_lqf_rate to (vFuel_lqf_last - ship:liquidfuel) / (time:seconds - vFuel_lqf_lasttime).	// How much fuel is being burned
		if vFuel_lqf_rate > 0 set vFuel_lqf_time to ship:liquidfuel / vFuel_lqf_rate.
		if throttle > 0 set vFuel_lqf_rateMax to vFuel_lqf_rate / throttle.
		else set vFuel_lqf_time to 0.
		set vFuel_lqf_range to vFuel_lqf_time * airspeed.

		set vFuel_acc_weightDiff to ship:drymass / ship:mass.
		set vFuel_lqf_fuelMass to ship:mass - ship:drymass.
		set vFuel_acc_emptyThrottle to throttle * vFuel_acc_weightDiff.
		if vFuel_acc_EmptyThrottle > 0 set vFuel_lqf_rateEmpty to vFuel_lqf_rateMax * vFuel_acc_EmptyThrottle.
		else set vFuel_lqf_rateEmpty to 0.
		if vFuel_lqf_rateEmpty > 0 set vFuel_lqf_timeEmpty to ship:liquidfuel / vFuel_lqf_rateEmpty.
		else set vFuel_lqf_timeEmpty to 0.
		set vFuel_lqf_rangeEmpty to vFuel_lqf_timeEmpty * airspeed.

		set vFuel_lqf_timeAvg to (vFuel_lqf_time + vFuel_lqf_timeEmpty) / 2.
		set vFuel_lqf_time_h to floor(vFuel_lqf_timeAvg/3600).
		set vFuel_lqf_time_min to floor(vFuel_lqf_timeAvg/60-vFuel_lqf_time_h*60).
		set vFuel_lqf_time_s to vFuel_lqf_timeAvg - vFuel_lqf_time_h * 3600 - vFuel_lqf_time_min*60.
		set vFuel_lqf_rangeAvg to (vFuel_lqf_range + vFuel_lqf_rangeEmpty) / 2.

		set vFuel_lqf_last to ship:liquidfuel.
		set vFuel_lqf_lasttime to time:seconds.
	}

	set xRange_nRange:text to round(vFuel_lqf_rangeAvg/1000):tostring() + "km".
	set xRange_nTime:text to vFuel_lqf_time_h:tostring() + "h " + vFuel_lqf_time_min:tostring() + "min " + round(vFueL_lqf_time_s):tostring() + "s".
	set xRange_nCons:text to round(vFuel_lqf_rate,2):tostring() + "u/s".
	set xRange_nTons:text to round(vFuel_lqf_fuelMass,3):tostring() + "t".

	set lag to time:seconds - vTime0.
	print "lag: " + round(lag,3) + "s  " at (35,0).
}

clearguis().
set ship:control:neutralize to true.
unlock all.

