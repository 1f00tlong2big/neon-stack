extends Node


func _ready() -> void:
	_bind("move_left", [KEY_LEFT])
	_bind("move_right", [KEY_RIGHT])
	_bind("soft_drop", [KEY_DOWN])
	_bind("hard_drop", [KEY_SPACE])
	_bind("rotate_cw", [KEY_UP, KEY_X])
	_bind("rotate_ccw", [KEY_Z, KEY_CTRL])
	_bind("rotate_180", [KEY_A])
	_bind("hold", [KEY_C, KEY_SHIFT])
	_bind("pause", [KEY_ESCAPE])
	_bind("ui_accept", [KEY_ENTER, KEY_SPACE])
	_bind("ui_cancel", [KEY_ESCAPE])


func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for keycode in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = keycode
		if not InputMap.action_has_event(action, ev):
			InputMap.action_add_event(action, ev)
