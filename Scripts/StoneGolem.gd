extends CharacterBody2D




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
@onready var progress_circle = $DamageArea/ProgressCircle
@onready var tween = $DamageArea/ProgressCircle/Tween
@onready var circle_edge = $DamageArea/CircleEdge
@onready var attack_col = $DamageArea/CollisionShape2D
@onready var sprite = $Sprite2D
@onready var spritetimer =$Sprite2D/SpriteTimer
#Variables de prueba con camara---------

var camara : Camera2D
var UmbralDistancia = 650
#---------------------------------------

var muerto = false
var direction = [0,0]
var posInicial
const VIDA_BASE = 50
const BASE_DAMAGE = 30
const VELOCIDAD_BASE = 80
const COOLDOWN_BASE  = 2
const XP_BASE = 40
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
var attacking = false
const EDGE_SCALE = Vector2(0.776,0.849)
const BASE_RANGO_CIRCULO = 229
var circle_scale
var tiempo_carga = 1.5
var rango_circulo = 229


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
	circle_edge.visible = false
	progress_circle.scale = Vector2(0,0)
	scale_circle(rango_circulo)
	

func scale_circle(new_range):
	attack_col.shape.radius = new_range
	$DamageArea/CircleEdge.scale.x = new_range * EDGE_SCALE.x / BASE_RANGO_CIRCULO
	$DamageArea/CircleEdge.scale.y = new_range * EDGE_SCALE.y / BASE_RANGO_CIRCULO
	circle_scale = new_range * 1.2 /229
	


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
		damage += nivel * 5
		velocidad += nivel * 5
		xp += nivel * 5
	else:  # Caso 4: Afectar stats base con nivel y oleada
		vida += (nivel * 7) + (oleada * 2.2)
		damage += (nivel * 5) + (oleada * 1)
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

func respawn():
	var random_radius = randf_range(500,550)
	position = player.position + Vector2(random_radius, 0).rotated(randf_range(0, 2 * PI))

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
		if puedeMoverse and not attacking:
			mover()
		inhabilitarmovimiento()
	update_counter += 1
	
	
func inhabilitarmovimiento():
	var vecinos = area2D.get_overlapping_bodies().size()
	if vecinos > 6 and not attacking:
		puedeMoverse = false
		sprite.play("Idle")
	else:
		puedeMoverse = true
		


func mover():
	var bodies_in_range = $AttackRange.get_overlapping_bodies()
	if not hit_timer.is_stopped():
		set_velocity(direction)
		move_and_slide()
		var _movimiento = velocity		
	elif bodies_in_range.size() > 0:
		for body in bodies_in_range:
			if body.is_in_group("Player"):
				attack()
				sprite.play("Attack")
	else:
		direction = (player.global_position-global_position).normalized()
		set_velocity(direction*_velocidad)
		move_and_slide()
		var _movimiento = velocity
		sprite.play("Walk")
		if direction.x > 0.1:
			sprite.flip_h = false
			pass
		elif direction.x < -0.1:
			sprite.flip_h = true
			pass



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
	spritetimer.start()
	if _vida <= 0:
		if not muerto:
			muerto=true
			circle_edge.hide()
			progress_circle.hide()
			emit_signal("enemy_died")
			barra_vida.hide()
			sprite.play("Death")
			await sprite.animation_finished
			dropear_experiencia()
			collision_shape.set_deferred("disabled",true)
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
	pass

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

func attack():
	if not attacking:
		attacking = true
		circle_edge.visible = true
		
		# Calcula el speed_scale basado en tiempo_carga
		var fps_original = 25.0  # Framerate original de la animación
		var speed_scale = (fps_original / tiempo_carga)/fps_original  # Calcula el speed_scale
#		sprite.speed_scale = speed_scale  # Aplica el speed_scale calculado
#		sprite.play("Attack")
		$ChargeAttackTimer.start(tiempo_carga)
		tween.interpolate_property(progress_circle, "scale", Vector2(0, 0), Vector2(circle_scale, circle_scale), tiempo_carga, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()


func do_damage():
	var bodies_in_area = $DamageArea.get_overlapping_bodies()
	if  bodies_in_area.size() > 0:
		for body in bodies_in_area:
			if body.is_in_group("Player"):
				body.take_damage(get_damage(),0,true)

func _on_ChargeAttackTimer_timeout():
	attacking = false
	puedeMoverse =true
	circle_edge.visible = false
#	sprite.speed_scale = 1
#	sprite.play("Walk_Idle")


func _on_Tween_tween_completed(object, key):
	progress_circle.scale = Vector2(0,0)
	do_damage()
