extends Node3D

## Scene de una fila de 3 puertas.
## Selecciona exactamente una puerta correcta al iniciar el nivel y configura
## las demás como sólidas/falsas.

@export var randomize_on_ready := true
@export_range(0, 2, 1) var forced_correct_index := 0

var correct_index := 0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	if randomize_on_ready:
		randomize_correct_door()
	else:
		_set_correct_door(forced_correct_index)

func randomize_correct_door() -> void:
	var doors := _get_doors()
	if doors.is_empty():
		return

	_rng.randomize()
	_set_correct_door(_rng.randi_range(0, doors.size() - 1))

func _set_correct_door(index: int) -> void:
	var doors := _get_doors()
	if doors.is_empty():
		return

	correct_index = clampi(index, 0, doors.size() - 1)
	for i in range(doors.size()):
		if doors[i].has_method("configure"):
			doors[i].configure(i == correct_index)

func _get_doors() -> Array[Node]:
	var doors: Array[Node] = []
	for child in get_children():
		if child.has_method("configure"):
			doors.append(child)
	return doors
