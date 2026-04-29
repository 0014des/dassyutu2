extends Node3D

@onready var player = $Player
@onready var clone = $Clone
@onready var rotatable_room = $RotatableRoom
@onready var door = $Door

var recording = []
var is_recording = false
var is_playing = false
var record_timer = 0.0
var play_index = 0
const MAX_RECORD_TIME = 10.0 
const INTERVAL = 0.05 

var perspective_solved = false

func _ready() -> void:
	clone.hide()

func start_recording() -> void:
	recording.clear()
	is_recording = true
	is_playing = false
	clone.hide()
	record_timer = 0.0
	GameManager.add_log("【最終統合】記録開始！スイッチAに乗って待機してください。")

func _physics_process(delta: float) -> void:
	if is_recording:
		record_timer += delta
		if record_timer >= INTERVAL:
			# 回転する部屋に対する相対的な座標を記録する
			var relative_transform = rotatable_room.global_transform.affine_inverse() * player.global_transform
			recording.append(relative_transform)
			record_timer = 0.0
		
		if recording.size() >= MAX_RECORD_TIME / INTERVAL:
			is_recording = false
			GameManager.add_log("記録終了！部屋を回転させて視点を合わせてください。")
			start_playing()

	if is_playing:
		if play_index < recording.size():
			# 部屋の現在の回転に合わせて分身を配置する
			clone.global_transform = rotatable_room.global_transform * recording[play_index]
			play_index += 1
		else:
			play_index = 0 

func start_playing() -> void:
	is_playing = true
	play_index = 0
	clone.show()

func _process(_delta: float) -> void:
	# 視点チェック
	if not player or not player.has_node("Camera3D"): return
	var camera = player.get_node("Camera3D")
	
	var viewpoint = $ViewpointMark.global_position + Vector3(0, 1, 0)
	var dist = player.global_position.distance_to(viewpoint)
	
	var look_dir = -camera.global_transform.basis.z
	var target_dir = (rotatable_room.global_position - camera.global_position).normalized()
	var dot = look_dir.dot(target_dir)
	
	# 部屋が90度回転している（x=90付近）かつ視点があっているか
	var is_rotated = abs(fmod(rotatable_room.rotation_degrees.x, 360.0) - 90.0) < 5.0
	perspective_solved = (dist < 1.0 and dot > 0.98 and is_rotated)
	
	# 全条件達成
	if $RotatableRoom/SwitchA.is_pressed and $SwitchB.is_pressed and perspective_solved:
		if door.has_method("unlock"):
			door.unlock()
