extends Node3D

@onready var body: AnimatableBody3D = $PlataformaMovil
@onready var area: Area3D = $PlataformaMovil/AreaAscensor
@onready var mesh: MeshInstance3D = $PlataformaMovil/MeshInstance3D
@onready var audio = $PlataformaMovil/MovingAudio

## Altura en metros que sube el ascensor desde su posicion inicial.
@export var lift_height: float = 5.0
## Velocidad de desplazamiento en metros por segundo.
@export var lift_speed: float = 2.0

var _start_pos: Vector3  # Posicion inicial del cuerpo animable
var _end_pos: Vector3    # Posicion final tras subir lift_height metros
var _tween: Tween

func _ready() -> void:
	_start_pos = body.global_position
	_end_pos = _start_pos + Vector3(0, lift_height, 0)

	# Copia unica del material para poder modificar la emision de este ascensor
	# sin afectar a otras instancias que compartan el mismo material base
	var mat = mesh.get_active_material(0)
	mesh.material_override = mat.duplicate()

	_set_indicator(false)

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	audio.stop()

## Cuando el jugador entra en el area, activa el indicador visual y sube el ascensor.
func _on_body_entered(body_node: Node) -> void:
	if body_node.is_in_group("player_body"):
		_set_indicator(true)
		_move_to(_end_pos)

## Cuando el jugador sale del area, desactiva el indicador visual y baja el ascensor.
func _on_body_exited(body_node: Node) -> void:
	if body_node.is_in_group("player_body"):
		_set_indicator(false)
		_move_to(_start_pos)

## Mueve el cuerpo del ascensor hacia [param target] a velocidad constante.
## Cancela cualquier movimiento previo antes de iniciar el nuevo.
## La duracion se calcula a partir de la distancia restante y lift_speed,
## de modo que la velocidad es siempre uniforme independientemente
## de si el ascensor esta a mitad de recorrido.
func _move_to(target: Vector3) -> void:
	audio.play()
	if _tween:
		_tween.kill()
	var distance = body.global_position.distance_to(target)
	var duration = distance / lift_speed
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(body, "position", target - global_position, duration)
	audio.stop()

## Activa o desactiva la emision del material para indicar visualmente
## si el ascensor esta en movimiento (azul brillante) o en reposo.
func _set_indicator(active: bool) -> void:
	var mat = mesh.material_override
	if active:
		mat.emission_enabled = true
		mat.emission = Color(0.2, 0.8, 1.0)  # azul brillante
		mat.emission_energy_multiplier = 1.5
	else:
		mat.emission_enabled = false
