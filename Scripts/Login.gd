extends Control
@onready var camera2d = $Camera2D
@onready var usuarioedit = $Contenedor/Usuario
@onready var contrasenaedit = $Contenedor/Contrasena
@onready var btnAceptar = $Contenedor/btnAceptar
@onready var btnRegistrarse = $Contenedor/btnRegistrarse
@onready var btnVolver = $Contenedor/btnVolver
@onready var aviso = $Contenedor/Avisos
@onready var AudioMenuMover = get_node("/root/Mundo/SoundMenuFX/MenuMover")
@onready var AudioMenuAceptar =  get_node("/root/Mundo/SoundMenuFX/MenuAceptar")
@onready var AudioMenuAtras = get_node("/root/Mundo/SoundMenuFX/MenuAtras")
const sqlite = preload("res://addons/godot-sqlite/gdsqlite.gdextension")
@onready var menuinicio2 = get_node("/root/Mundo/MenuInicio")
var userID = INF
var db
const DATABASE_PATH_RES = "res://data.db"
const DATABASE_PATH = "user://data.db"

func userDatabase():
	var dir = DirAccess.open("user://")
	if !dir.file_exists(DATABASE_PATH):
		dir.copy(DATABASE_PATH_RES,DATABASE_PATH)


func _ready():
	userDatabase()
	get_node("/root/Mundo/MenuInicio").connect("iniciarlogin", Callable(self, "_iniciarlogin"))
	db = SQLite.new()
	db.path = DATABASE_PATH

func _iniciarlogin():
	show()
	camera2d.set_current(true)
	usuarioedit.grab_focus()
	
func _on_Contrasena_mouse_entered():
	contrasenaedit.grab_focus()

func _on_Usuario_mouse_entered():
	usuarioedit.grab_focus()

func _on_btnAceptar_mouse_entered():
	btnAceptar.grab_focus()
	

func _on_btnRegistrarse_mouse_entered():
	btnRegistrarse.grab_focus()
	
func _on_btnVolver_mouse_entered():
	btnVolver.grab_focus()	


func _on_btnVolver_pressed():
	hide()
	AudioMenuAtras.play()
	camera2d.set_current(false)

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
		print("Save Encontrado en btn volver pressed: ",ScriptGuardado.get_SaveEncontrado())
		if ScriptGuardado.get_SaveEncontrado():
			print("Save Encontrado dentro de if :",ScriptGuardado.get_SaveEncontrado())
			menuinicio2.btnCargar.disabled = false
			menuinicio2.btnCargar.focus_mode = Control.FOCUS_ALL
			
		
	else:
		menuinicio2.BotonI.disabled = true
		menuinicio2.BotonI.focus_mode = Control.FOCUS_NONE
		menuinicio2.btnMejorar.disabled = true
		menuinicio2.btnMejorar.focus_mode = Control.FOCUS_NONE
		menuinicio2.visible = true
		CamaraMenu.set_current(true)
		menuinicio2.btnIniciar.grab_focus()
	hide()
	AudioMenuAtras.play()
	camera2d.set_current(false)
	
	


func _on_btnRegistrarse_pressed():
	hide()
	AudioMenuAceptar.play()
	camera2d.set_current(false)
	var registro = get_node("/root/Mundo/Registro")
	var CamaraRegistro = get_node("/root/Mundo/Registro/Camera2D")
	registro.visible = true
	CamaraRegistro.set_current(true)
	registro.usuarioedit.grab_focus()


func _on_btnAceptar_pressed():
	AudioMenuAceptar.play()
	var password = contrasenaedit.text
	var username = usuarioedit.text
	db.open_db()
	
	var result = db.query("SELECT _id, user, password FROM players WHERE user = '" + username + "' AND password = '" + password + "'")
	if db.query_result.size() > 0:
		userID = db.query_result[0]["_id"]  # Retrieve the ID from the query result
		aviso.set_text("¡Bienvenido "+username+"!")
		db.query("UPDATE players SET bandera = false")
		db.query("UPDATE players SET bandera = true WHERE _id = " + str(userID))
		menuinicio2.botonInv.disabled = true
		menuinicio2.botonInv.focus_mode = Control.FOCUS_NONE 
		ScriptGuardado.isGuest = false
		usuarioedit.set_text("") 
		contrasenaedit.set_text("")
		save_folder(userID,username)
		get_node("/root/Mundo/MenuInicio").aviso.set_text("¡Bienvenido "+username+"!")
		_on_btnVolver_pressed()
	
	else:
		aviso.set_text("Usuario y/o contraseña incorrectos")

func save_folder(id: int, username: String) -> void: #Revisa si existe un guardado para el player, si no crea una carpeta
	#Construye el nombre de la carpeta utilizando el ID del jugador y su nombre de ususario 
	var folder_name = str(id) + username
	var save_path = "user://saves/" + folder_name + "/"
	ScriptGuardado.SAVE_FILE_NAME = username+"Save.tres"
	# Check if the folder already exists
	if not DirAccess.dir_exists_absolute(save_path):
		# Create the directory
		var dir = DirAccess.open("user://saves/")
		var err = dir.make_dir_recursive(save_path)
		if err == OK:
			print("Carpeta de guardado creada en : " + save_path)
			ScriptGuardado.SAVE_GAME_PATH = save_path
		else:
			print("Error al crear carpeta de guardado. Error code: " + str(err))
	else: #Carpeta encontrada
		print("Carpeta de guardado encontrada en : " + save_path)
		ScriptGuardado.SAVE_GAME_PATH = save_path
		comprobar_save(ScriptGuardado.SAVE_GAME_PATH + ScriptGuardado.SAVE_FILE_NAME)
		print("SaveEncontrado despues de comprobarsave(): ",ScriptGuardado.get_SaveEncontrado())

func comprobar_save(save_path): #Comprueba si existe una partida guardada y 
	if FileAccess.file_exists(save_path):
		print("SI EXISTE: ", save_path)
		ScriptGuardado.set_SaveEncontrado(true)
	else:
		print("NO EXISTE EL ARCHIVO", save_path)
		ScriptGuardado.set_SaveEncontrado(false)
	


func _on_Usuario_focus_entered():
	AudioMenuMover.play()


func _on_btnAceptar_focus_entered():
	AudioMenuMover.play()


func _on_Contrasena_focus_entered():
	AudioMenuMover.play()


func _on_btnRegistrarse_focus_entered():
	AudioMenuMover.play()


func _on_btnVolver_focus_entered():
	AudioMenuMover.play()
