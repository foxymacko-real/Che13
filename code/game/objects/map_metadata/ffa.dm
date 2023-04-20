/obj/map_metadata/nomads_ffa
	ID = MAP_FREE_FOR_ALL
	title = "FFA"
	lobby_icon = "icons/lobby/civ13.gif"
	no_winner ="The round is proceeding normally."
	caribbean_blocking_area_types = list(/area/caribbean/no_mans_land/invisible_wall/)
	respawn_delay = 6000 // 10 minutes!
	has_hunger = TRUE

	faction_organization = list(
		CIVILIAN,)

	roundend_condition_sides = list(
		list(CIVILIAN) = /area/caribbean/british
		)
	age = "2040"
	civilizations = TRUE
	var/tribes_nr = 1
	faction_distribution_coeffs = list(CIVILIAN = 1)
	battle_name = "the civilizations"
	mission_start_message = "<big>The World is in disarray, everyone is fighting each other, can you survive in this hell? theres only one rule, no killing in spawn. good luck</b>"
	ambience = list('sound/ambience/desert.ogg')
	faction1 = CIVILIAN
	availablefactions = list("Nomad")
	songs = list(
		"Swallowing dust:1" = "sound/music/swallowingdust.ogg",)
	research_active = TRUE
	nomads = TRUE
	gamemode = "Free for all Wasteland"
	ordinal_age = 8
	default_research = 230
	research_active = FALSE
	age1_done = TRUE
	age2_done = TRUE
	age3_done = TRUE
	age4_done = TRUE
	age5_done = TRUE
	age6_done = TRUE
	age7_done = TRUE
	age8_done = TRUE

/obj/map_metadata/nomads_ffa/New()
	..()
	spawn(18000)
		seasons()

/obj/map_metadata/nomads_ffa/cross_message(faction)
	return ""

/obj/map_metadata/nomads_ffa/job_enabled_specialcheck(var/datum/job/J)
	if (J.is_ffa == TRUE)
		. = TRUE
	else
		. = FALSE