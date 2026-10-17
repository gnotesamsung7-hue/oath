extends Control
## Flow for the Chapter 1 slice: title → opening → naming → tunnel → battle → oath → camp.

const TitleScreen = preload("res://scripts/title_screen.gd")
const NamingScreen = preload("res://scripts/naming_screen.gd")
const Cutscene = preload("res://scripts/cutscene.gd")
const Battle = preload("res://scripts/battle.gd")
const Camp = preload("res://scripts/camp.gd")

const OPENING := [
	{"title": "Hollowmere · The Lantern Night", "sketch": "lanterns",
		"text": "Eighty years after the Quiet, the river town of Hollowmere lit its lanterns, as it did every year. Warm springs steamed beneath the streets. No one ever asked why they were warm."},
	{"title": "The Iron Came at Midnight", "sketch": "dragon",
		"text": "Syndicate raiders broke the river gate. Above the smoke, something vast crossed the moon: a shape of black iron scale and glowing vents."},
	{"title": "Brannoc at the Gate", "sketch": "gate",
		"text": "The old smith held the gate alone, his tower shield raised against the fire. \"Metal remembers every blow,\" he said. \"Now run.\""},
	{"title": "Four Who Ran", "sketch": "four",
		"text": "Four young survivors reached the drainage tunnels beneath the springs. Before the dark took them, someone had to remember their names."},
]
const TUNNEL := [
	{"title": "The Tunnel Mouth", "sketch": "raiders",
		"text": "Raiders already hold the far end of the tunnel. Sergeant Kess blocks the only way out. {M} lifts Brannoc's shield. \"Stay behind me.\""},
]
const OATH := [
	{"title": "The First Fire", "sketch": "campfire", "bloom": true,
		"text": "Far from Hollowmere, {N} opened a ledger and wrote the names of the lost until his hand shook. Then four voices, one after another, swore the same words:\n\nNo one else gets left."},
]

var current: Node = null


func _ready() -> void:
	theme = GameState.make_theme()
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shot="):
			_debug_shot(a.substr(7))
			return
	_show_title()


func _debug_shot(which: String) -> void:
	# Developer helper: render one screen and save a screenshot.
	match which:
		"title": _show_title()
		"naming": _show_naming()
		"cutscene": _cutscene(OPENING, func(): pass)
		"battle": _show_battle()
		"camp": _show_camp()
	await get_tree().create_timer(3.5).timeout
	get_viewport().get_texture().get_image().save_png("user://shot_%s.png" % which)
	get_tree().quit()


func _swap(n: Control) -> void:
	if current:
		current.queue_free()
	current = n
	add_child(n)


func _show_title() -> void:
	var t = TitleScreen.new()
	t.started.connect(func(): _cutscene(OPENING, _show_naming))
	_swap(t)


func _cutscene(pages: Array, next: Callable) -> void:
	var c = Cutscene.new()
	c.pages = pages
	c.done.connect(next, CONNECT_ONE_SHOT)
	_swap(c)


func _show_naming() -> void:
	var n = NamingScreen.new()
	n.done.connect(func(): _cutscene(TUNNEL, _show_battle))
	_swap(n)


func _show_battle() -> void:
	var b = Battle.new()
	b.finished.connect(_on_battle_finished)
	_swap(b)


func _on_battle_finished(victory: bool) -> void:
	if victory:
		_cutscene(OATH, _show_camp)
	else:
		_show_battle()


func _show_camp() -> void:
	var c = Camp.new()
	c.replay.connect(_show_battle)
	c.to_title.connect(_show_title)
	_swap(c)
