extends XRToolsSceneBase

@onready var win_area: Area3D = $EndPlatform/WinZone
@onready var death_zone: Area3D = $DeathZone
@onready var spawn_point: Marker3D = $StartPlatform/SpawnPoint
@onready var xr_origin: XROrigin3D = $XROrigin3D
@onready var xr_camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var desktop_player: CharacterBody3D = $PlayerFlat
@onready var log_timer: Timer = $LogTimer

# this loads your saved log.tscn file
const LOG_SCENE := preload("res://scenes/objects/obstacles/log.tscn")

@export var spawn_x: float = 0.0
@export var spawn_y: float = 6.0
@export var spawn_z: float = 0.0

var hud: Node3D
var is_game_over := false
var _using_desktop_player := false

func _ready() -> void:
	super()
	_setup_player_mode()
	win_area.body_entered.connect(_on_win_area_entered)
	death_zone.body_entered.connect(_on_death_zone_entered)
	log_timer.one_shot = false
	log_timer.timeout.connect(_spawn_log)

func scene_visible(user_data = null) -> void:
	super()
	if hud and hud.has_method("start_countdown"):
		hud.start_countdown()
	_spawn_log()
	log_timer.wait_time = randf_range(1, 2.0)
	log_timer.start()

func _spawn_log() -> void:
	log_timer.wait_time = randf_range(1, 2.0)

	var log := LOG_SCENE.instantiate()
	log.position = Vector3(
		spawn_x + randf_range(-0.4, 0.3),
		spawn_y + 3,
		spawn_z - 30
	)

	add_child(log)
	
	# force physics awake on the NEXT frame after it's fully in the tree
	await get_tree().process_frame
	log.freeze = false
	log.apply_central_impulse(Vector3(0, -1, 0))  # tiny kick downward to wake physics

	await get_tree().create_timer(20.0).timeout
	if is_instance_valid(log):
		log.queue_free()
		
func center_player_on(p_transform: Transform3D) -> void:
	if _using_desktop_player:
		desktop_player.global_transform = p_transform
	else:
		super(p_transform)

func scene_loaded(user_data = null) -> void:
	super(spawn_point.name)
	if _using_desktop_player:
		var desktop_camera := desktop_player.get_node("Camera3D") as Camera3D
		desktop_camera.current = true
		xr_camera.current = false
	else:
		xr_camera.current = true

func _setup_player_mode() -> void:
	hud = xr_camera.get_node_or_null("HUD")
	_using_desktop_player = desktop_player.visible and not _has_initialized_xr()
	if _using_desktop_player:
		if hud:
			var hud_parent: Node = hud.get_parent()
			if hud_parent:
				hud_parent.remove_child(hud)
			var desktop_camera := desktop_player.get_node("Camera3D") as Camera3D
			desktop_camera.add_child(hud)
		xr_origin.process_mode = Node.PROCESS_MODE_DISABLED
		xr_origin.visible = false
		return
	desktop_player.visible = false
	desktop_player.process_mode = Node.PROCESS_MODE_DISABLED
	xr_origin.process_mode = Node.PROCESS_MODE_INHERIT
	xr_origin.visible = true

func _has_initialized_xr() -> bool:
	var xr_interface: XRInterface = XRServer.primary_interface
	return xr_interface != null and xr_interface.is_initialized()

func _on_win_area_entered(body: Node3D) -> void:
	if is_game_over or not _is_player(body):
		return
	is_game_over = true
	log_timer.stop()
	if hud and hud.has_method("show_win"):
		hud.show_win()

func _on_death_zone_entered(body: Node3D) -> void:
	if is_game_over or not _is_player(body):
		return
	if hud and hud.has_method("show_fail"):
		hud.show_fail(_respawn_player)
		if hud.current_lives < 1:
			is_game_over = true
			log_timer.stop()
	else:
		_respawn_player()

func _respawn_player() -> void:
	center_player_on(spawn_point.global_transform)

func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player_body") or body is XROrigin3D
