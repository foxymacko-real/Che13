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

	min_positions = 9
	max_positions = 90

/datum/job/pirates/marg/leader/equip(var/mob/living/human/H)
	if (!H)	return FALSE
//shoes
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/usmc(H), slot_shoes)
//clothes
	H.equip_to_slot_or_del(new /obj/item/clothing/under/us_uni/us_camo_ucp(H), slot_w_uniform)
//armor
	var/obj/item/clothing/under/uniform = H.w_uniform
	var/obj/item/clothing/accessory/armband/french/red = new /obj/item/clothing/accessory/armband/french(null)
	uniform.attackby(red, H)
	var/obj/item/clothing/accessory/armor/coldwar/pasgt/blizzard/armour2 = new /obj/item/clothing/accessory/armor/coldwar/pasgt/blizzard(null)
	uniform.attackby(armour2, H)
//gun
	var/randimpw = rand(1,5)
	switch(randimpw)
		if (1)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/semiautomatic/m1garand(H), slot_shoulder)
			H.equip_to_slot_or_del(new /obj/item/weapon/grenade/coldwar/nonfrag/m26(H), slot_belt)
			var/obj/item/clothing/accessory/storage/webbing/us_ww2/garand/webbing = new /obj/item/clothing/accessory/storage/webbing/us_ww2/garand(null)
			uniform.attackby(webbing, H)
		if (2)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/submachinegun/m16(H), slot_shoulder)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/smallpouches/olive/m16_smoke(H), slot_belt)
			var/obj/item/clothing/accessory/storage/webbing/us_vest/m16/webbing = new /obj/item/clothing/accessory/storage/webbing/us_vest/m16(null)
			uniform.attackby(webbing, H)
		if (3)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/submachinegun/sten(H), slot_shoulder)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/smallpouches/sten(H), slot_belt)
			var/obj/item/clothing/accessory/storage/webbing/us_vest/sten/webbing = new /obj/item/clothing/accessory/storage/webbing/us_vest/sten(null)
			uniform.attackby(webbing, H)
		if (4)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/boltaction/springfield(H), slot_shoulder)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/springfield(H), slot_belt)
			var/obj/item/clothing/accessory/storage/webbing/us_vest/springfield/webbing = new /obj/item/clothing/accessory/storage/webbing/us_vest/springfield(null)
			uniform.attackby(webbing, H)
		if (5)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/semiautomatic/m1garand/match(H), slot_shoulder)
			H.equip_to_slot_or_del(new /obj/item/weapon/grenade/coldwar/m67(H), slot_belt)
			var/obj/item/clothing/accessory/storage/webbing/us_ww2/garand/webbing = new /obj/item/clothing/accessory/storage/webbing/us_ww2/garand(null)
			uniform.attackby(webbing, H)
//helmet
	if (prob(45))
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/modern/pasgt/white(H), slot_head)
	else if (prob(50))
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/modern/ach/white(H), slot_head)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/head/ww2/us_tanker(H), slot_head)
//glove
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/thick/combat(H), slot_gloves)
//suit
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/coat/fur/m05(H), slot_wear_suit)
//back
	if (prob(50))
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/rucksack/small/milpack(H), slot_back)

	H.civilization = "Rebellion"
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