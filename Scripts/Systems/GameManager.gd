extends Node

var loop_count: int = 0
var flags: Dictionary = {
	"has_key": false,
	"door1_unlocked": false
}

@onready var bgm_player = AudioStreamPlayer.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_inputs()
	add_child(bgm_player)
	bgm_player.bus = "Master"

func _setup_inputs() -> void:
	var inputs = {
		"move_forward": KEY_W,
		"move_backward": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"interact": KEY_E,
		"jump": KEY_SPACE,
		"pause": KEY_0,
		"toggle_mouse": KEY_9
	}
	for action in inputs:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event = InputEventKey.new()
			event.physical_keycode = inputs[action]
			InputMap.action_add_event(action, event)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	var current_scene = get_tree().current_scene
	if current_scene.name == "TitleScreen" or current_scene.name == "EndCredits":
		return
		
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# ポーズメニューを表示（動的にロード）
		var pause_menu = load("res://Scenes/UI/PauseMenu.tscn").instantiate()
		add_child(pause_menu)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		# ポーズメニューを閉じる
		var menu = get_node_or_null("PauseMenu")
		if menu: menu.queue_free()

func play_bgm(stream_path: String, volume_linear: float = 1.0) -> void:
	if bgm_player.stream and bgm_player.stream.resource_path == stream_path:
		bgm_player.volume_db = linear_to_db(volume_linear)
		return
	var stream = load(stream_path)
	if stream:
		bgm_player.stream = stream
		bgm_player.volume_db = linear_to_db(volume_linear)
		bgm_player.play()

func stop_bgm() -> void:
	bgm_player.stop()

func toggle_mute() -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus, !AudioServer.is_bus_mute(master_bus))

func goto_scene(path: String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(path)

func warp_to_stage(n: int) -> void:
	var path = "res://Scenes/Rooms/Room%d.tscn" % n
	goto_scene(path)
	add_log("Stage %d にワープしました。" % n)

func add_log(message: String) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("show_log"):
		player.show_log(message)
