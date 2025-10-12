## When

Tests should be written for as much as possible as to ensure the game works in the future.
Even if it seems redundant, write tests to be absolutely sure.

## How

Write pure functions whenever possible.
- Pure functions have a set output for every input, and do not modify anything outside of the function.
- If that is not possible, and the output depends on something other than the input, still separate the functionality into its own method and test it.

Following this: Never directly access properties from other classes unless there is a very good reason to do so. Instead, use setter/getter methods within the class to ensure that it can both be tested and expanded upon later.
- This is particularly the case for something like the player, where the drag of their movement depends on more than just the property "drag" that they have (A map could have ice ground, for instance).