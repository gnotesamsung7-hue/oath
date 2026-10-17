extends Control
## Chapter 1 battle: turn timeline, timed hits/parries, intercepts, morale breaks,
## the shared Vow Shield, the Resonance Gauge and Chain Arts.

signal finished(victory: bool)
signal _picked(value)

const PaperBG = preload("res://scripts/paper_bg.gd")
const DrawCtl = preload("res://scripts/draw_ctl.gd")
const UnitView = preload("res://scripts/unit_view.gd")
const TimingRing = preload("res://scripts/timing_ring.gd")


class Unit:
	var name = ""
	var short = ""
	var side = "hero"
	var idx = 0
	var kind = ""
	var hp = 100.0
	var max_hp = 100.0
	var atk = 10.0
	var def = 5.0
	var spd = 10.0
	var morale = 0.0
	var max_morale = 1.0
	var broken = false
	var alive = true
	var guard = false
	var next_t = 0.0
	var acts = 0
	var view: Control = null


const HERO_KINDS := ["mark", "jhona", "nelson", "rachel"]
const HERO_STATS := [
	{"hp": 150, "atk": 14, "def": 10, "spd": 8},
	{"hp": 95, "atk": 17, "def": 5, "spd": 14},
	{"hp": 95, "atk": 11, "def": 6, "spd": 10},
	{"hp": 105, "atk": 15, "def": 6, "spd": 12},
]
const SKILLS := [
	[
		{"name": "Mace Strike", "type": "attack", "power": 1.0, "morale": 0.6, "weight": 1.0},
		{"name": "Shield Bash", "type": "attack", "power": 0.7, "morale": 1.7, "weight": 1.2, "delay": 25.0},
		{"name": "Guard", "type": "guard", "weight": 0.8},
	],
	[
		{"name": "Twin Cut", "type": "attack", "power": 0.65, "hits": 2, "morale": 0.7, "weight": 1.0},
		{"name": "Hurricane Step", "type": "attack", "power": 0.85, "morale": 0.6, "weight": 0.55, "crit": 0.35},
		{"name": "Whirl", "type": "attack_all", "power": 0.5, "morale": 0.5, "weight": 1.3},
	],
	[
		{"name": "Chime Strike", "type": "attack", "power": 0.8, "morale": 1.1, "weight": 1.0},
		{"name": "Mend", "type": "heal", "amount": 45, "weight": 1.0},
		{"name": "Chime of Names", "type": "heal_all", "amount": 18, "res": 20, "weight": 1.2},
	],
	[
		{"name": "Bolt", "type": "attack", "power": 1.1, "morale": 0.6, "weight": 1.0},
		{"name": "Wire Snare", "type": "attack", "power": 0.4, "morale": 1.3, "weight": 0.9, "delay": 40.0},
		{"name": "Volley", "type": "attack_all", "power": 0.6, "morale": 0.6, "weight": 1.2},
	],
]
const CHAIN_ARTS := {
	"0-1": {"name": "Anvil Gale", "type": "attack", "power": 3.0, "morale": 2.0},
	"0-2": {"name": "Bulwark Hymn", "type": "heal_all", "amount": 55, "shield": 60},
	"0-3": {"name": "Ambush Wall", "type": "attack_all", "power": 1.2, "morale": 1.0, "delay": 30.0},
	"1-2": {"name": "Recital Storm", "type": "attack", "power": 0.6, "hits": 5, "morale": 1.4},
	"1-3": {"name": "Crossfire Dance", "type": "attack_all", "power": 1.5, "morale": 1.0},
	"2-3": {"name": "Erased Line", "type": "attack", "power": 1.5, "morale": 99.0},
}
const ENEMIES := [
	{"name": "Raider A", "short": "Ra", "kind": "raider", "hp": 85, "atk": 15, "def": 4, "spd": 10, "morale": 55},
	{"name": "Raider B", "short": "Rb", "kind": "raider", "hp": 85, "atk": 15, "def": 4, "spd": 11, "morale": 55},
	{"name": "Brute", "short": "Br", "kind": "brute", "hp": 160, "atk": 22, "def": 8, "spd": 6, "morale": 90},
	{"name": "Sgt. Kess", "short": "Ks", "kind": "sergeant", "hp": 200, "atk": 18, "def": 7, "spd": 9, "morale": 110},
]
const HERO_SLOTS := [Vector2(0.25, 0.15), Vector2(0.25, 0.44), Vector2(0.07, 0.19), Vector2(0.07, 0.48)]
const ENEMY_SLOTS := [Vector2(0.62, 0.15), Vector2(0.62, 0.44), Vector2(0.8, 0.19), Vector2(0.8, 0.48)]

