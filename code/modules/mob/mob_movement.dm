/mob/proc/setMoveCooldown(var/timeout)
	next_move = max(world.time + timeout, next_move)

/mob/proc/checkMoveCooldown()
	if(world.time < next_move)
		return FALSE // Need to wait more.
	return TRUE

/mob/proc/movement_delay(oldloc, direct)
	. = 0
	if(locate(/obj/item/grab) in src)
		. += 5

	if(lying)
		if(weakened >= 1)
			. += 14			// Very slow when weakened.
		else
			. += 8

	// Movespeed delay based on movement mode
	switch(m_intent)
		if(I_RUN)
			if(drowsyness > 0)
				. += 6
			. += CONFIG_GET(number/run_speed)
		if(I_WALK)
			. += CONFIG_GET(number/walk_speed)

/client/proc/client_dir(input, direction=-1)
	return turn(input, direction*dir2angle(dir))

/client/Northeast()
	diagonal_action(NORTHEAST)
/client/Northwest()
	diagonal_action(NORTHWEST)
/client/Southeast()
	diagonal_action(SOUTHEAST)
/client/Southwest()
	diagonal_action(SOUTHWEST)

/client/proc/diagonal_action(direction)
	switch(client_dir(direction, 1))
		if(NORTHEAST)
			swap_hand()
			return
		if(SOUTHEAST)
			attack_self()
			return
		if(SOUTHWEST)
			if(isliving(usr))
				var/mob/living/carbon/C = usr
				C.toggle_throw_mode()
			else
				to_chat(usr, span_red("This mob type cannot throw items."))
			return
		if(NORTHWEST)
			if(isliving(usr))
				var/mob/living/carbon/C = usr
				if(!C.get_active_hand())
					if(C.pulling)
						C.stop_pulling()
						return
					to_chat(usr, span_red("You have nothing to drop in your hand."))
					return
				drop_item()
			else
				to_chat(usr, span_red("This mob type cannot drop items."))
			return

//This gets called when you press the delete button.
/client/verb/delete_key_pressed()
	set hidden = 1

	if(!usr.pulling)
		to_chat(usr, span_blue("You are not pulling anything."))
		return
	usr.stop_pulling()

/client/verb/swap_hand()
	set hidden = 1
	if(isliving(mob))
		var/mob/living/L = mob
		L.swap_hand()
	if(istype(mob,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = mob
		R.cycle_modules()
	return



/client/verb/attack_self()
	set hidden = 1
	if(mob)
		mob.mode()
	return


/client/verb/toggle_throw_mode()
	set hidden = 1
	if(!istype(mob, /mob/living/carbon))
		return
	if (!mob.stat && isturf(mob.loc) && !mob.restrained())
		mob:toggle_throw_mode()
	else
		return


/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob) && mob.stat == CONSCIOUS && (isturf(mob.loc) || isbelly(mob.loc)))	// VOREStation Edit: dropping in bellies
		return mob.drop_item()
	return


/client/Center()
	/* No 3D movement in 2D spessman game. dir 16 is Z Up
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	*/
	return

/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)	return
			mob.control_object.dir = direct
		else
			mob.control_object.forceMove(get_step(mob.control_object,direct))
	return

