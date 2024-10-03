extends Node2D


var _salud = 100
var _salud_max
var _damage = 1
var _velocidad_movimiento = 100
var _regeneracion_pasiva = 2
var _suerte = 0
var _rango_recogida = 1
var _nivel = 1
var _experiencia = 0
var _monedas = 1
var _experiencia_maxima = 100

var nivelBotas = 0
var nivelRango = 0

var player_id

var estadisticasResource : Resource = EstadisticasSave.new()

func set_estadisticasResource():
	estadisticasResource.salud = _salud
	estadisticasResource.salud_max = _salud_max
	estadisticasResource.damage = _damage
	estadisticasResource.velocidad_movimiento = _velocidad_movimiento
	estadisticasResource.regeneracion_pasiva = _regeneracion_pasiva
	estadisticasResource.suerte = _suerte
	estadisticasResource.rango_recogida = _rango_recogida
	estadisticasResource.nivel = _nivel
	estadisticasResource.experiencia = _experiencia
	estadisticasResource.monedas = _monedas
	estadisticasResource.experiencia_maxima = _experiencia_maxima
	estadisticasResource.nivelBotas = nivelBotas
	estadisticasResource.nivelRango = nivelRango


signal vida_actualizada
signal exp_actualizada
signal rango_recogida_actualizado
signal lvl_actualizado
signal lvl_up
signal velocidad_mov_actualizada
signal muelto
signal vidamax_actualizada
signal experiencia_maxima_actualizada
signal suerte_actualizada
signal monedas_actualizadas
signal damage_actualizado
signal regeneracion_actualizada
signal actualizarDamageArma


const sqlite = preload("res://addons/godot-sqlite/gdsqlite.gdextension")
var db
const DATABASE_PATH_RES = "res://data.db"
const DATABASE_PATH = "user://data.db"
@onready var animacionPlayer = get_node("../AnimationPlayer")
@onready var player = self.get_parent()


func set_nivelBotas(value):
	nivelBotas = value
	estadisticasResource.nivelBotas = value
	
func userDatabase():
	var dir = DirAccess.open("user://")
	if !dir.file_exists(DATABASE_PATH):
		dir.copy(DATABASE_PATH_RES,DATABASE_PATH)


func _ready():
	userDatabase()
	db = SQLite.new()
	db.path = DATABASE_PATH
	
	
	

func set_stats():
	db.open_db()
	var query = "SELECT _id FROM players WHERE bandera = true"
	var resultado = db.query(query)
	if resultado and db.query_result.size() > 0:
		player_id = db.query_result[0]["_id"]
	if player_id:
		var query_stats = "SELECT * FROM player_stats WHERE player_id = ?"
		var resultado_stats = db.query_with_bindings(query_stats, [player_id])
		if resultado_stats:
			var stats = db.query_result
			set_salud_max(stats[0]["vidamaxima"])
			set_damage(stats[0]["daño"])
			set_velocidad_movimiento(stats[0]["velocidad"])
			set_rango_recogida(stats[0]["rango"])
			set_monedas(stats[0]["monedas"])
	db.close_db()
#	set_estadisticasResource() 
#Setea las estadisticas del save. No es necesario si ya se setean en cada setter de las estdisticas reales.


func get_nivelBotas():
	return nivelBotas
	
func set_nivelRango(value):
	nivelRango = value
	estadisticasResource.nivelRango = value

func get_nivelRango():
	return nivelRango

func set_salud(value):
	_salud = value
	estadisticasResource.salud = value
	emit_signal("vida_actualizada")
	check_vida()


func get_salud():
	return _salud
	
func set_salud_max(value):
	_salud_max = value
	estadisticasResource.salud_max = value
	if _salud + value >_salud_max:
		_salud = _salud_max
		estadisticasResource.salud = estadisticasResource.salud_max
	else:
		_salud = _salud + value
		estadisticasResource.salud += value 
	emit_signal("vida_actualizada")
	emit_signal("vidamax_actualizada")

func get_salud_max():
	return _salud_max

func set_damage(value):
	_damage = value
	estadisticasResource.damage = value
	emit_signal("actualizarDamageArma")
	emit_signal("damage_actualizado")
	