var units = []
var heroes = []
var enemies = []
var vow = 100.0
var vow_max = 100.0
var resonance = 0.0
var now_t = 0.0
var last_hero_target = null
var ended = false

var timeline
var gauges
var cmd_box: HBoxContainer
var log_lbl: Label
var help_lbl: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(PaperBG.new())
	_build_units()
	_build_ui()
	resized.connect(_layout)
	await get_tree().process_frame
	_layout()
	_run()


func _build_units() -> void:
	for i in 4:
		var s: Dictionary = HERO_STATS[i]
		var u = Unit.new()
		u.name = GameState.names[i]
		u.short = u.name.substr(0, 2)
		u.side = "hero"
		u.idx = i
		u.kind = HERO_KINDS[i]
		u.hp = s["hp"]
		u.max_hp = s["hp"]
		u.atk = s["atk"]
		u.def = s["def"]
		u.spd = s["spd"]
		heroes.append(u)
	for i in ENEMIES.size():
		var e: Dictionary = ENEMIES[i]
		var u = Unit.new()
		u.name = e["name"]
		u.short = e["short"]
		u.side = "enemy"
		u.idx = i
		u.kind = e["kind"]
		u.hp = e["hp"]
		u.max_hp = e["hp"]
		u.atk = e["atk"]
		u.def = e["def"]
		u.spd = e["spd"]
		u.morale = e["morale"]
		u.max_morale = e["morale"]
		enemies.append(u)
	units = heroes + enemies
	for u in units:
		u.next_t = 100.0 / u.spd * randf_range(0.2, 0.6)
		var v = UnitView.new(u)
		v.tapped.connect(func(x): _picked.emit(x))
		u.view = v
		add_child(v)


func _build_ui() -> void:
	timeline = DrawCtl.new(_draw_timeline)
	add_child(timeline)
	gauges = DrawCtl.new(_draw_gauges)
	add_child(gauges)
	cmd_box = HBoxContainer.new()
	cmd_box.add_theme_constant_override("separation", 10)
	add_child(cmd_box)
	log_lbl = Label.new()
	log_lbl.add_theme_font_size_override("font_size", 20)
	log_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(log_lbl)
	help_lbl = Label.new()
	help_lbl.add_theme_font_size_override("font_size", 13)
	help_lbl.add_theme_color_override("font_color", Color(GameState.INK, 0.75))
	help_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_lbl.text = "Tap when the ring meets the circle.\nBreak morale (gold bar) for double damage.\nLow-HP ally attacked? %s can INTERCEPT.\nFull Resonance unlocks Chain Arts." % GameState.names[0]
	add_child(help_lbl)
	var auto = CheckButton.new()
	auto.text = "Auto timing"
	auto.button_pressed = GameState.auto_timing
	auto.add_theme_font_size_override("font_size", 16)
	auto.toggled.connect(func(on): GameState.auto_timing = on)
	auto.name = "AutoToggle"
	add_child(auto)


func _layout() -> void:
	var s = size
	for i in heroes.size():
		var p = Vector2(s.x * HERO_SLOTS[i].x, s.y * HERO_SLOTS[i].y)
		heroes[i].view.position = p
		heroes[i].view.set_meta("home", p)
	for i in enemies.size():
		var p = Vector2(s.x * ENEMY_SLOTS[i].x, s.y * ENEMY_SLOTS[i].y)
		enemies[i].view.position = p
		enemies[i].view.set_meta("home", p)
	timeline.position = Vector2(s.x * 0.3, 8)
	timeline.size = Vector2(s.x * 0.5, 70)
	help_lbl.position = Vector2(14, 10)
	help_lbl.size = Vector2(s.x * 0.27, 90)
	var auto: Control = get_node("AutoToggle")
	auto.position = Vector2(s.x - 190, 14)
	gauges.position = Vector2(s.x * 0.03, s.y * 0.76)
	gauges.size = Vector2(s.x * 0.28, s.y * 0.2)
	cmd_box.position = Vector2(s.x * 0.34, s.y * 0.77)
	cmd_box.size = Vector2(s.x * 0.64, 56)
	log_lbl.position = Vector2(s.x * 0.34, s.y * 0.88)
	log_lbl.size = Vector2(s.x * 0.62, s.y * 0.1)


