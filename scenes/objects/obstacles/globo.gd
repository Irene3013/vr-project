extends RigidBody3D

@onready var area: Area3D = $Area3D
@onready var sound: AudioStreamPlayer3D = $SonidoRebote

const BOINGS = [
	preload("res://assets/audio/boing-1.ogg"),
	preload("res://assets/audio/boing-2.ogg"),
	preload("res://assets/audio/boing-3.ogg")
]


func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)


func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player_body"):

		if sound.playing:
			return

		sound.stream = BOINGS.pick_random()
		sound.play()
