class_name ScoreState
extends RefCounted

var score: int = 0
var lines: int = 0
var level: int = 1
var start_level: int = 1
var combo: int = -1
var back_to_back: bool = false
var last_clear_name: String = ""
var last_points: int = 0


func reset(p_start_level: int = 1) -> void:
	score = 0
	lines = 0
	start_level = maxi(p_start_level, 1)
	level = start_level
	combo = -1
	back_to_back = false
	last_clear_name = ""
	last_points = 0


func award_drop(hard: bool, cells: int) -> void:
	if cells <= 0:
		return
	score += cells * (2 if hard else 1)


func award_lock(lines_cleared: int, tspin: String, perfect: bool) -> Dictionary:
	var result := {
		name = "",
		points = 0,
		difficult = false,
		combo = combo,
		b2b = false,
		perfect = perfect,
	}
	if lines_cleared <= 0:
		combo = -1
		if tspin == "full":
			result.name = "T-SPIN"
			result.points = 400 * level
		elif tspin == "mini":
			result.name = "T-SPIN MINI"
			result.points = 100 * level
		score += result.points
		last_clear_name = result.name
		last_points = result.points
		return result

	combo += 1
	var difficult := false
	var name := ""
	var pts := 0

	if tspin == "full":
		difficult = true
		match lines_cleared:
			1:
				name = "T-SPIN SINGLE"
				pts = 800
			2:
				name = "T-SPIN DOUBLE"
				pts = 1200
			3:
				name = "T-SPIN TRIPLE"
				pts = 1600
			_:
				name = "T-SPIN"
				pts = 400
	elif tspin == "mini":
		match lines_cleared:
			1:
				name = "T-SPIN MINI SINGLE"
				pts = 200
				difficult = true
			2:
				name = "T-SPIN MINI DOUBLE"
				pts = 400
				difficult = true
			_:
				name = "T-SPIN MINI"
				pts = 100
	else:
		match lines_cleared:
			1:
				name = "SINGLE"
				pts = 100
			2:
				name = "DOUBLE"
				pts = 300
			3:
				name = "TRIPLE"
				pts = 500
			4:
				name = "TETRIS"
				pts = 800
				difficult = true
			_:
				name = "CLEAR"
				pts = 100 * lines_cleared

	pts *= level
	var used_b2b := false
	if difficult and back_to_back:
		pts = int(round(float(pts) * 1.5))
		used_b2b = true
		name = "B2B " + name

	if combo > 0:
		pts += 50 * combo * level

	if perfect:
		var pc := 0
		match lines_cleared:
			1:
				pc = 800
			2:
				pc = 1200
			3:
				pc = 1800
			4:
				pc = 3200 if used_b2b else 2000
			_:
				pc = 800 * lines_cleared
		pts += pc * level
		name += " PC"

	score += pts
	lines += lines_cleared
	var new_level := start_level + int(lines / float(GameConstants.LINES_PER_LEVEL))
	if new_level > level:
		level = new_level

	if difficult:
		back_to_back = true
	else:
		back_to_back = false

	result.name = name
	result.points = pts
	result.difficult = difficult
	result.combo = combo
	result.b2b = used_b2b
	last_clear_name = name
	last_points = pts
	return result
