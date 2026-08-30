class_name Piece
extends RefCounted

var kind: int
var rotation: int
var x: int
var y: int


func _init(p_kind: int = GameConstants.Kind.I, p_rot: int = 0, p_x: int = GameConstants.SPAWN_X, p_y: int = GameConstants.SPAWN_Y) -> void:
	kind = p_kind
	rotation = p_rot
	x = p_x
	y = p_y


func duplicate_piece() -> Piece:
	return Piece.new(kind, rotation, x, y)


func cells() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for c in GameConstants.cells_of(kind, rotation):
		out.append(Vector2i(x + c.x, y + c.y))
	return out


func min_y() -> int:
	var m := 999
	for c in cells():
		if c.y < m:
			m = c.y
	return m


func max_y() -> int:
	var m := -999
	for c in cells():
		if c.y > m:
			m = c.y
	return m
