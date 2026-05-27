@tool
extends StaticBody3D

## Tamaño de la plataforma en los tres ejes. Al modificarlo en el editor
## se actualiza automaticamente la malla y la colision.
@export var platform_size: Vector3 = Vector3(2.4, 0.65, 2.4):
	set(value):
		platform_size = value
		_update_platform()

## Color de la plataforma. Al modificarlo en el editor
## se actualiza automaticamente el material.
@export var albedo_color: Color = Color("348ac9"):
	set(value):
		albedo_color = value
		_update_platform()

@onready var mesh_instance: MeshInstance3D = $MeshPlataforma
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	_update_platform()

## Sincroniza malla, colision y material con los valores exportados.
## Se llama automaticamente al cambiar cualquier propiedad exportada
## o al inicializar la escena.
func _update_platform() -> void:
	if not mesh_instance or not collision_shape:
		return

	# Asignar simensiones al mesh
	var box_mesh := mesh_instance.mesh as BoxMesh
	if not box_mesh:
		box_mesh = BoxMesh.new()
		mesh_instance.mesh = box_mesh
	box_mesh.size = platform_size

	# Asignar dimensiones al colider
	var box_shape := collision_shape.shape as BoxShape3D
	if not box_shape:
		box_shape = BoxShape3D.new()
		collision_shape.shape = box_shape
	box_shape.size = platform_size

	# Asignar color material
	var mat := mesh_instance.material_override as StandardMaterial3D
	if not mat:
		mat = StandardMaterial3D.new()
		mesh_instance.material_override = mat
	mat.albedo_color = albedo_color