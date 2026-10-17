extends Control
## A Control that draws through a callback, so screens can draw without extra scripts.

var draw_fn: Callable
var animate = false


func _init(fn: Callable = Callable(), anim: bool = false) -> void:
	draw_fn = fn
	animate = anim
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if animate:
		queue_redraw()


func _draw() -> void:
	if draw_fn.is_valid():
		draw_fn.call(self)
