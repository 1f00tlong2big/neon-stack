class_name InputRepeat
extends RefCounted

var dir: int = 0
var das_timer: float = 0.0
var arr_timer: float = 0.0
var charged: bool = false


func reset() -> void:
	dir = 0
	das_timer = 0.0
	arr_timer = 0.0
	charged = false


func ticks(delta: float, left_held: bool, right_held: bool, left_just: bool, right_just: bool) -> int:
	var wanted := 0
	if left_just and not right_just:
		wanted = -1
	elif right_just and not left_just:
		wanted = 1
	elif left_held and right_held:
		wanted = dir if dir != 0 else 0
	elif left_held:
		wanted = -1
	elif right_held:
		wanted = 1

	if wanted == 0:
		reset()
		return 0

	if wanted != dir or left_just or right_just:
		dir = wanted
		das_timer = 0.0
		arr_timer = 0.0
		charged = false
		return dir

	if not charged:
		das_timer += delta
		if das_timer >= GameConstants.DAS:
			charged = true
			arr_timer = 0.0
			return dir
		return 0

	arr_timer += delta
	var steps := 0
	while arr_timer >= GameConstants.ARR:
		arr_timer -= GameConstants.ARR
		steps += 1
		if steps >= GameConstants.WIDTH:
			break
	return dir * steps
