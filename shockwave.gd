extends Node2D

const DURATION = 0.3      # seconds until self-destruct
const MAX_RADIUS = 80.0   # matches SQUEEZE_RADIUS in player.gd
const LINE_WIDTH = 2.0

var elapsed := 0.0

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= DURATION:
		queue_free()
	queue_redraw()  # trigger _draw every frame

func _draw() -> void:
	var t = elapsed / DURATION           # 0.0 to 1.0
	var radius = MAX_RADIUS * t          # grows outward
	var alpha = 1.0 - t                  # fades out
	var color = Color(0.85, 0.85, 1.0, alpha)  # matches blob color
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color, LINE_WIDTH)
