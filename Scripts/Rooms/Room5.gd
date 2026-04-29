extends Node3D

@onready var player = $Player
@onready var clone = $Clone
@onready var door = $Door

var recording = []
var is_recording = false
var is_playing = false
var record_timer = 0.0
var play_index = 0
const MAX_RECORD_TIME = 8.0 
const INTERVAL = 0.05 

func _ready() -> void:
	clone.hide()

func start_recording() -> void:
	recording.clear()
	is_recording = true
	is_playing = false
	clone.hide()
	record_timer = 0.0
	GameManager.add_log("記録開始... 8秒間自由に動いてください！")

func _physics_process(delta: float) -> void:
	if is_recording:
		record_timer += delta
		if record_timer >= INTERVAL:
			recording.append(player.global_transform)
			record_timer = 0.0
		
		if recording.size() >= MAX_RECORD_TIME / INTERVAL:
			is_recording = false
			GameManager.add_log("記録終了！再生を開始します。")
			start_playing()

	if is_playing:
		if play_index < recording.size():
			clone.global_transform = recording[play_index]
			play_index += 1
		else:
			play_index = 0 # ループ再生

func start_playing() -> void:
	is_playing = true
	play_index = 0
	clone.show()

func _process(_delta: float) -> void:
	if is_instance_valid(door) and $SwitchA.is_pressed and $SwitchB.is_pressed:
		if door.has_method("unlock"):
			door.unlock()
