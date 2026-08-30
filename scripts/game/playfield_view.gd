extends Node2D

const ORIGIN := Vector2(800, 168)
const SLIVER := 10

var block_tex: Texture2D
var ghost_tex: Texture2D

@onready var game: Node2D = get_parent()


func _ready() -> void:
	block_tex = load("res://assets/blocks/block.png")
	ghost_tex = load("res://assets/blocks/ghost.png")
	if game.has_signal("line_cleared"):
		game.line_cleared.connect(_on_lines)


func _process(_delta: float) -> void:
	queue_redraw()
	var s: float = game.shake
	position = Vector2(randf_range(-s, s) * 8.0, randf_range(-s, s) * 8.0)


func _draw() -> void:
	var w := GameConstants.WIDTH * GameConstants.CELL
	var h := GameConstants.VISIBLE_ROWS * GameConstants.CELL
	var rect := Rect2(ORIGIN, Vector2(w, h))
	draw_rect(rect, Color(0.05, 0.02, 0.1, 0.78))
	draw_rect(Rect2(ORIGIN.x, ORIGIN.y - SLIVER, w, SLIVER), Color(0.05, 0.02, 0.1, 0.45))

	var grid_c := Color(0.72, 0.48, 1.0, 0.1)
	for x in GameConstants.WIDTH + 1:
		var px := ORIGIN.x + x * GameConstants.CELL
		draw_line(Vector2(px, ORIGIN.y), Vector2(px, ORIGIN.y + h), grid_c, 1.0)
	for y in GameConstants.VISIBLE_ROWS + 1:
		var py := ORIGIN.y + y * GameConstants.CELL
		draw_line(Vector2(ORIGIN.x, py), Vector2(ORIGIN.x + w, py), grid_c, 1.0)
	draw_rect(rect.grow(6), Color(0.42, 0.16, 0.62, 0.95), false, 6.0)
	draw_rect(rect.grow(9), Color(0.9, 0.72, 0.32, 0.65), false, 2.0)
	draw_rect(rect, Color(0.9, 0.72, 0.32, 0.7), false, 2.0)

	if game.board == null:
		return
	for y in range(GameConstants.VISIBLE_START - 1, GameConstants.HEIGHT):
		for x in GameConstants.WIDTH:
			var kind: int = game.board.get_kind(x, y)
			if kind == GameConstants.Kind.EMPTY:
				continue
			_draw_cell(x, y, GameConstants.color_for(kind), false, y in game.flash_rows)

	if SettingsStore.ghost_enabled and game.current != null and game.state != game.State.GAME_OVER:
		var ghost: Piece = game.ghost_piece()
		if ghost and ghost.y != game.current.y:
			for c in ghost.cells():
				_draw_cell(c.x, c.y, GameConstants.color_for(ghost.kind), true, false)

	if game.current != null and game.state != game.State.GAME_OVER:
		for c in game.current.cells():
			_draw_cell(c.x, c.y, GameConstants.color_for(game.current.kind), false, false)


func _draw_cell(x: int, y: int, color: Color, ghost: bool, flash: bool) -> void:
	var px := ORIGIN.x + x * GameConstants.CELL
	var py := ORIGIN.y + (y - GameConstants.VISIBLE_START) * GameConstants.CELL
	if y == GameConstants.VISIBLE_START - 1:
		py = ORIGIN.y - SLIVER
	var size := GameConstants.CELL
	if y < GameConstants.VISIBLE_START - 1:
		return
	if flash:
		color = Color(1, 1, 1)
	var dest := Rect2(px + 1, py + 1, size - 2, size - 2)
	if y == GameConstants.VISIBLE_START - 1:
		dest = Rect2(px + 1, ORIGIN.y - SLIVER, size - 2, SLIVER)
	var tex := ghost_tex if ghost else block_tex
	if tex:
		var col := color
		if ghost:
			col.a = 0.35
		draw_texture_rect(tex, dest, false, col)
	else:
		draw_rect(dest, color if not ghost else Color(color.r, color.g, color.b, 0.3))


func _on_lines(rows: Array, _name: String, tetris: bool) -> void:
	var spark: Texture2D = load("res://assets/particles/spark.png")
	for y in rows:
		var p := CPUParticles2D.new()
		p.texture = spark
		p.one_shot = true
		p.explosiveness = 0.95
		p.amount = 28 if tetris else 16
		p.lifetime = 0.45
		p.emitting = true
		p.position = ORIGIN + Vector2(GameConstants.WIDTH * GameConstants.CELL * 0.5, (y - GameConstants.VISIBLE_START + 0.5) * GameConstants.CELL)
		p.direction = Vector2(0, -1)
		p.spread = 180
		p.initial_velocity_min = 40
		p.initial_velocity_max = 160
		p.gravity = Vector2(0, 220)
		p.scale_amount_min = 0.4
		p.scale_amount_max = 1.1
		add_child(p)
		get_tree().create_timer(0.7).timeout.connect(p.queue_free)
