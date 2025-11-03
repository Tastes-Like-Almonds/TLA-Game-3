___
**Note: Unofficial meeting; done after game release to discuss what we can fix**
## Attendance
---

```attendance
date: 2025-09-16
title: Game Development Club
query: #members
- [[Aidan Wignall]], "Present", ""
- [[Anton Nemkov]], "Present", ""
- [[Evan Gould]], "Present", ""
```

## Topics to Cover
___
**Gameplay**
- Only rating so far was a 5 for gameplay; Not good!

**What are the issues?**
- This game is not a precision platformer, yet does not have features which allow for other gameplay types.
- Not enough ACTION!
- Charge orbs are hard to use
- Sword spam is busted
- Cables are hard to use
	- Because pulling up at the end and getting the velocity right makes them weird sometimes
- The hammer isn't intuitive
	- Why? It's hard to aim, and hits the ground and seemingly random times (not random, but it feels that way
- Game feels unpolished. Why? I don't know.

**Visual stuff**
- The player looks weird using the sword. How do we fix this?
	- Player has an arm which points toward?
	- Player is a mage which can telekinetically move the sword?

## Notes
___
**What can be done to fix these problems?**
- System to lock camera movement to dynamic axis
	- Fixes some issues with level design, and encourages more sidescrolley levels
- Full movement on cables as if sword was on ground
	- More intuitive, Allows for easier to use cables
- 

## Testing Notes
___
- *Buff sword KB against bats*
- *Make dashing cancel gravity*
- *More cable control*
- *Add more ground friction*
- Make the sword give a strong push upon a rapid collision
- Make the sword not bounce off of wall collisions
- *Make dash bigger?*
- *Gravity orbs should reset dash*
- *Dash should instead reset velocity before pushing*
- Make the sword slide sound pitch shift always
- Make hammer lock to the nearest sixteenth rotation
- Make jabs better

## Changelog from Notes
___
- Sword now cancels velocity before dashing
- Buffed sword dash speed
- Gravity orbs now reset dash
- Ground friction was increased by 0.1
- Cables are now easier to exit (You leave immediately when moving up and are above the cable)
- Enemies take roughly triple the knockback and have a max_kb property.
- You can now move horizontally on the cable
- Vertical speed of cable pull halved
- Soft limit coef is now 5x stronger on a cable (as to prevent bouncing way too high)
- The camera now shakes slightly upon a dash

## Remaining Notes
___
- Make hammer lock to the nearest sixteenth rotation
- Make jabs better
- Make the sword slide sound pitch shift always
- Make the sword give a strong push upon a rapid collision
- Make the sword not bounce off of wall collisions