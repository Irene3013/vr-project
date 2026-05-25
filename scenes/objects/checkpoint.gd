extends Node3D

## Señal emitida cuando el jugador activa el checkpoint por primera vez.
## Transporta el transform del marker para usarlo como punto de respawn.
signal checkpoint_reached(transform: Transform3D)

@onready var area: Area3D = $Area3D
@onready var marker: Marker3D = $CheckpointMarker
@onready var checkpoint_activated = $CheckpointActivated
@onready var hologram: MeshInstance3D = $CheckpointMesh/CilindroHolograma

# Color de luz indicando si está activo o no
#const COLOR_DEFAULT = Color(0.2, 0.8, 1.0, 0.7)
#const COLOR_ACTIVE = Color(0.2, 1.0, 0.2, 0.8)
const COLOR_DEFAULT = Color(1.0, 0.85, 0.1, 0.7)  # amarillo
const COLOR_ACTIVE = Color(0.1, 0.9, 0.3, 0.8)    # verde
# Indica si el checkpoint ya ha sido activado para evitar activaciones repetidas
var _activated := false

# Conecta la señal de colision del area y verifica que el mesh del aro existe
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	# Crear copia única del material para este checkpoint
	var mat = hologram.get_active_material(0)
	hologram.material_override = mat.duplicate()

# Se llama cuando un cuerpo entra en el area del checkpoint.
# Solo reacciona si el checkpoint no ha sido activado y el cuerpo es el jugador.
func _on_body_entered(body: Node) -> void:
	if _activated:
		return
	if body.is_in_group("player_body"):
		get_tree().call_group("checkpoint", "reset_checkpoint")
		_activated = true
		_show_activated()
		emit_signal("checkpoint_reached", marker.global_transform)

# Reproduce el audio de activacion y lanza la animacion del aro:
# cambia el color de amarillo a verde y hace un pulso de escala.
func _show_activated() -> void:
	checkpoint_activated.play()
	var mat = hologram.get_active_material(0)
	mat.set_shader_parameter("color", COLOR_ACTIVE)

func reset_checkpoint():
	_activated = false
	var mat = hologram.get_active_material(0)
	mat.set_shader_parameter("color", COLOR_DEFAULT)
