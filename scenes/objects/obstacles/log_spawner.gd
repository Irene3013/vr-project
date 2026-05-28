extends Node3D

const LOG_SCENE := preload("res://scenes/objects/obstacles/log.tscn")

@export var min_interval: float = 2.5
@export var max_interval: float = 4.0
@export var spawn_offset: Vector3 = Vector3(0, 0, 0)
@export var x_randomness: float = 0.4

@onready var timer: Timer = $LogTimer

func _ready() -> void:
	timer.one_shot = false
	timer.timeout.connect(_spawn_log)

func start() -> void:
	_spawn_log()
	timer.wait_time = randf_range(min_interval, max_interval)
	timer.start()

func stop() -> void:
	timer.stop()


func _spawn_log() -> void:
	timer.wait_time = randf_range(min_interval, max_interval)

	var log_mesh := LOG_SCENE.instantiate()
	log_mesh.position = global_position + spawn_offset + Vector3(randf_range(-x_randomness, x_randomness), 0, 0)
	get_parent().add_child(log_mesh)

	await get_tree().process_frame
	log_mesh.freeze = false
	log_mesh.apply_central_impulse(Vector3(0, -1, 0))
	
	# Limpieza en una fucion separada
	_schedule_cleanup(log_mesh)

func _schedule_cleanup(log_mesh: RigidBody3D) -> void:
	await get_tree().create_timer(8.0).timeout
	if is_instance_valid(log_mesh):
		log_mesh.queue_free()
		
