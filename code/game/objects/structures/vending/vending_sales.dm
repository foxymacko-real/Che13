/**
 *  A vending machine / market stall that actually charges per sale.
 */
/obj/structure/vending/sales
	name = "Vending Machine"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "snack"
	layer = 2.9
	anchored = TRUE
	density = TRUE
	flammable = FALSE
	not_movable = FALSE
	not_disassemblable = TRUE

	var/moneyin = 0
	var/owner = "Global"
	var/max_products = 5

/obj/structure/vending/ex_act(severity)
	return

/obj/structure/vending/sales/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/stack/money))
		var/obj/item/stack/money/M = W
		moneyin += M.amount*M.value
		if (map.ID == MAP_SOVAFGHAN)
			user << "You give \the [W] to the [src]."
		else
			user << "You put \the [W] in the [src]."
		qdel(W)
		return
	else if (istype(W, /obj/item/weapon/wrench))
		if (owner != "Global" && find_company_member(user,owner))
			playsound(loc, 'sound/items/Ratchet.ogg', 100, TRUE)
			if (anchored)
				user.visible_message("[user] begins unsecuring \the [src] from the floor.", "You start unsecuring \the [src] from the floor.")
			else
				user.visible_message("[user] begins securing \the [src] to the floor.", "You start securing \the [src] to the floor.")

			if (do_after(user, 20, src))
				if (!src) return
				user << "<span class='notice'>You [anchored? "un" : ""]secured \the [src]!</span>"
				anchored = !anchored
			return

	else
		if (owner != "Global" && find_company_member(user,owner))
			for (var/datum/data/vending_product/R in product_records)
				if (istype(W, R.product_path) && W.name == R.product_name)
					if (istype(W, /obj/item/stack))
						R.amount += W.amount
						qdel(W)
						return TRUE
					else
						stock(W, R, user)
						return TRUE
			//if it isnt in the list yet
			if (product_records.len >= max_products)
				var/datum/data/vending_product/free = null
				for (var/datum/data/vending_product/R in product_records)
					if (R.amount <= 0)
						free=R
				if (!free)
					user << "<span class='notice'>This [src] has too many different products already!</span>"
					return FALSE
				else
					product_records -= free
			user.unEquip(W)
			var/datum/data/vending_product/product = new/datum/data/vending_product(src, W.type, W.name, _icon = W.icon, _icon_state = W.icon_state, M = W)
			var/inputp = input(user, "What price do you want to set for \the [W]? (in silver coins)") as num
			if (!inputp)
				inputp = 0
			if (inputp < 0)
				inputp = 0
			product.price = inputp
			if (istype(W, /obj/item/stack))
				var/obj/item/stack/S = W
				product.amount = S.amount
				qdel(W)
			else
				if (W)
					W.forceMove(src)
			product_records.Add(product)
			update_icon()
			return TRUE
/obj/structure/vending/sales/verb/Manage()
	set category = null
	set src in range(1, usr)


	if (!istype(usr, /mob/living/human))
		return

	if (owner != "Global" && find_company_member(usr,owner))
		var/choice1 = WWinput(usr, "What do you want to do?", "Vendor Management", "Exit", list("Exit", "Change Name", "Change Prices", "Remove Product"))
		if (choice1 == "Exit")
			return TRUE
		else if (choice1 == "Change Name")
			var/input1 = input("What name do you want to give to this vendor?", "Vendor Name", name) as text
			if (input1 == null || input1 == "")
				return FALSE
			else
				name = input1
				return TRUE
		else if (choice1 == "Change Prices")
			var/list/choicelist = list("Exit")
			for(var/datum/data/vending_product/VP in product_records)
				choicelist += VP.product_name
			var/choice2 = WWinput(usr, "What product to change the price?", "Vendor Management", "Exit", choicelist)
			if (choice2 == "Exit")
				return FALSE
			else
				for(var/datum/data/vending_product/VP in product_records)
					if (VP.product_name == choice2)
						var/input3 = input("The current price for [VP.product_name] is [VP.price] silver coins. What should the new price be?", "Product Price", VP.price) as num
						if (input3 < 0 || input3 == null)
							return FALSE
						else
							VP.price = input3
							return TRUE
		else if (choice1 == "Remove Product")
			var/list/choicelist = list("Exit")
			for(var/datum/data/vending_product/VP in product_records)
				choicelist += VP.product_name
			var/choice2 = WWinput(usr, "What product to remove?", "Vendor Management", "Exit", choicelist)
			if (choice2 == "Exit")
				return FALSE
			else
				for(var/datum/data/vending_product/VP in product_records)
					if (VP.product_name == choice2)
						vend(VP, usr, VP.amount)
						return TRUE


	else
		usr << "You do not have permission to manage this vendor."
		return FALSE

/obj/structure/vending/sales/vend(datum/data/vending_product/R, mob/user, var/p_amount=1)
	vend_ready = FALSE //One thing at a time!!
	status_message = "Vending..."
	status_error = FALSE
	nanomanager.update_uis(src)

	spawn(vend_delay)
		R.get_product(get_turf(src),p_amount,user)
		playsound(loc, 'sound/machines/vending_drop.ogg', 100, TRUE)
		status_message = ""
		status_error = FALSE
		vend_ready = TRUE
		currently_vending = null
		update_icon()
		nanomanager.update_uis(src)

/**
 * Add item to the machine
 *
 * Checks if item is vendable in this machine should be performed before
 * calling. W is the item being inserted, R is the associated vending_product entry.
 */

