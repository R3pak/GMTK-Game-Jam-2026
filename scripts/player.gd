extends CharacterBody2D

# MOVEMENT VARS
var speed: float = 250.0
var direction_x: float
var acc: float = 1.05
var decel: float = 30.0

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
	
	print(direction_x) 
	
	animation()
	get_input()
	move_and_slide()

func get_input():
	direction_x = Input.get_axis("left", "right")
	
	if Input.is_action_pressed("run") and direction_x != 0:
		run()
	else:
		speed = move_toward(speed, 250.0, decel)
	
	if Input.is_action_just_pressed("jump"):
		jump()
	
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.3

func jump():
	velocity.y = jump_velocity

func get_gravity_value() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func run():
	if speed <= 750.0:
		speed *= acc

func animation():
	if not is_on_floor():
		if velocity.y < 0.0:
			if $Sprite.animation != "jump":
				$Sprite.play("jump")
		else:
			if $Sprite.animation != "fall":
				$Sprite.play("fall")
	else:
		if direction_x:
			$Sprite.play("walk")
		else:
			$Sprite.play("idle")
	
	if direction_x != 0:
		$Sprite.flip_h = direction_x < 0
