extends Control
@onready var popup = $PopupPanel
@onready var velmov = $PopupPanel/VelMov/value
@onready var suerte = $PopupPanel/Suerte/value
@onready var exprango = $PopupPanel/ExpRango/value
@onready var damage = $PopupPanel/Damage/value
@onready var vida = $PopupPanel/Vida/value
@onready var regeneracion = $PopupPanel/Regeneracion/value
@onready var monedas = $PopupPanel/Monedas/value
@onready var FPS = $PopupPanel/FPS/value
@onready var Pico = $PopupPanel/Armas/VBoxContainer/Pico
@onready var Picolvl = $PopupPanel/Armas/VBoxContainer/Pico/lvl
@onready var Gun = $PopupPanel/Armas/VBoxContainer/Gun
@onready var Gunlvl= $PopupPanel/Armas/VBoxContainer/Gun/lvl
@onready var Gunammo  = $PopupPanel/Armas/VBoxContainer/Gun/ammo
@onready var Gunammomax = $PopupPanel/Armas/VBoxContainer/Gun/ammoMax
@onready var Gunsigno = $PopupPanel/Armas/VBoxContainer/Gun/signo
@onready var sniper = $PopupPanel/Armas/VBoxContainer/sniper
@onready var sniperlvl =$PopupPanel/Armas/VBoxContainer/sniper/lvl
@onready var sniperammomax = $PopupPanel/Armas/VBoxContainer/sniper/ammomax
@onready var sniperammo = $PopupPanel/Armas/VBoxContainer/sniper/ammo
@onready var snipersigno = $PopupPanel/Armas/VBoxContainer/sniper/signo
@onready var lanzallamas = $PopupPanel/Armas/VBoxContainer/lanzallamas
@onready var lanzallamaslvl = $PopupPanel/Armas/VBoxContainer/lanzallamas/lvl
@onready var lanzallamasammo = $PopupPanel/Armas/VBoxContainer/lanzallamas/ammo
@onready var lanzallamassigno = $PopupPanel/Armas/VBoxContainer/lanzallamas/signo
@onready var lanzallamasammomax = $PopupPanel/Armas/VBoxContainer/lanzallamas/ammomax
@onready var bobina =$PopupPanel/Armas/VBoxContainer/BobinaTesla
@onready var bobinalvl = $PopupPanel/Armas/VBoxContainer/BobinaTesla/lvl
@onready var armaunknown =$PopupPanel/Armas/VBoxContainer/armaunknown
@onready var armaunknownlvl = $PopupPanel/Armas/VBoxContainer/armaunknown/lvl
@onready var armaunknownammo = $PopupPanel/Armas/VBoxContainer/armaunknown/ammo
@onready var container = $PopupPanel/Armas/VBoxContainer
@onready var stats = get_node("/root/Mundo/Juego/Player/EstadisticasPersonaje")
@onready var AudioMenuAceptar =  get_node("/root/Mundo/SoundMenuFX/MenuAceptar")
@onready var AudioMenuAtras = get_node("/root/Mundo/SoundMenuFX/MenuAtras")

var GunlvlN = 1
var PicolvlN = 1
var sniperlvlN = 1
var lanzallamaslvlN = 1
var bobinalvlN = 1
var posicion = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	popup.visible = false
	velmov.set_text(str(stats.get_velocidad_movimiento()))
	suerte.set_text(str(stats.get_suerte()))
	exprango.set_text(str(limitar_a_centesimas(stats.get_rango_recogida())))
	damage.set_text(str(stats.get_damage()))
	vida.set_text(str(int(stats.get_salud())))
	regeneracion.set_text(str(stats.get_regeneracion_pasiva()))
	monedas.set_text(str(stats.get_monedas()))
	container.remove_child(Pico)
	container.remove_child(Gun)
	container.remove_child(sniper)
	container.remove_child(lanzallamas)
	container.remove_child(bobina)
	container.remove_child(armaunknown)


func limitar_a_centesimas(valor):
	var factor = pow(10, 2)
	return floor(valor * factor) / factor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed('ui_e'):
		popup.visible  = not popup.visible
		AudioMenuAceptar.play()
	FPS.set_text(str(Engine.get_frames_per_second()))
 

func _on_EstadisticasPersonaje_rango_recogida_actualizado():
	exprango.set_text(str(stats.get_rango_recogida()))


func _on_EstadisticasPersonaje_velocidad_mov_actualizada():
	velmov.set_text(str(stats.get_velocidad_movimiento()))


func _on_EstadisticasPersonaje_vida_actualizada():
	vida.set_text(str(int(stats.get_salud())))


func _on_EstadisticasPersonaje_suerte_actualizada():
	suerte.set_text(str(stats.get_suerte()))


func _on_EstadisticasPersonaje_regeneracion_actualizada():
	regeneracion.set_text(str(stats.get_regeneracion_pasiva()))


func _on_EstadisticasPersonaje_monedas_actualizadas():
	monedas.set_text(str(stats.get_monedas()))


func _on_EstadisticasPersonaje_damage_actualizado():
	damage.set_text(str(stats.get_damage()))


func _on_Armas_inventarioAmetralladora():
	container.add_child(Gun)
	container.move_child(Gun, posicion)
	posicion = posicion + 1


func _on_Armas_inventarioBobina():
	container.add_child(bobina)
	container.move_child(bobina, posicion)
	posicion = posicion + 1


func _on_Armas_inventarioLanzallamas():
	container.add_child(lanzallamas)
	container.move_child(lanzallamas, posicion)
	posicion = posicion + 1


func _on_Armas_inventarioPico():
	container.add_child(Pico)
	container.move_child(Pico, posicion)
	posicion = posicion + 1
	

func _on_Armas_inventarioSniper():
	container.add_child(sniper)
	container.move_child(sniper, posicion)
	posicion = posicion + 1


func _on_Armas_mejorarAmetralladora():
	GunlvlN = GunlvlN + 1
	Gunlvl.set_text(String(GunlvlN))
	

func _on_Armas_mejorarBobina():
	bobinalvlN = bobinalvlN + 1
	bobinalvl.set_text(String(bobinalvlN))


func _on_Armas_mejorarLanzallamas():
	lanzallamaslvlN = lanzallamaslvlN + 1
	lanzallamaslvl.set_text(String(lanzallamaslvlN))

func _on_Armas_mejorarPico():
	PicolvlN = PicolvlN + 1
	Picolvl.set_text(String(PicolvlN))

func _on_Armas_mejorarSniper():
	sniperlvlN = sniperlvlN + 1
	sniperlvl.set_text(String(sniperlvlN))
