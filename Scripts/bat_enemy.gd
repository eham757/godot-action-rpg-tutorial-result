class_name Bat extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var hurt_box_area: Area2D = $HurtBoxArea

const SPEED = 125

@export var range: int = 64

func _ready() -> void:
	hurt_box_area.area_entered.connect(func(other_area_2d:Area2D):
		queue_free()
	)

func _physics_process(_delta: float) -> void:
	var state = playback.get_current_node()
	match state:
		"Idle":
			pass
			
		"Chase":
			var player = get_player()
			if player is Player:
				velocity = global_position.direction_to(player.global_position) * SPEED
				sprite_2d.scale.x = sign(velocity.x)
			move_and_slide()
	
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
