@tool
class_name Armature
extends Node2D

const KOTSU_IK_TAG: = "kotsu_ik"


enum {
	LIMB_LEN,
	LIMB_MIN,
	LIMB_MAX,
	LIMB_ANGLE_OFFSET,
}

# TODO: partiar rebuilding rebuilding 
enum RebuildType {
	All,
	BoneHierachy,
	Constrains,
}

@export_group("setup")
@export var agent: Node2D
@export var root_bone_node: Node2D
@export_tool_button("Gen from node hierachy", "Callable") var _gen_from_node_hierachy: Callable = _create_bone_structure_from_nodes

@export_category("Armeture")
@export var Armeture: bool
@export_category("Data")
@export_group("data")
@export var node_references: Dictionary[int, Node2D]

@export var joints: Array[Vector2]

@export var bone_hierachy: Dictionary[int, Dictionary]

@export var constrains: Dictionary[int, Array]

@export_group("debug")
@export var debug_draw: bool

@export var selected: int

@export var selected_color_angle: Color
@export var unselected_color_angle: Color

func _draw() -> void:
	if !debug_draw:
		return
	draw_set_transform_matrix(global_transform.affine_inverse())
	for idx in joints.size():
		draw_circle(joints[idx], 2, Color.MAGENTA if idx != selected else Color.YELLOW, false)
		draw_arc(joints[idx], 2, constrains[idx][LIMB_MIN] + constrains[idx][LIMB_ANGLE_OFFSET], constrains[idx][LIMB_MAX] + constrains[idx][LIMB_ANGLE_OFFSET], 20, unselected_color_angle if idx != selected else selected_color_angle, 2)
		for child_idx in bone_hierachy[idx].get("children", []):
			draw_line(joints[idx], joints[child_idx], Color.BLUE if idx != selected else Color.VIOLET)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _create_bone_structure_from_nodes() -> void:
	_clear_bone_structure()
	if !is_instance_valid(root_bone_node):
		push_warning("root_bone_node is null!")
		return
	var stack: Array 
	stack.append(root_bone_node)
	while !stack.is_empty():
		var current: Node2D = stack.pop_back()
		var current_joint: = current.global_position
		joints.append(current_joint)
		var idx: = joints.size() - 1
		node_references[idx] = current
		bone_hierachy[idx] = {}
		_populate_constrains(idx, current)
		for child in current.get_children():
			stack.append(child)
	_build_hierachy()

func _build_hierachy() -> void:
	for idx in  bone_hierachy.keys():
		var node: Node2D = node_references.get(idx)
		var indexes: Array[int]
		for child in node.get_children():
				var child_idx: int =node_references.find_key(child) 
				indexes.append(child_idx)
				bone_hierachy[idx]["parent"] = idx
		bone_hierachy[idx]["children"] = indexes
		var parent: = bone_hierachy[idx].get("parent", -1)
		var parent_is_ik: bool = bone_hierachy.get(parent, {}).get("is_IK", false)
		if node.is_in_group(KOTSU_IK_TAG) or parent_is_ik:
			bone_hierachy[idx]["is_IK"] = true

func _populate_constrains(idx: int, node: Node2D) -> void:
	constrains[idx] = [node.position.distance_to(Vector2.ZERO), -deg_to_rad(180), deg_to_rad(180), 0]

func _clear_bone_structure() -> void:
	node_references.clear()
	joints.clear()
	bone_hierachy.clear()
	constrains.clear()

