// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice

///from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (list/args)
#define COMSIG_GLOB_NEW_Z "!new_z"
/// called after a successful var edit somewhere in the world: (list/args)
#define COMSIG_GLOB_VAR_EDIT "!var_edit"
/// called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_EXPLOSION "!explosion"
/// mob was created somewhere : (mob)
#define COMSIG_GLOB_MOB_CREATED "!mob_created"
/// mob died somewhere : (mob , gibbed)
#define COMSIG_GLOB_MOB_DEATH "!mob_death"
/// global living say plug - use sparingly: (mob/speaker , message)
#define COMSIG_GLOB_LIVING_SAY_SPECIAL "!say_special"
/// called by datum/cinematic/play() : (datum/cinematic/new_cinematic)
#define COMSIG_GLOB_PLAY_CINEMATIC "!play_cinematic"
	#define COMPONENT_GLOB_BLOCK_CINEMATIC (1<<0)
/// ingame button pressed (/obj/machinery/button/button)
#define COMSIG_GLOB_BUTTON_PRESSED "!button_pressed"

/// signals from globally accessible objects

///from SSsun when the sun changes position : (azimuth)
#define COMSIG_SUN_MOVED "sun_moved"

//////////////////////////////////////////////////////////////////

/// Signal that gets sent when a ghost query is completed
#define COMSIG_GHOST_QUERY_COMPLETE "ghost_query_complete"

// /atom signals
///from base of atom/proc/Initialize(): sent any time a new atom is created
#define COMSIG_ATOM_CREATED "atom_created"
//from SSatoms InitAtom - Only if the  atom was not deleted or failed initialization
#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE "atom_init_success"
//from SSatoms InitAtom - Only if the  atom was not deleted or failed initialization and has a loc
#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON "atom_init_success_on"

/// called post /obj/item initialize (obj/item/created_item)
#define COMSIG_GLOB_ATOM_AFTER_POST_INIT "!atom_after_post_init"

///from base of atom/attackby(): (/obj/item, /mob/living, params)
#define COMSIG_PARENT_ATTACKBY "atom_attackby"
///Return this in response if you don't want later item attack procs to be called.
	#define COMPONENT_CANCEL_ATTACK_CHAIN (1<<0)
///from base of atom/attack_hulk(): (/mob/living/carbon/human)
#define COMSIG_ATOM_HULK_ATTACK "hulk_attack"
///from base of atom/animal_attack(): (/mob/user)
#define COMSIG_ATOM_ATTACK_ANIMAL "attack_animal"
///from base of atom/examine(): (/mob)
#define COMSIG_PARENT_EXAMINE "atom_examine"
///from base of atom/get_examine_name(): (/mob, list/overrides)
#define COMSIG_ATOM_GET_EXAMINE_NAME "atom_examine_name"
	//Positions for overrides list
	#define EXAMINE_POSITION_ARTICLE (1<<0)
	#define EXAMINE_POSITION_BEFORE (1<<1)
	//End positions
	#define COMPONENT_EXNAME_CHANGED (1<<0)
///from base of atom/update_icon(): ()
#define COMSIG_ATOM_UPDATE_ICON "atom_update_icon"
	#define COMSIG_ATOM_NO_UPDATE_ICON_STATE	(1<<0)
	#define COMSIG_ATOM_NO_UPDATE_OVERLAYS		(1<<1)
///from base of atom/update_overlays(): (list/new_overlays)
#define COMSIG_ATOM_UPDATE_OVERLAYS "atom_update_overlays"
///from base of atom/update_icon(): (signalOut, did_anything)
#define COMSIG_ATOM_UPDATED_ICON "atom_updated_icon"
///from base of atom/Entered(): (atom/movable/entering, /atom)
#define COMSIG_ATOM_ENTERED "atom_entered"
/// Sent from the atom that just Entered src. From base of atom/Entered(): (/atom/entered_atom, /atom/oldLoc)
#define COMSIG_ATOM_ENTERING "atom_entering"
///from base of atom/Exit(): (/atom/movable/exiting, /atom/newloc)
#define COMSIG_ATOM_EXIT "atom_exit"
	#define COMPONENT_ATOM_BLOCK_EXIT (1<<0)
///from base of atom/Exited(): (atom/movable/exiting, atom/newloc)
#define COMSIG_ATOM_EXITED "atom_exited"
///from base of atom/Bumped(): (/atom/movable)
#define COMSIG_ATOM_BUMPED "atom_bumped"
///from base of atom/ex_act(): (severity, target)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"
	#define COMPONENT_IGNORE_EXPLOSION (1<<0)
///from base of atom/emp_act(): (severity)
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"
///from base of atom/fire_act(): (exposed_temperature, exposed_volume)
#define COMSIG_ATOM_FIRE_ACT "atom_fire_act"
///from base of atom/bullet_act(): (/obj/projectile, def_zone)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"
///from base of atom/CheckParts(): (list/parts_list, datum/crafting_recipe/R)
#define COMSIG_ATOM_CHECKPARTS "atom_checkparts"
///from base of atom/CheckParts(): (atom/movable/new_craft) - The atom has just been used in a crafting recipe and has been moved inside new_craft.
#define COMSIG_ATOM_USED_IN_CRAFT "atom_used_in_craft"
///from base of atom/blob_act(): (/obj/structure/blob)
#define COMSIG_ATOM_BLOB_ACT "atom_blob_act"
///from base of atom/acid_act(): (acidpwr, acid_volume)
#define COMSIG_ATOM_ACID_ACT "atom_acid_act"
///from base of atom/emag_act(): (/mob/user)
#define COMSIG_ATOM_EMAG_ACT "atom_emag_act"
///from base of atom/rad_act(intensity)
#define COMSIG_ATOM_RAD_ACT "atom_rad_act"
///from base of atom/narsie_act(): ()
#define COMSIG_ATOM_NARSIE_ACT "atom_narsie_act"
///from base of atom/rcd_act(): (/mob, /obj/item/construction/rcd, passed_mode)
#define COMSIG_ATOM_RCD_ACT "atom_rcd_act"
///from base of atom/singularity_pull(): (S, current_size)
#define COMSIG_ATOM_SING_PULL "atom_sing_pull"
///from obj/machinery/bsa/full/proc/fire(): ()
#define COMSIG_ATOM_BSA_BEAM "atom_bsa_beam_pass"
	#define COMSIG_ATOM_BLOCKS_BSA_BEAM (1<<0)
