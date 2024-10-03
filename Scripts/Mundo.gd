extends Node2D



var menuinicio = load("res://Scenes/Menus/MenuInicio.tscn")
var mapa = load("res://Scenes/Mundo/MapGen.tscn")
var jugador = load("res://Scenes/Personajes/Player.tscn")
var spawner = load("res://Scenes/Mundo/Spawner.tscn")
var juego = load("res://Scenes/Mundo/Juego.tscn")
var login = load("res://Scenes/Menus/Login.tscn")
var registro = load("res://Scenes/Menus/Registro.tscn")
var menumejoras = load ("res://Scenes/Menus/MenuMejorasPerma.tscn")
var menuopciones = load("res://Scenes/Menus/GUIopciones.tscn")

var login_instance
var registro_instance
var juego_instance
var menumejoras_instance
var menuopciones_instance
var reinicio = false

var db
const sqlite = preload("res://addons/godot-sqlite/gdsqlite.gdextension")
const DATABASE_PATH_RES = "res://data.db"
const DATABASE_PATH = "user://data.db"


func userDatabase():
	var dir = DirAccess.open("user://")
	var err = DirAccess.get_open_error()
	print("ERROR DE DATABASE OPEN: ",err)
	if !dir.file_exists(DATABASE_PATH):
		dir.copy(DATABASE_PATH_RES,DATABASE_PATH)



func _ready():
	userDatabase()
	add_child(menuinicio.instantiate())
	login_instance = login.instantiate()
	registro_instance = registro.instantiate()
	menumejoras_instance = menumejoras.instantiate()
	menuopciones_instance = menuopciones.instantiate()
	add_child(login_instance)
	add_child(registro_instance)
	add_child(menumejoras_instance)
	add_child(menuopciones_instance)
	get_node("/root/Mundo/MenuInicio").connect("iniciarjuego", Callable(self, "_iniciarjuego"))
	login_instance.hide()
	registro_instance.hide()
	menumejoras_instance.hide()
	menuopciones_instance.hide()
	db = SQLite.new()
	db.path = DATABASE_PATH

func _iniciarjuego():
	AudioServer.set_bus_mute(0,true)
	_eliminar_juego_anterior()
	await get_tree().create_timer(0.1).timeout  # Espera 0.1 segundos para asegurarse de que el juego se elimine
	_crear_nueva_instancia_juego()
	AudioServer.set_bus_mute(0,false)

func _crear_nueva_instancia_juego():
	juego_instance = juego.instantiate()
	add_child(juego_instance)
	
	var mapa_instance = mapa.instantiate()
	var spawner_instance = spawner.instantiate()
	var jugador_instance = jugador.instantiate()

	juego_instance.add_child(mapa_instance)
	juego_instance.add_child(spawner_instance)
	juego_instance.add_child(jugador_instance)
	reinicio = false
	var gui_opciones = jugador_instance.get_node("Camera2D/CanvasLayer/GUIpausa")
	if not gui_opciones.is_connected("menuInicio", Callable(self, "_menuInicio")):
		gui_opciones.connect("menuInicio", Callable(self, "_menuInicio"))

	var you_died = jugador_instance.get_node("Camera2D/CanvasLayer/YOUDIED!")
	if not you_died.is_connected("menuInicioDied", Callable(self, "_menuInicio")):
		you_died.connect("menuInicioDied", Callable(self, "_menuInicio"))
	if not you_died.is_connected("iniciarjuegodied", Callable(self, "_reiniciar_juego")):
		you_died.connect("iniciarjuegodied", Callable(self, "_reiniciar_juego"))
	reinicio = false


func _eliminar_juego_anterior():
	if juego_instance and juego_instance.get_parent():
		juego_instance.queue_free()
#		yield(get_tree().create_timer(0.5), "timeout")
#		if get_node("/root/DamageNumbers").get_child_count()>0:
#			var remanin_numbers = DamageNumbers.get_children()
#			for number in remanin_numbers:
#				number.queue_free()
		juego_instance = null

func _menuInicio():
	
	_eliminar_juego_anterior()
	await get_tree().create_timer(0.1).timeout  # Espera 0.1 segundos para asegurarse de que el juego se elimine
	var menuinicio2 = get_node("/root/Mundo/MenuInicio")
	var CamaraMenu = get_node("/root/Mundo/MenuInicio/Camera2D")
	if reinicio == false:
		menuinicio2.visible = true
		CamaraMenu.current = true
		if ScriptGuardado.isGuest:
			menuinicio2.BotonI.focus_mode = Control.FOCUS_NONE
			menuinicio2.delete_guest_account()
		#menuinicio2.BotonI.grab_focus()
	get_tree().paused = false
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if $Juego and not ScriptGuardado.isGuest: #Si el jugador le dio a la cruz dentro del juego ,(no en el menu)
			ScriptGuardado.write_savegame()
		cerrar_sesion()

func cerrar_sesion():
	db.open_db()
	db.query("UPDATE players SET bandera = false")
	db.close_db()
	if not ScriptGuardado.isGuest:
		ScriptGuardado.reset()
	
func _reiniciar_juego():
	reinicio = true
	_iniciarjuego()
