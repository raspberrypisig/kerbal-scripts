set waypoint_database to list(	
	// name, latlng (geocoordinates)
	list("KSC Runway 09",latlng(-0.0486035631147535,-74.7242185628819)),				// 0
	list("KSC Runway 27",latlng(-0.0502198339178733,-74.4927407208138)),				// 1
	list("Island Airfield 27",latlng(-1.51577900148111,-71.8520974239621)),				// 2
	list("Island Airfield 09",latlng(-1.51742820315363,-71.9673819443859)),				// 3		
	list("Woomerang Launch Site",latlng(45.3200862887531,136.06540473502)),				// 4
	list("North Pole",latlng(90,-90)),								// 5
	list("Dessert Airfield",latlng(-6.59739118717951,-144.041152565066)),				// 6
	list("Island Airfield WN Appr",latlng(-0.624952502017451,-73.3246285206463)),		
	list("KSC Mountain SE Pass",latlng(-1.44080742211447,-76.6677203163974)),			// 8	
	list("KSC Mountain SW Pass",latlng(-3.04632570592582,-83.7940315071343)),
	list("Desert Long Hop Approach",latlng(-1.96183530147171,-105.8584112572)),			// 10
	list("Desert Airfield SE Appr",latlng(-9.45736502630028,-140.486637409811)),
	list("Desert AIrfield SW Appr",latlng(-8.45009319240933,-145.826441932105))			// 12
).

set runway_database to list(
	// name, latlng (geocoordinates),heading (deg),length (m)
	list("KSC Runway 09",latlng(-0.0486035631147535,-74.7242185628819),90.4),		// 0
	list("KSC Runway 27",latlng(-0.0502198339178733,-74.4927407208138),270.400055529,2425),		// 1
	list("Island Airfield 27",latlng(-1.51567794585235,-71.8513736262438),270.1492736067046,1200),	// 2
	list("Island Airfield 09",latlng(-1.51800935249801,-71.9675878222586),89.8507263932954,1200),	// 3
	list("Dessert Airfield 00",latlng(-6.59739118717951,-144.041152565066),0.9796924659,1550),	// 4
	list("Dessert Airfield 18",latlng(-6.45022603187249,-144.038635963533),180.9796924659,1550)	// 5
).

set routes to list(
	// first object is name, second object is list of waypoints with target runway at the end
	list("KSC to Island Airfield",
		list(
			waypoint_database[7],
			runway_database[3])),
	list("KSC to Desert Airfield",
		list(
			waypoint_database[8],
			waypoint_database[9],
			waypoint_database[10],
			waypoint_database[11],
			waypoint_database[12],
			runway_database[5]))
).


set airplaneData to list(
	list("Aeris 3A",	// name
		2.0,		// height
		1,		// thrreverse
		60,		// minspeed = final landing / touchdown speed
		150,		// maxspeed = maxspeed ap will maintain during approach
		-1.0,		// approachdec = deccalaration to maintain during approach
		40,		// vTakeOffSpeed = start pitching up at takeoff
		15,		// vTakeOffAngle = vis. angle to maintain at takeoff to prevent tailstrike
		100,		// vAfterTakeOffSpeed = speed to maintain after takeoff
		15		// vAfterTakeOffAngle = pitch angle to maintain after takeoff
	),
	list("A220",		// name
		3.0,		// height
		1,		// thrreverse
		80,		// minspeed = final landing / touchdown speed
		200,		// maxspeed = maxspeed ap will maintain during approach
		-1.0,		// approachdec = deccalaration to maintain during approach
		40,		// vTakeOffSpeed = start pitching up at takeoff
		10,		// vTakeOffAngle = vis. angle to maintain at takeoff to prevent tailstrike
		150,		// vAfterTakeOffSpeed = speed to maintain after takeoff
		15		// vAfterTakeOffAngle = pitch angle to maintain after takeoff
	),
	list("A300",
		5.0,
		1,
		95,
		200,
		-1.0,
		50,
		10,
		150,
		15
	),
	list("A310",
		5.0,
		1,
		95,
		200,
		-1.0,
		50,
		10,
		150,
		15
	),
	list("A310-200",
		5.0,
		1,
		110,
		200,
		-1.0,
		40,
		10,
		150,
		15
	),
	list("A330",
		5.0,
		1,
		95,
		200,
		-1.0,
		50,
		10,
		150,
		12
	),
	list("A340-300",
		5.0,
		1,
		110,
		200,
		-1.0,
		50,
		8,
		150,
		12
	),
	list("A340-600",
		5.0,
		1,
		110,
		200,
		-1.0,
		50,
		8,
		150,
		15
	),
	list("K707",
		5.0,
		1,
		95,
		200,
		-1.0,
		50,
		8,
		150,
		15
	),
	list("K707 Global Tanker",
		5.0,
		1,
		120,
		200,
		-1.0,
		50,
		8,
		150,
		15
	),
	list("K737-100",
		5.0,
		1,
		90,
		200,
		-1.0,
		50,
		8,
		150,
		15
	),
	list("K737-300",
		5.0,
		1,
		100,
		200,
		-1.0,
		50,
		8,
		150,
		15
	),
	list("K737-800",
		5.0,
		1,
		105,
		200,
		-1.0,
		50,
		8,
		150,
		15
	),
	list("K737 MAX8",
		5.0,
		1,
		110,
		200,
		-1.0,
		50,
		7,
		150,
		15
	),
	list("K737 MAX10",
		5.0,
		1,
		110,
		200,
		-1.0,
		50,
		5,
		150,
		15
	),
	list("K-747-400",
		10.0,
		1,
		100,
		200,
		-1.0,
		50,
		8,
		150,
		15
	),
	list("K-747-8",
		10.0,
		1,
		100,
		200,
		-1.0,
		50,
		6,
		150,
		15
	),
	list("K757",
		5.0,
		1,
		100,
		200,
		-1.0,
		50,
		7,
		150,
		15
	),
	list("K-777-200ER",
		7.0,
		1,
		120,
		200,
		-1.0,
		50,
		8,
		150,
		15
	),
	list("K-777-X",
		7.0,
		1,
		130,
		200,
		-1.0,
		80,
		8,
		150,
		10
	)		
).