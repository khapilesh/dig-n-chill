extends CharacterBody2D

signal dig_requested

@export var move_speed: float = 150.0
@export var jump_strength: float = -320.0

const GRAVITY: float = 900.0

var facing: int = 1

func _physics_process(delta: float) -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * move_speed

	if direction > 0.0:
		facing = 1
	elif direction < 0.0:
		facing = -1

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength

	move_and_slide()

	if Input.is_action_just_pressed("dig"):
		dig_requested.emit()

func _draw() -> void:
	# Temporary player art so the prototype needs no sprite file.
	draw_rect(Rect2(-9, -14, 18, 28), Color("#6d9b79"), true)
	draw_circle(Vector2(3, -7), 2.0, Color("#f4e9cf"))
