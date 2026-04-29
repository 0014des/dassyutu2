extends Node3D

@onready var player = $Player
@onready var door = $Door
var solved = false

func _process(_delta: float) -> void:
	if solved: return
	if not player or not player.has_node("Camera3D"): return
	var camera = player.get_node("Camera3D")
	
	# 指定された視点座標
	var viewpoint = Vector3(0, 1, -5)
	
	# プレイヤーの足元の座標（Y軸は無視するか、高さを考慮）
	var player_pos = player.global_position
	player_pos.y = 1.0 # プレイヤーの高さを基準に合わせる
	var dist = player_pos.distance_to(viewpoint)
	
	# 視線を向けるべき中心点
	var look_target = Vector3(0, 1, 0)
	var look_dir = -camera.global_transform.basis.z
	var target_dir = (look_target - camera.global_position).normalized()
	var dot = look_dir.dot(target_dir)
	
	# 所定の位置にいて、正しい方向を見ているか判定
	if dist < 0.8 and dot > 0.98:
		solved = true
		GameManager.add_log("視点が合致した！カチャッという音がした。")
		door.unlock()
