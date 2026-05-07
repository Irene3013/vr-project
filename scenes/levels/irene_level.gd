@tool
extends XRToolsSceneBase

@onready var win_area: Area3D = $EndPlatform/WinZone
@onready var death_zone: Area3D = $DeathZone
@onready var spawn_point: Marker3D = $StartPlatform/SpawnPoint

var win_label: Label3D
var fail_label: Label3D
var is_game_over := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()  # ejecuta el _ready() de XRToolsSceneBase primero
	#print(get_tree_string_pretty())
	var player_body = XRToolsPlayerBody.find_instance($XROrigin3D)
	if player_body:
		print("PlayerBody collision layer: ", player_body.collision_layer)
		print("PlayerBody mask layer: ", player_body.collision_mask)
	win_area.body_entered.connect(_on_win_area_entered)
	death_zone.body_entered.connect(_on_death_zone_entered)
	_setup_labels()
	
# scene_loaded se llama automáticamente desde el staging cuando carga la escena
# Aquí puedes pasar el spawn point inicial (ya lo gestiona la clase base)
#func scene_loaded(user_data = null) -> void:
	#super(spawn_point.name)  # Le pasamos el nombre del Marker3D como spawn point

func _setup_labels() -> void:
	win_label = Label3D.new()
	win_label.text = "YOU WIN!"
	win_label.font_size = 64
	win_label.modulate = Color.YELLOW
	win_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	win_label.visible = false
	$EndPlatform.add_child(win_label)
	win_label.position = Vector3(0, 2.5, 0)

	fail_label = Label3D.new()
	fail_label.text = "YOU FAILED!"
	fail_label.font_size = 64
	fail_label.modulate = Color.RED
	fail_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	fail_label.visible = false
	add_child(fail_label)
	fail_label.position = Vector3(0, 2.0, 0)

func _on_win_area_entered(body: Node3D) -> void:
	if is_game_over:
		return
	if _is_player(body):
		is_game_over = true
		win_label.visible = true

func _on_death_zone_entered(body: Node3D) -> void:
	#print("Entró en DeathZone: ", body.name, " | clase: ", body.get_class())
	if is_game_over:
		return
	if _is_player(body):
		fail_label.visible = true
		await get_tree().create_timer(2.0).timeout
		_respawn_player()
		fail_label.visible = false
		is_game_over = false  # permite morir de nuevo tras respawn

func _respawn_player() -> void:
	center_player_on(spawn_point.global_transform)

func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player_body") or body is XROrigin3D
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
