extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Server.BtnUnirse = $Unirse
	Server.Lobby = self
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Unirse_pressed():
	Server.join_server()
	$Unirse.disabled = true
	
