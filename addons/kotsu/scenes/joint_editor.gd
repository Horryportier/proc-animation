@tool
extends MarginContainer


@onready var angle_offset: HSlider = %AngleOffset

@onready var min_angle_line_edit: LineEdit = %MinAngleLineEdit
@onready var max_angle_line_edit: LineEdit = %MaxAngleLineEdit

@onready var angle_visulazer: TextureProgressBar = %AngleVisualizer

var _armeture: Armature

var current: int

func _ready() -> void:
	angle_offset.value_changed.connect(_on_angle_offset_value_changed)
	min_angle_line_edit.text_submitted.connect(_on_min_angle_line_edit_text_changed)
	max_angle_line_edit.text_submitted.connect(_on_max_angle_line_edit_text_changed)

func setup(armeture: Armature) -> void:
	_armeture = armeture

func change_selected_joint(idx: int) -> void:
	current = idx
	var constrains: Array = _armeture.constrains.get(current)
	if constrains.size() != 4:
		push_warning("invalid constrain array lenght")
		return
	angle_offset.value = 90 + rad_to_deg(constrains[_armeture.LIMB_ANGLE_OFFSET])
	min_angle_line_edit.text = str(rad_to_deg(constrains[_armeture.LIMB_MIN]))
	max_angle_line_edit.text = str(rad_to_deg(constrains[_armeture.LIMB_MAX]))
	angle_visulazer.radial_initial_angle = angle_offset.value
	update_visualizer()

func update_visualizer() -> void:
	var constrains: Array = _armeture.constrains.get(current)
	if constrains.size() != 4:
		push_warning("invalid constrain array lenght")
		return
	angle_visulazer.value = abs(rad_to_deg(constrains[_armeture.LIMB_MIN]))+\
		 abs(rad_to_deg(constrains[_armeture.LIMB_MAX])) 

	

func _on_angle_offset_value_changed(value: float) -> void:
	var constrains: Array = _armeture.constrains.get(current)
	if constrains.size() != 4:
		push_warning("invalid constrain array lenght")
		return
	constrains[_armeture.LIMB_ANGLE_OFFSET] = deg_to_rad(value - 90)
	angle_visulazer.radial_initial_angle = value
	update_visualizer()

func _on_min_angle_line_edit_text_changed(new_text: String) -> void:
	var constrains: Array = _armeture.constrains.get(current)
	if constrains.size() != 4:
		push_warning("invalid constrain array lenght")
		return
	if !new_text.is_valid_float():
		min_angle_line_edit.text = str(rad_to_deg(constrains[_armeture.LIMB_MIN]))
		return
	constrains[_armeture.LIMB_MIN] = deg_to_rad(float(min_angle_line_edit.text))
	print(constrains[_armeture.LIMB_MIN])
	update_visualizer()

func _on_max_angle_line_edit_text_changed(new_text: String) -> void:
	var constrains: Array = _armeture.constrains.get(current)
	if constrains.size() != 4:
		push_warning("invalid constrain array lenght")
		return
	if !new_text.is_valid_float():
		max_angle_line_edit.text = str(rad_to_deg(constrains[_armeture.LIMB_MAX]))
		return
	constrains[_armeture.LIMB_MAX] = deg_to_rad(float(max_angle_line_edit.text))
	update_visualizer()


