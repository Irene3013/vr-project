extends RigidBody3D

@onready var area: Area3D = $Area3D
@onready var sound: AudioStreamPlayer3D = $SonidoRebote

## Tres variantes de sonido de rebote que se eligen aleatoriamente en cada golpe.
const BOINGS = [
	preload("res://assets/audio/boing-1.ogg"),
	preload("res://assets/audio/boing-2.ogg"),
	preload("res://assets/audio/boing-3.ogg")
]

func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)

## Cuando el jugador toca el globo, reproduce un sonido de rebote aleatorio.
## Si ya hay un sonido reproduciendose, espera a que termine para no solaparse.
## La fisica del rebote se gestiona desde el script de PlayerBody.
func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player_body"):
		if sound.playing:
			return
		sound.stream = BOINGS.pick_random()
		sound.play()
