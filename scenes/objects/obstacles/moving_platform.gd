extends StaticBody3D

@export var movement_offset := Vector3(2.0, 0.0, 0.0)
@export var cycle_time := 4.0
@export var phase := 0.0
@onready var move_sound = $AudioEffect3D

var _start_position := Vector3.ZERO
var _time := 0.0

func _ready() -> void:
	move_sound.play()
	_start_position = position

func _physics_process(delta: float) -> void:
	_time += delta
	var safe_cycle_time: float = max(cycle_time, 0.1)
	var wave: float = sin(((_time / safe_cycle_time) + phase) * TAU) * 0.5 + 0.5
	position = _start_position + movement_offset * wave
