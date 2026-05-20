extends CharacterBody2D

# --- Component references ---
@onready var squash_stretch: Node = $SquashStretch
@onready var swipe: Node = $Swipe
@onready var blob = $PlayerModel
@onready var hop: Node = $Hop

# --- Movement constants ---
const SPEED = 200.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 1200.0

# --- Variable declarations ---
var was_on_floor := false
var is_dead := false
var last_safe_position: Vector2 = Vector2.ZERO
var facing := 1  # +1 right, -1 left

# --- Hug lock state ---
# When non-null, the player's movement is locked by another node (e.g. a Hugger).
# The locked branch in _physics_process gates input until the player breaks free.
var locked_by: Node = null


func _ready() -> void:
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
	last_safe_position = global_position
	swipe.fired.connect(_on_swipe_fired)
	Health.died.connect(_on_died)
	hop.fired.connect(_on_hop_fired)


func _on_swipe_fired() -> void:
	if locked_by != null:
		locked_by.release_and_fade()
		unlock_movement()

func _on_hop_fired() -> void:
	if locked_by != null:
		locked_by.release_and_fade()
		unlock_movement()

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
	hop.was_on_floor = false  # reset so hop re-syncs next frame


func _on_died() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.6).timeout
	Health.heal_full()
	get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:

	if is_dead:
		return

	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()
		return

	# --- Locked branch: only gravity + Swipe input processed ---
	# The player is held by something (Hugger). Gravity still applies so they
	# stay grounded; Swipe input is allowed so the player can break free.
	if locked_by != null:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		swipe.update(delta)
		hop.update(delta)
		move_and_slide()
		was_on_floor = is_on_floor()
		return

	# --- Gravity ---
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# --- Landing detection ---
	if not was_on_floor and is_on_floor():
		squash_stretch.on_land()

	# --- Squash & stretch (recovery + scale lerp) ---
	squash_stretch.update(delta, is_on_floor())

	# --- Swipe ---
	swipe.update(delta)
	
	# --- Hop ---
	hop.update(delta)

	# --- Horizontal movement ---
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		facing = int(sign(direction))
	velocity.x = direction * SPEED

	# --- Store floor state (must be BEFORE move_and_slide) ---
	was_on_floor = is_on_floor()

	move_and_slide()

	# Update last safe position whenever we're grounded.
	if is_on_floor():
		last_safe_position = global_position
