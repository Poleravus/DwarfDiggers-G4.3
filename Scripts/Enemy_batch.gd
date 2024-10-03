extends Node2D

var enemies
var cont = 0


func _ready():
	enemies = 10
	
	for enemy in get_children():
		cont=+1
		enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))

func _on_enemy_died():
	if get_child_count() == 0:
		queue_free()
