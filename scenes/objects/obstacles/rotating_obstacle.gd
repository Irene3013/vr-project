extends Node3D

## Eje local sobre el que rota el obstaculo. Por defecto Vector3.UP (gira en horizontal).
@export var rotation_axis := Vector3.UP
## Velocidad de rotacion en grados por segundo. Valores negativos invierten el sentido.
@export var rotation_speed_degrees := 75.0
## Fuerza tangencial aplicada al jugador cuando el palo lo golpea.
@export var push_strength := 6.0
## Fuerza vertical adicional aplicada al jugador para evitar que quede atrapado bajo el palo.
@export var lift_strength := 0.8

@onready var push_area: Area3D = $PushArea
@onready var rotating_audio = $RotatingAudio3D

## Lista de cuerpos actualmente dentro del area de empuje, actualizada en cada frame.
var _overlapping_bodies: Array[Node3D] = []

func _ready() -> void:
	push_area.body_entered.connect(_on_push_area_body_entered)
	push_area.body_exited.connect(_on_push_area_body_exited)
	rotating_audio.play()

## Rota el obstaculo y aplica el empuje a todos los cuerpos dentro del area.
func _physics_process(delta: float) -> void:
	var axis := rotation_axis.normalized()
	if axis.is_zero_approx():
		axis = Vector3.UP
	rotate_object_local(axis, deg_to_rad(rotation_speed_degrees) * delta)
	for body in _overlapping_bodies:
		if is_instance_valid(body):
			_push_body(body, axis)

## Añade el cuerpo a la lista de overlapping y le aplica un empuje inmediato al entrar.
func _on_push_area_body_entered(body: Node3D) -> void:
	if not _is_pushable(body):
		return
	if not _overlapping_bodies.has(body):
		_overlapping_bodies.append(body)
	_push_body(body, rotation_axis.normalized())

## Elimina el cuerpo de la lista de overlapping al salir del area.
func _on_push_area_body_exited(body: Node3D) -> void:
	_overlapping_bodies.erase(body)

## Calcula y aplica la velocidad de empuje tangencial al cuerpo dado.
## La direccion tangente se obtiene del producto vectorial entre el eje de rotacion
## y el vector radial desde el centro del obstaculo hasta el cuerpo,
## de modo que el empuje siempre va en el sentido de giro.
func _push_body(body: Node3D, axis: Vector3) -> void:
	if axis.is_zero_approx():
		axis = Vector3.UP
	var radial := body.global_position - global_position
	var tangent := axis.cross(radial).normalized()
	if tangent.is_zero_approx():
		tangent = global_transform.basis.x.normalized()
	tangent *= signf(rotation_speed_degrees) if rotation_speed_degrees != 0.0 else 1.0
	var push_velocity := tangent * push_strength + Vector3.UP * lift_strength
	if body is CharacterBody3D:
		body.velocity.x = push_velocity.x
		body.velocity.z = push_velocity.z
		body.velocity.y = max(body.velocity.y, push_velocity.y)  # No reduce la velocidad vertical si ya es mayor
	elif body is RigidBody3D:
		body.apply_central_impulse(push_velocity * body.mass)

## Devuelve true si el cuerpo puede ser empujado por el obstaculo.
func _is_pushable(body: Node3D) -> bool:
	return body.is_in_group("player_body") or body is CharacterBody3D or body is RigidBody3D