/obj/structure/vending/sales/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = TRUE)
	user.set_using_object(src)

	var/list/data = list()
	if (currently_vending)
		data["mode"] = TRUE
		data["company"] = owner
		data["product"] = currently_vending.product_name
		if (map.ID == MAP_THE_ART_OF_THE_DEAL)
			data["price"] = currently_vending.price/4
		else
			data["price"] = currently_vending.price
		data["message_err"] = FALSE
		data["message"] = status_message
		data["message_err"] = status_error
		if (map.ID == MAP_THE_ART_OF_THE_DEAL)
			data["moneyin"] = moneyin/4
		else
			data["moneyin"] = moneyin
	else
		data["mode"] = FALSE
		data["company"] = owner
		if (map.ID == MAP_THE_ART_OF_THE_DEAL)
			data["moneyin"] = moneyin/4
		else
			data["moneyin"] = moneyin
		var/list/listed_products = list()

		for (var/key = TRUE to product_records.len)
			var/datum/data/vending_product/I = product_records[key]
			if (map.ID == MAP_THE_ART_OF_THE_DEAL)
				listed_products.Add(list(list(
					"key" = key,
					"name" = I.product_name,
					"price" = I.price/4,
					"color" = I.display_color,
					"amount" = I.amount)))
			else
				listed_products.Add(list(list(
					"key" = key,
					"name" = I.product_name,
					"price" = I.price,
					"color" = I.display_color,
					"amount" = I.amount)))

		data["products"] = listed_products

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		if (map.ID == MAP_THE_ART_OF_THE_DEAL)
			ui = new(user, src, ui_key, "vending_machine_taotd.tmpl", name, 440, 600)
		else if (map.ID == MAP_GULAG13)
			ui = new(user, src, ui_key, "vending_machine_gulag.tmpl", name, 440, 600)
		else if (map.ID == MAP_SOVAFGHAN)
			ui = new(user, src, ui_key, "vending_machine_taotd.tmpl", name, 440, 600)
		else
			ui = new(user, src, ui_key, "vending_machine2.tmpl", name, 440, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/structure/vending/sales/Topic(href, href_list)
	if (isliving(usr))
		if (usr.stat || usr.restrained())
			return
	else if (isobserver(usr))
		if (!check_rights(R_MOD))
			return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))))
		if ((href_list["vend"]) && (vend_ready) && (!currently_vending))

			if (find_company_member(usr,owner))
				usr << "<span class='warning'>You can't buy from your own company. Remove the product instead.</span>"
				status_error = FALSE
				currently_vending = null
			else

				var/key = text2num(href_list["vend"])
				var/datum/data/vending_product/R = product_records[key]

				var/inp = 1
				if (R.amount > 1)
					inp = input(usr, "How many do you want to buy? (1 to [R.amount])",1) as num
					if (inp>R.amount)
						inp = R.amount
					else if (inp<=1)
						inp = 1

				if (R.price <= 0)
					vend(R, usr, inp)

				else
					var/mob/living/human/H = usr
					var/salestax = 0
					if (map.ID != MAP_SOVAFGHAN)
						if (H.civilization != "none")
							salestax = (map.custom_civs[H.civilization][9]/100)*R.price
					var/price_with_tax = R.price+salestax
					currently_vending = R
					if (moneyin < price_with_tax*inp)
						status_message = "Please insert money to pay for the item."
						status_error = FALSE
					else
						moneyin -= price_with_tax*inp
						if (owner != "Global")
							map.custom_company_value[owner] += price_with_tax*inp
							if (map.custom_civs[H.civilization])
								map.custom_civs[H.civilization][5] += salestax*inp
						if (map.ID == MAP_THE_ART_OF_THE_DEAL)
							var/obj/item/stack/money/dollar/D = new/obj/item/stack/money/dollar(loc)
							D.amount = moneyin/D.value
							if (D.amount == 0)
								qdel(D)
						else if (map.ID == MAP_GULAG13)
							var/obj/item/stack/money/rubles/D = new/obj/item/stack/money/rubles(loc)
							D.amount = moneyin/D.value
							if (D.amount == 0)
								qdel(D)
						else if (map.ID == MAP_SOVAFGHAN)
							var/obj/item/stack/money/dollar/D = new/obj/item/stack/money/dollar(loc)
							D.amount = moneyin/D.value
							if (D.amount == 0)
								qdel(D)
						else
							if (moneyin > 0 && moneyin <= 3)
								var/obj/item/stack/money/coppercoin/NM = new/obj/item/stack/money/coppercoin(loc)
								NM.amount = moneyin/NM.value
								if (NM.amount <= 0)
									qdel(NM)
							else if (moneyin > 3 && moneyin <= 40)
								var/obj/item/stack/money/silvercoin/NM = new/obj/item/stack/money/silvercoin(loc)
								NM.amount = moneyin/NM.value
								if (NM.amount <= 0)
									qdel(NM)
							else
								var/obj/item/stack/money/goldcoin/NM = new/obj/item/stack/money/goldcoin(loc)
								NM.amount = moneyin/NM.value
								if (NM.amount <= 0)
									qdel(NM)
						moneyin = 0
						vend(R, usr, inp)
						nanomanager.update_uis(src)

		else if (href_list["cancelpurchase"])
			currently_vending = null

		else if (href_list["remove_money"])
			if (map.ID == MAP_THE_ART_OF_THE_DEAL)
				var/obj/item/stack/money/dollar/D = new/obj/item/stack/money/dollar(loc)
				D.amount = moneyin/D.value
				if (D.amount == 0)
					qdel(D)
			else if (map.ID == MAP_GULAG13)
				var/obj/item/stack/money/rubles/D = new/obj/item/stack/money/rubles(loc)
				D.amount = moneyin/D.value
				if (D.amount == 0)
					qdel(D)
			else if (map.ID == MAP_SOVAFGHAN)
				var/obj/item/stack/money/dollar/D = new/obj/item/stack/money/dollar(loc)
				D.amount = moneyin/D.value
				if (D.amount == 0)
					qdel(D)
			else
				var/obj/item/stack/money/goldcoin/GC = new/obj/item/stack/money/goldcoin(loc)
				GC.amount = moneyin/GC.value
				if (GC.amount == 0)
					qdel(GC)
			moneyin = 0
			nanomanager.update_uis(src)
			return

		add_fingerprint(usr)
		playsound(usr.loc, 'sound/machines/button.ogg', 100, TRUE)
		nanomanager.update_uis(src)


