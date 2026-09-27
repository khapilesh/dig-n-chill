extends Control


func _ready() -> void:
	$CenterContainer/SettingsPanel/SettingsContainer/VolumeRow/VolumeSlider.value = Settings.volume
	$CenterContainer/SettingsPanel/SettingsContainer/VibrationRow/VibrationToggle.button_pressed = Settings.vibration
	call_deferred("_play_intro")


func _play_intro() -> void:
	var panel := $CenterContainer/SettingsPanel
	panel.pivot_offset = panel.size * 0.5
	panel.rotation_degrees = 0.9
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.88, 0.88)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.45) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_volume_slider_value_changed(value: float) -> void:
	Settings.set_volume(value)


func _on_vibration_toggle_toggled(toggled_on: bool) -> void:
	Settings.set_vibration(toggled_on)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
