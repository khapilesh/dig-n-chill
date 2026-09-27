extends Control
# Warm autumn sky - a hand-drawn gradient plus a soft glow, no image files needed.


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	_draw_sky()
	_draw_glow()


func _draw_sky() -> void:
	var top := Color(0.176, 0.098, 0.078)
	var bottom := Color(0.831, 0.596, 0.247)
	var pts := PackedVector2Array([
		Vector2(0, 0), Vector2(size.x, 0),
		Vector2(size.x, size.y), Vector2(0, size.y),
	])
	draw_polygon(pts, PackedColorArray([top, top, bottom, bottom]))


func _draw_glow() -> void:
	# Layered translucent circles fake a soft radial glow, like low autumn sun.
	var center := Vector2(size.x * 0.5, size.y * 0.24)
	var max_radius := size.x * 0.55
	var rings := 14
	for i in range(rings, 0, -1):
		var radius := max_radius * (float(i) / rings)
		draw_circle(center, radius, Color(1.0, 0.78, 0.4, 0.025))