//VENDING MACHINES
/obj/structure/vending/sales/food
	name = "food vending machine"
	desc = "Basic food products."
	icon_state = "nutrimat"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 15,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 0.15,
	)

/obj/structure/vending/sales/food/fruits
	name = "fruit vending machine"
	desc = "Basic food products."
	icon_state = "nutrimat"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 15,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 15,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange = 15,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherry = 15,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apricot = 15,
		/obj/item/weapon/reagent_containers/food/snacks/grown/coconut = 15,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 8,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 8,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange = 8,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherry = 8,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apricot = 8,
		/obj/item/weapon/reagent_containers/food/snacks/grown/coconut = 8,
	)
/obj/structure/vending/sales/food/snacks
	name = "baker's vending machine"
	desc = "Basic food products."
	icon_state = "snack"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich = 15,
		/obj/item/weapon/reagent_containers/food/snacks/sandwich = 15,
		/obj/item/weapon/reagent_containers/food/snacks/grilledcheese = 15,
		/obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice = 15,
		/obj/item/weapon/reagent_containers/food/snacks/bananabreadslice = 15,
		/obj/item/weapon/reagent_containers/food/snacks/applecakeslice = 15,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich = 20,
		/obj/item/weapon/reagent_containers/food/snacks/sandwich = 20,
		/obj/item/weapon/reagent_containers/food/snacks/grilledcheese = 20,
		/obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice = 16,
		/obj/item/weapon/reagent_containers/food/snacks/bananabreadslice = 16,
		/obj/item/weapon/reagent_containers/food/snacks/applecakeslice = 16,
	)

/obj/structure/vending/sales/food/hot
	name = "hot meal vending machine"
	desc = "Basic food products."
	icon_state = "hotfood"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatballspagetti = 15,
		/obj/item/weapon/reagent_containers/food/snacks/meatpie = 15,
		/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup = 15,
		/obj/item/weapon/reagent_containers/food/snacks/grilledcheese = 20,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatballspagetti = 20,
		/obj/item/weapon/reagent_containers/food/snacks/meatpie = 15,
		/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup = 10,
		/obj/item/weapon/reagent_containers/food/snacks/grilledcheese = 10,
	)

/obj/structure/vending/sales/drinks
	name = "drinks vending machine"
	desc = "Basic beverages."
	icon_state = "soda"
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/can/cola = 15,
		/obj/item/weapon/reagent_containers/food/drinks/can/tonic = 15,
		/obj/item/weapon/reagent_containers/food/drinks/can/ice_tea = 15,
		/obj/item/weapon/reagent_containers/food/drinks/can/lemonade = 15,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/plastic/water = 10,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/drinks/can/cola = 5,
		/obj/item/weapon/reagent_containers/food/drinks/can/tonic = 5,
		/obj/item/weapon/reagent_containers/food/drinks/can/ice_tea = 5,
		/obj/item/weapon/reagent_containers/food/drinks/can/lemonade = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/plastic/water  = 5,
	)
/obj/structure/vending/sales/drinks/cola
	name = "cola vending machine"
	icon_state = "cola"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/can/cola = 30)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/can/cola = 5)

/obj/structure/vending/sales/drinks/soviet //To be filled with appropriate drink when its added
	icon_state = "sovietsoda"
	products = list()
	prices = list()

/obj/structure/vending/sales/drinks/hot
	name = "hot drinks vending machine"
	desc = "Basic hot beverages."
	icon_state = "coffee"
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/coffee = 20,
		/obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 20,
		/obj/item/weapon/reagent_containers/food/drinks/tea = 20,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/drinks/coffee = 10,
		/obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 10,
		/obj/item/weapon/reagent_containers/food/drinks/tea = 10,
	)

/obj/structure/vending/sales/cigarettes
	name = "cigarette vending machine"
	desc = "Have a break, take a smoke."
	icon_state = "cigs"
	products = list(
		/obj/item/weapon/storage/fancy/cigarettes/marlboro = 10,
		/obj/item/weapon/storage/fancy/cigarettes/luckystrike = 10,
		/obj/item/weapon/storage/fancy/cigarettes/newport = 10,
		/obj/item/weapon/storage/fancy/cigarettes/prima = 10,
		/obj/item/weapon/flame/lighter/random = 15,
		/obj/item/weapon/flame/lighter/zippo = 2,
		/obj/item/weapon/matchbox = 20,
	)
	prices = list(
		/obj/item/weapon/storage/fancy/cigarettes/marlboro = 10,
		/obj/item/weapon/storage/fancy/cigarettes/luckystrike = 10,
		/obj/item/weapon/storage/fancy/cigarettes/newport = 10,
		/obj/item/weapon/storage/fancy/cigarettes/prima = 10,
		/obj/item/weapon/flame/lighter/random = 5,
		/obj/item/weapon/flame/lighter/zippo = 50,
		/obj/item/weapon/matchbox = 5,
	)
// MARKET STALLS//
/obj/structure/vending/sales/market_stall/prepared
	name = "market stall"
	desc = "A market stall selling an assortment of goods."
	icon_state = "market_stall"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 10,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage = 10,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 10,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread = 10

	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1.5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage = 1.5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 1.5,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread = 3.5
	)
	New()
		..()
		spawn(20)
			update_icon()

/obj/structure/vending/sales/market_stall/prepared/gulag
	name = "apparel comissary"
	desc = "A prison vending stall where prisoners can spend their hard-earned Rubles."
	products = list(
		/obj/item/clothing/gloves/watch/goldwatch = 5,
		/obj/item/clothing/glasses/monocle = 20,
		/obj/item/clothing/glasses/sunglasses = 20,
		/obj/item/clothing/head/bowler_hat = 20,
		/obj/item/clothing/suit/storage/coat/fancy_fur_coat = 5
	)
	prices = list(
		/obj/item/clothing/gloves/watch/goldwatch = 200,
		/obj/item/clothing/glasses/monocle = 50,
		/obj/item/clothing/glasses/sunglasses = 30,
		/obj/item/clothing/head/bowler_hat = 40,
		/obj/item/clothing/suit/storage/coat/fancy_fur_coat = 200
	)

