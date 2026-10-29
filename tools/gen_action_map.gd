extends SceneTree
## Run once in CI: writes Godot's default OpenXR action map (Index/Touch/Vive/etc. bindings,
## which SteamVR maps onto the Steam Frame controllers), then adds an eye-gaze pose binding
## (XR_EXT_eye_gaze_interaction) used for eye-tracked foveated rendering.
## The default map is saved first, so a failure in the gaze part can never lose it.
 
func _init() -> void:
	var m := OpenXRActionMap.new()
	m.create_default_action_sets()
	print("default action map saved, err=", ResourceSaver.save(m, "res://openxr_action_map.tres"))
	if _add_gaze(m):
		print("gaze binding saved, err=", ResourceSaver.save(m, "res://openxr_action_map.tres"))
	else:
		print("WARNING: gaze binding not added; eye-tracked foveation will fall back to fixed")
	quit()
 
func _add_gaze(m: OpenXRActionMap) -> bool:
	var aset: OpenXRActionSet = m.find_action_set("godot")
	if aset == null and m.get_action_sets().size() > 0:
		aset = m.get_action_sets()[0]
	if aset == null:
		return false
	var act := OpenXRAction.new()
	act.resource_name = "gaze_pose"
	act.localized_name = "Gaze pose"
	act.action_type = OpenXRAction.OPENXR_ACTION_POSE
	act.toplevel_paths = PackedStringArray(["/user/eyes_ext"])
	aset.add_action(act)
	var b := OpenXRIPBinding.new()
	b.action = act
	b.binding_path = "/user/eyes_ext/input/gaze_ext/pose"
	var bindings: Array[OpenXRIPBinding] = [b]
	var prof := OpenXRInteractionProfile.new()
	prof.interaction_profile_path = "/interaction_profiles/ext/eye_gaze_interaction"
	prof.bindings = bindings
	m.add_interaction_profile(prof)
	return true
