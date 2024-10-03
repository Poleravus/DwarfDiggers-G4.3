extends Control
@onready var btnReiniciar = $Fondo/btnReiniciar
@onready var btnMenu = $Fondo/btnMenu
signal menuInicioDied
signal iniciarjuegodied
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


func _on_btnMenu_mouse_entered():
	btnMenu.grab_focus()
	



func _on_btnReiniciar_mouse_entered():
	btnReiniciar.grab_focus()


func _on_btnReiniciar_pressed():
	emit_signal("menuInicioDied")
	emit_signal("iniciarjuegodied")
	

func _on_btnMenu_pressed():
	emit_signal("menuInicioDied")
