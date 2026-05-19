extends StaticBody3D

@export var collapse_delay := 1.0
@export var respawn_delay := 2.5
@export var fall_distance := 3.0
@export var fall_duration := 0.35

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var trigger_area: Area3D = $TriggerArea
@onready var trigger_shape: CollisionShape3D = $TriggerArea/CollisionShape3D

var _start_position := Vector3.ZERO
var _armed := true

func _ready() -> void:
	_start_position = position
	trigger_area.body_entered.connect(_on_trigger_area_body_entered)

func _on_trigger_area_body_entered(body: Node3D) -> void:
	if not _armed or not _is_player(body):
		return

	_armed = false
	await get_tree().create_timer(collapse_delay).timeout
	await _collapse()
	await get_tree().create_timer(respawn_delay).timeout
	_respawn()

func _collapse() -> void:
	collision_shape.disabled = true
	trigger_shape.disabled = true

	var tween := create_tween()
	tween.tween_property(self, "position", _start_position + Vector3.DOWN * fall_distance, fall_duration)
	await tween.finished
	mesh_instance.visible = false

func _respawn() -> void:
	position = _start_position
	mesh_instance.visible = true
	collision_shape.disabled = false
	trigger_shape.disabled = false
	_armed = true

func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player_body") or body is CharacterBody3D
