extends StaticBody3D

func interact(_player) -> void:
	if GameManager.flags["has_key"]:
		GameManager.flags["door1_unlocked"] = true
		GameManager.add_log("鍵でドアを開けた！")
		get_tree().change_scene_to_file("res://Scenes/Rooms/Room2.tscn")
	else:
		GameManager.add_log("鍵がかかっている...")
