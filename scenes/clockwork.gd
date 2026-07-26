extends Area2D

func _ready() -> void:
	$AnimationPlayer.play("hover")


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("timer_plus"):
		body.timer_plus(2.0)
		queue_free()
