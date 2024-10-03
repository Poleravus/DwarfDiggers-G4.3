extends CharacterBody2D

var direction: Vector2
const SPEED = 4000
var damage = 0
var knockback = 50
var max_distance = 500
var distance_traveled = 0
var bounces = 0
var desactivado = false
var velocity
@onready var area = $Area2D

func set_bounces(value):
	bounces = value
	
func get_bounces():
	return bounces

func _ready():
	$Sprite2D.visible = false

func _physics_process(delta):
	if not desactivado:
		velocity = direction * SPEED
		var collision_info = move_and_collide(direction * SPEED * delta)
		area.set_rotation_degrees(rad_to_deg(atan2(velocity.y,velocity.x)))
		if collision_info:
			if collision_info.collider.is_in_group("Tilemap"):
				if bounces <= 0:
					desactivado = true
					deactivate_bullet()
					return
				bounces -= 1
				direction = direction.bounce(collision_info.normal)
		# Calculating distance traveled
		distance_traveled += direction.length() * delta
		
		# Check if max_distance has been exceeded
		if distance_traveled >= max_distance:
			desactivado = true
			deactivate_bullet()

func deactivate_bullet():
	if has_node("Trail2D"):
		var trail = $Trail2D
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(5,false)
		$Sprite2D.visible = false
		trail.deactivate_trail()
		set_physics_process(false)


func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemy") or body.is_in_group("Entity"):
		body.take_damage(damage,false)
