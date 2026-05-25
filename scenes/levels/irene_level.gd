@tool
extends XRToolsSceneBase

@onready var win_area: Area3D = $SceneBasics/EndPlatform/WinZone
@onready var death_zone: Area3D = $SceneBasics/DeathZone
@onready var spawn_point: Marker3D = $SceneBasics/StartPlatform/SpawnPoint
@onready var hud = $XROrigin3D/XRCamera3D/HUD
@onready var right_controller = $XROrigin3D/RightHand
#@onready var confeti = $XROrigin3D/XRCamera3D/Confeti

# Sistema de respawn y checkpoints
var is_game_over: bool = false
var _spawn_transform: Transform3D  # guardamos al inicio
var _current_spawn_transform: Transform3D

# Inicializa la escena base. Las señales se conectan en scene_loaded
# para garantizar que todos los nodos estan listos cuando el staging los carga.
func _ready() -> void:
	super()  # ejecuta el _ready() de XRToolsSceneBase primero	

# Se llama cuando el countdown termina. Habilita el movimiento del jugador.
func _on_countdown_finished() -> void:
	_set_player_movement(true)

# Se llama cuando el juego termina (victoria o game over).
# Bloquea el movimiento del jugador y activa la espera del trigger para reiniciar.
func _on_game_finished() -> void:
	is_game_over = true
	_set_player_movement(false)

# Habilita o deshabilita el procesado del nodo PlayerBody,
# bloqueando o permitiendo todo el movimiento y fisica del jugador XR.
func _set_player_movement(enabled: bool) -> void:
	# XRToolsPlayerBody es hijo del XROrigin3D
	var player = get_node_or_null("XROrigin3D/PlayerBody")
	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED

# Comprueba cada frame si el jugador pulsa el trigger del controlador derecho
# para reiniciar la escena una vez que el juego ha terminado.
func _process(delta: float) -> void:
	if not is_game_over:
		return
	if right_controller.get_float("trigger") > 0.8:
		is_game_over = false
		reset_scene()

# Llamado automaticamente por el staging al cargar la escena.
# Guarda el transform del spawn inicial, conecta checkpoints y señales del nivel.
func scene_loaded(user_data = null) -> void:
	super(spawn_point.name)  # Le pasamos el nombre del Marker3D como spawn point
	_spawn_transform = spawn_point.global_transform  # guardamos orientación inicial
	_current_spawn_transform = _spawn_transform  # empieza en el spawn inicial
	
	# Conectar todos los checkpoints del nivel
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		checkpoint.checkpoint_reached.connect(_on_checkpoint_reached)
	# Asignar color a no-activo
	get_tree().call_group("checkpoint", "reset_checkpoint")
	
	win_area.body_entered.connect(_on_win_area_entered)
	death_zone.body_entered.connect(_on_death_zone_entered)
	hud.countdown_finished.connect(_on_countdown_finished)
	hud.game_finished.connect(_on_game_finished)

# Llamado automaticamente por el staging cuando la escena es visible para el jugador.
# Bloquea el movimiento e inicia el countdown antes de permitir jugar.
func scene_visible(user_data = null) -> void:
	super()
	_set_player_movement(false)
	hud.start_countdown() # La cuenta atrás empieza cuando la escena es visible para el jugador

# Actualiza el punto de respawn activo al nuevo transform del checkpoint alcanzado
# y muestra el mensaje de confirmacion en el HUD.
func _on_checkpoint_reached(new_transform: Transform3D) -> void:
	#get_tree().call_group("checkpoint", "reset_checkpoint")
	_current_spawn_transform = new_transform  # actualiza el spawn activo
	hud.show_sheckpoint_saved() # muestra checkpoint saved

# Gestiona la entrada del jugador en la zona de victoria.
# Muestra el panel de fin y lanza el efecto de confeti.
func _on_win_area_entered(body: Node3D) -> void:
	if _is_player(body):
		hud.show_win()
		#confeti.emitting = true   # lanza el confeti

# Gestiona la entrada del jugador en la zona de muerte.
# Delega en el HUD la logica de vidas y respawn.
func _on_death_zone_entered(body: Node3D) -> void:
	if _is_player(body):
		hud.show_fail(_respawn_player)

# Teletransporta al jugador al ultimo checkpoint activado,
# o al spawn inicial si no hay ningun checkpoint activado.
func _respawn_player() -> void:
	#center_player_on(_spawn_transform)
	center_player_on(_current_spawn_transform) 

# Devuelve true si el cuerpo dado pertenece al grupo del jugador XR.
func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player_body")
