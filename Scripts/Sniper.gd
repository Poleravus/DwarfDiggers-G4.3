extends Arma

class_name Sniper

@onready var player = get_node("/root/Mundo/Juego/Player")
@onready var juego = get_node("/root/Mundo/Juego")
@onready var ray_cast = $RayCast2D
@onready var line = $Line2D
@onready var rango_shape = $Rango/CollisionShape2D
@onready var hud = get_node("/root/Mundo/Juego/Player/Camera2D/CanvasLayer/HUD")
@onready var reloadtimer = $ReloadTimer
@onready var estadisticasView = get_node("/root/Mundo/Juego/Player/Camera2D/CanvasLayer/EstadisticasView")
@onready var ShootFX = $ShootFX
@onready var ReloadFX = $ReloadFX
const RANGO_BASE = 400
const ELNUMERO = 0.95
const BASE_DAMAGE = 10
const COOLDOWN_BASE = 2
const AMMO_BASE = 5
const RELOAD_TIME_BASE = 7


var preDamage = BASE_DAMAGE
var ammo_max = AMMO_BASE
var ammo = AMMO_BASE
var reload_time = RELOAD_TIME_BASE
var tiempoCooldown = COOLDOWN_BASE
var reloading = false
var debeRecargar = true
var bounces = 0
var apuntandoConMouse = false


func set_bounces_sniper(value):
	bounces = value
	
func get_bounces_sniper():
	return bounces


func set_damage(value=0):
	preDamage += value
	var nuevoDamage = preDamage * stats.get_damage()
	damage =nuevoDamage

func _ready():
	damage = BASE_DAMAGE  * stats.get_damage()
	set_rango(RANGO_BASE)
	timer_apuntar.connect("timeout", Callable(self, "_update_closest_enemy"))
	timer_apuntar.start(2)
	get_parent().connect("mejorarSniper", Callable(self, "_on_Armas_mejorarSniper"))
	able_shoot=true
	estadisticasView.sniperammo.set_text(String(ammo))
	estadisticasView.sniperammomax.set_text(String(ammo_max))

func shoot():
	if rango.get_overlapping_bodies() == []:
		return
	if not apuntandoConMouse:
		aim_to_enemy()
	else:
		pivot.look_at(get_global_mouse_position())
	ShootFX.play()
	var bala = preload("res://Scenes/Balas/Bala_sniper.tscn").instantiate()
	#setear el vector direccion (donde esta mirando pivot)
	var pivot_rotation = $Pivot.global_rotation  # Obtener la rotación global del pivot
	var direccion = Vector2.RIGHT.rotated(pivot_rotation)
	var enemigos = get_tree().get_nodes_in_group("Rebote_conexion")
	bala.direction = direccion
	bala.damage = get_damage()
	bala.global_position = $Pivot.global_position
	bala.set_bounces(get_bounces_sniper())
	juego.add_sibling(get_node("/root/Mundo/Juego/Spawner"),bala)
	cooldown.start(tiempoCooldown)
	if debeRecargar:
		ammo = ammo - 1
		estadisticasView.sniperammo.set_text(String(ammo))
		if ammo <= 0:
			estadisticasView.sniperammo.set_text(String(ammo))
			start_reload()

func _input(event):
	if (event.is_action_pressed("Reload") and reloading == false and debeRecargar == true and ammo != ammo_max ):
		ammo = 0
		start_reload()

		
func start_reload():
	ReloadFX.play()
	able_shoot = false
	reloading = true
	reload_time = RELOAD_TIME_BASE
	reloadtimer.start(reload_time)
	hud.reloadiconSniper.show()


func aplicarMejoras():
	match self.nivel:
		0:
			pass
		1:
			set_damage(1)
		2:
			set_bounces_sniper(1)
		3:
			set_damage(3)
		4:
			set_damage(4)
		5:
			set_damage(5)
			set_bounces_sniper(2)

func _on_Armas_mejorarSniper():
	var nivelActual = self.get_nivel()
	self.set_nivel(nivelActual+1);
	aplicarMejoras()

func mejorarDamage(value):
	set_damage(value)
	
func mejorarCooldown(value):
	var tmp = tiempoCooldown * value
	tiempoCooldown -=abs(tmp)

func set_rango(value):
	rango_shape.shape.set_radius(value)

func get_target_enemy(enemies):
	var closest_enemy = null
	var closest_distance = INF
	for enemy in enemies:
		if not enemy.get_muerto():
			var distance = global_position.distance_to(enemy.global_position)
			if distance < closest_distance and not behind_wall(enemy):
				closest_distance = distance
				closest_enemy = enemy
	return closest_enemy

func behind_wall(enemy):
	var ray_start = global_position
	var ray_end = enemy.global_position
	ray_cast.set_target_position((ray_end - ray_start)*ELNUMERO)
	ray_cast.force_raycast_update()  # Aseguramos que el raycast se actualice inmediatamente
#	line.clear_points()
#	line.add_point(ray_cast.position)
#	line.add_point(ray_cast.get_cast_to())
#	line.show()
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		# Asumimos que las paredes tienen una propiedad o grupo que las identifica
		if collider.is_in_group("Walls"):  
			return true
	return false
	
func _on_Cooldown_timeout():
	if not debeRecargar and able_shoot:
		shoot()
	elif ammo > 0 and able_shoot:
		shoot()


func _on_EstadisticasPersonaje_muelto():
	muelto = true


func _on_Armas_mejorarAmetralladora():
	var nivelActual = self.get_nivel()
	self.set_nivel(nivelActual+1);
	aplicarMejoras()




func _on_ReloadTimer_timeout():
	reloading = false
	ammo = ammo_max
	hud.reloadiconSniper.hide()
	estadisticasView.sniperammo.set_text(String(ammo))

