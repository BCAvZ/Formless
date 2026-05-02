# Formless

A vibe-coded metroidvania built in Godot 4 — my first ever game project.

The player controls a formless blob, a dream trying to become real. To exist, it must pass through four standalone emotional worlds — Joy, Anger, Sadness, Fear — each ending in a boss that embodies the emotion itself. Completing a world adds to the blob's form. The final form is the sum of all four.

## Status

**Sessions 1–5 complete.** World 01 (Joy) groundwork in place:
- Blob movement (gravity, jump with coyote time + jump buffer)
- Squash & stretch visual deformation
- Squeeze ability (charged shockwave, directional)
- Hugger enemy with lock-and-teach tutorial pattern
- AbilityManager autoload — ability state persists across scene reloads

**Session 5.5 — done.** File restructure into feature-grouped folders, project under version control.

**Session 6 — next.** Joy boss, death/respawn, Legs ability, blob's first visible transformation, title screen.

## Project structure

```
res://
├── player/         Player scene + components (movement, squeeze, squash_stretch, shockwave)
├── enemies/        Enemy scenes, one folder per enemy
│   └── hugger/
├── worlds/         World scenes
└── autoloads/      Global singletons (AbilityManager)
```

Files are grouped by feature, not by type. See `MetriodDreamiaArchitecture.html` for full architectural notes.

## Tech

- **Engine:** Godot 4 (GDScript)
- **Pattern:** Composition — Player is a tree of focused component nodes, `player.gd` is a thin coordinator
- **Persistence:** Autoloads for cross-scene state (ability unlocks, world progress)
- **Scene references:** `@export var: PackedScene` wired in editor — no hardcoded `preload()` paths

## Running locally

1. Clone the repo
2. Open Godot 4
3. Import the project (`project.godot` at the root)
4. F5 to run

## Notes

This is a learning project. The guiding principle is finish over perfect — one mechanic at a time, ship the demo ugly. Code is intentionally simple and well-commented for beginner readability.
