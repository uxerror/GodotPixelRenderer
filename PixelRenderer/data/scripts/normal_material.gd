extends Node

const NORMAL_MATERIAL = preload("res://PixelRenderer/data/NormalMaterial.tres")

@onready var models_spawner: Node3D = %ModelsSpawner


func toggle_normal_map(toggle : bool):
	var meshes = get_all_mesh_instances(get_all_children(models_spawner))
	
	if toggle:
		for mesh in meshes:
			mesh.set_surface_override_material(0, NORMAL_MATERIAL)
	else:
		for mesh in meshes:
			mesh.set_surface_override_material(0, null)



func get_all_children(node) -> Array:
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)
	return nodes

func get_all_mesh_instances(array : Array) -> Array[MeshInstance3D]:
	var mesh_instances : Array[MeshInstance3D] = []
	
	for N in array:
		if N is MeshInstance3D:
			mesh_instances.append(N)
	return mesh_instances
