@tool
extends XRToolsSceneBase

@onready var win_area: Area3D = $SceneBasics/EndPlatform/WinZone
@onready var death_zone: Area3D = $SceneBasics/DeathZone
@onready var spawn_point: Marker3D = $SceneBasics/StartPlatform/SpawnPoint
@onready var hud = $XROrigin3D/XRCamera3D/HUD
@onready var right_controller = $XROrigin3D/RightHand

var is_game_over: bool = false
var _spawn_transform: Transform3D          # Transform del punto de inicio del nivel
var _current_spawn_transform: Transform3D  # Transform del ultimo checkpoint activado

## Inicializa la escena base. 
func _ready() -> void:
	super()

## Se llama cuando el countdown termina. Habilita el movimiento del jugador.
func _on_countdown_finished() -> void:
	_set_player_movement(true)

## Se llama cuando el juego termina (victoria o game over).
## Bloquea el movimiento del jugador y activa la espera del trigger para reiniciar.
func _on_game_finished() -> void:
	is_game_over = true
	_set_player_movement(false)
	return_to_stage()

## Habilita o deshabilita el procesado del nodo PlayerBody,
## bloqueando o permitiendo todo el movimiento y fisica del jugador XR.
func _set_player_movement(enabled: bool) -> void:
	var player = get_node_or_null("XROrigin3D/PlayerBody")
	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED

## Para volver al staging (menu/pantalla de carga) una vez que el juego ha terminado.
func return_to_stage():
	await get_tree().create_timer(5).timeout
	reset_scene()

## Llamado automaticamente por el staging al cargar la escena.
## Guarda el transform del spawn inicial, conecta checkpoints y señales del nivel.
func scene_loaded(user_data = null) -> void:
	super(spawn_point.name)
	_spawn_transform = spawn_point.global_transform
	_current_spawn_transform = _spawn_transform

	# Conectar la señal de cada checkpoint del nivel y resetear su estado visual
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		checkpoint.checkpoint_reached.connect(_on_checkpoint_reached)
	get_tree().call_group("checkpoint", "reset_checkpoint")

	win_area.body_entered.connect(_on_win_area_entered)
	death_zone.body_entered.connect(_on_death_zone_entered)
	hud.countdown_finished.connect(_on_countdown_finished)
	hud.game_finished.connect(_on_game_finished)

## Llamado automaticamente por el staging cuando la escena es visible para el jugador.
## Bloquea el movimiento e inicia el countdown antes de permitir jugar.
func scene_visible(user_data = null) -> void:
	super()
	_set_player_movement(false)
	hud.start_countdown()

## Actualiza el punto de respawn activo al transform del checkpoint alcanzado
## HUD: Muestra el mensaje de confirmacion.
func _on_checkpoint_reached(new_transform: Transform3D) -> void:
	_current_spawn_transform = new_transform
	hud.show_sheckpoint_saved()

## Gestiona la entrada del jugador en la zona de victoria.
## HUD: Muestra el panel de fin y lanza el efecto de confeti.
func _on_win_area_entered(body: Node3D) -> void:
	if _is_player(body):
		hud.show_win()

## Gestiona la entrada del jugador en la zona de muerte.
## HUD: Delega en el HUD la logica de vidas y respawn.
func _on_death_zone_entered(body: Node3D) -> void:
	if _is_player(body):
		hud.show_fail(_respawn_player)

## Teletransporta al jugador al ultimo checkpoint activado, o al spawn inicial
## si no se ha activado ninguno, usando center_player_on() de XRTools.
## Reposiciona el XROrigin3D y el PlayerBody respetando la orientacion de la camara.
func _respawn_player() -> void:
	center_player_on(_current_spawn_transform)

## Devuelve true si el cuerpo detectado es el del jugador XR.
func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player_body")
