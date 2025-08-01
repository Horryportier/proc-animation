@tool
class_name Armature
extends Node2D

const KOTSU_IK_TAG: = "kotsu_ik"


signal selected_changed

enum {
	LIMB_LEN,
	LIMB_MIN,
	LIMB_MAX,
	LIMB_ANGLE_OFFSET,
}

# TODO: partiar rebuilding rebuilding 
enum {
	REBUILD_TYPE_ALL = 1 ,
	REBUILD_TYPE_BONEHIERACHY = 2,
	REBUILD_TYPE_CONSTRAINS = 4,
}

@export_group("setup")
@export var agent: Node2D
@export var root_bone_node: Node2D
@export_flags("ALL", "BONE_HIERACHY", "CONSTRAINS") var rebuild_type: int = REBUILD_TYPE_ALL
@export_tool_button("Gen from node hierachy", "Callable") var _gen_from_node_hierachy: Callable = _create_bone_structure_from_nodes

@export_category("Armeture")
@export var Armeture: bool
@export_category("Data")
@export_group("data")
@export var node_references: Dictionary[int, Node2D]

@export var joints: PackedVector2Array
@export var joints_rest_pose: PackedVector2Array

@export var bone_hierachy: Dictionary[int, Dictionary]

@export var constrains: Dictionary[int, Array]

@export var ik_chains: Dictionary[Node2D, Dictionary]

@export_group("debug")
@export var debug_draw: bool

@export var selected: int:
	set(val):
		selected = val
		selected_changed.emit()

@export var selected_color_angle: Color
@export var unselected_color_angle: Color

var default_font 


func _ready() -> void:
	selected_changed.connect(_on_selected_changed)
	default_font = ThemeDB.fallback_font

func _draw() -> void:
	if !debug_draw:
		return
	#draw_set_transform_matrix(global_transform.affine_inverse())
	for idx in joints.size():
		var is_ik = bone_hierachy[idx].get("is_IK")
		draw_circle(joints[idx], 2, Color.RED if is_ik else Color.YELLOW, false)
		draw_arc(joints[idx], 2, constrains[idx][LIMB_MIN] + constrains[idx][LIMB_ANGLE_OFFSET], constrains[idx][LIMB_MAX] + constrains[idx][LIMB_ANGLE_OFFSET], 20, unselected_color_angle if idx != selected else selected_color_angle, 2)
		for child_idx in bone_hierachy[idx].get("children", []):
			draw_line(joints[idx], joints[child_idx], Color.BLUE if idx != selected else Color.VIOLET)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_ik_chain(node_references[selected], get_global_mouse_position())
	if debug_draw:
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
		if is_any_rebuild_flag_maching(REBUILD_TYPE_ALL | REBUILD_TYPE_CONSTRAINS):
			_populate_constrains(idx)
		constrains[idx][LIMB_LEN] = current.position.distance_to(Vector2.ZERO)
		for child in current.get_children():
			stack.append(child)
	joints_rest_pose = joints.duplicate()
	_build_hierachy()
	_find_ik_chanis()

func _build_hierachy() -> void:
	for idx in  bone_hierachy.keys():
		var node: Node2D = node_references.get(idx)
		var indexes: Array[int]
		for child in node.get_children():
				var child_idx: int =node_references.find_key(child) 
				indexes.append(child_idx)
				bone_hierachy[child_idx]["parent"] = idx
		bone_hierachy[idx]["children"] = indexes
		var parent: = bone_hierachy[idx].get("parent", -1)
		var parent_is_ik: bool = bone_hierachy.get(parent, {}).get("is_IK", false)
		if node.is_in_group(KOTSU_IK_TAG):
			bone_hierachy[idx]["IK_start"] = true
		if node.is_in_group(KOTSU_IK_TAG) or parent_is_ik:
			bone_hierachy[idx]["is_IK"] = true

func _populate_constrains(idx: int) -> void:
	constrains[idx] = [0, -deg_to_rad(180), deg_to_rad(180), 0]

func _find_ik_chanis() -> void:
	var ik_starts: Array[int]
	for idx in bone_hierachy.keys():
		if bone_hierachy[idx].get("IK_start",  false):
			ik_starts.append(idx)
	for ik_start in ik_starts:
		var node = node_references[ik_start]
		ik_chains[node] = { "indexes": get_decentands_non_branching(ik_start) }
		ik_chains[node]["lenght"] = get_chain_lenght(ik_chains[node]["indexes"])

func get_chain_lenght(indexes: Array[int]) -> float:
	var sum: = 0
	for idx in indexes:
		sum += constrains[idx][LIMB_LEN]
	return sum

func update_ik_chain(node: Node2D, target: Vector2) -> void:
	var ik_chain: = ik_chains.get(node, {})
	var indexes: Array = ik_chain.get("indexes", [])
	if indexes.is_empty():
		if Engine.is_editor_hint():
			return
		push_warning("tried to update node thats' not an ik chain: ", node)
		return
	var _joints: PackedVector2Array
	var _limbs: Array = [[0, 0, 0, 0]]
	for idx in indexes:
		_joints.append(joints[idx])
		_limbs.append(constrains[idx])
	_joints.resize(_limbs.size() + 1)
	var new_joints := FabirkConstrained._update(to_local(target), _joints, _limbs, node.position, ik_chain["lenght"], _limbs.size())
	for idx in indexes.size():
		joints[indexes[idx]] = new_joints[idx + 1]

func get_decentands_non_branching(start: int) -> Array[int]:
	var indexes: Array[int]
	var stack : Array
	stack.append(start)
	while !stack.is_empty():
		var current: = stack.pop_back()
		if current != start:
			indexes.append(current)
		var children: = bone_hierachy[current].get("children", [])
		if children.size() != 0:
			stack.append(children[0])
	return indexes

func is_any_rebuild_flag_maching(flag: int) -> bool:
	return rebuild_type & flag != 0

func _clear_bone_structure() -> void:
	if is_any_rebuild_flag_maching(REBUILD_TYPE_ALL | REBUILD_TYPE_BONEHIERACHY):
			ik_chains.clear()
			node_references.clear()
			joints.clear()
			bone_hierachy.clear()
	if is_any_rebuild_flag_maching(REBUILD_TYPE_CONSTRAINS):
			constrains.clear()
	
func _on_selected_changed() -> void:
	if !ik_chains.has(node_references[selected]):
		joints = joints_rest_pose.duplicate()

