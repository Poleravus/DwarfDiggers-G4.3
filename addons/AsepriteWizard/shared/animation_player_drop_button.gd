@tool
extends Button

signal node_dropped(node_path)

func _can_drop_data(_pos, data):
	if data.type == "nodes":
		var node = get_node(data.nodes[0])
		return node is AnimationPlayer
	return false


func _drop_data(_pos, data):
	emit_signal("node_dropped", data.nodes[0])