///from base of atom/setDir(): (old_dir, new_dir)
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"
///from base of atom/handle_atom_del(): (atom/deleted)
#define COMSIG_ATOM_CONTENTS_DEL "atom_contents_del"
///from base of atom/get_gravity(): (turf/location, list/forced_gravities)
#define COMSIG_ATOM_HAS_GRAVITY "atom_has_gravity"
///from proc/get_rad_contents(): ()
#define COMSIG_ATOM_RAD_PROBE "atom_rad_probe"
	#define COMPONENT_BLOCK_RADIATION (1<<0)
///from base of datum/radiation_wave/radiate(): (strength)
#define COMSIG_ATOM_RAD_CONTAMINATING "atom_rad_contam"
	#define COMPONENT_BLOCK_CONTAMINATION (1<<0)
///from base of datum/radiation_wave/check_obstructions(): (datum/radiation_wave, width)
#define COMSIG_ATOM_RAD_WAVE_PASSING "atom_rad_wave_pass"
	#define COMPONENT_RAD_WAVE_HANDLED (1<<0)
///from internal loop in atom/movable/proc/CanReach(): (list/next)
#define COMSIG_ATOM_CANREACH "atom_can_reach"
	#define COMPONENT_BLOCK_REACH (1<<0)
///from base of atom/screwdriver_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_SCREWDRIVER_ACT "atom_screwdriver_act"
///from base of atom/wrench_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_WRENCH_ACT "atom_wrench_act"
///from base of atom/multitool_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_MULTITOOL_ACT "atom_multitool_act"
///from base of atom/welder_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_WELDER_ACT "atom_welder_act"
///from base of atom/wirecutter_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_WIRECUTTER_ACT "atom_wirecutter_act"
///from base of atom/crowbar_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_CROWBAR_ACT "atom_crowbar_act"
///from base of atom/analyser_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_ANALYSER_ACT "atom_analyser_act"
	#define COMPONENT_BLOCK_TOOL_ATTACK (1<<0)
///called when teleporting into a protected turf: (channel, turf/origin)
#define COMSIG_ATOM_INTERCEPT_TELEPORT "intercept_teleport"
	#define COMPONENT_BLOCK_TELEPORT (1<<0)
///called when an atom is added to the hearers on get_hearers_in_view(): (list/processing_list, list/hearers)
#define COMSIG_ATOM_HEARER_IN_VIEW "atom_hearer_in_view"
///called when an atom starts orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_BEGIN "atom_orbit_begin"
///called when an atom stops orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_STOP "atom_orbit_stop"
///from base of atom/set_opacity(): (new_opacity)
#define COMSIG_ATOM_SET_OPACITY "atom_set_opacity"
/////////////////
///from base of atom/attack_ghost(): (mob/dead/observer/ghost)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"
///from base of atom/attack_hand(): (mob/user)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"
///from base of atom/attack_paw(): (mob/user)
//This signal return value bitflags can be found in __DEFINES/misc.dm

///called for each movable in a turf contents on /turf/zImpact(): (atom/movable/A, levels)
#define COMSIG_ATOM_INTERCEPT_Z_FALL "movable_intercept_z_impact"
///called on a movable (NOT living) when someone starts pulling it (atom/movable/puller, state, force)
#define COMSIG_ATOM_START_PULL "movable_start_pull"
///called on /living when someone starts pulling it (atom/movable/puller, state, force)
#define COMSIG_LIVING_START_PULL "living_start_pull"
///from base atom/Exited(): (mob/user, obj/item/extrapolator/extrapolator, dry_run, list/result)
#define COMSIG_ATOM_EXTRAPOLATOR_ACT "atom_extrapolator_act"

/////////////////

///from base of area/Entered(): (/area)
#define COMSIG_ENTER_AREA "enter_area"
///from base of area/Exited(): (/area)
#define COMSIG_EXIT_AREA "exit_area"
///from base of client/Click(): (atom/target, atom/location, control, params, mob/user)
#define COMSIG_CLIENT_CLICK "atom_client_click"
///from base of atom/Click(): (location, control, params, mob/user)
#define COMSIG_CLICK "atom_click"
///from base of atom/ShiftClick(): (/mob)
#define COMSIG_CLICK_SHIFT "shift_click"
	#define COMPONENT_ALLOW_EXAMINATE (1<<0) 							//Allows the user to examinate regardless of client.eye.
///from base of atom/CtrlClickOn(): (/mob)
#define COMSIG_CLICK_CTRL "ctrl_click"
///from base of atom/AltClick(): (/mob)
#define COMSIG_CLICK_ALT "alt_click"
///from base of atom/CtrlShiftClick(/mob)
#define COMSIG_CLICK_CTRL_SHIFT "ctrl_shift_click"
///from base of atom/MouseDrop(): (/atom/over, /mob/user)
#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"
	#define COMPONENT_NO_MOUSEDROP (1<<0)
///from base of atom/MouseDrop_T: (/atom/from, /mob/user)
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"

// /area signals

///from base of area/Entered(): (atom/movable/M)
#define COMSIG_AREA_ENTERED "area_entered"
///from base of area/Exited(): (atom/movable/M)
#define COMSIG_AREA_EXITED "area_exited"

// /turf signals

///from base of turf/ChangeTurf(): (path, list/new_baseturfs, flags, list/transferring_comps)
#define COMSIG_TURF_CHANGE "turf_change"
///from base of atom/get_gravity(): (atom/asker, list/forced_gravities)
#define COMSIG_TURF_HAS_GRAVITY "turf_has_gravity"
///from base of turf/multiz_turf_del(): (turf/source, direction)
#define COMSIG_TURF_MULTIZ_DEL "turf_multiz_del"
///from base of turf/multiz_turf_new: (turf/source, direction)
#define COMSIG_TURF_MULTIZ_NEW "turf_multiz_new"

// /atom/movable signals

///from base of atom/movable/Move(): (atom/newloc, dir, movetime)
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"
	#define COMPONENT_MOVABLE_BLOCK_PRE_MOVE (1<<0)
///from base of atom/movable/Moved(): (/atom, dir)
#define COMSIG_MOVABLE_MOVED "movable_moved"
///from base of atom/movable/Cross(): (/atom/movable)
#define COMSIG_MOVABLE_CROSS "movable_cross"
///when we cross over something (calling Crossed() on that atom)
#define COMSIG_CROSSED_MOVABLE "crossed_movable"
///from base of atom/movable/Bump(): (/atom)
#define COMSIG_MOVABLE_BUMP "movable_bump"
///from base of atom/movable/throw_impact(): (/atom/hit_atom, /datum/thrownthing/throwingdatum)
#define COMSIG_MOVABLE_IMPACT "movable_impact"
	#define COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH (1<<0)				//if true, flip if the impact will push what it hits
	#define COMPONENT_MOVABLE_IMPACT_NEVERMIND (1<<1)					//return true if you destroyed whatever it was you're impacting and there won't be anything for hitby() to run on
