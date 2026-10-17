extends Node
## Global game state: hero names, bonds, settings and the shared palette.

const DEFAULT_NAMES := ["Mark", "Jhona", "Nelson", "Rachel"]
const VOWS := ["The Vow of the Shield", "The Vow of the Blade", "The Vow of the Mend", "The Vow of the Veil"]

const PAPER := Color(0.92, 0.86, 0.73)
const PAPER_DARK := Color(0.84, 0.75, 0.58)
const INK := Color(0.23, 0.15, 0.09)
const SANGUINE := Color(0.64, 0.27, 0.17)
const GOLD := Color(0.78, 0.58, 0.2)
const SAGE := Color(0.33, 0.45, 0.3)

var names: Array = DEFAULT_NAMES.duplicate()
var bonds = {}
var talks_done = {}
var auto_timing = false
var autoplay = false


func _ready() -> void:
	autoplay = OS.get_cmdline_user_args().has("--autoplay")
	if autoplay:
		auto_timing = true
		Engine.time_scale = 4.0


func fmt(text: String) -> String:
	return text.replace("{M}", names[0]).replace("{J}", names[1]).replace("{N}", names[2]).replace("{R}", names[3])


func bond_key(a: int, b: int) -> String:
	return "%d-%d" % [mini(a, b), maxi(a, b)]


func get_bond(a: int, b: int) -> int:
	return bonds.get(bond_key(a, b), 0)


func add_bond(a: int, b: int, v: int = 1) -> void:
	bonds[bond_key(a, b)] = get_bond(a, b) + v


func make_theme() -> Theme:
	var t = Theme.new()
	t.default_font_size = 20
	var sb = StyleBoxFlat.new()
	sb.bg_color = PAPER_DARK
	sb.border_color = INK
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	var hov: StyleBoxFlat = sb.duplicate()
	hov.bg_color = Color(0.96, 0.9, 0.76)
	var pr: StyleBoxFlat = sb.duplicate()
	pr.bg_color = SANGUINE
	var dis: StyleBoxFlat = sb.duplicate()
	dis.bg_color = Color(0.8, 0.74, 0.62, 0.5)
	dis.border_color = Color(INK, 0.35)
	t.set_stylebox("normal", "Button", sb)
	t.set_stylebox("hover", "Button", hov)
	t.set_stylebox("pressed", "Button", pr)
	t.set_stylebox("disabled", "Button", dis)
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_color", "Button", INK)
	t.set_color("font_hover_color", "Button", INK)
	t.set_color("font_focus_color", "Button", INK)
	t.set_color("font_pressed_color", "Button", PAPER)
	t.set_color("font_disabled_color", "Button", Color(INK, 0.4))
	t.set_color("font_color", "Label", INK)
	t.set_color("default_color", "RichTextLabel", INK)
	t.set_color("font_color", "CheckButton", INK)
	t.set_color("font_hover_color", "CheckButton", INK)
	t.set_color("font_pressed_color", "CheckButton", INK)
	t.set_color("font_focus_color", "CheckButton", INK)
	t.set_color("font_hover_pressed_color", "CheckButton", INK)
	var le: StyleBoxFlat = sb.duplicate()
	le.bg_color = PAPER
	t.set_stylebox("normal", "LineEdit", le)
	t.set_stylebox("focus", "LineEdit", le)
	t.set_color("font_color", "LineEdit", INK)
	t.set_color("caret_color", "LineEdit", SANGUINE)
	var panel: StyleBoxFlat = sb.duplicate()
	panel.bg_color = Color(PAPER, 0.97)
	panel.content_margin_left = 24
	panel.content_margin_right = 24
	panel.content_margin_top = 18
	panel.content_margin_bottom = 18
	t.set_stylebox("panel", "PanelContainer", panel)
	return t
