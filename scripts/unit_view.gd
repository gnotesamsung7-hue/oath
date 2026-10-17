extends Control
## A hero or enemy drawn as a red-chalk / ink figure with HP and morale bars.

signal tapped(unit)

var u = null
var active = false
var targetable = false
var flash = 0.0


func _init(unit = null) -> void:
	u = unit
	size = Vector2(140, 178)
	custom_minimum_size = size


func _gui_input(e: InputEvent) -> void:
	if targetable and e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		tapped.emit(u)
		accept_event()


func _process(delta: float) -> void:
	if flash > 0.0:
		flash = maxf(0.0, flash - delta * 2.5)
	queue_redraw()


func _draw() -> void:
	var hero: bool = u.side == "hero"
	var f = 1.0 if hero else -1.0
	var base: Color = GameState.SANGUINE if hero else GameState.INK
	var col: Color = base.lerp(GameState.GOLD, flash)
	if not u.alive:
		col = Color(base, 0.3)
	var font = ThemeDB.fallback_font

	draw_set_transform(Vector2(70, 142), 0.0, Vector2(1.0, 0.22))
	draw_circle(Vector2.ZERO, 46, Color(GameState.INK, 0.12))
	if active:
		draw_arc(Vector2.ZERO, 56, 0, TAU, 48, GameState.GOLD, 10.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	if targetable:
		var pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 140.0)
		draw_rect(Rect2(2, 16, 136, 128), Color(GameState.GOLD, 0.35 + 0.5 * pulse), false, 3.0)

	if not u.alive:
		draw_line(Vector2(30, 136), Vector2(100, 136), col, 3.0, true)
		draw_arc(Vector2(112, 132), 10, 0, TAU, 24, col, 3.0, true)
	else:
		var tilt = -0.3 * f if u.broken else 0.0
		var sc = 1.12 if u.kind == "brute" else 1.0
		draw_set_transform(Vector2(70, 140), tilt, Vector2(sc, sc))
		_figure(col, f)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	draw_string(font, Vector2(0, 13), u.name, HORIZONTAL_ALIGNMENT_CENTER, 140, 17, GameState.INK)
	var r = Rect2(10, 148, 120, 10)
	draw_rect(r, Color(GameState.INK, 0.12))
	draw_rect(Rect2(r.position, Vector2(r.size.x * clampf(u.hp / u.max_hp, 0.0, 1.0), r.size.y)), GameState.SAGE if hero else GameState.SANGUINE)
	draw_rect(r, GameState.INK, false, 1.5)
	draw_string(font, Vector2(10, 174), "%d/%d" % [u.hp, u.max_hp], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, GameState.INK)
	if not hero:
		var m = Rect2(72, 164, 58, 7)
		draw_rect(m, Color(GameState.INK, 0.12))
		draw_rect(Rect2(m.position, Vector2(m.size.x * clampf(u.morale / u.max_morale, 0.0, 1.0), m.size.y)), GameState.GOLD)
		draw_rect(m, GameState.INK, false, 1.0)
	if u.broken:
		draw_string(font, Vector2(0, 32), "BROKEN", HORIZONTAL_ALIGNMENT_CENTER, 140, 17, GameState.SANGUINE)
	elif u.guard:
		draw_string(font, Vector2(0, 32), "GUARD", HORIZONTAL_ALIGNMENT_CENTER, 140, 17, GameState.SAGE)


func _figure(c: Color, f: float) -> void:
	var w = 3.0
	draw_arc(Vector2(0, -100), 12, 0, TAU, 28, c, w, true)
	draw_line(Vector2(0, -88), Vector2(0, -42), c, w, true)
	draw_line(Vector2(0, -42), Vector2(-12, 0), c, w, true)
	draw_line(Vector2(0, -42), Vector2(12, 0), c, w, true)
	match u.kind:
		"mark":
			draw_line(Vector2(0, -78), Vector2(18 * f, -64), c, w, true)
			var sh = PackedVector2Array([Vector2(16 * f, -92), Vector2(40 * f, -92), Vector2(40 * f, -50), Vector2(28 * f, -38), Vector2(16 * f, -50), Vector2(16 * f, -92)])
			draw_colored_polygon(sh, Color(GameState.PAPER_DARK, 0.9))
			draw_polyline(sh, c, w, true)
			draw_line(Vector2(0, -78), Vector2(-16 * f, -60), c, w, true)
			draw_line(Vector2(-16 * f, -60), Vector2(-26 * f, -92), c, w, true)
			draw_circle(Vector2(-26 * f, -96), 6, c)
		"jhona":
			draw_line(Vector2(0, -78), Vector2(20 * f, -66), c, w, true)
			draw_line(Vector2(0, -78), Vector2(-14 * f, -62), c, w, true)
			draw_line(Vector2(20 * f, -66), Vector2(46 * f, -88), c, 2.0, true)
			draw_line(Vector2(-14 * f, -62), Vector2(14 * f, -50), c, 2.0, true)
		"nelson":
			draw_line(Vector2(22 * f, -124), Vector2(22 * f, 0), c, w, true)
			draw_circle(Vector2(22 * f, -128), 6, GameState.GOLD)
			draw_line(Vector2(0, -78), Vector2(22 * f, -72), c, w, true)
			draw_line(Vector2(0, -78), Vector2(-14 * f, -60), c, w, true)
		"rachel":
			draw_line(Vector2(0, -78), Vector2(30 * f, -76), c, w, true)
			draw_line(Vector2(0, -78), Vector2(16 * f, -70), c, w, true)
			draw_line(Vector2(6 * f, -76), Vector2(40 * f, -76), c, w, true)
			var a0 = -PI / 2 if f > 0 else PI / 2
			draw_arc(Vector2(40 * f, -76), 14, a0, a0 + PI, 16, c, 2.0, true)
		"raider":
			draw_line(Vector2(-15, -106), Vector2(15, -106), c, 4.0, true)
			draw_line(Vector2(0, -78), Vector2(20 * f, -70), c, w, true)
			draw_line(Vector2(18 * f, -10), Vector2(30 * f, -134), c, 2.0, true)
			draw_line(Vector2(30 * f, -134), Vector2(26 * f, -122), GameState.SANGUINE, 3.0, true)
		"brute":
			draw_line(Vector2(-16, -106), Vector2(16, -106), c, 5.0, true)
			draw_line(Vector2(0, -78), Vector2(22 * f, -66), c, w, true)
			draw_line(Vector2(16 * f, -54), Vector2(32 * f, -120), c, w, true)
			draw_colored_polygon(PackedVector2Array([Vector2(28 * f, -124), Vector2(48 * f, -132), Vector2(44 * f, -104), Vector2(30 * f, -108)]), c)
		"sergeant":
			draw_line(Vector2(-15, -106), Vector2(15, -106), c, 4.0, true)
			draw_arc(Vector2(0, -114), 9, PI, TAU, 12, GameState.SANGUINE, 3.0, true)
			draw_polyline(PackedVector2Array([Vector2(0, -86), Vector2(-24 * f, -60), Vector2(-20 * f, -30)]), Color(c, 0.6), 2.0, true)
			draw_line(Vector2(0, -78), Vector2(20 * f, -68), c, w, true)
			draw_line(Vector2(20 * f, -68), Vector2(48 * f, -102), c, 2.5, true)
