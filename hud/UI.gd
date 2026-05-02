# hud.gd
# Three-pip health display, top-left of screen.
# Listens to Health.health_changed and updates pip visibility to match.
# CanvasLayer parent means it ignores camera movement and draws above world content.
extends CanvasLayer

# Active and inactive pip alphas — tune for visual taste.
const PIP_ACTIVE_ALPHA = 1.0
const PIP_INACTIVE_ALPHA = 0.2

@onready var pips: Array = [
	$Pips/Pip1,
	$Pips/Pip2,
	$Pips/Pip3,
]


func _ready() -> void:
	Health.health_changed.connect(_on_health_changed)
	# Seed initial state — Health may already have a value before HUD spawned.
	_on_health_changed(Health.current, Health.MAX_HP)


func _on_health_changed(current: int, _max_hp: int) -> void:
	for i in range(pips.size()):
		pips[i].modulate.a = PIP_ACTIVE_ALPHA if i < current else PIP_INACTIVE_ALPHA