/obj/structure/vending/sales/market_stall/prepared/gulag/food
	name = "food comissary"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread = 50,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 50,
		/obj/item/weapon/reagent_containers/food/snacks/sausage/salted/salami = 50,
		/obj/item/weapon/reagent_containers/food/snacks/meatpie = 50,
		/obj/item/weapon/reagent_containers/food/snacks/sandwich = 50
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread = 10,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 5,
		/obj/item/weapon/reagent_containers/food/snacks/sausage/salted/salami = 15,
		/obj/item/weapon/reagent_containers/food/snacks/meatpie = 15,
		/obj/item/weapon/reagent_containers/food/snacks/sandwich = 15
	)

/obj/structure/vending/sales/market_stall/prepared/gulag/consumables
	name = "consumables comissary"
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 50,
		/obj/item/weapon/storage/fancy/cigarettes/randompack/lighter = 50,
		/obj/item/weapon/storage/fancy/cigar/full = 50,
		/obj/item/weapon/reagent_containers/pill/cocaine = 50,
		/obj/item/clothing/mask/smokable/cigarette/joint = 50
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 40,
		/obj/item/weapon/storage/fancy/cigarettes/randompack/lighter = 15,
		/obj/item/weapon/storage/fancy/cigar/full = 180,
		/obj/item/weapon/reagent_containers/pill/cocaine = 200,
		/obj/item/clothing/mask/smokable/cigarette/joint = 70
	)

////MONEY COUNTER

/obj/structure/vending/sales/moneycounter
	name = "currency counter"
	desc = "Useful for easily merging piles of money into one clean stack."
	icon_state = "CurrencyCounter"
	products = list()
	prices = list()

////MARKET STALL AND VENDORS CUSTOM OBJECTS////
/obj/structure/vending/sales/market_stall
	name = "market stall"
	desc = "A market stall selling an assortment of goods."
	icon_state = "market_stall"
	var/image/overlay_primary = null
	var/image/overlay_secondary = null

/obj/structure/vending/sales/market_stall/New()
	..()
	invisibility = 101
	spawn(3)
		overlay_primary = image(icon = icon, icon_state = "[icon_state]_overlay_primary")
		overlay_primary.color = map.custom_company_colors[owner][1]
		overlay_secondary = image(icon = icon, icon_state = "[icon_state]_overlay_secondary")
		overlay_secondary.color = map.custom_company_colors[owner][2]
		update_icon()
		invisibility = 0

/obj/structure/vending/sales/market_stall/update_icon()
	overlays.Cut()
	if (overlay_primary && overlay_secondary)
		overlay_primary.color = map.custom_company_colors[owner][1]
		overlay_secondary.color = map.custom_company_colors[owner][2]
		overlays += overlay_primary
		overlays += overlay_secondary
	var/ct1 = 0
	for(var/datum/data/vending_product/VP in product_records)
		if (VP.product_image)
			var/image/NI = VP.product_image
			NI.layer = layer+0.01
			var/matrix/M = matrix()
			M.Scale(0.5)
			NI.transform = M
			NI.pixel_x = -10+ct1
			NI.pixel_y = -4
			overlays += NI
			ct1+=4

/obj/structure/vending/sales/vending
	name = "vending machine"
	desc = "A vending machine selling an assortment of goods."
	icon_state = "custom2"
	var/image/overlay_primary = null
	var/image/overlay_secondary = null
	max_products = 10

/obj/structure/vending/sales/vending/New()
	..()
	invisibility = 101
	spawn(3)
		overlay_primary = image(icon = icon, icon_state = "[icon_state]_overlay_primary")
		overlay_primary.color = map.custom_company_colors[owner][1]
		overlay_secondary = image(icon = icon, icon_state = "[icon_state]_overlay_secondary")
		overlay_secondary.color = map.custom_company_colors[owner][2]
		update_icon()
		invisibility = 0

/obj/structure/vending/sales/vending/update_icon()
	overlays.Cut()
	if (overlay_primary && overlay_secondary)
		overlay_primary.color = map.custom_company_colors[owner][1]
		overlay_secondary.color = map.custom_company_colors[owner][2]
		overlays += overlay_primary
		overlays += overlay_secondary
		overlays += image(icon = icon, icon_state = "[icon_state]_base")

/obj/structure/vending/sales/stock(obj/item/W, var/datum/data/vending_product/R, var/mob/user)
	if (!user.unEquip(W))
		return

	user << "<span class='notice'>You insert \the [W] in \the [src].</span>"
	if (istype(W, /obj/item/stack))
		var/obj/item/stack/S = W
		R.amount += S.amount
		qdel(W)
	else
		W.forceMove(src)
		R.product_item += W
		R.amount++
	nanomanager.update_uis(src)

/obj/structure/vending/process()

	if (!active)
		return

	return

//vending exports