# ---------------------------------------------------------------- flow

func _run() -> void:
	_log("Raiders hold the tunnel mouth. Break their will and get out!")
	while not ended:
		if _alive(enemies).is_empty():
			await _end(true)
			return
		if _alive(heroes).is_empty():
			await _end(false)
			return
		var u = _preview(1)[0]
		now_t = u.next_t
		for x in units:
			x.view.active = x == u
		_refresh()
		if u.side == "hero":
			await _hero_turn(u)
		else:
			await _enemy_turn(u)
		resonance = clampf(resonance, 0.0, 100.0)
		_refresh()
		await _wait(0.12)


func _preview(n: int) -> Array:
	var sims = []
	for u in units:
		if u.alive:
			sims.append({"u": u, "t": u.next_t})
	var out = []
	if sims.is_empty():
		return out
	for i in n:
		sims.sort_custom(func(a, b): return a["t"] < b["t"] or (a["t"] == b["t"] and a["u"].side == "hero"))
		var s: Dictionary = sims[0]
		out.append(s["u"])
		s["t"] += 100.0 / s["u"].spd
	return out


func _alive(list: Array) -> Array:
	return list.filter(func(x): return x.alive)


# ---------------------------------------------------------------- hero turn

func _hero_turn(u) -> void:
	u.guard = false
	_log("%s's turn." % u.name)
	while true:
		var choice = await _choose_command(u)
		if choice is Dictionary and choice.get("chain_menu", false):
			var partner = await _choose_partner(u)
			if partner == null:
				continue
			var art: Dictionary = CHAIN_ARTS[GameState.bond_key(u.idx, partner.idx)]
			var target = null
			if art["type"] == "attack":
				target = await _choose_target("enemy")
				if target == null:
					continue
			await _do_chain(u, partner, art, target)
			return
		var skill: Dictionary = choice
		var target = null
		if skill["type"] == "attack":
			target = await _choose_target("enemy")
			if target == null:
				continue
		elif skill["type"] == "heal":
			target = await _choose_target("ally")
			if target == null:
				continue
		await _do_skill(u, skill, target)
		return


func _clear_cmds() -> void:
	for ch in cmd_box.get_children():
		ch.queue_free()


func _add_cmd(text: String, value, enabled: bool = true) -> void:
	var b = Button.new()
	b.text = text
	b.disabled = not enabled
	b.custom_minimum_size = Vector2(0, 52)
	b.pressed.connect(func(): _picked.emit(value))
	cmd_box.add_child(b)


func _choose_command(u):
	_clear_cmds()
	for s in SKILLS[u.idx]:
		_add_cmd(s["name"], s)
	var can_chain = resonance >= 100.0 and _alive(heroes).size() > 1
	_add_cmd("★ Chain Art", {"chain_menu": true}, can_chain)
	if GameState.autoplay:
		await _wait(0.05)
		if can_chain:
			return {"chain_menu": true}
		return SKILLS[u.idx][0]
	return await _picked


func _choose_partner(u):
	_clear_cmds()
	var options = []
	for h in _alive(heroes):
		if h != u:
			options.append(h)
			var art: Dictionary = CHAIN_ARTS[GameState.bond_key(u.idx, h.idx)]
			_add_cmd("+ %s: %s" % [h.name, art["name"]], h)
	_add_cmd("Back", null)
	if GameState.autoplay:
		await _wait(0.05)
		return options[0]
	return await _picked


func _choose_target(kind: String):
	_clear_cmds()
	_add_cmd("Back", null)
	var pool: Array = _alive(enemies) if kind == "enemy" else heroes
	if GameState.autoplay:
		await _wait(0.05)
		if kind == "enemy":
			return pool[0]
		var best = pool[0]
		for h in pool:
			if h.hp / h.max_hp < best.hp / best.max_hp:
				best = h
		return best
	for t in pool:
		t.view.targetable = true
	_log("Choose a target." if kind == "enemy" else "Choose an ally (fallen allies can be revived).")
	var v = await _picked
	for t in units:
		t.view.targetable = false
	return v


