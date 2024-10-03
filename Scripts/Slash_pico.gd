extends Node2D

@onready var animation = $Animacion/AnimationPlayer
@onready var damage_area = $Sprite2D/Damage_area
var damage = 0
var playing  = false
var knockback = 70

func set_damage(value):
	damage = value

func _ready():
	animation.play("attack")
	$Sprite2D.visible = false
	# Espera un pequeño tiempo antes de llamar a do_damage para asegurarse de que las colisiones se detecten
	await get_tree().create_timer(0.1).timeout
	do_damage()

func do_damage():

	var direction = Vector2.RIGHT.rotated(rotation)
	var enemigos_dentro = damage_area.get_overlapping_bodies()
	damage_area.set_collision_mask_value(1,false)
	if enemigos_dentro != null and enemigos_dentro.size() > 0:
		for enemigo in enemigos_dentro:
			if enemigo.has_method("take_damage"):
				enemigo.take_damage(damage, direction * knockback)
				
	else:
		queue_free()

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
