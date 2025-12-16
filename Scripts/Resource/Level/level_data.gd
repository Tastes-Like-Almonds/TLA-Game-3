class_name LevelData extends Resource

@export var title: String = ""
@export_multiline var description: String = ""
@export var difficulty:Level.Difficulty = Level.Difficulty.EFFORTLESS
@export_file_path("*.tscn") var level_path : String
