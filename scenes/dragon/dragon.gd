extends CharacterBody2D


@onready var visual: Node2D = $Visual
@onready var low_floor_raycast: RayCast2D = %LowFloorRaycast
@onready var hight_floor_raycast: RayCast2D = %HighFloorRaycast
@onready var drango_neck: Node2D = %DragonLowerNeck
@onready var armeture: Armature = $Armature

@export var speed: float = 640

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	if hight_floor_raycast.is_colliding():
		velocity.y = 0
	else:
		velocity.y = get_gravity().y * delta
	if low_floor_raycast.is_colliding():
		velocity.y = get_gravity().y * delta * -1
	velocity.x = Input.get_axis("left", "right") * speed * delta
	armeture.update_ik_chain(drango_neck, get_global_mouse_position())
	move_and_slide()