///from base of mob/living/hitby(): (mob/living/target, hit_zone)
#define COMSIG_MOVABLE_IMPACT_ZONE "item_impact_zone"
///from base of atom/movable/buckle_mob(): (mob, force)
#define COMSIG_MOVABLE_BUCKLE "buckle"
///from base of atom/movable/unbuckle_mob(): (mob, force)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"
///from base of atom/movable/throw_at(): (list/args)
#define COMSIG_MOVABLE_PRE_THROW "movable_pre_throw"
	#define COMPONENT_CANCEL_THROW (1<<0)
///from base of atom/movable/throw_at(): (datum/thrownthing, spin)
#define COMSIG_MOVABLE_POST_THROW "movable_post_throw"
///from base of atom/movable/onTransitZ(): (old_z, new_z)
#define COMSIG_MOVABLE_Z_CHANGED "movable_ztransit"
///called when the movable is placed in an unaccessible area, used for stationloving: ()
#define COMSIG_MOVABLE_SECLUDED_LOCATION "movable_secluded"
///from base of atom/movable/Hear(): (proc args list(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode))
#define COMSIG_MOVABLE_HEAR "movable_hear"
	#define HEARING_MESSAGE 1
	#define HEARING_SPEAKER 2
//	#define HEARING_LANGUAGE 3
	#define HEARING_RAW_MESSAGE 4
	/* #define HEARING_RADIO_FREQ 5
	#define HEARING_SPANS 6
	#define HEARING_MESSAGE_MODE 7 */
///from /datum/controller/subsystem/motion_tracker/notice() (/datum/weakref/source_atom,/turf/echo_turf_location)
#define COMSIG_MOVABLE_MOTIONTRACKER "move_motiontracker"

///called when the movable is added to a disposal holder object for disposal movement: (obj/structure/disposalholder/holder, obj/machinery/disposal/source)
#define COMSIG_MOVABLE_DISPOSING "movable_disposing"

// /mob signals

///from base of /mob/Login(): ()
#define COMSIG_MOB_LOGIN "mob_login"
///from base of /mob/Logout(): ()
#define COMSIG_MOB_LOGOUT "mob_logout"
///from base of mob/death(): (gibbed)
#define COMSIG_MOB_DEATH "mob_death"
///from base of mob/set_stat(): (new_stat)
#define COMSIG_MOB_STATCHANGE "mob_statchange"
///from base of mob/clickon(): (atom/A, params)
#define COMSIG_MOB_CLICKON "mob_clickon"
///from base of mob/MiddleClickOn(): (atom/A)
#define COMSIG_MOB_MIDDLECLICKON "mob_middleclickon"
///from base of mob/AltClickOn(): (atom/A)
#define COMSIG_MOB_ALTCLICKON "mob_altclickon"
	#define COMSIG_MOB_CANCEL_CLICKON (1<<0)

///from base of obj/allowed(mob/M): (/obj) returns bool, if TRUE the mob has id access to the obj
#define COMSIG_MOB_ALLOWED "mob_allowed"
///from base of mob/anti_magic_check(): (mob/user, magic, holy, tinfoil, chargecost, self, protection_sources)
#define COMSIG_MOB_RECEIVE_MAGIC "mob_receive_magic"
	#define COMPONENT_BLOCK_MAGIC (1<<0)
///from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"
///from base of atom/attack_hand(): (mob/user)
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"
///from base of /obj/item/attack(): (mob/M, mob/user)
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"
	#define COMPONENT_ITEM_NO_ATTACK (1<<0)
///from the base of /mob/living/silicon/robot/ClickOn(): (var/atom/A, var/params)
#define COMSIG_ROBOT_ITEM_ATTACK "robot_item_attack"
///from base of /mob/living/proc/apply_damage(): (damage, damagetype, def_zone)
#define COMSIG_MOB_APPLY_DAMGE	"mob_apply_damage"
///from base of obj/item/afterattack(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"
///from base of obj/item/attack_qdeleted(): (atom/target, mob/user, proxiumity_flag, click_parameters)
#define COMSIG_MOB_ITEM_ATTACK_QDELETED "mob_item_attack_qdeleted"
///from base of mob/RangedAttack(): (atom/A, params)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"
///from base of /mob/throw_item(): (atom/target)
#define COMSIG_MOB_THROW "mob_throw"
///from base of /mob/verb/examinate(): (atom/target)
#define COMSIG_MOB_EXAMINATE "mob_examinate"
///from base of /mob/update_sight(): ()
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"
////from /mob/living/say(): ()
#define COMSIG_MOB_SAY "mob_say"
	#define COMPONENT_UPPERCASE_SPEECH (1<<0)
	// used to access COMSIG_MOB_SAY argslist
	#define SPEECH_MESSAGE 1
	// #define SPEECH_BUBBLE_TYPE 2
	#define SPEECH_SPANS 3
	/* #define SPEECH_SANITIZE 4
	#define SPEECH_LANGUAGE 5
	#define SPEECH_IGNORE_SPAM 6
	#define SPEECH_FORCED 7 */

///from /mob/say_dead(): (mob/speaker, message)
#define COMSIG_MOB_DEADSAY "mob_deadsay"
	#define MOB_DEADSAY_SIGNAL_INTERCEPT (1<<0)
///from /mob/living/emote(): ()
#define COMSIG_MOB_EMOTE "mob_emote"
///from base of mob/swap_hand(): (obj/item)
#define COMSIG_MOB_SWAP_HANDS "mob_swap_hands"
	#define COMPONENT_BLOCK_SWAP (1<<0)

// /mob/living signals

///from base of mob/living/resist() (/mob/living)
#define COMSIG_LIVING_RESIST "living_resist"
///from base of mob/living/IgniteMob() (/mob/living)
#define COMSIG_LIVING_IGNITED "living_ignite"
///from base of mob/living/ExtinguishMob() (/mob/living)
#define COMSIG_LIVING_EXTINGUISHED "living_extinguished"
#define COMSIG_LIVING_SHOCK_PREVENTED "living_shock_prevented"
///sent by stuff like stunbatons and tasers: ()
#define COMSIG_LIVING_MINOR_SHOCK "living_minor_shock"
///from base of mob/living/revive() (full_heal, admin_revive)
#define COMSIG_LIVING_REVIVE "living_revive"
///from base of /mob/living/regenerate_limbs(): (noheal, excluded_limbs)
#define COMSIG_LIVING_REGENERATE_LIMBS "living_regen_limbs"
///from base of /obj/item/bodypart/proc/attach_limb(): (new_limb, special) allows you to fail limb attachment
#define COMSIG_LIVING_ATTACH_LIMB "living_attach_limb"
	#define COMPONENT_NO_ATTACH (1<<0)
