extends Spatial

onready var camera = $Camera
onready var player = $Player

var ray_origin = Vector3.ZERO
var ray_target = Vector3.ZERO

func _physics_process(delta):
	
	var mouse_position = get_viewport().get_mouse_position()
#	print("Mouse Position: ", mouse_position)

	ray_origin = camera.project_ray_origin(mouse_position)
#	print("ray_origin: ", ray_origin)
	ray_target = ray_origin + camera.project_ray_normal(mouse_position) * 2000
	
	var space_state = get_world().direct_space_state
	var intersection = space_state.intersect_ray(ray_origin, ray_target)
	
	if not intersection.empty():
		var pos = intersection.position
		var loot_at_me = Vector3(pos.x, player.translation.y ,pos.z)
		player.look_at(loot_at_me, Vector3.UP)
