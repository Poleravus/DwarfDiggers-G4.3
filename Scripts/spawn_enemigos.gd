extends Node2D

signal enemigos_vivos_cambiado
signal nivel_cambiado
signal oleada_cambiada

const MAX_CANT_ENEMY = 300

var oleada  
var nivel 
var enemigos_vivos = 0
var n = 0
var recogiendo = false
var rango_recogida_shape
var radio_inicial
const TIEMPO_ENTRE_OLEADAS = 60
const MAX_WAVE = 10


# Setters
func set_oleada(value):
	oleada = value
	emit_signal("oleada_cambiada")

func set_nivel(value):
	nivel = value
	emit_signal("nivel_cambiado")

# Getters
func get_oleada():
	return oleada

func get_nivel():
	return nivel

func get_enemigos_vivos():
	return enemigos_vivos

func _ready():
	set_oleada(0)
	set_nivel(1)

	$Spawn_timer.start(TIEMPO_ENTRE_OLEADAS)
	call_deferred("spawn_wave")
	TransicionNivel.animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func spawn_wave():
	oleada += 1
	if oleada <= MAX_WAVE:
		set_oleada(oleada)
		for _i in range(oleada):#FANTASMA
			var enemy_batch = preload("res://Scenes/Enemigos/Enemy_batch.tscn").instantiate()
			var random_radius = randf_range(500,550)
			enemy_batch.position = get_node("/root/Mundo/Juego/Player").position + Vector2(random_radius, 0).rotated(randf_range(0, 2 * PI))
			call_deferred("add_child",enemy_batch)
			conectar_enemigos(enemy_batch)
		for _i in range(0,oleada*2):#MURCIEGALO
			var bat = preload("res://Scenes/Enemigos/Bat.tscn").instantiate()
			var random_radius = randf_range(500,550)
			bat.position = get_node("/root/Mundo/Juego/Player").position + Vector2(random_radius, 0).rotated(randf_range(0, 2 * PI))
			call_deferred("add_child",bat)
			bat.connect("enemy_died", Callable(self, "_on_enemy_died"))
			enemigos_vivos += 1
		var cantGolem = (oleada * 0.5) - 3 
		cantGolem = floor(cantGolem)
		if cantGolem < 1:
			cantGolem = 1
		for _i in range(0,cantGolem):#GOLEM
			var stone_golem = preload("res://Scenes/Enemigos/StoneGolem.tscn").instantiate()
			var random_radius = randf_range(500,550)
			stone_golem.position = get_node("/root/Mundo/Juego/Player").position + Vector2(random_radius, 0).rotated(randf_range(0, 2 * PI))
			call_deferred("add_child",stone_golem)
			stone_golem.connect("enemy_died", Callable(self, "_on_enemy_died"))
			enemigos_vivos += 1
		emit_signal("enemigos_vivos_cambiado")
			
		if oleada == MAX_WAVE:#JEFE FANTASMA
			var enemy = load("res://Scenes/Enemigos/Enemigo.tscn")
			var enemy_instance
			enemy_instance = enemy.instantiate()
			enemy_instance.position = get_node("/root/Mundo/Juego/Player").position + Vector2(400, 0).rotated(randf_range(0, 2 * PI))
			enemy_instance.connect("enemy_died", Callable(self, "_on_enemy_died"))
			add_child(enemy_instance)
			enemigos_vivos +=1
			emit_signal("enemigos_vivos_cambiado")
			enemy_instance.StarBoss.show()
			enemy_instance.set_damage(100)
			enemy_instance.set_vida(600)
			enemy_instance.set_velocidad((enemy_instance.jugador.stats.get_velocidad_movimiento())*0.8)
			enemy_instance.sprite.set_modulate("#bc4d88")
			enemy_instance.set_scale(Vector2(2, 2))
			$Spawn_timer.stop()
	else:
		set_oleada(0)
		set_nivel(get_nivel()+1)
		
		
func conectar_enemigos(enemy_batch):
	for enemy in enemy_batch.get_children():
		enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
		enemigos_vivos += 1
	if enemigos_vivos >= MAX_CANT_ENEMY:
		$Spawn_timer.stop()
	emit_signal("enemigos_vivos_cambiado")
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_normal":
		$Break_timer.start(5)

func _on_enemy_died():
	enemigos_vivos -= 1
	if enemigos_vivos <=MAX_CANT_ENEMY-100 and oleada<MAX_WAVE and $Spawn_timer.is_stopped():
		$Spawn_timer.start(TIEMPO_ENTRE_OLEADAS)
	if enemigos_vivos == 0:
		$Spawn_timer.stop()
		if oleada == MAX_WAVE:
			$Break_timer.start(7)
			rango_recogida_shape = get_node("/root/Mundo/Juego/Player/Rango_recogida/CollisionShape2D")
			radio_inicial = get_node("/root/Mundo/Juego/Player").RADIO_INICIAL
			rango_recogida_shape.shape.radius = 6000
			recogiendo = true
		$Break_timer.start(5)
	emit_signal("enemigos_vivos_cambiado")

	
func _on_Spawn_timer_timeout():
	spawn_wave()
	

func _on_Break_timer_timeout():
	if recogiendo:
		var stats = get_node("/root/Mundo/Juego/Player/EstadisticasPersonaje")
		stats.emit_signal("rango_recogida_actualizado")
	$Break_timer.stop()
	$Spawn_timer.start(TIEMPO_ENTRE_OLEADAS)
	spawn_wave()
