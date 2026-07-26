extends CharacterBody2D

var lose_scene = preload("res://scenes/lose.tscn")

# MOVEMENT VARS
var speed: float = 250.0
var x_input: float
var velocity_weight: float
var acc: float = 5.2
var accfs: float = 1.05 #the reason there is 2 acc variables is the first one breaks the speed accel since its a much bigger number
var decel: float = 30.0
var friction: float = 4.5
var dashcd: bool = false
var dashing: bool = false
var absorbed: bool = false

# JUMP VARS
@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float
@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

# HEALTH VARS
var health: int
var stunned: bool = false
var knockback_force: float = 600.0
var knockback_up: float = 300.0

# DUST VARS
var dusty: bool
@onready var dustscene = preload("res://scenes/dust.tscn")

func _ready() -> void:
	$HealthTimer.start()
	$Sprite.animation_finished.connect(_on_sprite_animation_finished)

func _physics_process(delta: float) -> void:
	var is_running := Input.is_action_pressed("run")
	
	if not dashing:
		velocity.y += get_gravity_value() * delta
	x_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if not dashing and not stunned and not absorbed:  # CHANGED: added `and not absorbed`
		if x_input == 0:
			velocity.x = move_toward(velocity.x, 0.0, friction * speed * delta)
		elif is_running:
			velocity.x = lerp(velocity.x, x_input * speed, delta * acc)
		else:
			velocity.x = x_input * speed
	elif stunned or absorbed:  # CHANGED: also decay to stop when absorbed
		velocity.x = move_toward(velocity.x, 0.0, friction * speed * delta)
	
	if dusty:
		var instance = dustscene.instantiate()
		instance.global_position = $Marker2D.global_position
		get_parent().add_child(instance)
	
	health = int($HealthTimer.time_left)
	$Camera2D/Label.text = str(health)
	
	dust()
	animation()
	get_input()
	move_and_slide()

func get_input():
	if absorbed:
		return
	if Input.is_action_pressed("run") and x_input != 0:
		run()
	else:
		speed = move_toward(speed, 250.0, decel)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.3
	
	if Input.is_action_just_pressed("dash") and not dashcd:
		velocity.y = 0.0
		var dash_dir: float = -1.0 if $Sprite.flip_h else 1.0
		velocity.x = dash_dir * 1500
		dashcd = true
		dashing = true
		$Sprite.play("dash")
		$DashAudio.play()
		$DashCd.start()

func jump():
	velocity.y = jump_velocity

func get_gravity_value() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func run():
	if speed <= 750.0:
		speed *= accfs

func animation():
	if absorbed:
		if $Sprite.animation != "absorbed":
			$Sprite.play("absorbed")
		return
	if stunned:
		if $Sprite.animation != "hurt":
			$Sprite.play("hurt")
		return
	if dashing:
		return
	if not is_on_floor():
		if velocity.y < 0.0:
			if $Sprite.animation != "jump":
				$Sprite.play("jump")
		else:
			if $Sprite.animation != "fall":
				$Sprite.play("fall")
	else:
		if x_input:
			if Input.is_action_pressed("run"):
				if $Sprite.animation != "run":
					$Sprite.play("run")
			else:
				if $Sprite.animation != "walk":
					$Sprite.play("walk")
		else:
			if $Sprite.animation != "idle":
				$Sprite.play("idle")
	
	if x_input != 0:
		$Sprite.flip_h = x_input < 0

func _on_sprite_animation_finished() -> void:
	if $Sprite.animation == "dash":
		dashing = false

func _on_dash_cd_timeout() -> void:
	dashcd = false

func die():
	get_tree().change_scene_to_packed(lose_scene)

func _on_health_timer_timeout() -> void:
	die()

func dust():
	if x_input and $DustTimer.is_stopped() and is_on_floor() and not dashing:
		$DustTimer.start()
		spawn_dust()
		$StepAudio.pitch_scale = randf_range(0.75, 1.25)
		$StepAudio.volume_db = randf_range(1.0, 1.25)
		$StepAudio.play()
	elif not x_input:
		$DustTimer.stop()

func spawn_dust():
	var instance = dustscene.instantiate()
	instance.global_position = $Marker2D.global_position
	get_parent().add_child(instance)

func _on_dust_timer_timeout() -> void:
	if x_input:
		spawn_dust()
	else:
		$DustTimer.stop()

func timer_plus(amount:float):
	var add: float = $HealthTimer.time_left + amount
	$HealthTimer.start(add)

func take_damage(amount: float, knockback_dir: float) -> void:
	var remaining: float = $HealthTimer.time_left - amount
	$Camera2D.screen_shake(20, 0.2)
	if remaining <= 0.0:
		die()
		return
	$HealthTimer.start(remaining)
	
	$HurtAudio.play()
	dashing = false
	stunned = true
	velocity.x = knockback_dir * knockback_force
	velocity.y = -knockback_up
	$StunTimer.start()

func _on_stun_timer_timeout() -> void:
	stunned = false
