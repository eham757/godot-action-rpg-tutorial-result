class_name Hurtbox extends Area2D

signal hurt(hitbox: Hitbox)

func _ready() -> void:
	area_entered.connect(_other_area_entered)
	
func _other_area_entered(area2d: Area2D) -> void:
	if area2d is not Hitbox: return
	hurt.emit(area2d)
