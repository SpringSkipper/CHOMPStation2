// Alien larva are quite simple.
/mob/living/carbon/alien/Life()

	set invisibility = INVISIBILITY_NONE

	if (transforming)	return
	if(!loc)			return

	..()

	if (stat != DEAD) //still breathing
		// GROW!
		update_progression()

	blinded = null

	//Status updates, death etc.
	update_icons()

/mob/living/carbon/alien/handle_mutations_and_radiation()

	// Currently both Dionaea and larvae like to eat radiation, so I'm defining the
	// rad absorbtion here. This will need to be changed if other baby aliens are added.

	if(!radiation)
		return

	var/rads = radiation/25
	radiation -= rads
	//adjust_nutrition(rads) //Commented out to prevent alien obesity.
	heal_overall_damage(rads,rads)
	adjustOxyLoss(-(rads))
	adjustToxLoss(-(rads))
	return

/mob/living/carbon/alien/handle_regular_status_updates()

	if(SEND_SIGNAL(src, COMSIG_CHECK_FOR_GODMODE) & COMSIG_GODMODE_CANCEL) //I don't want to go in and do HUD stuff imediately, so... no.
		return 0	// Cancelled by a component

	if(stat == DEAD)
		blinded = 1
		silent = 0
		deaf_loop.stop() // CHOMPStation Add: Ear Ringing/Deafness - Not sure if we need this, but, safety.
	else
		updatehealth()
		if(health <= 0)
			death()
			blinded = 1
			silent = 0
			deaf_loop.stop() // CHOMPStation Add: Ear Ringing/Deafness - Not sure if we need this, but, safety.
			return 1

		if(paralysis && paralysis > 0)
			blinded = 1
			set_stat(UNCONSCIOUS)
			if(halloss > 0)
				adjustHalLoss(-3)

		if(sleeping)
			adjustHalLoss(-3)
			if (mind)
				if(mind.active && client != null)
					AdjustSleeping(-1)
			blinded = 1
			set_stat(UNCONSCIOUS)
		else if(resting)
			if(halloss > 0)
				adjustHalLoss(-3)

		else
			set_stat(CONSCIOUS)
			if(halloss > 0)
				adjustHalLoss(-1)

		// Eyes and blindness.
		if(!has_eyes())
			SetBlinded(1)
			blinded =    1
			eye_blurry = 1
		else if(eye_blind)
			AdjustBlinded(-1)
			blinded =    1
		else if(eye_blurry)
			eye_blurry = max(eye_blurry-1, 0)

		update_icons()

	return 1

/mob/living/carbon/alien/handle_regular_hud_updates()

	if (stat == 2 || (XRAY in src.mutations))
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if (stat != 2)
		sight &= ~SEE_TURFS
		sight &= ~SEE_MOBS
		sight &= ~SEE_OBJS
		see_in_dark = 2
		see_invisible = SEE_INVISIBLE_LIVING

	if (healths)
		if (stat != 2)
			switch(health)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(80 to 100)
					healths.icon_state = "health1"
				if(60 to 80)
					healths.icon_state = "health2"
				if(40 to 60)
					healths.icon_state = "health3"
				if(20 to 40)
					healths.icon_state = "health4"
				if(0 to 20)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if (client)
		client.screen.Remove(GLOB.global_hud.blurry,GLOB.global_hud.druggy,GLOB.global_hud.vimpaired)

	if ( stat != 2)
		if ((blinded))
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		else
			clear_fullscreen("blind")
			set_fullscreen(disabilities & NEARSIGHTED, "impaired", /obj/screen/fullscreen/impaired, 1)
			set_fullscreen(eye_blurry, "blurry", /obj/screen/fullscreen/blurry)
			set_fullscreen(druggy, "high", /obj/screen/fullscreen/high)
		if(machine)
			if(machine.check_eye(src) < 0)
				reset_view(null)
		else
			if(client && !client.adminobs)
				reset_view(null)

	return 1

/mob/living/carbon/alien/handle_environment(var/datum/gas_mixture/environment)
	// Both alien subtypes survive in vaccum and suffer in high temperatures,
	// so I'll just define this once, for both (see radiation comment above)
	if(!environment) return

	if(environment.temperature > (T0C+66))
		adjustFireLoss((environment.temperature - (T0C+66))/5) // Might be too high, check in testing.
		throw_alert("alien_fire", /obj/screen/alert/alien_fire)
		if(prob(20))
			to_chat(src, span_red("You feel a searing heat!"))
	else
		clear_alert("alien_fire")

/mob/living/carbon/alien/handle_fire()
	if(..())
		return
	bodytemperature += BODYTEMP_HEATING_MAX //If you're on fire, you heat up!
	return
