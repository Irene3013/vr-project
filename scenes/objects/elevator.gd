extends Node3D

@onready var body: AnimatableBody3D = $PlataformaMovil
@onready var area: Area3D = $PlataformaMovil/AreaAscensor
@onready var mesh: MeshInstance3D = $PlataformaMovil/MeshInstance3D

@export var lift_height: float = 5.0   # cuánto sube
@export var lift_speed: float = 2.0    # velocidad

var _start_pos: Vector3
var _end_pos: Vector3
var _tween: Tween

func _ready() -> void:
	_start_pos = body.global_position
	_end_pos = _start_pos + Vector3(0, lift_height, 0)
	
	# Copia única del material
	var mat = mesh.get_active_material(0)
	mesh.material_override = mat.duplicate()
	
	_set_indicator(false)
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body_node: Node) -> void:
	if body_node.is_in_group("player_body"):
		_set_indicator(true)
		_move_to(_end_pos)

func _on_body_exited(body_node: Node) -> void:
	if body_node.is_in_group("player_body"):
		_set_indicator(false)
		_move_to(_start_pos)

func _move_to(target: Vector3) -> void:
	if _tween:
		_tween.kill()

	var distance = body.global_position.distance_to(target)
	var duration = distance / lift_speed

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(body, "position", target - global_position, duration)


func _set_indicator(active: bool) -> void:
	var mat = mesh.material_override
	if active:
		mat.emission_enabled = true
		mat.emission = Color(0.2, 0.8, 1.0)  # azul brillante
		mat.emission_energy_multiplier = 1.5
	else:
		mat.emission_enabled = false
