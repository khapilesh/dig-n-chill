extends Control


func _ready() -> void:
	call_deferred("_play_intro")


func _play_intro() -> void:
	var panel := $CenterContainer/MenuPanel
	panel.pivot_offset = panel.size * 0.5
	panel.rotation_degrees = -1.1
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.88, 0.88)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.45) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://character_body_2d.tscn")


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://settings_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
