extends Control
## Aged parchment page with faint construction lines and mirror-written margin notes.

const NOTES := ["il ferro ricorda ogni colpo", "nessuno rimane indietro", "quattro lanterne", "il giuramento"]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)


func _draw() -> void:
	var s = size
	draw_rect(Rect2(Vector2.ZERO, s), GameState.PAPER)
	for i in 14:
		var m = i * 7.0
		draw_rect(Rect2(Vector2(m, m), s - Vector2(m, m) * 2.0), Color(0.45, 0.3, 0.15, 0.035), false, 14.0)
	var rng = RandomNumberGenerator.new()
	rng.seed = 7
	for i in 16:
		var a = Vector2(rng.randf() * s.x, rng.randf() * s.y)
		var b = a + Vector2(rng.randf_range(-320, 320), rng.randf_range(-220, 220))
		draw_line(a, b, Color(0.4, 0.25, 0.12, 0.07), 1.0, true)
	for i in 5:
		var c = Vector2(rng.randf() * s.x, rng.randf() * s.y)
		draw_arc(c, rng.randf_range(40, 160), 0, TAU, 64, Color(0.4, 0.25, 0.12, 0.06), 1.0, true)
	var f = ThemeDB.fallback_font
	for i in NOTES.size():
		var p = Vector2(s.x - 24, 90 + i * (s.y - 160) / (NOTES.size() - 1))
		draw_set_transform(p, -0.04, Vector2(-1, 1))
		draw_string(f, Vector2.ZERO, NOTES[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.35, 0.22, 0.12, 0.22))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
