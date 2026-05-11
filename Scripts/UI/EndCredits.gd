extends Control

@onready var credits_container = $CreditsContainer
@onready var final_display = $CreditsContainer/FinalDisplay

func _ready() -> void:
	# クリア後はマウスを表示させる
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# エンディングのBGMを再生
	GameManager.play_bgm("res://sound/エンドロール.mp3")
	
	# ビューポートのサイズに合わせてコンテナの幅を調整
	var viewport_size = get_viewport_rect().size
	credits_container.size.x = viewport_size.x
	
	# 初期位置：画面内からスタートさせる（すぐに見えるように）
	credits_container.position.y = viewport_size.y * 0.6
	
	await get_tree().process_frame
	
	# アニメーション設定
	var tween = create_tween()
	
	# 最終地点の計算：
	var final_display_height = final_display.get_combined_minimum_size().y
	var target_y = (viewport_size.y / 2.0) - final_display.position.y - (final_display_height / 2.0)
	
	# 元の速度を維持するための時間計算
	var speed = (viewport_size.y - target_y) / 30.0
	var distance = credits_container.position.y - target_y
	var duration = distance / speed
	
	tween.tween_property(credits_container, "position:y", target_y, duration)

func _input(event: InputEvent) -> void:
	# Pキーでのスキップも残しておく
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_P:
			_on_skip_button_pressed()

func _on_skip_button_pressed() -> void:
	GameManager.goto_scene("res://Scenes/UI/TitleScreen.tscn")

func _on_clear_button_pressed() -> void:
	# クリア達成！タイトルに戻る
	GameManager.goto_scene("res://Scenes/UI/TitleScreen.tscn")
