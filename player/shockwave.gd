extends Node2D

# Travelling shockwave projectile spawned by Swipe.
# Moves horizontally in the given direction, draws an expanding ring,
# has a HitArea Area2D child for damage detection, self-destructs after DURATION.

const DURATION  = 0.3
const SPEED     = 400.0   # px/s lateral travel
const MAX_RADIUS = 40.0   # visual ring radius at full expansion
const LINE_WIDTH = 2.0

var direction := 1        # set by swipe.gd after instantiation (+1 right, -1 left)
var elapsed   := 0.0

func _process(delta: float) -> void:
	elapsed += delta
	position.x += direction * SPEED * delta
	if elapsed >= DURATION:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var t      = elapsed / DURATION
	var radius = MAX_RADIUS * t
	var alpha  = 1.0 - t
	var color  = Color(0.85, 0.85, 1.0, alpha)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color, LINE_WIDTH)
