class_name Bat extends CharacterBody2D



const SPEED = 90
const FRICTION = 500

@export var range: int = 64
@export var stats: Stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var hurt_box_area: Area2D = $HurtBoxArea

func _ready() -> void:
	stats = stats.duplicate()
	hurt_box_area.hurt.connect(take_hit.call_deferred)
	stats.no_health.connect(queue_free)

func _physics_process(delta: float) -> void:
	var state = playback.get_current_node()
	match state:
		"IdleState":
			pass
			
		"ChaseState":
			var player = get_player()
			if player is Player:
				velocity = global_position.direction_to(player.global_position) * SPEED
				sprite_2d.scale.x = sign(velocity.x)
			move_and_slide()
		"HitState":
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			move_and_slide()

func take_hit(hitting_hitbox: Hitbox) -> void:
		velocity = hitting_hitbox.knockback_direction * hitting_hitbox.knockback_amount
		playback.start("HitState")
		stats.health -= hitting_hitbox.damage
	
func get_player() -> Player:
	return get_tree().get_first_node_in_group("player")

func is_player_in_range() -> bool:
	var result = false
	var player = get_player()
	if player is Player:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player < range:
			result = true
	return result

func can_see_player() -> bool:
	if not is_player_in_range(): return false
	var player = get_player()
	ray_cast_2d.target_position = player.global_position - global_position
	var can_see_player_unobstructed = not ray_cast_2d.is_colliding()
	return can_see_player_unobstructed
