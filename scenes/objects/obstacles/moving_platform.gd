extends StaticBody3D

## Desplazamiento maximo respecto a la posicion inicial.
## La plataforma oscila entre su posicion original y original + movement_offset.
@export var movement_offset := Vector3(2.0, 0.0, 0.0)
## Tiempo en segundos de un ciclo completo de ida y vuelta.
@export var cycle_time := 4.0
## Desfase de fase entre 0.0 y 1.0, permite que varias plataformas
## se muevan desincronizadas entre si.
@export var phase := 0.0

@onready var move_sound = $AudioEffect3D

var _start_position := Vector3.ZERO
var _time := 0.0

func _ready() -> void:
	move_sound.play()
	_start_position = position

## Actualiza la posicion de la plataforma cada frame usando una onda sinusoidal,
## de modo que oscila suavemente entre la posicion inicial y la posicion inicial + movement_offset.
func _physics_process(delta: float) -> void:
	_time += delta
	var safe_cycle_time: float = max(cycle_time, 0.1)  # Evita division por cero
	var wave: float = sin(((_time / safe_cycle_time) + phase) * TAU) * 0.5 + 0.5
	position = _start_position + movement_offset * wave
