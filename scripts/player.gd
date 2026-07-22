extends CharacterBody2D

# MOVEMENT VARS
var speed := 250.0
var direction_x: float

# JUMP VARS
@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float
@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _physics_process(delta: float) -> void:
	
	velocity.y += get_gravity_value() * delta
	velocity.x = direction_x * speed
	
	animation()
	get_input()
	move_and_slide()

func get_input():
	direction_x = Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("jump"):
		jump()

func jump():
	velocity.y = jump_velocity

func get_gravity_value() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func animation():
	if not is_on_floor():
		if $Sprite.animation != "jump":
			$Sprite.play("jump")
	else:
		if direction_x:
			$Sprite.play("walk")
		else:
			$Sprite.play("idle")
	
	if direction_x != 0:
		$Sprite.flip_h = direction_x < 0
