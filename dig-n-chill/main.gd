extends Node2D

const SOURCE_ID: int = 0
const ATLAS_COORDS: Vector2i = Vector2i(0, 0)
const ROOT_CHANCE: float = 0.18

@onready var terrain: TileMapLayer = $Terrain
@onready var player: CharacterBody2D = $Player
@onready var status_label: Label = $HUD/StatusLabel

var random_generator: RandomNumberGenerator = RandomNumberGenerator.new()
var roots_by_cell: Dictionary = {}
var roots_found: int = 0

func _ready() -> void:
	random_generator.randomize()
	generate_world()
	
	# Make generated tiles and their collision available immediately.
	terrain.update_internals()
	
	player.connect("dig_requested", Callable(self, "dig_in_front_of_player"))

	player.global_position = terrain.to_global(
		terrain.map_to_local(Vector2i(1, -1))
	)

	status_label.text = "Roots: 0\nA/D: move   Space: jump   E: dig"
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

	# Check exactly one grid cell in front of the player.
	var target_cell: Vector2i = player_cell + Vector2i(direction, 0)

	# TileMapLayer returns -1 if the cell is empty.
	if terrain.get_cell_source_id(target_cell) == -1:
		show_status("Roots: %d\nNo soil in front of you." % roots_found)
		return

	terrain.erase_cell(target_cell)

	if roots_by_cell.has(target_cell):
		roots_by_cell.erase(target_cell)
		roots_found += 1
		show_status("Roots: %d\nYou found a root!" % roots_found)
	else:
		show_status("Roots: %d\nYou dug out some soil." % roots_found)

func show_status(message: String) -> void:
	status_label.text = message
