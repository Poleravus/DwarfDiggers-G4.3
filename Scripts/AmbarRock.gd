extends CharacterBody2D



@onready var sprite = $Sprite2D
@onready var spritetimer = $Sprite2D/SpirteTimer
@onready var juego = get_node("/root/Mundo/Juego")


const VIDA_BASE = 35
const CURACION_BASE = 30

@export var vida: float = 35
var muerto = false
var invulnerable = false
var contador_llama = 0
var cont_invulnerable = 0
var cont_tickDamage = 0
func set_vida(value):
	vida = value
	
func get_vida():
	return vida
	

func get_muerto():
	return muerto

func take_damage(damage,knockback,source=""):
	if source=="llama":
		if invulnerable:
			cont_invulnerable+=1
			contador_llama+=1
			if contador_llama>22:
				contador_llama=0
				cont_tickDamage+=1
			if cont_invulnerable>28:
				invulnerable = false
				cont_invulnerable=0
			return
	vida -=damage
	DamageNumbers.display_number(damage,self.global_position,juego,false)
	sprite.set_self_modulate("#f16060")
	spritetimer.start(0.2)
	if vida <= 0:
		if not muerto:
			muerto=true
			dropear_curacion()
			self.set_collision_layer_value(1,false)
			self.set_collision_mask_value(1,false)
			queue_free()
	invulnerable = true

func dropear_curacion():
	call_deferred("_do_dropear_curacion")

func _do_dropear_curacion():
	var curacion = preload("res://Scenes/Objeto.tscn").instantiate()
	curacion.position = self.global_position
	curacion.set_tipo("cura")
	curacion.set_cantidad(CURACION_BASE)
	juego.add_sibling(get_node("/root/Mundo/Juego/Spawner"),curacion)

func _on_SpirteTimer_timeout():
	sprite.set_self_modulate(sprite.get_modulate())
