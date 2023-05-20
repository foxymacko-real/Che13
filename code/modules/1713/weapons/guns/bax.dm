///guns are in smg.dm

//ammo mags
/obj/item/ammo_magazine/bax2
	name = "BAX2 magazine (9mm)"
	icon_state = "bx2"
	mag_type = MAGAZINE
	caliber = "a9x19"
	ammo_type = /obj/item/ammo_casing/a9x19
	max_ammo = 35
	weight = 0.3
	multiple_sprites = TRUE

/obj/item/ammo_magazine/bax7
	name = "BAX7 magazine (5.56x45mm)"
	icon_state = "bx7"
	mag_type = MAGAZINE
	caliber = "a556x45"
	ammo_type = /obj/item/ammo_casing/a556x45
	max_ammo = 30
	weight = 0.5
	multiple_sprites = TRUE

/obj/item/ammo_magazine/bax10
	name = "BAX7 magazine (5.56x45mm)"
	icon_state = "bx7"
	mag_type = MAGAZINE
	caliber = "a556x45"
	ammo_type = /obj/item/ammo_casing/a556x45
	max_ammo = 30
	weight = 0.5
	multiple_sprites = TRUE

/obj/item/ammo_magazine/bax10
	name = "BAX10 magazine (5.70x20mm ACRASA)"
	desc = "A weird blue cointainer with crystalized something inside, you can pull out the bullets from the top."
	icon_state = "bx10"
	mag_type = MAGAZINE
	caliber = "acrasa"
	ammo_type = /obj/item/ammo_casing/a556x45
	max_ammo = 40
	weight = 0.5
	multiple_sprites = TRUE
//ammo type

/obj/item/ammo_casing/acrasa
	name = "5.70x20mm ACRASA cartridge"
	desc = "A weird brass casing."
	icon_state = "pistol-bullet"
	spent_icon = "pistol-casing"
	weight = 0.04
	projectile_type = /obj/item/projectile/bullet/special/acrasa
	caliber = "acrasa"
	value = 100
	leaves_residue = FALSE

/obj/item/projectile/bullet/special/acrasa
	icon_state = "acrasa"
	damage = DAMAGE_HIGH + 3
	penetrating = 3
	armor_penetration = 30