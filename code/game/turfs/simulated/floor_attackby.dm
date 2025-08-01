/turf/simulated/floor/attackby(var/obj/item/C, var/mob/user, attack_modifier, click_parameters)

	if(!C || !user)
		return 0

	if(isliving(user) && istype(C, /obj/item)) //CHOMPEDIT START - Making engraving require disarm intent (and simplifying the proc)
		var/mob/living/L = user
		if(L.a_intent != I_HELP)
			if(L.a_intent == I_GRAB)
				try_graffiti(L, C, click_parameters) // back by unpopular demand - CHOMPEdit Add - Click parameters
				return
			attack_tile(C, L) // Be on help intent if you want to decon something.
			return	//CHOMPEDIT END

	// Multi-z roof building
	if(istype(C, /obj/item/stack/tile/roofing))
		var/expended_tile = FALSE // To track the case. If a ceiling is built in a multiz zlevel, it also necessarily roofs it against weather
		var/turf/T = GetAbove(src)
		var/obj/item/stack/tile/roofing/R = C

		// Patch holes in the ceiling
		if(T)
			if(isopenturf(T))
				// Must be build adjacent to an existing floor/wall, no floating floors
				var/list/cardinalTurfs = list() // Up a Z level
				for(var/dir in GLOB.cardinal)
					var/turf/B = get_step(T, dir)
					if(B)
						cardinalTurfs += B

				var/turf/simulated/A = locate(/turf/simulated/floor) in cardinalTurfs
				if(!A)
					A = locate(/turf/simulated/wall) in cardinalTurfs
				if(!A)
					to_chat(user, span_warning("There's nothing to attach the ceiling to!"))
					return

				if(R.use(1)) // Cost of roofing tiles is 1:1 with cost to place lattice and plating
					T.ReplaceWithLattice()
					T.ChangeTurf(/turf/simulated/floor, preserve_outdoors = TRUE)
					playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
					user.visible_message(span_notice("[user] patches a hole in the ceiling."), span_notice("You patch a hole in the ceiling."))
					expended_tile = TRUE
			else
				to_chat(user, span_warning("There aren't any holes in the ceiling to patch here."))
				return

		// Create a ceiling to shield from the weather
		if(src.is_outdoors())
			for(var/dir in GLOB.cardinal)
				var/turf/A = get_step(src, dir)
				if(A && !A.is_outdoors())
					if(expended_tile || R.use(1))
						make_indoors()
						playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
						user.visible_message(span_notice("[user] roofs a tile, shielding it from the elements."), span_notice("You roof this tile, shielding it from the elements."))
					break
		return

	// Floor has flooring set
	if(!is_plating())
		if(istype(C, /obj/item))
			try_deconstruct_tile(C, user)
			return
		else if(istype(C, /obj/item/stack/cable_coil))
			to_chat(user, span_warning("You must remove the [flooring.descriptor] first."))
			return
		else if(istype(C, /obj/item/stack/tile))
			if(try_replace_tile(C, user))
				return
			else if(istype(C, /obj/item/stack/tile/floor)) // While we're at it, let's see if this is a raw patch of natural sand, dirt, or whatever that you're trying to put a plating on.
				if(!flooring.build_type && can_be_plated && !((flooring.flags & TURF_REMOVE_WRENCH) || (flooring.flags & TURF_REMOVE_CROWBAR) || (flooring.flags & TURF_REMOVE_SCREWDRIVER) || (flooring.flags & TURF_REMOVE_SHOVEL)))
					for(var/obj/structure/P in contents)
						if(istype(P, /obj/structure/flora))
							to_chat(user, span_warning("The [P.name] is in the way, you'll have to get rid of it first."))
							return
					var/obj/item/stack/tile/floor/S = C
					if (S.get_amount() < 1)
						return
					S.use(1)
					playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
					ChangeTurf(/turf/simulated/floor, preserve_outdoors = TRUE)
					return


	// Floor is plating (or no flooring)
	else
		// Placing wires on plating
		if(istype(C, /obj/item/stack/cable_coil))
			if(broken || burnt)
				to_chat(user, span_warning("This section is too damaged to support anything. Use a welder to fix the damage."))
				return
			var/obj/item/stack/cable_coil/coil = C
			coil.turf_place(src, user)
			return
		// Placing flooring on plating
		else if(istype(C, /obj/item/stack))
			if(broken || burnt)
				to_chat(user, span_warning("This section is too damaged to support anything. Use a welder to fix the damage."))
				return
			var/obj/item/stack/S = C
			var/decl/flooring/use_flooring
			for(var/flooring_type in flooring_types)
				var/decl/flooring/F = flooring_types[flooring_type]
				if(!F.build_type)
					continue
				if((S.type == F.build_type) || (S.build_type == F.build_type))
					use_flooring = F
					break
			if(!use_flooring)
				return
			// Do we have enough?
			if(use_flooring.build_cost && S.get_amount() < use_flooring.build_cost)
				to_chat(user, span_warning("You require at least [use_flooring.build_cost] [S.name] to complete the [use_flooring.descriptor]."))
				return
			// Stay still and focus...
			if(use_flooring.build_time && !do_after(user, use_flooring.build_time))
				return
			if(!is_plating() || !S || !user || !use_flooring)
				return
			if(S.use(use_flooring.build_cost))
				set_flooring(use_flooring)
				playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
				return
		// Plating repairs and removal
		else if(C.has_tool_quality(TOOL_WELDER))
			var/obj/item/weldingtool/welder = C.get_welder()
			if(welder.isOn())
				// Needs repairs
				if(broken || burnt)
					if(welder.remove_fuel(0,user))
						to_chat(user, span_notice("You fix some dents on the broken plating."))
						playsound(src, welder.usesound, 80, 1)
						icon_state = "plating"
						burnt = null
						broken = null
					else
						to_chat(user, span_warning("You need more welding fuel to complete this task."))
				// Deconstructing plating
				else
					var/base_type = get_base_turf_by_area(src)
					if(type == base_type || !base_type)
						to_chat(user, span_warning("There's nothing under [src] to expose by cutting."))
						return
					if(!can_remove_plating(user))
						return

					user.visible_message(span_warning("[user] begins cutting through [src]."), span_warning("You begin cutting through [src]."))
					// This is slow because it's a potentially hostile action to just cut through places into space in the middle of the bar and such
					// Presumably also the structural floor is thick?
					if(do_after(user, 10 SECONDS, src, TRUE, exclusive = TASK_ALL_EXCLUSIVE))
						if(!can_remove_plating(user))
							return // Someone slapped down some flooring or cables or something
						do_remove_plating(C, user, base_type)