func _do_skill(u, s: Dictionary, target) -> void:
	_clear_cmds()
	match s["type"]:
		"guard":
			u.guard = true
			vow = minf(vow_max, vow + 25.0)
			_pop(u.view, "Guard +Shield", GameState.SAGE)
			_log("%s raises the shield. The Vow Shield steadies." % u.name)
		"heal":
			_heal(u, target, s["amount"])
			resonance += 10.0
			_log("%s mends %s." % [u.name, target.name])
		"heal_all":
			for h in heroes:
				if h.alive:
					_heal(u, h, s["amount"])
			resonance += s.get("res", 0)
			_log("%s rings the chime and speaks the names of the lost." % u.name)
		"attack":
			var mult = await _timing_mult(target.view.position + target.view.size * 0.5, "Strike!")
			await _lunge(u)
			for i in s.get("hits", 1):
				if not target.alive:
					break
				var crit = randf() < s.get("crit", 0.0)
				_hit_enemy(u, target, s["power"] * mult * (1.5 if crit else 1.0), s["morale"], crit)
				await _wait(0.16)
			if s.has("delay") and target.alive:
				target.next_t += s["delay"]
				_pop(target.view, "Delayed!", GameState.INK, 40)
			if last_hero_target == target:
				resonance += 6.0
			last_hero_target = target
			_log("%s uses %s." % [u.name, s["name"]])
		"attack_all":
			var mult = await _timing_mult(_enemy_center(), "Strike!")
			await _lunge(u)
			for e in _alive(enemies):
				_hit_enemy(u, e, s["power"] * mult, s["morale"], false)
			_log("%s uses %s." % [u.name, s["name"]])
			await _wait(0.3)
	u.next_t = now_t + 100.0 / u.spd * s.get("weight", 1.0)


func _do_chain(u, p, art: Dictionary, target) -> void:
	_clear_cmds()
	resonance = 0.0
	_log("%s and %s: %s!" % [u.name, p.name, art["name"]])
	await _banner(art["name"])
	var bonus = 1.0 + 0.1 * GameState.get_bond(u.idx, p.idx)
	match art["type"]:
		"attack":
			var mult = await _timing_mult(target.view.position + target.view.size * 0.5, "Together!")
			await _lunge(u)
			for i in art.get("hits", 1):
				if not target.alive:
					break
				_hit_enemy(u, target, art["power"] * mult * bonus, art["morale"], false)
				await _wait(0.12)
		"attack_all":
			var mult = await _timing_mult(_enemy_center(), "Together!")
			await _lunge(u)
			for e in _alive(enemies):
				_hit_enemy(u, e, art["power"] * mult * bonus, art["morale"], false)
				if art.has("delay") and e.alive:
					e.next_t += art["delay"]
			await _wait(0.3)
		"heal_all":
			for h in heroes:
				if h.alive:
					_heal(u, h, art["amount"] * bonus)
			vow = minf(vow_max, vow + art.get("shield", 0))
	u.next_t = now_t + 100.0 / u.spd
	p.next_t += 15.0


func _heal(u, t, amount: float) -> void:
	var amt = roundf(amount + u.atk * 0.5)
	if not t.alive:
		t.alive = true
		t.hp = 0.0
		t.next_t = now_t + 50.0 / t.spd
		_log("%s rises again!" % t.name)
	t.hp = minf(t.max_hp, t.hp + amt)
	_pop(t.view, "+%d" % amt, GameState.SAGE)


func _hit_enemy(u, e, power: float, mpow: float, crit: bool) -> void:
	var dmg = maxf(1.0, u.atk * power * randf_range(0.9, 1.1) - e.def * 0.5)
	if e.broken:
		dmg *= 2.0
	dmg = roundf(dmg)
	e.hp -= dmg
	resonance += 4.0
	_pop(e.view, ("%d!" % dmg) if crit else str(dmg), GameState.SANGUINE)
	e.view.flash = 1.0
	if not e.broken:
		e.morale -= dmg * mpow
		if e.morale <= 0.0:
			e.morale = 0.0
			e.broken = true
			resonance += 10.0
			_pop(e.view, "BROKEN!", GameState.GOLD, 46)
			_log("%s's will breaks! Double damage while Broken." % e.name)
	if e.hp <= 0.0:
		e.hp = 0.0
		e.alive = false
		_log("%s falls." % e.name)


# ---------------------------------------------------------------- enemy turn

