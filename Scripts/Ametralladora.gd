extends Arma

class_name Ametralladora

@onready var player = get_node("/root/Mundo/Juego/Player")
@onready var juego = get_node("/root/Mundo/Juego")
@onready var ray_cast = $RayCast2D
@onready var line = $Line2D
@onready var rango_shape = $Rango/CollisionShape2D
@onready var hud = get_node("/root/Mundo/Juego/Player/Camera2D/CanvasLayer/HUD")
@onready var estadisticasView = get_node("/root/Mundo/Juego/Player/Camera2D/CanvasLayer/EstadisticasView")
@onready var reloadtimer = $ReloadTimer
@onready var ShootFX1 = $MachineGunShootFX1
@onready var ReloadFX = $MachineGunReloadFX
const RANGO_BASE = 60
const ELNUMERO = 0.3
const BASE_DAMAGE = 3
const COOLDOWN_BASE = 0.3
const AMMO_BASE = 21
const RELOAD_TIME_BASE = 5


var preDamage = BASE_DAMAGE
var ammo_max = AMMO_BASE
var ammo = AMMO_BASE
var reload_time = RELOAD_TIME_BASE
var tiempoCooldown = COOLDOWN_BASE
var reloading = false
var debeRecargar = true
var apuntandoConMouse = false


var rng = RandomNumberGenerator.new()

func set_damage(value=0):
	if value == BASE_DAMAGE:
		damage =value
	else:
		preDamage += value
		var nuevoDamage = preDamage * stats.get_damage()
		damage =nuevoDamage

func _ready():
	rng.randomize()
	set_damage(BASE_DAMAGE)
	set_rango(RANGO_BASE)
	timer_apuntar.connect("timeout", Callable(self, "_update_closest_enemy"))
	timer_apuntar.start(0.2)
	get_parent().connect("mejorarAmetralladora", Callable(self, "_on_Armas_mejorarAmetralladora"))
	able_shoot=true
	estadisticasView.Gunammo.set_text(String(ammo))
	estadisticasView.Gunammomax.set_text(String(ammo_max))

func shoot():
	if apuntandoConMouse:
		pivot.look_at(get_global_mouse_position())
	elif rango.get_overlapping_bodies() == []:
		return
	ShootFX1.play()
	var bala = load("res://Scenes/Balas/Bala_ametralladora.tscn").instantiate()
	bala.set_rotation(pivot.global_rotation)
	bala.set_position(player.global_position)
	bala.damage = get_damage()
	juego.add_sibling(get_node("/root/Mundo/Juego/Spawner"),bala)
	cooldown.start(tiempoCooldown)
	if debeRecargar:
		ammo -= 1	
		estadisticasView.Gunammo.set_text(String(ammo))
		if ammo <= 0:	
			start_reload()
			estadisticasView.Gunammo.set_text(String(ammo))

func _input(event):
	if (event.is_action_pressed("Reload") and reloading == false and debeRecargar == true and ammo != ammo_max):
		ammo = 0
		start_reload()

func start_reload():
	ReloadFX.play()
	able_shoot = false
	reloading = true
	reload_time = RELOAD_TIME_BASE
	reloadtimer.start(reload_time)
	hud.reloadiconGun.show()


func aplicarMejoras():
	match self.nivel:
		0:
			pass
		1:
			mejorarDamage(5)

		2:
			mejorarCooldown(0.3)

		3:
			mejorarDamage(5)
			
		4:
			mejorarCooldown(0.4)
			ammo_max = 45
			estadisticasView.Gunammomax.set_text(String(ammo_max))

		5:
			debeRecargar = false
			estadisticasView.Gunammo.hide()
			estadisticasView.Gunammomax.hide()
			estadisticasView.Gunsigno.hide()
			set_rango(85)
			hud.reloadiconGun.hide()



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
	ray_cast.set_target_position((ray_end - ray_start) *ELNUMERO)
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


func _update_closest_enemy():
	if apuntandoConMouse:
		pivot.look_at(get_global_mouse_position())
		if not reloading:
			able_shoot = true
	else:
		aim_to_enemy()

func _on_ReloadTimer_timeout():
	reloading = false
	ammo = ammo_max
	able_shoot = true
	estadisticasView.Gunammo.set_text(String(ammo))
	hud.reloadiconGun.hide()

