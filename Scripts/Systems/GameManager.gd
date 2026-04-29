extends Node

var loop_count: int = 0
var flags: Dictionary = {
	"has_key": false,
	"door1_unlocked": false
}

func _ready() -> void:
	_setup_inputs()

func _setup_inputs() -> void:
	var inputs = {
		"move_forward": KEY_W,
		"move_backward": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"interact": KEY_E,
		"jump": KEY_SPACE
	}
	for action in inputs:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event = InputEventKey.new()
			event.physical_keycode = inputs[action]
			InputMap.action_add_event(action, event)

func add_log(message: String) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("show_log"):
		player.show_log(message)
