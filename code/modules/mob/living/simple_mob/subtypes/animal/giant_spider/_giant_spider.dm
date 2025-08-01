/*
	Spiders come in various types, and are a fairly common enemy both inside and outside the station.
	Their attacks can inject reagents, which can cause harm long after the spider is killed.
	Thick material will prevent injections, similar to other means of injections.
*/

// Obtained by scanning any giant spider.
/datum/category_item/catalogue/fauna/giant_spider/giant_spiders
	name = "Giant Spiders"
	desc = "Giant Spiders are massive arachnids genetically descended from conventional Earth spiders, \
	however what caused ordinary arachnids to evolve into these are disputed. \
	Different initial species of spider have co-evolved and interbred to produce a robust biological caste system \
	capable of producing many varieties of giant spider. They are considered by most people to be a dangerous \
	invasive species, due to their hostility, venom, and high rate of reproduction. A strong resistance to \
	various poisons and toxins has been found, making it difficult to indirectly control their population.\
	<br><br>\
	Giant Spiders have three known castes, 'Guard', 'Hunter', and 'Nurse'. \
	Spiders in the Guard caste are generally the physically stronger, resilient types. \
	The ones in the Hunter caste are usually faster, or have some from of ability to \
	close the distance between them and their prey rapidly. \
	Finally, those in the Nurse caste generally act in a supporting role to the other two \
	castes, spinning webs and ensuring their nest grows larger and more terrifying."
	value = CATALOGUER_REWARD_TRIVIAL
	unlocked_by_any = list(/datum/category_item/catalogue/fauna/giant_spider)

// Obtained by scanning all spider types.
/datum/category_item/catalogue/fauna/all_giant_spiders
	name = "Collection - Giant Spiders"
	desc = "You have scanned a large array of different types of giant spiders, \
	and therefore you have been granted a large sum of points, through this \
	entry."
	value = CATALOGUER_REWARD_HARD
	unlocked_by_all = list(
		/datum/category_item/catalogue/fauna/giant_spider/guard_spider,
		/datum/category_item/catalogue/fauna/giant_spider/carrier_spider,
		/datum/category_item/catalogue/fauna/giant_spider/electric_spider,
		/datum/category_item/catalogue/fauna/giant_spider/frost_spider,
		/datum/category_item/catalogue/fauna/giant_spider/hunter_spider,
		/datum/category_item/catalogue/fauna/giant_spider/lurker_spider,
		/datum/category_item/catalogue/fauna/giant_spider/nurse_spider,
		/datum/category_item/catalogue/fauna/giant_spider/pepper_spider,
		/datum/category_item/catalogue/fauna/giant_spider/phorogenic_spider,
		/datum/category_item/catalogue/fauna/giant_spider/thermic_spider,
		/datum/category_item/catalogue/fauna/giant_spider/tunneler_spider,
		/datum/category_item/catalogue/fauna/giant_spider/webslinger_spider
		)

// Specific to guard spiders.
/datum/category_item/catalogue/fauna/giant_spider/guard_spider
	name = "Giant Spider - Guard"
	desc = "This specific spider has been catalogued as 'Guard', \
	and belongs to the 'Guard' caste. It has a brown coloration, with \
	red glowing eyes.\
	<br><br>\
	This spider, like the others in its caste, is bulky, strong, and resilient. It \
	relies on its raw strength to kill prey, due to having less potent venom compared \
	to other spiders."
	value = CATALOGUER_REWARD_EASY

// The base spider, in the 'walking tank' family.
/mob/living/simple_mob/animal/giant_spider
	name = "giant spider"
	desc = "Furry and brown, it makes you shudder to look at it. This one has deep red eyes."
	tt_desc = "X Atrax robustus gigantus"
	catalogue_data = list(/datum/category_item/catalogue/fauna/giant_spider/guard_spider)

	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	has_eye_glow = TRUE
	density = FALSE
	minbodytemp = 175 //yw edit, Makes mobs survive cryogaia temps
	faction = FACTION_AWAYMISSION //yw edit, Makes away mobs be on the same fuckin' side.
	maxHealth = 200
	health = 200
	pass_flags = PASSTABLE
	movement_cooldown = 3
	movement_sound = 'sound/effects/spider_loop.ogg'
	poison_resist = 0.5

	see_in_dark = 10

	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "punches"

	organ_names = /decl/mob_organ_names/spider


	melee_damage_lower = 18
	melee_damage_upper = 30
	attack_sharp = TRUE
	attack_edge = 1
	attack_sound = 'sound/weapons/bite.ogg'

	heat_damage_per_tick = 20
	cold_damage_per_tick = 20
	minbodytemp = 175 // So they can all survive Sif without having to be classed under /sif subtype.

	speak_emote = list("chitters")

	meat_amount = 5
	meat_type = /obj/item/reagent_containers/food/snacks/xenomeat/spidermeat

	say_list_type = /datum/say_list/spider

	tame_items = list(
	/obj/item/reagent_containers/food/snacks/xenomeat = 10,
	/obj/item/reagent_containers/food/snacks/crabmeat = 40,
	/obj/item/reagent_containers/food/snacks/meat = 20
	)

	var/poison_type = REAGENT_ID_SPIDERTOXIN	// The reagent that gets injected when it attacks.
	var/poison_chance = 10			// Chance for injection to occur.
	var/poison_per_bite = 5			// Amount added per injection.

	butchery_loot = list(\
		/obj/item/stack/material/chitin = 1\
		)

	allow_mind_transfer = TRUE
	can_be_drop_prey = FALSE
	species_sounds = "Spider"
	pain_emote_1p = list("chitter", "click")
	pain_emote_3p = list("chitters", "clicks")

	var/warning_warmup = 2 SECONDS // How long the leap telegraphing is.
	var/warning_sound = 'sound/weapons/spiderlunge.ogg'

	no_pull_when_living = TRUE


