extends StaticBody3D

var is_unlocked = false

var changing_scene = false

func interact(_player) -> void:
	if changing_scene: return
	if is_unlocked:
		changing_scene = true
		GameManager.add_log("扉を開けた！いよいよ最終ルームだ。")
		# 少し待ってから遷移することで、ログを表示する余裕を持たせる
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://Scenes/Rooms/Room6.tscn")
	else:
		GameManager.add_log("扉はロックされている。2つのスイッチを同時に押す必要がある。")

func unlock() -> void:
	if not is_unlocked:
		is_unlocked = true
		GameManager.add_log("カチッ！同時押しに成功し、扉が開いた！")
