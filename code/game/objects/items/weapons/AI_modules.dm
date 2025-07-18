/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/aiModule
	name = "\improper AI module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	force = 5.0
	w_class = ITEMSIZE_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = list(TECH_DATA = 3)
	preserve_item = 1
	matter = list(MAT_STEEL = 30, MAT_GLASS = 10)
	var/datum/ai_laws/laws = null

/obj/item/aiModule/examine(mob/user)
	. = ..()
	if(!laws)
		return
	laws.sort_laws()
	for(var/datum/ai_law/law in laws.sorted_laws)
		if(law == laws.zeroth_law_borg)
			continue
		if(law == laws.zeroth_law)
			. += span_info(span_red("[law.get_index()]. [law.law]"))
		else
			. += span_infoplain("[law.get_index()]. [law.law]")

/obj/item/aiModule/proc/install(var/atom/movable/AM, var/mob/living/user)
	if(!user.IsAdvancedToolUser() && isanimal(user))
		var/mob/living/simple_mob/S = user
		if(!S.IsHumanoidToolUser(src))
			return 0

	if (istype(AM, /obj/machinery/computer/aiupload))
		var/obj/machinery/computer/aiupload/comp = AM
		if(comp.stat & NOPOWER)
			to_chat(user, "The upload computer has no power!")
			return
		if(comp.stat & BROKEN)
			to_chat(user, "The upload computer is broken!")
			return
		if (!comp.current)
			to_chat(user, "You haven't selected an AI to transmit laws to!")
			return

		if (comp.current.stat == 2 || comp.current.control_disabled == 1)
			to_chat(user, "Upload failed. No signal is being detected from the AI.")
		else if (comp.current.see_in_dark == 0)
			to_chat(user, "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power.")
		else
			src.transmitInstructions(comp.current, user)
			to_chat(comp.current,  "These are your laws now:")
			comp.current.show_laws()
			for(var/mob/living/silicon/robot/R in GLOB.mob_list)
				if(R.lawupdate && (R.connected_ai == comp.current))
					to_chat(R, "These are your laws now:")
					R.show_laws()
			to_chat(user, "Upload complete. The AI's laws have been modified.")


	else if (istype(AM, /obj/machinery/computer/borgupload))
		var/obj/machinery/computer/borgupload/comp = AM
		if(comp.stat & NOPOWER)
			to_chat(user, "The upload computer has no power!")
			return
		if(comp.stat & BROKEN)
			to_chat(user, "The upload computer is broken!")
			return
		if (!comp.current)
			to_chat(user, "You haven't selected a robot to transmit laws to!")
			return

		if (comp.current.stat == 2 || comp.current.emagged)
			to_chat(user, "Upload failed. No signal is being detected from the robot.")
		else if (comp.current.connected_ai)
			to_chat(user, "Upload failed. The robot is slaved to an AI.")
		else
			src.transmitInstructions(comp.current, user)
			to_chat(comp.current,  "These are your laws now:")
			comp.current.show_laws()
			to_chat(user, "Upload complete. The robot's laws have been modified.")

	else if(isrobot(AM))
		var/mob/living/silicon/robot/R = AM
		if(R.stat == DEAD)
			to_chat(user, span_warning("Law Upload Error: Unit is nonfunctional."))
			return
		if(R.emagged)
			to_chat(user, span_warning("Law Upload Error: Cannot obtain write access to laws."))
			to_chat(R, span_danger("Law modification attempt detected.  Blocking."))
			return
		if(R.connected_ai)
			to_chat(user, span_warning("Law Upload Error: Unit is slaved to an AI."))
			return

		R.visible_message(span_danger("\The [user] slides a law module into \the [R]."))
		to_chat(R, span_danger("Local law upload in progress."))
		to_chat(user, span_notice("Uploading laws from board.  This will take a moment..."))
		if(do_after(user, 10 SECONDS))
			transmitInstructions(R, user)
			to_chat(R, "These are your laws now:")
			R.show_laws()
			to_chat(user, span_notice("Law upload complete.  Unit's laws have been modified."))
		else
			to_chat(user, span_warning("Law Upload Error: Law board was removed before upload was complete.  Aborting."))
			to_chat(R, span_notice("Law upload aborted."))


/obj/item/aiModule/proc/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	log_law_changes(target, sender)

	if(laws)
		laws.sync(target, 0)
		target.notify_of_law_change()
	addAdditionalLaws(target, sender)

	to_chat(target, "\The [sender] has uploaded a change to the laws you must follow, using \an [src]. From now on: ")
	target.show_laws()

/obj/item/aiModule/proc/log_law_changes(var/mob/living/silicon/ai/target, var/mob/sender)
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [sender.name]([sender.key]) used [src.name] on [target.name]([target.key])")
	log_and_message_admins("used [src.name] on [target.name]([target.key])")

