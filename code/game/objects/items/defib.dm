
/obj/item/defib //ROTTING IMPLEMENTED (check human_life.dm)
	var/uses = 5
	var/ready = FALSE
	name = "Military Defibrillator"
	desc = "A Field Defibrillator, perfect for reviving people. You have 5 uses left."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "dekard"
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = ITEM_SIZE_NORMAL

/obj/item/defib/examine(mob/user)
	..()
	desc = "A Field Defibrillator, perfect for reviving people. <b>You have [uses] uses left.</b>"

/obj/item/defib/attack(var/mob/living/human/M as mob, var/mob/user as mob)
	if (ready == TRUE)
		user << "You need to ready the [src] before using it."
		return
		if (uses > 0)
			if (M.ckey == user.ckey)
				user << "You cannot Defibrilate youself."
				return
			if (M.getBrainLoss() > 5) //no reviving people with a damaged brain or reviving headshotted people
				user << "[M] brain is too damaged."
				return
			if (M.rotting_stage > 0) //no reviving rotted corpses
				user << "[M] is too rotted to be revived."
				return
			if(M.getBruteLoss() > 250)
				user << "[M] is too damaged to revive."
				return
			if(M.adjustFireLoss() > 250)
				user << "[M] is too burned to revive."
				return
			if (M.stat == DEAD)
				user.visible_message("<span class='notice'>[user] starts trying to revive [M].</span>", "<span class='notice'>You start Defibrillating [M].</span>")
				playsound(get_turf(src), 'sound/effects/defib_charge.ogg', 200, FALSE)
				if (do_after(user, 90, src, can_move = FALSE))
					playsound(get_turf(M), 'sound/effects/defib_release.ogg', 200, FALSE)
					if (!M.ckey && M.lastKnownCkey)
						M.ckey = M.lastKnownCkey
					user.visible_message("<font size=3>[user] Defibrilates [M]!</font>")
					uses--
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(5, TRUE, loc)
					s.start()
					if (M.stat == DEAD)
						dead_mob_list -= src
						living_mob_list += src
						M.tod = null
						M.timeofdeath = FALSE
					M.revive()
					sleep(1)
					M.add_chemical_effect(CE_PULSE, 1)
					M.eye_blurry = max(M.eye_blurry - 5, FALSE)
					M.AdjustParalysis(15)
					M.AdjustStunned(15)
					M.Weaken(5)
					M.drowsyness = max(M.drowsyness, 20)
					M.adjustBruteLoss(35)
					M.adjustFireLoss(35)
					M.adjustToxLoss(5)
					M.ExtinguishMob()
					M.fire_stacks = 0
					M.shock_stage = 0
					M.traumatic_shock = 0
					M.timeofdeath = FALSE
					M.sleeping = 0 //Short nap
					M.failed_last_breath = FALSE //So mobs that died of oxyloss don't revive and have perpetual out of breath.
					M.regenerate_icons()
					M.updatehealth()
					M.update_canmove()
					M.UpdateDamageIcon()
					M.sleep_update()
					M.updateicon()
					return
			else
				user << "You cannot revive a alive person."
				return

/obj/item/defib/ex_act()
	var/turf/t = get_turf(src)
	visible_message("<span class = 'warning'>\The [src] battery is caught in a blast which causes it to rapidly discharge and explode!</span>")
	explosion(t,0,0,1,1)
	qdel(src)

/obj/item/defib/bullet_act(var/obj/item/projectile/proj, def_zone)
	var/turf/t = get_turf(src)
	if (prob(6))
		explosion(t,0,0,1,1)
		visible_message("<span class = 'warning'>\The [src] battery is hit by a projectile which causes it to explode violently!</span>")
		qdel(src)
	else
		visible_message("<span class = 'warning'>\The [src] is hit by a projectile but absorbs it!</span>")

/obj/item/defib/verb/Recharge() //replace with battery charge when someone adds it
	set category = null
	set src in usr
	if (type != /obj/item/defib)
		return
	else
		if (uses > 4)
			usr << "<span class = 'danger'>Theres no reason to recharge the Defibrillator when it has charges.</span>"
		else
			usr << "<span class = 'danger'>You start Cranking the hand crank, this will take a while.</span>"
			playsound(get_turf(src), 'sound/effects/defib_charge.ogg', 200, FALSE)
			if (do_after(usr, 150, src, can_move = FALSE))
				uses++
				playsound(get_turf(src), 'sound/effects/defib_success.ogg', 200, FALSE)
				usr << "<span class = 'danger'>You finish cranking it.</span>"

/obj/item/defib/verb/Ready() //make it a secondary action later
	set category = null
	set src in usr
	if (type != /obj/item/defib)
		return
	else
		if (ready == TRUE)
			usr << "<span class = 'danger'>you pack up and unready the [src].</span>"
			ready = FALSE
			slot_flags = SLOT_BELT|SLOT_BACK
			w_class = ITEM_SIZE_NORMAL
			icon_state = "dekard"
		else
			usr << "<span class = 'danger'>You take out the defib and start preparing it.</span>"
			if (do_after(usr, 50, src, can_move = FALSE))
				ready = TRUE
				playsound(get_turf(src), 'sound/effects/defib_success.ogg', 200, FALSE)
				usr << "<span class = 'danger'>You finish preparing it.</span>"
				slot_flags = FALSE
				w_class = ITEM_SIZE_LARGE
				icon_state = "dekard_r"

/obj/item/defib/civilian
	icon_state = "defibt"
	name = "Defibrillator"