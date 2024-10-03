extends Node2D
const SPEED = 100
var damage = 0
var knockback = 50
var direction = Vector2.RIGHT.rotated(rotation)	
func _physics_process(delta):
	direction = Vector2.RIGHT.rotated(rotation)	
	position+= direction * delta * SPEED
	
			
			


func _on_Damage_area_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(damage,0,true)
		queue_free()
	if body.is_in_group("Tilemap"):
		queue_free()