// NB: This is called for 'self movement', not for being pulled or things like that, which COULD be the case for /mob/Move
// But to be honest, A LOT OF THIS CODE should be in /mob/Move
/client/Move(n, direct)
	// Prevents a double-datum lookup each time this is referenced
	// May seem dumb, but it's faster to look up a var on my_mob than dereferencing mob on client, then dereferencing the var on that mob
	// Having it in a var here means it's more available to look up things on. It won't speed up that second dereference, though.
	var/mob/my_mob = mob

	// Nothing to do in nullspace
	if(!my_mob.loc)
		return

	// Used many times below, faster reference.
	var/atom/loc = my_mob.loc

	// We're controlling an object which is when admins possess an object.
	if(my_mob.control_object)
		Move_object(direct)

	// Ghosty mob movement
	if(my_mob.is_incorporeal())
		if(isobserver(my_mob)) //We're an observer! Don't worry about any more checks. Be free!
			Process_Incorpmove(direct)
			DEBUG_INPUT("--------")
			next_move_dir_add = 0	// This one I *think* exists so you can tap move and it will move even if delay isn't quite up.
			next_move_dir_sub = 0 	// I'm not really sure why next_move_dir_sub even exists.
			return
		else //We are anything BUT an observer.
			if(!my_mob.canmove)//If you want to be very restrictive, add my_mob.restrained() and it'll stop people cuffed/straight jacketed. For now, that's too restrictive for a bugfix PR.
				return
			else //Proceed like normal.
				Process_Incorpmove(direct)
				DEBUG_INPUT("--------")
				next_move_dir_add = 0
				next_move_dir_sub = 0
				return

	// We're in the middle of another move we've already decided to do
	if(moving)
		log_debug("Client [src] attempted to move while moving=[moving]")
		return 0

	// We're still cooling down from the last move
	if(!my_mob.checkMoveCooldown())
		DEBUG_INPUT("--------")
		return
	next_move_dir_add = 0	// This one I *think* exists so you can tap move and it will move even if delay isn't quite up.
	next_move_dir_sub = 0 	// I'm not really sure why next_move_dir_sub even exists.

	if(!n || !direct)
		return

	// If dead and we try to move in our mob, it leaves our body
	if(my_mob.stat == DEAD && isliving(my_mob) && !my_mob.forbid_seeing_deadchat)
		my_mob.setMoveCooldown(my_mob.movement_delay(n, direct))
		my_mob.ghostize()
		return

	// If we have an eyeobj, it moves instead
	if(my_mob.eyeobj)
		return my_mob.EyeMove(n,direct)

	// This is sota the goto stop mobs from moving var (for some reason)
	if(my_mob.transforming)
		return

	if(isliving(my_mob))
		var/mob/living/L = my_mob
		if(L.is_incorporeal())//Move though walls
			Process_Incorpmove(direct)
			return
		/* TODO observer unzoom
		if(view != world.view) // If mob moves while zoomed in with device, unzoom them.
			for(var/obj/item/item in mob.contents)
				if(item.zoom)
					item.zoom()
					break
		*/

	if(Process_Grab())
		return

	// Can't move
	if(!my_mob.canmove)
		return

	// Relaymove could handle it
	if(my_mob.machine)
		var/result = my_mob.machine.relaymove(my_mob, direct)
		if(result)
			return result

	// Can't control ourselves when drifting
	if((isspace(loc) || my_mob.lastarea?.get_gravity() == 0) && isturf(loc))
		if(!my_mob.Process_Spacemove(0))
			return 0

	// Inside an object, tell it we moved
	if(isobj(loc) || ismob(loc))
		return loc.relaymove(my_mob, direct)

	// Can't move unless you're in the world somewhere
	if(!isturf(loc))
		return

	// Why being pulled while cuffed prevents you from moving
	if(my_mob.restrained())
		for(var/mob/M in range(my_mob, 1))
			if(M.pulling == my_mob)
				if(!M.restrained() && M.stat == 0 && M.canmove && my_mob.Adjacent(M))
					to_chat(src, span_blue("You're restrained! You can't move!"))
					return 0
				else
					M.stop_pulling()

	if(my_mob.pinned.len)
		to_chat(src, span_blue("You're pinned to a wall by [my_mob.pinned[1]]!"))
		return 0

	var/old_delay = mob.next_move

	if(istype(my_mob.buckled, /obj/vehicle) || ismob(my_mob.buckled))
		//manually set move_delay for vehicles so we don't inherit any mob movement penalties
		//specific vehicle move delays are set in code\modules\vehicles\vehicle.dm
		my_mob.next_move = world.time
		//drunk driving
		if(my_mob.confused && prob(20)) //vehicles tend to keep moving in the same direction
			direct = turn(direct, pick(90, -90))
		if(ismob(my_mob.buckled))
			var/mob/M = my_mob.buckled
			if(M.next_move > my_mob.next_move) // Don't let piggyback riders move their mob IN ADDITION TO the mob moving
				return
		return my_mob.buckled.relaymove(my_mob,direct)

	var/total_delay = my_mob.movement_delay(n, direct)

	if(my_mob.pulledby || my_mob.buckled) // Wheelchair driving!
		if(isspace(loc))
			return // No wheelchair driving in space
		if(istype(my_mob.pulledby, /obj/structure/bed/chair/wheelchair))
			total_delay += 3
		else if(istype(my_mob.buckled, /obj/structure/bed/chair/wheelchair))
			if(ishuman(my_mob))
				var/mob/living/carbon/human/driver = my_mob
				var/obj/item/organ/external/l_hand = driver.get_organ(BP_L_HAND)
				var/obj/item/organ/external/r_hand = driver.get_organ(BP_R_HAND)
				if((!l_hand || l_hand.is_stump()) && (!r_hand || r_hand.is_stump()))
					return // No hands to drive your chair? Tough luck!
			//drunk wheelchair driving
			else if(my_mob.confused)
				switch(my_mob.m_intent)
					if(I_RUN)
						if(prob(50))
							direct = turn(direct, pick(90, -90))
					if(I_WALK)
						if(prob(25))
							direct = turn(direct, pick(90, -90))
			total_delay += 3

	// We are now going to move
	moving = 1
	var/pre_move_loc = loc

	// Confused direction randomization
	if(my_mob.confused)
		switch(my_mob.m_intent)
			if(I_RUN)
				if(prob(75))
					direct = turn(direct, pick(90, -90))
					n = get_step(my_mob, direct)
			if(I_WALK)
				if(prob(25))
					direct = turn(direct, pick(90, -90))
					n = get_step(my_mob, direct)


	if(istype(my_mob.pulledby, /obj/structure/bed/chair/wheelchair))
		. = my_mob.pulledby.relaymove(my_mob, direct)
	else if(istype(my_mob.buckled, /obj/structure/bed/chair/wheelchair))
		. = my_mob.buckled.relaymove(my_mob,direct)
	else
		. = my_mob.SelfMove(n, direct, total_delay)

	//CHOMPEdit Begin
	// If we ended up moving diagonally, increase delay.
	if((direct & (direct - 1)) && mob.loc == n)
		total_delay *= SQRT_2

	//total_delay = DS2NEARESTTICK(total_delay) //Rounded to the next tick in equivalent ds
	if(mob.last_move_time > (world.time - total_delay * 1.25))
		mob.next_move = DS2NEARESTTICK(old_delay + total_delay)
	else
		mob.next_move = DS2NEARESTTICK(world.time + total_delay)

	if(!isliving(my_mob))
		moving = 0
		return

	// If we have a grab
	var/list/grablist = my_mob.ret_grab()
	if(LAZYLEN(grablist))
		grablist -= my_mob // Just in case we're in a circular grab chain

		// It's just us and another person
		if(grablist.len == 1)
			var/mob/M = grablist[1]
			if(M && !my_mob.Adjacent(M)) //Oh no, we moved away
				M.Move(pre_move_loc, get_dir(M, pre_move_loc), total_delay) //Have them step towards where we were

		// It's a grab chain
		else
			for(var/mob/M in grablist)
				my_mob.other_mobs = 1
				M.other_mobs = 1 //Has something to do with people being able or unable to pass a chain of mobs

				//Ugly!
				spawn(0) //Step
					M.Move(pre_move_loc, get_dir(M, pre_move_loc), total_delay)
				spawn(1) //Unstep
					M.other_mobs = null
				spawn(1) //Unset
					my_mob.other_mobs = null

	// Update all the grabs!
	for (var/obj/item/grab/G in my_mob)
		if (G.state == GRAB_NECK)
			mob.set_dir(GLOB.reverse_dir[direct])
		G.adjust_position()
	for (var/obj/item/grab/G in my_mob.grabbed_by)
		G.adjust_position()

	// We're not in the middle of a move anymore
	moving = 0
	mob.last_move_time = world.time

