extends Node2D

func _ready() -> void:
	$AudioStreamPlayer2D.play()
	var player = get_tree().get_first_node_in_group("Player")  # NEW
	if player:
		player.get_node("HealthTimer").start(20.0)  # NEW: 20 "seconds" = 20 health
