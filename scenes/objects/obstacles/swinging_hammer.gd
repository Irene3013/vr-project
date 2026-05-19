extends Node3D

@export var swing_angle_degrees := 55.0
@export var swing_speed := 1.15
@export var push_strength := 8.0
@export var lift_strength := 1.2

@onready var pivot: Node3D = $Pivot
@onready var push_area: Area3D = $Pivot/HammerHead/PushArea

var _time := 0.0
var _previous_angle := 0.0
var _angular_velocity := 0.0
var _overlapping_bodies: Array[Node3D] = []

func _ready() -> void:
	_previous_angle = pivot.rotation.z
	push_area.body_entered.connect(_on_push_area_body_entered)
	push_area.body_exited.connect(_on_push_area_body_exited)

func _physics_process(delta: float) -> void:
	_time += delta

	var angle := deg_to_rad(swing_angle_degrees) * sin(_time * TAU * swing_speed)
	_angular_velocity = (angle - _previous_angle) / max(delta, 0.001)
	_previous_angle = angle
	pivot.rotation.z = angle

	for body in _overlapping_bodies:
		if is_instance_valid(body):
			_push_body(body)

func _on_push_area_body_entered(body: Node3D) -> void:
	if not _is_pushable(body):
		return

	if not _overlapping_bodies.has(body):
		_overlapping_bodies.append(body)
	_push_body(body)

func _on_push_area_body_exited(body: Node3D) -> void:
	_overlapping_bodies.erase(body)

func _push_body(body: Node3D) -> void:
	var direction := global_transform.basis.x.normalized() * signf(_angular_velocity)
	if direction.is_zero_approx():
		direction = global_transform.basis.x.normalized()

	var push_velocity := direction * push_strength + Vector3.UP * lift_strength
	if body is CharacterBody3D:
		body.velocity.x = push_velocity.x
		body.velocity.z = push_velocity.z
		body.velocity.y = max(body.velocity.y, push_velocity.y)
	elif body is RigidBody3D:
		body.apply_central_impulse(push_velocity * body.mass)

func _is_pushable(body: Node3D) -> bool:
	return body.is_in_group("player_body") or body is CharacterBody3D or body is RigidBody3D
