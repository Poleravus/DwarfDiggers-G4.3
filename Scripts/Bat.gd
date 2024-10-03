extends CharacterBody2D


@onready var sprite = $AnimatedSprite2D
@onready var spritetimer = $AnimatedSprite2D/SpriteTimer
@onready var juego = get_node("/root/Mundo/Juego")
@onready  var barra_vida = $Barra_vida/BarraVida
@onready var progress_bar = $Barra_vida/BarraVida/ProgressBar
@onready var barra_vida_timer = $Barra_vida/Barra_vida_timer
@onready var hit_timer = $Hit_timer
@onready var collision_shape = $CollisionShape2D
@onready var area2D = $Area2D
@onready var SpriteEfecto = $SpriteEfecto
@onready var FireTickTimer= $FireTick
@onready var spawner = get_node("/root/Mundo/Juego/Spawner")
@onready var player = get_node("/root/Mundo/Juego/Player")
@onready var cooldownTimer = $Cooldown
@onready var pivot = $Pivot
var muerto = false
var direction = [0,0]
var posInicial
const VIDA_BASE = 4
const BASE_DAMAGE = 3
const VELOCIDAD_BASE = 60
const COOLDOWN_BASE  = 2
const XP_BASE = 5
@export var _velocidad: float = 30.0
@export var _vida: float = 10.0
@export var _damage: float = 10.0
var xp
var hit = false
signal enemy_died
var timer = true
var puedeMoverse = true
var update_counter = 0
const UPDATE_FREQUENCY = 2
var contador_llama = 0
var cont_invulnerable = 0
var cont_tickDamage = 0
var tickDamage = 1
var enLlamas=false
var invulnerable = false
var tiempoCooldown = COOLDOWN_BASE
var canShoot = true

#Variables de prueba con camara---------

var camara : Camera2D
var UmbralDistancia = 650
#---------------------------------------


func set_damage(value):
	_damage = value

func set_velocidad(value):
	_velocidad = value

func set_vida(value):
	_vida = value
	progress_bar.max_value = value
	
func set_xp(value):
	xp = value
	
func get_xp():
	return xp

func get_damage():
	return _damage
	
func get_velocidad():
	return _velocidad
	
func get_vida():
	return _vida
	
func get_muerto():
	return muerto


func _ready():
	camara = get_node("/root/Mundo/Juego/Player/Camera2D") #Prueba camara
	posInicial = global_position
	set_enemy_stats()
	barra_vida.visible = false
	SpriteEfecto.visible = false


func set_enemy_stats():
	var oleada = spawner.get_oleada()
	var nivel = spawner.get_nivel()
	
	var vida = VIDA_BASE
	var damage = BASE_DAMAGE
	var velocidad = VELOCIDAD_BASE
	xp = XP_BASE
	
	if oleada == 1 and nivel == 1:  # Caso 1: No afectar stats base
		pass
	elif oleada != 1 and nivel == 1:  # Caso 2: Afectar stats base con oleada
		vida += oleada * 2.5
		damage += oleada * 1
		velocidad += oleada * 1
		xp += oleada * 1
	elif oleada == 1 and nivel != 1:  # Caso 3: Afectar stats base solo con nivel
		vida += nivel * 7
		damage += nivel * 2
		velocidad += nivel * 5
		xp += nivel * 5
	else:  # Caso 4: Afectar stats base con nivel y oleada
		vida += (nivel * 7) + (oleada * 2.2)
		damage += (nivel * 2) + (oleada * 1)
		velocidad += (nivel * 5) + (oleada * 1)
		xp += (nivel * 5) + (oleada * 1)
	
	set_vida(vida)
	set_damage(damage)
	set_velocidad(velocidad)
	set_xp(xp)


func activar_barra_vida():
	barra_vida_timer.start(5)
	barra_vida.visible = true
	progress_bar.value = _vida
	
