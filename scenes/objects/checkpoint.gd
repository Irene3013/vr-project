extends Node3D

## Señal emitida cuando el jugador activa el checkpoint por primera vez.
## Transporta el transform del marker para usarlo como punto de respawn.
signal checkpoint_reached(transform: Transform3D)

@onready var area: Area3D = $Area3D
@onready var marker: Marker3D = $CheckpointMarker
@onready var checkpoint_activated = $CheckpointActivated
@onready var hologram: MeshInstance3D = $CheckpointMesh/CilindroHolograma

const COLOR_DEFAULT = Color(1.0, 0.85, 0.1, 0.7)  # amarillo: checkpoint no activado
const COLOR_ACTIVE  = Color(0.1, 0.9, 0.3, 0.8)   # verde: checkpoint activado

## Indica si el checkpoint ya ha sido activado para evitar activaciones repetidas.
var _activated := false

## Conecta la señal de colision del area y duplica el material del holograma
## para que cada checkpoint tenga su propia instancia de material independiente.
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	var mat = hologram.get_active_material(0)
	hologram.material_override = mat.duplicate()

## Se llama cuando un cuerpo entra en el area del checkpoint.
## Solo reacciona si el checkpoint no ha sido activado y el cuerpo es el jugador.
## Resetea todos los checkpoints del nivel, activa este y emite la señal.
func _on_body_entered(body: Node) -> void:
	if _activated:
		return
	if body.is_in_group("player_body"):
		get_tree().call_group("checkpoint", "reset_checkpoint")
		_activated = true
		_show_activated()
		emit_signal("checkpoint_reached", marker.global_transform)

## Reproduce el audio de activacion y cambia el color del holograma de amarillo a verde.
func _show_activated() -> void:
	checkpoint_activated.play()
	var mat = hologram.get_active_material(0)
	mat.set_shader_parameter("color", COLOR_ACTIVE)

## Resetea el checkpoint a su estado inicial: lo marca como no activado
## y restaura el color del holograma a amarillo.
func reset_checkpoint():
	_activated = false
	var mat = hologram.get_active_material(0)
	mat.set_shader_parameter("color", COLOR_DEFAULT)
