extends Control


# Declare member variables here. Examples:
@onready var hp_bar = $BarraVida/ProgressBar
@onready var exp_bar = $BarraEXP/ProgressBar
@onready var numeroLVL = $lvl/numeroLVL
@onready var game_timer =$Game_timer
@onready var timer = $Timer
@onready var enemigos_vivos = $Enemigos_vivos
@onready var spawner = get_node("/root/Mundo/Juego/Spawner")
@onready var oleadalabel = $Oleada/value
@onready var nivellabel = $Nivel/value
@onready var nombre = $nombre
@onready var reloadiconGun = $reloadiconGun
@onready var reloadiconLanzallamas = $reloadiconLanzallamas
@onready var reloadiconSniper = $reloadiconSniper
@onready var stats = get_node("../../../EstadisticasPersonaje")

const sqlite = preload("res://addons/godot-sqlite/gdsqlite.gdextension")
var db
const DATABASE_PATH_RES = "res://data.db"
const DATABASE_PATH = "user://data.db"


var tiempo

func userDatabase():
	var dir = DirAccess.open("user://")
	if !dir.file_exists(DATABASE_PATH):
		dir.copy(DATABASE_PATH_RES,DATABASE_PATH)

# Called when the node enters the scene tree for the first time.
func _ready():

	userDatabase()
	db = SQLite.new()
	db.path = DATABASE_PATH
	
	reloadiconGun.hide()
	reloadiconSniper.hide()
	reloadiconLanzallamas.hide()
	tiempo = 0
	timer.set_text(convertir_segundos(tiempo))
	game_timer.start(1)

	nivellabel.set_text(str(spawner.get_nivel()))
	oleadalabel.set_text(str(spawner.get_oleada()))
	spawner.connect("enemigos_vivos_cambiado", Callable(self, "_on_enemigos_vivos_cambiado"))
	spawner.connect("oleada_cambiada", Callable(self, "_oleada_cambiada"))
	spawner.connect("nivel_cambiado", Callable(self, "_nivel_cambiado"))
	
	var username = get_username()
	if username != "":
		nombre.set_text(username)
	else:
		nombre.set_text("Usuario no encontrado")

	
func get_username():
	db.open_db()
	var query = "SELECT user FROM players WHERE bandera = true LIMIT 1"
	db.query(query)
	if db.query_result.size() > 0:
		return db.query_result[0]["user"]
	else:
		return ""
	
func get_tiempo():
	return tiempo
	
func _on_EstadisticasPersonaje_vida_actualizada():
	hp_bar.value = stats.get_salud()

func _on_EstadisticasPersonaje_exp_actualizada():
	exp_bar.value = stats.get_experiencia()
	stats.check_exp()

func _on_EstadisticasPersonaje_lvl_actualizado():
	numeroLVL.text = String(stats.get_nivel())

func _on_EstadisticasPersonaje_vidamax_actualizada():
	hp_bar.max_value = stats.get_salud_max()
	hp_bar.value = stats.get_salud_max() #FIX MARRANO

func _on_EstadisticasPersonaje_experiencia_maxima_actualizada():
	exp_bar.max_value = stats.get_experiencia_maxima()
	

func convertir_segundos(seconds: int) -> String:
	var hours = int(seconds / 3600)
	var minutes = int((seconds % 3600) / 60)
	var remaining_seconds = seconds % 60

	var formatted_time = str("%02d:%02d:%02d" % [hours, minutes, remaining_seconds])
	return formatted_time

func _on_enemigos_vivos_cambiado():
	enemigos_vivos.set_text("Enemigos restantes:\n" + str(spawner.get_enemigos_vivos())) 

func _on_Game_timer_timeout():
	tiempo += 1
	timer.set_text(convertir_segundos(tiempo))
	
func _nivel_cambiado():
	TransicionNivel.transicion()
	nivellabel.set_text(str(spawner.get_nivel()))


func _oleada_cambiada():
	oleadalabel.set_text(str(spawner.get_oleada()))
