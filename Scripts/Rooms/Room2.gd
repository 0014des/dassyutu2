extends Node3D

@onready var player = $Player

func _ready() -> void:
	_update_loop_state()

func _process(delta: float) -> void:
	if not player:
		return
		
	if player.global_position.z > 20:
		if abs(GameManager.loop_count) >= 2:
			get_tree().change_scene_to_file("res://Scenes/Rooms/Room3.tscn")
		else:
			player.global_position.z -= 15
			GameManager.loop_count += 1
			_update_loop_state()
	elif player.global_position.z < 5:
		if abs(GameManager.loop_count) < 2:
			player.global_position.z += 15
			GameManager.loop_count -= 1
			_update_loop_state()

func _update_loop_state() -> void:
	var count = abs(GameManager.loop_count)
	if count == 0:
		if $Box: $Box.show()
		if $Memo: $Memo.hide()
	elif count == 1:
		if $Box: $Box.show()
		if $Memo: $Memo.show()
	elif count >= 2:
		if $Box: $Box.hide()
		if $Memo: $Memo.hide()
