extends Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg()
	var title := ThemeUtil.title_label("NEON STACK", 84)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_left = -420
	title.offset_right = 420
	title.offset_top = 140
	title.offset_bottom = 240
	add_child(title)
	var sub := Label.new()
	sub.text = "a guideline-style marathon"
	sub.set_anchors_preset(Control.PRESET_CENTER_TOP)
	sub.offset_left = -300
	sub.offset_right = 300
	sub.offset_top = 230
	sub.offset_bottom = 270
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 20)
	sub.add_theme_color_override("font_color", Color(0.75, 0.55, 1.0, 0.95))
	add_child(sub)

	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.offset_left = -160
	col.offset_right = 160
	col.offset_top = -20
	col.offset_bottom = 280
	col.add_theme_constant_override("separation", 16)
	add_child(col)
	_menu_btn(col, "PLAY", func(): get_tree().change_scene_to_file("res://scenes/game.tscn"))
	_menu_btn(col, "SETTINGS", func(): get_tree().change_scene_to_file("res://scenes/settings.tscn"))
	_menu_btn(col, "SCORES", func(): get_tree().change_scene_to_file("res://scenes/scores.tscn"))
	_menu_btn(col, "QUIT", func(): get_tree().quit())
	var hint := Label.new()
	hint.text = "Add your own music in Settings"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color(0.9, 0.75, 0.45, 0.85))
	col.add_child(hint)
	MusicLibrary.play_selected()


func _bg() -> void:
	var tex := load("res://assets/bg/menu.jpg")
	var r := TextureRect.new()
	r.texture = tex
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.04, 0.0, 0.08, 0.18)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)


func _menu_btn(parent: Node, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 56)
	ThemeUtil.style_button(b)
	b.pressed.connect(cb)
	parent.add_child(b)
