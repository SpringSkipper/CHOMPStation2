/mob/living/simple_mob
	melee_attack_delay = 1
	base_attack_cooldown = 10
	melee_miss_chance = 25

	var/temperature_range = 40			// How close will they get to environmental temperature before their body stops changing its heat

	var/vore_active = 0					// If vore behavior is enabled for this mob

	vore_capacity = 1					// The capacity (in people) this person can hold
	var/vore_max_size = RESIZE_HUGE		// The max size this mob will consider eating
	var/vore_min_size = RESIZE_TINY 	// The min size this mob will consider eating
	var/vore_bump_chance = 0			// Chance of trying to eat anyone that bumps into them, regardless of hostility
	var/vore_bump_emote	= "grabs hold of"				// Allow messages for bumpnom mobs to have a flavorful bumpnom
	var/vore_pounce_chance = 5			// Chance of this mob knocking down an opponent
	var/vore_pounce_cooldown = 0		// Cooldown timer - if it fails a pounce it won't pounce again for a while
	var/vore_pounce_successrate	= 100	// Chance of a pounce succeeding against a theoretical 0-health opponent
	var/vore_pounce_falloff = 1			// Success rate falloff per %health of target mob.
	var/vore_pounce_maxhealth = 80		// Mob will not attempt to pounce targets above this %health
	var/vore_standing_too = 0			// Can also eat non-stunned mobs
	var/vore_ignores_undigestable = FALSE	// If set to true, will refuse to eat mobs who are undigestable by the prefs toggle.
	var/swallowsound = null				// What noise plays when you succeed in eating the mob.

	var/vore_default_mode = DM_DIGEST	// Default bellymode (DM_DIGEST, DM_HOLD, DM_ABSORB)
	var/vore_default_flags = 0			// No flags
	var/vore_digest_chance = 25			// Chance to switch to digest mode if resisted
	var/vore_absorb_chance = 0			// Chance to switch to absorb mode if resisted
	var/vore_escape_chance = 25			// Chance of resisting out of mob
	var/vore_escape_chance_absorbed = 20// Chance of absorbed prey finishing an escape. Requires a successful escape roll against the above as well.

	var/vore_stomach_name				// The name for the first belly if not "stomach"
	var/vore_stomach_flavor				// The flavortext for the first belly if not the default

	var/vore_default_item_mode = IM_DIGEST_FOOD			//How belly will interact with items
	var/vore_default_contaminates = TRUE				//Will it contaminate? // CHOMPedit: Put back to true like it always was.
	var/vore_default_contamination_flavor = "Generic"	//Contamination descriptors
	var/vore_default_contamination_color = "green"		//Contamination color

	var/life_disabled = 0				// For performance reasons

	var/vore_attack_override = FALSE	// Enable on mobs you want to have special behaviour on melee grab attack.

	var/mount_offset_x = 5				// Horizontal riding offset.
	var/mount_offset_y = 8				// Vertical riding offset

	var/obj/item/radio/headset/mob_radio		//Adminbus headset for simplemob shenanigans.
	does_spin = FALSE
	can_be_drop_pred = TRUE				// Mobs are pred by default.
	can_be_drop_prey = TRUE				//CHOMP Add This also counts for spontaneous prey for telenoms and phase noms.
	var/damage_threshold  = 0 //For some mobs, they have a damage threshold required to deal damage to them.

	var/nom_mob = FALSE //If a mob is meant to be hostile for vore purposes but is otherwise not hostile, if true makes certain AI ignore the mob

	var/voremob_loaded = FALSE // On-demand belly loading.

// Release belly contents before being gc'd!
/mob/living/simple_mob/Destroy()
	if(mob_radio)
		QDEL_NULL(mob_radio)
	release_vore_contents()
	LAZYCLEARLIST(prey_excludes)
	return ..()

//For all those ID-having mobs
/mob/living/simple_mob/GetIdCard()
	if(get_active_hand()) //CHOMPAdd Start
		var/obj/item/I = get_active_hand()
		var/id = I.GetID()
		if(id)
			return id //CHOMPAdd End
	if(myid)
		return myid