func _enemy_turn(e) -> void:
	e.acts += 1
	_clear_cmds()
	if e.broken:
		if e.kind != "sergeant" and e.hp < e.max_hp * 0.5 and randf() < 0.6:
			e.alive = false
			_pop(e.view, "Surrenders", GameState.INK)
			_log("%s throws down their weapon and flees into the dark." % e.name)
			await _wait(0.6)
			return
		e.broken = false
		e.morale = e.max_morale * 0.5
		_log("%s regains their nerve." % e.name)
		e.next_t = now_t + 100.0 / e.spd
		await _wait(0.5)
		return
	var alive = _alive(heroes)
	if alive.is_empty():
		return
	if e.kind == "sergeant" and e.acts % 3 == 0:
		_log("Sgt. Kess bellows: \"Iron Call!\" — brace yourselves!")
		await _wait(0.4)
		var res: String = await _timing(_hero_center(), "BRACE!", GameState.INK)
		var m: float = {"perfect": 0.4, "good": 0.75}.get(res, 1.0)
		if res == "perfect":
			resonance += 10.0
		await _lunge(e)
		for h in alive:
			_hit_hero(e, h, 0.65 * m)
		await _wait(0.4)
	else:
		var target = alive.pick_random()
		if randf() < 0.6:
			for h in alive:
				if h.hp / h.max_hp < target.hp / target.max_hp:
					target = h
		var power = 1.3 if e.kind == "brute" else 1.0
		var mark = heroes[0]
		var final = target
		var mult = 1.0
		_log("%s attacks %s!" % [e.name, target.name])
		await _wait(0.3)
		var tc: Vector2 = target.view.position + target.view.size * 0.5
		if target != mark and mark.alive and target.hp / target.max_hp < 0.45:
			var res: String = await _timing(tc, "INTERCEPT with %s!" % mark.name, GameState.GOLD)
			if res != "miss":
				final = mark
				mult = 0.4 if res == "perfect" else 0.8
				resonance += 20.0
				_log("%s leaps in front of %s!" % [mark.name, target.name])
				var tw = create_tween()
				tw.tween_property(mark.view, "position", target.view.position + Vector2(60, 0), 0.15)
				await tw.finished
		else:
			var res2: String = await _timing(tc, "PARRY!", GameState.INK)
			mult = {"perfect": 0.3, "good": 0.7}.get(res2, 1.0)
			if res2 == "perfect":
				resonance += 10.0
				_pop(target.view, "Parry!", GameState.GOLD, 46)
		await _lunge(e)
		_hit_hero(e, final, power * mult)
		if final != target:
			await _wait(0.3)
			var back = create_tween()
			back.tween_property(mark.view, "position", mark.view.get_meta("home"), 0.2)
			await back.finished
	e.next_t = now_t + 100.0 / e.spd * (1.3 if e.kind == "brute" else 1.0)


func _hit_hero(e, h, power: float) -> void:
	if not h.alive:
		return
	var dmg = maxf(1.0, e.atk * power * randf_range(0.9, 1.1) - h.def * 0.5)
	if h.guard:
		dmg *= 0.5
	if vow > 0.0:
		var absorb = minf(vow, dmg * 0.35)
		vow -= absorb
		dmg -= absorb
		if vow <= 0.0:
			vow = 0.0
			_log("The Vow Shield shatters! The party staggers.")
			_banner("Vow Shield broken")
			for x in heroes:
				x.next_t += 25.0
	dmg = roundf(dmg)
	h.hp -= dmg
	h.view.flash = 1.0
	_pop(h.view, str(dmg), GameState.INK)
	if h.hp <= 0.0:
		h.hp = 0.0
		h.alive = false
		_log("%s falls! %s can still mend them." % [h.name, GameState.names[2]])


# ---------------------------------------------------------------- helpers

func _timing(center: Vector2, prompt: String, col: Color) -> String:
	if GameState.auto_timing:
		await _wait(0.1)
		return "good"
	var r = TimingRing.new()
	r.start(center, prompt, col)
	add_child(r)
	return await r.resolved


func _timing_mult(center: Vector2, prompt: String) -> float:
	var res: String = await _timing(center, prompt, GameState.SANGUINE)
	if res == "perfect":
		resonance += 12.0
		return 1.5
	return 1.2 if res == "good" else 1.0


func _enemy_center() -> Vector2:
	return Vector2(size.x * 0.76, size.y * 0.42)