/mob/proc/SelfMove(turf/n, direct, movetime)
	return Move(n, direct, movetime)


//Set your incorporeal movespeed
//Important to note: world.time is always in deciseconds. Higher tickrates mean more subdivisions of world.time (20fps = 0.5, 40fps = 0.25)
/client
	var/is_leaving_belly = FALSE
	var/incorporeal_speed = 0.5

/client/verb/set_incorporeal_speed()
	set category = "OOC.Game Settings"
	set name = "Set Incorporeal Speed"

	var/input = tgui_input_number(usr, "Set an incorporeal movement delay between 0 (fastest) and 5 (slowest)", "Incorporeal movement speed", (0.5/world.tick_lag), 5, 0)
	incorporeal_speed = input * world.tick_lag

///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	if(isbelly(mob.loc) && isobserver(mob))
		if(is_leaving_belly)
			return
		is_leaving_belly = TRUE
		if(tgui_alert(mob, "Do you want to leave your predator's belly?", "Leave belly?", list("Yes", "No")) != "Yes")
			is_leaving_belly = FALSE
			return
		is_leaving_belly = FALSE
	var/turf/mobloc = get_turf(mob)

	if(incorporeal_speed)
		var/mob/my_mob = mob
		if(!my_mob.checkMoveCooldown()) //Only bother with speed if it isn't 0
			return
		my_mob.setMoveCooldown(incorporeal_speed)

	switch(mob.incorporeal_move)
		if(1)
			var/turf/T = get_step(mob, direct)
			if(!T)
				return
			var/area/A = T.loc	//RS Port #658
			if(mob.check_holy(T))
				to_chat(mob, span_warning("You cannot get past holy grounds while you are in this plane of existence!"))
				return
			else if(!istype(mob, /mob/observer/dead) && T.blocks_nonghost_incorporeal)
				return
			//RS Port #658 Start
			if(!check_rights_for(src, R_HOLDER))
				if(isliving(mob) && A.flag_check(AREA_BLOCK_PHASE_SHIFT))
					to_chat(mob, span_warning("Something blocks you from entering this location while phased out."))
					return
				if(isobserver(mob) && A.flag_check(AREA_BLOCK_GHOSTS) && !isbelly(mob.loc))
					to_chat(mob, span_warning("Ghosts can't enter this location."))
					var/area/our_area = mobloc.loc
					if(our_area.flag_check(AREA_BLOCK_GHOSTS) && !isbelly(mob.loc))
						var/mob/observer/dead/D = mob
						D.return_to_spawn()
					return
			mob.forceMove(get_step(mob, direct))
			mob.dir = direct
			//RS Port #658 End
		if(2)
			if(prob(50))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
				mob.forceMove(locate(locx,locy,mobloc.z))
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in getline(mobloc, mob.loc))
						spawn(0)
							anim(T,mob,'icons/mob/mob.dmi',,"shadow",,mob.dir)
						limit--
						if(limit<=0)	break
			else
				spawn(0)
					anim(mobloc,mob,'icons/mob/mob.dmi',,"shadow",,mob.dir)
				mob.forceMove(get_step(mob, direct))
			mob.dir = direct

	mob.Post_Incorpmove()
	return 1

