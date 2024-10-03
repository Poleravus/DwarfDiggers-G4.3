extends Node

func display_number(value: int, position: Vector2, juego: Node, is_critical: bool = false):
	var number = preload("res://Scenes/Number.tscn").instantiate()
	number.global_position = position + Vector2(-15,0)
	number.set_text(str(value))

	var color = Color(1, 1, 1)
	if is_critical:
		color = Color8(255, 231, 39, 255) 
	if value == 0:
		color = Color(1, 1, 1, 0.5)

	number.add_theme_color_override("font_color", color)
	
	juego.add_sibling(juego.get_child(2),number)

	# Agregar animación con Tween
	var tween = Tween.new()
	add_child(tween)
	#Escala el tamaño del número de su tamaño original (1, 1) a un tamaño más grande (1.5, 1.5) durante 0.2 segundos.
	tween.interpolate_property(number, "scale", Vector2(0.7, 0.7), Vector2(1.1, 1.1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)

	# Mueve la posición global en el eje Y del número desde su posición original (position.y - 30) hasta una posición más alta (position.y - 100) durante 0.2 segundos.
	tween.interpolate_property(number, "global_position:y", position.y - 30, position.y - 50, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)

	# Vuelve a escalar el número de su tamaño más grande (1.5, 1.5) a su tamaño original (1, 1) durante 0.2 segundos, comenzando después de un retraso de 0.2 segundos.
	tween.interpolate_property(number, "scale", Vector2(1.1, 1.1), Vector2(0.7, 0.7), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.2)

	# Mueve la posición global en el eje Y del número desde su posición más alta (position.y - 100) hasta su posición original (position.y - 30) durante 0.2 segundos, comenzando después de un retraso de 0.2 segundos.
	tween.interpolate_property(number, "global_position:y", position.y - 50, position.y - 30, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.2)
	tween.start()

	# Programar el QueueFree después de la duración total de la animación
	
	var total_duration = 0.3
	await tween.tween_completed
	await get_tree().create_timer(total_duration).timeout
	tween.queue_free()
	if get_node("/root/Mundo/Juego"):
		number.queue_free()