/obj/structure/vending/sales/ffa/clothingbasic
	name = "Clothing Shop"
	desc = "Cointains clothing."
	icon_state = "apparel_usa"
	products = list(
		/obj/item/clothing/under/tacticool_hawaiian = 10,
		/obj/item/clothing/under/tacticool_hawaiian/green = 10,
		/obj/item/clothing/under/tacticool_hawaiian/orange = 10,
		/obj/item/clothing/under/tacticool_hawaiian/purple = 10,
		/obj/item/clothing/under/ww2/civ1 = 5,
		/obj/item/clothing/under/ww2/civ2 = 5,
		/obj/item/clothing/under/ww2/soviet_amoeba/winter = 5,
		/obj/item/clothing/under/ww2/soviet_berezka = 5,
		/obj/item/clothing/under/sov_klmk = 5,
		/obj/item/clothing/under/sov_kzs = 5,
		/obj/item/clothing/under/tacti = 5,
		/obj/item/clothing/under/tactical1 = 5,
		/obj/item/clothing/under/gorka/frag = 5,
		/obj/item/clothing/head/chinaguardcap = 5,
		/obj/item/clothing/head/sov_ushanka_new = 5,
		/obj/item/clothing/head/olivebandana = 9,
		/obj/item/clothing/head/flatcap1 = 9,
		/obj/item/clothing/head/flatcap2 = 9,
		/obj/item/clothing/head/flatcap3 = 9,
		/obj/item/clothing/head/commando_bandana = 9,
	)
	prices = list(
		/obj/item/clothing/under/tacticool_hawaiian = 50,
		/obj/item/clothing/under/tacticool_hawaiian/green = 50,
		/obj/item/clothing/under/tacticool_hawaiian/orange = 50,
		/obj/item/clothing/under/tacticool_hawaiian/purple = 50,
		/obj/item/clothing/under/ww2/civ1 = 50,
		/obj/item/clothing/under/ww2/civ2 = 50,
		/obj/item/clothing/under/ww2/soviet_amoeba/winter = 70,
		/obj/item/clothing/under/ww2/soviet_berezka = 70,
		/obj/item/clothing/under/sov_klmk = 80,
		/obj/item/clothing/under/sov_kzs = 80,
		/obj/item/clothing/under/tacti = 120,
		/obj/item/clothing/under/tactical1 = 120,
		/obj/item/clothing/under/gorka/frag = 160,
		/obj/item/clothing/head/chinaguardcap = 65,
		/obj/item/clothing/head/sov_ushanka_new = 100,
		/obj/item/clothing/head/olivebandana = 55,
		/obj/item/clothing/head/flatcap1 = 55,
		/obj/item/clothing/head/flatcap2 = 55,
		/obj/item/clothing/head/flatcap3 = 55,
		/obj/item/clothing/head/commando_bandana = 55,
	)

/obj/structure/vending/sales/ffa/bootsaglovesbasic
	name = "Shoes and boots Shop"
	desc = "Cointains boots and gloves."
	icon_state = "apparel_german2"
	products = list(
		/obj/item/clothing/gloves/fingerless = 5,
		/obj/item/clothing/gloves/thick = 10,
		/obj/item/clothing/gloves/thick/combat = 10,
		/obj/item/clothing/gloves/toughguy = 5,
		/obj/item/clothing/shoes/leather = 35,
		/obj/item/clothing/shoes/workboots = 25,
		/obj/item/clothing/shoes/soldiershoes = 10,
		/obj/item/clothing/shoes/jackboots = 10,
		/obj/item/clothing/shoes/iogboots/black = 5,
	)
	prices = list(
		/obj/item/clothing/gloves/fingerless = 25,
		/obj/item/clothing/gloves/thick = 50,
		/obj/item/clothing/gloves/thick/combat = 80,
		/obj/item/clothing/gloves/toughguy = 70,
		/obj/item/clothing/shoes/leather = 35,
		/obj/item/clothing/shoes/workboots = 45,
		/obj/item/clothing/shoes/soldiershoes = 60,
		/obj/item/clothing/shoes/jackboots = 70,
		/obj/item/clothing/shoes/iogboots/black = 200,
	)

/obj/structure/vending/sales/ffa/weaponry
	name = "Weaponry Shop"
	desc = "Cointains Weapons and ammo for them."
	icon_state = "equipment_russia"
	products = list(
		/obj/item/weapon/gun/projectile/boltaction/singleshot/makeshiftbolt = 5,
		/obj/item/weapon/gun/projectile/boltaction/mosin/m30 = 10,
		/obj/item/ammo_magazine/mosin = 50,
		/obj/item/ammo_magazine/mosinbox = 20,
		/obj/item/weapon/gun/projectile/semiautomatic/svt = 20,
		/obj/item/ammo_magazine/svt = 40,
		/obj/item/weapon/gun/projectile/submachinegun/makeshiftak47 = 25,
		/obj/item/weapon/gun/projectile/submachinegun/ak47/akms = 27,
		/obj/item/ammo_magazine/ak47 = 60,
		/obj/item/weapon/gun/projectile/submachinegun/ermaemp = 20,
		/obj/item/weapon/gun/projectile/submachinegun/mp40 = 30,
		/obj/item/ammo_magazine/mp40/box = 25,
		/obj/item/ammo_magazine/mp40 = 30,
		/obj/item/weapon/gun/projectile/submachinegun/sten = 20,
		/obj/item/ammo_magazine/sten2 = 30,
		/obj/item/weapon/gun/projectile/pistol/glock17 = 20,
		/obj/item/ammo_magazine/glock17 = 90,
		/obj/item/weapon/gun/projectile/submachinegun/ak74/aks74 = 35,
		/obj/item/weapon/gun/projectile/submachinegun/ak74 = 30,
		/obj/item/weapon/gun/projectile/submachinegun/ak74m = 30,
		/obj/item/ammo_magazine/ak74 = 90,
		/obj/item/ammo_magazine/ak74/box = 30,
		/obj/item/weapon/gun/projectile/submachinegun/m16 = 30,
		/obj/item/weapon/gun/projectile/submachinegun/m16/commando/m4 = 20,
		/obj/item/weapon/gun/projectile/submachinegun/m16/m16a4 = 20,
		/obj/item/ammo_magazine/m16 = 90,
		/obj/item/ammo_magazine/m16/box = 30,
		/obj/item/weapon/gun/projectile/pistol/makarov = 30,
		/obj/item/ammo_magazine/makarov = 90,
	)
	prices = list(
		/obj/item/weapon/gun/projectile/boltaction/singleshot/makeshiftbolt = 250,
		/obj/item/weapon/gun/projectile/boltaction/mosin/m30 = 350,
		/obj/item/ammo_magazine/mosin = 200,
		/obj/item/ammo_magazine/mosinbox = 600,
		/obj/item/weapon/gun/projectile/semiautomatic/svt = 430,
		/obj/item/ammo_magazine/svt = 400,
		/obj/item/weapon/gun/projectile/submachinegun/makeshiftak47 = 350,
		/obj/item/weapon/gun/projectile/submachinegun/ak47/akms = 450,
		/obj/item/ammo_magazine/ak47 = 520,
		/obj/item/weapon/gun/projectile/submachinegun/ermaemp = 300,
		/obj/item/weapon/gun/projectile/submachinegun/mp40 = 340,
		/obj/item/ammo_magazine/mp40/box = 455,
		/obj/item/ammo_magazine/mp40 = 115,
		/obj/item/weapon/gun/projectile/submachinegun/sten = 290,
		/obj/item/ammo_magazine/sten2 = 105,
		/obj/item/weapon/gun/projectile/pistol/glock17 = 280,
		/obj/item/ammo_magazine/glock17 = 100,
		/obj/item/weapon/gun/projectile/submachinegun/ak74/aks74 = 505,
		/obj/item/weapon/gun/projectile/submachinegun/ak74 = 520,
		/obj/item/weapon/gun/projectile/submachinegun/ak74m = 600,
		/obj/item/ammo_magazine/ak74 = 300,
		/obj/item/ammo_magazine/ak74/box = 490,
		/obj/item/weapon/gun/projectile/submachinegun/m16 = 520,
		/obj/item/weapon/gun/projectile/submachinegun/m16/commando/m4 = 550,
		/obj/item/weapon/gun/projectile/submachinegun/m16/m16a4 = 650,
		/obj/item/ammo_magazine/m16 = 320,
		/obj/item/ammo_magazine/m16/box = 530,
		/obj/item/weapon/gun/projectile/pistol/makarov = 290,
		/obj/item/ammo_magazine/makarov = 95,
	)

