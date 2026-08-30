extends Control

var music_option: OptionButton
var start_slider: HSlider
var start_value: Label
var master_slider: HSlider
var music_slider: HSlider
var sfx_slider: HSlider
var ghost_check: CheckButton
var file_dialog: FileDialog
var status: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg()
	var title := ThemeUtil.title_label("SETTINGS", 56)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_left = -300
	title.offset_right = 300
	title.offset_top = 48
	title.offset_bottom = 120
	add_child(title)

	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -420
	panel.offset_top = -280
	panel.offset_right = 420
	panel.offset_bottom = 320
	panel.add_theme_stylebox_override("panel", ThemeUtil.panel())
	add_child(panel)

	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 28
	v.offset_top = 20
	v.offset_right = -28
	v.offset_bottom = -20
	v.add_theme_constant_override("separation", 10)
	panel.add_child(v)

	start_slider = _slider_row(v, "Start level", 1, GameConstants.MAX_START_LEVEL, SettingsStore.start_level)
	start_slider.value_changed.connect(_on_start)
	start_value = start_slider.get_meta("value_label")
	start_value.text = str(SettingsStore.start_level)

	master_slider = _slider_row(v, "Master volume", 0, 100, SettingsStore.master_volume * 100.0)
	master_slider.value_changed.connect(func(val): _vol("master", val))
	music_slider = _slider_row(v, "Music volume", 0, 100, SettingsStore.music_volume * 100.0)
	music_slider.value_changed.connect(func(val): _vol("music", val))
	sfx_slider = _slider_row(v, "SFX volume", 0, 100, SettingsStore.sfx_volume * 100.0)
	sfx_slider.value_changed.connect(func(val): _vol("sfx", val))

	ghost_check = CheckButton.new()
	ghost_check.text = "Ghost piece"
	ghost_check.button_pressed = SettingsStore.ghost_enabled
	ghost_check.add_theme_font_size_override("font_size", 20)
	ghost_check.toggled.connect(func(on):
		SettingsStore.ghost_enabled = on
		SettingsStore.save_to_disk()
	)
	v.add_child(ghost_check)

	var music_cap := Label.new()
	music_cap.text = "Custom music  (ogg / mp3 / wav)"
	music_cap.add_theme_font_size_override("font_size", 18)
	music_cap.add_theme_color_override("font_color", Color(0.55, 0.95, 1.0))
	v.add_child(music_cap)

	music_option = OptionButton.new()
	music_option.custom_minimum_size = Vector2(0, 40)
	v.add_child(music_option)
	_rebuild_music_list()
	music_option.item_selected.connect(_on_music_picked)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	v.add_child(row)
	_small_btn(row, "Add music…", _browse)
	_small_btn(row, "Open music folder", func(): MusicLibrary.open_folder())
	_small_btn(row, "Refresh", _rebuild_music_list)

	status = Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size", 14)
	status.add_theme_color_override("font_color", Color(0.75, 0.9, 1.0, 0.85))
	status.text = "Drop tracks into the music folder or use Add music…  Files are copied into your library and loop in-game."
	v.add_child(status)

	var back := Button.new()
	back.text = "BACK"
	back.custom_minimum_size = Vector2(200, 48)
	ThemeUtil.style_button(back)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	v.add_child(back)

	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.use_native_dialog = true
	file_dialog.add_filter("*.ogg,*.mp3,*.wav", "Audio")
	file_dialog.file_selected.connect(_on_file)
	add_child(file_dialog)
	MusicLibrary.library_changed.connect(_rebuild_music_list)


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
	dim.color = Color(0.04, 0.0, 0.08, 0.38)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)


func _slider_row(parent: Node, caption: String, mn: float, mx: float, value: float) -> HSlider:
	var cap := Label.new()
	cap.text = caption
	cap.add_theme_font_size_override("font_size", 18)
	parent.add_child(cap)
	var row := HBoxContainer.new()
	parent.add_child(row)
	var s := HSlider.new()
	s.min_value = mn
	s.max_value = mx
	s.step = 1
	s.value = value
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.custom_minimum_size = Vector2(200, 28)
	row.add_child(s)
	var val := Label.new()
	val.custom_minimum_size = Vector2(48, 0)
	val.text = str(int(value))
	val.add_theme_font_size_override("font_size", 18)
	row.add_child(val)
	s.set_meta("value_label", val)
	s.value_changed.connect(func(v): val.text = str(int(v)))
	return s


func _small_btn(parent: Node, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ThemeUtil.style_button(b)
	b.add_theme_font_size_override("font_size", 16)
	b.custom_minimum_size = Vector2(0, 40)
	b.pressed.connect(cb)
	parent.add_child(b)


func _on_start(val: float) -> void:
	SettingsStore.start_level = clampi(int(val), 1, GameConstants.MAX_START_LEVEL)
	SettingsStore.save_to_disk()


func _vol(which: String, val: float) -> void:
	var lin := clampf(val / 100.0, 0.0, 1.0)
	match which:
		"master":
			SettingsStore.master_volume = lin
		"music":
			SettingsStore.music_volume = lin
		"sfx":
			SettingsStore.sfx_volume = lin
	SettingsStore.apply_volumes()
	SettingsStore.save_to_disk()


func _rebuild_music_list() -> void:
	if music_option == null:
		return
	music_option.clear()
	music_option.add_item("None (silence)")
	music_option.set_item_metadata(0, "")
	var selected := 0
	var tracks := MusicLibrary.list_tracks()
	for i in tracks.size():
		var t: Dictionary = tracks[i]
		music_option.add_item(str(t.display))
		music_option.set_item_metadata(i + 1, str(t.filename))
		if str(t.filename) == SettingsStore.selected_music:
			selected = i + 1
	music_option.select(selected)


func _on_music_picked(index: int) -> void:
	SettingsStore.selected_music = str(music_option.get_item_metadata(index))
	SettingsStore.save_to_disk()
	MusicLibrary.play_selected()


func _browse() -> void:
	MusicLibrary.ensure_library()
	file_dialog.popup_centered_ratio(0.6)


func _on_file(path: String) -> void:
	var name := MusicLibrary.import_file(path)
	if name.is_empty():
		status.text = "Could not add that file. Use .ogg, .mp3, or .wav."
	else:
		status.text = "Added %s — now playing." % name
		_rebuild_music_list()
