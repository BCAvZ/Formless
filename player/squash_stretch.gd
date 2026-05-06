extends Node
# Handles visual squash & stretch deformation of the blob.
# Listens for events (land, jump, swipe) from player.gd and animates scale.
# The actual scale being animated is the parent CharacterBody2D's scale.

# --- Tuning ---
const NORMAL_SCALE  = Vector2(1.0, 1.0)
const SQUASH_SCALE  = Vector2(1.4, 0.6)   # wide and flat on landing
const STRETCH_SCALE = Vector2(0.7, 1.3)   # tall and thin on jump
const SWIPE_DOWN_SCALE = Vector2(1.5, 0.5)  # downward swipe pose
const SWIPE_LATERAL_SCALE = Vector2(0.5, 1.5)  # lateral swipe pose
const SQUASH_SPEED  = 15.0  # how fast scale snaps to target
const RECOVER_SPEED = 10.0  # how fast scale returns to normal
const SWIPE_RECOVER_TIME = 0.15

# --- State ---
var target_scale := NORMAL_SCALE
var _swipe_timer := 0.0

# Cached reference to the parent (the actual node we deform)
@onready var body: Node2D = get_parent()


# --- Public API: called by player.gd on events ---

func on_jump() -> void:
	target_scale = STRETCH_SCALE

func on_land() -> void:
	target_scale = SQUASH_SCALE

func on_swipe_down() -> void:
	target_scale = SWIPE_DOWN_SCALE

func on_swipe_lateral() -> void:
	target_scale = SWIPE_LATERAL_SCALE

func on_swipe() -> void:
	target_scale = SWIPE_LATERAL_SCALE
	_swipe_timer = SWIPE_RECOVER_TIME

# --- Per-frame update: called by player.gd ---

func update(delta: float, is_on_floor: bool) -> void:
	if _swipe_timer > 0:
		_swipe_timer -= delta
		if _swipe_timer <= 0:
			target_scale = NORMAL_SCALE
	
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
