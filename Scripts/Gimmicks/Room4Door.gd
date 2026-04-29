extends StaticBody3D

var is_unlocked = false

func interact(_player) -> void:
	if is_unlocked:
		GameManager.add_log("扉を開けた！")
		get_tree().change_scene_to_file("res://Scenes/Rooms/Room5.tscn")
	else:
		GameManager.add_log("扉はロックされている。空間の『視点』を合わせる必要があるようだ。")

func unlock() -> void:
	is_unlocked = true
