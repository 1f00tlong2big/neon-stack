class_name GameConstants
extends RefCounted

## Row 0 is the TOP of the 40-row matrix.
## Rows 0-19 are the hidden buffer (a sliver of row 19 is drawn).
## Rows 20-39 are the visible 10x20 playfield.

const WIDTH := 10
const HEIGHT := 40
const VISIBLE_ROWS := 20
const VISIBLE_START := 20
const CELL := 32
const SPAWN_X := 3
const SPAWN_Y := 18
const NEXT_COUNT := 5

const DAS := 0.167
const ARR := 0.033
const LOCK_DELAY := 0.5
const LOCK_RESET_LIMIT := 15
const LINE_CLEAR_TIME := 0.35
const ARE_TIME := 0.10
const LINES_PER_LEVEL := 10
const SOFT_DROP_FACTOR := 20.0
const MAX_START_LEVEL := 10

enum Kind { EMPTY, I, O, T, S, Z, J, L }

const KIND_ORDER: Array[int] = [Kind.I, Kind.O, Kind.T, Kind.S, Kind.Z, Kind.J, Kind.L]

const KIND_NAMES: Array[String] = ["", "I", "O", "T", "S", "Z", "J", "L"]

## Crystal tints (modulate the faceted mino).
static func color_for(kind: int) -> Color:
	match kind:
		Kind.I:
			return Color(0.45, 0.95, 1.0)
		Kind.O:
			return Color(1.0, 0.88, 0.4)
		Kind.T:
			return Color(0.82, 0.45, 1.0)
		Kind.S:
			return Color(0.4, 1.0, 0.62)
		Kind.Z:
			return Color(1.0, 0.38, 0.55)
		Kind.J:
			return Color(0.4, 0.55, 1.0)
		Kind.L:
			return Color(1.0, 0.62, 0.28)
		_:
			return Color.WHITE


## Four SRS rotation states per kind. Cells are (x, y) in the 4x4 box, y down.
static func shapes() -> Dictionary:
	return {
		Kind.I: [
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
			[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)],
			[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)],
		],
		Kind.O: [
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
		],
		Kind.T: [
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
		],
		Kind.S: [
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
			[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)],
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
		],
		Kind.Z: [
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)],
		],
		Kind.J: [
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)],
		],
		Kind.L: [
			[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)],
		],
	}


static func cells_of(kind: int, rotation: int) -> Array:
	var all: Dictionary = shapes()
	var states: Array = all[kind]
	return states[posmod(rotation, 4)]
