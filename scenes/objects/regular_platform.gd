@tool
extends StaticBody3D

@export var platform_size: Vector3 = Vector3(2.4, 0.65, 2.4):
	set(value):
		platform_size = value
		_update_platform()

@export var albedo_color: Color = Color("348ac9"):
	
	set(value):
		albedo_color = value
		_update_platform()

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	_update_platform()


func _update_platform() -> void:
	if not mesh_instance or not collision_shape:
		return

	# ---------- MESH ----------
	var box_mesh := mesh_instance.mesh as BoxMesh

	if not box_mesh:
		box_mesh = BoxMesh.new()
		mesh_instance.mesh = box_mesh

	box_mesh.size = platform_size

	# ---------- COLLISION ----------
	var box_shape := collision_shape.shape as BoxShape3D

	if not box_shape:
		box_shape = BoxShape3D.new()
		collision_shape.shape = box_shape

	box_shape.size = platform_size

	# ---------- MATERIAL ----------
	var mat := mesh_instance.material_override as StandardMaterial3D

	if not mat:
		mat = StandardMaterial3D.new()
		mesh_instance.material_override = mat

	mat.albedo_color = albedo_color
