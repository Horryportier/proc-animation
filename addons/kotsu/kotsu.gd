@tool
extends EditorPlugin


var plugin: EditorInspectorPlugin

func _enter_tree() -> void:
	plugin = preload("uid://d14l1205dpdoa").new()
	add_inspector_plugin(plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(plugin)
