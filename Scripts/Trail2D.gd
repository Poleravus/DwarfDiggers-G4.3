extends Line2D

@export var trail_lifetime = 20
var time_left_to_remove_point = 0.05
var lenght = 100
var point = Vector2()
var timer = 0.0
var is_trail_active = true

func _ready():
	clear_points()

func _process(delta):
	if is_trail_active:
		global_position = Vector2(0, 0)
		global_rotation = 0
		point = get_parent().global_position
		add_point(point)
		while get_point_count()>lenght:
			remove_point(0)
	else:
		global_position = Vector2(0, 0)
		
		time_left_to_remove_point -=delta
		if time_left_to_remove_point <=0:
			remove_point(0)
			time_left_to_remove_point = 0.1
		if get_point_count() <= 0:
			get_parent().queue_free()

func deactivate_trail():
	is_trail_active = false
	point = get_parent().global_position
	add_point(point)