/obj/structure/vending/sales/ffa/heavyweaponry
	name = "Heavy Support Weaponry Shop"
	desc = "Cointains Deployable Heavy Support weapons and ammo for them and some other things too, Devastating but not cheap."
	icon_state = "modern_british"
	products = list(
		/obj/item/weapon/foldable/pkm = 5,
		/obj/item/weapon/gun/projectile/automatic/pkm = 5,
		/obj/item/ammo_magazine/pkm = 20,
		/obj/item/ammo_magazine/pkm/c100 = 20,
		/obj/item/weapon/foldable/generic = 2,
		/obj/item/cannon_ball/mortar_shell = 80,
		/obj/item/cannon_ball/mortar_shell/smoke = 40,
		/obj/item/weapon/foldable/atgm = 2,
		/obj/item/weapon/storage/backpack/heavyrucksack/atgm = 2,
		/obj/item/ammo_casing/rocket/atgm = 5,
		/obj/item/ammo_casing/rocket/atgm/apcr = 5,
		/obj/item/ammo_casing/rocket/atgm/he = 5,
		/obj/item/weapon/gun/projectile/automatic/dp28 = 5,
		/obj/item/ammo_magazine/dp = 45,
		/obj/item/weapon/gun/projectile/boltaction/singleshot/ptrd = 2,
		/obj/item/ammo_magazine/ptrd_pouch = 5,
		/obj/item/ammo_magazine/ptrd_pouch/ap = 5,
		/obj/item/weapon/grenade/antitank/custom = 5,
		/obj/item/weapon/grenade/smokebomb = 25,
		/obj/item/weapon/grenade/modern/custom = 15,
		/obj/item/weapon/gun/launcher/rocket/single_shot/rpg22 = 2,
	)
	prices = list(
		/obj/item/weapon/foldable/pkm = 700,
		/obj/item/weapon/gun/projectile/automatic/pkm = 550,
		/obj/item/ammo_magazine/pkm = 600,
		/obj/item/ammo_magazine/pkm/c100 = 400,
		/obj/item/weapon/foldable/generic = 600,
		/obj/item/cannon_ball/mortar_shell = 350,
		/obj/item/cannon_ball/mortar_shell/smoke = 390,
		/obj/item/weapon/foldable/atgm = 900,
		/obj/item/weapon/storage/backpack/heavyrucksack/atgm = 700,
		/obj/item/ammo_casing/rocket/atgm = 250,
		/obj/item/ammo_casing/rocket/atgm/apcr = 300,
		/obj/item/ammo_casing/rocket/atgm/he = 250,
		/obj/item/weapon/gun/projectile/automatic/dp28 = 450,
		/obj/item/ammo_magazine/dp = 400,
		/obj/item/weapon/gun/projectile/boltaction/singleshot/ptrd = 600,
		/obj/item/ammo_magazine/ptrd_pouch = 600,
		/obj/item/ammo_magazine/ptrd_pouch/ap = 650,
		/obj/item/weapon/grenade/antitank/custom = 250,
		/obj/item/weapon/grenade/smokebomb = 150,
		/obj/item/weapon/grenade/modern/custom = 190,
		/obj/item/weapon/gun/launcher/rocket/single_shot/rpg22 = 800,
	)

