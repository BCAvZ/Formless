# hugger.gd
# The Hugger — a sad creature in Joy that wants only to hug the blob.
# Tutorial enemy: walks toward player, locks them on contact, prompts
# the player to Squeeze free. Squeezing teaches Squeeze (unlocks ability).
extends CharacterBody2D

enum State { IDLE, APPROACHING, HUGGING, FADING }

# --- Tuning ---
const APPROACH_SPEED = 60.0
const DETECTION_RANGE = 250.0
const GRAVITY = 1200.0
const FADE_DURATION = 1.5

# --- State ---
var state: State = State.IDLE
var fade_timer := 0.0
var hugged_player: CharacterBody2D = null

# --- Refs ---
@onready var hug_area: Area2D = $HugArea
@onready var sprite: Polygon2D = $HuggerModel

# Set in editor or via export — drag the player in, or find at runtime.
var player: CharacterBody2D = null


func _ready() -> void:
	# One-shot tutorial guard — once Squeeze is learned, the Hugger is obsolete.
	# On every scene reload (death/respawn), re-hugging would be unbearable.
	if AbilityManager.has("swipe"):
		queue_free()
		return
	
	# Find player in scene (assumes one player named "Player" in current scene).
	player = get_tree().get_first_node_in_group("player")
	hug_area.body_entered.connect(_on_hug_area_entered)


func _physics_process(delta: float) -> void:
	# Gravity always — hugger is grounded.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	match state:
		State.IDLE:
			velocity.x = 0
			if player and global_position.distance_to(player.global_position) < DETECTION_RANGE:
				state = State.APPROACHING

		State.APPROACHING:
			if player:
				var dir = sign(player.global_position.x - global_position.x)
				velocity.x = dir * APPROACH_SPEED

		State.HUGGING:
			velocity.x = 0
			# Player is locked — handled by player-side check (see 3c).
			# Hugger waits here until told to fade.

		State.FADING:
			velocity.x = 0
			fade_timer += delta
			sprite.modulate.a = 1.0 - (fade_timer / FADE_DURATION)
			if fade_timer >= FADE_DURATION:
				queue_free()

	move_and_slide()


func _on_hug_area_entered(body: Node2D) -> void:
	if body == player and state == State.APPROACHING:
		state = State.HUGGING
		hugged_player = body
		body.lock_movement(self)  # see 3c
		AbilityManager.unlock("swipe")


# Called by player when they successfully swipe free.
func release_and_fade() -> void:
	if state != State.HUGGING:
		return
	state = State.FADING
	hugged_player = null
