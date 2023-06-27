extends CharacterBody2D

@export var health : int = 3

var hit : bool = false
var dead : bool = false
var has_died : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta
	if not has_died:
		if dead:
			print(health)
			$AnimatedSprite2D.play("dead")
			has_died = true
		if hit:
			$AnimatedSprite2D.play("hit")
		if not hit && not dead:
			$AnimatedSprite2D.play("idle")
	
	move_and_slide()
	update_dir()
	
func update_dir():
	var player = get_parent().get_node("Player")
	if player and player.global_position.x < global_position.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
		
func on_enemy_hit():
	health = health - 1
	hit = true
	if health <= 0:
		hit = false
		dead = true


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "hit":
		hit = false
	if $AnimatedSprite2D.animation == "dead":
		dead = false