/obj/structure/vending/sales/ffa/survivaltools
	name = "Survival tools shop"
	desc = "Cointains equipment that might increase your odds of survival."
	icon_state = "apparel_pirates"
	products = list(
		/obj/item/weapon/attachment/bayonet = 50,
		/obj/item/weapon/reagent_containers/food/snacks/MRE/generic/american = 50,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/canteen/full = 25,
		/obj/item/weapon/attachment/scope/adjustable/binoculars/binoculars = 25,
		/obj/item/weapon/compass = 25,
		/obj/item/weapon/foldable_shovel/trench/etool = 50,
		/obj/item/weapon/gun_cleaning_kit = 50,
		/obj/item/weapon/storage/toolbox/emergency = 20,
		/obj/item/weapon/tent = 20,
		/obj/item/weapon/radio = 20,
		/obj/item/weapon/radio/walkietalkie = 20,
		/obj/item/weapon/bedroll = 20,
		/obj/item/weapon/foldable/antitankkit = 50,
		/obj/item/weapon/foldable/hescokit = 50,
		/obj/item/weapon/storage/box/sandbags = 50,
		/obj/item/stack/medical/bruise_pack/gauze = 50,
		/obj/item/weapon/storage/box/firstaid/advsmall = 6,
		/obj/item/weapon/storage/box/firstaid/basicsmall = 6,
		/obj/item/clothing/mask/gas/soviet/gp5 = 50,
		/obj/item/clothing/glasses/nvg = 7,
		/obj/item/clothing/glasses/thermal = 9,
		/obj/item/weapon/storage/box/canned = 25,
		/obj/item/weapon/storage/box/flare = 25,
		/obj/item/weapon/flame/lighter/zippo = 25,
		/obj/item/flashlight/militarylight = 55,
	)
	prices = list(
		/obj/item/weapon/attachment/bayonet = 120,
		/obj/item/weapon/reagent_containers/food/snacks/MRE/generic/american = 100,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/canteen/full = 95,
		/obj/item/weapon/attachment/scope/adjustable/binoculars/binoculars = 90,
		/obj/item/weapon/compass = 100,
		/obj/item/weapon/foldable_shovel/trench/etool = 110,
		/obj/item/weapon/gun_cleaning_kit = 130,
		/obj/item/weapon/storage/toolbox/emergency = 300,
		/obj/item/weapon/tent = 250,
		/obj/item/weapon/radio = 200,
		/obj/item/weapon/radio/walkietalkie = 400,
		/obj/item/weapon/bedroll = 220,
		/obj/item/weapon/foldable/antitankkit = 250,
		/obj/item/weapon/foldable/hescokit = 250,
		/obj/item/weapon/storage/box/sandbags = 90,
		/obj/item/stack/medical/bruise_pack/gauze = 50,
		/obj/item/weapon/storage/box/firstaid/advsmall = 255,
		/obj/item/weapon/storage/box/firstaid/basicsmall = 155,
		/obj/item/clothing/mask/gas/soviet/gp5 = 355,
		/obj/item/clothing/glasses/nvg = 900,
		/obj/item/clothing/glasses/thermal = 1100,
		/obj/item/weapon/storage/box/canned = 150,
		/obj/item/weapon/storage/box/flare = 120,
		/obj/item/weapon/flame/lighter/zippo = 100,
		/obj/item/flashlight/militarylight = 150,
	)

/obj/structure/vending/sales/ffa/armor
	name = "Armor shop"
	desc = "Cointains armor that will increase your odds of surviving a firefight."
	icon_state = "apparel_british"
	products = list(
		/obj/item/clothing/accessory/armor/modern/plate/lightplate = 10,
		/obj/item/clothing/accessory/armor/coldwar/flakjacket/b1 = 5,
		/obj/item/clothing/accessory/armor/nomads/civiliankevlar = 25,
		/obj/item/clothing/accessory/armor/coldwar/pasgt/blizzard = 25,
		/obj/item/clothing/accessory/armor/coldwar/plates/interceptor = 25,
		/obj/item/clothing/accessory/armor/coldwar/plates/b3 = 25,
		/obj/item/clothing/accessory/armor/coldwar/plates/b2 = 15,
		/obj/item/clothing/accessory/armor/coldwar/plates/b5 = 15,
		/obj/item/clothing/head/helmet/kevlarhelmet = 15,
		/obj/item/clothing/head/helmet/ww2/soviet = 15,
		/obj/item/clothing/head/helmet/ww2/soviet/winter = 15,
		/obj/item/clothing/head/helmet/modern/pasgt = 15,
		/obj/item/clothing/head/helmet/modern/ssh_68 = 15,
		/obj/item/clothing/head/helmet/modern/ssh_68/winter = 15,
		/obj/item/clothing/head/helmet/modern/zsh1 = 15,
		/obj/item/clothing/head/helmet/modern/sfera = 15,
		/obj/item/clothing/head/helmet/modern/a6b47 = 15,
		/obj/item/clothing/head/helmet/modern/sovietfacehelmet = 5,
	)
	prices = list(
		/obj/item/clothing/accessory/armor/modern/plate/lightplate = 155,
		/obj/item/clothing/accessory/armor/coldwar/flakjacket/b1 = 145,
		/obj/item/clothing/accessory/armor/nomads/civiliankevlar = 180,
		/obj/item/clothing/accessory/armor/coldwar/pasgt/blizzard = 200,
		/obj/item/clothing/accessory/armor/coldwar/plates/interceptor = 225,
		/obj/item/clothing/accessory/armor/coldwar/plates/b3 = 195,
		/obj/item/clothing/accessory/armor/coldwar/plates/b2 = 150,
		/obj/item/clothing/accessory/armor/coldwar/plates/b5 = 350,
		/obj/item/clothing/head/helmet/kevlarhelmet = 355,
		/obj/item/clothing/head/helmet/ww2/soviet = 125,
		/obj/item/clothing/head/helmet/ww2/soviet/winter = 125,
		/obj/item/clothing/head/helmet/modern/pasgt = 175,
		/obj/item/clothing/head/helmet/modern/ssh_68 = 145,
		/obj/item/clothing/head/helmet/modern/ssh_68/winter = 145,
		/obj/item/clothing/head/helmet/modern/zsh1 = 355,
		/obj/item/clothing/head/helmet/modern/sfera = 255,
		/obj/item/clothing/head/helmet/modern/a6b47 = 195,
		/obj/item/clothing/head/helmet/modern/sovietfacehelmet = 455,
	)

