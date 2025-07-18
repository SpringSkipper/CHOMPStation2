/datum/power/changeling/bioelectrogenesis
	name = "Bioelectrogenesis"
	desc = "We reconfigure a large number of cells in our body to generate an electric charge.  \
	On demand, we can attempt to recharge anything in our active hand, or we can touch someone with an electrified hand, shocking them."
	helptext = "We can shock someone by grabbing them and using this ability, or using the ability with an empty hand and touching them.  \
	Shocking someone costs ten chemicals per use."
	enhancedtext = "Shocking biologicals without grabbing only requires five chemicals, and has more disabling power."
	ability_icon_state = "ling_bioelectrogenesis"
	genomecost = 2
	verbpath = /mob/living/carbon/human/proc/changeling_bioelectrogenesis

//Recharge whatever's in our hand, or shock people.
/mob/living/carbon/human/proc/changeling_bioelectrogenesis()
	set category = "Changeling"
	set name = "Bioelectrogenesis (20 + 10/shock)"
	set desc = "Recharges anything in your hand, or shocks people."

	var/datum/component/antag/changeling/changeling = changeling_power(20,0,100,CONSCIOUS)

	var/obj/held_item = get_active_hand()

	if(!changeling)
		return FALSE

	if(held_item == null)
		if(changeling.recursive_enhancement)
			if(changeling_generic_weapon(/obj/item/electric_hand/efficent,0))
				to_chat(src, span_notice("We will shock others more efficently."))
				return TRUE
		else
			if(changeling_generic_weapon(/obj/item/electric_hand,0))  //Chemical cost is handled in the equip proc.
				return TRUE
		return FALSE

	else
		// Handle glove conductivity.
		var/obj/item/clothing/gloves/gloves = src.gloves
		var/siemens = 1
		if(gloves)
			siemens = gloves.siemens_coefficient //Funnily enough, this means things like Knights Gloves will make you stun 2x harder and charge 2x more!

		//If we're grabbing someone, electrocute them.
		if(istype(held_item,/obj/item/grab))
			var/obj/item/grab/G = held_item
			if(G.affecting)
				G.affecting.electrocute_act(10 * siemens, src, 1.0, BP_TORSO, 0)
				var/agony = 80 * siemens //Does more than if hit with an electric hand, since grabbing is slower.
				G.affecting.stun_effect_act(0, agony, BP_TORSO, src)

				add_attack_logs(src,G.affecting,"Changeling shocked")

				if(siemens)
					visible_message(span_warning("Arcs of electricity strike [G.affecting]!"),
					span_warning("Our hand channels raw electricity into [G.affecting]."),
					span_warningplain("You hear sparks!"))
				else
					to_chat(src, span_warning("Our gloves block us from shocking \the [G.affecting]."))
				changeling.chem_charges -= 10
				return TRUE

		//Otherwise, charge up whatever's in their hand.
		else
			//This checks both the active hand, and the contents of the active hand's held item.
			var/success = FALSE
			var/list/L = new() //We make a new list to avoid copypasta.

			//Check our hand.
			if(istype(held_item,/obj/item/cell))
				L.Add(held_item)

			//Now check our hand's item's contents, so we can recharge guns and other stuff.
			for(var/obj/item/cell/cell in held_item.contents)
				L.Add(cell)

			//Now for the actual recharging.
			for(var/obj/item/cell/cell in L)
				visible_message(span_warning("Some sparks fall out from \the [src.name]\'s [held_item]!"),
				span_warning("Our hand channels raw electricity into \the [held_item]. We must remain by the [held_item] to recharge it."),
				span_warningplain("You hear sparks!"))
				cell.gradual_charge(10, siemens, TRUE, src)
				success = TRUE
			if(success == FALSE) //If we couldn't do anything with the ability, don't deduct the chemicals.
				to_chat(src, span_warning("We are unable to affect \the [held_item]."))
			else
				changeling.chem_charges -= 10
			return success

/obj/item/electric_hand
	name = "electrified hand"
	desc = "You could probably shock someone badly if you touched them, or recharge something."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "electric_hand"
	show_examine = FALSE
	destroy_on_drop = TRUE

	var/shock_cost = 10
	var/agony_amount = 60
	var/electrocute_amount = 10

/obj/item/electric_hand/efficent
	shock_cost = 5
	agony_amount = 80
	electrocute_amount = 20

/obj/item/electric_hand/Initialize(mapload)
	. = ..()
	if(ismob(loc))
		visible_message(span_warning("Electrical arcs form around [loc.name]\'s hand!"),
		span_warning("We store a charge of electricity in our hand."),
		span_warningplain("You hear crackling electricity!"))
		var/T = get_turf(src)
		new /obj/effect/effect/sparks(T)

/obj/item/electric_hand/afterattack(var/atom/target, var/mob/living/carbon/human/user, proximity)
	if(!target)
		return
	if(!proximity)
		return

	// Handle glove conductivity.
	var/obj/item/clothing/gloves/gloves = user.gloves
	var/siemens = 1
	if(gloves)
		siemens = gloves.siemens_coefficient

	//Excuse the copypasta.
	var/datum/component/antag/changeling/comp = is_changeling(user)
	if(istype(target,/mob/living/carbon))
		var/mob/living/carbon/C = target

		if(comp.chem_charges < shock_cost)
			to_chat(src, span_warning("We require more chemicals to electrocute [C]!"))
			return FALSE

		C.electrocute_act(electrocute_amount * siemens,src,1.0,BP_TORSO)
		C.stun_effect_act(0, agony_amount * siemens, BP_TORSO, src)

		add_attack_logs(user,C,"Shocked with [src]")

		if(siemens)
			visible_message(span_warning("Arcs of electricity strike [C]!"),
			span_warning("Our hand channels raw electricity into [C]"),
			span_warningplain("You hear sparks!"))
		else
			to_chat(src, span_warning("Our gloves block us from shocking \the [C]."))
		comp.chem_charges -= shock_cost
		return TRUE

	else if(istype(target,/mob/living/silicon))
		var/mob/living/silicon/S = target

		if(comp.chem_charges < 10)
			to_chat(src, span_warning("We require more chemicals to electrocute [S]!"))
			return FALSE

		S.electrocute_act(60,src,0.75) //If only they had surge protectors.
		if(siemens)
			visible_message(span_warning("Arcs of electricity strike [S]!"),
			span_warning("Our hand channels raw electricity into [S]"),
			span_warningplain("You hear sparks!"))
			to_chat(S, span_danger("Warning: Electrical surge detected!"))
		comp.chem_charges -= 10
		return TRUE

	else
		if(istype(target,/obj/))
			var/success = FALSE
			var/obj/T = target
			//We can also recharge things we touch, such as APCs or hardsuits.
			for(var/obj/item/cell/cell in T.contents)
				visible_message(span_warning("Some sparks fall out from \the [target]!"),
				span_warning("Our hand channels raw electricity into \the [target]."),
				span_warningplain("You hear sparks!"))
				cell.gradual_charge(10, siemens, TRUE, src)
				success = TRUE
			if(success == FALSE)
				to_chat(src, span_warning("We are unable to affect \the [target]."))
			else
				qdel(src)
			return TRUE