///sent from borg recharge stations: (amount, repairs)
#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "living_charge"
///sent when a mob/login() finishes: (client)
#define COMSIG_MOB_CLIENT_LOGIN "comsig_mob_client_login"
///sent from borg mobs to itself, for tools to catch an upcoming destroy() due to safe decon (rather than detonation)
#define COMSIG_BORG_SAFE_DECONSTRUCT "borg_safe_decon"
///From living/Life().
#define COMSIG_LIVING_LIFE "living_life"
///From /living/handle_disabilities().
#define COMSIG_HANDLE_DISABILITIES "handle_disabilities"
///From /mob/living/proc/updatehealth().
#define COMSIG_UPDATE_HEALTH "update_health"
	#define COMSIG_UPDATE_HEALTH_GOD_MODE (1<<0) //If this will set health to 100 and stat to conscious.

// Damage specific signals for /mob/living
///from /mob/living/proc/adjustBrainLoss(amount) and /mob/living/proc/setBrainLoss(amount)
#define COMSIG_TAKING_BRAIN_DAMAGE "taking_brain_damage"
///Return this in response if you don't want brain damage to be dealt via the normal proc.
	#define COMSIG_CANCEL_BRAIN_DAMAGE (1<<0)
///from /mob/living/proc/adjustOxyLoss(amount) and /mob/living/proc/setOxyLoss(amount)
#define COMSIG_TAKING_OXY_DAMAGE "taking_oxy_damage"
///Return this in response if you don't want brain damage to be dealt via the normal proc.
	#define COMSIG_CANCEL_OXY_DAMAGE (1<<0)
///from /mob/living/proc/adjustToxLoss(amount) and /mob/living/proc/setToxLoss(amount)
#define COMSIG_TAKING_TOX_DAMAGE "taking_tox_damage"
///Return this in response if you don't want tox damage to be dealt via the normal proc.
	#define COMSIG_CANCEL_TOX_DAMAGE (1<<0)
///from /mob/living/proc/adjustCloneLoss(amount) and /mob/living/proc/setCloneLoss(amount)
#define COMSIG_TAKING_CLONE_DAMAGE "taking_clone_damage"
///Return this in response if you don't want clone damage to be dealt via the normal proc.
	#define COMSIG_CANCEL_CLONE_DAMAGE (1<<0)
///from /mob/living/proc/adjustFireLoss(amount, include_robo)
#define COMSIG_TAKING_FIRE_DAMAGE "taking_fire_damage"
///Return this in response if you don't want fire damage to be dealt via the normal proc.
	#define COMSIG_CANCEL_FIRE_DAMAGE (1<<0)
///from /mob/living/proc/adjustBruteLoss(amount, include_robo) and /mob/living/carbon/human/adjustBruteLoss(amount, include_robo)
#define COMSIG_TAKING_BRUTE_DAMAGE "taking_brute_damage"
///Return this in response if you don't want brute damage to be dealt via the normal proc.
	#define COMSIG_CANCEL_BRUTE_DAMAGE (1<<0)
///from /mob/living/proc/adjustHalLoss(amount)
#define COMSIG_TAKING_HALO_DAMAGE "taking_halo_damage"
///Return this in response if you don't want halo damage to be dealt via the normal proc.
	#define COMSIG_CANCEL_HALO_DAMAGE (1<<0)
///from /mob/living/proc/apply_effect(effect, effecttype, blocked, check_protection)
#define COMSIG_TAKING_APPLY_EFFECT "applying_effect"
///Return this in response if you don't want the effect to be applied
	#define COMSIG_CANCEL_EFFECT (1<<0)

///Misc signal for checking for godmode. Used by /datum/element/godmode
#define COMSIG_CHECK_FOR_GODMODE "check_for_godmode"
///Returned by /datum/element/godmode if the target is in godmode and whatever we're checking we want to cancel
	#define COMSIG_GODMODE_CANCEL (1<<0)

//ALL OF THESE DO NOT TAKE INTO ACCOUNT WHETHER AMOUNT IS 0 OR LOWER AND ARE SENT REGARDLESS!

///from base of mob/living/Stun() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_STUN "living_stun"
///from base of mob/living/Knockdown() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"
///from base of mob/living/Paralyze() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"
///from base of mob/living/Immobilize() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"
///from base of mob/living/Unconscious() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"
///from base of mob/living/Sleeping() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"
	#define COMPONENT_NO_STUN (1<<0)									//For all of them
///from base of /mob/living/can_track(): (mob/user)
#define COMSIG_LIVING_CAN_TRACK "mob_cantrack"
	#define COMPONENT_CANT_TRACK (1<<0)

// /mob/living/carbon signals

///from base of mob/living/carbon/soundbang_act(): (list(intensity))
#define COMSIG_CARBON_SOUNDBANG "carbon_soundbang"
///from /item/organ/proc/Insert() (/obj/item/organ/)
#define COMSIG_CARBON_GAIN_ORGAN "carbon_gain_organ"
///from /item/organ/proc/Remove() (/obj/item/organ/)
#define COMSIG_CARBON_LOSE_ORGAN "carbon_lose_organ"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_EQUIP_HAT "carbon_equip_hat"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_UNEQUIP_HAT "carbon_unequip_hat"
///defined twice, in carbon and human's topics, fired when interacting with a valid embedded_object to pull it out (mob/living/carbon/target, /obj/item, /obj/item/bodypart/L)
#define COMSIG_CARBON_EMBED_RIP "item_embed_start_rip"
///called when removing a given item from a mob, from mob/living/carbon/remove_embedded_object(mob/living/carbon/target, /obj/item)
#define COMSIG_CARBON_EMBED_REMOVAL "item_embed_remove_safe"
///called when being electrocuted, from /mob/living/carbon/electrocute_act(shock_damage, source, siemens_coeff, def_zone, stun)
#define COMSIG_BEING_ELECTROCUTED "being_electrocuted"
	#define COMPONENT_CARBON_CANCEL_ELECTROCUTE (1<<0) //If this is set, the carbon will be not be electrocuted.


// /mob/living/silicon signals
///called when a silicon is emp'd. from /mob/living/silicon/emp_act(severity)
#define COMSIG_SILICON_EMP_ACT "silicon_emp_act"
	#define COMPONENT_BLOCK_EMP (1<<0) //If this is set, the EMP will not go through. Used by other EMP acts as well.

