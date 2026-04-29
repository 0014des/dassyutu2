extends StaticBody3D

func interact(_player) -> void:
	var room = get_parent()
	if room.has_method("start_recording"):
		room.start_recording()
