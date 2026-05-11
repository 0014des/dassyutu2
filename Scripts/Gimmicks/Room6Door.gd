extends StaticBody3D

var is_unlocked = false

func interact(_player) -> void:
	if is_unlocked:
		GameManager.add_log("脱出成功！おめでとうございます！")
		await get_tree().create_timer(2.0).timeout
		GameManager.goto_scene("res://Scenes/UI/EndCredits.tscn")
	else:
		GameManager.add_log("【最終試練】分身・回転・視点をすべて合わせる必要がある。")

func unlock() -> void:
	if not is_unlocked:
		is_unlocked = true
		GameManager.add_log("すべての謎が解けた！脱出用の扉が開いた！")
