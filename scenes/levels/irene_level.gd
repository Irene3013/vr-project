@tool
extends XRToolsSceneBase

@onready var win_area: Area3D = $EndPlatform/WinZone
@onready var death_zone: Area3D = $DeathZone
@onready var spawn_point: Marker3D = $StartPlatform/SpawnPoint
var hud: Node3D

var is_game_over := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()  # ejecuta el _ready() de XRToolsSceneBase primero	
	win_area.body_entered.connect(_on_win_area_entered)
	death_zone.body_entered.connect(_on_death_zone_entered)
	
	hud = $XROrigin3D/XRCamera3D/HUD
	# Si usamos el player plano, le pasamos el HUD a su cámara y desactivamos el VR player para evitar colisiones
	if has_node("PlayerFlat") and $PlayerFlat.visible:
		var hud_parent = hud.get_parent()
		if hud_parent:
			hud_parent.remove_child(hud)
		$PlayerFlat/Camera3D.add_child(hud)
		$XROrigin3D.process_mode = Node.PROCESS_MODE_DISABLED
		#$XROrigin3D.global_position = Vector3(0, -1000, 0)


# Sobreescribimos el centrado de jugador para que funcione con el PlayerFlat
func center_player_on(p_transform: Transform3D) -> void:
	if has_node("PlayerFlat") and $PlayerFlat.visible:
		$PlayerFlat.global_transform = p_transform
	else:
		super(p_transform)

# scene_loaded se llama automáticamente desde el staging cuando carga la escena
# Aquí puedes pasar el spawn point inicial (ya lo gestiona la clase base)
func scene_loaded(user_data = null) -> void:
	super(spawn_point.name)  # Le pasamos el nombre del Marker3D como spawn point
	
	# Aseguramos que la cámara activa es la del PlayerFlat si está activado
	if has_node("PlayerFlat") and $PlayerFlat.visible:
		$PlayerFlat/Camera3D.current = true
		if has_node("XROrigin3D/XRCamera3D"):
			$XROrigin3D/XRCamera3D.current = false

func scene_visible(user_data = null) -> void:
	super()
	hud.start_countdown() # La cuenta atrás empieza cuando la escena es visible para el jugador

func _on_win_area_entered(body: Node3D) -> void:
	if is_game_over:
		return
	if _is_player(body):
		is_game_over = true
		hud.show_win()

func _on_death_zone_entered(body: Node3D) -> void:
	if is_game_over:
		return
	if _is_player(body):
		hud.show_fail(_respawn_player)

func _respawn_player() -> void:
	center_player_on(spawn_point.global_transform)

func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player_body") or body is XROrigin3D
