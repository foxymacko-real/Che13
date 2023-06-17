///////////////goverment//
/datum/job/american/marg
	default_language = "English"
	additional_languages = list("Russian" = 55, "Arabic" = 10)

/datum/job/american/marg/overseer
	title = "Overseer"
	en_meaning = "Overseer"
	rank_abbreviation = "Ov."
	spawn_location = "Gov"

	is_marg = TRUE

	uses_squads = FALSE
	whitelisted = FALSE

	min_positions = 1
	max_positions = 1

/datum/job/american/marg/overseer/equip(var/mob/living/human/H)
	if (!H)	return FALSE
//shoes
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots/modern(H), slot_shoes)
//clothes
	H.equip_to_slot_or_del(new /obj/item/clothing/under/margygal/govcomb(H), slot_w_uniform)
//armor
	var/obj/item/clothing/under/uniform = H.w_uniform
	var/obj/item/clothing/accessory/armband/french/red = new /obj/item/clothing/accessory/armband/french(null)
	uniform.attackby(red, H)
	var/obj/item/clothing/accessory/armor/coldwar/plates/interceptor/armour2 = new /obj/item/clothing/accessory/armor/coldwar/plates/interceptor(null)
	uniform.attackby(armour2, H)
//gun
	var/obj/item/clothing/accessory/storage/webbing/largepouches/webbing = new /obj/item/clothing/accessory/storage/webbing/largepouches(null)
	uniform.attackby(webbing, H)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack/gauze(H), slot_l_store)
	H.equip_to_slot_or_del(new /obj/item/weapon/key/margygal(H), slot_r_store)
	if (prob(55))
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/submachinegun/bax2(H), slot_shoulder)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/bax2(H), slot_belt)
		webbing.attackby(new/obj/item/ammo_magazine/bax2, H)
		webbing.attackby(new/obj/item/ammo_magazine/bax2, H)
		webbing.attackby(new/obj/item/ammo_magazine/bax2, H)
		webbing.attackby(new/obj/item/ammo_magazine/bax2, H)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/submachinegun/bax7(H), slot_shoulder)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/bax7(H), slot_belt)
		webbing.attackby(new/obj/item/ammo_magazine/bax7, H)
		webbing.attackby(new/obj/item/ammo_magazine/bax7, H)
		webbing.attackby(new/obj/item/ammo_magazine/bax7, H)
		webbing.attackby(new/obj/item/ammo_magazine/bax7, H)
//helmet
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/marg(H), slot_head)
//glove
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/thick/combat(H), slot_gloves)
//back
	H.equip_to_slot_or_del(new /obj/item/weapon/radio/faction1(H), slot_back)

	H.civilization = "Coalition"
	H.add_note("Role", "You are a <b>[title]</b>. Follow your Squad Leader and his orders!")
	H.setStat("strength", STAT_MEDIUM_LOW)
	H.setStat("crafting", STAT_NORMAL)
	H.setStat("rifle", STAT_NORMAL)
	H.setStat("dexterity", STAT_NORMAL)
	H.setStat("swords", STAT_NORMAL)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("bows", STAT_NORMAL)
	H.setStat("medical", STAT_NORMAL)
	H.setStat("machinegun", STAT_NORMAL)
	give_random_name(H)

	return TRUE

/datum/job/american/marg/inf
	title = "Margygal Infantry"
	en_meaning = "Infantry of the Margygal goverment"
	rank_abbreviation = "pvt."
	spawn_location = "Gov"

	is_marg = TRUE

	uses_squads = TRUE
	whitelisted = FALSE

	min_positions = 15
	max_positions = 100

/datum/job/american/marg/inf/equip(var/mob/living/human/H)
	if (!H)	return FALSE
//shoes
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots/modern(H), slot_shoes)
//clothes
	H.equip_to_slot_or_del(new /obj/item/clothing/under/margygal/govcomb(H), slot_w_uniform)
//armor
	var/obj/item/clothing/under/uniform = H.w_uniform
	var/obj/item/clothing/accessory/armband/french/red = new /obj/item/clothing/accessory/armband/french(null)
	uniform.attackby(red, H)
	var/obj/item/clothing/accessory/armor/coldwar/plates/interceptor/armour2 = new /obj/item/clothing/accessory/armor/coldwar/plates/interceptor(null)
	uniform.attackby(armour2, H)
//gun
	var/obj/item/clothing/accessory/storage/webbing/largepouches/webbing = new /obj/item/clothing/accessory/storage/webbing/largepouches(null)
	uniform.attackby(webbing, H)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack/gauze(H), slot_l_store)
	H.equip_to_slot_or_del(new /obj/item/weapon/key/margygal(H), slot_r_store)
	if (prob(95))
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/submachinegun/bax2(H), slot_shoulder)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/bax2(H), slot_belt)
		webbing.attackby(new/obj/item/ammo_magazine/bax2, H)
		webbing.attackby(new/obj/item/ammo_magazine/bax2, H)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/submachinegun/bax7(H), slot_shoulder)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/bax7(H), slot_belt)
		webbing.attackby(new/obj/item/ammo_magazine/bax7, H)
		webbing.attackby(new/obj/item/ammo_magazine/bax7, H)
