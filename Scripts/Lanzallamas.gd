extends Node2D

class_name Lanzallamas

@onready var player = get_node("/root/Mundo/Juego/Player")
@onready var juego = get_node("/root/Mundo/Juego")
@onready var lanzallamas = load("res://Scenes/Armas/Lanzallamas.tscn")
@onready var hud = get_node("/root/Mundo/Juego/Player/Camera2D/CanvasLayer/HUD")
@onready var stats = get_node("/root/Mundo/Juego/Player/EstadisticasPersonaje")
@onready var estadisticasView = get_node("/root/Mundo/Juego/Player/Camera2D/CanvasLayer/EstadisticasView")
@onready var pivot = $Pivot
@onready var reloadtimer = $ReloadTimer
@onready var ShootFX = $LanzallamasShootFX
@onready var ReloadFX = $LanzallamasReloadFX
var flama = preload("res://Scenes/Balas/Llama.tscn")
const BASE_DAMAGE = 2
const AMMO_BASE = 800
const RELOAD_TIME_BASE = 5
var damage = 0
var nivel = 0
var muelto = false
var able_shoot = false
var angulo_maximo = 15 
var flamas_por_tiro = 2
var LuzBala = false


var preDamage = BASE_DAMAGE
var ammo_max = AMMO_BASE
var ammo = AMMO_BASE
var reload_time = RELOAD_TIME_BASE
var reloading = false
var debeRecargar = true
var apuntandoConMouse = false

func set_damage(value=0):
	preDamage += value
	var nuevoDamage = preDamage * stats.get_damage()
	damage =nuevoDamage

func _ready():
	ShootFX.play()
	damage = BASE_DAMAGE
	self.set_damage() #Actualiza el daño actual con el multiplicador de las estadisticas
	get_parent().connect("mejorarLanzallamas", Callable(self, "_on_Armas_mejorarLanzallamas"))
	estadisticasView.lanzallamasammo.set_text(String(ammo))
	estadisticasView.lanzallamasammomax.set_text(String(ammo_max))

func _physics_process(delta):
	if not debeRecargar:
		shoot()
	elif ammo > 0:
		shoot()

func shoot():
	var bala
	if not apuntandoConMouse and player.direccion_vista != null:
		pivot.look_at(player.direccion_vista)
	elif apuntandoConMouse:
		pivot.look_at(get_global_mouse_position())
	for _i in range(flamas_por_tiro):
		bala =flama.instantiate()
		var angulo_random = deg_to_rad(randf_range(-angulo_maximo, angulo_maximo))
		bala.set_rotation(pivot.global_rotation + angulo_random)
		bala.set_position(player.global_position)
		bala.damage = get_damage()
		bala.velocidadJugador = player.velocity
		juego.add_sibling(get_node("/root/Mundo/Juego/Spawner"),bala)
	if debeRecargar:
		ammo = ammo - 1
		estadisticasView.lanzallamasammo.set_text(String(ammo))
		if ammo <= 0:
			estadisticasView.lanzallamasammo.set_text(String(ammo))
			start_reload()
			
func randf_range(_min, _max):
	return randf() * (_max - _min) + _min

func start_reload():
	ShootFX.stop()
	ReloadFX.play()
	able_shoot = false
	reloading = true
	reload_time = RELOAD_TIME_BASE
	reloadtimer.start(reload_time)
	hud.reloadiconLanzallamas.show()


func aplicarMejoras():
	match self.nivel:
		0:
			pass
		1:
			set_damage(2)

		2:
			set_damage(2)

		3:
			set_damage(2)

		4:
			set_damage(2)

		5:
			estadisticasView.lanzallamasammo.hide()
			estadisticasView.lanzallamasammomax.hide()
			estadisticasView.lanzallamassigno.hide()
			debeRecargar = false
			hud.reloadiconLanzallamas.hide()



func _input(event):
	if (event.is_action_pressed("Reload") and reloading == false and debeRecargar == true and ammo != ammo_max):
		ammo = 0
		start_reload()


func mejorarDamage(value):
	set_damage(value)

func get_damage():
	return damage
	
func get_nivel():
	return nivel
	
func set_nivel(value):
	nivel = value
	
func _on_Cooldown_timeout():
	if not debeRecargar and able_shoot:
		shoot()
	elif ammo > 0 and able_shoot:
		shoot()


func _on_EstadisticasPersonaje_muelto():
	muelto = true


func _on_Armas_mejorarLanzallamas():
	var nivelActual = self.get_nivel()
	self.set_nivel(nivelActual+1);
	aplicarMejoras()




func _on_ReloadTimer_timeout():
	ShootFX.play()
	estadisticasView.lanzallamasammo.set_text(String(ammo))
	reloading = false
	ammo = ammo_max
	able_shoot = true
	hud.reloadiconLanzallamas.hide()

