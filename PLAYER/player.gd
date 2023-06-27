extends CharacterBody2D


@export var speed : float = 200.0
@export var jump_velocity : float = -250.0
@export var double_jump_velocity : float = -150.0

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer : Timer = $AttackTimer
@onready var attack_area_1 : Area2D = $Attack1Area
@onready var attack_area_2 : Area2D = $Attack2Area
@onready var attack_area_3 : Area2D = $Attack3Area

var has_double_jump : bool = false
var animation_lock : bool = false
var movement_lock : bool = false
var direction : Vector2 = Vector2.ZERO
var attack_part : int = 0
var i : int = 0;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		
		has_double_jump = false

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") && not movement_lock:
		if is_on_floor():
			velocity.y = jump_velocity
		elif not has_double_jump:
			velocity.y += double_jump_velocity
			has_double_jump = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	direction = Input.get_vector("ui_left", "ui_right", "ui_accept", "ui_down")
	if not movement_lock:
		if direction:
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()
	update_animation()
	update_dir()
	jump()
	attack()



func update_animation():
	if not animation_lock:
		if direction.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

func update_dir():
	if direction.x > 0:
		animated_sprite.flip_h = false
		attack_area_1.scale.x = 1
		attack_area_2.scale.x = 1
		attack_area_3.scale.x = 1
	elif direction.x < 0:
		animated_sprite.flip_h = true
		attack_area_1.scale.x = -1
		attack_area_2.scale.x = -1
		attack_area_3.scale.x = -1

func jump():
	if velocity.y < 0: 
		animated_sprite.play("jump")
		animation_lock = true
	elif velocity.y > 0:
		animated_sprite.play("fall")
		animation_lock = false

func attack():
	if Input.is_action_just_pressed("Attack"):
		if is_on_floor():
			if attack_part == 0:
				velocity.x = 0
				animation_lock = true
				animated_sprite.play("attack1")
				$Attack1Area/CollisionShape2D.disabled = false
				movement_lock = true
				reset_attack_timer()
			if attack_part == 1:
				velocity.x = 0
				animation_lock = true
				animated_sprite.play("attack2")
				$Attack2Area/CollisionShape2D.disabled = false
				movement_lock = true
				reset_attack_timer()
			if attack_part == 2:
				velocity.x = 0
				animation_lock = true
				animated_sprite.play("attack3")
				$Attack3Area/CollisionShape2D.disabled = false
				movement_lock = true
				reset_attack_timer()

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack1":
		animation_lock = false
		movement_lock = false
		$Attack1Area/CollisionShape2D.disabled = true
		attack_part = 1
	if animated_sprite.animation == "attack2":
		animation_lock = false
		movement_lock = false
		$Attack2Area/CollisionShape2D.disabled = true
		attack_part = 2
	if animated_sprite.animation == "attack3":
		animation_lock = false
		movement_lock = false
		$Attack3Area/CollisionShape2D.disabled = true
		attack_part = 0

func reset_attack_timer():
	attack_timer.stop()
	attack_timer.start()

func _on_attack_timer_timeout():
	attack_part = 0


func _on_attack_1_area_body_entered(body):
	if body.is_in_group("ENEMY"):
		body.on_enemy_hit() # Replace with function body.


func _on_attack_2_area_body_entered(body):
	if body.is_in_group("ENEMY"):
		body.on_enemy_hit() # Replace with function body.


func _on_attack_3_area_body_entered(body):
	if body.is_in_group("ENEMY"):
		body.on_enemy_hit() # Replace with function body.
