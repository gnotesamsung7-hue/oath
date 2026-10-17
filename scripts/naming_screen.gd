extends Control
## The four heroes' introductions: players can rename each one.

signal done

const PaperBG = preload("res://scripts/paper_bg.gd")
const Sketch = preload("res://scripts/sketch.gd")
const Sketches = preload("res://scripts/sketches.gd")

var edits = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(PaperBG.new())
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)

	var title = Label.new()
	title.text = "Four Who Ran"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", GameState.SANGUINE)
	box.add_child(title)
	var sub = Label.new()
	sub.text = "Before the dark takes them, remember their names."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)

	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	for i in 4:
		var card = VBoxContainer.new()
		card.add_theme_constant_override("separation", 8)
		row.add_child(card)
		var sk = Sketch.new()
		sk.custom_minimum_size = Vector2(196, 140)
		sk.set_strokes(Sketches.build("hero"))
		sk.play(1.6 + i * 0.4)
		card.add_child(sk)
		var vow = Label.new()
		vow.text = GameState.VOWS[i]
		vow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vow.add_theme_font_size_override("font_size", 16)
		vow.add_theme_color_override("font_color", GameState.SANGUINE)
		card.add_child(vow)
		var le = LineEdit.new()
		le.text = GameState.names[i]
		le.max_length = 12
		le.alignment = HORIZONTAL_ALIGNMENT_CENTER
		le.custom_minimum_size = Vector2(196, 0)
		card.add_child(le)
		edits.append(le)

	var go = Button.new()
	go.text = "They run together"
	go.custom_minimum_size = Vector2(300, 54)
	go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	go.pressed.connect(_confirm)
	box.add_child(go)

	if GameState.autoplay:
		await get_tree().create_timer(0.3).timeout
		_confirm()


func _confirm() -> void:
	for i in 4:
		var n: String = edits[i].text.strip_edges()
		GameState.names[i] = n if n != "" else GameState.DEFAULT_NAMES[i]
	done.emit()