// /mob/living/silicon/robot signals
///called when a robot is emp'd. from /mob/living/silicon/robot/emp_act(severity)
#define COMSIG_ROBOT_EMP_ACT "robot_emp_act"

///from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"
///called in /obj/structure/setAnchored(): (value)
#define COMSIG_OBJ_SETANCHORED "obj_setanchored"
///from base of code/game/machinery
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
///from base of /turf/proc/levelupdate(). (intact) true to hide and false to unhide
#define COMSIG_OBJ_HIDE	"obj_hide"
///called in /obj/update_icon()
#define COMSIG_OBJ_UPDATE_ICON "obj_update_icon"

// climbable signals

///called when a mob is mousedropped onto, or uses a verb to climb an object
#define COMSIG_CLIMBABLE_START_CLIMB "starting_climb_action"
///called when an object is considered unsafe to climb on
#define COMSIG_CLIMBABLE_SHAKE_CLIMBERS "shaking_climbing_mobs"

// /obj/machinery signals

///from /obj/machinery/obj_break(damage_flag): (damage_flag)
#define COMSIG_MACHINERY_BROKEN "machinery_broken"
///from base power_change() when power is lost
#define COMSIG_MACHINERY_POWER_LOST "machinery_power_lost"
///from base power_change() when power is restored
#define COMSIG_MACHINERY_POWER_RESTORED "machinery_power_restored"

// /obj/item signals

///from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK "item_attack"
///from base of obj/item/attack_self(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"
	#define COMPONENT_NO_INTERACT (1<<0)
///from base of obj/item/attack_obj(): (/obj, /mob)
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"
	#define COMPONENT_NO_ATTACK_OBJ (1<<0)
///from base of obj/item/pre_attack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_PRE_ATTACK "item_pre_attack"
	#define COMPONENT_NO_ATTACK (1<<0)
///from base of obj/item/afterattack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"
///from base of obj/item/attack_qdeleted(): (atom/target, mob/user, params)
#define COMSIG_ITEM_ATTACK_QDELETED "item_attack_qdeleted"
///from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_EQUIPPED "item_equip"
///from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_DROPPED "item_drop"
///from base of obj/item/pickup(): (/mob/taker)
#define COMSIG_ITEM_PICKUP "item_pickup"
///from base of mob/living/carbon/attacked_by(): (mob/living/carbon/target, mob/living/user, hit_zone)
#define COMSIG_ITEM_ATTACK_ZONE "item_attack_zone"
///return a truthy value to prevent ensouling, checked in /obj/effect/proc_holder/spell/targeted/lichdom/cast(): (mob/user)
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul"
///called before marking an object for retrieval, checked in /obj/effect/proc_holder/spell/targeted/summonitem/cast() : (mob/user)
#define COMSIG_ITEM_MARK_RETRIEVAL "item_mark_retrieval"
	#define COMPONENT_BLOCK_MARK_RETRIEVAL (1<<0)
///from base of obj/item/hit_reaction(): (list/args)
#define COMSIG_ITEM_HIT_REACT "item_hit_react"
///called on item when crossed by something (): (/atom/movable, mob/living/crossed)
#define COMSIG_ITEM_WEARERCROSSED "wearer_crossed"
///called on item when microwaved (): (obj/machinery/microwave/M)
#define COMSIG_ITEM_MICROWAVE_ACT "microwave_act"
///from base of item/sharpener/attackby(): (amount, max)
#define COMSIG_ITEM_SHARPEN_ACT "sharpen_act"
	#define COMPONENT_BLOCK_SHARPEN_APPLIED (1<<0)
	#define COMPONENT_BLOCK_SHARPEN_BLOCKED (1<<1)
	#define COMPONENT_BLOCK_SHARPEN_ALREADY (1<<2)
	#define COMPONENT_BLOCK_SHARPEN_MAXED (1<<3)
///from base of [/obj/item/proc/tool_check_callback]: (mob/living/user)
#define COMSIG_TOOL_IN_USE "tool_in_use"
///from base of [/obj/item/proc/tool_start_check]: (mob/living/user)
#define COMSIG_TOOL_START_USE "tool_start_use"
///from [/obj/item/proc/disableEmbedding]:
#define COMSIG_ITEM_DISABLE_EMBED "item_disable_embed"
///from [/obj/effect/mine/proc/triggermine]:
#define COMSIG_MINE_TRIGGERED "minegoboom"

// /obj/item signals for economy
///called when an item is sold by the exports subsystem
#define COMSIG_ITEM_SOLD "item_sold"
///called when a wrapped up structure is opened by hand
#define COMSIG_STRUCTURE_UNWRAPPED "structure_unwrapped"
#define COMSIG_ITEM_UNWRAPPED "item_unwrapped"
///called when a wrapped up item is opened by hand
	#define COMSIG_ITEM_SPLIT_VALUE  (1<<0)
///called when getting the item's exact ratio for cargo's profit.
#define COMSIG_ITEM_SPLIT_PROFIT "item_split_profits"
///called when getting the item's exact ratio for cargo's profit, without selling the item.
#define COMSIG_ITEM_SPLIT_PROFIT_DRY "item_split_profits_dry"

// /obj/item/clothing signals

///from base of obj/item/clothing/shoes/proc/step_action(): ()
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"
///from base of /obj/item/clothing/suit/space/proc/toggle_spacesuit(): (obj/item/clothing/suit/space/suit)
#define COMSIG_SUIT_SPACE_TOGGLE "suit_space_toggle"

// /obj/item/implant signals
///from base of /obj/item/implant/proc/activate(): ()
#define COMSIG_IMPLANT_ACTIVATED "implant_activated"
///from base of /obj/item/implant/proc/implant(): (list/args)
#define COMSIG_IMPLANT_IMPLANTING "implant_implanting"
	#define COMPONENT_STOP_IMPLANTING (1<<0)
///called on already installed implants when a new one is being added in /obj/item/implant/proc/implant(): (list/args, obj/item/implant/new_implant)
#define COMSIG_IMPLANT_OTHER "implant_other"
	//#define COMPONENT_STOP_IMPLANTING (1<<0) //The name makes sense for both
	#define COMPONENT_DELETE_NEW_IMPLANT (1<<1)
	#define COMPONENT_DELETE_OLD_IMPLANT (1<<2)
///called on implants being implanted into someone with an uplink implant: (datum/component/uplink)
#define COMSIG_IMPLANT_EXISTING_UPLINK "implant_uplink_exists"
	//This uses all return values of COMSIG_IMPLANT_OTHER

// /obj/item/pda signals

