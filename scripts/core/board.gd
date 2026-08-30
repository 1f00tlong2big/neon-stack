class_name Board
extends RefCounted

var cells: Array = [] ## HEIGHT arrays of WIDTH ints (Kind)


func _init() -> void:
	clear()


func clear() -> void:
	cells.clear()
	for _y in GameConstants.HEIGHT:
		var row: Array[int] = []
		row.resize(GameConstants.WIDTH)
		row.fill(GameConstants.Kind.EMPTY)
		cells.append(row)


func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < GameConstants.WIDTH and y >= 0 and y < GameConstants.HEIGHT


func occupied(x: int, y: int) -> bool:
	if x < 0 or x >= GameConstants.WIDTH:
		return true
	if y < 0 or y >= GameConstants.HEIGHT:
		return true
	return cells[y][x] != GameConstants.Kind.EMPTY


func get_kind(x: int, y: int) -> int:
	if not in_bounds(x, y):
		return GameConstants.Kind.EMPTY
	return cells[y][x]


func collides(piece: Piece) -> bool:
	for c in piece.cells():
		if occupied(c.x, c.y):
			return true
	return false


func lock_piece(piece: Piece) -> void:
	for c in piece.cells():
		if in_bounds(c.x, c.y):
			cells[c.y][c.x] = piece.kind


func full_rows() -> Array[int]:
	var rows: Array[int] = []
	for y in GameConstants.HEIGHT:
		var full := true
		for x in GameConstants.WIDTH:
			if cells[y][x] == GameConstants.Kind.EMPTY:
				full = false
				break
		if full:
			rows.append(y)
	return rows


func clear_rows(rows: Array[int]) -> void:
	if rows.is_empty():
		return
	var remove: Dictionary = {}
	for y in rows:
		remove[y] = true
	var kept: Array = []
	for y in GameConstants.HEIGHT:
		if not remove.has(y):
			kept.append(cells[y])
	var missing := GameConstants.HEIGHT - kept.size()
	cells.clear()
	for _i in missing:
		var row: Array[int] = []
		row.resize(GameConstants.WIDTH)
		row.fill(GameConstants.Kind.EMPTY)
		cells.append(row)
	for row in kept:
		cells.append(row)


func is_perfect_clear() -> bool:
	for y in GameConstants.HEIGHT:
		for x in GameConstants.WIDTH:
			if cells[y][x] != GameConstants.Kind.EMPTY:
				return false
	return true


func locked_above_visible(piece: Piece) -> bool:
	for c in piece.cells():
		if c.y >= GameConstants.VISIBLE_START:
			return false
	return true
