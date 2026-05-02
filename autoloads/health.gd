# health.gd — autoload as "Health"
extends Node

signal health_changed(current: int, max: int)
signal died

const MAX_HP = 3

var current: int = MAX_HP

func take_damage(amount: int) -> void:
	if current <= 0:
		return  # already dead, ignore
	current = max(0, current - amount)
	health_changed.emit(current, MAX_HP)
	if current == 0:
		died.emit()

func heal_full() -> void:
	current = MAX_HP
	health_changed.emit(current, MAX_HP)