///called on pda when the user changes the ringtone: (mob/living/user, new_ringtone)
#define COMSIG_PDA_CHANGE_RINGTONE "pda_change_ringtone"
	#define COMPONENT_STOP_RINGTONE_CHANGE (1<<0)
#define COMSIG_PDA_CHECK_DETONATE "pda_check_detonate"
	#define COMPONENT_PDA_NO_DETONATE (1<<0)

// /obj/item/radio signals

///called from base of /obj/item/radio/proc/set_frequency(): (list/args)
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"

// /obj/item/pen signals

///called after rotation in /obj/item/pen/attack_self(): (rotation, mob/living/carbon/user)
#define COMSIG_PEN_ROTATED "pen_rotated"

// /obj/item/gun signals

///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_MOB_FIRED_GUN "mob_fired_gun"

// /obj/item/grenade signals

///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_PRIME "grenade_prime"
///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_ARMED "grenade_armed"

// /obj/projectile signals (sent to the firer)

///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_SELF_ON_HIT "projectile_self_on_hit"
///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_ON_HIT "projectile_on_hit"
///from base of /obj/projectile/proc/fire(): (obj/projectile, atom/original_target)
#define COMSIG_PROJECTILE_BEFORE_FIRE "projectile_before_fire"
///from the base of /obj/projectile/proc/fire(): ()
#define COMSIG_PROJECTILE_FIRE "projectile_fire"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_PREHIT "com_proj_prehit"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_RANGE_OUT "projectile_range_out"
///sent when trying to force an embed (mainly for projectiles, only used in the embed element)
#define COMSIG_EMBED_TRY_FORCE "item_try_embed"

///sent to targets during the process_hit proc of projectiles
#define COMSIG_PELLET_CLOUD_INIT "pellet_cloud_init"

// /obj/mecha signals

///sent from mecha action buttons to the mecha they're linked to
#define COMSIG_MECHA_ACTION_ACTIVATE "mecha_action_activate"

// /mob/living/carbon/human signals

///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity)
#define COMSIG_HUMAN_EARLY_UNARMED_ATTACK "human_early_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (mob/living/carbon/human/attacker)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY "human_melee_unarmed_attackby"
///Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)
#define COMSIG_HUMAN_DISARM_HIT	"human_disarm_hit"
///Whenever EquipRanked is called, called after job is set
#define COMSIG_JOB_RECEIVED "job_received"
///When the mob's dna and species have been fully applied
#define COMSIG_HUMAN_DNA_FINALIZED "human_dna_finished"

// Organ specific signals

///from /obj/item/organ/external/take_damage(brute, burn, sharp, edge, used_weapon, forbidden_limbs, permutation, projectile)
#define COMSIG_EXTERNAL_ORGAN_PRE_DAMAGE_APPLICATION "external_organ_pre_damage_application"
///Return this in response if you don't want external organ damage to be dealt via the normal proc.
	#define COMPONENT_CANCEL_EXTERNAL_ORGAN_DAMAGE (1<<0)
///from /obj/item/organ/external/take_damage(brute, burn, sharp, edge, used_weapon, forbidden_limbs, permutation, projectile)
#define COMSIG_EXTERNAL_ORGAN_POST_DAMAGE_APPLICATION "external_organ_post_damage_application"
///from /obj/item/organ/take_damage(amount, silent)
#define COMSIG_INTERNAL_ORGAN_PRE_DAMAGE_APPLICATION "internal_organ_pre_damage_application"
///Return this in response if you don't want internal organ damage to be dealt via the normal proc.
	#define COMPONENT_CANCEL_INTERNAL_ORGAN_DAMAGE (1<<0)
///from /obj/item/organ/take_damage(amount, silent)
#define COMSIG_INTERNAL_ORGAN_POST_DAMAGE_APPLICATION "internal_organ_post_damage_application"
///From /obj/item/organ/external/proc/embed(W, silent)
#define COMSIG_EMBED_OBJECT "embed_object"
///Return this in response if you don't want the embed to go through.
	#define COMSIG_CANCEL_EMBED (1<<0)

// /datum/species signals

///from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species)
#define COMSIG_SPECIES_GAIN "species_gain"
///from datum/species/on_species_loss(): (datum/species/lost_species)
#define COMSIG_SPECIES_LOSS "species_loss"

// /datum/song signals

///sent to the instrument when a song starts playing
#define COMSIG_SONG_START 	"song_start"
///sent to the instrument when a song stops playing
#define COMSIG_SONG_END		"song_end"

/*******Component Specific Signals*******/
//Janitor

///(): Returns bitflags of wet values.
#define COMSIG_TURF_IS_WET "check_turf_wet"
///(max_strength, immediate, duration_decrease = INFINITY): Returns bool.
#define COMSIG_TURF_MAKE_DRY "make_turf_try"

//Creamed

///called when you wash your face at a sink: (num/strength)
#define COMSIG_COMPONENT_CLEAN_FACE_ACT "clean_face_act"

//Food

///from base of obj/item/reagent_containers/food/snacks/attack(): (mob/living/eater, mob/feeder)
#define COMSIG_FOOD_EATEN "food_eaten"

//Gibs

///from base of /obj/effect/decal/cleanable/blood/gibs/streak(): (list/directions, list/diseases)
#define COMSIG_GIBS_STREAK "gibs_streak"

//Mood

///called when you send a mood event from anywhere in the code.
#define COMSIG_ADD_MOOD_EVENT "add_mood"
///Mood event that only RnD members listen for
#define COMSIG_ADD_MOOD_EVENT_RND "RND_add_mood"
///called when you clear a mood event from anywhere in the code.
#define COMSIG_CLEAR_MOOD_EVENT "clear_mood"

//NTnet

///called on an object by its NTNET connection component on receive. (sending_id(number), sending_netname(text), data(datum/netdata))
#define COMSIG_COMPONENT_NTNET_RECEIVE "ntnet_receive"

//Nanites

