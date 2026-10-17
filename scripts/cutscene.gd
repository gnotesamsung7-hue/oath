extends Control
## Notebook-page cutscenes: the drawing inks itself in while the text writes out.
## Pages marked "bloom" glow into warm colour once the sketch is complete.

signal done

const PaperBG = preload("res://scripts/paper_bg.gd")
const Sketch = preload("res://scripts/sketch.gd")
const Sketches = preload("res://scripts/sketches.gd")
const DrawCtl = preload("res://scripts/draw_ctl.gd")

var pages: Array = []
var idx = 0
var sketch
var glow
var glow_a = 0.0
var title_lbl: Label
var body: Label
var hint: Label
var typing: Tween
var auto_t = 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(PaperBG.new())
	glow = DrawCtl.new(_draw_glow)
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(glow)
	sketch = Sketch.new()
	sketch.finished.connect(_on_sketch_done)
	add_child(sketch)
	title_lbl = Label.new()
	title_lbl.add_theme_font_size_override("font_size", 36)
	title_lbl.add_theme_color_override("font_color", GameState.SANGUINE)
	add_child(title_lbl)
	body = Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 24)
	body.add_theme_constant_override("line_spacing", 8)
	add_child(body)
	hint = Label.new()
	hint.text = "tap to continue"
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color(GameState.INK, 0.5))
	add_child(hint)
	var skip = Button.new()
	skip.text = "Skip"
	skip.position = Vector2(20, 20)
	skip.pressed.connect(func(): done.emit())
	add_child(skip)
	resized.connect(_layout)
	_layout()
	_show_page()


func _layout() -> void:
	var s = size
	var w = minf(s.x * 0.5, s.y * 0.7 * 1.4)
	sketch.position = Vector2(s.x * 0.04, s.y * 0.17)
	sketch.size = Vector2(w, w / 1.4)
	title_lbl.position = Vector2(s.x * 0.04 + 110, s.y * 0.05)
	title_lbl.size = Vector2(s.x * 0.85, 50)
	body.position = Vector2(s.x * 0.04 + w + s.x * 0.04, s.y * 0.2)
	body.size = Vector2(s.x - body.position.x - s.x * 0.06, s.y * 0.6)
	hint.position = Vector2(s.x - 180, s.y - 44)


func _show_page() -> void:
	var p: Dictionary = pages[idx]
	title_lbl.text = GameState.fmt(p["title"])
	body.text = GameState.fmt(p["text"])
	body.visible_ratio = 0.0
	sketch.set_strokes(Sketches.build(p["sketch"]))
	sketch.play(2.4)
	glow_a = 0.0
	glow.queue_redraw()
	if typing:
		typing.kill()
	typing = create_tween()
	typing.tween_property(body, "visible_ratio", 1.0, maxf(1.5, body.text.length() * 0.028))


func _on_sketch_done() -> void:
	if pages[idx].get("bloom", false):
		create_tween().tween_method(func(v): glow_a = v; glow.queue_redraw(), 0.0, 1.0, 1.6)


func _draw_glow(c: Control) -> void:
	if glow_a <= 0.0:
		return
	var center = sketch.position + sketch.size * 0.5
	for i in 14:
		var r: float = sketch.size.x * 0.75 * (1.0 - i / 14.0)
		c.draw_circle(center, r, Color(0.88, 0.55, 0.22, 0.045 * glow_a))


func _advance() -> void:
	if sketch.playing or body.visible_ratio < 1.0:
		sketch.finish()
		if typing:
			typing.kill()
		body.visible_ratio = 1.0
		return
	idx += 1
	if idx >= pages.size():
		done.emit()
	else:
		_show_page()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		_advance()
		accept_event()


func _process(delta: float) -> void:
	if GameState.autoplay:
		auto_t += delta
		if auto_t > 0.15:
			auto_t = 0.0
			_advance()
