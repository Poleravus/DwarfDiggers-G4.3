@tool
extends Button

signal dir_dropped(path)

func _can_drop_data(_pos, data):
	if data.type == "files_and_dirs":
		var dir = DirAccess.new()
		return dir.dir_exists(data.files[0])
	return false


func _drop_data(_pos, data):
	emit_signal("dir_dropped", data.files[0])
