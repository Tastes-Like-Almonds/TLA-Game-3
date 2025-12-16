## Attendance
---

```attendance
date: 2025-09-16
title: Game Development Club
query: #members
- [[Aidan Wignall]], "Present", ""
- [[Mizuki Wong]], "Present", ""
- [[Anton Nemkov]], "Present", ""
- [[Zachary Cluff]], "Present", ""
- [[Evan Gould]], "Present", ""
```

## Topics to Cover
___
- Huge art inconsistencies
	- 2px (tilemap) vs 1px (character + sword)
	- Why does the player look so strange in comparison?
	- Color consistency issues

## Notes
___
- https://aran.ink/posts/celeste-tilesets - This is a great example for pixel art design for these levels, though doesn't directly correlate to Godot's capabilities
	- We should study other games to see how they manage art consistency
- We need to get more details for the first area; I'll assign work to the story designer for this

## Remaining Notes
___
- Make hammer lock to the nearest sixteenth rotation
- Make jabs better
- Make the sword slide sound pitch shift always
- Make the sword give a strong push upon a rapid collision
- Make the sword not bounce off of wall collisions

## Notes from Additional Playtesting
- **Notes for level design**
	- Don't introduce cables until the player is familiar with sword movement
		- Cables require advanced use of both sword movement and dashing
	- Only introduce the dash after the first level
		- People become too reliant on the dash, and don't learn wall jumping
	- Don't have elements which are counter intuitive to the player (backwards jump orbs, false gravity orbs, false cables, etc.). This rule is overridden in optional challenge levels.
- **Visual Notes**
	- Have feedback for when the player can dash
	- Have the direction of damage orbs displayed