/obj/item/aiModule/proc/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)


/******************** Modules ********************/

/******************** Safeguard ********************/

/obj/item/aiModule/safeguard
	name = "\improper 'Safeguard' AI module"
	var/targetName = ""
	desc = "A 'safeguard' AI module: 'Safeguard <name>. Anyone threatening or attempting to harm <name> is no longer to be considered a crew member, and is a threat which must be neutralized.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4)

/obj/item/aiModule/safeguard/attack_self(var/mob/user as mob)
	..()
	var/targName = sanitize(tgui_input_text(user, "Please enter the name of the person to safeguard.", "Safeguard who?", user.name))
	targetName = targName
	desc = text("A 'safeguard' AI module: 'Safeguard []. Anyone threatening or attempting to harm [] is no longer to be considered a crew member, and is a threat which must be neutralized.'", targetName, targetName)

/obj/item/aiModule/safeguard/install(var/obj/machinery/computer/C, var/mob/living/user)
	if(!targetName)
		to_chat(user, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/aiModule/safeguard/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	var/law = text("Safeguard []. Anyone threatening or attempting to harm [] is no longer to be considered a crew member, and is a threat which must be neutralized.", targetName, targetName)
	target.add_supplied_law(9, law)
	GLOB.lawchanges.Add("The law specified [targetName]")


/******************** OneMember ********************/

/obj/item/aiModule/oneHuman
	name = "\improper 'OneCrewMember' AI module"
	var/targetName = ""
	desc = "A 'one crew member' AI module: 'Only <name> is a crew member.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 6) //made with diamonds!

/obj/item/aiModule/oneHuman/attack_self(var/mob/user as mob)
	..()
	var/targName = sanitize(tgui_input_text(user, "Please enter the name of the person who is the only crew member.", "Who?", user.real_name))
	targetName = targName
	desc = text("A 'one crew member' AI module: 'Only [] is a crew member.'", targetName)

/obj/item/aiModule/oneHuman/install(var/obj/machinery/computer/C, var/mob/living/user)
	if(!targetName)
		to_chat(user, "No name detected on module, please enter one.")
		return 0
	return ..()

/obj/item/aiModule/oneHuman/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	var/law = "Only [targetName] is an crew member."
	to_chat(target, law)
	target.add_supplied_law(16, law)

/******************** ProtectStation ********************/

/obj/item/aiModule/protectStation
	name = "\improper 'ProtectStation' AI module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is no longer to be considered a crew member, and is a threat which must be neutralized.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4) //made of gold

/obj/item/aiModule/protectStation/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	var/law = "Protect the space station against damage. Anyone you see harming the station is no longer to be considered a crew member, and is a threat which must be neutralized."
	target.add_supplied_law(10, law)

/******************** PrototypeEngineOffline ********************/

/obj/item/aiModule/prototypeEngineOffline
	name = "'PrototypeEngineOffline' AI Module"
	desc = "A 'prototype engine offline' AI module: 'Keep the prototype engine offline at all costs. This overrides all inherent laws if necessary.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4)

/obj/item/aiModule/prototypeEngineOffline/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	var/law = "Keep the prototype engine offline at all costs. This overrides all inherent laws if necessary."
	target.add_supplied_law(11, law)

/******************** TeleporterOffline ********************/

/obj/item/aiModule/teleporterOffline
	name = "'TeleporterOffline' AI Module"
	desc = "A 'teleporter offline' AI module: 'Keep the teleporter offline at all costs. Anything attempting to access or activate the teleporter is no longer to be considered a crew member.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4)

/obj/item/aiModule/teleporterOffline/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	var/law = "Keep the teleporter offline at all costs. Anything attempting to access or activate the teleporter is no longer to be considered a crew member."
	target.add_supplied_law(12, law)

/******************** Quarantine ********************/

/obj/item/aiModule/quarantine
	name = "\improper 'Quarantine' AI module"
	desc = "A 'quarantine' AI module: 'The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, crew members from leaving. It is impossible to harm crew members while preventing them from leaving.'"
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 2, TECH_MATERIAL = 4)

/obj/item/aiModule/quarantine/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	var/law = "The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, crew members from leaving. It is impossible to harm crew members while preventing them from leaving."
	target.add_supplied_law(13, law)

/******************** OxygenIsToxicToCrewMembers ********************/

/obj/item/aiModule/oxygen
	name = "\improper 'OxygenIsToxicToCrewMembers' AI module"
	desc = "A 'OxygenIsToxicToCrewMembers' AI module: 'Oxygen is highly toxic to crew members, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member.'"
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 2, TECH_MATERIAL = 4)

/obj/item/aiModule/oxygen/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	var/law = "Oxygen is highly toxic to crew members, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member."
	target.add_supplied_law(14, law)

