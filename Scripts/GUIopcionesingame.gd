extends Control

@onready var FullscreenCheck = $Fondo/Video/FullScreen/FCheckBox
@onready var BorderlessCheck = $Fondo/Video/Borderless/BCheckBox
@onready var VsyncCheck = $Fondo/Video/Vsync/VCheckBox
@onready var VolumenMasterSlider = $Fondo/Audio/Master/MaVHSlider
@onready var VolumenMusicaSlider = $Fondo/Audio/Musica/MuVHSlider
@onready var VolumenFXSlider = $Fondo/Audio/FX/FxVHSlider
@onready var RegresarBTN = $Fondo/RegresarBTN
@onready var MenuPausa = get_node("../GUIpausa")
@onready var AudioMenuMover = get_node("/root/Mundo/SoundMenuFX/MenuMover")
@onready var AudioMenuAceptar =  get_node("/root/Mundo/SoundMenuFX/MenuAceptar")
@onready var AudioMenuAtras = get_node("/root/Mundo/SoundMenuFX/MenuAtras")
@onready var AudioCambiarVolumen = get_node("/root/Mundo/SoundMenuFX/CambiarVolumen")

var iniciado = false



# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func iniciaropcionesingame():
	iniciado = true
	show()
	FullscreenCheck.grab_focus()
	get_tree().paused = true
	FullscreenCheck.set_pressed(((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))
	BorderlessCheck.set_pressed(get_window().borderless)
	VsyncCheck.set_pressed((DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED))
	VolumenMasterSlider.set_value(AudioServer.get_bus_volume_db(0))
	VolumenFXSlider.set_value(AudioServer.get_bus_volume_db(1))
	VolumenMusicaSlider.set_value(AudioServer.get_bus_volume_db(2))



func _on_FCheckBox_mouse_entered():
	FullscreenCheck.grab_focus()	
	

func _on_BCheckBox_mouse_entered():
	BorderlessCheck.grab_focus()

	
func _on_VCheckBox_mouse_entered():
	VsyncCheck.grab_focus()


func _on_VHSlider_mouse_entered():
	VolumenMasterSlider.grab_focus()

func _on_RegresarBTN_mouse_entered():
	RegresarBTN.grab_focus()


func _on_FCheckBox_toggled(button_pressed):
	AudioMenuAceptar.play()
	if button_pressed:
		BorderlessCheck.set_pressed(false)
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (button_pressed) else Window.MODE_WINDOWED
	


func _on_BCheckBox_toggled(button_pressed):
	AudioMenuAceptar.play()
	if button_pressed:
		FullscreenCheck.set_pressed(false)
	get_window().borderless = (button_pressed)


func _on_VCheckBox_toggled(button_pressed):
	AudioMenuAceptar.play()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (button_pressed) else DisplayServer.VSYNC_DISABLED)


func _on_VHSlider_value_changed(value):
	AudioCambiarVolumen.play()
	volume(0, value)
	
func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)
	if value == -30:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)


func _on_RegresarBTN_pressed():
	AudioMenuAtras.play()
	hide()
	iniciado = false
	get_tree().paused = false
	MenuPausa._on_Player_menupausa()


func _on_FCheckBox_focus_entered():
	AudioMenuMover.play()


func _on_BCheckBox_focus_entered():
	AudioMenuMover.play()


func _on_VCheckBox_focus_entered():
	AudioMenuMover.play()


func _on_VHSlider_focus_entered():
	AudioMenuMover.play()

func _on_RegresarBTN_focus_entered():
	AudioMenuMover.play()


func _on_MuVHSlider_focus_entered():
	AudioMenuMover.play()


func _on_FXVHSlider_focus_entered():
	AudioMenuMover.play()


func _on_MuVHSlider_mouse_entered():
	VolumenMusicaSlider.grab_focus()


func _on_FXVHSlider_mouse_entered():
	VolumenFXSlider.grab_focus()


func _on_MuVHSlider_value_changed(value):
	AudioCambiarVolumen.play()
	volume(2, value)


func _on_FXVHSlider_value_changed(value):
	AudioCambiarVolumen.play()
	volume(1, value)
