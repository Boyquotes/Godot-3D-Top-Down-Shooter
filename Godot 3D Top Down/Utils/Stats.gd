extends Node
class_name Stats

signal you_died_signal

export (float) var max_HP := 10.0

onready var current_HP := max_HP

func _ready():
	pass
	
func take_hit(damage):
	current_HP -= damage
#	print("I'm hit ! - ", current_HP, "/", max_HP)
	
	if current_HP <= 0:
		die()

func die():
	emit_signal("you_died_signal")
