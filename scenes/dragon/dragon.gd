@tool
extends CharacterBody2D


@onready var visual: Node2D = $Visual
@onready var low_floor_raycast: RayCast2D = %LowFloorRaycast
@onready var hight_floor_raycast: RayCast2D = %HighFloorRaycast

@export var speed: float = 640
@export var bone_restrictions: Dictionary[Node2D, BoneRestriction]
@export var angle_color: Color
@export_tool_button("Gen", "Callable") var generate_bone_restrictions: Callable = _gen_bone_restrictions

@export var selected_node: Sprite2D:
	set(val):
		if selected_node != val:
			selected_node = val
			var br: BoneRestriction = bone_restrictions.get(selected_node)
			if br != null:
				offset = br.offset
				max_angle = br.max_angle

@export_range(-360, 360)var offset: float = 0:
	set(val):
		if offset != val:
			offset = val
			if is_instance_valid(selected_node):
				var br: BoneRestriction =  bone_restrictions.get(selected_node)
				if br != null:
					br.offset = offset
					set_angle = set_angle

@export_range(0, 360) var max_angle: float:
	set(val):
		if max_angle != val:
			max_angle = val
			if is_instance_valid(selected_node):
				var br: BoneRestriction =  bone_restrictions.get(selected_node)
				if br != null:
					br.max_angle = max_angle
					set_angle = set_angle
	
@export_range(0, 1) var set_angle: float = 0.5:
	set(val):
		set_angle = val
		if is_instance_valid(selected_node):
			var br: BoneRestriction =  bone_restrictions.get(selected_node)
			if br != null:
				selected_node.rotation_degrees = remap(set_angle,0, 1,  br.offset, br.offset + br.max_angle)
	
var limbs: Array[Array]

var sprites: Array[Sprite2D]

func _ready() -> void:
	sprites = _get_all_sprites(visual)
		

func _get_all_sprites(node: Node) -> Array[Sprite2D]: 
	var s: Array[Sprite2D]
	var stack: Array = [node]
	while !stack.is_empty():
		var current : Node = stack.pop_back()
		if current.get_child_count() != 0:
			var children = current.get_children()
			for child in children:
				if child is Sprite2D:
					s.append(child)
				stack.append(child)
	return s

func _draw() -> void:
	if Engine.is_editor_hint():
		return
	draw_set_transform_matrix(global_transform.affine_inverse())
	for sprite in sprites:
		draw_circle(sprite.global_position, 5, Color.GREEN, false)
		if bone_restrictions.has(sprite):
			var br: =  bone_restrictions[sprite]
			draw_arc(sprite.global_position, 5, deg_to_rad(br.offset), deg_to_rad(br.offset + br.max_angle), 20, angle_color, 2)
	if sprites.is_empty():
		return
	var root_node: = sprites[0]
	var stack: Array = [root_node]
	while !stack.is_empty():
		var current : Node = stack.pop_back()
		if current.get_child_count() != 0:
			var children = current.get_children()
			for child in children:
				draw_line(current.global_position, child.global_position, Color.BLUE)
				stack.append(child)

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
	move_and_slide()

func _gen_bone_restrictions() -> void:
	for s in sprites:
		bone_restrictions[s] = BoneRestriction.new()
		bone_restrictions[s].max_angle = 90
