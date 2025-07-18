/*****************************Money bag********************************/

/obj/item/moneybag
	icon = 'icons/obj/storage.dmi'
	name = "Money bag"
	icon_state = "moneybag"
	force = 10.0
	throwforce = 2.0
	w_class = ITEMSIZE_LARGE

/obj/item/moneybag/attack_hand(user as mob)
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_phoron = 0
	var/amt_uranium = 0

	for (var/obj/item/coin/C in contents)
		if (istype(C,/obj/item/coin/diamond))
			amt_diamond++;
		if (istype(C,/obj/item/coin/phoron))
			amt_phoron++;
		if (istype(C,/obj/item/coin/iron))
			amt_iron++;
		if (istype(C,/obj/item/coin/silver))
			amt_silver++;
		if (istype(C,/obj/item/coin/gold))
			amt_gold++;
		if (istype(C,/obj/item/coin/uranium))
			amt_uranium++;

	var/dat = span_bold("The contents of the moneybag reveal...") + "<br>"
	if (amt_gold)
		dat += text("Gold coins: [amt_gold] <A href='byond://?src=\ref[src];remove=gold'>Remove one</A><br>")
	if (amt_silver)
		dat += text("Silver coins: [amt_silver] <A href='byond://?src=\ref[src];remove=silver'>Remove one</A><br>")
	if (amt_iron)
		dat += text("Metal coins: [amt_iron] <A href='byond://?src=\ref[src];remove=iron'>Remove one</A><br>")
	if (amt_diamond)
		dat += text("Diamond coins: [amt_diamond] <A href='byond://?src=\ref[src];remove=diamond'>Remove one</A><br>")
	if (amt_phoron)
		dat += text("Phoron coins: [amt_phoron] <A href='byond://?src=\ref[src];remove=phoron'>Remove one</A><br>")
	if (amt_uranium)
		dat += text("Uranium coins: [amt_uranium] <A href='byond://?src=\ref[src];remove=uranium'>Remove one</A><br>")

	var/datum/browser/popup = new(user, "moneybag", "Moneybag")
	popup.set_content(dat)
	popup.open()

/obj/item/moneybag/attackby(obj/item/W, mob/user)
	..()
	if (istype(W, /obj/item/coin))
		var/obj/item/coin/C = W
		to_chat(user, span_blue("You add the [C.name] into the bag."))
		user.drop_item()
		contents += C
	if (istype(W, /obj/item/moneybag))
		var/obj/item/moneybag/C = W
		for (var/obj/O in C.contents)
			contents += O;
		to_chat(user, span_blue("You empty the [C.name] into the bag."))
	return

/obj/item/moneybag/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["remove"])
		var/obj/item/coin/COIN
		switch(href_list["remove"])
			if(MAT_GOLD)
				COIN = locate(/obj/item/coin/gold,src.contents)
			if(MAT_SILVER)
				COIN = locate(/obj/item/coin/silver,src.contents)
			if(MAT_IRON)
				COIN = locate(/obj/item/coin/iron,src.contents)
			if(MAT_DIAMOND)
				COIN = locate(/obj/item/coin/diamond,src.contents)
			if(MAT_URANIUM)
				COIN = locate(/obj/item/coin/phoron,src.contents)
			if(MAT_URANIUM)
				COIN = locate(/obj/item/coin/uranium,src.contents)
		if(!COIN)
			return
		COIN.loc = src.loc
	return



/obj/item/moneybag/vault

/obj/item/moneybag/vault/Initialize(mapload)
	. = ..()
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/gold(src)
