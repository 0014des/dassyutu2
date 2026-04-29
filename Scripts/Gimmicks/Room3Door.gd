extends StaticBody3D

func interact(_player) -> void:
	if GameManager.flags.get("room3_switch", false):
		GameManager.add_log("ドアを開けた！")
		get_tree().change_scene_to_file("res://Scenes/Rooms/Room4.tscn")
	else:
		GameManager.add_log("ドアはロックされている。部屋のどこかにあるスイッチを押そう。")
