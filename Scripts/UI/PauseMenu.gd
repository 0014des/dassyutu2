extends CanvasLayer

@onready var mute_button = get_node_or_null("CenterContainer/Panel/Margin/VBox/MuteButton")
@onready var title_mute_button = get_node_or_null("MuteButton") # タイトル画面用

func _ready() -> void:
	# ポーズメニュー自体はポーズ中も動くようにする
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	_update_mute_button_text()
	_apply_animations_recursive($CenterContainer/Panel/Margin/VBox)

func _apply_animations_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			_setup_button_animations(child)
		elif child.get_child_count() > 0:
			_apply_animations_recursive(child)

func _setup_button_animations(button: Button) -> void:
	button.pivot_offset = button.size / 2
	button.mouse_entered.connect(func():
		var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.2)
		button.modulate = Color(1.2, 1.2, 1.2)
	)
	button.mouse_exited.connect(func():
		var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
		button.modulate = Color(1.0, 1.0, 1.0)
	)

func _on_resume_button_pressed() -> void:
	GameManager.toggle_pause()

func _on_title_button_pressed() -> void:
	get_tree().paused = false
	queue_free() # 自分を消してから遷移
	GameManager.goto_scene("res://Scenes/UI/TitleScreen.tscn")

func _on_settings_button_pressed() -> void:
	var settings = load("res://Scenes/UI/SettingsMenu.tscn").instantiate()
	add_child(settings)

func _on_credits_button_pressed() -> void:
	get_tree().paused = false
	queue_free() # 自分を消してから遷移
	GameManager.goto_scene("res://Scenes/UI/EndCredits.tscn")

func _on_mute_button_pressed() -> void:
	GameManager.toggle_mute()
	_update_mute_button_text()

func _update_mute_button_text() -> void:
	var is_muted = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	var btn = mute_button if mute_button else title_mute_button
	if btn:
		btn.text = "AUDIO: OFF (MUTED)" if is_muted else "AUDIO: ON"
		var color = Color(1, 0.3, 0.3) if is_muted else Color(0.3, 0.7, 1)
		btn.add_theme_color_override("font_color", color)

func _on_warp_button_pressed(room_number: int) -> void:
	GameManager.warp_to_stage(room_number)
	queue_free() # ワープ後にメニューを閉じる

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
