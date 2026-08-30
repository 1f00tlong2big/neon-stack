extends Panel

enum Mode { HOLD, NEXT }

@export var mode: Mode = Mode.HOLD

var _tex: Texture2D


func _ready() -> void:
	_tex = load("res://assets/blocks/block.png")
	set_process(true)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if _tex == null:
		_tex = load("res://assets/blocks/block.png")
	var game := get_tree().get_first_node_in_group("neon_game")
	if game == null:
		return
	if mode == Mode.HOLD:
		if game.hold_kind > 0:
			_draw_kind(game.hold_kind, Vector2(size.x * 0.5, 110), 22.0)
	else:
		var q: Array = game.next_queue
		for i in mini(GameConstants.NEXT_COUNT, q.size()):
			_draw_kind(q[i], Vector2(size.x * 0.5, 80 + i * 72), 18.0)


func _draw_kind(kind: int, center: Vector2, cell: float) -> void:
	var cells: Array = GameConstants.cells_of(kind, 0)
	var min_x := 99
	var max_x := -99
	var min_y := 99
	var max_y := -99
	for c in cells:
		min_x = mini(min_x, c.x)
		max_x = maxi(max_x, c.x)
		min_y = mini(min_y, c.y)
		max_y = maxi(max_y, c.y)
	var ox := center.x - (min_x + max_x + 1) * cell * 0.5
	var oy := center.y - (min_y + max_y + 1) * cell * 0.5
	var col := GameConstants.color_for(kind)
	for c in cells:
		var r := Rect2(ox + c.x * cell + 1, oy + c.y * cell + 1, cell - 2, cell - 2)
		if _tex:
			draw_texture_rect(_tex, r, false, col)
		else:
			draw_rect(r, col)
