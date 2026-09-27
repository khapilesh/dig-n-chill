extends Node2D
# Procedural autumn leaves - shaped blades with a center vein, not just dots.

const LEAF_COUNT := 18

const PALETTE := [
	Color(0.82, 0.30, 0.09),  # burnt orange
	Color(0.90, 0.55, 0.12),  # pumpkin
	Color(0.93, 0.72, 0.22),  # gold
	Color(0.64, 0.16, 0.10),  # cranberry
	Color(0.52, 0.32, 0.14),  # walnut
]

var _leaves: Array = []


func _ready() -> void:
	randomize()
	var vp := get_viewport_rect().size
	for i in LEAF_COUNT:
		var depth := randf_range(0.5, 1.4)  # smaller & slower reads as "further away"
		var leaf := _spawn_leaf(depth)
		leaf.position = Vector2(randf() * vp.x, randf_range(-vp.y, vp.y))
		add_child(leaf)
		_leaves.append({
			"node": leaf,
			"fall_speed": randf_range(24.0, 55.0) * depth,
			"sway_speed": randf_range(0.8, 2.0),
			"sway_amount": randf_range(18.0, 42.0) * depth,
			"spin_speed": randf_range(-2.2, 2.2) / depth,
			"depth": depth,
			"phase": randf() * TAU,
			"flutter_phase": randf() * TAU,
		})


func _process(delta: float) -> void:
	var vp := get_viewport_rect().size
	for data in _leaves:
		var leaf: Node2D = data["node"]
		data["phase"] += delta * data["sway_speed"]
		data["flutter_phase"] += delta * 4.0

		leaf.position.y += data["fall_speed"] * delta
		leaf.position.x += sin(data["phase"]) * data["sway_amount"] * delta
		leaf.rotation += data["spin_speed"] * delta

		# a slight horizontal squash as it tumbles, like it's catching the light
		var flutter: float = 1.0 - 0.15 * abs(sin(data["flutter_phase"]))
		leaf.scale = Vector2(flutter, 1.0) * data["depth"]

		if leaf.position.y > vp.y + 24:
			leaf.position.y = -24.0
			leaf.position.x = randf() * vp.x


func _spawn_leaf(depth: float) -> Node2D:
	var holder := Node2D.new()
	var base_color: Color = PALETTE[randi() % PALETTE.size()]
	base_color = base_color.lightened(randf_range(-0.05, 0.12))

	var shape := _leaf_shape(randf_range(9.0, 15.0), randf_range(6.0, 10.0))

	var body := Polygon2D.new()
	body.polygon = shape
	body.color = base_color
	holder.add_child(body)

	var vein := Line2D.new()
	vein.width = 1.0
	vein.default_color = base_color.darkened(0.35)
	vein.points = PackedVector2Array([shape[0], shape[5]])
	holder.add_child(vein)

	holder.z_index = int(depth * 10.0)
	holder.modulate.a = clamp(depth, 0.55, 1.0)
	return holder


func _leaf_shape(length: float, width: float) -> PackedVector2Array:
	# A simple ten-point leaf blade, tip at one end, stem notch at the other.
	var half := width * 0.5
	var raw := [
		Vector2(0, -length * 0.5),
		Vector2(half * 0.55, -length * 0.26),
		Vector2(half, -length * 0.02),
		Vector2(half * 0.68, length * 0.24),
		Vector2(half * 0.22, length * 0.4),
		Vector2(0, length * 0.5),
		Vector2(-half * 0.22, length * 0.4),
		Vector2(-half * 0.68, length * 0.24),
		Vector2(-half, -length * 0.02),
		Vector2(-half * 0.55, -length * 0.26),
	]
	# tiny jitter per point so no two leaves are perfect copies of each other
	var pts := PackedVector2Array()
	for p in raw:
		pts.append(p + Vector2(randf_range(-0.6, 0.6), randf_range(-0.6, 0.6)))
	return pts
