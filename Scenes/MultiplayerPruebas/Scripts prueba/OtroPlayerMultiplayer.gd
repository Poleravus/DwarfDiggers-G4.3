extends CharacterBody2D

@onready var tween= $Tween
@onready var Animacion= $AnimationPlayer
@onready var sprite = $Sprite2D

var speed = 200

var puppet_pos=Vector2()
var puppet_anim = ""
var puppet_vel = Vector2()


	

func update_transform(_puppet_pos,_puppet_anim,_puppet_vel,_puppet_spriteFlip):
	new_puppet_pos(_puppet_pos)
	update_puppet_anim(_puppet_anim)
	puppet_vel = _puppet_vel
	sprite.flip_h = _puppet_spriteFlip
	
func update_puppet_anim(animation):
	if animation:
		Animacion.play(animation)
	else:
		Animacion.play("Idle")

func new_puppet_pos(value):
	puppet_pos = value
	tween.interpolate_property(self,"global_position",global_position,puppet_pos,0.05)
	tween.start()

