class_name SRS
extends RefCounted

## Kick tables stored with y-down (SRS wiki uses y-up; y signs are flipped).


static func try_rotate(board: Board, piece: Piece, dir: int) -> Dictionary:
	## dir: +1 CW, -1 CCW, +2 for 180. Returns {ok, kick_index} and mutates piece on success.
	if piece.kind == GameConstants.Kind.O and dir != 2:
		var nxt := posmod(piece.rotation + dir, 4)
		var probe := piece.duplicate_piece()
		probe.rotation = nxt
		if not board.collides(probe):
			piece.rotation = nxt
			return {ok = true, kick_index = 0}
		return {ok = false, kick_index = -1}

	var from_r := piece.rotation
	var to_r := posmod(from_r + dir, 4)
	var kicks: Array = _kicks_for(piece.kind, from_r, to_r, dir)
	for i in kicks.size():
		var k: Vector2i = kicks[i]
		var probe := piece.duplicate_piece()
		probe.rotation = to_r
		probe.x += k.x
		probe.y += k.y
		if not board.collides(probe):
			piece.rotation = to_r
			piece.x = probe.x
			piece.y = probe.y
			return {ok = true, kick_index = i}
	return {ok = false, kick_index = -1}


static func _kicks_for(kind: int, from_r: int, to_r: int, dir: int) -> Array:
	if dir == 2 or dir == -2:
		return _kicks_180()
	if kind == GameConstants.Kind.I:
		return _i_kicks(from_r, to_r)
	if kind == GameConstants.Kind.O:
		return [Vector2i(0, 0)]
	return _jlstz_kicks(from_r, to_r)


static func _jlstz_kicks(from_r: int, to_r: int) -> Array:
	var key := "%d>%d" % [from_r, to_r]
	var table := {
		"0>1": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, 2), Vector2i(-1, 2)],
		"1>0": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, -2), Vector2i(1, -2)],
		"1>2": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, -2), Vector2i(1, -2)],
		"2>1": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, 2), Vector2i(-1, 2)],
		"2>3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2)],
		"3>2": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -2), Vector2i(-1, -2)],
		"3>0": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -2), Vector2i(-1, -2)],
		"0>3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2)],
	}
	return table.get(key, [Vector2i(0, 0)])


static func _i_kicks(from_r: int, to_r: int) -> Array:
	var key := "%d>%d" % [from_r, to_r]
	var table := {
		"0>1": [Vector2i(0, 0), Vector2i(-2, 0), Vector2i(1, 0), Vector2i(-2, 1), Vector2i(1, -2)],
		"1>0": [Vector2i(0, 0), Vector2i(2, 0), Vector2i(-1, 0), Vector2i(2, -1), Vector2i(-1, 2)],
		"1>2": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-1, -2), Vector2i(2, 1)],
		"2>1": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(1, 2), Vector2i(-2, -1)],
		"2>3": [Vector2i(0, 0), Vector2i(2, 0), Vector2i(-1, 0), Vector2i(2, -1), Vector2i(-1, 2)],
		"3>2": [Vector2i(0, 0), Vector2i(-2, 0), Vector2i(1, 0), Vector2i(-2, 1), Vector2i(1, -2)],
		"3>0": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(1, 2), Vector2i(-2, -1)],
		"0>3": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-1, -2), Vector2i(2, 1)],
	}
	return table.get(key, [Vector2i(0, 0)])


static func _kicks_180() -> Array:
	return [
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
		Vector2i(1, 1),
		Vector2i(-1, 1),
		Vector2i(1, -1),
		Vector2i(-1, -1),
	]
