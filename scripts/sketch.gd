extends Control
## Draws a list of strokes progressively, so drawings "ink themselves in".

signal finished

var strokes: Array = []
var progress = 1.0
var duration = 2.0
var playing = false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_strokes(s: Array) -> void:
	strokes = s
	progress = 0.0
	queue_redraw()


func play(d: float = 2.0) -> void:
	duration = d
	progress = 0.0
	playing = true


func finish() -> void:
	if playing:
		playing = false
		progress = 1.0
		queue_redraw()
		finished.emit()


func _process(delta: float) -> void:
	if playing:
		progress = minf(1.0, progress + delta / duration)
		queue_redraw()
		if progress >= 1.0:
			playing = false
			finished.emit()


func _draw() -> void:
	var total = strokes.size()
	if total == 0:
		return
	var shown = progress * total
	for i in total:
		if i >= shown:
			break
		var s: Dictionary = strokes[i]
		var pts: PackedVector2Array = s["pts"]
		var frac = clampf(shown - i, 0.0, 1.0)
		var n = int(ceil(pts.size() * frac))
		if n < 2:
			continue
		var out = PackedVector2Array()
		for k in n:
			out.append(Vector2(pts[k].x * size.x, pts[k].y * size.y))
		var col: Color = s["col"]
		var w: float = s["w"]
		draw_polyline(out, Color(col, col.a * 0.3), w + 2.5, true)
		draw_polyline(out, col, w, true)
