extends CharacterBody2D

# --- Component references ---
@onready var squash_stretch: Node = $SquashStretch
@onready var squeeze: Node = $Squeeze

# --- Movement constants ---
const SPEED = 200.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 1200.0

# --- Variable declarations ---
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var was_on_floor := false
var is_dead := false
var last_safe_position: Vector2 = Vector2.ZERO

# --- Hug lock state ---
# When non-null, the player's movement is locked by another node (e.g. a Hugger).
# The locked branch in _physics_process gates input until the player breaks free.
var locked_by: Node = null


# Blob shape setup — called once at ready
func _ready() -> void:
	var blob = $PlayerModel
	squeeze.fired.connect(_on_squeeze_fired)
	Health.died.connect(_on_died)
	
	blob.polygon = PackedVector2Array([
		Vector2(0, -22),
		Vector2(10, -18),
		Vector2(18, -10),
		Vector2(21, 0),
		Vector2(18, 11),
		Vector2(10, 19),
		Vector2(0, 22),
		Vector2(-11, 19),
		Vector2(-19, 11),
		Vector2(-22, 0),
		Vector2(-19, -10),
		Vector2(-11, -18),
	])
	blob.color = Color(0.85, 0.85, 1.0)
	last_safe_position = global_position  # start position is always safe

func recover_from_fall() -> void:
	# Called by KillZone areas when the player falls into a pit.
	# Costs 1 HP, then teleports back to last known safe spot — but only
	# if still alive. If the damage kills, let the normal death loop handle it.
	Health.take_damage(1)
	if Health.current > 0:
		global_position = last_safe_position
		velocity = Vector2.ZERO

# --- Public API: called by Hugger (or any future grab-style enemy) ---

func lock_movement(by: Node) -> void:
	locked_by = by
	velocity = Vector2.ZERO


func unlock_movement() -> void:
	locked_by = null

func _on_squeeze_fired(_direction: String) -> void:
	if locked_by != null:
		locked_by.release_and_fade()
		unlock_movement()

func _on_died() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.6).timeout
	Health.heal_full()
	get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:

	if is_dead:
		return

	if Input.is_action_just_pressed("ui_cancel"):  # Esc by default
		get_tree().reload_current_scene()
		return
	
	# --- Locked branch: only gravity + Squeeze input processed ---
	# The player is held by something (Hugger). Gravity still applies so they
	# stay grounded; Squeeze input is allowed so the player can break free.
	# Squeeze firing writes velocity directly — that escape impulse breaks the lock.
	if locked_by != null:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		squeeze.update(delta)
		move_and_slide()
		was_on_floor = is_on_floor()
		return

	# --- Gravity ---
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# --- Coyote time ---
	if was_on_floor and not is_on_floor():
		coyote_timer = COYOTE_TIME
	if coyote_timer > 0:
		coyote_timer -= delta

	# --- Jump buffer ---
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# --- Jump logic ---
	var can_jump = is_on_floor() or coyote_timer > 0
	if jump_buffer_timer > 0 and can_jump:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		squash_stretch.on_jump()

	# --- Landing detection ---
	if not was_on_floor and is_on_floor():
		squash_stretch.on_land()

	# --- Squash & stretch (recovery + scale lerp) ---
	squash_stretch.update(delta, is_on_floor())

	# --- Squeeze (charge, release, directional fire) ---
	squeeze.update(delta)

	# --- Horizontal movement ---
	# Skip if squeeze just fired laterally — don't cancel the burst
	if not squeeze.fired_lateral_this_frame:
		var direction = Input.get_axis("ui_left", "ui_right")
		if squeeze.is_charging and is_on_floor():
			velocity.x = direction * SPEED * 0.35  # slow while coiling on floor
		else:
			velocity.x = direction * SPEED

	# --- Store floor state (must be BEFORE move_and_slide) ---
	was_on_floor = is_on_floor()

	move_and_slide()
	
	# Update last safe position whenever we're grounded and not mid-fall.
# This becomes the respawn point if we hit a KillZone next.
	if is_on_floor():
		last_safe_position = global_position
