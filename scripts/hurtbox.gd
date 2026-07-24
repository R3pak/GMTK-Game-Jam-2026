extends Area2D

@export var damage: float = 3.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		var knockback_dir: float = sign(body.global_position.x - global_position.x)
		if knockback_dir == 0.0:
			knockback_dir = 1.0
		body.take_damage(damage, knockback_dir)
