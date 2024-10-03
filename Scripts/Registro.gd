extends Control
@onready var camera2d = $Camera2D
@onready var usuarioedit = $Contenedor/Usuario
@onready var contrasenaedit = $Contenedor/Contrasena
@onready var correoedit = $Contenedor/Correo
@onready var btnRegistrar = $Contenedor/btnRegistrar
@onready var btnVolver = $Contenedor/btnVolver
@onready var aviso = $Contenedor/Avisos
@onready var AudioMenuMover = get_node("/root/Mundo/SoundMenuFX/MenuMover")
@onready var AudioMenuAceptar =  get_node("/root/Mundo/SoundMenuFX/MenuAceptar")
@onready var AudioMenuAtras = get_node("/root/Mundo/SoundMenuFX/MenuAtras")

const sqlite = preload("res://addons/godot-sqlite/gdsqlite.gdextension")
var db
const DATABASE_PATH_RES = "res://data.db"
const DATABASE_PATH = "user://data.db"

func userDatabase():
	var dir = DirAccess.open("user://")
	if !dir.file_exists(DATABASE_PATH):
		dir.copy(DATABASE_PATH_RES,DATABASE_PATH)

# Called when the node enters the scene tree for the first time.
func _ready():
	userDatabase()
	camera2d.set_enabled(false) 
	db = SQLite.new()
	db.path = DATABASE_PATH
	



func _on_Usuario_mouse_entered():
	usuarioedit.grab_focus()
	

func _on_btnRegistrar_mouse_entered():
	btnRegistrar.grab_focus()
	

func _on_Contrasena_mouse_entered():
	contrasenaedit.grab_focus()


func _on_btnVolver_mouse_entered():
	btnVolver.grab_focus()
	

func _on_Correo_mouse_entered():
	correoedit.grab_focus()


func _on_btnVolver_pressed():
	hide()
	AudioMenuAtras.play()
	camera2d.set_current(false)
	var menuinicio2 = get_node("/root/Mundo/MenuInicio")
	var CamaraMenu = get_node("/root/Mundo/MenuInicio/Camera2D")
	db.open_db()
	db.query("SELECT COUNT(*) as count FROM players WHERE bandera = true")
	if db.query_result[0]["count"] > 0:
		menuinicio2.BotonI.disabled = false
		menuinicio2.BotonI.focus_mode = Control.FOCUS_ALL
		menuinicio2.btnMejorar.disabled = false
		menuinicio2.btnMejorar.focus_mode = Control.FOCUS_ALL
		menuinicio2.visible = true
		CamaraMenu.set_current(true)
		menuinicio2.BotonI.grab_focus()
		
	else:
		menuinicio2.BotonI.disabled = true
		menuinicio2.BotonI.focus_mode = Control.FOCUS_NONE
		menuinicio2.btnMejorar.disabled = true
		menuinicio2.btnMejorar.focus_mode = Control.FOCUS_NONE
		menuinicio2.visible = true
		CamaraMenu.set_current(true)
		menuinicio2.btnIniciar.grab_focus()
	


func _on_btnRegistrar_pressed():
	AudioMenuAceptar.play()
	var password = contrasenaedit.text
	var email = correoedit.text
	var username = usuarioedit.text
	insert_data(username, email, password,false)
	

func insert_data(user: String, email: String, password: String, bandera: bool):
	if user.is_empty() or email.is_empty() or password.is_empty():
		aviso.set_text("Todos los valores son obligatorios.")
		contrasenaedit.text = ""
		correoedit.text = ""
		usuarioedit.text = ""
		return
	if not is_valid_email(email):
		aviso.set_text("El correo electrónico no es válido.")
		contrasenaedit.text = ""
		correoedit.text = ""
		usuarioedit.text = ""
		return
		
	db.open_db()
	var query = "INSERT INTO players (user, password, email, bandera) VALUES (?, ?, ?, ?)"
	var resultado = db.query_with_bindings(query, [user, password, email, bandera])
	if resultado:
		var last_insert_id_result = db.query("SELECT last_insert_rowid() AS id")
		if last_insert_id_result and db.query_result.size() > 0:
			var result_last_id = db.query_result[0]["id"]
			var query_stats = "INSERT INTO player_stats (player_id) VALUES (?)"
			var result = db.query_with_bindings(query_stats, [result_last_id])
			if result == true:
				aviso.set_text("¡Registro exitoso!")
				hide()
				usuarioedit.set_text("")
				correoedit.set_text("")
				contrasenaedit.set_text("")
				camera2d.set_current(false)
				var menu_inicio = get_node("/root/Mundo/MenuInicio")
				var Camara_inicio = get_node("/root/Mundo/MenuInicio/Camera2D")
				menu_inicio.aviso.set_text("¡Registro exitoso!, ahora inicia sesion.")
				menu_inicio.visible = true
				Camara_inicio.set_current(true)
		else:
			aviso.set_text("Algo salio mal, vuelve a intentarlo.")
			contrasenaedit.text = ""
			correoedit.text = ""
			usuarioedit.text = ""
	else:
		aviso.set_text("El nombre de usuario o correo ya existe/n")

func is_valid_email(email: String) -> bool:
	var email_regex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
	var regex = RegEx.new()
	if regex.compile(email_regex) == OK:
		return regex.search(email) != null
	return false
	


func _on_Usuario_focus_entered():
	AudioMenuMover.play()


func _on_btnRegistrar_focus_entered():
	AudioMenuMover.play()


func _on_Contrasena_focus_entered():
	AudioMenuMover.play()


func _on_btnVolver_focus_entered():
	AudioMenuMover.play()


func _on_Correo_focus_entered():
	AudioMenuMover.play()
