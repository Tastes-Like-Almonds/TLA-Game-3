@abstract
extends Node
class_name WeaponVisual

var charge_prog : float = 0.0

## Update the internal charge progress. Might have visual effects depending on implementation.
func update_charge_prog(val : float):
	charge_prog = clamp(val, 0, 1)

## Update the weapon visual. Origin is the start position and the destination is where the focus of the weapon is.
## For players, the origin should be the center and destination the sword tip.
@abstract func update_visual(origin : Vector2, dest : Vector2)
