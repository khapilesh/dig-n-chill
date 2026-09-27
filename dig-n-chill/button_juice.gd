extends Button
# Gives buttons a bit of squish so they feel touched, not just clicked.

var _rest_scale := Vector2.ONE
var _hovering := false


func _ready() -> void:
	_refresh_pivot()
	resized.connect(_refresh_pivot)
	mouse_entered.connect(_on_hover_start)
	mouse_exited.connect(_on_hover_end)
	button_down.connect(_on_press)
	button_up.connect(_on_release)


func _refresh_pivot() -> void:
	pivot_offset = size * 0.5


func _on_hover_start() -> void:
	_hovering = true
	_animate(_rest_scale * 1.045, 0.12)


func _on_hover_end() -> void:
	_hovering = false
	_animate(_rest_scale, 0.14)


func _on_press() -> void:
	_animate(_rest_scale * 0.93, 0.06)


func _on_release() -> void:
	_animate(_rest_scale * 1.045 if _hovering else _rest_scale, 0.12)


func _animate(target: Vector2, duration: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", target, duration)
