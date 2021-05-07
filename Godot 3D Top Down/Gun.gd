extends Spatial

export (PackedScene) var Bullet
export var muzzle_speed := 30.0
export var millis_between_shots := 300

onready var muzzle = $Muzzle
onready var rof_timer = $Timer

var can_shoot := true

func _ready():
	rof_timer.wait_time = millis_between_shots / 1000.0
	
func _process(delta):
	pass
	
func shoot():
	if can_shoot:
		var new_bullet = Bullet.instance()
		new_bullet.global_transform = muzzle.global_transform
		new_bullet.speed = muzzle_speed
		var scene_root = get_tree().get_root().get_children()[0]
		scene_root.add_child(new_bullet)
		can_shoot = false
		rof_timer.start()

func _on_Timer_timeout():
	can_shoot = true
