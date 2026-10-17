extends Control
## Title page.

signal started

const PaperBG = preload("res://scripts/paper_bg.gd")
const Sketch = preload("res://scripts/sketch.gd")
const Sketches = preload("res://scripts/sketches.gd")


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(PaperBG.new())
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)

	var sk = Sketch.new()
	sk.custom_minimum_size = Vector2(364, 260)
	sk.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	sk.set_strokes(Sketches.build("title"))
	sk.play(3.0)
	box.add_child(sk)

	var title = Label.new()
	title.text = "The Oath of the Last Survivors"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 50)
	title.add_theme_color_override("font_color", GameState.SANGUINE)
	box.add_child(title)

	var sub = Label.new()
	sub.text = "Chapter 1 · The Lantern Night  (playable slice)"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)

	var begin = Button.new()
	begin.text = "Begin"
	begin.custom_minimum_size = Vector2(260, 56)
	begin.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	begin.add_theme_font_size_override("font_size", 26)
	begin.pressed.connect(func(): started.emit())
	box.add_child(begin)

	var auto = CheckButton.new()
	auto.text = "Auto timing (no tapping needed)"
	auto.button_pressed = GameState.auto_timing
	auto.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	auto.toggled.connect(func(on): GameState.auto_timing = on)
	box.add_child(auto)

	if GameState.autoplay:
		await get_tree().create_timer(0.3).timeout
		started.emit()
