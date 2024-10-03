extends CharacterBody2D

const RADIO_INICIAL = 30

@onready var nodo_armas = $Armas
@onready var armas = nodo_armas.get_children()


@onready var sprite = $Sprite2D
@onready var spritetimer = $Sprite2D/TimerSprite
#onready var stats = get_node("/root/Mundo/Juego/Player/EstadisticasPersonaje")
@onready var stats = $EstadisticasPersonaje
@onready var rango_recogida = $Rango_recogida/CollisionShape2D
@onready var speed = stats.get_velocidad_movimiento()
@onready var hitbox_area = $HitboxArea
@onready var Camara = $Camera2D
@onready var Animacion = $AnimationPlayer
@onready var hud = $Camera2D/CanvasLayer/HUD
@onready var guiLvlup = $Camera2D/CanvasLayer/GUIlvlup
@onready var DeathFX = $DeathFX
@onready var regenTimer = $PasiveRegenTimer

var muerto = false
var menuopc = false
var pausa_activa = false
var moving = false
var empujar=false;
const sqlite = preload("res://addons/godot-sqlite/gdsqlite.gdextension")
var db
const DATABASE_PATH_RES = "res://data.db"
const DATABASE_PATH = "user://data.db"
var movimiento: Vector2
var direccion_vista
var animacionActual=""
var SpriteFlip=false


signal set_mejora_pico
signal set_mejora_botas
signal set_mejora_rango
signal set_mejora_damage
signal set_mejora_dinero
signal set_mejora_vida
signal set_mejora_ametra
signal set_mejora_bobina
signal set_mejora_sniper
signal set_mejora_lanzallamas


func userDatabase():
	var dir = DirAccess.open("user://")
	if !dir.file_exists(DATABASE_PATH):
		dir.copy(DATABASE_PATH_RES,DATABASE_PATH)

func _ready():
	regenTimer.start(5)
	userDatabase()
	rango_recogida.shape.radius = RADIO_INICIAL
	show()
	Camara.make_current()
	db = SQLite.new()
	db.path = DATABASE_PATH
	Camara.set_visible(true)
	global_position = Vector2(0,0)
	$HitboxArea/CollisionShape2D.shape.set_radius(24.0)
	if StaticData.on_android:
		var joystick_scene = load("res://Scenes/HUD/CanvasUI.tscn")
		var joystick = joystick_scene.instantiate()
		self.add_child(joystick)
	
	for arma in armas:
		match arma.get_name():
			"Pico":
				guiLvlup.nivelesMejoras["1"]=1
			"Ametralladora":
				guiLvlup.nivelesMejoras["6"]=1
			"Bobina_tesla":
				guiLvlup.nivelesMejoras["7"]=1
			"Sniper":
				guiLvlup.nivelesMejoras["8"]=1
			"Lanzallamas":
				guiLvlup.nivelesMejoras["9"]=1

	stats.set_stats()
	self.z_index +=1

func _physics_process(_delta):
	if muerto:
		return
	
	movimiento_player()
	
	
	for body in hitbox_area.get_overlapping_bodies():
		if body.is_in_group("Enemy") and not body.is_in_group("EnemyNoAnim"):
			if !muerto and not body.get_muerto():
				take_damage(body.get_damage(), _delta,false)
				body.Animation_Player.play("Attack")
				if not body.Animation_Player.is_playing() or body.Animation_Player.current_animation != "Attack":
					body.Animation_Player.play("Attack")


func take_damage(damage, _delta, deltaNotNeeded:bool): #Using delta for damage calculations for enemy melee attacks.
	if deltaNotNeeded:
		var salud_actual = stats.get_salud()
		stats.set_salud(salud_actual-damage)
		sprite.set_self_modulate("#f16060")
		spritetimer.start(0.2)
		return
	else:
		var salud_actual = stats.get_salud()
		stats.set_salud(salud_actual-(damage*_delta))
		sprite.set_self_modulate("#f16060")
		spritetimer.start(0.2)


