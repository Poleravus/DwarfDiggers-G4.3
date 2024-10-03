extends Control

@onready var btnAceptar = $Contenedor2/btnAceptar
@onready var AudioMenuAceptar =  get_node("/root/Mundo/SoundMenuFX/MenuAceptar")

var iniciado = false


# Called when the node enters the scene tree for the first time.
func _ready():
	btnAceptar.grab_focus()
	get_tree().paused = true
	iniciado = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_btnAceptar_pressed():
	hide()
	get_tree().paused = false
	AudioMenuAceptar.play()
	iniciado = false
