extends Node3D

## Señal emitida cuando el jugador activa el checkpoint por primera vez.
## Transporta el transform del marker para usarlo como punto de respawn.
signal checkpoint_reached(transform: Transform3D)

@onready var area: Area3D = $Area3D
@onready var marker: Marker3D = $CheckpointMarker
@onready var checkpoint_activated = $CheckpointActivated
@onready var aro_mesh: MeshInstance3D = $CheckpointMesh/AroVisual

# Indica si el checkpoint ya ha sido activado para evitar activaciones repetidas
var _activated := false

# Conecta la señal de colision del area y verifica que el mesh del aro existe
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	if aro_mesh == null:
		print("Nodos disponibles: ")
		for child in get_children():
			print(" - ", child.name)

# Se llama cuando un cuerpo entra en el area del checkpoint.
# Solo reacciona si el checkpoint no ha sido activado y el cuerpo es el jugador.
func _on_body_entered(body: Node) -> void:
	if _activated:
		return
	if body.is_in_group("player_body"):
		_activated = true
		_show_activated()
		emit_signal("checkpoint_reached", marker.global_transform)

# Reproduce el audio de activacion y lanza la animacion del aro:
# cambia el color de amarillo a verde y hace un pulso de escala.
func _show_activated() -> void:
	checkpoint_activated.play()
	# TODO da error (lo arregla Irene)
	# Obtener el material del aro
	#var material = aro_mesh.get_surface_override_material(0)
	#if material == null:
		#material = aro_mesh.mesh.surface_get_material(0)
	## Tween: cambiar color a verde y pulso de escala
	#var tween = create_tween().set_parallel(true)
	## Color blanco-amarillo a verde claro
	#tween.tween_method(
		#func(c: Color): 
			#material.albedo_color = c
			#material.emission = c,
		#Color(1.0, 0.95, 0.4, 1),   # color inicial
		#Color(0.3, 1.0, 0.4, 1),    # verde claro
		#0.5                           # duración
	#)
	## Pulso de escala: crece y vuelve
	#tween.tween_property($AroVisual, "scale", Vector3(1.3, 1.3, 1.3), 0.2)
	#await get_tree().create_timer(0.2).timeout
	#tween.tween_property($AroVisual, "scale", Vector3(1.0, 1.0, 1.0), 0.2)
