extends Node3D

## Plataforma balanceable.
## Inclina un pivote central de forma suave
## según la posición lateral del jugador, evitando vibraciones bruscas.

@export var max_tilt_degrees := 12.0
@export var fall_tilt_degrees := 30.0 #38.0
@export var seconds_until_fall_tilt := 2.8
@export var tilt_smoothness := 4.5
@export var usable_half_width := 2.0

@onready var pivot: Node3D = $Pivot
@onready var player_area: Area3D = $Pivot/AnimatableBody3D/PlayerArea

var _players_on_platform: Array[Node3D] = []
var _occupied_time := 0.0
var _fallback_tilt_direction := 1.0

func _ready() -> void:
	player_area.body_entered.connect(_on_player_area_body_entered)
	player_area.body_exited.connect(_on_player_area_body_exited)

func _physics_process(delta: float) -> void:
	var target_angle: float = 0.0

	if not _players_on_platform.is_empty():
		_occupied_time += delta
		var average_x: float = 0.0
		var valid_players: int = 0
		for body in _players_on_platform:
			if is_instance_valid(body):
				average_x +=  pivot.to_local(body.global_position).x #to_local(body.global_position).x
				valid_players += 1

		if valid_players > 0:
			average_x /= valid_players
			var normalized_x: float = clamp(average_x / max(usable_half_width, 0.1), -1.0, 1.0)
			var tilt_direction: float = _get_tilt_direction(normalized_x)
			var time_pressure: float = clamp(_occupied_time / max(seconds_until_fall_tilt, 0.1), 0.0, 1.0)
			var dynamic_max_tilt: float = lerp(max_tilt_degrees, fall_tilt_degrees, time_pressure)
			var effective_weight: float = max(abs(normalized_x), time_pressure)
			# Rotación Z: al principio responde a la posición lateral; si el
			# jugador se queda quieto, la inclinación crece hasta hacerlo caer.
			target_angle = -tilt_direction * effective_weight * deg_to_rad(dynamic_max_tilt)
	else:
		_occupied_time = max(_occupied_time - delta * 2.0, 0.0)

	pivot.rotation.z = lerp_angle(pivot.rotation.z, target_angle, clamp(delta * tilt_smoothness, 0.0, 1.0))

func _on_player_area_body_entered(body: Node3D) -> void:
	if _is_player(body) and not _players_on_platform.has(body):
		_players_on_platform.append(body)
		_set_fallback_direction_from_body(body)

func _on_player_area_body_exited(body: Node3D) -> void:
	_players_on_platform.erase(body)
	if _players_on_platform.is_empty():
		_occupied_time = 0.0

func _get_tilt_direction(normalized_x: float) -> float:
	if abs(normalized_x) > 0.08:
		_fallback_tilt_direction = signf(normalized_x)
	return _fallback_tilt_direction

func _set_fallback_direction_from_body(body: Node3D) -> void:
	var local_x := pivot.to_local(body.global_position).x #to_local(body.global_position).x
	if abs(local_x) > 0.05:
		_fallback_tilt_direction = signf(local_x)
	else:
		_fallback_tilt_direction *= -1.0

func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player_body") or body is CharacterBody3D
