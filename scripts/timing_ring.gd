extends Control
## Timed-action prompt: a ring closes on a circle; tap when they meet.

signal resolved(result)

const TARGET_T := 0.8
const END_T := 1.15
const R := 44.0

var center = Vector2.ZERO
var prompt = ""
var col = Color.RED
var t = 0.0
var done = false
var result = ""


func start(c: Vector2, p: String, color: Color) -> void:
	center = c
	prompt = p
	col = color


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(delta: float) -> void:
	if not done:
		t += delta
		if t >= END_T:
			_finish("miss")
	queue_redraw()


func _gui_input(e: InputEvent) -> void:
	if not done and e is InputEventMouseButton and e.pressed:
		_judge()
		accept_event()


func _input(e: InputEvent) -> void:
	if not done and e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_SPACE:
		_judge()
		get_viewport().set_input_as_handled()


func _judge() -> void:
	var dt = absf(t - TARGET_T)
	if dt < 0.08:
		_finish("perfect")
	elif dt < 0.2:
		_finish("good")
	else:
		_finish("miss")


func _finish(r: String) -> void:
	done = true
	result = r
	queue_redraw()
	await get_tree().create_timer(0.35).timeout
	resolved.emit(r)
	queue_free()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.2, 0.12, 0.05, 0.16))
	draw_circle(center, R, Color(GameState.PAPER, 0.45))
	draw_arc(center, R, 0, TAU, 48, GameState.INK, 3.0, true)
	var f = ThemeDB.fallback_font
	if not done:
		var r = R * 3.0 - R * 2.0 * (t / TARGET_T)
		if r > 2.0:
			draw_arc(center, r, 0, TAU, 64, col, 6.0, true)
		draw_string(f, center + Vector2(-220, R + 46), prompt, HORIZONTAL_ALIGNMENT_CENTER, 440, 30, col)
	else:
		var txt = {"perfect": "PERFECT!", "good": "GOOD", "miss": "MISS"}[result]
		var c = {"perfect": GameState.GOLD, "good": GameState.SAGE, "miss": GameState.INK}[result]
		draw_string(f, center + Vector2(-150, 10), txt, HORIZONTAL_ALIGNMENT_CENTER, 300, 30, c)