/mob/proc/Post_Incorpmove()
	return

/mob/proc/get_jetpack()
	return

///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/proc/Process_Spacemove(var/check_drift = 0)

	if(is_incorporeal())
		return

	if(!Check_Dense_Object()) //Nothing to push off of so end here
		update_floating(0)
		return 0

	update_floating(1)

	if(restrained()) //Check to see if we can do things
		return 0
	inertia_dir = 0
	return 1

/mob/proc/Check_Dense_Object() //checks for anything to push off in the vicinity. also handles magboots on gravity-less floors tiles

	var/dense_object = 0
	var/shoegrip

	for(var/turf/turf in oview(1,src))
		if(isspace(turf))
			continue

		if(istype(turf,/turf/simulated/floor)) // Floors don't count if they don't have gravity
			var/area/A = turf.loc
			if(istype(A) && A.get_gravity() == 0)
				if(shoegrip == null)
					shoegrip = Check_Shoegrip() //Shoegrip is only ever checked when a zero-gravity floor is encountered to reduce load
				if(!shoegrip)
					continue

		dense_object++
		break

	if(!dense_object && (locate(/obj/structure/lattice) in oview(1, src)))
		dense_object++

	if(!dense_object && (locate(/obj/structure/catwalk) in oview(1, src)))
		dense_object++


	//Lastly attempt to locate any dense objects we could push off of
	//TODO: If we implement objects drifing in space this needs to really push them
	//Due to a few issues only anchored and dense objects will now work.
	if(!dense_object)
		for(var/obj/O in oview(1, src))
			if((O) && (O.density) && (O.anchored))
				dense_object++
				break

	return dense_object

/mob/proc/Check_Shoegrip()
	return 0

/mob/proc/mob_get_gravity(turf/T)
	return get_gravity(src, T)

/mob/proc/update_gravity()
	return

#define DO_MOVE(this_dir) var/final_dir = turn(this_dir, -dir2angle(dir)); Move(get_step(mob, final_dir), final_dir);

/client/verb/moveup()
	set name = ".moveup"
	set instant = 1
	DO_MOVE(NORTH)

/client/verb/movedown()
	set name = ".movedown"
	set instant = 1
	DO_MOVE(SOUTH)

/client/verb/moveright()
	set name = ".moveright"
	set instant = 1
	DO_MOVE(EAST)

/client/verb/moveleft()
	set name = ".moveleft"
	set instant = 1
	DO_MOVE(WEST)

#undef DO_MOVE
