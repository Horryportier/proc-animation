extends CharacterBody2D

@onready var tentacle_scene: PackedScene = preload("res://scenes/test/tentacle.tscn")
@onready var snap_point_texture: Texture2D = preload("uid://y5m8xebrs64u")
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var raycast: RayCast2D = $RayCast2D

var tentacle_count: int = 4


var disable_grabing_force: bool


@export var speed: float = 640

@export var y_velocity_per_tentacle_count: Curve
@export var max_statinary_time: float = 5
@export var min_statinary_velocity: Vector2 = Vector2(16, 16)

var tentacles: Array

var target: Vector2 = Vector2(200, 300)

var connected: int


var nav_timeout: SceneTreeTimer 

var statinary_time: float

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	tentacle_count = randi_range(2, 5)
	for i in tentacle_count:
		var tentacle: Node2D = tentacle_scene.instantiate()
		tentacle.position = rand_vec(16)
		tentacles.append(tentacle)
		add_child(tentacle)
		tentacle.line2D.modulate = modulate
	_change_target((Vector2(randf(), randf()) * 2  -Vector2.ONE) * 1024)
	

func _change_target(new_target: Vector2) -> void:
	nav_timeout = null
	target = NavigationServer2D.map_get_closest_point(get_world_2d().navigation_map, new_target)
	set_movement_target(target)
	

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("select"):
		var raw_target: = get_global_mouse_position() + ((Vector2(randf(), randf()) * 2  -Vector2.ONE) * 64)
		_change_target(raw_target)
	connected =  tentacles.map(func (f: Node2D) -> bool: return f.is_at_target()).filter(func (f: bool) -> bool: return f).size()
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	for tentacle in tentacles:
		if tentacle.is_at_target():
			continue
		raycast.target_position = Vector2.LEFT.rotated(deg_to_rad(randf_range(0 ,360))) * (tentacle.segments_count * tentacle.segments_lenght)
		#raycast.force_update_transform()
		for i in 360 / 30:
			if raycast.is_colliding():
				tentacle.update_target(raycast.get_collision_point())
				continue
			raycast.target_position = raycast.target_position.rotated(45)

func _draw() -> void:
	return
	draw_set_transform_matrix(global_transform.affine_inverse())
	draw_circle(target, 10, Color.MISTY_ROSE)
	draw_line(global_position, global_position + velocity, Color.PURPLE)



func set_movement_target(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	if velocity.abs() < min_statinary_velocity:
		statinary_time += get_process_delta_time()
	else: 
		statinary_time = 0
	if statinary_time >= max_statinary_time:
		raycast.target_position =  global_position.direction_to(target) * (tentacles[0].segments_count * tentacles[0].segments_lenght)
		if !raycast.is_colliding() and !navigation_agent.is_target_reached() and !disable_grabing_force:
			disable_grabing_force = true
			get_tree().create_timer(3).timeout.connect(func () -> void: disable_grabing_force = false)
			
		#_change_target(target + rand_vec(64))
		
	velocity = safe_velocity 
	var gravity_influance: float = y_velocity_per_tentacle_count.sample(remap(connected , 0, tentacle_count, 0, 1)) if !disable_grabing_force else 1
	velocity.y += clampf((get_gravity() * gravity_influance).y, 0, INF)
	
	move_and_slide()

func rand_vec(radious: float) -> Vector2:
	return ((Vector2(randf(), randf()) * 2  -Vector2.ONE) * radious)
