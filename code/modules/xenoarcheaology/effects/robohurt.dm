/datum/artifact_effect/robohurt
	name = "robotic harm"
	var/last_message

	effect_color = "#5432cf"

/datum/artifact_effect/robohurt/New()
	..()
	effect_type = pick(EFFECT_ELECTRO, EFFECT_PARTICLE)

/datum/artifact_effect/robohurt/DoEffectTouch(var/mob/user)
	if(user)
		if (isrobot(user))
			var/mob/living/silicon/robot/R = user
			to_chat(R, span_red("Your systems report severe damage has been inflicted!"))
			R.adjustBruteLoss(rand(10,50))
			R.adjustFireLoss(rand(10,50))
			return 1

/datum/artifact_effect/robohurt/DoEffectAura()
	var/atom/holder = get_master_holder()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/mob/living/silicon/robot/M in range(src.effectrange,T))
			if(world.time - last_message > 200)
				to_chat(M, span_red("SYSTEM ALERT: Harmful energy field detected!"))
				last_message = world.time
			M.adjustBruteLoss(1)
			M.adjustFireLoss(1)
			M.updatehealth()
		return 1

/datum/artifact_effect/robohurt/DoEffectPulse()
	var/atom/holder = get_master_holder()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/mob/living/silicon/robot/M in range(src.effectrange,T))
			if(world.time - last_message > 200)
				to_chat(M, span_red("SYSTEM ALERT: Structural damage inflicted by energy pulse!"))
				last_message = world.time
			M.adjustBruteLoss(10)
			M.adjustFireLoss(10)
			M.updatehealth()
		return 1
