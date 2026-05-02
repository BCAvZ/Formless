# ability_manager.gd
# Autoload singleton — registered in Project Settings → AutoLoad as "AbilityManager".
# Single source of truth for which abilities the blob has unlocked.
# Components ask: AbilityManager.has("squeeze") before firing.
# Pickups/encounters call: AbilityManager.unlock("squeeze") to grant.
extends Node

# Emitted whenever a new ability is unlocked.
# Useful for UI, sound cues, or "ability gained" popups later.
signal ability_unlocked(ability_name: String)

# Set of currently unlocked abilities.
# Using a Dictionary as a set — values are always true, keys are what matter.
var _unlocked: Dictionary = {}


func has(ability_name: String) -> bool:
	return _unlocked.has(ability_name)


func unlock(ability_name: String) -> void:
	# Idempotent — unlocking twice is a no-op, no signal re-fire.
	if _unlocked.has(ability_name):
		return
	_unlocked[ability_name] = true
	print("ABILITY UNLOCKED: ", ability_name)
	ability_unlocked.emit(ability_name)


func reset() -> void:
	# For new-game / debug. Wipes all unlocks.
	_unlocked.clear()
