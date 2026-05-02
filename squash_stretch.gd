extends Node
# Handles visual squash & stretch deformation of the blob.
# Listens for events (land, jump, squeeze) from player.gd and animates scale.
# The actual scale being animated is the parent CharacterBody2D's scale.

# --- Tuning ---
const NORMAL_SCALE  = Vector2(1.0, 1.0)
const SQUASH_SCALE  = Vector2(1.4, 0.6)   # wide and flat on landing
const STRETCH_SCALE = Vector2(0.7, 1.3)   # tall and thin on jump
const SQUEEZE_DOWN_SCALE = Vector2(1.5, 0.5)  # downward squeeze pose
const SQUEEZE_LATERAL_SCALE = Vector2(0.5, 1.5)  # lateral squeeze pose
const SQUASH_SPEED  = 15.0  # how fast scale snaps to target
const RECOVER_SPEED = 10.0  # how fast scale returns to normal

# --- State ---
var target_scale := NORMAL_SCALE

# Cached reference to the parent (the actual node we deform)
@onready var body: Node2D = get_parent()


# --- Public API: called by player.gd on events ---

func on_jump() -> void:
	target_scale = STRETCH_SCALE

func on_land() -> void:
	target_scale = SQUASH_SCALE

func on_squeeze_down() -> void:
	target_scale = SQUEEZE_DOWN_SCALE

func on_squeeze_lateral() -> void:
	target_scale = SQUEEZE_LATERAL_SCALE


# --- Per-frame update: called by player.gd ---

func update(delta: float, is_on_floor: bool) -> void:
	# Recover toward normal when squashed on ground or stretched in air
	if is_on_floor and target_scale == SQUASH_SCALE:
		target_scale = target_scale.lerp(NORMAL_SCALE, RECOVER_SPEED * delta)
		if target_scale.distance_to(NORMAL_SCALE) < 0.01:
			target_scale = NORMAL_SCALE
	elif not is_on_floor and target_scale == STRETCH_SCALE:
		target_scale = target_scale.lerp(NORMAL_SCALE, RECOVER_SPEED * delta)
		if target_scale.distance_to(NORMAL_SCALE) < 0.01:
			target_scale = NORMAL_SCALE

	# Smoothly animate parent's scale toward the target
	body.scale = body.scale.lerp(target_scale, SQUASH_SPEED * delta)
