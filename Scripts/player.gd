class_name Player extends CharacterBody2D

const SPEED:float = 120.0
const ROLL_SPEED:float = 150.0

var input_vector:= Vector2.ZERO
var last_input_vector:= Vector2.DOWN

@export var stats: Stats

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var sword_hitbox_area: Hitbox = $SwordHitboxArea
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer

func _ready() -> void:
	hurtbox.hurt.connect(take_hit.call_deferred)
	stats.no_health.connect(die)
	pass

func _physics_process(_delta: float) -> void:
	var state = playback.get_current_node()
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	sword_hitbox_area.knockback_direction = last_input_vector.normalized() #Tutorial used animation for this, i chose to keep it like this
	
	if Input.is_action_pressed("attack"):
		playback.travel("AttackState")

	if Input.is_action_pressed("roll"):
		playback.travel("RollState")
	
	match state:
		"MoveState":
			move_state(_delta)

		"AttackState":
			pass
		
		"RollState":
			roll_state(_delta)

func move_state(_delta: float) -> void:
	if input_vector != Vector2.ZERO:
		var direction_vector = Vector2(input_vector.x, -input_vector.y)
		update_blend_positions(direction_vector)
		last_input_vector = input_vector
		velocity = input_vector * SPEED
		move_and_slide()

func roll_state(_delta: float) -> void:
	velocity = last_input_vector.normalized() * ROLL_SPEED
	move_and_slide()

func take_hit(hitting_hitbox:Hitbox) -> void:
	stats.health -= hitting_hitbox.damage
	effect_animation_player.play("blink")
	
func die() -> void:
	hide()
	remove_from_group("player")
	process_mode = Node.PROCESS_MODE_DISABLED
	

func update_blend_positions(direction_vector: Vector2) -> void:
	animation_tree.set("parameters/StateMachine/MoveState/RunState/blend_position", direction_vector)
	animation_tree.set("parameters/StateMachine/MoveState/StandState/blend_position", direction_vector)
	animation_tree.set("parameters/StateMachine/AttackState/blend_position", direction_vector)
	animation_tree.set("parameters/StateMachine/RollState/blend_position", direction_vector)
