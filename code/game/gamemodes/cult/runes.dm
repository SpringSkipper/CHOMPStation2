var/list/sacrificed = list()

/obj/effect/rune/cultify()
	return

/*
 * Use as a general guideline for this and related files:
 *  * span_warning("...") - when something non-trivial or an error happens, so something similar to "Sparks come out of the machine!"
 *  * span_danger("...")  - when something that is fit for 'warning' happens but there is some damage or pain as well.
 *  * span_cult("...")    - when there is a private message to the cultists. This guideline is very arbitrary but there has to be some consistency!
 */


/////////////////////////////////////////FIRST RUNE
/obj/effect/rune/proc/teleport(var/key)
	var/mob/living/user = usr
	var/allrunesloc[]
	allrunesloc = new/list()
	var/index = 0
	for(var/obj/effect/rune/R in GLOB.rune_list)
		if(R == src)
			continue
		if(R.word1 == GLOB.cultwords["travel"] && R.word2 == GLOB.cultwords["self"] && R.word3 == key && isPlayerLevel(R.z))
			index++
			allrunesloc.len = index
			allrunesloc[index] = R.loc
	if(index >= 5)
		to_chat(user, span_danger("You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric."))
		if (isliving(user))
			user.take_overall_damage(5, 0)
		qdel(src)
	if(allrunesloc && index != 0)
		if(istype(src,/obj/effect/rune))
			user.say("Sas[pick("'","`")]so c'arta forbici!")//Only you can stop auto-muting
		else
			user.whisper("Sas[pick("'","`")]so c'arta forbici!")
		user.visible_message(span_danger("[user] disappears in a flash of red light!"), \
		span_danger("You feel as your body gets dragged through the dimension of Nar-Sie!"), \
		span_danger("You hear a sickening crunch and sloshing of viscera."))
		user.loc = allrunesloc[rand(1,index)]
		return
	if(istype(src,/obj/effect/rune))
		return	fizzle() //Use friggin manuals, Dorf, your list was of zero length.
	else
		call(/obj/effect/rune/proc/fizzle)()
		return


/obj/effect/rune/proc/itemport(var/key)
	var/culcount = 0
	var/runecount = 0
	var/obj/effect/rune/IP = null
	var/mob/living/user = usr
	for(var/obj/effect/rune/R in GLOB.rune_list)
		if(R == src)
			continue
		if(R.word1 == GLOB.cultwords["travel"] && R.word2 == GLOB.cultwords["other"] && R.word3 == key)
			IP = R
			runecount++
	if(runecount >= 2)
		to_chat(user, span_danger("You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric."))
		if (isliving(user))
			user.take_overall_damage(5, 0)
		qdel(src)
	for(var/mob/living/carbon/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount>=3)
		user.say("Sas[pick("'","`")]so c'arta forbici tarem!")
		user.visible_message(span_warning("You feel air moving from the rune - like as it was swapped with somewhere else."), \
		span_warning("You feel air moving from the rune - like as it was swapped with somewhere else."), \
		span_warning("You smell ozone."))
		for(var/obj/O in src.loc)
			if(!O.anchored)
				O.loc = IP.loc
		for(var/mob/M in src.loc)
			M.loc = IP.loc
		return

	return fizzle()


/////////////////////////////////////////SECOND RUNE

/obj/effect/rune/proc/tomesummon()
	if(istype(src,/obj/effect/rune))
		usr.say("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	else
		usr.whisper("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	usr.visible_message(span_warning("Rune disappears with a flash of red light, and in its place now a book lies."), \
	span_warning("You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a book."), \
	span_warning("You hear a pop and smell ozone."))
	if(istype(src,/obj/effect/rune))
		new /obj/item/book/tome(src.loc)
	else
		new /obj/item/book/tome(usr.loc)
	qdel(src)
	return



/////////////////////////////////////////THIRD RUNE

/obj/effect/rune/proc/convert()
	var/mob/attacker = usr
	var/mob/living/carbon/target = null
	for(var/mob/living/carbon/M in src.loc)
		if(!iscultist(M) && M.stat < DEAD && !(M in converting))
			target = M
			break

	if(!target) //didn't find any new targets
		if(!converting.len)
			fizzle()
		else
			to_chat(usr, span_danger("You sense that the power of the dark one is already working away at them."))
		return

	usr.say("Mah[pick("'","`")]weyh pleggh at e'ntrath!")

	converting |= target
	var/list/waiting_for_input = list(target = 0) //need to box this up in order to be able to reset it again from inside spawn, apparently
	var/initial_message = 0
	while(target in converting)
		if(target.loc != src.loc || target.stat == DEAD)
			converting -= target
			if(target.getFireLoss() < 100)
				target.hallucination = min(target.hallucination, 500)
			return 0

		target.take_overall_damage(0, rand(5, 20)) // You dirty resister cannot handle the damage to your mind. Easily. - even cultists who accept right away should experience some effects
		// Resist messages go!
		if(initial_message) //don't do this stuff right away, only if they resist or hesitate.
			add_attack_logs(attacker,target,"Convert rune")
			switch(target.getFireLoss())
				if(0 to 25)
					to_chat(target, span_cult("Your blood boils as you force yourself to resist the corruption invading every corner of your mind."))
				if(25 to 45)
					to_chat(target, span_cult("Your blood boils and your body burns as the corruption further forces itself into your body and mind."))
				if(45 to 75)
					to_chat(target, span_cult("You begin to hallucinate images of a dark and incomprehensible being and your entire body feels like its engulfed in flame as your mental defenses crumble."))
					target.apply_effect(rand(1,10), STUTTER)
				if(75 to 100)
					to_chat(target, span_cult("Your mind turns to ash as the burning flames engulf your very soul and images of an unspeakable horror begin to bombard the last remnants of mental resistance."))
					//broken mind - 5000 may seem like a lot I wanted the effect to really stand out for maxiumum losing-your-mind-spooky
					//hallucination is reduced when the step off as well, provided they haven't hit the last stage...

					//5000 is waaaay too much, in practice.
					target.hallucination = min(target.hallucination + 100, 500)
					target.apply_effect(10, STUTTER)
					target.adjustBrainLoss(1)
				if(100 to INFINITY)
					to_chat(target, span_cult("Your entire broken soul and being is engulfed in corruption and flames as your mind shatters away into nothing."))
					//5000 is waaaay too much, in practice.
					target.hallucination = min(target.hallucination + 100, 500)
					target.apply_effect(15, STUTTER)
					target.adjustBrainLoss(1)

		initial_message = 1
		if (!target.can_feel_pain())
			target.visible_message(span_warning("The markings below \the [target] glow a bloody red."))
		else
			var/datum/gender/TT = GLOB.gender_datums[target.get_visible_gender()]
			target.visible_message(span_warning("[target] writhes in pain as the markings below [TT.him] glow a bloody red."), span_danger("AAAAAAHHHH!"), span_warning("You hear an anguished scream."))

		if(!waiting_for_input[target]) //so we don't spam them with dialogs if they hesitate
			waiting_for_input[target] = 1

			if(!cult.can_become_antag(target.mind) || jobban_isbanned(target, JOB_CULTIST))//putting jobban check here because is_convertable uses mind as argument
				//waiting_for_input ensures this is only shown once, so they basically auto-resist from here on out. They still need to find a way to get off the freaking rune if they don't want to burn to death, though.
				to_chat(target, span_cult("Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root."))
				to_chat(target, span_danger("And you were able to force it out of your mind. You now know the truth, there's something horrible out there, stop it and its minions at all costs."))

			else spawn()
				var/choice = tgui_alert(target,"Do you want to join the cult?","Submit to Nar'Sie",list("Resist","Submit"))
				waiting_for_input[target] = 0
				if(choice == "Submit") //choosing 'Resist' does nothing of course.
					cult.add_antagonist(target.mind)
					converting -= target
					target.hallucination = 0 //sudden clarity

		sleep(100) //proc once every 10 seconds
	return 1

/////////////////////////////////////////FOURTH RUNE

/obj/effect/rune/proc/tearreality()
	if(!cult.allow_narsie)
		return fizzle()

	var/list/cultists = new()
	for(var/mob/M in range(1,src))
		if(iscultist(M) && !M.stat)
			M.say("Tok-lyr rqa'nap g[pick("'","`")]lt-ulotf!")
			if(istype(M, /mob/living/carbon/human/dummy)) //No manifest cheese.
				continue
			cultists.Add(M)
	if(cultists.len >= 9)
		if(!narsie_cometh)//so we don't initiate Hell more than one time.
			to_world(span_narsie(span_red(span_bold("THE VEIL HAS BEEN SHATTERED!"))))
			world << sound('sound/effects/weather/old_wind/wind_5_1.ogg')

			SetUniversalState(/datum/universal_state/hell)
			narsie_cometh = 1

			spawn(10 SECONDS)
				if(emergency_shuttle)
					emergency_shuttle.call_evac()
					emergency_shuttle.launch_time = 0	// Cannot recall

		log_and_message_admins_many(cultists, "summoned the end of days.")
		return
	else
		return fizzle()

/////////////////////////////////////////FIFTH RUNE

/obj/effect/rune/proc/emp(var/U,var/range_red) //range_red - var which determines by which number to reduce the default emp range, U is the source loc, needed because of talisman emps which are held in hand at the moment of using and that apparently messes things up -- Urist
	log_and_message_admins("activated an EMP rune.")
	if(istype(src,/obj/effect/rune))
		usr.say("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	else
		usr.whisper("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	playsound(U, 'sound/items/Welder2.ogg', 25, 1)
	var/turf/T = get_turf(U)
	if(T)
		T.hotspot_expose(700,125)
	var/rune = src // detaching the proc - in theory
	empulse(U, (range_red - 3), (range_red - 2), (range_red - 1), range_red)
	qdel(rune)
	return

/////////////////////////////////////////SIXTH RUNE

/obj/effect/rune/proc/drain()
	var/drain = 0
	for(var/obj/effect/rune/R in GLOB.rune_list)
		if(R.word1==GLOB.cultwords["travel"] && R.word2==GLOB.cultwords["blood"] && R.word3==GLOB.cultwords["self"])
			for(var/mob/living/carbon/D in R.loc)
				if(D.stat!=2)
					add_attack_logs(usr,D,"Blood drain rune")
					var/bdrain = rand(1,25)
					to_chat(D, span_warning("You feel weakened."))
					D.take_overall_damage(bdrain, 0)
					drain += bdrain
	if(!drain)
		return fizzle()
	usr.say ("Yu[pick("'","`")]gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
	usr.visible_message(span_danger("Blood flows from the rune into [usr]!"), \
	span_danger("The blood starts flowing from the rune and into your frail mortal body. You feel... empowered."), \
	span_warning("You hear a liquid flowing."))
	var/mob/living/user = usr
	if(user.bhunger)
		user.bhunger = max(user.bhunger-2*drain,0)
	if(drain>=50)
		user.visible_message(span_danger("[user]'s eyes give off eerie red glow!"), \
		span_danger("...but it wasn't nearly enough. You crave, crave for more. The hunger consumes you from within."), \
		span_warning("You hear a heartbeat."))
		user.bhunger += drain
		src = user
		spawn()
			for (,user.bhunger>0,user.bhunger--)
				sleep(50)
				user.take_overall_damage(3, 0)
		return
	user.heal_organ_damage(drain%5, 0)
	drain-=drain%5
	for (,drain>0,drain-=5)
		sleep(2)
		user.heal_organ_damage(5, 0)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			for(var/obj/item/organ/I in H.internal_organs)
				if(I.damage > 0)
					I.damage = max(I.damage - 5, 0)		//Heals 5 damage per organ per use
				if(I.damage <= 5 && I.organ_tag == O_EYES)
					H.sdisabilities &= ~BLIND
			for(var/obj/item/organ/E in H.bad_external_organs)
				var/obj/item/organ/external/affected = E
				if((affected.damage < affected.min_broken_damage * CONFIG_GET(number/organ_health_multiplier)) && (affected.status & ORGAN_BROKEN))
					affected.status &= ~ORGAN_BROKEN
				for(var/datum/wound/W in affected.wounds)
					if(istype(W, /datum/wound/internal_bleeding))
						affected.wounds -= W
						affected.update_damages()
	return






/////////////////////////////////////////SEVENTH RUNE

/obj/effect/rune/proc/seer()
	if(usr.loc==src.loc)
		if(usr.seer==1)
			usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium viortia.")
			to_chat(usr, span_danger("The world beyond fades from your vision."))
			usr.see_invisible = SEE_INVISIBLE_LIVING
			usr.seer = 0
		else if(usr.see_invisible!=SEE_INVISIBLE_LIVING)
			to_chat(usr, span_warning("The world beyond flashes your eyes but disappears quickly, as if something is disrupting your vision."))
			usr.see_invisible = SEE_INVISIBLE_CULT
			usr.seer = 0
		else
			usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium vivira. Itonis al'ra matum!")
			to_chat(usr, span_warning("The world beyond opens to your eyes."))
			usr.see_invisible = SEE_INVISIBLE_CULT
			usr.seer = 1
		return
	return fizzle()

/////////////////////////////////////////EIGHTH RUNE

/obj/effect/rune/proc/raise()
	var/mob/living/carbon/human/corpse_to_raise
	var/mob/living/carbon/human/body_to_sacrifice

	var/is_sacrifice_target = 0
	for(var/mob/living/carbon/human/M in src.loc)
		if(M.stat == DEAD)
			if(cult && M.mind == cult.sacrifice_target)
				is_sacrifice_target = 1
			else
				corpse_to_raise = M
				break

	if(!corpse_to_raise)
		if(is_sacrifice_target)
			to_chat(usr, span_warning("The Geometer of blood wants this mortal for himself."))
		return fizzle()


	is_sacrifice_target = 0
	find_sacrifice:
		for(var/obj/effect/rune/R in GLOB.rune_list)
			if(R.word1==GLOB.cultwords["blood"] && R.word2==GLOB.cultwords["join"] && R.word3==GLOB.cultwords["hell"])
				for(var/mob/living/carbon/human/N in R.loc)
					if(cult && N.mind && N.mind == cult.sacrifice_target)
						is_sacrifice_target = 1
					else
						if(N.stat!= DEAD)
							body_to_sacrifice = N
							break find_sacrifice

	if(!body_to_sacrifice)
		if (is_sacrifice_target)
			to_chat(usr, span_warning("The Geometer of Blood wants that corpse for himself."))
		else
			to_chat(usr, span_warning("The sacrifical corpse is not dead. You must free it from this world of illusions before it may be used."))
		return fizzle()

	if(!cult.can_become_antag(corpse_to_raise.mind) || jobban_isbanned(corpse_to_raise, JOB_CULTIST))
		to_chat(usr, span_warning("The Geometer of Blood refuses to touch this one."))
		return fizzle()
	else if(!corpse_to_raise.client && corpse_to_raise.mind) //Don't force the dead person to come back if they don't want to.
		for(var/mob/observer/dead/ghost in GLOB.player_list)
			if(ghost.mind == corpse_to_raise.mind)
				to_chat(ghost, span_interface(span_large(span_bold("The cultist [usr.real_name] is trying to \
				revive you. Return to your body if you want to be resurrected into the service of Nar'Sie!") + "\
				(Verbs -> Ghost -> Re-enter corpse)")))
				break

	sleep(10 SECONDS)

	if(corpse_to_raise.client)

		var/datum/gender/TU = GLOB.gender_datums[corpse_to_raise.get_visible_gender()]
		var/datum/gender/TT = GLOB.gender_datums[body_to_sacrifice.get_visible_gender()]

		cult.add_antagonist(corpse_to_raise.mind)
		corpse_to_raise.revive()

		usr.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
		corpse_to_raise.visible_message(span_warning("[corpse_to_raise]'s eyes glow with a faint red as [TU.he] stand[TU.s] up, slowly starting to breathe again."), \
		span_warning("Life... I'm alive again..."), \
		span_warning("You hear a faint, slightly familiar whisper."))
		body_to_sacrifice.visible_message(span_danger("[body_to_sacrifice] is torn apart, a black smoke swiftly dissipating from [TT.his] remains!"), \
		span_danger("You feel as your blood boils, tearing you apart."), \
		span_danger("You hear a thousand voices, all crying in pain."))
		body_to_sacrifice.gib()

		to_chat(corpse_to_raise, span_cult("Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root."))
		to_chat(corpse_to_raise, span_cult("Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back."))

	return





/////////////////////////////////////////NINETH RUNE

/obj/effect/rune/proc/obscure(var/rad)
	var/S=0
	for(var/obj/effect/rune/R in orange(rad,src))
		if(R!=src)
			R.invisibility=INVISIBILITY_OBSERVER
		S=1
	if(S)
		if(istype(src,/obj/effect/rune))
			usr.say("Kla[pick("'","`")]atu barada nikt'o!")
			for (var/mob/V in viewers(src))
				V.show_message(span_warning("The rune turns into gray dust, veiling the surrounding runes."), 3)
			qdel(src)
		else
			usr.whisper("Kla[pick("'","`")]atu barada nikt'o!")
			to_chat(usr, span_warning("Your talisman turns into gray dust, veiling the surrounding runes."))
			for (var/mob/V in orange(1,src))
				if(V!=usr)
					V.show_message(span_warning("Dust emanates from [usr]'s hands for a moment."), 3)

		return
	if(istype(src,/obj/effect/rune))
		return	fizzle()
	else
		call(/obj/effect/rune/proc/fizzle)()
		return

/////////////////////////////////////////TENTH RUNE

/obj/effect/rune/proc/ajourney() //some bits copypastaed from admin tools - Urist
	if(usr.loc==src.loc)
		var/mob/living/carbon/human/L = usr
		var/datum/gender/TU = GLOB.gender_datums[L.get_visible_gender()]
		usr.say("Fwe[pick("'","`")]sh mah erl nyag r'ya!")
		usr.visible_message(span_warning("[usr]'s eyes glow blue as [TU.he] freeze[TU.s] in place, absolutely motionless."), \
		span_warning("The shadow that is your spirit separates itself from your body. You are now in the realm beyond. While this is a great sight, being here strains your mind and body. Hurry..."), \
		span_warning("You hear only complete silence for a moment."))
		announce_ghost_joinleave(usr.ghostize(1), 1, "You feel that they had to use some [pick("dark", "black", "blood", "forgotten", "forbidden")] magic to [pick("invade","disturb","disrupt","infest","taint","spoil","blight")] this place!")
		L.ajourn = 1
		while(L)
			if(L.key)
				L.ajourn=0
				return
			else
				L.take_organ_damage(3, 0)
			sleep(100)
	return fizzle()




/////////////////////////////////////////ELEVENTH RUNE

/obj/effect/rune/proc/manifest()
	var/obj/effect/rune/this_rune = src
	src = null
	if(usr.loc!=this_rune.loc)
		return this_rune.fizzle()
	var/mob/observer/dead/ghost
	for(var/mob/observer/dead/O in this_rune.loc)
		if(!O.client)	continue
		if(!O.MayRespawn()) continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
		if(!(O.client.prefs.be_special & BE_CULTIST)) continue
		ghost = O
		break
	if(!ghost)
		return this_rune.fizzle()
	if(jobban_isbanned(ghost, JOB_CULTIST))
		return this_rune.fizzle()

	usr.say("Gal'h'rfikk harfrandid mud[pick("'","`")]gib!")
	var/mob/living/carbon/human/dummy/D = new(this_rune.loc)
	usr.visible_message(span_warning("A shape forms in the center of the rune. A shape of... a man."), \
	span_warning("A shape forms in the center of the rune. A shape of... a man."), \
	span_warning("You hear liquid flowing."))
	D.real_name = "Unknown"
	var/chose_name = 0
	for(var/obj/item/paper/P in this_rune.loc)
		if(P.info)
			D.real_name = copytext(P.info, findtext(P.info,">")+1, findtext(P.info,"<",2) )
			chose_name = 1
			break
	D.universal_speak = 1
	D.RemoveElement(/datum/element/godmode)
	D.b_eyes = 200
	D.r_eyes = 200
	D.g_eyes = 200
	D.update_eyes()
	D.all_underwear.Cut()
	D.key = ghost.key
	cult.add_antagonist(D.mind)

	if(!chose_name)
		D.real_name = pick("Anguished", "Blasphemous", "Corrupt", "Cruel", "Depraved", "Despicable", "Disturbed", "Exacerbated", "Foul", "Hateful", "Inexorable", "Implacable", "Impure", "Malevolent", "Malignant", "Malicious", "Pained", "Profane", "Profligate", "Relentless", "Resentful", "Restless", "Spiteful", "Tormented", "Unclean", "Unforgiving", "Vengeful", "Vindictive", "Wicked", "Wronged")
		D.real_name += " "
		D.real_name += pick("Apparition", "Aptrgangr", "Dis", "Draugr", "Dybbuk", "Eidolon", "Fetch", "Fylgja", "Ghast", "Ghost", "Gjenganger", "Haint", "Phantom", "Phantasm", "Poltergeist", "Revenant", "Shade", "Shadow", "Soul", "Spectre", "Spirit", "Spook", "Visitant", "Wraith")

	log_and_message_admins("used a manifest rune.")
	var/mob/living/user = usr
	while(this_rune && user && user.stat==CONSCIOUS && user.client && user.loc==this_rune.loc)
		user.take_organ_damage(1, 0)
		sleep(30)
	if(D)
		D.visible_message(span_danger("[D] slowly dissipates into dust and bones."), \
		span_danger("You feel pain, as bonds formed between your soul and this homunculus break."), \
		span_warning("You hear faint rustle."))
		D.dust()
	return





/////////////////////////////////////////TWELFTH RUNE

/obj/effect/rune/proc/talisman()//only hide, emp, teleport, deafen, blind and tome runes can be imbued atm
	var/obj/item/paper/newtalisman
	var/unsuitable_newtalisman = 0
	for(var/obj/item/paper/P in src.loc)
		if(!P.info)
			newtalisman = P
			break
		else
			unsuitable_newtalisman = 1
	if (!newtalisman)
		if (unsuitable_newtalisman)
			to_chat(usr, span_warning("The blank is tainted. It is unsuitable."))
		return fizzle()

	var/obj/effect/rune/imbued_from
	var/obj/item/paper/talisman/T
	for(var/obj/effect/rune/R in orange(1,src))
		if(R==src)
			continue
		if(R.word1==GLOB.cultwords["travel"] && R.word2==GLOB.cultwords["self"])  //teleport
			T = new(src.loc)
			T.imbue = "[R.word3]"
			T.info = "[R.word3]"
			imbued_from = R
			break
		if(R.word1==GLOB.cultwords["see"] && R.word2==GLOB.cultwords["blood"] && R.word3==GLOB.cultwords["hell"]) //tome
			T = new(src.loc)
			T.imbue = "newtome"
			imbued_from = R
			break
		if(R.word1==GLOB.cultwords["destroy"] && R.word2==GLOB.cultwords["see"] && R.word3==GLOB.cultwords["technology"]) //emp
			T = new(src.loc)
			T.imbue = "emp"
			imbued_from = R
			break
		if(R.word1==GLOB.cultwords["blood"] && R.word2==GLOB.cultwords["see"] && R.word3==GLOB.cultwords["destroy"]) //conceal
			T = new(src.loc)
			T.imbue = "conceal"
			imbued_from = R
			break
		if(R.word1==GLOB.cultwords["hell"] && R.word2==GLOB.cultwords["destroy"] && R.word3==GLOB.cultwords["other"]) //armor
			T = new(src.loc)
			T.imbue = "armor"
			imbued_from = R
			break
		if(R.word1==GLOB.cultwords["blood"] && R.word2==GLOB.cultwords["see"] && R.word3==GLOB.cultwords["hide"]) //reveal
			T = new(src.loc)
			T.imbue = "revealrunes"
			imbued_from = R
			break
		if(R.word1==GLOB.cultwords["hide"] && R.word2==GLOB.cultwords["other"] && R.word3==GLOB.cultwords["see"]) //deafen
			T = new(src.loc)
			T.imbue = "deafen"
			imbued_from = R
			break
		if(R.word1==GLOB.cultwords["destroy"] && R.word2==GLOB.cultwords["see"] && R.word3==GLOB.cultwords["other"]) //blind
			T = new(src.loc)
			T.imbue = "blind"
			imbued_from = R
			break
		if(R.word1==GLOB.cultwords["self"] && R.word2==GLOB.cultwords["other"] && R.word3==GLOB.cultwords["technology"]) //communicat
			T = new(src.loc)
			T.imbue = "communicate"
			imbued_from = R
			break
		if(R.word1==GLOB.cultwords["join"] && R.word2==GLOB.cultwords["hide"] && R.word3==GLOB.cultwords["technology"]) //communicat
			T = new(src.loc)
			T.imbue = "runestun"
			imbued_from = R
			break
	if (imbued_from)
		for (var/mob/V in viewers(src))
			V.show_message(span_warning("The runes turn into dust, which then forms into an arcane image on the paper."), 3)
		usr.say("H'drak v[pick("'","`")]loso, mir'kanas verbot!")
		qdel(imbued_from)
		qdel(newtalisman)
	else
		return fizzle()

/////////////////////////////////////////THIRTEENTH RUNE

/obj/effect/rune/proc/mend()
	var/mob/living/user = usr
	var/datum/gender/TU = GLOB.gender_datums[usr.get_visible_gender()]
	src = null
	user.say("Uhrast ka'hfa heldsagen ver[pick("'","`")]lot!")
	user.take_overall_damage(200, 0)
	GLOB.runedec+=10
	user.visible_message(span_danger("\The [user] keels over dead, [TU.his] blood glowing blue as it escapes [TU.his] body and dissipates into thin air."), \
	span_danger("In the last moment of your humble life, you feel an immense pain as fabric of reality mends... with your blood."), \
	span_warning("You hear faint rustle."))
	for(,user.stat==2)
		sleep(600)
		if (!user)
			return
	GLOB.runedec-=10
	return


/////////////////////////////////////////FOURTEETH RUNE

// returns 0 if the rune is not used. returns 1 if the rune is used.
/obj/effect/rune/proc/communicate()
	. = 1 // Default output is 1. If the rune is deleted it will return 1
	var/input = tgui_input_text(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")//sanitize() below, say() and whisper() have their own
	if(!input)
		if (istype(src))
			fizzle()
			return 0
		else
			return 0

	if(istype(src,/obj/effect/rune))
		usr.say("O bidai nabora se[pick("'","`")]sma!")
	else
		usr.whisper("O bidai nabora se[pick("'","`")]sma!")

	input = sanitize(input)
	log_and_message_admins("used a communicate rune to say '[input]'")
	for(var/datum/mind/H in cult.current_antagonists)
		if (H.current)
			to_chat(H.current, span_cult("[input]"))
	for(var/mob/observer/dead/O in GLOB.player_list)
		to_chat(O, span_cult("[input]"))
	qdel(src)
	return 1

/////////////////////////////////////////FIFTEENTH RUNE

/obj/effect/rune/proc/sacrifice()
	var/list/mob/living/carbon/human/cultsinrange = list()
	var/list/mob/living/carbon/human/victims = list()
	for(var/mob/living/carbon/human/V in src.loc)//Checks for non-cultist humans to sacrifice
		if(ishuman(V))
			if(!(iscultist(V)))
				victims += V//Checks for cult status and mob type
	for(var/obj/item/I in src.loc)//Checks for MMIs/brains/Intellicards
		if(istype(I,/obj/item/organ/internal/brain))
			var/obj/item/organ/internal/brain/B = I
			victims += B.brainmob
		else if(istype(I,/obj/item/mmi))
			var/obj/item/mmi/B = I
			victims += B.brainmob
		else if(istype(I,/obj/item/aicard))
			for(var/mob/living/silicon/ai/A in I)
				victims += A
	for(var/mob/living/carbon/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			cultsinrange += C
			C.say("Barhah hra zar[pick("'","`")]garis!")

	for(var/mob/H in victims)

		var/worth = 0
		if(ishuman(H))
			var/mob/living/carbon/human/lamb = H
			if(lamb.species.rarity_value > 3)
				worth = 1

		if (ticker.mode.name == "cult")
			if(H.mind == cult.sacrifice_target)
				if(cultsinrange.len >= 3)
					sacrificed += H.mind
					if(isrobot(H))
						H.dust()//To prevent the MMI from remaining
					else
						H.gib()
					to_chat(usr, span_cult("The Geometer of Blood accepts this sacrifice, your objective is now complete."))
				else
					to_chat(usr, span_warning("Your target's earthly bonds are too strong. You need more cultists to succeed in this ritual."))
			else
				if(cultsinrange.len >= 3)
					if(H.stat !=2)
						if(prob(80) || worth)
							to_chat(usr, span_cult("The Geometer of Blood accepts this [worth ? "exotic " : ""]sacrifice."))
							cult.grant_runeword(usr)
						else
							to_chat(usr, span_cult("The Geometer of Blood accepts this sacrifice."))
							to_chat(usr, span_warning("However, this soul was not enough to gain His favor."))
						if(isrobot(H))
							H.dust()//To prevent the MMI from remaining
						else
							H.gib()
					else
						if(prob(40) || worth)
							to_chat(usr, span_cult("The Geometer of Blood accepts this [worth ? "exotic " : ""]sacrifice."))
							cult.grant_runeword(usr)
						else
							to_chat(usr, span_cult("The Geometer of Blood accepts this sacrifice."))
							to_chat(usr, span_warning("However, a mere dead body is not enough to satisfy Him."))
						if(isrobot(H))
							H.dust()//To prevent the MMI from remaining
						else
							H.gib()
				else
					if(H.stat !=2)
						to_chat(usr, span_warning("The victim is still alive, you will need more cultists chanting for the sacrifice to succeed."))
					else
						if(prob(40))

							to_chat(usr, span_cult("The Geometer of Blood accepts this sacrifice."))
							cult.grant_runeword(usr)
						else
							to_chat(usr, span_cult("The Geometer of Blood accepts this sacrifice."))
							to_chat(usr, span_warning("However, a mere dead body is not enough to satisfy Him."))
						if(isrobot(H))
							H.dust()//To prevent the MMI from remaining
						else
							H.gib()
		else
			if(cultsinrange.len >= 3)
				if(H.stat !=2)
					if(prob(80))
						to_chat(usr, span_cult("The Geometer of Blood accepts this sacrifice."))
						cult.grant_runeword(usr)
					else
						to_chat(usr, span_cult("The Geometer of Blood accepts this sacrifice."))
						to_chat(usr, span_warning("However, this soul was not enough to gain His favor."))
					if(isrobot(H))
						H.dust()//To prevent the MMI from remaining
					else
						H.gib()
				else
					if(prob(40))
						to_chat(usr, span_cult("The Geometer of Blood accepts this sacrifice."))
						cult.grant_runeword(usr)
					else
						to_chat(usr, span_cult("The Geometer of Blood accepts this sacrifice."))
						to_chat(usr, span_warning("However, a mere dead body is not enough to satisfy Him."))
					if(isrobot(H))
						H.dust()//To prevent the MMI from remaining
					else
						H.gib()
			else
				if(H.stat !=2)
					to_chat(usr, span_warning("The victim is still alive, you will need more cultists chanting for the sacrifice to succeed."))
				else
					if(prob(40))
						to_chat(usr, span_cult("The Geometer of Blood accepts this sacrifice."))
						cult.grant_runeword(usr)
					else
						to_chat(usr, span_cult("The Geometer of Blood accepts this sacrifice."))
						to_chat(usr, span_warning("However, a mere dead body is not enough to satisfy Him."))
					if(isrobot(H))
						H.dust()//To prevent the MMI from remaining
					else
						H.gib()

/////////////////////////////////////////SIXTEENTH RUNE

/obj/effect/rune/proc/revealrunes(var/obj/W as obj)
	var/go=0
	var/rad
	var/S=0
	if(istype(W,/obj/effect/rune))
		rad = 6
		go = 1
	if (istype(W,/obj/item/paper/talisman))
		rad = 4
		go = 1
	if (istype(W,/obj/item/nullrod))
		rad = 1
		go = 1
	if(go)
		for(var/obj/effect/rune/R in orange(rad,src))
			if(R!=src)
				R:visibility=15
			S=1
	if(S)
		if(istype(W,/obj/item/nullrod))
			to_chat(usr, span_warning("Arcane markings suddenly glow from underneath a thin layer of dust!"))
			return
		if(istype(W,/obj/effect/rune))
			usr.say("Nikt[pick("'","`")]o barada kla'atu!")
			for (var/mob/V in viewers(src))
				V.show_message(span_warning("The rune turns into red dust, reveaing the surrounding runes."), 3)
			qdel(src)
			return
		if(istype(W,/obj/item/paper/talisman))
			usr.whisper("Nikt[pick("'","`")]o barada kla'atu!")
			to_chat(usr, span_warning("Your talisman turns into red dust, revealing the surrounding runes."))
			for (var/mob/V in orange(1,usr.loc))
				if(V!=usr)
					V.show_message(span_warning("Red dust emanates from [usr]'s hands for a moment."), 3)
			return
		return
	if(istype(W,/obj/effect/rune))
		return	fizzle()
	if(istype(W,/obj/item/paper/talisman))
		call(/obj/effect/rune/proc/fizzle)()
		return

/////////////////////////////////////////SEVENTEENTH RUNE

/obj/effect/rune/proc/wall()
	usr.say("Khari[pick("'","`")]d! Eske'te tannin!")
	src.density = !src.density
	var/mob/living/user = usr
	user.take_organ_damage(2, 0)
	if(src.density)
		to_chat(usr, span_danger("Your blood flows into the rune, and you feel that the very space over the rune thickens."))
	else
		to_chat(usr, span_danger("Your blood flows into the rune, and you feel as the rune releases its grasp on space."))
	return

/////////////////////////////////////////EIGHTTEENTH RUNE

/obj/effect/rune/proc/freedom()
	var/mob/living/user = usr
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in cult.current_antagonists)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/carbon/users = new
	for(var/mob/living/carbon/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			users+=C
	var/dam = round(15 / users.len)
	if(users.len>=3)
		var/mob/living/carbon/cultist = tgui_input_list(user, "Choose the one who you want to free", "Followers of Geometer", (cultists - users))
		if(!cultist)
			return fizzle()
		if (cultist == user) //just to be sure.
			return
		if(!(cultist.buckled || \
			cultist.handcuffed || \
			istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle) || \
			(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded) || \
			(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked) || \
			(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked) \
		))
			to_chat(user, span_warning("The [cultist] is already free."))
			return
		cultist.buckled = null
		if (cultist.handcuffed)
			cultist.drop_from_inventory(cultist.handcuffed)
		if (cultist.legcuffed)
			cultist.drop_from_inventory(cultist.legcuffed)
		if (istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle))
			cultist.drop_from_inventory(cultist.wear_mask)
		if(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded)
			cultist.loc:welded = 0
		if(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked)
			cultist.loc:locked = 0
		if(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked)
			cultist.loc:locked = 0
		for(var/mob/living/carbon/C in users)
			user.take_overall_damage(dam, 0)
			C.say("Khari[pick("'","`")]d! Gual'te nikka!")
		qdel(src)
	return fizzle()

/////////////////////////////////////////NINETEENTH RUNE

/obj/effect/rune/proc/cultsummon()
	var/mob/living/user = usr
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in cult.current_antagonists)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/carbon/users = new
	for(var/mob/living/carbon/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			users += C
	if(users.len>=3)
		var/mob/living/carbon/cultist = tgui_input_list(user, "Choose the one who you want to summon", "Followers of Geometer", (cultists - user))
		if(!cultist)
			return fizzle()
		if (cultist == user) //just to be sure.
			return
		if(cultist.buckled || cultist.handcuffed || (!isturf(cultist.loc) && !istype(cultist.loc, /obj/structure/closet)))
			var/datum/gender/TU = GLOB.gender_datums[cultist.get_visible_gender()]
			to_chat(user, span_warning("You cannot summon \the [cultist], for [TU.his] shackles of blood are strong."))
			return fizzle()
		cultist.forceMove(src.loc)
		cultist.lying = 1
		cultist.regenerate_icons()

		var/dam = round(25 / (users.len/2))	//More people around the rune less damage everyone takes. Minimum is 3 cultists

		for(var/mob/living/carbon/human/C in users)
			if(iscultist(C) && !C.stat)
				C.say("N'ath reth sh'yro eth d[pick("'","`")]rekkathnor!")
				C.take_overall_damage(dam, 0)
				if(users.len <= 4)				// You did the minimum, this is going to hurt more and we're going to stun you.
					C.apply_effect(rand(3,6), STUN)
					C.apply_effect(1, WEAKEN)
		user.visible_message(span_warning("Rune disappears with a flash of red light, and in its place now a body lies."), \
		span_warning("You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a body."), \
		span_warning("You hear a pop and smell ozone."))
		qdel(src)
	return fizzle()

/////////////////////////////////////////TWENTIETH RUNES

/obj/effect/rune/proc/deafen()
	if(istype(src,/obj/effect/rune))
		var/list/affected = new()
		for(var/mob/living/carbon/C in range(7,src))
			if (iscultist(C))
				continue
			var/obj/item/nullrod/N = locate() in C
			if(N)
				continue
			C.ear_deaf += 50
			C.deaf_loop.start(skip_start_sound = TRUE) // CHOMPStation Add: Ear Ringing/Deafness
			C.show_message(span_warning("The world around you suddenly becomes quiet."), 3)
			affected += C
			if(prob(1))
				C.sdisabilities |= DEAF
		if(affected.len)
			usr.say("Sti[pick("'","`")] kaliedir!")
			to_chat(usr, span_warning("The world becomes quiet as the deafening rune dissipates into fine dust."))
			add_attack_logs(usr,affected,"Deafen rune")
			qdel(src)
		else
			return fizzle()
	else
		var/list/affected = new()
		for(var/mob/living/carbon/C in range(7,usr))
			if (iscultist(C))
				continue
			var/obj/item/nullrod/N = locate() in C
			if(N)
				continue
			C.ear_deaf += 30
			C.deaf_loop.start(skip_start_sound = TRUE) // CHOMPStation Add: Ear Ringing/Deafness
			//talismans is weaker.
			C.show_message(span_warning("The world around you suddenly becomes quiet."), 3)
			affected += C
		if(affected.len)
			usr.whisper("Sti[pick("'","`")] kaliedir!")
			to_chat(usr, span_warning("Your talisman turns into gray dust, deafening everyone around."))
			add_attack_logs(usr, affected, "Deafen rune")
			for (var/mob/V in orange(1,src))
				if(!(iscultist(V)))
					V.show_message(span_warning("Dust flows from [usr]'s hands for a moment, and the world suddenly becomes quiet.."), 3)
	return

/obj/effect/rune/proc/blind()
	if(istype(src,/obj/effect/rune))
		var/list/affected = new()
		for(var/mob/living/carbon/C in viewers(src))
			if (iscultist(C))
				continue
			var/obj/item/nullrod/N = locate() in C
			if(N)
				continue
			C.eye_blurry += 50
			C.Blind(20)
			if(prob(5))
				C.disabilities |= NEARSIGHTED
				if(prob(10))
					C.sdisabilities |= BLIND
			C.show_message(span_warning("Suddenly you see a red flash that blinds you."), 3)
			affected += C
		if(affected.len)
			usr.say("Sti[pick("'","`")] kaliesin!")
			to_chat(usr, span_warning("The rune flashes, blinding those who not follow the Nar-Sie, and dissipates into fine dust."))
			add_attack_logs(usr, affected, "Blindness rune")
			qdel(src)
		else
			return fizzle()
	else
		var/list/affected = new()
		for(var/mob/living/carbon/C in view(2,usr))
			if (iscultist(C))
				continue
			var/obj/item/nullrod/N = locate() in C
			if(N)
				continue
			C.eye_blurry += 30
			C.Blind(10)
			//talismans is weaker.
			affected += C
			C.show_message(span_warning("You feel a sharp pain in your eyes, and the world disappears into darkness.."), 3)
		if(affected.len)
			usr.whisper("Sti[pick("'","`")] kaliesin!")
			to_chat(usr, span_warning("Your talisman turns into gray dust, blinding those who not follow the Nar-Sie."))
			add_attack_logs(usr, affected, "Blindness rune")
	return


/obj/effect/rune/proc/bloodboil() //cultists need at least one DANGEROUS rune. Even if they're all stealthy.
/*
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
*/
	var/list/cultists = list() //also, wording for it is old wording for obscure rune, which is now hide-see-blood.
	var/list/victims = list()
//			var/list/cultboil = list(cultists-usr) //and for this words are destroy-see-blood.
	for(var/mob/living/carbon/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			cultists+=C
	if(cultists.len>=3)
		for(var/mob/living/carbon/M in viewers(usr))
			if(iscultist(M))
				continue
			var/obj/item/nullrod/N = locate() in M
			if(N)
				continue
			M.take_overall_damage(51,51)
			to_chat(M, span_danger("Your blood boils!"))
			victims += M
			if(prob(5))
				spawn(5)
					M.gib()
		for(var/obj/effect/rune/R in view(src))
			if(prob(10))
				explosion(R.loc, -1, 0, 1, 5)
		for(var/mob/living/carbon/human/C in orange(1,src))
			if(iscultist(C) && !C.stat)
				C.say("Dedo ol[pick("'","`")]btoh!")
				C.take_overall_damage(15, 0)
		add_attack_logs(usr, victims, "Blood boil rune")
		qdel(src)
	else
		return fizzle()
	return

// WIP rune, I'll wait for Rastaf0 to add limited blood.

/obj/effect/rune/proc/burningblood()
	var/culcount = 0
	for(var/mob/living/carbon/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount >= 5)
		for(var/obj/effect/rune/R in GLOB.rune_list)
			if(R.forensic_data?.get_blooddna() == src.forensic_data?.get_blooddna())
				for(var/mob/living/M in orange(2,R))
					M.take_overall_damage(0,15)
					if (R.invisibility>M.see_invisible)
						to_chat(M, span_danger("Aargh it burns!"))
					else
						to_chat(M, span_danger("Rune suddenly ignites, burning you!"))
					var/turf/T = get_turf(R)
					T.hotspot_expose(700,125)
		for(var/obj/effect/decal/cleanable/blood/B in world)
			if(B.forensic_data?.get_blooddna() == src.forensic_data?.get_blooddna())
				for(var/mob/living/M in orange(1,B))
					M.take_overall_damage(0,5)
					to_chat(M, span_danger("Blood suddenly ignites, burning you!"))
					var/turf/T = get_turf(B)
					T.hotspot_expose(700,125)
					qdel(B)
		qdel(src)

//////////             Rune 24 (counting burningblood, which kinda doesnt work yet.)

/obj/effect/rune/proc/runestun(var/mob/living/T as mob)
	if(istype(src,/obj/effect/rune))   ///When invoked as rune, flash and stun everyone around.
		usr.say("Fuu ma[pick("'","`")]jin!")
		for(var/mob/living/L in viewers(src))
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.flash_eyes()
				if(C.stuttering < 1 && (!(HULK in C.mutations)))
					C.stuttering = 1
				C.Weaken(1)
				C.Stun(1)
				C.show_message(span_danger("The rune explodes in a bright flash."), 3)
				add_attack_logs(usr,C,"Stun rune")

			else if(issilicon(L))
				var/mob/living/silicon/S = L
				S.Weaken(5)
				S.show_message(span_danger("BZZZT... The rune has exploded in a bright flash."), 3)
				add_attack_logs(usr,S,"Stun rune")
		qdel(src)
	else                        ///When invoked as talisman, stun and mute the target mob.
		usr.say("Dream sign ''Evil sealing talisman'[pick("'","`")]!")
		var/obj/item/nullrod/N = locate() in T
		if(N)
			for(var/mob/O in viewers(T, null))
				O.show_message(span_boldwarning("[usr] invokes a talisman at [T], but they are unaffected!"), 1)
		else
			for(var/mob/O in viewers(T, null))
				O.show_message(span_boldwarning("[usr] invokes a talisman at [T]"), 1)

			if(issilicon(T))
				T.Weaken(15)
				add_attack_logs(usr,T,"Stun rune")
			else if(iscarbon(T))
				var/mob/living/carbon/C = T
				C.flash_eyes()
				if (!(HULK in C.mutations))
					C.silent += 15
				C.Weaken(25)
				C.Stun(25)
				add_attack_logs(usr,C,"Stun rune")
		return

/////////////////////////////////////////TWENTY-FIFTH RUNE

/obj/effect/rune/proc/armor()
	var/mob/living/carbon/human/user = usr
	if(istype(src,/obj/effect/rune))
		usr.say("N'ath reth sh'yro eth d[pick("'","`")]raggathnor!")
	else
		usr.whisper("N'ath reth sh'yro eth d[pick("'","`")]raggathnor!")
	usr.visible_message(span_warning("The rune disappears with a flash of red light, and a set of armor appears on [usr]..."), \
	span_warning("You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor."))

	user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(user), slot_shoes)
	user.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(user), slot_back)
	//the above update their overlay icons cache but do not call update_icons()
	//the below calls update_icons() at the end, which will update overlay icons by using the (now updated) cache
	user.put_in_hands(new /obj/item/melee/cultblade(user))	//put in hands or on floor

	qdel(src)
	return
