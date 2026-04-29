extends StaticBody3D

func interact(_player) -> void:
	if not GameManager.flags.get("room3_switch", false):
		GameManager.flags["room3_switch"] = true
		GameManager.add_log("スイッチを押した！何かのロックが解除されたようだ。")
	else:
		GameManager.add_log("すでにスイッチは押されている。")
