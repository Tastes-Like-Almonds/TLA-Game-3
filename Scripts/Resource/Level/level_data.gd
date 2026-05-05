class_name LevelData extends Resource

@export var title: String = ""
@export_multiline var description: String = ""
@export var difficulty:Level.Difficulty = Level.Difficulty.EFFORTLESS
@export_file_path("*.tscn") var level_path : String
@export var is_boss : bool = false

func get_difficulty_string() -> String:
	var s := "[b]Difficulty:[/b] "
	
	match difficulty:
		Level.Difficulty.EFFORTLESS:
			s += "[color=light_green]Efforless[/color]"
		Level.Difficulty.EASY:
			s += "[color=green]Easy[/color]"
		Level.Difficulty.AVERAGE:
			s += "[color=orange]Moderate[/color]"
		Level.Difficulty.HARD:
			s += "[color=red]Hard[/color]"
		Level.Difficulty.TOUGH:
			s += "[color=dark_red]Tough[/color]"
	
	return s
