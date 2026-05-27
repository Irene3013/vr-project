extends StaticBody3D

## Tiempo en segundos desde que el jugador la pisa hasta que empieza a caer.
@export var collapse_delay := 1.0
## Tiempo en segundos que tarda en reaparecer tras caer.
@export var respawn_delay := 2.5
## Distancia en metros que cae la plataforma antes de desaparecer.
@export var fall_distance := 3.0
## Duracion en segundos de la animacion de caida.
@export var fall_duration := 0.35

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var trigger_area: Area3D = $TriggerArea
@onready var trigger_shape: CollisionShape3D = $TriggerArea/CollisionShape3D
@onready var sound = $FallingAudio3D

const TRIGGER_AUDIO = preload("res://assets/audio/button-press.ogg")  # Sonido al pisar
const FALLING_AUDIO = preload("res://assets/audio/falling-whistle-cartoon.ogg")  # Sonido al caer

var _start_position := Vector3.ZERO  # Posicion original para poder reaparecer en ella
var _armed := true  # Evita activaciones multiples mientras la plataforma esta cayendo o reapareciendo

func _ready() -> void:
	_start_position = position
	trigger_area.body_entered.connect(_on_trigger_area_body_entered)

## Cuando el jugador entra en el area de disparo, inicia la secuencia:
## espera collapse_delay, cae, espera respawn_delay y reaparece.
func _on_trigger_area_body_entered(body: Node3D) -> void:
	if not _armed or not _is_player(body):
		return

	sound.stream = TRIGGER_AUDIO
	sound.play()

	_armed = false
	await get_tree().create_timer(collapse_delay).timeout
	await _collapse()
	await get_tree().create_timer(respawn_delay).timeout
	_respawn()

## Desactiva la colision, reproduce el sonido de caida y anima el descenso.
## La plataforma se hace invisible al terminar la animacion.
func _collapse() -> void:
	collision_shape.disabled = true
	trigger_shape.disabled = true

	sound.stream = FALLING_AUDIO
	sound.play()

	var tween := create_tween()
	tween.tween_property(self, "position", _start_position + Vector3.DOWN * fall_distance, fall_duration)
	await tween.finished
	mesh_instance.visible = false

## Devuelve la plataforma a su posicion y estado original, lista para volver a activarse.
func _respawn() -> void:
	position = _start_position
	mesh_instance.visible = true
	collision_shape.disabled = false
	trigger_shape.disabled = false
	_armed = true

## Devuelve true si el cuerpo es el jugador XR o un CharacterBody3D.
func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player_body") or body is CharacterBody3D