obj/structure/vending/sales/ffa/matsshop
	name = "Material shop"
	desc = "Cointains Materials so you can fortify and build."
	icon_state = "apparel_confed"
	products = list(
		/obj/item/stack/material/barbwire = 1000,
		/obj/item/stack/material/bronze = 500,
		/obj/item/stack/material/copper = 500,
		/obj/item/stack/material/cloth = 900,
		/obj/item/stack/material/kevlar = 505,
		/obj/item/stack/material/plastic = 900,
		/obj/item/stack/material/steel = 2000,
		/obj/item/stack/material/stone = 2000,
		/obj/item/stack/material/wood = 2000,
		/obj/item/stack/material/glass = 1000,
	)
	prices = list(
		/obj/item/stack/material/barbwire = 9,
		/obj/item/stack/material/bronze = 30,
		/obj/item/stack/material/copper = 25,
		/obj/item/stack/material/cloth = 15,
		/obj/item/stack/material/kevlar = 50,
		/obj/item/stack/material/plastic = 15,
		/obj/item/stack/material/steel = 10,
		/obj/item/stack/material/stone = 6,
		/obj/item/stack/material/wood = 2,
		/obj/item/stack/material/glass = 5,
	)

obj/structure/vending/sales/ffa/logishop
	name = "Logistical shop"
	desc = "Cointains Logistical items such as webbing belts backpacks and crates.."
	icon_state = "apparel_china"
	products = list(
		/obj/item/weapon/storage/belt/smallpouches = 60,
		/obj/item/weapon/storage/belt/smallpouches/white = 60,
		/obj/item/weapon/storage/belt/largepouches = 50,
		/obj/item/weapon/storage/belt/largepouches/white = 50,
		/obj/item/weapon/storage/belt/tacpouches = 50,
		/obj/item/weapon/storage/belt/tacpouches/white = 50,
		/obj/item/weapon/storage/belt = 50,
		/obj/item/weapon/storage/ammo_can = 15,
		/obj/item/weapon/storage/backpack/buttpack = 55,
		/obj/item/weapon/storage/backpack/sovpack = 55,
		/obj/item/weapon/storage/backpack/satchel = 45,
		/obj/item/weapon/storage/backpack/civbag = 25,
		/obj/item/weapon/storage/backpack/duffel = 25,
		/obj/item/weapon/storage/backpack/duffel/black = 25,
		/obj/item/weapon/storage/backpack/rucksack = 25,
		/obj/item/weapon/storage/backpack/heavyrucksack = 35,
		/obj/item/clothing/accessory/storage/webbing/light = 55,
		/obj/item/clothing/accessory/storage/webbing/pouches = 55,
		/obj/item/clothing/accessory/storage/webbing/us_bandolier = 35,
		/obj/item/clothing/accessory/storage/webbing/us_vest = 35,
		/obj/item/clothing/accessory/storage/webbing/largepouches = 35,
		/obj/item/clothing/accessory/storage/webbing/russian = 35,
	)
	prices = list(
		/obj/item/weapon/storage/belt/smallpouches = 60,
		/obj/item/weapon/storage/belt/smallpouches/white = 60,
		/obj/item/weapon/storage/belt/largepouches = 50,
		/obj/item/weapon/storage/belt/largepouches/white = 50,
		/obj/item/weapon/storage/belt/tacpouches = 90,
		/obj/item/weapon/storage/belt/tacpouches/white = 90,
		/obj/item/weapon/storage/belt = 125,
		/obj/item/weapon/storage/ammo_can = 95,
		/obj/item/weapon/storage/backpack/buttpack = 159,
		/obj/item/weapon/storage/backpack/sovpack = 200,
		/obj/item/weapon/storage/backpack/satchel = 210,
		/obj/item/weapon/storage/backpack/civbag = 230,
		/obj/item/weapon/storage/backpack/duffel = 250,
		/obj/item/weapon/storage/backpack/duffel/black = 250,
		/obj/item/weapon/storage/backpack/rucksack = 300,
		/obj/item/weapon/storage/backpack/heavyrucksack = 390,
		/obj/item/clothing/accessory/storage/webbing/light = 90,
		/obj/item/clothing/accessory/storage/webbing/pouches = 90,
		/obj/item/clothing/accessory/storage/webbing/us_bandolier = 120,
		/obj/item/clothing/accessory/storage/webbing/us_vest = 125,
		/obj/item/clothing/accessory/storage/webbing/largepouches = 155,
		/obj/item/clothing/accessory/storage/webbing/russian = 160,
	)

obj/structure/vending/sales/ffa/uselessshop
	name = "Useless things shop"
	desc = "Cointains Things that may seem useless to you."
	icon_state = "apparel_china"
	products = list(
		/obj/item/clothing/accessory/ruffle/neck = 10,
		/obj/item/clothing/accessory/catears = 1,
		/obj/item/clothing/accessory/custom/armband = 50,
		/obj/item/weapon/storage/fancy/cigarettes/randompack/lighter = 50,
		/obj/item/weapon/storage/fancy/candle_box = 50,
		/obj/item/weapon/storage/ww2 = 50,
		/obj/item/trombone = 5,
		/obj/item/violin = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 5,
	)
	prices = list(
		/obj/item/clothing/accessory/ruffle/neck = 100,
		/obj/item/clothing/accessory/catears = 255,
		/obj/item/clothing/accessory/custom/armband = 50,
		/obj/item/weapon/storage/fancy/cigarettes/randompack/lighter = 55,
		/obj/item/weapon/storage/fancy/candle_box = 50,
		/obj/item/weapon/storage/ww2 = 60,
		/obj/item/trombone = 120,
		/obj/item/violin = 120,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 120,
	)

/obj/structure/ffa/export
	name = "Export guy"
	desc = "Give me things and i will give you money."
	icon = 'icons/mob/npcs.dmi'
	icon_state = "greenistani_2"
	flammable = FALSE
	not_movable = TRUE
	not_disassemblable = TRUE
	density = TRUE
	opacity = FALSE
	anchored = TRUE

/obj/structure/ffa/export/attackby(obj/item/W, mob/living/human/user)
	if (!W)
		user << "I don't accept this."
		return
	else if (istype(W, /obj/item/stack))
		user << "I don't accept this."
		return
	else
		qdel(W)
		user << "Nice, here's the money."
		new/obj/item/stack/money/rubles (src.loc, round(W.value))
	return