/mob/living/simple_mob/update_icon()
	. = ..()
	if(vore_active)
		var/voremob_awake = FALSE
		if(icon_state == icon_living)
			voremob_awake = TRUE
		update_fullness()
		if(!vore_fullness)
			update_transform()
			return 0
		else if((stat == CONSCIOUS) && (!icon_rest || !resting || !incapacitated(INCAPACITATION_DISABLED)) && (vore_icons & SA_ICON_LIVING))
			icon_state = "[icon_living]-[vore_fullness]"
		else if(stat >= DEAD && (vore_icons & SA_ICON_DEAD))
			icon_state = "[icon_dead]-[vore_fullness]"
		else if(((stat == UNCONSCIOUS) || resting || incapacitated(INCAPACITATION_DISABLED) ) && icon_rest && (vore_icons & SA_ICON_REST))
			icon_state = "[icon_rest]-[vore_fullness]"
		if(vore_eyes && voremob_awake) //Update eye layer if applicable.
			remove_eyes()
			add_eyes()
	update_transform()
	for(var/belly_class in vore_fullness_ex)
		var/vs_fullness = vore_fullness_ex[belly_class]
		if(vs_fullness > 0)
			add_overlay("[icon_state]_[belly_class]-[vs_fullness]")

/mob/living/simple_mob/regenerate_icons()
	..()
	update_icon()

/mob/living/simple_mob/proc/will_eat(var/mob/living/M)
	if(client) //You do this yourself, dick!
		//ai_log("vr/wont eat [M] because we're player-controlled", 3) //VORESTATION AI TEMPORARY REMOVAL
		return 0
	if(!istype(M)) //Can't eat 'em if they ain't /mob/living
		//ai_log("vr/wont eat [M] because they are not /mob/living", 3) //VORESTATION AI TEMPORARY REMOVAL
		return 0
	if(src == M) //Don't eat YOURSELF dork
		//ai_log("vr/won't eat [M] because it's me!", 3) //VORESTATION AI TEMPORARY REMOVAL
		return 0
	if(M.is_incorporeal()) // No eating the phased ones
		return 0
	if(vore_ignores_undigestable && !M.digestable) //Don't eat people with nogurgle prefs
		//ai_log("vr/wont eat [M] because I am picky", 3) //VORESTATION AI TEMPORARY REMOVAL
		return 0
	if(!M.allowmobvore || !M.devourable) // Don't eat people who don't want to be ate by mobs
		//ai_log("vr/wont eat [M] because they don't allow mob vore", 3) //VORESTATION AI TEMPORARY REMOVAL
		return 0
	if(LAZYFIND(prey_excludes, M)) // They're excluded
		//ai_log("vr/wont eat [M] because they are excluded", 3) //VORESTATION AI TEMPORARY REMOVAL
		return 0
	if(M.size_multiplier < vore_min_size || M.size_multiplier > vore_max_size)
		//ai_log("vr/wont eat [M] because they too small or too big", 3) //VORESTATION AI TEMPORARY REMOVAL
		return 0
	if(vore_capacity != 0 && (vore_fullness >= vore_capacity)) // We're too full to fit them
		//ai_log("vr/wont eat [M] because I am too full", 3) //VORESTATION AI TEMPORARY REMOVAL
		return 0
	return 1

/mob/living/simple_mob/apply_attack(atom/A, damage_to_do)
	if(isliving(A)) // Converts target to living
		var/mob/living/L = A

		//ai_log("vr/do_attack() [L]", 3)
		// If we're not hungry, call the sideways "parent" to do normal punching
		if(!vore_active)
			return ..()

		// If target is standing we might pounce and knock them down instead of attacking
		var/pouncechance = CanPounceTarget(L)
		if(pouncechance)
			return PounceTarget(L, pouncechance)

		// We're not attempting a pounce, if they're down or we can eat standing, do it as long as they're edible. Otherwise, hit normally.
		if(will_eat(L) && (L.lying || vore_standing_too)) //CHOMPEdit
			return EatTarget(L)
		else
			return ..()
	else
		return ..()


/mob/living/simple_mob/proc/CanPounceTarget(var/mob/living/M) //returns either FALSE or a %chance of success
	if(!M.canmove || issilicon(M) || world.time < vore_pounce_cooldown) //eliminate situations where pouncing CANNOT happen
		return FALSE
	if(M.is_incorporeal())
		return FALSE
	if(!prob(vore_pounce_chance) || !will_eat(M)) //mob doesn't want to pounce
		return FALSE
	if(vore_standing_too) //100% chance of hitting people we can eat on the spot
		return 100
	var/TargetHealthPercent = (M.health/M.getMaxHealth())*100 //now we start looking at the target itself
	if (TargetHealthPercent > vore_pounce_maxhealth) //target is too healthy to pounce
		return FALSE
	else
		return max(0,(vore_pounce_successrate - (vore_pounce_falloff * TargetHealthPercent)))


