extends Node

const HOP_FORCE    = 380.0
const COYOTE_TIME  = 0.1
const BUFFER_TIME  = 0.1

@export var body: CharacterBody2D
@export var squash_stretch: Node

signal fired

var coyote_timer  := 0.0
var buffer_timer  := 0.0
var was_on_floor  := false


func update(delta: float) -> void:
	if AbilityManager.has("legs"):
		return
	# Coyote time
	if was_on_floor and not body.is_on_floor():
		coyote_timer = COYOTE_TIME
	if coyote_timer > 0:
		coyote_timer -= delta

	# Jump buffer
	if Input.is_action_just_pressed("hop"):
		buffer_timer = BUFFER_TIME
	if buffer_timer > 0:
		buffer_timer -= delta

	# Hop
	var can_hop = body.is_on_floor() or coyote_timer > 0
	if buffer_timer > 0 and can_hop:
		body.velocity.y = -HOP_FORCE
		buffer_timer  = 0.0
		coyote_timer  = 0.0
		squash_stretch.on_jump()
		emit_signal("fired")

	was_on_floor = body.is_on_floor()
