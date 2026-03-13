class_name DialogTree extends Resource

## Default time between characters displayed
const DEFAULT_SPEED: float = 0.05

## Multipliers applied to specific symbols when displaying text; e.g. "." being set to 2 would mean
## it pauses for twice the time.
const SYMBOL_COEFS: Dictionary[String, float] = {
	".": 6,
	"!": 4,
	"?": 4,
	",": 3,
	";": 3
}

## An array of dialog lines to be displayed sequentially.
@export var lines : Array[DialogLine]

## After the dialog has run out of lines, these choices are presented to further dialog.
@export var choices : Dictionary[String,DialogTree]
