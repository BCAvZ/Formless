extends Area2D

const IFRAMES = 0.6  # invulnerability after a hit

var invulnerable := false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if invulnerable:
		return
	if area.is_in_group("damage"):
		Health.take_damage(1)
		_start_iframes()

func _start_iframes() -> void:
	invulnerable = true
	# Optional: flash the blob — use modulate on PlayerModel
	await get_tree().create_timer(IFRAMES).timeout
	invulnerable = false
