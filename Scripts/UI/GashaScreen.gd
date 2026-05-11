extends CanvasLayer

@onready var image_display = $ImageDisplay
@onready var smoke_screen = $SmokeScreen
@onready var description_label = $DescriptionLabel
@onready var buttons_container = $Buttons
@onready var audio_player1 = $AudioPlayer1
@onready var audio_player2 = $AudioPlayer2

var current_step = 1

var descriptions = {
	"ガシャ3 error.png": "error",
	"R.png": "【レア】不思議な模様の石を手に入れた。",
}

func _ready() -> void:
	GameManager.stop_bgm()
	# ボタンのアニメーション設定
	_setup_button_animations($Buttons/RetryButton)
	_setup_button_animations($Buttons/DoneButton)
	_start_gasha()

func _setup_button_animations(button: Button) -> void:
	button.pivot_offset = button.size / 2
	button.mouse_entered.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)
		button.modulate = Color(1.2, 1.2, 1.2)
	)
	button.mouse_exited.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
		button.modulate = Color(1.0, 1.0, 1.0)
	)

func _start_gasha() -> void:
	current_step = 1
	description_label.hide()
	buttons_container.hide()
	smoke_screen.modulate.a = 0
	_play_step(1)

func _play_step(step: int) -> void:
	current_step = step
	
	if step == 3:
		_show_smoke_effect()
	else:
		_apply_step_content(step)

func _show_smoke_effect() -> void:
	var tween = create_tween()
	tween.tween_property(smoke_screen, "modulate:a", 1.0, 0.3)
	tween.tween_callback(func(): _apply_step_content(3))
	tween.tween_property(smoke_screen, "modulate:a", 0.0, 1.0).set_delay(0.2)

func _apply_step_content(step: int) -> void:
	var filename = ""
	if step == 1: filename = "ガシャ1.jpg"
	elif step == 2: filename = "ガシャ2.jpg"
	elif step == 3: filename = "ガシャ3 error.png"
	
	var img_path = "res://picture/" + filename
	
	# 画像ファイルの存在確認
	if ResourceLoader.exists(img_path):
		image_display.texture = load(img_path)
	else:
		# ファイルがない場合はエラー表示
		image_display.texture = null
		if step == 3:
			description_label.text = "error: " + filename + " が見つかりません"
			description_label.show()
	
	# 音声ファイルの存在確認と再生
	var snd_path = "res://sound/ガシャ%d.mp3" % step
	var player = audio_player1 if step % 2 != 0 else audio_player2
	
	if ResourceLoader.exists(snd_path):
		var stream = load(snd_path)
		player.stream = stream
		player.play()
		
		# ガシャ2の時のみタイマー起動
		if step == 2:
			var wait_time = stream.get_length() - 3.0
			if wait_time > 0:
				get_tree().create_timer(wait_time).timeout.connect(func(): if current_step == 2: _play_step(3))
			else:
				_play_step(3)
	else:
		# 音声がない場合は少し待って次へ
		get_tree().create_timer(1.0).timeout.connect(func(): _on_audio_player_finished())

	# 説明文の設定（画像がある場合の上書き）
	if step == 3 and ResourceLoader.exists(img_path):
		if descriptions.has(filename):
			description_label.text = descriptions[filename]
		else:
			description_label.text = "アイテムを獲得しました！"
		description_label.show()

func _on_audio_player_finished() -> void:
	if current_step == 1:
		_play_step(2)
	elif current_step == 3:
		buttons_container.show()

func _on_retry_button_pressed() -> void:
	audio_player1.stop()
	audio_player2.stop()
	_start_gasha()

func _on_done_button_pressed() -> void:
	GameManager.play_bgm("res://sound/タイトルBGM.mp3")
	queue_free()
