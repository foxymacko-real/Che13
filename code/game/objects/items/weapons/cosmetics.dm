/obj/item/weapon/lipstick
	gender = PLURAL
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	var/colour = "red"
	var/open = FALSE


/obj/item/weapon/lipstick/purple
	name = "purple lipstick"
	colour = "purple"
	flags = FALSE

/obj/item/weapon/lipstick/jade
	name = "jade lipstick"
	colour = "jade"

/obj/item/weapon/lipstick/black
	name = "black lipstick"
	colour = "black"


/obj/item/weapon/lipstick/random
	name = "lipstick"

/obj/item/weapon/lipstick/random/New()
	colour = pick("red","purple","jade","black")
	name = "[colour] lipstick"


/obj/item/weapon/lipstick/attack_self(mob/user as mob)
	user << "<span class='notice'>You twist \the [src] [open ? "closed" : "open"].</span>"
	open = !open
	if (open)
		icon_state = "[initial(icon_state)]_[colour]"
	else
		icon_state = initial(icon_state)

/obj/item/weapon/lipstick/attack(mob/M as mob, mob/user as mob)
	if (!open)	return

	if (!istype(M, /mob))	return

	if (ishuman(M))
		var/mob/living/human/H = M
		if (H.lip_style)	//if they already have lipstick on
			user << "<span class='notice'>You need to wipe off the old lipstick first!</span>"
			return
		if (H == user)
			user.visible_message("<span class='notice'>[user] does their lips with \the [src].</span>", \
								 "<span class='notice'>You take a moment to apply \the [src]. Perfect!</span>")
			H.lip_style = colour
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to do [H]'s lips with \the [src].</span>", \
								 "<span class='notice'>You begin to apply \the [src].</span>")
			if (do_after(user, 20, H) && do_after(H, 20, needshand = FALSE))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] does [H]'s lips with \the [src].</span>", \
									 "<span class='notice'>You apply \the [src].</span>")
				H.lip_style = colour
				H.update_body()
	else
		user << "<span class='notice'>Where are the lips on that?</span>"

//you can wipe off lipstick with paper! see code/modules/paperwork/paper.dm, paper/attack()


/obj/item/weapon/haircomb //sparklysheep's comb
	name = "comb"
	desc = "A pristine comb made from flexible plastic."
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	icon = 'icons/obj/items.dmi'
	icon_state = "purplecomb"
	item_state = "comb"
	flammable = TRUE
	flags = FALSE

/obj/item/weapon/haircomb/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user] uses [src] to comb their hair neatly a [user.gender == FEMALE ? "lady" : "guy"].</span>")