/mob/living/simple_mob/proc/PounceTarget(var/mob/living/M, var/successrate = 100)
	vore_pounce_cooldown = world.time + 20 SECONDS // don't attempt another pounce for a while
	if(prob(successrate)) // pounce success!
		M.Weaken(5)
		M.AdjustStunned(2)
		M.visible_message(span_danger("\The [src] pounces on \the [M]!"))
	else // pounce misses!
		M.visible_message(span_danger("\The [src] attempts to pounce \the [M] but misses!"))
		playsound(src, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

	if(will_eat(M) && (M.lying || vore_standing_too)) //if they're edible then eat them too
		return EatTarget(M)
	else
		return //just leave them

// Attempt to eat target
// TODO - Review this.  Could be some issues here
/mob/living/simple_mob/proc/EatTarget(var/mob/living/M)
	//ai_log("vr/EatTarget() [M]",2) //VORESTATION AI TEMPORARY REMOVAL
	//stop_automated_movement = 1 //VORESTATION AI TEMPORARY REMOVAL
	var/old_target = M
	set_AI_busy(1) //VORESTATION AI TEMPORARY EDIT
	. = animal_nom(M)
	playsound(src, swallowsound, 50, 1)
	update_icon()

	if(.)
		// If we succesfully ate them, lose the target
		set_AI_busy(0) // lose_target(M) //Unsure what to put here. Replaced with set_AI_busy(1) //VORESTATION AI TEMPORARY EDIT
		return old_target
	else if(old_target == M)
		// If we didn't but they are still our target, go back to attack.
		// but don't run the handler immediately, wait until next tick
		// Otherwise we'll be in a possibly infinate loop
		set_AI_busy(0) //VORESTATION AI TEMPORARY EDIT
	//stop_automated_movement = 0 //VORESTATION AI TEMPORARY EDIT

/mob/living/simple_mob/death()
	release_vore_contents()
	. = ..()

// Make sure you don't call ..() on this one, otherwise you duplicate work.
/mob/living/simple_mob/init_vore(force)
	if(force)
		vore_active = TRUE
		voremob_loaded = TRUE
	if(!vore_active || no_vore || !voremob_loaded)
		return

	AddElement(/datum/element/slosh) // Sloshy element

	if(!soulgem)
		soulgem = new(src)

	// Since they have bellies, add verbs to toggle settings on them.
	add_verb(src, /mob/living/simple_mob/proc/toggle_digestion)
	add_verb(src, /mob/living/simple_mob/proc/toggle_fancygurgle)
	add_verb(src, /mob/living/proc/vertical_nom)
	add_verb(src, /mob/living/simple_mob/proc/animal_nom)
	add_verb(src, /mob/living/proc/shred_limb)
	add_verb(src, /mob/living/simple_mob/proc/nutrition_heal)

	if(LAZYLEN(vore_organs))
		return

	can_be_drop_pred = TRUE // Mobs will eat anyone that decides to drop/slip into them by default.
	load_default_bellies()

/mob/living/simple_mob/proc/load_default_bellies()
	//A much more detailed version of the default /living implementation
	var/obj/belly/B = new /obj/belly(src)
	vore_selected = B
	B.immutable = 1
	B.affects_vore_sprites = TRUE
	B.name = vore_stomach_name ? vore_stomach_name : "stomach"
	B.desc = vore_stomach_flavor ? vore_stomach_flavor : "Your surroundings are warm, soft, and slimy. Makes sense, considering you're inside \the [name]."
	B.digest_mode = vore_default_mode
	B.mode_flags = vore_default_flags
	B.item_digest_mode = vore_default_item_mode
	B.contaminates = vore_default_contaminates
	B.contamination_flavor = vore_default_contamination_flavor
	B.contamination_color = vore_default_contamination_color
	B.escapable = vore_escape_chance > 0
	B.escapechance = vore_escape_chance
	B.escapechance_absorbed = vore_escape_chance_absorbed
	B.digestchance = vore_digest_chance
	B.absorbchance = vore_absorb_chance
	B.human_prey_swallow_time = swallowTime
	B.nonhuman_prey_swallow_time = swallowTime
	B.vore_verb = "swallow"
	B.emote_lists[DM_HOLD] = list( // We need more that aren't repetitive. I suck at endo. -Ace
		"The insides knead at you gently for a moment.",
		"The guts glorp wetly around you as some air shifts.",
		"The predator takes a deep breath and sighs, shifting you somewhat.",
		"The stomach squeezes you tight for a moment, then relaxes harmlessly.",
		"The predator's calm breathing and thumping heartbeat pulses around you.",
		"The warm walls kneads harmlessly against you.",
		"The liquids churn around you, though there doesn't seem to be much effect.",
		"The sound of bodily movements drown out everything for a moment.",
		"The predator's movements gently force you into a different position.")
	B.emote_lists[DM_DIGEST] = list(
		"The burning acids eat away at your form.",
		"The muscular stomach flesh grinds harshly against you.",
		"The caustic air stings your chest when you try to breathe.",
		"The slimy guts squeeze inward to help the digestive juices soften you up.",
		"The onslaught against your body doesn't seem to be letting up; you're food now.",
		"The predator's body ripples and crushes against you as digestive enzymes pull you apart.",
		"The juices pooling beneath you sizzle against your sore skin.",
		"The churning walls slowly pulverize you into meaty nutrients.",
		"The stomach glorps and gurgles as it tries to work you into slop.")
	can_be_drop_pred = TRUE // Mobs will eat anyone that decides to drop/slip into them by default.
//	B.belly_fullscreen = "yet_another_tumby" //Chompedit - Why are they even using this one, I do not understand.
	B.belly_fullscreen = "a_tumby" //Chompedit
	B.belly_fullscreen_color = "#823232" //Chompedit
	B.belly_fullscreen_color2 = "#823232" //Chompedit

/mob/living/simple_mob/Bumped(var/atom/movable/AM, yes)
	if(tryBumpNom(AM))
		return
	..()

/mob/living/simple_mob/proc/tryBumpNom(var/mob/tmob)
	//returns TRUE if we actually start an attempt to bumpnom, FALSE if checks fail or the random bump nom chance fails
	if(istype(tmob) && will_eat(tmob) && !istype(tmob, type) && prob(vore_bump_chance) && !ckey) //check if they decide to eat. Includes sanity check to prevent cannibalism.
		if(!faction_bump_vore && faction == tmob.faction)
			return FALSE
		if(tmob.canmove && prob(vore_pounce_chance)) //if they'd pounce for other noms, pounce for these too, otherwise still try and eat them if they hold still
			tmob.Weaken(5)
		tmob.visible_message(span_danger("\The [src] [vore_bump_emote] \the [tmob]!"))
		set_AI_busy(TRUE)
		spawn()
			animal_nom(tmob)
			update_icon()
			set_AI_busy(FALSE)
		return TRUE
	return FALSE

// Checks to see if mob doesn't like this kind of turf
/mob/living/simple_mob/IMove(turf/newloc, safety = TRUE)
	if(istype(newloc,/turf/unsimulated/floor/sky))
		return MOVEMENT_FAILED //Mobs aren't that stupid, probably
	return ..() // Procede as normal.

// Riding
/datum/riding/simple_mob
	keytype = /obj/item/material/twohanded/riding_crop // Crack!
	nonhuman_key_exemption = FALSE	// If true, nonhumans who can't hold keys don't need them, like borgs and simplemobs.
	key_name = "a riding crop"		// What the 'keys' for the thing being rided on would be called.
	only_one_driver = TRUE			// If true, only the person in 'front' (first on list of riding mobs) can drive.

/datum/riding/simple_mob/handle_vehicle_layer()
	ridden.layer = initial(ridden.layer)

/datum/riding/simple_mob/ride_check(mob/living/M)
	var/mob/living/L = ridden
	if(L.stat)
		force_dismount(M)
		return FALSE
	return TRUE

/datum/riding/simple_mob/force_dismount(mob/M)
	. =..()
	ridden.visible_message(span_notice("[M] stops riding [ridden]!"))

/datum/riding/simple_mob/get_offsets(pass_index) // list(dir = x, y, layer)
	var/mob/living/simple_mob/L = ridden
	var/scale = L.size_multiplier
	var/scale_difference = (L.size_multiplier - rider_size) * 10

	var/list/values = list(
		"[NORTH]" = list(0, L.mount_offset_y*scale + scale_difference, ABOVE_MOB_LAYER),
		"[SOUTH]" = list(0, L.mount_offset_y*scale + scale_difference, BELOW_MOB_LAYER),
		"[EAST]" = list(-L.mount_offset_x*scale, L.mount_offset_y*scale + scale_difference, ABOVE_MOB_LAYER),
		"[WEST]" = list(L.mount_offset_x*scale, L.mount_offset_y*scale + scale_difference, ABOVE_MOB_LAYER))

	return values

/mob/living/simple_mob/buckle_mob(mob/living/M, forced = FALSE, check_loc = TRUE)
	if(forced)
		return ..() // Skip our checks
	if(!riding_datum)
		return FALSE
	if(lying)
		return FALSE
	if(!ishuman(M))
		return FALSE
	if(M in buckled_mobs)
		return FALSE
	if(M.size_multiplier > size_multiplier * 1.2)
		to_chat(src,span_warning("This isn't a pony show! You need to be bigger for them to ride."))
		return FALSE

	var/mob/living/carbon/human/H = M

	if(H.loc != src.loc)
		if(H.Adjacent(src))
			H.forceMove(get_turf(src))

	. = ..()
	if(.)
		riding_datum.rider_size = H.size_multiplier
		buckled_mobs[H] = "riding"

/mob/living/simple_mob/attack_hand(mob/user as mob)
	if(riding_datum && LAZYLEN(buckled_mobs))
		//We're getting off!
		if(user in buckled_mobs)
			riding_datum.force_dismount(user)
		//We're kicking everyone off!
		if(user == src)
			for(var/rider in buckled_mobs)
				riding_datum.force_dismount(rider)
	else
		. = ..()

/mob/living/simple_mob/proc/animal_mount(var/mob/living/M in living_mobs(1))
	set name = "Animal Mount/Dismount"
	set category = "Abilities.Mob"
	set desc = "Let people ride on you."

	if(LAZYLEN(buckled_mobs))
		for(var/rider in buckled_mobs)
			riding_datum.force_dismount(rider)
		return
	if (stat != CONSCIOUS)
		return
	if(!can_buckle || !istype(M) || !M.Adjacent(src) || M.buckled)
		return
	if(buckle_mob(M))
		visible_message(span_notice("[M] starts riding [name]!"))

/mob/living/simple_mob/handle_message_mode(message_mode, message, verb, used_radios, speaking, alt_name)
	//CHOMPEdit - This whole proc tbh
	if(message_mode)
		if(message_mode == "intercom")
			for(var/obj/item/radio/intercom/I in view(1, null))
				I.talk_into(src,message,message_mode,verb,speaking)
				used_radios += I
		if(message_mode == "headset")
			if(mob_radio && istype(mob_radio,/obj/item/radio/headset))
				mob_radio.talk_into(src,message,message_mode,verb,speaking)
				used_radios += mob_radio
		else
			if(mob_radio && istype(mob_radio,/obj/item/radio/headset))
				if(mob_radio.channels[message_mode])
					mob_radio.talk_into(src,message,message_mode,verb,speaking)
					used_radios += mob_radio
	else
		..()

/mob/living/simple_mob/proc/leap()
	set name = "Pounce Target"
	set category = "Abilities.Mob"
	set desc = "Select a target to pounce at."

	if(last_special > world.time)
		to_chat(src, "Your legs need some more rest.")
		return

	if(incapacitated(INCAPACITATION_DISABLED))
		to_chat(src, "You cannot leap in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/M in view(3,src))
		choices += M
	choices -= src

	var/mob/living/T = tgui_input_list(src, "Who do you wish to leap at?", "Target Choice", choices)

	if(!T || !src || stat) return

	if(get_dist(get_turf(T), get_turf(src)) > 3) return

	if(last_special > world.time)
		return

	if(incapacitated(INCAPACITATION_DISABLED))
		to_chat(src, "You cannot leap in your current state.")
		return

	last_special = world.time + 10
	status_flags |= LEAPING
	pixel_y = pixel_y + 10

	visible_message(span_danger("\The [src] leaps at [T]!"))
	throw_at(get_step(get_turf(T),get_turf(src)), 4, 1, src)
	playsound(src, 'sound/effects/bodyfall1.ogg', 50, 1)
	pixel_y = default_pixel_y

	sleep(5)

	if(status_flags & LEAPING) status_flags &= ~LEAPING

	if(!Adjacent(T))
		to_chat(src, span_warning("You miss!"))
		return

	if(ishuman(T))
		var/mob/living/carbon/human/H = T
		if(H.species.lightweight == 1)
			H.Weaken(3)
			return
	var/armor_block = run_armor_check(T, "melee")
	var/armor_soak = get_armor_soak(T, "melee")
	T.apply_damage(20, HALLOSS,, armor_block, armor_soak)
	if(prob(75)) //CHOMPEdit
		T.apply_effect(3, WEAKEN, armor_block)
