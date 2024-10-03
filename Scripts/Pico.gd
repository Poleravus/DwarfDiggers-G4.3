extends Arma
class_name Pico_arma
@onready var player = get_node("/root/Mundo/Juego/Player")
@onready var juego = get_node("/root/Mundo/Juego")
@onready var rango_deteccion = $Rango/CollisionShape2D
@onready var SlashFX1 = $SlashFXpico1
@onready var SlashFX2 = $SlashFXpico2
@onready var SlashFX3 = $SlashFXpico3
@onready var SlashFX4 = $SlashFXpico4
@onready var SlashFX5 = $SlashFXpico5

@onready var joypads = Input.get_connected_joypads()

const RANGO_BASE = 60
const SPRITE_SCALE = Vector2(0.08,0.08)
const ANIMATION_SCALE = Vector2(1.4,1.4)
const POSICION_ANIMACION = Vector2(44,3)
const POSICION_SPRITE = 39
const BASE_DAMAGE = 8
const COOLDOWN_BASE = 2
var preDamage = BASE_DAMAGE
var rango_slash = RANGO_BASE
var sprite_scale
var animation_scale
var sprite_newPos
var animacion_newPos
var tiempoCooldown = COOLDOWN_BASE

var rng = RandomNumberGenerator.new()
"res://Scenes/Armas/Pico.tscn"
func set_damage(value=0):
	if value == BASE_DAMAGE:
		damage =value
	else:
		preDamage += value
		var nuevoDamage = preDamage * stats.get_damage()
		damage =nuevoDamage
	

func _ready():
	get_parent().connect("mejorarPico", Callable(self, "_on_Armas_mejorarPico"))
	set_damage(BASE_DAMAGE)
	sprite_scale = SPRITE_SCALE
	animation_scale = ANIMATION_SCALE
	sprite_newPos = POSICION_SPRITE
	actualizar_radio(rango_slash);
	aim_to_enemy()
	rng.randomize()


func shoot_pico():
	if rango.get_overlapping_bodies()== []:
		able_shoot = true
		return
	aim_to_enemy()
	sound_random()
	var bala = preload("res://Scenes/Balas/Slash_pico.tscn").instantiate()
	bala.set_deferred("rotation",pivot.global_rotation)
	bala.set_deferred("position",pivot.global_position)
	bala.set_damage(get_damage())
	bala.get_node("Sprite2D").set_deferred("scale",sprite_scale)
	bala.get_node("Sprite2D").set_deferred("position.x",sprite_newPos) 
	bala.get_node("Animacion").set_deferred("scale",animation_scale) 
	bala.get_node("Animacion").set_deferred("position",animacion_newPos)
	call_deferred("add_bullet_to_scene", bala)
	able_shoot=false
	if joypads.size() > 0:
		var joypad_id = joypads[0]
		Input.start_joy_vibration(joypad_id, 0.2, 0.75, 0.2)  # Configuración de prueba
	

	cooldown.start(tiempoCooldown)
	able_shoot=false
	if joypads.size() > 0:
		var joypad_id = joypads[0]
		Input.start_joy_vibration(joypad_id, 0.2, 0.75, 0.2)  # Configuración de prueba
	
	


func add_bullet_to_scene(bala):
	juego.add_sibling(get_node("/root/Mundo/Juego/Spawner"), bala)
	
func sound_random():
	var numeroFX = rng.randi_range(1,5)
	
	match numeroFX:
		1:
			SlashFX1.play()
		2:
			SlashFX2.play()
		3: 
			SlashFX3.play()
		4:
			SlashFX4.play()
		5:
			SlashFX5.play()

func actualizar_radio(radio_nuevo):
	rango_deteccion.shape.set_radius(radio_nuevo)
	rango_slash = radio_nuevo
	sprite_scale = radio_nuevo * SPRITE_SCALE / RANGO_BASE
	animation_scale = radio_nuevo * ANIMATION_SCALE / RANGO_BASE
	sprite_newPos = radio_nuevo * POSICION_SPRITE/ RANGO_BASE
	animacion_newPos = radio_nuevo * POSICION_ANIMACION / RANGO_BASE

func aplicarMejoras():
	match self.nivel:
		0:
			pass
		1:
			mejorarDamage(2)
		2:
			mejorarCooldown(0.2)
		3:
			mejorarDamage(3)
		4:
			mejorarCooldown(0.45)
		5:
			actualizar_radio(rango_slash+40)

func mejorarDamage(mejora):
	var damageActual = self.get_damage()
	self.set_damage(mejora)

func mejorarCooldown(mejora):
	var tmp = tiempoCooldown * mejora
	tiempoCooldown = COOLDOWN_BASE-tmp


func _on_Armas_mejorarPico():
	var nivelActual = self.get_nivel()
	self.set_nivel(nivelActual+1);
	aplicarMejoras()
	
func _on_Cooldown_timeout():
	able_shoot = true
	shoot_pico()

	


func _on_Rango_body_entered(body):
	if able_shoot and body.is_in_group("Enemy"):
		shoot_pico()
