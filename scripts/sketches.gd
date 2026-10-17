extends RefCounted
## Procedural "Leonardo notebook" drawings. Coordinates are normalized (0..1)
## for a sketch area with aspect ratio A (width / height).

const A := 1.4
const INK := Color(0.23, 0.15, 0.09)
const RED := Color(0.64, 0.27, 0.17)


static func o(c: Vector2, x: float, y: float) -> Vector2:
	return c + Vector2(x / A, y)


static func st(pts: PackedVector2Array, col: Color, w: float = 2.0) -> Dictionary:
	return {"pts": pts, "col": col, "w": w}


static func circle(c: Vector2, r: float, col: Color, w: float = 2.0, a0: float = 0.0, a1: float = TAU, steps: int = 40) -> Dictionary:
	var pts = PackedVector2Array()
	for i in steps + 1:
		var a: float = lerpf(a0, a1, float(i) / steps)
		pts.append(c + Vector2(cos(a) * r / A, sin(a) * r))
	return st(pts, col, w)


static func line(a: Vector2, b: Vector2, col: Color, w: float = 2.0) -> Dictionary:
	var pts = PackedVector2Array()
	for i in 9:
		pts.append(a.lerp(b, i / 8.0))
	return st(pts, col, w)


static func path(points: Array, col: Color, w: float = 2.0) -> Dictionary:
	var pts = PackedVector2Array()
	for i in points.size() - 1:
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		for k in 6:
			pts.append(a.lerp(b, k / 6.0))
	pts.append(points[points.size() - 1])
	return st(pts, col, w)


static func wave(y: float, amp: float, freq: float, col: Color, w: float = 1.5) -> Dictionary:
	var pts = []
	for i in 24:
		var x = 0.04 + 0.92 * i / 23.0
		pts.append(Vector2(x, y + amp * sin(x * freq)))
	return path(pts, col, w)


static func figure(c: Vector2, s: float, col: Color, pose: String = "stand") -> Array:
	var out = []
	out.append(circle(o(c, 0, -0.42 * s), 0.075 * s, col))
	if pose == "seated":
		out.append(line(o(c, 0, -0.34 * s), o(c, 0, -0.05 * s), col))
		out.append(path([o(c, 0, -0.05 * s), o(c, 0.18 * s, -0.04 * s), o(c, 0.2 * s, 0.15 * s)], col))
		out.append(line(o(c, 0, -0.26 * s), o(c, 0.15 * s, -0.12 * s), col))
		return out
	out.append(line(o(c, 0, -0.34 * s), o(c, 0, 0.02 * s), col))
	match pose:
		"out":
			out.append(line(o(c, -0.36 * s, -0.26 * s), o(c, 0.36 * s, -0.26 * s), col))
			out.append(line(o(c, 0, 0.02 * s), o(c, -0.2 * s, 0.4 * s), col))
			out.append(line(o(c, 0, 0.02 * s), o(c, 0.2 * s, 0.4 * s), col))
		"up":
			out.append(line(o(c, 0, -0.27 * s), o(c, -0.32 * s, -0.5 * s), col))
			out.append(line(o(c, 0, -0.27 * s), o(c, 0.32 * s, -0.5 * s), col))
			out.append(line(o(c, 0, 0.02 * s), o(c, -0.07 * s, 0.42 * s), col))
			out.append(line(o(c, 0, 0.02 * s), o(c, 0.07 * s, 0.42 * s), col))
		_:
			out.append(line(o(c, 0, -0.27 * s), o(c, -0.15 * s, -0.04 * s), col))
			out.append(line(o(c, 0, -0.27 * s), o(c, 0.15 * s, -0.04 * s), col))
			out.append(line(o(c, 0, 0.02 * s), o(c, -0.09 * s, 0.36 * s), col))
			out.append(line(o(c, 0, 0.02 * s), o(c, 0.09 * s, 0.36 * s), col))
	return out


static func vitruvian(c: Vector2, s: float) -> Array:
	var out = []
	out.append(circle(c, 0.45 * s, RED, 2.0))
	out.append(path([o(c, -0.4 * s, -0.42 * s), o(c, 0.4 * s, -0.42 * s), o(c, 0.4 * s, 0.42 * s), o(c, -0.4 * s, 0.42 * s), o(c, -0.4 * s, -0.42 * s)], RED, 2.0))
	out.append_array(figure(c, s, INK, "out"))
	out.append_array(figure(c, s, Color(INK, 0.4), "up"))
	return out


static func tunnel(col: Color) -> Array:
	return [circle(Vector2(0.5, 0.9), 0.62, col, 2.5, PI, TAU), circle(Vector2(0.5, 0.9), 0.5, Color(col, 0.5), 1.5, PI, TAU), line(Vector2(0.03, 0.9), Vector2(0.97, 0.9), col)]