/turf/simulated/floor/proc/try_deconstruct_tile(obj/item/W as obj, mob/user as mob)
	if(W.has_tool_quality(TOOL_CROWBAR))
		if(broken || burnt)
			to_chat(user, span_notice("You remove the broken [flooring.descriptor]."))
			make_plating()
		else if(flooring.flags & TURF_IS_FRAGILE)
			to_chat(user, span_danger("You forcefully pry off the [flooring.descriptor], destroying them in the process."))
			make_plating()
		else if(flooring.flags & TURF_REMOVE_CROWBAR)
			to_chat(user, span_notice("You lever off the [flooring.descriptor]."))
			make_plating(1)
		else
			return 0
		playsound(src, W.usesound, 80, 1)
		if(isliving(user) && is_plating())
			var/mob/living/deconstructor = user
			var/obj/item/stack/tile/T = deconstructor.get_inactive_hand()
			if(T)
				attackby(T, user) // Replace the tile
		return 1
	else if(W.has_tool_quality(TOOL_SCREWDRIVER) && (flooring.flags & TURF_REMOVE_SCREWDRIVER))
		if(broken || burnt)
			return 0
		to_chat(user, span_notice("You unscrew and remove the [flooring.descriptor]."))
		make_plating(1)
		playsound(src, W.usesound, 80, 1)
		return 1
	else if(W.has_tool_quality(TOOL_WRENCH) && (flooring.flags & TURF_REMOVE_WRENCH))
		to_chat(user, span_notice("You unwrench and remove the [flooring.descriptor]."))
		make_plating(1)
		playsound(src, W.usesound, 80, 1)
		return 1
	else if(istype(W, /obj/item/shovel) && (flooring.flags & TURF_REMOVE_SHOVEL))
		to_chat(user, span_notice("You shovel off the [flooring.descriptor]."))
		make_plating(1)
		playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
		return 1
	return 0

/turf/simulated/floor/proc/try_replace_tile(obj/item/stack/tile/T as obj, mob/user as mob)
	if(T.type == flooring.build_type)
		return
	var/obj/item/W = user.is_holding_item_of_type(/obj/item)
	if(!istype(W))
		return
	if(!try_deconstruct_tile(W, user))
		return
	if(flooring && !flooring.is_plating)
		return
	attackby(T, user)

/turf/simulated/floor/proc/can_remove_plating(mob/user)
	if(!is_plating())
		to_chat(user, span_warning("\The [src] can't be cut through!"))
		return FALSE
	if(locate(/obj/structure) in contents)
		to_chat(user, span_warning("\The [src] has structures that must be removed before cutting!"))
		return FALSE
	return TRUE

/turf/simulated/floor/proc/do_remove_plating(obj/item/W, mob/user, base_type)
	if(W.has_tool_quality(TOOL_WELDER))
		var/obj/item/weldingtool/WT = W.get_welder()
		if(!WT.remove_fuel(5,user))
			to_chat(user, span_warning("You don't have enough fuel in [WT] finish cutting through [src]."))
			return
		playsound(src, WT.usesound, 80, 1)

	// Keep in mind, turfs can never actually be deleted in byond, after this line
	// our turf is just 'magically changed' to the new type and src refers to that
	ChangeTurf(base_type, preserve_outdoors = TRUE)

	var/static/list/floors_that_need_lattice = list(
		/turf/space,
		/turf/simulated/open
	)
	if(is_type_in_list(src, floors_that_need_lattice))
		new /obj/structure/lattice(src)
