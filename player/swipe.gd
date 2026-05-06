extends Node

# Sideways attack ability. Replaces squeeze.gd.
# Press X for an uncharged horizontal shockwave in the blob's facing direction.
# Gated by AbilityManager.has("swipe") — silently no-ops until unlocked.

# --- Tuning ---
const SWIPE_RECOIL := 120.0  # px/s lateral bump on hit — tune to feel

# --- Refs (wired in editor) ---
@export var body: CharacterBody2D
@export var squash_stretch: Node
@export var shockwave_scene: PackedScene

# --- Signals ---
signal fired

# --- State ---
var _recoil_applied := false  # one recoil per swipe lifetime


func update(_delta: float) -> void:
	if not AbilityManager.has("swipe"):
		return
	if Input.is_action_just_pressed("swipe"):
		_fire()


func _fire() -> void:
	_recoil_applied = false

	var direction: int = body.facing

	var shockwave = shockwave_scene.instantiate()
	get_tree().current_scene.add_child(shockwave)
	shockwave.global_position = body.global_position
	shockwave.direction = direction

	# Listen for the first HitArea hit to apply recoil.
	# shockwave.tscn needs an Area2D child named HitArea in the player_attack group.
	var hit_area = shockwave.get_node_or_null("HitArea")
	if hit_area:
		hit_area.area_entered.connect(_on_shockwave_hit.bind(direction), CONNECT_ONE_SHOT)

	squash_stretch.on_swipe()
	emit_signal("fired")


func _on_shockwave_hit(_area: Area2D, direction: int) -> void:
	if _recoil_applied:
		return
	_recoil_applied = true
	body.velocity.x = -direction * SWIPE_RECOIL
