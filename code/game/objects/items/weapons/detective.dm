#define BURNING_RAG_LIFE_TICKS 10000 // pretty much forever

/obj/item/clothing/gloves
	var/transfer_blood = FALSE
	var/mob/living/human/bloody_hands_mob

/obj/item/clothing/shoes/
	var/track_blood = FALSE

/obj/item/weapon/reagent_containers/glass/rag
	name = "cleaning rag"
	desc = "For cleaning up messes, you suppose."
	w_class = ITEM_SIZE_TINY
	icon = 'icons/obj/trash.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 10
	flags = OPENCONTAINER | NOBLUDGEON
	dropsound = null
	flammable = TRUE
	var/on_fire = FALSE
	var/burn_time = BURNING_RAG_LIFE_TICKS //if the rag burns for too long it turns to ashes

/obj/item/weapon/reagent_containers/glass/rag/New()
	..()
	update_name()

/obj/item/weapon/reagent_containers/glass/rag/Destroy()
	processing_objects -= src //so we don't continue turning to ash while gc'd
	..()

/obj/item/weapon/reagent_containers/glass/rag/attack_self(mob/user as mob)
	if (on_fire)
		user.visible_message("<span class='warning'>\The [user] stamps out [src].</span>", "<span class='warning'>You stamp out [src].</span>")
		user.unEquip(src)
		extinguish()
	else
		remove_contents(user)

/obj/item/weapon/reagent_containers/glass/rag/attackby(obj/item/W, mob/user)
	if (!on_fire)
		if (istype(W, /obj/item/weapon/flame) || istype(W, /obj/item/clothing/mask/smokable/cigarette) && W:on)
			var/cont = FALSE
			var/obj/item/weapon/flame/F = W
			if (istype(F) && F.lit)
				cont = TRUE
			else if (istype(W, /obj/item/flashlight))
				var/obj/item/flashlight/FL = W
				if (FL.on)
					cont = TRUE

			if (cont)
				ignite()
				if (on_fire)
					visible_message("<span class='warning'>\The [user] lights [src] with [W].</span>")
				else
					user << "<span class='warning'>You manage to singe [src], but fail to light it. Maybe you should wet it.</span>"
	. = ..()
	update_name()

/obj/item/weapon/reagent_containers/glass/rag/proc/update_name()
	if (on_fire)
		name = "burning [initial(name)]"
	else if (reagents.total_volume)
		name = "damp [initial(name)]"
	else
		name = "dry [initial(name)]"

/obj/item/weapon/reagent_containers/glass/rag/update_icon()

	overlays.Cut()

	if (on_fire)
		overlays += icon('icons/effects/fire.dmi', "fire")

	var/obj/item/weapon/reagent_containers/food/drinks/bottle/B = loc
	if (istype(B))
		B.update_icon()

/obj/item/weapon/reagent_containers/glass/rag/proc/remove_contents(mob/user, atom/trans_dest = null)
	if (!trans_dest && !user.loc)
		return

	if (reagents.total_volume)
		var/target_text = trans_dest? "\the [trans_dest]" : "\the [user.loc]"
		user.visible_message("<span class='danger'>\The [user] begins to wring out [src] over [target_text].</span>", "<span class='notice'>You begin to wring out [src] over [target_text].</span>")

		if (do_after(user, reagents.total_volume*5, progress = FALSE)) //50 for a fully soaked rag
			if (trans_dest)
				reagents.trans_to(trans_dest, reagents.total_volume)
			else
				reagents.splash(user.loc, reagents.total_volume)
			user.visible_message("<span class='danger'>\The [user] wrings out [src] over [target_text].</span>", "<span class='notice'>You finish to wringing out [src].</span>")
			update_name()

/obj/item/weapon/reagent_containers/glass/rag/proc/wipe_down(atom/A, mob/user)
	if (!reagents.total_volume)
		user << "<span class='warning'>The [initial(name)] is dry!</span>"
	else
		user.visible_message("\The [user] starts to wipe down [A] with [src]!")
		reagents.splash(A, TRUE) //get a small amount of liquid on the thing we're wiping.
		update_name()
		if (do_after(user,30, progress = FALSE))
			user.visible_message("\The [user] finishes wiping off the [A]!")
			A.clean_blood()

