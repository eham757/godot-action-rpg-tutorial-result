class_name Hurtbox extends Area2D

signal hurt(hitbox: Hitbox)

func _ready() -> void:
	area_entered.connect(_other_area_entered)
	
func _other_area_entered(area2d: Area2D) -> void:
	if area2d is not Hitbox: return
	var hitbox = area2d as Hitbox
	if self in hitbox.hit_targets: return
	if hitbox.stores_hit_target: hitbox.hit_targets.append(self)
	hurt.emit(hitbox)