func movimiento_player():
	if StaticData.on_android:
		if $UI/Joystick.touched == true:
			moving = true
			Animacion.play("Move")
		else:
			moving = false
	else:
		moving = false
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		Animacion.play("Move")
		animacionActual = "Move"
		velocity.x += 1
		moving = true
		sprite.flip_h = false
		SpriteFlip = false
	if Input.is_action_pressed('ui_left'):
		Animacion.play("Move")
		animacionActual = "Move"
		velocity.x -= 1
		moving = true
		sprite.flip_h = true
		SpriteFlip = true
	if Input.is_action_pressed('ui_down'):
		Animacion.play("Move")
		animacionActual = "Move"
		velocity.y += 1
		moving = true
	if Input.is_action_pressed('ui_up'):
		Animacion.play("Move")
		animacionActual = "Move"
		moving = true
		velocity.y -= 1
		
	if StaticData.on_android:
		velocity = $UI/Joystick.get_velo() * speed
		if velocity.x < 0:
			sprite.flip_h = true
		if velocity.x > 0:
			sprite.flip_h = false
	else:
		velocity = velocity.normalized() * speed	
	if not moving:
		Animacion.play("Idle")
		animacionActual = "Idle"
		
	
		
		
	set_velocity(velocity)
	move_and_slide()
	movimiento = velocity
	if velocity != Vector2(0,0):
		direccion_vista = self.velocity+self.position

	

func _on_HitboxArea_area_entered(area):
	if area.get_parent().has_method("activar_efecto"):
		area.get_parent().activar_efecto()
		

func _on_Rango_recogida_area_entered(area):
	if area.is_in_group("Objects"):
		area.remove_from_group("Objects")
		area.get_parent().set_activar_movimiento(true)
		area.get_parent().set_last_player_pos(self.position)
	


func _on_EstadisticasPersonaje_rango_recogida_actualizado():
	rango_recogida.shape.radius = RADIO_INICIAL * stats.get_rango_recogida()


func _on_EstadisticasPersonaje_velocidad_mov_actualizada():
	speed = stats.get_velocidad_movimiento()


func _on_GUIlvlup_mejora_elegida(indiceMejora):
	match indiceMejora:
		"0":
			emit_signal("set_mejora_botas")
		"1":
			emit_signal("set_mejora_pico")
		"2":
			emit_signal("set_mejora_rango")
		"3":
			emit_signal("set_mejora_damage")
		"4":
			emit_signal("set_mejora_dinero")
		"5":
			emit_signal("set_mejora_vida")
		"6":
			emit_signal("set_mejora_ametra")
		"7":
			emit_signal("set_mejora_bobina")
		"8":
			emit_signal("set_mejora_sniper")
		"9":
			emit_signal("set_mejora_lanzallamas")


func _on_EstadisticasPersonaje_muelto():
	muerto = true
#	DeathFX.play()
	Animacion.play("Muerte")
	await Animacion.animation_finished
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = true
	var puntuacion = stats.get_nivel()*70+stats.get_experiencia()*3+hud.get_tiempo() #70n +3e +t |n = nivel e = experiencia t = tiempo
	var monedas = puntuacion/10
	monedas +=stats.get_monedas()
	stats.set_monedas(int(monedas))      
	guardar_monedas(stats.get_monedas())                                                               
	get_node("/root/Mundo/Juego/Player/Camera2D/CanvasLayer/YOUDIED!").visible = true
	get_node("/root/Mundo/Juego/Player/Camera2D/CanvasLayer/YOUDIED!/Fondo/btnReiniciar").grab_focus()
	get_node("/root/Mundo/Juego/Player/Camera2D/CanvasLayer/YOUDIED!/Fondo/score").set_text(str(int(puntuacion)))                    

func guardar_monedas(monedas):
	db.open_db()
	var query = "UPDATE player_stats SET monedas = ? WHERE player_id = ?"
	db.query_with_bindings(query, [monedas, stats.player_id])
	db.close_db()


func _on_TimerSprite_timeout():
	sprite.set_self_modulate("#ffffff")


func _on_PasiveRegenTimer_timeout():
	var salud_actual = stats.get_salud()
	if salud_actual >= stats.get_salud_max():
		return
	if salud_actual+stats.get_regeneracion_pasiva() >= stats.get_salud_max():
		stats.set_salud(stats.get_salud_max())
		return
	stats.set_salud(salud_actual+stats.get_regeneracion_pasiva())


func _on_TimerMulti_timeout():
	Server.rpc_unreliable_id(1,"update_transform",global_position,animacionActual,velocity,SpriteFlip)
