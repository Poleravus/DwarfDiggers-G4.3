extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer
signal on_transicion_finished

func _ready():
	color_rect.visible = false
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		emit_signal("on_transicion_finished")
		# Una vez que la transición a negro ha finalizado, iniciar la transición de nuevo mapa
		_iniciar_transicion_nuevo_mapa()
	elif anim_name == "fade_to_normal":
		color_rect.visible = false

func _iniciar_transicion_nuevo_mapa():
	var map_gen = get_node("/root/Mundo/Juego/MapGen")
	var player = get_node("/root/Mundo/Juego/Player")
	player.global_position = Vector2(0, 0)
	map_gen.nuevoMapa()
	# Iniciar la transición de vuelta a la normalidad después de cambiar el mapa
	animation_player.play("fade_to_normal")

func transicion():
	# Asegurar que el color_rect esté visible antes de iniciar la transición
	color_rect.visible = true
	# Iniciar la animación de transición a negro
	animation_player.play("fade_to_black")
