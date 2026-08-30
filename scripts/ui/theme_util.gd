class_name ThemeUtil
extends RefCounted


static func panel() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.07, 0.03, 0.12, 0.82)
	s.border_color = Color(0.86, 0.68, 0.28, 0.85)
	s.set_border_width_all(2)
	s.set_corner_radius_all(10)
	s.shadow_color = Color(0.55, 0.22, 0.85, 0.35)
	s.shadow_size = 14
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s


static func style_button(b: Button) -> void:
	var n := StyleBoxFlat.new()
	n.bg_color = Color(0.12, 0.05, 0.2, 0.92)
	n.border_color = Color(0.9, 0.72, 0.32)
	n.set_border_width_all(2)
	n.set_corner_radius_all(8)
	n.content_margin_left = 16
	n.content_margin_right = 16
	var h := n.duplicate()
	h.bg_color = Color(0.22, 0.1, 0.34, 0.95)
	h.border_color = Color(1.0, 0.85, 0.45)
	var p := n.duplicate()
	p.bg_color = Color(0.08, 0.03, 0.12, 0.95)
	b.add_theme_stylebox_override("normal", n)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("pressed", p)
	b.add_theme_stylebox_override("focus", h)
	b.add_theme_font_size_override("font_size", 22)
	b.add_theme_color_override("font_color", Color(0.98, 0.9, 0.7))
	b.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.82))


static func title_label(text: String, size: int = 72) -> Label:
	var t := Label.new()
	t.text = text
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", size)
	t.add_theme_color_override("font_color", Color(0.96, 0.82, 0.42))
	t.add_theme_color_override("font_outline_color", Color(0.42, 0.12, 0.7))
	t.add_theme_constant_override("outline_size", 10)
	return t
