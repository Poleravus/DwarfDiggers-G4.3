extends Control

@onready var botonR = $Fondo/botonReanudar
@onready var botonO = $Fondo/botonOpciones
@onready var botonS = $Fondo/botonSalir
@onready var pausa = $Pausa
@onready var Fondo = $Fondo
@onready var AudioMenuMover = get_node("/root/Mundo/SoundMenuFX/MenuMover")
@onready var AudioMenuAceptar =  get_node("/root/Mundo/SoundMenuFX/MenuAceptar")
@onready var AudioMenuAtras = get_node("/root/Mundo/SoundMenuFX/MenuAtras")
#onready var menulvlup =  get_node("/root/Mundo/Juego/Player/Camera2D/GUIlvlup")
@onready var menulvlup =  get_node("../GUIlvlup")
#onready var opcionesingame = get_node("/root/Mundo/Juego/Player/Camera2D/GUIopcionesingame")
@onready var opcionesingame = get_node("../GUIopcionesingame")
@onready var instrucciones = get_node("../Instrucciones")
@onready var menu = get_node("/root/Mundo/MenuInicio")
var inicio = preload("res://Scenes/Menus/MenuInicio.tscn")
var pausa_activa = false
var player = load("res://Scenes/Personajes/Player.tscn")
signal menuInicio

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
	Fondo.visible = false
	pausa.visible = true
	set_process_input(true)
	pausa.connect("pressed", Callable(self, "_on_Player_menupausa"))
	db = SQLite.new()
	db.path = DATABASE_PATH
	

	
func _input(event):
	if (event.is_action_pressed("ui_cancel") or pausa.is_pressed()) and  opcionesingame.iniciado == false and instrucciones.iniciado == false:
		if pausa_activa: 
			_on_botonReanudar_pressed()
		else:
			_on_Player_menupausa()



func _on_Player_menupausa():
		AudioMenuAceptar.play()
		pausa.hide()
		get_tree().paused = true
		set_focus_mode(Control.FOCUS_ALL)
		Fondo.visible = true
		botonR.grab_focus()
		pausa_activa = true



func _on_botonReanudar_pressed():
	AudioMenuAtras.play()
	if menulvlup.menulvlupactivo:
		pausa.show()
		menulvlup.boton1.grab_focus()
	else:
		get_tree().paused = false
	Fondo.visible = false
	pausa.show()
	pausa_activa = false
	
	


func _on_botonReanudar_mouse_entered():
	botonR.grab_focus()


func _on_botonOpciones_pressed():
	AudioMenuAceptar.play()
	if menulvlup.menulvlupactivo:
		menulvlup.boton1.grab_focus()
	else:
		get_tree().paused = false
	Fondo.visible = false
	opcionesingame.iniciaropcionesingame()


func _on_botonOpciones_mouse_entered():
	botonO.grab_focus()
	


func _on_botonSalir_pressed():
	AudioMenuAtras.play()
	if not ScriptGuardado.isGuest:
		ScriptGuardado.write_savegame()
	else:
		menu.delete_guest_account()
		
	emit_signal("menuInicio")
	

	

func _on_botonSalir_mouse_entered():
	botonS.grab_focus()



func _on_Pausa_mouse_entered():
	pausa.grab_focus()


func _on_botonReanudar_focus_entered():
	AudioMenuMover.play()


func _on_botonOpciones_focus_entered():
	AudioMenuMover.play()


func _on_botonSalir_focus_entered():
	AudioMenuMover.play()
