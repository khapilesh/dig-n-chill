extends Node

const SAVE_PATH := "user://settings.cfg"

var volume: float = 0.8
var vibration: bool = true


func _ready() -> void:
	_load()
	_apply_volume()


func set_volume(value: float) -> void:
	volume = value
	_apply_volume()
	_save()


func set_vibration(value: bool) -> void:
	vibration = value
	_save()


func _apply_volume() -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(clamp(volume, 0.0001, 1.0)))


func _load() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		volume = config.get_value("audio", "volume", volume)
		vibration = config.get_value("game", "vibration", vibration)


func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.set_value("game", "vibration", vibration)
	config.save(SAVE_PATH)
