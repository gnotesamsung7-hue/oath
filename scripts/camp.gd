extends Control
## The first camp: a campfire, the Bond Tether between the four, and bond talks.

signal replay
signal to_title

const PaperBG = preload("res://scripts/paper_bg.gd")
const DrawCtl = preload("res://scripts/draw_ctl.gd")

const SEATS := [Vector2(0.27, 0.66), Vector2(0.35, 0.42), Vector2(0.55, 0.42), Vector2(0.63, 0.66)]
const FIRE := Vector2(0.45, 0.6)
const TALKS := [
	{"a": 0, "b": 1, "title": "{M} & {J}: Count to Three", "lines": [
		[1, "You ran back into the fire, {M}. Twice."],
		[0, "Someone had to hold the door."],
		[1, "Next time the someone is both of us. Deal? Count to three."],
		[0, "...You're already gone, aren't you."],
		[1, "Already gone. Keep up, big brother."]]},
	{"a": 2, "b": 3, "title": "{N} & {R}: A Name for the Ledger", "lines": [
		[2, "I need to write you down properly, {R}. Where did you come from, before Hollowmere?"],
		[3, "Somewhere with no ledgers."],
		[2, "Then I'll write what I know. '{R}. Came to us at ten. Stayed.'"],
		[3, "...Write it neat, {N}."]]},
	{"a": 0, "b": 2, "title": "{M} & {N}: What Metal Remembers", "lines": [
		[2, "You haven't let go of Brannoc's shield since the gate."],
		[0, "'Metal remembers every blow.' He said it every day at the forge."],
		[2, "Then let it remember tonight too. We got out. All four of us."],
		[0, "All four. I'll hold you to that, ledger-keeper."]]},
]

var scene_ctl
var talk_btns = []
var panel: PanelContainer
var talk_title: Label
var talk_text: RichTextLabel


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(PaperBG.new())
	scene_ctl = DrawCtl.new(_draw_camp, true)
	scene_ctl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scene_ctl)

	var title = Label.new()
	title.text = "Camp · The First Fire"
	title.position = Vector2(40, 24)
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", GameState.SANGUINE)
	add_child(title)
	var info = Label.new()
	info.text = "End of the Chapter 1 slice. Bond talks brighten the tether, and a brighter tether makes that pair's Chain Art stronger."
	info.position = Vector2(40, 76)
	info.size = Vector2(620, 60)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size", 17)
	add_child(info)

	var side = VBoxContainer.new()
	side.add_theme_constant_override("separation", 12)
	side.anchor_left = 0.72
	side.anchor_right = 0.97
	side.anchor_top = 0.2
	side.anchor_bottom = 0.95
	add_child(side)
	var hdr = Label.new()
	hdr.text = "Evening"
	hdr.add_theme_font_size_override("font_size", 26)
	side.add_child(hdr)
	for i in TALKS.size():
		var b = Button.new()
		b.text = GameState.fmt(TALKS[i]["title"]).split(":")[0] + " (talk)"
		b.disabled = GameState.talks_done.has(i)
		b.pressed.connect(_open_talk.bind(i))
		side.add_child(b)
		talk_btns.append(b)
	var again = Button.new()
	again.text = "Replay the tunnel battle"
	again.pressed.connect(func(): replay.emit())
	side.add_child(again)
	var home = Button.new()
	home.text = "Return to title"
	home.pressed.connect(func(): to_title.emit())
	side.add_child(home)

	panel = PanelContainer.new()
	panel.anchor_left = 0.08
	panel.anchor_right = 0.7
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.96
	panel.visible = false
	add_child(panel)
	var pv = VBoxContainer.new()
	pv.add_theme_constant_override("separation", 10)
	panel.add_child(pv)
	talk_title = Label.new()
	talk_title.add_theme_font_size_override("font_size", 24)
	talk_title.add_theme_color_override("font_color", GameState.SANGUINE)
	pv.add_child(talk_title)
	talk_text = RichTextLabel.new()
	talk_text.bbcode_enabled = true
	talk_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	talk_text.add_theme_font_size_override("normal_font_size", 20)
	pv.add_child(talk_text)
	var close = Button.new()
	close.text = "Close"
	close.size_flags_horizontal = Control.SIZE_SHRINK_END
	close.pressed.connect(func(): panel.visible = false)
	pv.add_child(close)

	if GameState.autoplay:
		_open_talk(0)
		await get_tree().create_timer(0.5).timeout
		print("[camp] bonds=", GameState.bonds, " AUTOPLAY OK")
		get_tree().quit()