//helmet
	if (prob(35))
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/marg(H), slot_head)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/head/ww2/us_sailor_hat/marg(H), slot_head)
//glove
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/thick/combat(H), slot_gloves)
//back
	if (prob(35))
		H.equip_to_slot_or_del(new /obj/item/weapon/radio/faction1(H), slot_back)

	H.civilization = "Coalition"
	H.add_note("Role", "You are a <b>[title]</b>. Follow orders, maintain peace, shoot armed rebels!")
	H.setStat("strength", STAT_MEDIUM_LOW)
	H.setStat("crafting", STAT_NORMAL)
	H.setStat("rifle", STAT_NORMAL)
	H.setStat("dexterity", STAT_NORMAL)
	H.setStat("swords", STAT_NORMAL)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("bows", STAT_NORMAL)
	H.setStat("medical", STAT_NORMAL)
	H.setStat("machinegun", STAT_NORMAL)
	give_random_name(H)

	return TRUE

///////////////////rebels

/datum/job/pirates/marg
	default_language = "English"
	additional_languages = list("Russian" = 25, "Arabic" = 70)

/datum/job/pirates/marg/leader
	title = "Rebellion lead"
	en_meaning = "Reb Lead"
	rank_abbreviation = " ."
	spawn_location = "Reb"

	is_marg = TRUE

	uses_squads = TRUE
	whitelisted = FALSE

	min_positions = 1
	max_positions = 2

/datum/job/pirates/marg/leader/equip(var/mob/living/human/H)
	if (!H)	return FALSE
//shoes
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/usmc(H), slot_shoes)
//clothes
	H.equip_to_slot_or_del(new /obj/item/clothing/under/civ3(H), slot_w_uniform)
//armor

//helmet
	if (prob(45))
		H.equip_to_slot_or_del(new /obj/item/clothing/head/ww2/us_tanker(H), slot_head)
//glove
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/thick/combat(H), slot_gloves)
//suit
//back
	if (prob(50))
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/milcrate(H), slot_back)

	H.civilization = "Rebellion"
	H.add_note("Role", "You are a <b>[title]</b>. Coordinate the rebellion!")
	H.setStat("strength", STAT_MEDIUM_LOW)
	H.setStat("crafting", STAT_NORMAL)
	H.setStat("rifle", STAT_NORMAL)
	H.setStat("dexterity", STAT_NORMAL)
	H.setStat("swords", STAT_NORMAL)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("bows", STAT_NORMAL)
	H.setStat("medical", STAT_NORMAL)
	H.setStat("machinegun", STAT_NORMAL)
	give_random_name(H)

	return TRUE

/datum/job/pirates/marg/rebel
	title = "Rebel"
	en_meaning = "Rebel"
	rank_abbreviation = ""
	spawn_location = "Reb"

	is_marg = TRUE

	uses_squads = TRUE
	whitelisted = FALSE

	min_positions = 25
	max_positions = 50

/datum/job/pirates/marg/rebel/equip(var/mob/living/human/H)
	if (!H)	return FALSE
//shoes
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/usmc(H), slot_shoes)
//clothes
	if (prob(50))
		H.equip_to_slot_or_del(new /obj/item/clothing/under/civ2(H), slot_w_uniform)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/civ1(H), slot_w_uniform)

//back
	if (prob(10))
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/milcrate(H), slot_back)

	H.civilization = "Rebellion"
	H.add_note("Role", "You are a <b>[title]</b>.Follow your leader!")
	H.setStat("strength", STAT_NORMAL)
	H.setStat("crafting", STAT_NORMAL)
	H.setStat("rifle", STAT_NORMAL)
	H.setStat("dexterity", STAT_NORMAL)
	H.setStat("swords", STAT_NORMAL)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("bows", STAT_NORMAL)
	H.setStat("medical", STAT_NORMAL)
	H.setStat("machinegun", STAT_NORMAL)
	give_random_name(H)

	return TRUE

/datum/job/pirates/marg/civ
	title = "Civilian"
	en_meaning = "Civilian"
	rank_abbreviation = ""
	spawn_location = "Civ"

	is_marg = TRUE

	uses_squads = FALSE
	whitelisted = FALSE

	min_positions = 25
	max_positions = 90

/datum/job/pirates/marg/civ/equip(var/mob/living/human/H)
	if (!H)	return FALSE
//shoes
	if (prob(50))
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/usmc(H), slot_shoes)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(H), slot_shoes)

//clothes
	if (prob(50))
		H.equip_to_slot_or_del(new /obj/item/clothing/under/civ2(H), slot_w_uniform)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/civ1(H), slot_w_uniform)

	H.civilization = "Nonaligned"
	H.add_note("Role", "You are a <b>[title]</b>.By default you are not aligned to anyone, but you have one goal in mind, get into the city!")
	H.setStat("strength", STAT_NORMAL)
	H.setStat("crafting", STAT_NORMAL)
	H.setStat("rifle", STAT_NORMAL)
	H.setStat("dexterity", STAT_NORMAL)
	H.setStat("swords", STAT_NORMAL)
	H.setStat("pistol", STAT_NORMAL)
	H.setStat("bows", STAT_NORMAL)
	H.setStat("medical", STAT_NORMAL)
	H.setStat("machinegun", STAT_NORMAL)
	give_random_name(H)

	return TRUE