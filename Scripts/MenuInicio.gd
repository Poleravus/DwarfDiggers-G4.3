extends Control

@onready var BotonI = $Contenedor/BotonIniciar
@onready var BotonC = $Contenedor/BotonCerrar
@onready var Camara = $Camera2D
@onready var btnIniciar = $Contenedor/btnIniciarSesion
@onready var btnOpciones = $Contenedor/btnOpciones
@onready var btnMejorar = $Contenedor/Mejoras
@onready var btnCargar = $Contenedor/BotonCargar
@onready var btnMultijugador = $Contenedor/multijugador
@onready var aviso = $Contenedor/Avisos
@onready var botonInv = $Contenedor/BotonInvitado
@onready var AudioMenuMover = get_node("/root/Mundo/SoundMenuFX/MenuMover")
@onready var AudioMenuAceptar =  get_node("/root/Mundo/SoundMenuFX/MenuAceptar")

var db
const DATABASE_PATH_RES = "res://data.db"
const DATABASE_PATH = "user://data.db"

signal iniciarlogin
signal iniciarjuego
signal iniciaropciones

func userDatabase():
	var dir = DirAccess.open("user://")
	if !dir.file_exists(DATABASE_PATH):
		dir.copy(DATABASE_PATH_RES,DATABASE_PATH)


# Called when the node enters the scene tree for the first time.
func _ready():
	userDatabase()
	btnMultijugador.disabled = true
	btnMultijugador.focus_mode = Control.FOCUS_NONE
	btnIniciar.grab_focus()
	Camara.make_current()
	db = SQLite.new()
	db.path = DATABASE_PATH
	aviso.set_text("¡Tienes que iniciar sesión para jugar!")
	BotonI.disabled = true
	BotonI.focus_mode = Control.FOCUS_NONE
	btnMejorar.disabled = true
	btnMejorar.focus_mode = Control.FOCUS_NONE
	btnCargar.disabled = true
	btnCargar.focus_mode = Control.FOCUS_NONE
	

	if OS.has_feature("HTML5"):
		BotonC.disabled = true
		BotonC.focus_mode = Control.FOCUS_NONE
	

func _on_BotonIniciar_pressed():
	AudioMenuAceptar.play()
	emit_signal("iniciarjuego")
	visible = false
	

func _on_BotonCerrar_pressed():
	db.open_db()
	AudioMenuAceptar.play()
	db.query("UPDATE players SET bandera = false")
	db.close_db()
	get_tree().quit()

func _on_BotonCerrar_mouse_entered():
	BotonC.grab_focus()


func _on_btnIniciarSesion_mouse_entered():
	btnIniciar.grab_focus()
	

func _on_btnOpciones_mouse_entered():
	btnOpciones.grab_focus()


func _on_btnIniciarSesion_pressed():
	visible = false
	AudioMenuAceptar.play()
	emit_signal("iniciarlogin")

func _on_Mejoras_mouse_entered():
	if not btnMejorar.disabled:
		btnMejorar.grab_focus()


func _on_Mejoras_pressed():
	hide()
	Camara.current = false
	var menumejoras = get_node("/root/Mundo/MenuMejorasPerma")
	var Camaramenumejoras = get_node("/root/Mundo/MenuMejorasPerma/Camera2D")
	menumejoras.obtenerStatsDB()
	menumejoras.actualizarDatos()
	AudioMenuAceptar.play()
	menumejoras.visible = true
	Camaramenumejoras.current = true
	menumejoras.upgradevida.grab_focus()

func _on_BotonIniciar_mouse_entered():
	if not BotonI.disabled:
		BotonI.grab_focus()




func _on_btnOpciones_pressed():
	visible = false
	AudioMenuAceptar.play()
	emit_signal("iniciaropciones")


func _on_BotonIniciar_focus_entered():
	AudioMenuMover.play()


func _on_BotonCerrar_focus_entered():
	AudioMenuMover.play()


func _on_btnIniciarSesion_focus_entered():
	AudioMenuMover.play()


func _on_btnOpciones_focus_entered():
	AudioMenuMover.play()


func _on_Mejoras_focus_entered():
	AudioMenuMover.play()


func _on_multijugador_pressed():
	var err 
	err = get_tree().change_scene_to_file("res://Scenes/MultiplayerPruebas/LobbyMultiplayer.tscn")
	if err:
		print("ERROR: ",err)


func _on_BotonInvitado_pressed():
	create_guest_account()

func create_guest_account():

	db.open_db()
	randomize()
	var user = "Guest" + str(ceil(randf_range(1000,9999)))
	var password = ""
	var email = str(ceil(randf_range(1000,9999)))
	var bandera = true
	var query = "INSERT INTO players (user, password, email, bandera) VALUES (?, ?, ?, ?)"
	var resultado = db.query_with_bindings(query, [user, password, email, bandera])
	if resultado:
		var last_insert_id_result = db.query("SELECT last_insert_rowid() AS id")
		if last_insert_id_result and db.query_result.size() > 0:
			var result_last_id = db.query_result[0]["id"]
			ScriptGuardado.userID = result_last_id
			var query_stats = "INSERT INTO player_stats (player_id) VALUES (?)"
			var result = db.query_with_bindings(query_stats, [result_last_id])
			if result == true:
				AudioMenuAceptar.play()
				emit_signal("iniciarjuego")
				visible = false
				#BotonI.disabled = true
				BotonI.focus_mode = Control.FOCUS_ALL
				btnMejorar.disabled = false
				btnMejorar.focus_mode = Control.FOCUS_ALL
				ScriptGuardado.isGuest = true
		else:
			aviso.set_text("Algo salio mal, vuelve a intentarlo.")
	else:
		aviso.set_text("El nombre de usuario o correo ya existe/n")

func delete_guest_account():
	var id = ScriptGuardado.userID
		
	var query_players = "DELETE FROM players WHERE _id = %d" % id
	var query_stats = "DELETE FROM player_stats WHERE player_id = %d" % id
	
	db.open_db()
	var result_players = db.query(query_players)
	var result_stats = db.query(query_stats)
	
	if result_players and result_stats:
		print("Registros eliminados con éxito.")
	else:
		print("Error al eliminar los registros.")
	
	db.close_db()
	btnMejorar.disabled = true
	btnMejorar.focus_mode = Control.FOCUS_NONE
	

func _on_BotonCargar_pressed():
	print("Cargar pulsado")
	AudioMenuAceptar.play()
	visible = false


func _on_BotonCargar_mouse_entered():
	if not btnCargar.disabled:
		btnMejorar.grab_focus()


func _on_BotonCargar_focus_entered():
	AudioMenuMover.play()


func _on_BotonInvitado_mouse_entered():
	if not botonInv.disabled:
		botonInv.grab_focus()


func _on_BotonInvitado_focus_entered():
	AudioMenuMover.play()
