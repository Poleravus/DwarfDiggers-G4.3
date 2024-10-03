extends Node2D

@onready var player = get_node("/root/Mundo/Juego/Player")
@onready var sprite = $Area2D/Sprite2D
@onready var soundExp = $EXPfx
@export var velocidad_objeto = 3
var activar_movimiento = false
const TIME_GOING_BACK = 0.1
@export var tipo = "xp"
var cantidad = 0
var aceleracion = 1
var went_back = false
var textura_xp = preload("res://Sprites/Objetos/Experiencia.png")
var textura_cura = preload("res://Sprites/Objetos/DropHP.png")
var time_var = TIME_GOING_BACK
var last_player_pos
@onready var stats = get_node("/root/Mundo/Juego/Player/EstadisticasPersonaje")
#-----Setters-----
func set_last_player_pos(pos):
	last_player_pos=pos
func set_tipo(_tipo):
	tipo = _tipo
func set_cantidad(_cantidad):
	cantidad = _cantidad
func set_activar_movimiento(_activar_movimiento):
	activar_movimiento = _activar_movimiento

#------Getters-----
func get_last_player_pos():
	return last_player_pos
func get_tipo():
	return tipo
func get_cantidad():
	return cantidad
func get_activar_movimiento():
	return activar_movimiento

	
func _ready():
	dibujar()

func _physics_process(delta):
	if activar_movimiento:
		mover()
		time_var -= delta
		if time_var<= 0:
			went_back = true
	

func mover():
	if went_back:
		position+=((player.position - position).normalized()*velocidad_objeto) * aceleracion
		aceleracion += 0.005
	else:
		position-=((last_player_pos - position).normalized()*(velocidad_objeto+2)) 


	


func activar_efecto():
	if tipo == "xp":
		var xp_actual = stats.get_experiencia()
		soundExp.play()
#		if cantidad > 20:
#			sprite.get_canvas_item().set_modulate(Color(10,241,57,255)) Cambiar color? da un bug raro, de RID en CanvasItem
		stats.set_experiencia(xp_actual+cantidad)
		hide()
		
		
	if tipo == "cura":
		var vida_actual = stats.get_salud()
		var vida_max = stats.get_salud_max()
		var curacion = cantidad
		if vida_actual != vida_max:
			if  curacion < (vida_max - vida_actual) :
				stats.set_salud(vida_actual + curacion)
			else:
				stats.set_salud(vida_max)
		soundExp.play()
		hide()
	
	await soundExp.finished
	queue_free()
	


func dibujar(): #Settea el sprite a utilizar segun el tipo de objeto
	if tipo == "xp":
		sprite.set_texture(textura_xp)
	if tipo == "cura":
		sprite.set_scale(Vector2(0.04,0.04))
		sprite.set_texture(textura_cura)