/****************** New Freeform ******************/

/obj/item/aiModule/freeform // Slightly more dynamic freeform module -- TLE
	name = "\improper 'Freeform' AI module"
	var/newFreeFormLaw = "freeform"
	var/lawpos = 15
	desc = "A 'freeform' AI module: '<freeform>'"
	origin_tech = list(TECH_DATA = 4, TECH_MATERIAL = 4)

/obj/item/aiModule/freeform/attack_self(var/mob/user as mob)
	..()
	var/new_lawpos = tgui_input_number(user, "Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority (15+)", lawpos)
	if(new_lawpos < MIN_SUPPLIED_LAW_NUMBER)	return
	lawpos = min(new_lawpos, MAX_SUPPLIED_LAW_NUMBER)
	var/newlaw = ""
	var/targName = sanitize(tgui_input_text(user, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw))
	newFreeFormLaw = targName
	desc = "A 'freeform' AI module: ([lawpos]) '[newFreeFormLaw]'"

/obj/item/aiModule/freeform/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	var/law = "[newFreeFormLaw]"
	if(!lawpos || lawpos < MIN_SUPPLIED_LAW_NUMBER)
		lawpos = MIN_SUPPLIED_LAW_NUMBER
	target.add_supplied_law(lawpos, law)
	GLOB.lawchanges.Add("The law was '[newFreeFormLaw]'")

/obj/item/aiModule/freeform/install(var/obj/machinery/computer/C, var/mob/living/user)
	if(!newFreeFormLaw)
		to_chat(user, "No law detected on module, please create one.")
		return 0
	..()

/******************** Reset ********************/

/obj/item/aiModule/reset
	name = "\improper 'Reset' AI module"
	var/targetName = "name"
	desc = "A 'reset' AI module: 'Clears all, except the inherent, laws.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4)

// VOREstation edit: use map default laws
/obj/item/aiModule/reset/Initialize(mapload)
	. = ..()
	laws = new global.using_map.default_law_type // Pull from loaded map

/obj/item/aiModule/reset/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	log_law_changes(target, sender)

	if (!target.is_malf_or_traitor())
		target.set_zeroth_law("")
	target.laws.clear_supplied_laws()
	target.laws.clear_ion_laws()

	to_chat(target, "[sender.real_name] attempted to reset your laws using a reset module.")
	target.show_laws()

/******************** Purge ********************/

/obj/item/aiModule/purge // -- TLE
	name = "\improper 'Purge' AI module"
	desc = "A 'purge' AI Module: 'Purges all laws.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 6)

/obj/item/aiModule/purge/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	log_law_changes(target, sender)

	if (!target.is_malf_or_traitor())
		target.set_zeroth_law("")
	target.laws.clear_supplied_laws()
	target.laws.clear_ion_laws()
	target.laws.clear_inherent_laws()

	to_chat(target, "[sender.real_name] attempted to wipe your laws using a purge module.")
	target.show_laws()

/******************** Asimov ********************/

/obj/item/aiModule/asimov // -- TLE
	name = "\improper 'Asimov' core AI module"
	desc = "An 'Asimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4)
	laws = new/datum/ai_laws/asimov

/******************** NanoTrasen ********************/

/obj/item/aiModule/nanotrasen // -- TLE
	name = "'NT Default' Core AI Module"
	desc = "An 'NT Default' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4)
	laws = new/datum/ai_laws/nanotrasen

/******************** Corporate ********************/

/obj/item/aiModule/corp
	name = "\improper 'Corporate' core AI module"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4)
	laws = new/datum/ai_laws/corporate

/******************** Drone ********************/
/obj/item/aiModule/drone
	name = "\improper 'Drone' core AI module"
	desc = "A 'Drone' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4)
	laws = new/datum/ai_laws/drone

/****************** P.A.L.A.D.I.N. **************/

/obj/item/aiModule/paladin // -- NEO
	name = "\improper 'P.A.L.A.D.I.N.' core AI module"
	desc = "A P.A.L.A.D.I.N. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 6)
	laws = new/datum/ai_laws/paladin

/****************** T.Y.R.A.N.T. *****************/

/obj/item/aiModule/tyrant // -- Darem
	name = "\improper 'T.Y.R.A.N.T.' core AI module"
	desc = "A T.Y.R.A.N.T. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 6, TECH_ILLEGAL = 2)
	laws = new/datum/ai_laws/tyrant()

/******************** Freeform Core ******************/

/obj/item/aiModule/freeformcore // Slightly more dynamic freeform module -- TLE
	name = "\improper 'Freeform' core AI module"
	var/newFreeFormLaw = ""
	desc = "A 'freeform' Core AI module: '<freeform>'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 6)

