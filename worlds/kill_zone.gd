# kill_zone.gd
# An Area2D that catches falling players and triggers fall damage + recovery.
# Place this far below valid play space, or inside specific pits.
extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.recover_from_fall()
