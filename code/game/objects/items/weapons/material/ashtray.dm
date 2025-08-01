GLOBAL_LIST_EMPTY(ashtray_cache)

/obj/item/material/ashtray
	name = "ashtray"
	icon = 'icons/obj/objects.dmi'
	icon_state = "ashtray"
	randpixel = 5
	force_divisor = 0.1
	thrown_force_divisor = 0.1
	w_class = ITEMSIZE_SMALL
	var/image/base_image
	var/max_butts = 10

/obj/item/material/ashtray/Initialize(mapload, material_key)
	. = ..()
	if(!material)
		return INITIALIZE_HINT_QDEL
	icon_state = "blank"
	max_butts = round(material.hardness/5) //This is arbitrary but whatever.
	randpixel_xy()
	update_icon()

/obj/item/material/ashtray/update_icon()
	color = null
	cut_overlays()
	var/cache_key = "base-[material.name]"
	if(!GLOB.ashtray_cache[cache_key])
		var/image/I = image('icons/obj/objects.dmi',"ashtray")
		I.color = material.icon_colour
		GLOB.ashtray_cache[cache_key] = I
	add_overlay(GLOB.ashtray_cache[cache_key])

	if (contents.len == max_butts)
		if(!GLOB.ashtray_cache["full"])
			GLOB.ashtray_cache["full"] = image('icons/obj/objects.dmi',"ashtray_full")
		add_overlay(GLOB.ashtray_cache["full"])
		desc = "It's stuffed full."
	else if (contents.len > max_butts/2)
		if(!GLOB.ashtray_cache["half"])
			GLOB.ashtray_cache["half"] = image('icons/obj/objects.dmi',"ashtray_half")
		add_overlay(GLOB.ashtray_cache["half"])
		desc = "It's half-filled."
	else
		desc = "An ashtray made of [material.display_name]."

/obj/item/material/ashtray/attackby(obj/item/W as obj, mob/user as mob)
	if (health <= 0)
		return
	if (istype(W,/obj/item/trash/cigbutt) || istype(W,/obj/item/clothing/mask/smokable/cigarette) || istype(W, /obj/item/flame/match))
		if (contents.len >= max_butts)
			to_chat(user, "\The [src] is full.")
			return
		user.remove_from_mob(W)
		W.loc = src

		if (istype(W,/obj/item/clothing/mask/smokable/cigarette))
			var/obj/item/clothing/mask/smokable/cigarette/cig = W
			if (cig.lit == 1)
				src.visible_message("[user] crushes [cig] in \the [src], putting it out.")
				STOP_PROCESSING(SSobj, cig)
				var/obj/item/butt = new cig.type_butt(src)
				cig.transfer_fingerprints_to(butt)
				//CHOMPAdd Start - Turn mind bound cigs into butts
				if(cig.possessed_voice && cig.possessed_voice.len)
					var/mob/living/voice/V = src.possessed_voice[1]
					butt.inhabit_item(V, null, V.tf_mob_holder, TRUE)
					qdel(V)
				//CHOMPAdd End
				qdel(cig)
				W = butt
				//spawn(1)
				//	TemperatureAct(150)
			else if (cig.lit == 0)
				to_chat(user, "You place [cig] in [src] without even smoking it. Why would you do that?")

		src.visible_message("[user] places [W] in [src].")
		user.update_inv_l_hand()
		user.update_inv_r_hand()
		add_fingerprint(user)
		update_icon()
	else
		health = max(0,health - W.force)
		to_chat(user, "You hit [src] with [W].")
		if (health < 1)
			shatter()
	return

/obj/item/material/ashtray/throw_impact(atom/hit_atom)
	if (health > 0)
		health = max(0,health - 3)
		if (contents.len)
			src.visible_message(span_danger("\The [src] slams into [hit_atom], spilling its contents!"))
		for (var/obj/item/O in contents) //CHOMPEdit - Dump all items out, so it ejects butts too
			O.loc = src.loc
		if (health < 1)
			shatter()
			return
		update_icon()
	return ..()

/obj/item/material/ashtray/plastic/Initialize(mapload)
	. = ..(mapload, MAT_PLASTIC)

/obj/item/material/ashtray/bronze/Initialize(mapload)
	. = ..(mapload, MAT_BRONZE)

/obj/item/material/ashtray/glass/Initialize(mapload)
	. = ..(mapload, MAT_GLASS)
