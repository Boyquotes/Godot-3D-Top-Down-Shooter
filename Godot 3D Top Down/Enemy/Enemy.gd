extends KinematicBody

class_name Enemy

export (float) var speed := 3.0
export (float) var attack_speed_multiplier := 5.0

onready var nav = $"../Navigation" as Navigation
onready var player = $"../Player" as KinematicBody
onready var attack_timer = $AttackTimer

onready var mesh_instance = $MeshInstance
onready var default_material = load("res://Enemy/Materials/EnemyDefaultMaterial.tres")
onready var attack_material = load("res://Enemy/Materials/EnemyAttackMaterial.tres")
onready var resting_material = load("res://Enemy/Materials/EnemyRestingMaterial.tres")

onready var attack_radius = $AttackRadius

var path = []
var current_node := 0
var attack_target := Vector3.ZERO
var return_target := Vector3.ZERO

enum state {
	SEEKING,
	ATTACKING,
	RETURNING,
	RESTING
}

var current_state = state.SEEKING

func _ready():
	mesh_instance.set_surface_material(0, default_material)
	
func _physics_process(_delta):
	if is_instance_valid(player):
		match current_state:
			state.SEEKING:
				if current_node < path.size():
					var seeking_vector: Vector3 = path[current_node] - global_transform.origin
					var _err = move_and_slide(seeking_vector.normalized() * speed)
					seeking_vector = path[current_node] - global_transform.origin
					if seeking_vector.length() < 1:
						current_node += 1
					
					if attack_radius.overlaps_body(player):
						init_attack()
					
			state.ATTACKING:
				move_and_attack()
			state.RETURNING:
				move_and_attack()
			state.RESTING:
				pass
	#			print("Resting !")

func move_and_attack():
	var  attack_vector: Vector3 = attack_target - global_transform.origin
	var direction : Vector3 = attack_vector.normalized()
	var distance = attack_vector.length()
	
#	print("I'm this far away from my target: ", distance)
	var _err = move_and_slide(direction * speed * attack_speed_multiplier)

	if distance < 1:
		match current_state:
			state.ATTACKING:
				var player_stats: Stats = player.get_node("Stats")
				player_stats.take_hit(0.67)
				var player_health_pourcent = ((player_stats.current_HP / player_stats.max_HP) / player_stats.max_HP) * 1000
				if player_stats.current_HP >= 0.01:
					print("Player Health: ", player_stats.current_HP, "/", player_stats.max_HP, " - Pourcent: ", player_health_pourcent, "%")
				current_state = state.RETURNING
				attack_target = return_target
			state.RETURNING:
				current_state = state.RESTING
				mesh_instance.set_surface_material(0, resting_material)
				collide_with_other_enemies(true)
				_err = move_and_slide(Vector3.ZERO)
				attack_timer.start()

func collide_with_other_enemies(should_we_collide):
	set_collision_mask_bit(2, should_we_collide)
	set_collision_layer_bit(2, should_we_collide)

func update_path(target_position):
	path = nav.get_simple_path(global_transform.origin, target_position)

func init_attack() -> void:
	attack_target = player.global_transform.origin
	return_target = global_transform.origin
	current_state = state.ATTACKING
	mesh_instance.set_surface_material(0, attack_material)
	collide_with_other_enemies(false)
#	print(body, " enterred my attack radius")

func _on_PathUpdateTimer_timeout():
#	print("Looking for Player!")
	if is_instance_valid(player):
		update_path(player.global_transform.origin)
		current_node = 0

func _on_Stats_you_died_signal():
	queue_free()

func _on_AttackTimer_timeout() -> void:
	current_state = state.SEEKING
	mesh_instance.set_surface_material(0, default_material)
