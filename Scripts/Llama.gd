extends Node2D
const SPEED = 250


var damage = 0
var knockback = 50
var direction = Vector2.RIGHT.rotated(rotation)	
var velocidadJugador:Vector2


func _physics_process(delta):
	direction = Vector2.RIGHT.rotated(rotation)	
	position+= (direction * SPEED + velocidadJugador)* delta 
	


func _on_Damage_area_body_entered(body):
	if body.is_in_group("Enemy") or body.is_in_group("Entity"):
		body.take_damage(damage,false,"llama")
	if body.is_in_group("Walls"):
		queue_free()


func _on_tiempoVida_timeout():
	queue_free()

