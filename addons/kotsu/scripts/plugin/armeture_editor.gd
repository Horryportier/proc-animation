extends EditorProperty


# The main control for editing the property.
var property_control_scene: PackedScene = preload("uid://blnby0jr21rpn")
# An internal value of the property.
var property_control: Control
var current_value: Armature
# A guard against internal changes when the property is updated.
var updating = false


func _init():
	use_folding = true
	# Add the control as a direct child of EditorProperty node.
	property_control = property_control_scene.instantiate()
	add_child(property_control)
	# Make sure the control is able to retain the focus.
	add_focusable(property_control)
	# Setup the initial state and connect to the signal to track changes.


func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()

	# Update the control with the new value.
	updating = true
	current_value = new_value
	property_control.set_up_data(current_value)
	updating = false