///() returns TRUE if nanites are found
#define COMSIG_HAS_NANITES "has_nanites"
///() returns TRUE if nanites have stealth
#define COMSIG_NANITE_IS_STEALTHY "nanite_is_stealthy"
///() deletes the nanite component
#define COMSIG_NANITE_DELETE "nanite_delete"
///(list/nanite_programs) - makes the input list a copy the nanites' program list
#define COMSIG_NANITE_GET_PROGRAMS	"nanite_get_programs"
///(amount) Returns nanite amount
#define COMSIG_NANITE_GET_VOLUME "nanite_get_volume"
///(amount) Sets current nanite volume to the given amount
#define COMSIG_NANITE_SET_VOLUME "nanite_set_volume"
///(amount) Adjusts nanite volume by the given amount
#define COMSIG_NANITE_ADJUST_VOLUME "nanite_adjust"
///(amount) Sets maximum nanite volume to the given amount
#define COMSIG_NANITE_SET_MAX_VOLUME "nanite_set_max_volume"
///(amount(0-100)) Sets cloud ID to the given amount
#define COMSIG_NANITE_SET_CLOUD "nanite_set_cloud"
///(method) Modify cloud sync status. Method can be toggle, enable or disable
#define COMSIG_NANITE_SET_CLOUD_SYNC "nanite_set_cloud_sync"
///(amount) Sets safety threshold to the given amount
#define COMSIG_NANITE_SET_SAFETY "nanite_set_safety"
///(amount) Sets regeneration rate to the given amount
#define COMSIG_NANITE_SET_REGEN "nanite_set_regen"
///(code(1-9999)) Called when sending a nanite signal to a mob.
#define COMSIG_NANITE_SIGNAL "nanite_signal"
///(comm_code(1-9999), comm_message) Called when sending a nanite comm signal to a mob.
#define COMSIG_NANITE_COMM_SIGNAL "nanite_comm_signal"
///(mob/user, full_scan) - sends to chat a scan of the nanites to the user, returns TRUE if nanites are detected
#define COMSIG_NANITE_SCAN "nanite_scan"
///(list/data, scan_level) - adds nanite data to the given data list - made for ui_data procs
#define COMSIG_NANITE_UI_DATA "nanite_ui_data"
///(datum/nanite_program/new_program, datum/nanite_program/source_program) Called when adding a program to a nanite component
#define COMSIG_NANITE_ADD_PROGRAM "nanite_add_program"
	///Installation successful
	#define COMPONENT_PROGRAM_INSTALLED		(1<<0)
	///Installation failed, but there are still nanites
	#define COMPONENT_PROGRAM_NOT_INSTALLED	(1<<1)
///(datum/component/nanites, full_overwrite, copy_activation) Called to sync the target's nanites to a given nanite component
#define COMSIG_NANITE_SYNC "nanite_sync"

// /datum/component/storage signals

///() - returns bool.
#define COMSIG_CONTAINS_STORAGE "is_storage"
///(obj/item/inserting, mob/user, silent, force) - returns bool
#define COMSIG_TRY_STORAGE_INSERT "storage_try_insert"
///(mob/show_to, force) - returns bool.
#define COMSIG_TRY_STORAGE_SHOW "storage_show_to"
///(mob/hide_from) - returns bool
#define COMSIG_TRY_STORAGE_HIDE_FROM "storage_hide_from"
///returns bool
#define COMSIG_TRY_STORAGE_HIDE_ALL "storage_hide_all"
///(newstate)
#define COMSIG_TRY_STORAGE_SET_LOCKSTATE "storage_lock_set_state"
///() - returns bool. MUST CHECK IF STORAGE IS THERE FIRST!
#define COMSIG_IS_STORAGE_LOCKED "storage_get_lockstate"
///(type, atom/destination, amount = INFINITY, check_adjacent, force, mob/user, list/inserted) - returns bool - type can be a list of types.
#define COMSIG_TRY_STORAGE_TAKE_TYPE "storage_take_type"
///(type, amount = INFINITY, force = FALSE). Force will ignore max_items, and amount is normally clamped to max_items.
#define COMSIG_TRY_STORAGE_FILL_TYPE "storage_fill_type"
///(obj, new_loc, force = FALSE) - returns bool
#define COMSIG_TRY_STORAGE_TAKE "storage_take_obj"
///(loc) - returns bool - if loc is null it will dump at parent location.
#define COMSIG_TRY_STORAGE_QUICK_EMPTY "storage_quick_empty"
///(list/list_to_inject_results_into, recursively_search_inside_storages = TRUE)
#define COMSIG_TRY_STORAGE_RETURN_INVENTORY "storage_return_inventory"
///(obj/item/insertion_candidate, mob/user, silent) - returns bool
#define COMSIG_TRY_STORAGE_CAN_INSERT "storage_can_equip"

// /datum/component/two_handed signals

///from base of datum/component/two_handed/proc/wield(mob/living/carbon/user): (/mob/user)
#define COMSIG_TWOHANDED_WIELD "twohanded_wield"
	#define COMPONENT_TWOHANDED_BLOCK_WIELD (1<<0)
///from base of datum/component/two_handed/proc/unwield(mob/living/carbon/user): (/mob/user)
#define COMSIG_TWOHANDED_UNWIELD "twohanded_unwield"

// /datum/action signals

///from base of datum/action/proc/Trigger(): (datum/action)
#define COMSIG_ACTION_TRIGGER "action_trigger"
	#define COMPONENT_ACTION_BLOCK_TRIGGER (1<<0)
/// From /datum/action/Grant(): (mob/grant_to)
#define COMSIG_ACTION_GRANTED "action_grant"
/// From /datum/action/Remove(): (mob/removed_from)
#define COMSIG_ACTION_REMOVED "action_removed"
/// From /datum/action/Grant(): (datum/action)
#define COMSIG_MOB_GRANTED_ACTION "mob_action_grant"
/// From /datum/action/Remove(): (datum/action)
#define COMSIG_MOB_REMOVED_ACTION "mob_action_removed"
/// From /datum/action/apply_button_overlay()
#define COMSIG_ACTION_OVERLAY_APPLY "action_overlay_applied"

//Xenobio hotkeys

///from slime CtrlClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_CTRL "xeno_slime_click_ctrl"
///from slime AltClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_ALT "xeno_slime_click_alt"
///from slime ShiftClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_SHIFT "xeno_slime_click_shift"
///from turf ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_SHIFT "xeno_turf_click_shift"
///from turf AltClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_CTRL "xeno_turf_click_alt"
///from monkey CtrlClickOn(): (/mob)
#define COMSIG_XENO_MONKEY_CLICK_CTRL "xeno_monkey_click_ctrl"

///SSalarm signals
#define COMSIG_TRIGGERED_ALARM "ssalarm_triggered"
#define COMSIG_CANCELLED_ALARM "ssalarm_cancelled"

#define COMSIG_REAGENTS_CRAFTING_PING "reagents_crafting_ping"

// Lighting:
///from base of [atom/proc/set_light]: (l_range, l_power, l_color, l_on)
#define COMSIG_ATOM_SET_LIGHT "atom_set_light"
	/// Blocks [/atom/proc/set_light], [/atom/proc/set_light_power], [/atom/proc/set_light_range], [/atom/proc/set_light_color], [/atom/proc/set_light_on], and [/atom/proc/set_light_flags].
	#define COMPONENT_BLOCK_LIGHT_UPDATE (1<<0)
