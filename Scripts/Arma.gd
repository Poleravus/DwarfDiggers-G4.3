extends Node2D
class_name Arma

@onready var rango = $Rango
@onready var pivot = $Pivot
@onready var cooldown = $Cooldown
@onready var stats = get_node("/root/Mundo/Juego/Player/EstadisticasPersonaje")
@onready var timer_apuntar = $Apuntar
var damage = 0
var nivel = 0
var muelto = false
var able_shoot:bool
func get_nivel():
	return nivel

func set_nivel(value):
	nivel = value

func get_damage():
	return damage

func _ready():
	cooldown.start(1)
#	timer_apuntar.connect("timeout", self, "_update_closest_enemy")
#	timer_apuntar.start(0.2)
	aim_to_enemy()

func aim_to_enemy():
	var overlappingBodies = rango.get_overlapping_bodies()
	if overlappingBodies != []:
		var target_enemy = get_target_enemy(overlappingBodies)
		if target_enemy == null:
			able_shoot=false
			return
		if target_enemy!=null:
			able_shoot=true
			var direction = target_enemy.global_position
			pivot.look_at(direction)



func _update_closest_enemy():
	aim_to_enemy()



func shoot():
	aim_to_enemy()
	if rango.get_overlapping_bodies()== []:
		return
	var bala = load("res://Scenes/Balas/Bala_ametralladora.tscn").instantiate()
	bala.set_rotation(pivot.global_rotation)
	bala.set_position(pivot.global_position)
	add_child(bala)
	cooldown.start(0.3)

func _on_EstadisticasPersonaje_muelto():
	muelto = true

func get_target_enemy(enemies):
	var closest_enemy = null
	var shortest_distance = INF
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var distance = self.global_position.distance_to(enemy.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_enemy = enemy
	return closest_enemy




func _on_Cooldown_timeout():
	shoot()
