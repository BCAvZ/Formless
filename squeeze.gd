extends Node
# Handles the Squeeze ability: charge on hold, fire on release.
# Direction is set by left/right input at the moment of release.
# No input = downward floor bounce. Left/right = lateral burst.
#
# Talks to player.gd by:
#   - reading is_on_floor() from the parent
#   - returning a velocity override (or null) from try_fire()
#   - notifying squash_stretch directly for visual response

const Shockwave = preload("res://shockwave.tscn")

# --- Tuning ---
const MAX_CHARGE = 0.5         # max charge time in seconds
const MIN_FORCE  = -200.0      # short press force
const MAX_FORCE  = -600.0      # full charge force
const RADIUS     = 80.0        # shockwave visual radius (for later)
const LATERAL_LIFT = 0.5       # fraction of force applied as upward lift in lateral fire

# --- State ---
var charge := 0.0
var is_charging := false
var fired_lateral_this_frame := false  # true for one frame after lateral fire
signal fired(direction: String)  # "down" or "lateral"

# --- Component refs ---
@onready var body: CharacterBody2D = get_parent()
@onready var squash_stretch: Node = get_parent().get_node("SquashStretch")


# --- Public API ---

func update(delta: float) -> void:
    # Reset per-frame flag at the start of every physics step.
    fired_lateral_this_frame = false
    
    # Gated by AbilityManager — silently ignore input until unlocked.
    if not AbilityManager.has("squeeze"):
        return
    
    # Start charging on press
    if Input.is_action_just_pressed("ui_select"):
        is_charging = true

    # Accumulate charge while held
    if is_charging:
        charge = min(charge + delta, MAX_CHARGE)

    # Fire on release
    if Input.is_action_just_released("ui_select") and is_charging:
        _fire()


# --- Internal ---

func _fire() -> void:
    is_charging = false

    if not body.is_on_floor():
        print("SQUEEZE RELEASED — not on floor, ignoring")
        charge = 0.0
        return

    var t = charge / MAX_CHARGE
    var force = lerp(MIN_FORCE, MAX_FORCE, t)
    var dir = Input.get_axis("ui_left", "ui_right")
    
    if dir == 0:
        # No input — fire downward
        body.velocity.y = force
        squash_stretch.on_squeeze_down()
    else:
        # Left or right held — fire laterally
        body.velocity.x = -force * dir
        body.velocity.y = -abs(force) * LATERAL_LIFT
        squash_stretch.on_squeeze_lateral()
        fired_lateral_this_frame = true
    
    if dir == 0:
        body.velocity.y = force
        squash_stretch.on_squeeze_down()
        fired.emit("down")
    else:
        body.velocity.x = -force * dir
        body.velocity.y = -abs(force) * LATERAL_LIFT
        squash_stretch.on_squeeze_lateral()
        fired_lateral_this_frame = true
        fired.emit("lateral")
    
    # Spawn shockwave visual at blob position
    var sw = Shockwave.instantiate()
    body.get_tree().current_scene.add_child(sw)
    sw.global_position = body.global_position

    print("velocity after: ", body.velocity)
    charge = 0.0