static func build(name: String) -> Array:
	var out = []
	match name:
		"title":
			out = vitruvian(Vector2(0.5, 0.5), 0.92)
		"hero":
			out = vitruvian(Vector2(0.5, 0.5), 0.9)
		"lanterns":
			out.append(path([Vector2(0.03, 0.66), Vector2(0.12, 0.52), Vector2(0.22, 0.66), Vector2(0.3, 0.56), Vector2(0.42, 0.44), Vector2(0.54, 0.62), Vector2(0.64, 0.52), Vector2(0.78, 0.4), Vector2(0.9, 0.6), Vector2(0.97, 0.56)], INK))
			var sp = []
			for i in 11:
				var t = i / 10.0
				sp.append(Vector2(0.05 + 0.9 * t, 0.12 + 0.12 * sin(PI * t)))
			out.append(path(sp, INK, 1.5))
			for i in range(1, 8):
				var t = i / 8.0
				var p = Vector2(0.05 + 0.9 * t, 0.12 + 0.12 * sin(PI * t))
				out.append(line(p, p + Vector2(0, 0.05), INK, 1.5))
				out.append(circle(p + Vector2(0, 0.09), 0.04, RED, 2.5))
			out.append(wave(0.76, 0.012, 38.0, INK))
			out.append(wave(0.83, 0.012, 31.0, Color(INK, 0.7)))
			out.append(wave(0.9, 0.012, 44.0, Color(INK, 0.5)))
			for x in [0.3, 0.5, 0.7]:
				out.append(circle(Vector2(x, 0.7), 0.03, Color(INK, 0.4), 1.2, 0.0, TAU * 1.5))
		"dragon":
			out.append(circle(Vector2(0.74, 0.24), 0.15, INK, 1.5))
			out.append(path([Vector2(0.05, 0.6), Vector2(0.12, 0.56), Vector2(0.2, 0.55), Vector2(0.32, 0.5), Vector2(0.5, 0.48), Vector2(0.66, 0.44), Vector2(0.76, 0.39), Vector2(0.82, 0.4), Vector2(0.79, 0.44), Vector2(0.74, 0.44)], RED, 3.0))
			out.append(path([Vector2(0.34, 0.49), Vector2(0.42, 0.14), Vector2(0.48, 0.3), Vector2(0.56, 0.1), Vector2(0.6, 0.3), Vector2(0.7, 0.18), Vector2(0.64, 0.43)], RED, 3.0))
			out.append(path([Vector2(0.4, 0.5), Vector2(0.46, 0.62), Vector2(0.52, 0.56), Vector2(0.58, 0.66), Vector2(0.6, 0.47)], Color(RED, 0.6), 2.0))
			var flames = []
			for i in 21:
				flames.append(Vector2(0.03 + 0.94 * i / 20.0, 0.95 if i % 2 == 0 else 0.8 - 0.05 * sin(i)))
			out.append(path(flames, RED, 2.5))
			for x in [0.2, 0.45, 0.8]:
				out.append(circle(Vector2(x, 0.72), 0.05, Color(INK, 0.35), 1.2, 0.0, TAU * 1.3))
		"gate":
			out.append(path([Vector2(0.12, 0.88), Vector2(0.12, 0.22), Vector2(0.28, 0.22), Vector2(0.28, 0.88)], INK, 2.5))
			out.append(path([Vector2(0.72, 0.88), Vector2(0.72, 0.22), Vector2(0.88, 0.22), Vector2(0.88, 0.88)], INK, 2.5))
			out.append(circle(Vector2(0.5, 0.5), 0.3, INK, 2.5, PI, TAU))
			out.append(line(Vector2(0.03, 0.88), Vector2(0.97, 0.88), INK))
			out.append_array(figure(Vector2(0.5, 0.62), 0.42, INK, "stand"))
			out.append(path([Vector2(0.53, 0.5), Vector2(0.6, 0.5), Vector2(0.6, 0.68), Vector2(0.565, 0.73), Vector2(0.53, 0.68), Vector2(0.53, 0.5)], RED, 3.0))
			for i in 6:
				out.append(line(Vector2(0.32 + i * 0.07, 0.16), Vector2(0.36 + i * 0.07, 0.04), Color(RED, 0.5), 1.5))
		"four":
			out.append_array(tunnel(INK))
			for i in 4:
				out.append_array(figure(Vector2(0.3 + i * 0.13, 0.66), 0.36, RED, "stand"))
		"raiders":
			out.append_array(tunnel(INK))
			for i in 4:
				var c = Vector2(0.26 + i * 0.16, 0.66)
				out.append_array(figure(c, 0.36, INK, "stand"))
				out.append(line(Sketches_o(c, -0.04, -0.47), Sketches_o(c, 0.04, -0.47), INK, 3.0))
				out.append(line(Sketches_o(c, 0.06, 0.3), Sketches_o(c, 0.1, -0.24), RED, 2.0))
		"campfire":
			out.append(line(Vector2(0.42, 0.84), Vector2(0.58, 0.76), INK, 3.0))
			out.append(line(Vector2(0.42, 0.76), Vector2(0.58, 0.84), INK, 3.0))
			out.append(path([Vector2(0.44, 0.76), Vector2(0.46, 0.6), Vector2(0.48, 0.68), Vector2(0.5, 0.48), Vector2(0.52, 0.66), Vector2(0.54, 0.58), Vector2(0.56, 0.76)], RED, 3.0))
			out.append_array(figure(Vector2(0.2, 0.74), 0.34, INK, "seated"))
			out.append_array(figure(Vector2(0.33, 0.6), 0.3, INK, "seated"))
			out.append_array(figure(Vector2(0.64, 0.6), 0.3, INK, "seated"))
			out.append_array(figure(Vector2(0.77, 0.74), 0.34, INK, "seated"))
			for p in [Vector2(0.15, 0.12), Vector2(0.4, 0.08), Vector2(0.62, 0.15), Vector2(0.85, 0.1)]:
				out.append(circle(p, 0.012, INK, 1.5))
	return out


static func Sketches_o(c: Vector2, x: float, y: float) -> Vector2:
	return o(c, x * 0.36, y * 0.36)
