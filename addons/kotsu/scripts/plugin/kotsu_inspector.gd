extends EditorInspectorPlugin

var armature_editor: = preload("uid://b142hy0rsr7rr")

const KOTSU_SETUP_VALUE: String = "Armeture"

func _can_handle(object: Object) -> bool:
	return object is Armature

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == KOTSU_SETUP_VALUE:
		print(object)
		var editor: = armature_editor.new()
		add_property_editor(name, editor)
		return true
	return false
