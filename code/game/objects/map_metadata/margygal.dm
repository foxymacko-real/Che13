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
		PIRATES,
		AMERICAN)

	roundend_condition_sides = list(
		list(PIRATES) = /area/caribbean/british/land/inside/objective,
		list(AMERICAN) = /area/caribbean/arab
		)
	age = "2091"
	ordinal_age = 7
	faction_distribution_coeffs = list(AMERICAN = 0.3, PIRATES = 0.7)
	battle_name = "Margygal Insurgency."
	mission_start_message = ""
	faction1 = PIRATES
	faction2 = AMERICAN
	grace_wall_timer = 6000
	valid_weather_types = list(WEATHER_NONE, WEATHER_WET)
	songs = list(
		"Kino - I Want Changes:1" = "sound/music/want_changes.ogg",)
	artillery_count = 0
	valid_artillery = list()
	scores = list(
		"Margygal" = 0,
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
		if (PIRATES)
			return "Militia"
		if (AMERICAN)
			return "Margygal"
/obj/map_metadata/margygal/roundend_condition_def2army(define)
	..()
	switch (define)
		if (PIRATES)
			return "Militias"
		if (AMERICAN)
			return "Margygal"

/obj/map_metadata/margygal/army2name(army)
	..()
	switch (army)
		if ("Militias")
			return "Militia"
		if ("Margygal")
			return "Margygal"

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
		world << "<big>Margygal: [scores["Margygal"]]</big>"

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


/obj/item/weapon/key/margygal
	code = 232145
	name = "Margygal Goverment Key"

/obj/structure/simple_door/key_door/custom/jail/steeljail/margygal
	unique_door_name = "Margygal Goverment locked"
	locked = TRUE
	custom_code = 232145

/obj/structure/simple_door/key_door/custom/jail/steeljail/margygal/open
	starts_open = TRUE
	locked = FALSE
	custom_code = 232145
	New()
		..()
		icon_state = "cellopen"
		density = FALSE