func _physics_process(_delta):
	if update_counter % UPDATE_FREQUENCY == 0:
		if muerto:
			return
		#PRUEBAS CAMARA-------------
		 # Calculate distance from camera
		var distance_to_camera = global_position.distance_to(camara.global_position)

		# Check if the enemy should move
		if distance_to_camera >= UmbralDistancia:
			respawn()
		#-----------------------------
		if puedeMoverse:
			mover()
#		inhabilitarmovimiento()
	update_counter += 1
	
func respawn():
	var random_radius = randf_range(500,700)
	position = player.position + Vector2(random_radius, 0).rotated(randf_range(0, 2 * PI))

func inhabilitarmovimiento():
	var vecinos = area2D.get_overlapping_bodies().size()
	if vecinos > 6:
		puedeMoverse = false
	else:
		puedeMoverse = true
		

func cambiodecooldown():
	tiempoCooldown = randf_range(1.5,4.5)
	
	

func mover():
	if not hit_timer.is_stopped():
		set_velocity(direction)
		move_and_slide()
		var _movimiento = velocity

	else:
		direction = (player.global_position-global_position).normalized()
		if (global_position.distance_to(player.global_position))>200:
			set_velocity(direction*_velocidad)
			move_and_slide()
			var _movimiento = velocity
		else:
			if canShoot:
				shoot()
				
		if direction.x > 0.1:
			sprite.flip_h = false
		elif direction.x < -0.1:
			sprite.flip_h = true

func shoot():
	pivot.look_at(player.global_position)
	var proyectile = preload("res://Scenes/Enemigos/EnemyProyectiles/Bat/CloudProyectile.tscn").instantiate()
	proyectile.set_rotation(pivot.global_rotation)
	proyectile.set_position(pivot.global_position)
	proyectile.damage = get_damage()
	cambiodecooldown()
	juego.add_sibling(get_node("/root/Mundo/Juego/Spawner"),proyectile)
	canShoot=false
	cooldownTimer.start(tiempoCooldown)

func damage_fuego():
	if not enLlamas:
		enLlamas=true
		$SpriteEfecto.visible = true
		FireTickTimer.start(1)

			
func take_damage(damage,knockback,source=""):
	if source=="llama":
		if invulnerable:
			damage_fuego()
			cont_invulnerable+=1
			contador_llama+=1
			if contador_llama>22:
				contador_llama=0
				cont_tickDamage+=1
			if cont_invulnerable>28:
				invulnerable = false
				cont_invulnerable=0
			return
	_vida -=damage
	if not muerto:
		activar_barra_vida()
	DamageNumbers.display_number(damage,self.global_position,juego,false)
	if knockback:
		hit_timer.start(0.2)
		direction = knockback
	sprite.set_self_modulate("#f16060")
	spritetimer.start(0.2)
	if _vida <= 0:
		if not muerto:
			muerto=true
			emit_signal("enemy_died")
			barra_vida.hide()
			dropear_experiencia()
			self.set_collision_layer_value(1,false)
			self.set_collision_mask_value(1,false)
			queue_free()
	invulnerable = true
			

func dropear_experiencia():
	call_deferred("_do_dropear_experiencia")

func _do_dropear_experiencia():
	var experiencia = load("res://Scenes/Objeto.tscn").instantiate()
	experiencia.position = self.global_position
	experiencia.set_tipo("xp")
	experiencia.set_cantidad(xp)
	juego.add_sibling(get_node("/root/Mundo/Juego/Spawner"),experiencia)

func _on_Barra_vida_timer_timeout():
	barra_vida_timer.stop()
	barra_vida.visible = false
	pass # Replace with function body.


func _on_SpriteTimer_timeout():
	sprite.set_self_modulate("#ffffff")

func _on_FireTick_timeout():
	self.take_damage(tickDamage,false)
	if cont_tickDamage>0 and not muerto:
		if cont_tickDamage >4:
			cont_tickDamage = 5
		cont_tickDamage= cont_tickDamage-1
		FireTickTimer.start(1)
	else:
		enLlamas = false
		$SpriteEfecto.visible = false
		FireTickTimer.stop()


func _on_Cooldown_timeout():
	canShoot=true


func _on_Hit_timer_timeout():
	hit_timer.stop()
