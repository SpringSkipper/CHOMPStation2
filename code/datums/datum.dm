/**
 * The absolute base class for everything
 *
 * A datum instantiated has no physical world prescence, use an atom if you want something
 * that actually lives in the world
 *
 * Be very mindful about adding variables to this class, they are inherited by every single
 * thing in the entire game, and so you can easily cause memory usage to rise a lot with careless
 * use of variables at this level
 */
/datum
	/**
	  * Tick count time when this object was destroyed.
	  *
	  * If this is non zero then the object has been garbage collected and is awaiting either
	  * a hard del by the GC subsystme, or to be autocollected (if it has no references)
	  */
	var/gc_destroyed

	/// Open uis owned by this datum
	/// Lazy, since this case is semi rare
	var/list/open_tguis // FIXME: open_uis

	/// Active timers with this datum as the target
	var/list/_active_timers
	/// Status traits attached to this datum. associative list of the form: list(trait name (string) = list(source1, source2, source3,...))
	var/list/_status_traits

	/**
	  * Components attached to this datum
	  *
	  * Lazy associated list in the structure of `type -> component/list of components`
	  */
	var/list/_datum_components
	/**
	  * Any datum registered to receive signals from this datum is in this list
	  *
	  * Lazy associated list in the structure of `signal -> registree/list of registrees`
	  */
	var/list/_listen_lookup
	/// Lazy associated list in the structure of `target -> list(signal -> proctype)` that are run when the datum receives that signal
	var/list/list/_signal_procs

	/// Datum level flags
	var/datum_flags = NONE
	var/trigger_uid
	var/status_traits

	/// A weak reference to another datum
	var/datum/weakref/weak_reference

	/*
	* Lazy associative list of currently active cooldowns.
	*
	* cooldowns [ COOLDOWN_INDEX ] = add_timer()
	* add_timer() returns the truthy value of -1 when not stoppable, and else a truthy numeric index
	*/
	var/list/cooldowns

#ifdef REFERENCE_TRACKING
	var/tmp/running_find_references
	var/tmp/last_find_references = 0
	var/tmp/find_references_on_destroy = FALSE //set this to true on an item to have it find refs after
	#ifdef REFERENCE_TRACKING_DEBUG
	///Stores info about where refs are found, used for sanity checks and testing
	var/list/found_refs
	#endif
#endif

	// If we have called dump_harddel_info already. Used to avoid duped calls (since we call it immediately in some cases on failure to process)
	// Create and destroy is weird and I wanna cover my bases
	var/harddel_deets_dumped = FALSE

/**
 * Default implementation of clean-up code.
 *
 * This should be overridden to remove all references pointing to the object being destroyed, if
 * you do override it, make sure to call the parent and return its return value by default
 *
 * Return an appropriate [QDEL_HINT][QDEL_HINT_QUEUE] to modify handling of your deletion;
 * in most cases this is [QDEL_HINT_QUEUE].
 *
 * The base case is responsible for doing the following
 * * Erasing timers pointing to this datum
 * * Erasing compenents on this datum
 * * Notifying datums listening to signals from this datum that we are going away
 *
 * Returns [QDEL_HINT_QUEUE]
 */
/datum/proc/Destroy(force=FALSE)
	SHOULD_CALL_PARENT(TRUE)
	//SHOULD_NOT_SLEEP(TRUE)
	tag = null
	weak_reference = null //ensure prompt GCing of weakref.

	//clear timers
	if(_active_timers)
		var/list/timers = _active_timers
		_active_timers = null
		for(var/datum/timedevent/timer as anything in timers)
			if (timer.spent && !(timer.flags & TIMER_DELETE_ME))
				continue
			qdel(timer)

	#ifdef REFERENCE_TRACKING
	#ifdef REFERENCE_TRACKING_DEBUG
	found_refs = null
	#endif
	#endif

	//BEGIN: ECS SHIT
	var/list/dc = _datum_components
	if(dc)
		for(var/component_key in dc)
			var/component_or_list = dc[component_key]
			if(islist(component_or_list))
				for(var/datum/component/component as anything in component_or_list)
					qdel(component, FALSE)
			else
				var/datum/component/C = component_or_list
				qdel(C, FALSE)
		dc.Cut()

	_clear_signal_refs()
	//END: ECS SHIT

	SStgui.close_uis(src)

	SEND_SIGNAL(src,COMSIG_OBSERVER_DESTROYED)

	#ifdef REFERENCE_TRACKING
	if(find_references_on_destroy)
		return QDEL_HINT_FINDREFERENCE
	if(SSgarbage.find_reference_on_fail_global_toggle)
		return QDEL_HINT_IFFAIL_FINDREFERENCE
	#endif

	return QDEL_HINT_QUEUE

///Only override this if you know what you're doing. You do not know what you're doing
///This is a threat
/datum/proc/_clear_signal_refs()
	var/list/lookup = _listen_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for(var/datum/component/comp as anything in comps)
					comp.UnregisterSignal(src, sig)
			else
				var/datum/component/comp = comps
				comp.UnregisterSignal(src, sig)
		_listen_lookup = lookup = null

	for(var/target in _signal_procs)
		UnregisterSignal(target, _signal_procs[target])

/**
 * Callback called by a timer to end an associative-list-indexed cooldown.
 *
 * Arguments:
 * * source - datum storing the cooldown
 * * index - string index storing the cooldown on the cooldowns associative list
 *
 * This sends a signal reporting the cooldown end.
 */
/proc/end_cooldown(datum/source, index)
	if(QDELETED(source))
		return
	SEND_SIGNAL(source, COMSIG_CD_STOP(index))
	TIMER_COOLDOWN_END(source, index)

/**
 * Proc used by stoppable timers to end a cooldown before the time has ran out.
 *
 * Arguments:
 * * source - datum storing the cooldown
 * * index - string index storing the cooldown on the cooldowns associative list
 *
 * This sends a signal reporting the cooldown end, passing the time left as an argument.
 */
/proc/reset_cooldown(datum/source, index)
	if(QDELETED(source))
		return
	SEND_SIGNAL(source, COMSIG_CD_RESET(index), S_TIMER_COOLDOWN_TIMELEFT(source, index))
	TIMER_COOLDOWN_END(source, index)

/// Return text from this proc to provide extra context to hard deletes that happen to it
/// Optional, you should use this for cases where replication is difficult and extra context is required
/// Can be called more then once per object, use harddel_deets_dumped to avoid duplicate calls (I am so sorry)
/datum/proc/dump_harddel_info()
	return

///images are pretty generic, this should help a bit with tracking harddels related to them
/image/dump_harddel_info()
	if(harddel_deets_dumped)
		return
	harddel_deets_dumped = TRUE
	return "Image icon: [icon] - icon_state: [icon_state] [loc ? "loc: [loc] ([loc.x],[loc.y],[loc.z])" : ""]"
