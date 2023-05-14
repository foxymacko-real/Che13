/obj/item/weapon/gun/projectile/automatic/stationary/coax
	name = "Coax placeholder"
	desc = "Heavy Maxim machinegun on a tank mount, usually put into vehicles."
	icon_state = "coaxmg"
	base_icon = "coaxmg"
	load_delay = 15
	layer = MOB_LAYER + 3
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	hardness = 95
	load_method = MAGAZINE
	handle_casings = EJECT_CASINGS
	caliber = "a762x54"
	good_mags = list(/obj/item/ammo_magazine/maxim)
	magazine_type = /obj/item/ammo_magazine/maxim
	ammo_type = /obj/item/ammo_casing/a762x54

	max_shells = FALSE
	auto_eject = TRUE
	fire_sound = 'sound/weapons/guns/fire/Maxim.ogg'
	firemodes = list(
		list(name = "full auto", burst=3, burst_delay=1.5, fire_delay=1.5, dispersion=list(0.8, 0.9, 1.0, 1.0, 1.1), accuracy=list(2))
		)
	full_auto = TRUE
	fire_delay = 3
