class_name Bone
extends Resource

@export var constrain: Dictionary[String, float]

static func from_node2D(_node: Node2D) -> Bone:
	var tmp: = Bone.new()
	tmp.constrain["lenght"] = Vector2.ZERO.distance_to(_node.position)
	return tmp



