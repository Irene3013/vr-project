extends Node3D

## Puerta modular
## La fila decide si esta puerta es correcta; la puerta solo gestiona su visual,
## colisión y detección de golpe para mantener la lógica separada.

signal opened

@export var open_fall_angle_degrees := 82.0
@export var open_duration := 0.35
@export var blocked_feedback_distance := 0.12
@export var backward_fall_offset := 0.35

@onready var door_body: StaticBody3D = $DoorBody
@onready var collision_shape: CollisionShape3D = $DoorBody/CollisionShape3D
@onready var hit_area: Area3D = $HitArea
@onready var mesh_instance: MeshInstance3D = $DoorBody/MeshInstance3D
@onready var open_audio: AudioStreamPlayer3D = $OpenAudio
@onready var locked_audio: AudioStreamPlayer3D = $LockedAudio

var is_correct := false
var _opened := false
var _feedback_running := false
var _closed_transform := Transform3D.IDENTITY

func _ready() -> void:
	_closed_transform = door_body.transform
	hit_area.body_entered.connect(_on_hit_area_body_entered)
	_set_visual_state(false)

func configure(correct: bool) -> void:
	is_correct = correct
	_opened = false
	if is_node_ready():
		door_body.transform = _closed_transform
		collision_shape.disabled = false
		hit_area.monitoring = true
		_set_visual_state(false)

func _on_hit_area_body_entered(body: Node3D) -> void:
	if _opened or not _is_player(body):
		return

	if is_correct:
		_open_correct_door()
	else:
		_show_blocked_feedback()

func _open_correct_door() -> void:
	_opened = true
	_set_visual_state(true)
	open_audio.play()

	# Desactivar colisión antes de animar garantiza paso estable en VR.
	collision_shape.disabled = true
	hit_area.monitoring = false

	var target_transform := _closed_transform
	# El nivel avanza hacia -Z; usar ángulo negativo y offset +Z hace que
	# la puerta caiga hacia atrás, alejándose del jugador que la golpea.
	target_transform = target_transform.rotated_local(Vector3.RIGHT, deg_to_rad(-abs(open_fall_angle_degrees)))
	target_transform.origin += Vector3(0.0, -0.25, backward_fall_offset)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(door_body, "transform", target_transform, open_duration)
	opened.emit()

func _show_blocked_feedback() -> void:
	if _feedback_running:
		return

	_feedback_running = true
	locked_audio.play()
	var bump_transform := _closed_transform
	bump_transform.origin += Vector3(0.0, 0.0, -blocked_feedback_distance)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(door_body, "transform", bump_transform, 0.08)
	tween.tween_property(door_body, "transform", _closed_transform, 0.12)
	await tween.finished
	_feedback_running = false

func _set_visual_state(opened_state: bool) -> void:
	var material := mesh_instance.get_active_material(0)
	if material:
		mesh_instance.material_override = material.duplicate()
		var override_material := mesh_instance.material_override as StandardMaterial3D
		if override_material:
			override_material.albedo_color = Color(0.1, 0.9, 0.45, 1.0) if opened_state else Color(0.95, 0.28, 0.55, 1.0)

func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player_body") or body is CharacterBody3D
