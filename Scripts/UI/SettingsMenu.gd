extends Control

@onready var action_list = $Panel/Content/Scroll/ActionList
@onready var waiting_overlay = $WaitingOverlay

var current_action = ""
var is_waiting_for_key = false

# 設定対象のアクション一覧
var configurable_actions = {
	"move_forward": "前進",
	"move_backward": "後退",
	"move_left": "左移動",
	"move_right": "右移動",
	"jump": "ジャンプ",
	"interact": "調べる",
	"pause": "ポーズ"
}

func _ready() -> void:
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	_setup_button_animations($Panel/Content/Buttons/SaveButton)
	_setup_button_animations($Panel/Content/Buttons/CancelButton)
	_refresh_list()

func _setup_button_animations(button: Button) -> void:
	button.pivot_offset = button.size / 2
	button.mouse_entered.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.2)
		button.modulate = Color(1.2, 1.2, 1.2)
	)
	button.mouse_exited.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
		button.modulate = Color(1.0, 1.0, 1.0)
	)

func _refresh_list() -> void:
	# リストをクリア
	for child in action_list.get_children():
		child.queue_free()
	
	for action in configurable_actions.keys():
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 20)
		
		var label = Label.new()
		label.text = configurable_actions[action]
		label.custom_minimum_size.x = 200
		label.add_theme_font_size_override("font_size", 22)
		hbox.add_child(label)
		
		var btn = Button.new()
		btn.text = _get_action_key_text(action)
		btn.custom_minimum_size = Vector2(200, 45)
		btn.add_theme_font_size_override("font_size", 20)
		btn.pressed.connect(_on_action_button_pressed.bind(action))
		_setup_button_animations(btn) # アニメーション適用
		hbox.add_child(btn)
		
		action_list.add_child(hbox)

func _get_action_key_text(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		return events[0].as_text().replace(" (Physical)", "")
	return "None"

func _on_action_button_pressed(action: String) -> void:
	current_action = action
	is_waiting_for_key = true
	waiting_overlay.show()

func _input(event: InputEvent) -> void:
	if is_waiting_for_key and event is InputEventKey and event.is_pressed():
		_remap_action(current_action, event)
		is_waiting_for_key = false
		waiting_overlay.hide()
		_refresh_list()
		get_viewport().set_input_as_handled()

func _remap_action(action: String, event: InputEventKey) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)

func _on_save_button_pressed() -> void:
	# 本来はここでConfigファイルへの保存処理を行う
	# 今回はメモリ上のInputMap変更のみ反映して戻る
	_close()

func _on_cancel_button_pressed() -> void:
	# 変更を保存せずに戻る（簡易化のため今回は即戻る）
	_close()

func _close() -> void:
	# タイトル画面に戻るか、ポーズメニューからなら削除
	if get_parent() == get_tree().root:
		get_tree().change_scene_to_file("res://Scenes/UI/TitleScreen.tscn")
	else:
		queue_free()
