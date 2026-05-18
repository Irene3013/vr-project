extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")



const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity := 0.002
@export var portal_surface_offset := 0.35

var rotation_x := 0.0

@onready var camera = $Camera3D

func _ready():
	$Camera3D.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Asegurarnos de tener las mismas colisiones que el PlayerBody de VR
	collision_layer = 524290
	# Mask por defecto en XRToolsPlayerBody 524295 (Capas 1, 2, 3 y 20)
	collision_mask = 524295


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, deg_to_rad(-80), deg_to_rad(80))
		camera.rotation.x = rotation_x
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= abs(gravity) * delta



	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