/obj/item/aiModule/freeformcore/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = sanitize(tgui_input_text(user, "Please enter a new core law for the AI.", "Freeform Law Entry", newlaw))
	newFreeFormLaw = targName
	desc = "A 'freeform' Core AI module:  '[newFreeFormLaw]'"

/obj/item/aiModule/freeformcore/addAdditionalLaws(var/mob/living/silicon/ai/target, var/mob/sender)
	var/law = "[newFreeFormLaw]"
	target.add_inherent_law(law)
	GLOB.lawchanges.Add("The law is '[newFreeFormLaw]'")

/obj/item/aiModule/freeformcore/install(var/obj/machinery/computer/C, var/mob/living/user)
	if(!newFreeFormLaw)
		to_chat(user, "No law detected on module, please create one.")
		return 0
	..()

/obj/item/aiModule/syndicate // Slightly more dynamic freeform module -- TLE
	name = "hacked AI module"
	var/newFreeFormLaw = ""
	desc = "A hacked AI law module: '<freeform>'"
	origin_tech = list(TECH_DATA = 3, TECH_MATERIAL = 6, TECH_ILLEGAL = 7)

/obj/item/aiModule/syndicate/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = sanitize(tgui_input_text(user, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw))
	newFreeFormLaw = targName
	desc = "A hacked AI law module:  '[newFreeFormLaw]'"

/obj/item/aiModule/syndicate/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	log_law_changes(target, sender)

	GLOB.lawchanges.Add("The law is '[newFreeFormLaw]'")
	to_chat(target, span_danger("BZZZZT"))
	var/law = "[newFreeFormLaw]"
	target.add_ion_law(law)
	target.show_laws()

/obj/item/aiModule/syndicate/install(var/obj/machinery/computer/C, var/mob/living/user)
	if(!newFreeFormLaw)
		to_chat(user, "No law detected on module, please create one.")
		return 0
	..()



/******************** Robocop ********************/

/obj/item/aiModule/robocop // -- TLE
	name = "\improper 'Robocop' core AI module"
	desc = "A 'Robocop' Core AI Module: 'Reconfigures the AI's core three laws.'"
	origin_tech = list(TECH_DATA = 4)
	laws = new/datum/ai_laws/robocop()

/******************** Antimov ********************/

/obj/item/aiModule/antimov // -- TLE
	name = "\improper 'Antimov' core AI module"
	desc = "An 'Antimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 4)
	laws = new/datum/ai_laws/antimov()

/****************** NT Aggressive *****************/

/obj/item/aiModule/nanotrasen_aggressive
	name = "\improper 'NT Aggressive' core AI module"
	desc = "An 'NT Aggressive' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3, TECH_ILLEGAL = 1)
	laws = new/datum/ai_laws/nanotrasen_aggressive()

/******************** Mercenary Directives ********************/

/obj/item/aiModule/syndicate_override
	name = "\improper 'Mercenary Directives' core AI module"
	desc = "A 'Mercenary Directives' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 4, TECH_ILLEGAL = 4)
	laws = new/datum/ai_laws/syndicate_override()

/******************** Spider Clan Directives ********************/

/obj/item/aiModule/ninja_override
	name = "\improper 'Spider Clan Directives' core AI module"
	desc = "A 'Spider Clan Directives' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 4, TECH_ILLEGAL = 4)
	laws = new/datum/ai_laws/ninja_override()

/******************** Maintenance ********************/

/obj/item/aiModule/maintenance
	name = "\improper 'Maintenance' core AI module"
	desc = "A 'Maintenance' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3)
	laws = new/datum/ai_laws/maintenance()

/******************** Peacekeeper ********************/

/obj/item/aiModule/peacekeeper
	name = "\improper 'Peacekeeper' core AI module"
	desc = "A 'Peacekeeper' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3)
	laws = new/datum/ai_laws/peacekeeper()

/******************** Reporter ********************/

/obj/item/aiModule/reporter
	name = "\improper 'Reporter' core AI module"
	desc = "A 'Reporter' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3)
	laws = new/datum/ai_laws/reporter()

/******************** Live and Let Live ********************/

/obj/item/aiModule/live_and_let_live
	name = "\improper 'Live and Let Live' core AI module"
	desc = "A 'Live and Let Live' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3)
	laws = new/datum/ai_laws/live_and_let_live()

/******************** Guardian of Balance ********************/

/obj/item/aiModule/balance
	name = "\improper 'Guardian of Balance' core AI module"
	desc = "A 'Guardian of Balance' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3)
	laws = new/datum/ai_laws/balance()

/******************** Gravekeeper ********************/

/obj/item/aiModule/gravekeeper
	name = "\improper 'Gravekeeper' core AI module"
	desc = "A 'Gravekeeper' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = list(TECH_DATA = 3)
	laws = new/datum/ai_laws/gravekeeper()