/mob/living/simple_mob/animal/giant_spider/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swarming)

/mob/living/simple_mob/animal/giant_spider/CanPass(atom/movable/mover, turf/target)
	if(isliving(mover) && !istype(mover, /mob/living/simple_mob/animal/giant_spider) && mover.density == TRUE && stat != DEAD)
		return FALSE
	return ..()

/mob/living/simple_mob/animal/giant_spider/apply_melee_effects(var/atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.reagents)
			var/target_zone = pick(BP_TORSO,BP_TORSO,BP_TORSO,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_HEAD)
			if(L.can_inject(src, null, target_zone))
				inject_poison(L, target_zone)

// Does actual poison injection, after all checks passed.
/mob/living/simple_mob/animal/giant_spider/proc/inject_poison(mob/living/L, target_zone)
	if(prob(poison_chance))
		to_chat(L, span_warning("You feel a tiny prick."))
		L.reagents.add_reagent(poison_type, poison_per_bite)

/mob/living/simple_mob/animal/giant_spider/proc/make_spiderling()
	adjust_scale(icon_scale_x * 0.7, icon_scale_y * 0.7)
	maxHealth = round(maxHealth * 0.5)
	health = round(health * 0.5)
	melee_damage_lower *= 0.7
	melee_damage_upper *= 0.7

	response_harm = "kicks"

	see_in_dark = max(2, round(see_in_dark * 0.6))

	if(poison_per_bite)
		poison_per_bite *= 1.3

// A different type of much weaker bite with different effects for event spawned spiders before becoming hostile
/mob/living/simple_mob/animal/giant_spider/proc/warning_bite(mob/living/A)
	set waitfor = FALSE
	set_AI_busy(TRUE)

	// Telegraph, since getting bitten suddenly feels bad.
	do_windup_animation(A, warning_warmup)
	addtimer(CALLBACK(src, PROC_REF(warning_leap), A), warning_warmup) // For the telegraphing.

/mob/living/simple_mob/animal/giant_spider/proc/warning_leap(mob/living/A)
	// Do the actual leap.
	status_flags |= LEAPING // Lets us pass over everything.
	visible_message(span_danger("\The [src] leaps at \the [A]!"))
	throw_at(get_step(get_turf(A), get_turf(src)), 4, 1, src)
	playsound(src, warning_sound, 75, 1)

	addtimer(CALLBACK(src, PROC_REF(warning_finish), A), 0.5 SECONDS) // For the throw to complete. It won't hold up the AI ticker due to waitfor being false.

/mob/living/simple_mob/animal/giant_spider/proc/warning_finish(mob/living/A)
	if(status_flags & LEAPING)
		status_flags &= ~LEAPING // Revert special passage ability.

	. = FALSE

	// Now for the bite.
	var/mob/living/victim = null
	for(var/mob/living/L in oview(1,src)) // So player-controlled spiders only need to click the tile to stun them.
		if(L == src)
			continue

		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.check_shields(damage = 0, damage_source = src, attacker = src, def_zone = null, attack_text = "the leap"))
				continue // We were blocked.

		victim = L
		break

	if(victim?.reagents)
		victim.reagents.add_reagent(REAGENT_ID_WARNINGTOXIN, poison_per_bite)
		victim.AdjustWeakened(2)
		victim.visible_message(span_danger("\The [src] has bitten \the [victim]!"))
		to_chat(victim, span_critical("\The [src] bites you and retreats!"))
		. = TRUE

	step_away(src,victim,3)

	set_AI_busy(FALSE)

/decl/mob_organ_names/spider
	hit_zones = list("cephalothorax", "abdomen", "left forelegs", "right forelegs", "left hind legs", "right hind legs", "pedipalp", "mouthparts")
