extends Control

@onready var buttons_container = $Content/Buttons
@onready var mute_button = $MuteButton
@onready var youtube_button = $YouTubeButton

func _ready() -> void:
	# 全体を透明にしてからフェードインさせる
	modulate.a = 0
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 1.5)
	
	# タイトルの初期位置を少し下から上にスライドさせるアニメーション
	$Content.position.y += 50
	var slide_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	slide_tween.tween_property($Content, "position:y", $Content.position.y - 50, 1.5)
	
	# マウスを表示
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# タイトルのBGMを再生
	GameManager.play_bgm("res://sound/タイトルBGM.mp3")
	_update_mute_button_text()
	
	# 全てのボタンにホバーアニメーションを適用
	for button in buttons_container.get_children():
		if button is Button:
			_setup_button_animations(button)
	
	_setup_button_animations(mute_button)
	_setup_button_animations(youtube_button)

func _setup_button_animations(button: Button) -> void:
	# ボタンのピボット（回転・拡大の中心）を中央に設定
	button.pivot_offset = button.size / 2
	
	# マウスが乗った時
	button.mouse_entered.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)
		button.modulate = Color(1.2, 1.2, 1.2) # 少し明るくする
	)
	
	# マウスが離れた時
	button.mouse_exited.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
		button.modulate = Color(1.0, 1.0, 1.0) # 元に戻す
	)

func _on_start_button_pressed() -> void:
	GameManager.goto_scene("res://Scenes/Rooms/Room1.tscn")

func _on_gasha_button_pressed() -> void:
	var gasha = load("res://Scenes/UI/GashaScreen.tscn").instantiate()
	add_child(gasha)

func _on_true_ending_button_pressed() -> void:
	OS.shell_open("https://www.youtube.com/watch?v=Dy_0fqqBvaQ")

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/SettingsMenu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_youtube_button_pressed() -> void:
	OS.shell_open("https://www.youtube.com/channel/UCWiqsd3o3VJwBq5QNm8G71A")

func _on_mute_button_pressed() -> void:
	GameManager.toggle_mute()
	_update_mute_button_text()

func _update_mute_button_text() -> void:
	var is_muted = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	if mute_button:
		mute_button.text = "AUDIO: OFF (MUTED)" if is_muted else "AUDIO: ON"
		var color = Color(1, 0.3, 0.3) if is_muted else Color(0.3, 0.7, 1)
		mute_button.add_theme_color_override("font_color", color)
