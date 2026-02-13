## Attendance
---

```attendance
date: 2025-09-16
title: Game Development Club
query: #members
- [[Aidan Wignall]], "Present", ""
- [[Mizuki Wong]], "Present", ""
- [[Anton Nemkov]], "Excused", ""
- [[Zachary Cluff]], "Present", ""
- [[Evan Gould]], "Present", ""
```

## Topics to Cover
___
None; All that is needed is to cover issues with the other team.

## Notes
___
- Group doc is now present (It has been, but I forgot to add this to the notes)
- We are a bit behind in content, though making progress
- Changes have been made to our level system
	- We will have five "worlds", and levels will connect seamlessly.
		- As such, we will not have a level loader unless there is enough time budgeted later in dev.
	- Level data will mostly be hidden "name, description, etc."

## Development TODO
- Create level loading node
	- On collision, load level from exported path
	- Visual transition between levels
- Create separate environment node to be instantiated across levels in the same world
- Create dialog system
## Remaining Notes
___
- Make hammer lock to the nearest sixteenth rotation
- Make jabs better
- Make the sword slide sound pitch shift always
- Make the sword give a strong push upon a rapid collision
- Make the sword not bounce off of wall collisions