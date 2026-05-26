# run_data.gd
class_name RunData
extends Resource

@export var player_name: String = ""
@export var time_seconds: float = 0.0
@export var deaths: int = 0
@export var date: String = ""

func get_time_formatted() -> String:
	var minutes := int(time_seconds) / 60
	var seconds := int(time_seconds) % 60
	var millis := int((time_seconds - floor(time_seconds)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, millis]
