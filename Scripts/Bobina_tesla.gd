extends Node2D

class_name Bobina_tesla
@onready var stats = get_node("/root/Mundo/Juego/Player/EstadisticasPersonaje")
@onready var rango = $Rango
@onready var cooldown = $Cooldown
@onready var sprite = $Sprite2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var ShootFX = $ShootFX
const SPRITE_SCALE = Vector2(0.205,0.221)
const BASE_DAMAGE = 2
const ANIMATED_SPRITE_SCALE = Vector2(0.65,0.65)
var enemigos_dentro
var RANGO_BASE = 63.1269
var sprite_scale
var damage
var rango_inicial = 70
var preDamage = BASE_DAMAGE
@onready var rango_shape = $Rango/CollisionShape2D

var nivel = 0
func get_nivel():
	return nivel

func set_nivel(value):
	nivel = value

func _ready():
	damage = BASE_DAMAGE
	self.set_damage() #Actualiza el daño actual con el multiplicador de las estadisticas
	sprite.visible = true
	animated_sprite.visible =true
	set_rango(rango_inicial)
	cooldown.start(0.5)
	get_parent().connect("mejorarBobina", Callable(self, "_on_Armas_mejorarBobina"))
	
func set_damage(value=0):
	preDamage += value
	var nuevoDamage = preDamage * stats.get_damage()
	damage =nuevoDamage


	
func _on_Armas_mejorarBobina():
	var nivelActual = self.get_nivel()
	self.set_nivel(nivelActual+1);
	aplicarMejoras()
	
	
func shoot():
	enemigos_dentro = rango.get_overlapping_bodies()
	if enemigos_dentro != []:
		ShootFX.play()
		animated_sprite.visible = true
		for enemigo in enemigos_dentro:
			if enemigo.has_method("take_damage"):
				enemigo.take_damage(damage, false)
	else:
		animated_sprite.visible = false
 
func aplicarMejoras():
	match self.nivel:
		0:
			pass
		1:
			set_damage(1)

		2:
			set_rango(85)
			rango_inicial = 85

		3:
			set_damage(2)

		4:
			set_rango(100)
			rango_inicial = 100

		5:
			set_damage(5)
			set_rango(130)
			rango_inicial = 130
	
func set_rango(value):
	rango_shape.shape.set_radius(value)
	sprite_scale = value * SPRITE_SCALE / RANGO_BASE
	$Sprite2D.scale = sprite_scale
	var animated_scale = value * ANIMATED_SPRITE_SCALE / RANGO_BASE
	animated_sprite.scale = animated_scale
		
func _on_Cooldown_timeout():
	shoot()