func get_damage():
	return _damage

func set_velocidad_movimiento(value):
	_velocidad_movimiento = value
	estadisticasResource.velocidad_movimiento = value
	emit_signal("velocidad_mov_actualizada")	

func get_velocidad_movimiento():
	return _velocidad_movimiento

func set_regeneracion_pasiva(value):
	_regeneracion_pasiva = value
	estadisticasResource.regeneracion_pasiva = value
	emit_signal("regeneracion_actualizada")

func get_regeneracion_pasiva():
	return _regeneracion_pasiva

func set_suerte(value):
	_suerte = value
	estadisticasResource.suerte = value
	emit_signal("suerte_actualizada")

func get_suerte():
	return _suerte

func set_rango_recogida(value):
	if value > 0:
		_rango_recogida = value
		estadisticasResource.rango_recogida = value
		emit_signal("rango_recogida_actualizado")

func get_rango_recogida():
	return _rango_recogida

func set_nivel(value):
	_nivel = value
	estadisticasResource.nivel = value
	emit_signal("lvl_actualizado")

func get_nivel():
	return _nivel

func set_experiencia(value):
	_experiencia = value
	estadisticasResource.experiencia = value
	emit_signal("exp_actualizada")

func get_experiencia():
	return _experiencia

func set_monedas(value):
	_monedas = value
	estadisticasResource.monedas = value
	emit_signal("monedas_actualizadas")

func get_monedas():
	return _monedas
	
func set_experiencia_maxima(value):
	_experiencia_maxima = value
	estadisticasResource.experiencia_maxima = value
	emit_signal("experiencia_maxima_actualizada")
	
func get_experiencia_maxima():
	return _experiencia_maxima

func check_vida():
	if _salud <= 0:
		if not player.muerto:
			emit_signal("muelto")  
		
func check_exp():
	if _experiencia >= _experiencia_maxima:
		set_experiencia(get_experiencia() - get_experiencia_maxima())
		set_nivel(_nivel+1)
		set_experiencia_maxima((get_experiencia_maxima()*1.1)+30)
		emit_signal("lvl_up")
		
func lvlupDebug():
	set_experiencia(0)
	set_nivel(_nivel+1)
	emit_signal("lvl_up")
		
func aplicarMejorasBotas():
	match nivelBotas:
		1,2:
			set_velocidad_movimiento(_velocidad_movimiento+5)
		3:
			set_velocidad_movimiento(_velocidad_movimiento+10)
		4: 
			set_velocidad_movimiento(_velocidad_movimiento+10)
		5:
			set_velocidad_movimiento(_velocidad_movimiento+20)
		6:
			set_velocidad_movimiento(_velocidad_movimiento+20)
			
			
func aplicarMejorasRango():
	match nivelRango:
		1,2:
			mejorarRango(0.2)
		3:
			mejorarRango(0.2)
		4: 
			mejorarRango(0.4)
		5:
			mejorarRango(0.4)
		6:
			mejorarRango(0.4)
			
			

func _on_Player_set_mejora_botas():
	var nivelActual = get_nivelBotas()
	set_nivelBotas(nivelActual+1);
	aplicarMejorasBotas()
	

func mejorarRango(mejora):
	var rangoActual = get_rango_recogida()
	var nuevoRango = rangoActual*mejora
	set_rango_recogida(rangoActual+nuevoRango)

func _on_Player_set_mejora_rango():
	var nivelActual = get_nivelRango()
	set_nivelRango(nivelActual+1);
	aplicarMejorasRango()
	


func _on_Player_set_mejora_vida():
	var vida_actual = get_salud()
	var vida_max = get_salud_max()
	var curacion = 10
	if vida_actual != vida_max:
		if  curacion < (vida_max - vida_actual) :
			set_salud(vida_actual + curacion)
		else:
			set_salud(vida_max)


func _on_Player_set_mejora_damage():
	var damageActual = get_damage()
	set_damage(damageActual+0.1)
	


func _on_Player_set_mejora_dinero():
	var monedasActuales = self.get_monedas()
	self.set_monedas(monedasActuales+200)
	
