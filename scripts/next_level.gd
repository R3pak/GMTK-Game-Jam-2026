extends Area2D

const file_begin = "res://scenes/levels/level_"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.absorbed = true  # CHANGED: was body.speed = 0
		body.velocity = Vector2.ZERO  # NEW: kill any existing momentum instantly
		var current_scene_file = get_tree().current_scene.scene_file_path
		var next_level_number = current_scene_file.to_int() + 1
		var next_level_path = file_begin + str(next_level_number) + ".tscn"
		
		$AudioStreamPlayer2D.play()
		await $AudioStreamPlayer2D.finished
		get_tree().change_scene_to_file.call_deferred(next_level_path)
