
/datum/event/viral_outbreak
	var/severity = 1

/datum/event/viral_outbreak/setup()
	announceWhen = rand(0, 3000)
	endWhen = announceWhen + 1
	severity = rand(2, 4)

/datum/event/viral_outbreak/announce()
	command_alert("Confirmed outbreak of level 7 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Viral Outbreak")
	world << sound('sound/AI/outbreak7.ogg')
	// Chomp edit: Changed "Biohazard Alert" to "Viral Outbreak" and yes I know this file isn't used anymore but I'm going to be consistent in case it does get used.

/datum/event/viral_outbreak/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)	return
	candidates = shuffle(candidates)//Incorporating Donkie's list shuffle

	while(severity > 0 && candidates.len)
		if(prob(33))
			infect_mob_random_lesser(candidates[1])
		else
			infect_mob_random_greater(candidates[1])

		candidates.Remove(candidates[1])
		severity--
