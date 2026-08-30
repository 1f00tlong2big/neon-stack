extends CanvasLayer

@onready var game: Node2D = get_parent()

var hold_label: Label
var next_labels: Array[Label] = []
var score_label: Label
var lines_label: Label
var level_label: Label
var toast_label: Label
var pause_panel: Control
var over_panel: Control
var over_score: Label
var next_draw: Control
var hold_draw: Control


func _ready() -> void:
	_build()
	game.stats_changed.connect(_refresh)
	game.topped_out.connect(_on_over)
	game.paused_changed.connect(_on_paused)
	_refresh()


func _build() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	hold_draw = _side_panel(root, Vector2(520, 168), Vector2(220, 180), "HOLD")
	next_draw = _side_panel(root, Vector2(1180, 168), Vector2(220, 420), "NEXT")
	var preview_script := load("res://scripts/game/preview_draw.gd")
	hold_draw.set_script(preview_script)
	hold_draw.mode = 0
	hold_draw.set_process(true)
	next_draw.set_script(preview_script)
	next_draw.mode = 1
	next_draw.set_process(true)
	var stats := _side_panel(root, Vector2(520, 380), Vector2(220, 280), "STATS")
	score_label = _stat(stats, "SCORE", 48)
	lines_label = _stat(stats, "LINES", 120)
	level_label = _stat(stats, "LEVEL", 192)

	toast_label = Label.new()
	toast_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast_label.offset_top = 80
	toast_label.offset_left = -400
	toast_label.offset_right = 400
	toast_label.offset_bottom = 140
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 36)
	toast_label.add_theme_color_override("font_color", Color(0.98, 0.86, 0.5))
	toast_label.add_theme_color_override("font_outline_color", Color(0.4, 0.12, 0.7))
	toast_label.add_theme_constant_override("outline_size", 6)
	root.add_child(toast_label)

	var help := Label.new()
	help.text = "← → move   ↓ soft   space hard   Z/X rotate   A 180   C hold   Esc pause"
	help.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	help.offset_left = -600
	help.offset_right = 600
	help.offset_top = -48
	help.offset_bottom = -16
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help.add_theme_font_size_override("font_size", 16)
	help.add_theme_color_override("font_color", Color(0.92, 0.8, 0.55, 0.75))
	root.add_child(help)

	pause_panel = _overlay(root, "PAUSED", true)
	pause_panel.visible = false
	over_panel = _overlay(root, "TOP OUT", false)
	over_panel.visible = false


func _side_panel(parent: Control, pos: Vector2, size: Vector2, title: String) -> Control:
	var p := Panel.new()
	p.position = pos
	p.size = size
	p.add_theme_stylebox_override("panel", _panel_style())
	parent.add_child(p)
	var t := Label.new()
	t.text = title
	t.position = Vector2(16, 10)
	t.size = Vector2(size.x - 32, 28)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 18)
	t.add_theme_color_override("font_color", Color(0.95, 0.8, 0.42))
	p.add_child(t)
	return p


func _stat(parent: Control, title: String, y: int) -> Label:
	var cap := Label.new()
	cap.text = title
	cap.position = Vector2(16, y)
	cap.size = Vector2(188, 22)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.add_theme_font_size_override("font_size", 14)
	cap.add_theme_color_override("font_color", Color(0.6, 0.75, 0.95, 0.8))
	parent.add_child(cap)
	var v := Label.new()
	v.position = Vector2(16, y + 22)
	v.size = Vector2(188, 36)
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_theme_font_size_override("font_size", 28)
	v.add_theme_color_override("font_color", Color(0.95, 1.0, 1.0))
	parent.add_child(v)
	return v


func _panel_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.07, 0.03, 0.12, 0.8)
	s.border_color = Color(0.88, 0.7, 0.3, 0.75)
	s.set_border_width_all(2)
	s.set_corner_radius_all(8)
	s.shadow_color = Color(0.55, 0.22, 0.85, 0.28)
	s.shadow_size = 8
	return s


func _overlay(parent: Control, title: String, is_pause: bool) -> Control:
	var wrap := ColorRect.new()
	wrap.set_anchors_preset(Control.PRESET_FULL_RECT)
	wrap.color = Color(0, 0, 0, 0.55)
	parent.add_child(wrap)
	var box := Panel.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -220
	box.offset_top = -180
	box.offset_right = 220
	box.offset_bottom = 180
	box.add_theme_stylebox_override("panel", _panel_style())
	wrap.add_child(box)
	var t := Label.new()
	t.text = title
	t.position = Vector2(20, 24)
	t.size = Vector2(400, 48)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 40)
	t.add_theme_color_override("font_color", Color(0.96, 0.82, 0.42))
	box.add_child(t)
	if is_pause:
		_btn(box, "RESUME", Vector2(90, 120), game.request_unpause)
		_btn(box, "MENU", Vector2(90, 200), game.request_menu)
	else:
		over_score = Label.new()
		over_score.position = Vector2(20, 80)
		over_score.size = Vector2(400, 40)
		over_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		over_score.add_theme_font_size_override("font_size", 22)
		box.add_child(over_score)
		_btn(box, "RETRY", Vector2(90, 140), game.request_restart)
		_btn(box, "MENU", Vector2(90, 210), game.request_menu)
	return wrap


func _btn(parent: Control, text: String, pos: Vector2, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = Vector2(260, 52)
	_style_button(b)
	b.pressed.connect(cb)
	parent.add_child(b)


func _style_button(b: Button) -> void:
	var n := StyleBoxFlat.new()
	n.bg_color = Color(0.12, 0.05, 0.2, 0.95)
	n.border_color = Color(0.9, 0.72, 0.32)
	n.set_border_width_all(2)
	n.set_corner_radius_all(6)
	var h := n.duplicate()
	h.bg_color = Color(0.22, 0.1, 0.34, 0.95)
	h.border_color = Color(1.0, 0.85, 0.45)
	b.add_theme_stylebox_override("normal", n)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("pressed", h)
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", Color(0.98, 0.9, 0.7))


func _refresh() -> void:
	if score_label == null:
		return
	score_label.text = "%d" % game.scores.score
	lines_label.text = "%d" % game.scores.lines
	level_label.text = "%d" % game.scores.level
	toast_label.text = game.toast
	hold_draw.queue_redraw()
	next_draw.queue_redraw()


func _process(_delta: float) -> void:
	toast_label.text = game.toast
	hold_draw.queue_redraw()
	next_draw.queue_redraw()


func _on_paused(paused: bool) -> void:
	pause_panel.visible = paused


func _on_over() -> void:
	over_score.text = "SCORE  %d    LINES  %d" % [game.scores.score, game.scores.lines]
	over_panel.visible = true
