@tool
extends Control

@onready var joints_list: ItemList = %JointsList
@onready var joint_editor: Control  = %JointEditor



var _armeture: Armature



func set_up_data(armeture: Armature) -> void:
	_armeture = armeture
	joint_editor.setup(_armeture)
	_generate_joints_list(_armeture)

	joints_list.item_selected.connect(_on_joints_list_item_selected)

func _generate_joints_list(armeture: Armature) -> void:
	joints_list.clear()
	var gui = EditorInterface.get_base_control()
	for idx in armeture.joints.size():
		var node: Node2D = armeture.node_references.get(idx)
		if !is_instance_valid(node):
			push_warning("found invalid node reference in armeture")
			continue
		var icon: Texture2D = gui.get_theme_icon(node.get_class(), "EditorIcons")
		joints_list.add_item(node.name, icon)

func _on_joints_list_item_selected(idx: int) -> void:
	_armeture.selected = idx
	joint_editor.change_selected_joint(idx)
