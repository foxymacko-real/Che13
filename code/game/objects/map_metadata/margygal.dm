/obj/map_metadata/margygal
	ID = MAP_MARGYGAL
	title = "Margygal Insurgency"
	lobby_icon = "icons/lobby/yeltsin.png"
	caribbean_blocking_area_types = list(/area/caribbean/no_mans_land/invisible_wall,/area/caribbean/no_mans_land/invisible_wall/one,/area/caribbean/no_mans_land/invisible_wall/two)
	respawn_delay = 1200
	no_winner = "The operation is still underway."
	gamemode = "Kills."
	no_hardcore = FALSE

	faction_organization = list(
		CIVILIAN,
		AMERICAN)

	roundend_condition_sides = list(
		list(CIVILIAN) = /area/caribbean/british/land/inside/objective,
		list(AMERICAN) = /area/caribbean/arab
		)
	age = "1993"
	ordinal_age = 7
	faction_distribution_coeffs = list(AMERICAN = 0.3, CIVILIAN = 0.7)
	battle_name = "Margygal Insurgency."
	mission_start_message = ""
	faction1 = CIVILIAN
	faction2 = RUSSIAN
	grace_wall_timer = 6000
	valid_weather_types = list(WEATHER_NONE, WEATHER_WET)
	songs = list(
		"Kino - I Want Changes:1" = "sound/music/want_changes.ogg",)
	artillery_count = 0
	valid_artillery = list()
	scores = list(
		"Russian Army" = 0,
		"Militia" = 0,
	)

/obj/map_metadata/margygal/job_enabled_specialcheck(var/datum/job/J)
	..()
	if (J.is_marg == TRUE)
		. = TRUE
	else
		. = FALSE

/obj/map_metadata/margygal/roundend_condition_def2name(define)
	..()
	switch (define)
		if (CIVILIAN)
			return "Militia"
		if (AMERICAN)
			return "margygal Army"
/obj/map_metadata/margygal/roundend_condition_def2army(define)
	..()
	switch (define)
		if (CIVILIAN)
			return "Militias"
		if (AMERICAN)
			return "margygal Army"

/obj/map_metadata/margygal/army2name(army)
	..()
	switch (army)
		if ("Militias")
			return "Militia"
		if ("Russian Army")
			return "margygal Army"

/obj/map_metadata/margygal/cross_message(faction)
	if (faction == AMERICAN)
		return "<font size = 4>The Goverment army may now cross the invisible wall!</font>"
	else
		return ""

/obj/map_metadata/margygal/reverse_cross_message(faction)
	if (faction == AMERICAN)
		return "<span class = 'userdanger'>The Goverment Army may no longer cross the invisible wall!</span>"
	else
		return ""

/obj/map_metadata/margygal/proc/points_check()
	if (processes.ticker.playtime_elapsed > 4800)
	world << "<big><b>Current Points:</big></b>"
	world << "<big>Militia: [scores["Militia"]]</big>"
	world << "<big>Russian Army: [scores["Russian Army"]]</big>"

/obj/map_metadata/margygal/check_caribbean_block(var/mob/living/human/H, var/turf/T)
	if (!istype(H) || !istype(T))
		return FALSE
	var/area/A = get_area(T)
	if (istype(A, /area/caribbean/no_mans_land/invisible_wall))
		if (istype(A, /area/caribbean/no_mans_land/invisible_wall/one))
			if (H.faction_text == faction1)
				return TRUE
		else if (istype(A, /area/caribbean/no_mans_land/invisible_wall/two))
			if (H.faction_text == faction2)
				return TRUE
		else
			return !faction1_can_cross_blocks()
	return FALSE
