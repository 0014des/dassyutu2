extends StaticBody3D

func interact(_player) -> void:
	GameManager.flags["has_key"] = true
	GameManager.add_log("鍵を手に入れた！")
	queue_free()
