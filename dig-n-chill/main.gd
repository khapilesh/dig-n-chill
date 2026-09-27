extends Node2D

const SOURCE_ID: int = 0
const ATLAS_COORDS: Vector2i = Vector2i(0, 0)
const ROOT_CHANCE: float = 0.18
const ROOT_GOAL: int = 5
@onready var terrain: TileMapLayer = $Terrain
@onready var player: CharacterBody2D = $Player
@onready var status_label: Label = $HUD/StatusLabel

var random_generator: RandomNumberGenerator = RandomNumberGenerator.new()
var roots_by_cell: Dictionary = {}
var roots_found: int = 0

func _ready() -> void:
	random_generator.randomize()
	add_dirt_collision()
	generate_world()

	# Make generated tiles and their collision available immediately.
	terrain.update_internals()
	var tile_data = terrain.get_cell_tile_data(Vector2i(5, -1))
	if tile_data == null:
		print("TEST: no tile data at (5, -1)")
	else:
		print("TEST: collider polygons = ",
		tile_data.get_collision_polygons_count(0))

	print("TEST: Player detects layer 1 = ",
	player.get_collision_mask_value(1))
	player.connect("dig_requested", Callable(self, "dig_in_front_of_player"))

	player.global_position = terrain.to_global(
		terrain.map_to_local(Vector2i(1, -1))
	)

	status_label.text = "Roots: 0/5\nA/D: move   Space: jump   E: dig"
func generate_world() -> void:
	# Make the floor. Tile row 0 is below the player's starting row.
	for x in range(-3, 46):
		var floor_cell := Vector2i(x, 0)
		terrain.set_cell(floor_cell, SOURCE_ID, ATLAS_COORDS)

	# Make a dirt wall. Negative Y rows appear above the floor in 2D.
	for x in range(5, 46):
		for y in range(-1, -7, -1):
			var soil_cell := Vector2i(x, y)
			terrain.set_cell(soil_cell, SOURCE_ID, ATLAS_COORDS)

			# Store only the cells that contain roots.
			if random_generator.randf() < ROOT_CHANCE:
				roots_by_cell[soil_cell] = true

func dig_in_front_of_player() -> void:
	var player_local_position: Vector2 = terrain.to_local(player.global_position)
	var player_cell: Vector2i = terrain.local_to_map(player_local_position)
	var direction: int = int(player.get("facing"))
	var target_cell: Vector2i = player_cell + Vector2i(direction, 0)

	if terrain.get_cell_source_id(target_cell) == -1:
		show_status("Roots: %d/%d\nNo soil in front of you." % [roots_found, ROOT_GOAL])
		return

	terrain.erase_cell(target_cell)

	if roots_by_cell.has(target_cell):
		roots_by_cell.erase(target_cell)
		roots_found += 1

		if roots_found >= ROOT_GOAL:
			show_status("Roots: %d/%d\nYou found all the roots! You win!" % [roots_found, ROOT_GOAL])
			player.set_physics_process(false)
			await get_tree().create_timer(2.0).timeout

			get_tree().change_scene_to_file("res://main_menu.tscn")
			return

		show_status("Roots: %d/%d\nYou found a root!" % [roots_found, ROOT_GOAL])
	else:
		show_status("Roots: %d/%d\nYou dug out some soil." % [roots_found, ROOT_GOAL])

func show_status(message: String) -> void:
	status_label.text = message
func add_dirt_collision() -> void:
	var atlas := terrain.tile_set.get_source(SOURCE_ID) as TileSetAtlasSource

	if atlas == null:
		push_error("Could not find the dirt atlas source.")
		return

	var tile_data := atlas.get_tile_data(ATLAS_COORDS, 0)

	if tile_data == null:
		push_error("Could not find the dirt tile at atlas coordinates (0, 0).")
		return
	var half_size := Vector2(terrain.tile_set.tile_size) / 2.0
	var rectangle := PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2( half_size.x, -half_size.y),
		Vector2( half_size.x,  half_size.y),
		Vector2(-half_size.x,  half_size.y)
	])

	tile_data.set_collision_polygons_count(0, 1)
	tile_data.set_collision_polygon_points(0, 0, rectangle)
