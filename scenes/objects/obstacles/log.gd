extends RigidBody3D

func _ready() -> void:
	# physics settings
	mass = 30.0
	freeze = false
	gravity_scale = 2.0

	
# create mesh
	var mesh_instance := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.2
	cylinder.bottom_radius = 0.2
	cylinder.height = 1.7
	mesh_instance.mesh = cylinder
	mesh_instance.rotation_degrees.z = 90.0
	
	# wood texture material
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load("res://assets/splash/wood.jpg")
	mesh_instance.material_override = mat
	
	add_child(mesh_instance)

	# create collision
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 0.2
	shape.height = 1.7
	collision.shape = shape
	collision.rotation_degrees.z = 90.0
	add_child(collision)
	
	# physics material - no bounce
	var phys_mat := PhysicsMaterial.new()
	phys_mat.bounce = 0.0
	phys_mat.friction = 0.9
	phys_mat.absorbent = true
	physics_material_override = phys_mat

	# wake up physics after one frame
	await get_tree().process_frame
	apply_central_impulse(Vector3(0, -5, 0))