func _open_talk(i: int) -> void:
	var t: Dictionary = TALKS[i]
	talk_title.text = GameState.fmt(t["title"])
	var txt = ""
	for line in t["lines"]:
		txt += "[color=#a4442c][b]%s:[/b][/color] %s\n" % [GameState.names[line[0]], GameState.fmt(line[1])]
	talk_text.text = txt
	talk_text.visible_ratio = 0.0
	create_tween().tween_property(talk_text, "visible_ratio", 1.0, 2.5)
	panel.visible = true
	if not GameState.talks_done.has(i):
		GameState.talks_done[i] = true
		GameState.add_bond(t["a"], t["b"])
		talk_btns[i].disabled = true


func _draw_camp(c: Control) -> void:
	var s = c.size
	var tm = Time.get_ticks_msec() / 1000.0
	var fire = Vector2(s.x * FIRE.x, s.y * FIRE.y)
	var seats = []
	for p in SEATS:
		seats.append(Vector2(s.x * p.x, s.y * p.y))
	for i in 4:
		for j in range(i + 1, 4):
			var b = GameState.get_bond(i, j)
			var a = 0.18 + 0.25 * b + 0.06 * sin(tm * 3.0 + i + j)
			c.draw_line(seats[i] + Vector2(0, -40), seats[j] + Vector2(0, -40), Color(GameState.GOLD, a), 2.0 + 2.5 * b, true)
	for k in 6:
		c.draw_circle(fire + Vector2(0, -10), 120.0 - k * 18.0, Color(0.9, 0.55, 0.2, 0.05))
	c.draw_line(fire + Vector2(-40, 18), fire + Vector2(40, -4), GameState.INK, 5.0, true)
	c.draw_line(fire + Vector2(-40, -4), fire + Vector2(40, 18), GameState.INK, 5.0, true)
	var flame = PackedVector2Array()
	for i in 9:
		var x = -30.0 + i * 7.5
		var h = (70.0 if i % 2 == 1 else 22.0) * (0.8 + 0.25 * sin(tm * 9.0 + i * 1.7))
		flame.append(fire + Vector2(x, -h))
	flame.append(fire + Vector2(30, 0))
	flame.append(fire + Vector2(-30, 0))
	c.draw_colored_polygon(flame, Color(GameState.SANGUINE, 0.75))
	c.draw_polyline(flame, GameState.SANGUINE, 2.0, true)
	var f = ThemeDB.fallback_font
	for i in 4:
		var p: Vector2 = seats[i]
		var dir = 1.0 if p.x < fire.x else -1.0
		c.draw_arc(p + Vector2(0, -58), 13, 0, TAU, 24, GameState.INK, 3.0, true)
		c.draw_line(p + Vector2(0, -45), p + Vector2(0, -10), GameState.INK, 3.0, true)
		c.draw_polyline(PackedVector2Array([p + Vector2(0, -10), p + Vector2(26 * dir, -8), p + Vector2(30 * dir, 18)]), GameState.INK, 3.0, true)
		c.draw_line(p + Vector2(0, -36), p + Vector2(22 * dir, -22), GameState.INK, 3.0, true)
		c.draw_string(f, p + Vector2(-70, 46), GameState.names[i], HORIZONTAL_ALIGNMENT_CENTER, 140, 18, GameState.SANGUINE)
