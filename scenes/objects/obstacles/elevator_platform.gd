extends StaticBody3D

## Plataforma elevadora.
## Sube cuando el jugador entra en el área y vuelve a su punto inicial
## 2 segundos después de que el jugador sale.

@export var lift_offset := Vector3(0.0, 8.75, 0.0)
@export var move_speed := 3.0
@export var return_delay := 2.0

@onready var player_area: Area3D = $PlayerArea

var _start_position := Vector3.ZERO
var _target_position := Vector3.ZERO
var _players_on_platform: Array[Node3D] = []
var _return_timer: SceneTreeTimer

func _ready() -> void:
	_start_position = position
	_target_position = _start_position
	player_area.body_entered.connect(_on_player_area_body_entered)
	player_area.body_exited.connect(_on_player_area_body_exited)

func _physics_process(delta: float) -> void:
	position = position.move_toward(_target_position, move_speed * delta)

func _on_player_area_body_entered(body: Node3D) -> void:
	if not _is_player(body):
		return

	if not _players_on_platform.has(body):
		_players_on_platform.append(body)

	# Cualquier reentrada cancela la bajada pendiente y vuelve a subir.
	_return_timer = null
	_target_position = _start_position + lift_offset

func _on_player_area_body_exited(body: Node3D) -> void:
	_players_on_platform.erase(body)
	if not _players_on_platform.is_empty():
		return

	_schedule_return()

func _schedule_return() -> void:
	var timer := get_tree().create_timer(return_delay)
	_return_timer = timer
	await timer.timeout

	# Si nadie volvió a entrar durante la espera, baja a su posición original.
	if _return_timer == timer and _players_on_platform.is_empty():
		_target_position = _start_position
		_return_timer = null

func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player_body") or body is CharacterBody3D
