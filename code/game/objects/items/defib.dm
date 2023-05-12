/obj/item/defib //TODO IMPLEMENT ROTTING STAGE CHECK SO OLD PEOPLE CANT BE REVIVED (check human_life.dm)
	var/uses = 5
	name = "Military Defibrillator"
	desc = "A Field Defibrillator, perfect for reviving people. You have 5 uses left."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "dekard"
	slot_flags = SLOT_BELT|SLOT_BACK

/obj/item/defib/examine(mob/user)
	..()
	desc = "A Field Defibrillator, perfect for reviving people. <b>You have [uses] uses left.</b>"

/obj/item/defib/attack(var/mob/living/human/M as mob, var/mob/user as mob)
	if (uses > 0)
		if (M.ckey == user.ckey)
			user << "You cannot Defibrilate youself."
			return
		if (M.getBrainLoss() > 5) //no reviving people with a damaged brain or reviving headshotted people
			user << "[M] brain is too damaged."
			return
		if(M.getBruteLoss() > 210)
			user << "[M] is too damaged to revive."
			return
		if(M.adjustFireLoss() > 210)
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
				M.revive()
				sleep(1)
				M.add_chemical_effect(CE_PULSE, 1)
				M.eye_blurry = max(M.eye_blurry - 5, FALSE)
				M.AdjustParalysis(15)
				M.AdjustStunned(15)
				M.Weaken(5)
				M.drowsyness = max(M.drowsyness, 20)
				M.adjustBruteLoss(25)
				M.adjustFireLoss(25)
				M.adjustToxLoss(5)
				M.tod = null
				M.ExtinguishMob()
				M.fire_stacks = 0
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

/obj/item/defib/verb/recharge() //replace with battery charge when someone adds it
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
/obj/item/defib/civilian
	icon_state = "defibt"
	name = "Defibrillator"