extends CharacterBody2D
var speed: float = 70
var gravity = 15
@onready var player_node: CharacterBody2D = get_parent().get_node("player")
@export_range(-1, 1) var dir: int = 1
@export var damage: float = 3.0
var turning: bool = false

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	
	if dir == 0:
		dir = 1
	$AnimatedSprite2D.flip_h = false if dir == 1 else true
	$AnimatedSprite2D.play("spin")

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		var knockback_dir: float = sign(body.global_position.x - global_position.x)
		if knockback_dir == 0.0:
			knockback_dir = 1.0
		body.take_damage(damage, knockback_dir)

func _wait_dir_change(desired_dir: int):
	await get_tree().create_timer(0.5).timeout
	dir = desired_dir
	turning = false
	$AnimatedSprite2D.play("spin")

func _physics_process(delta: float) -> void:
	if not turning:
		if dir == 1 and (!$rightbuz.is_colliding() or $rightwalbuz.is_colliding()):
			$AnimatedSprite2D.flip_h = true
			turning = true
			dir = 0
			$AnimatedSprite2D.play("rotate")
			_wait_dir_change(-1)
		elif dir == -1 and (!$leftbuz.is_colliding() or $leftwalbuz.is_colliding()):
			$AnimatedSprite2D.flip_h = false
			turning = true
			dir = 0
			$AnimatedSprite2D.play("rotate")
			_wait_dir_change(1)
	
	velocity.x = lerp(velocity.x, dir * speed, 10.0 * delta)
	velocity.y += gravity
	move_and_slide()
