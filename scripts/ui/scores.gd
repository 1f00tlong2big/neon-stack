extends Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var tex := load("res://assets/bg/menu.jpg")
	var r := TextureRect.new()
	r.texture = tex
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(r)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.04, 0.0, 0.08, 0.38)
	add_child(dim)

	var title := ThemeUtil.title_label("HIGH SCORES", 56)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_left = -400
	title.offset_right = 400
	title.offset_top = 60
	title.offset_bottom = 130
	add_child(title)

	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -360
	panel.offset_top = -240
	panel.offset_right = 360
	panel.offset_bottom = 260
	panel.add_theme_stylebox_override("panel", ThemeUtil.panel())
	add_child(panel)

	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 24
	v.offset_top = 16
	v.offset_right = -24
	v.offset_bottom = -16
	v.add_theme_constant_override("separation", 8)
	panel.add_child(v)

	if HighScores.entries.is_empty():
		var empty := Label.new()
		empty.text = "No scores yet. Survive a marathon."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_theme_font_size_override("font_size", 20)
		v.add_child(empty)
	else:
		for i in HighScores.entries.size():
			var e: Dictionary = HighScores.entries[i]
			var row := Label.new()
			row.text = "%2d.  %8d    L%s    %s lines" % [i + 1, int(e.score), str(e.level), str(e.lines)]
			row.add_theme_font_size_override("font_size", 22)
			row.add_theme_color_override("font_color", Color(0.96, 0.88, 0.7))
			v.add_child(row)

	var back := Button.new()
	back.text = "BACK"
	back.custom_minimum_size = Vector2(200, 48)
	ThemeUtil.style_button(back)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	v.add_child(back)