///Called right before the atom changes the value of light_power to a different one, from base [atom/proc/set_light_power]: (new_power)
#define COMSIG_ATOM_SET_LIGHT_POWER "atom_set_light_power"
///Called right after the atom changes the value of light_power to a different one, from base of [/atom/proc/set_light_power]: (old_power)
#define COMSIG_ATOM_UPDATE_LIGHT_POWER "atom_update_light_power"
///Called right before the atom changes the value of light_range to a different one, from base [atom/proc/set_light_range]: (new_range)
#define COMSIG_ATOM_SET_LIGHT_RANGE "atom_set_light_range"
///Called right after the atom changes the value of light_range to a different one, from base of [/atom/proc/set_light_range]: (old_range)
#define COMSIG_ATOM_UPDATE_LIGHT_RANGE "atom_update_light_range"
///Called right before the atom changes the value of light_color to a different one, from base [atom/proc/set_light_color]: (new_color)
#define COMSIG_ATOM_SET_LIGHT_COLOR "atom_set_light_color"
///Called right after the atom changes the value of light_color to a different one, from base of [/atom/proc/set_light_color]: (old_color)
#define COMSIG_ATOM_UPDATE_LIGHT_COLOR "atom_update_light_color"
///Called right before the atom changes the value of light_on to a different one, from base [atom/proc/set_light_on]: (new_value)
#define COMSIG_ATOM_SET_LIGHT_ON "atom_set_light_on"
///Called right after the atom changes the value of light_on to a different one, from base of [/atom/proc/set_light_on]: (old_value)
#define COMSIG_ATOM_UPDATE_LIGHT_ON "atom_update_light_on"
///Called right before the atom changes the value of light_flags to a different one, from base [atom/proc/set_light_flags]: (new_flags)
#define COMSIG_ATOM_SET_LIGHT_FLAGS "atom_set_light_flags"
///Called right after the atom changes the value of light_flags to a different one, from base of [/atom/proc/set_light_flags]: (old_flags)
#define COMSIG_ATOM_UPDATE_LIGHT_FLAGS "atom_update_light_flags"

// /datum/element/light_eater
///from base of [/datum/element/light_eater/proc/table_buffet]: (list/light_queue, datum/light_eater)
#define COMSIG_LIGHT_EATER_QUEUE "light_eater_queue"
///from base of [/datum/element/light_eater/proc/devour]: (datum/light_eater)
#define COMSIG_LIGHT_EATER_ACT "light_eater_act"
	///Prevents the default light eater behavior from running in case of immunity or custom behavior
	#define COMPONENT_BLOCK_LIGHT_EATER (1<<0)
///from base of [/datum/element/light_eater/proc/devour]: (atom/eaten_light)
#define COMSIG_LIGHT_EATER_DEVOUR "light_eater_devour"

// Lootpiles
#define COMSIG_LOOT_REWARD "lootpile_reward_drop"

// conflict checking elements
/// (id) - returns flags - Registered on something by conflict checking elements.
#define COMSIG_CONFLICT_ELEMENT_CHECK "conflict_element_check"
	/// A conflict was found
	#define ELEMENT_CONFLICT_FOUND	(1<<0)
//From reagents touch_x.
#define COMSIG_REAGENTS_TOUCH "reagent_touch"


//Moved observer stuff to DCS
#define COMSIG_OBSERVER_MOVED "observer_move"
#define COMSIG_OBSERVER_DESTROYED "observer_destroyed"
#define COMSIG_OBSERVER_SHUTTLE_ADDED "observer_shuttle_added"
#define COMSIG_OBSERVER_SHUTTLE_PRE_MOVE "observer_shuttle_premove"
#define COMSIG_OBSERVER_SHUTTLE_MOVED "observer_shuttle_moved"
#define COMSIG_OBSERVER_TURF_ENTERED "observer_turf_entered"
#define COMSIG_OBSERVER_TURF_EXITED "observer_turf_exited"
#define COMSIG_OBSERVER_Z_MOVED "observer_z_moved"
#define COMSIG_OBSERVER_MOB_EQUIPPED "observer_mob_equipped"
#define COMSIG_OBSERVER_ITEM_EQUIPPED "observer_item_equipped"
#define COMSIG_OBSERVER_MOB_UNEQUIPPED "observer_mob_unequipped"
#define COMSIG_OBSERVER_ITEM_UNEQUIPPED "observer_item_unequipped"
#define COMSIG_OBSERVER_APC "observer_apc"
#define COMSIG_OBSERVER_GLOBALMOVED "observer_global_move"

// Bellies
///from /obj/belly/HandleBellyReagents() and /obj/belly/update_internal_overlay()
#define COMSIG_BELLY_UPDATE_VORE_FX "update_vore_fx"
///from /obj/belly/process()
#define COMSIG_BELLY_UPDATE_PREY_LOOP "update_prey_loop"
/// COMSIG used to get messages where they need to go
#define COMSIG_VISIBLE_MESSAGE "visible_message"

// Weaver Component
///from /mob/living/proc/check_silk_amount()
#define COMSIG_CHECK_SILK_AMOUNT "check_silk_amount"
///from /mob/living/proc/weave_structure()
#define COMSIG_WEAVE_STRUCTURE "weave_structure"
///from /mob/living/proc/toggle_silk_production()
#define COMSIG_TOGGLE_SILK_PRODUCTION "toggle_silk_production"
///from /mob/living/proc/weave_item()
#define COMSIG_WEAVE_ITEM "weave_item"
///from /mob/living/proc/set_silk_color()
#define COMSIG_SET_SILK_COLOR "set_silk_color"

// Gargoyle Component
///from /mob/living/carbon/human/proc/gargoyle_transformation()
#define COMSIG_GARGOYLE_TRANSFORMATION "gargoyle_transformation"
///from /mob/living/carbon/human/proc/gargoyle_pause()
#define COMSIG_GARGOYLE_PAUSE "gargoyle_pause"
///from /mob/living/carbon/human/proc/gargoyle_checkenergy()
#define COMSIG_GARGOYLE_CHECK_ENERGY "gargoyle_check_energy"

// Species Components
///from /datum/species/proc/handle_species_components()
#define COMSIG_XENOCHIMERA_COMPONENT "xenochimera_component"
#define COMSIG_SHADEKIN_COMPONENT "shadekin_component"

// Hose Connector Component
#define COMSIG_HOSE_FORCEPUMP "hose_force_pump"

//Unittest data update
#ifdef UNIT_TEST
#define COMSIG_UNITTEST_DATA "unittest_send_data"
#endif