/obj/item/weapon/reagent_containers/glass/rag/attack(atom/target as obj|turf|area, mob/user as mob , flag)
	if (isliving(target))
		if (do_after(user, 20, get_turf(user)))
			var/mob/living/M = target
			if (on_fire)
				user.visible_message("<span class='danger'>\The [user] hits [target] with [src]!</span>",)
				user.do_attack_animation(src)
				M.IgniteMob()
			else if (reagents.total_volume)
				if (user.targeted_organ == "mouth")
					user.do_attack_animation(src)
					user.visible_message(
						"<span class='danger'>\The [user] smothers [target] with [src]!</span>",
						"<span class='warning'>You smother [target] with [src]!</span>",
						"You hear some struggling and muffled cries of surprise"
						)

					//it's inhaled, so... maybe CHEM_BLOOD doesn't make a whole lot of sense but it's the best we can do for now
					reagents.trans_to_mob(target, amount_per_transfer_from_this, CHEM_BLOOD)
					update_name()
				else
					wipe_down(target, user)
			return

	return ..()

/obj/item/weapon/reagent_containers/glass/rag/afterattack(atom/A as obj|turf|area, mob/user as mob, proximity)
	if (!proximity)
		return

	if (istype(A, /obj/structure/reagent_dispensers))
		if (!reagents.get_free_space())
			user << "<span class='warning'>\The [src] is already soaked.</span>"
			return

		if (A.reagents && A.reagents.trans_to_obj(src, reagents.maximum_volume))
			user.visible_message("<span class='notice'>\The [user] soaks [src] using [A].</span>", "<span class='notice'>You soak [src] using [A].</span>")
			update_name()
		return

	if (!on_fire && istype(A) && (src in user))
		if (A.is_open_container() && !(A in user))
			remove_contents(user, A)
		else if (!ismob(A)) //mobs are handled in attack() - this prevents us from wiping down people while smothering them.
			wipe_down(A, user)
		return
/*
/obj/item/weapon/reagent_containers/glass/rag/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if (exposed_temperature >= 50 + T0C)
		ignite()
	if (exposed_temperature >= 900 + T0C)
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)
*/
//rag must have a minimum of 2 units welder fuel and at least 80% of the reagents must be welder fuel.
//maybe generalize flammable reagents someday
/obj/item/weapon/reagent_containers/glass/rag/proc/can_ignite()
	var/fuel = reagents.get_reagent_amount("fuel")
	for (var/datum/reagent/R in reagents.reagent_list)
		if (istype(R, /datum/reagent/ethanol))
			fuel += R.volume

	return (fuel >= 2 && fuel >= reagents.total_volume*0.8)

/obj/item/weapon/reagent_containers/glass/rag/proc/ignite()
	if (on_fire)
		return
	if (!can_ignite())
		return

	//also copied from matches
	if (reagents.get_reagent_amount("plasma")) // the plasma explodes when exposed to fire
		visible_message("<span class='danger'>\The [src] conflagrates violently!</span>")
		var/datum/effect/effect/system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount("plasma") / 2.5, TRUE), get_turf(src), FALSE, FALSE)
		e.start()
		qdel(src)
		return

	processing_objects += src
	set_light(2, null, "#E38F46")
	on_fire = TRUE
	update_name()
	update_icon()

/obj/item/weapon/reagent_containers/glass/rag/proc/extinguish()
	processing_objects -= src
	set_light(0)
	on_fire = FALSE

	//rags sitting around with TRUE second of burn time left is dumb.
	//ensures players always have a few seconds of burn time left when they light their rag
	if (burn_time <= 5)
		visible_message("<span class='warning'>\The [src] falls apart!</span>")
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)
	update_name()
	update_icon()

/obj/item/weapon/reagent_containers/glass/rag/process()
	if (!can_ignite())
		visible_message("<span class='warning'>\The [src] burns out.</span>")
		extinguish()

	//copied from matches
	if (isliving(loc))
		var/mob/living/M = loc
		M.IgniteMob()

	var/turf/location = get_turf(src)

	if (burn_time <= 0)
		processing_objects -= src
		new /obj/effect/decal/cleanable/ash(location)
		qdel(src)
		return

//	reagents.remove_reagent("fuel", reagents.maximum_volume/BURNING_RAG_LIFE_TICKS)
	update_name()
	burn_time--

/obj/item/weapon/reagent_containers/glass/rag/soaked/New()
	..()
	reagents.add_reagent("vodka", 10)