func _hero_center() -> Vector2:
	return Vector2(size.x * 0.22, size.y * 0.42)


func _lunge(u) -> void:
	var home: Vector2 = u.view.get_meta("home", u.view.position)
	var f = 1.0 if u.side == "hero" else -1.0
	var tw = create_tween()
	tw.tween_property(u.view, "position", home + Vector2(36 * f, 0), 0.09)
	tw.tween_property(u.view, "position", home, 0.12)
	await tw.finished


func _wait(t: float) -> void:
	await get_tree().create_timer(t).timeout


func _pop(view: Control, text: String, col: Color, size_px: int = 30) -> void:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", GameState.PAPER)
	l.add_theme_constant_override("outline_size", 6)
	l.position = view.position + Vector2(30 + randf_range(-12, 12), 28)
	add_child(l)
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 60, 0.9)
	tw.tween_property(l, "modulate:a", 0.0, 0.9).set_delay(0.3)
	tw.chain().tween_callback(l.queue_free)


func _banner(text: String) -> void:
	var l = Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 64)
	l.add_theme_color_override("font_color", GameState.SANGUINE)
	l.add_theme_color_override("font_outline_color", GameState.PAPER)
	l.add_theme_constant_override("outline_size", 10)
	l.size = Vector2(size.x, 90)
	l.position = Vector2(0, size.y * 0.32)
	l.modulate.a = 0.0
	add_child(l)
	var tw = create_tween()
	tw.tween_property(l, "modulate:a", 1.0, 0.2)
	tw.tween_interval(0.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.3)
	tw.tween_callback(l.queue_free)
	await _wait(0.8)


func _log(t: String) -> void:
	log_lbl.text = t
	if GameState.autoplay:
		print("[battle] ", t)


func _refresh() -> void:
	timeline.queue_redraw()
	gauges.queue_redraw()


func _draw_timeline(c: Control) -> void:
	var f = ThemeDB.fallback_font
	c.draw_string(f, Vector2(0, 14), "TURN ORDER", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(GameState.INK, 0.6))
	var x = 0.0
	var order = _preview(8)
	for i in order.size():
		var u = order[i]
		var r = 25.0 if i == 0 else 18.0
		var center = Vector2(x + r, 44)
		var col: Color = GameState.SANGUINE if u.side == "hero" else GameState.INK
		c.draw_circle(center, r, col)
		c.draw_arc(center, r, 0, TAU, 32, GameState.GOLD if i == 0 else GameState.PAPER, 3.0 if i == 0 else 2.0, true)
		c.draw_string(f, center + Vector2(-r, 6), u.short, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, 18 if i == 0 else 14, GameState.PAPER)
		x += r * 2.0 + 8.0


func _draw_gauges(c: Control) -> void:
	_bar(c, 0.0, "Vow Shield", vow / vow_max, GameState.SAGE)
	var ready = resonance >= 100.0
	_bar(c, 58.0, "Resonance — Chain Art ready!" if ready else "Resonance", resonance / 100.0, GameState.GOLD if ready else GameState.SANGUINE)


func _bar(c: Control, y: float, label: String, frac: float, col: Color) -> void:
	var f = ThemeDB.fallback_font
	c.draw_string(f, Vector2(0, y + 16), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, GameState.INK)
	var r = Rect2(0, y + 24, c.size.x, 18)
	c.draw_rect(r, Color(GameState.INK, 0.1))
	c.draw_rect(Rect2(r.position, Vector2(r.size.x * clampf(frac, 0.0, 1.0), r.size.y)), col)
	c.draw_rect(r, GameState.INK, false, 2.0)


func _end(victory: bool) -> void:
	ended = true
	_clear_cmds()
	for x in units:
		x.view.active = false
	var shade = DrawCtl.new(func(c): c.draw_rect(Rect2(Vector2.ZERO, c.size), Color(GameState.PAPER, 0.8)))
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	center.add_child(box)
	var l = Label.new()
	l.text = "The way is clear." if victory else "The Oath falters..."
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 52)
	l.add_theme_color_override("font_color", GameState.SANGUINE)
	box.add_child(l)
	var b = Button.new()
	b.text = "Continue" if victory else "Try again"
	b.custom_minimum_size = Vector2(240, 54)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(b)
	if GameState.autoplay:
		print("[battle] END victory=", victory)
		await _wait(0.3)
	else:
		await b.pressed
	finished.emit(victory)
