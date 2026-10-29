class_name FrameInput
extends RefCounted
## Steam Frame controller model. Left: thumbstick, D-pad, View, bumper, trigger, grip.
## Right: thumbstick, A/B/X/Y, Menu, bumper, trigger, grip.
## Every incoming OpenXR action name (Frame profile actions "frame_*", or the generic/Touch names used
## when SteamVR falls back to a Touch layout) is normalised to one canonical button name.

const BUTTONS := {
	"trigger": "Trigger", "bumper": "Bumper", "grip": "Grip", "stick": "Stick click",
	"a": "A", "b": "B", "x": "X", "y": "Y",
	"dpad_up": "D-pad Up", "dpad_down": "D-pad Down", "dpad_left": "D-pad Left", "dpad_right": "D-pad Right",
	"view": "View/Menu",
}
const SHORT := {
	"trigger": "Trig", "bumper": "Bump", "grip": "Grip", "stick": "Stick",
	"a": "A", "b": "B", "x": "X", "y": "Y",
	"dpad_up": "D-Up", "dpad_down": "D-Down", "dpad_left": "D-Left", "dpad_right": "D-Right",
	"view": "View",
}
const FRAME_ACTIONS := {
	"frame_trigger": "trigger", "frame_bumper": "bumper", "frame_grip": "grip", "frame_stick": "stick",
	"frame_a": "a", "frame_b": "b", "frame_x": "x", "frame_y": "y",
	"frame_dpad_up": "dpad_up", "frame_dpad_down": "dpad_down", "frame_dpad_left": "dpad_left", "frame_dpad_right": "dpad_right",
	"frame_view": "view", "frame_menu": "view",
}
const LEFT_BUTTONS := ["trigger", "bumper", "grip", "stick", "dpad_up", "dpad_down", "dpad_left", "dpad_right", "view"]
const RIGHT_BUTTONS := ["trigger", "bumper", "grip", "stick", "a", "b", "x", "y", "view"]

## side = physical controller, "left" or "right".
static func canon(btn: String, side: String) -> String:
	if FRAME_ACTIONS.has(btn):
		return FRAME_ACTIONS[btn]
	match btn:
		"trigger_click":
			return "trigger"
		"grip_click":
			return "grip"
		"primary_click":
			return "stick"
		"menu_button", "select_button":
			return "view"
		"ax_button":
			return "a" if side == "right" else "dpad_down"
		"by_button":
			return "b" if side == "right" else "dpad_up"
	return ""

## All OpenXR action names that can mean this canonical button on this controller.
static func action_names(cn: String, side: String) -> Array:
	var out := []
	for k in FRAME_ACTIONS:
		if FRAME_ACTIONS[k] == cn:
			out.append(k)
	match cn:
		"trigger":
			out.append("trigger_click")
		"grip":
			out.append("grip_click")
		"stick":
			out.append("primary_click")
		"view":
			out.append("menu_button")
		"a":
			if side == "right":
				out.append("ax_button")
		"b":
			if side == "right":
				out.append("by_button")
		"dpad_down":
			if side == "left":
				out.append("ax_button")
		"dpad_up":
			if side == "left":
				out.append("by_button")
	return out

static func short(cn: String) -> String:
	return str(SHORT.get(cn, cn))

static func has(side: String, cn: String) -> bool:
	if side == "left":
		return cn in LEFT_BUTTONS
	return cn in RIGHT_BUTTONS

static func _b(hand: String, btn: String) -> Dictionary:
	return {"hand": hand, "btn": btn}

## Default layout. dom = which controller holds the gun ("right" = ABXY side, "left" = D-pad side).
static func defaults(dom: String) -> Dictionary:
	if dom == "right":
		return {
			"fire": _b("gun", "trigger"), "holster": _b("gun", "grip"),
			"drop_mag": _b("gun", "a"), "slide_release": _b("gun", "b"),
			"next_optic": _b("gun", "x"), "next_gun": _b("gun", "y"), "ammo_check": _b("gun", "bumper"),
			"grab": _b("off", "grip"), "timer": _b("off", "dpad_up"), "recenter": _b("off", "dpad_down"),
			"drill_prev": _b("off", "dpad_left"), "drill_next": _b("off", "dpad_right"),
			"target_reset": _b("off", "trigger"), "reticle": _b("off", "bumper"), "menu": _b("off", "view"),
		}
	return {
		"fire": _b("gun", "trigger"), "holster": _b("gun", "grip"),
		"drop_mag": _b("gun", "dpad_left"), "slide_release": _b("gun", "dpad_right"),
		"next_optic": _b("gun", "dpad_up"), "next_gun": _b("gun", "dpad_down"), "ammo_check": _b("gun", "bumper"),
		"grab": _b("off", "grip"), "timer": _b("off", "a"), "recenter": _b("off", "b"),
		"drill_prev": _b("off", "x"), "drill_next": _b("off", "y"),
		"target_reset": _b("off", "trigger"), "reticle": _b("off", "bumper"), "menu": _b("gun", "view"),
	}
