class_name DialogLine extends Resource

enum SoundType {
	PER_CHARACTER, # A sound is played as each character displays
	PER_LINE       # One sound plays at the start of the line
}


## Text to be displayed via BBCode
@export_multiline var text := ""

## If true, the dialog will skip to the next line immediately when finished.
@export var auto: bool = false


@export_category("Display")
## Name to be displayed at the top of the dialog box.
@export var name:String

## Icon to be displayed. If not set, nothing is shown.
@export var icon: Texture2D


@export_category("Audio")

## The sound played during dialog.
@export var sound:SoundData = SoundData.new("res://Assets/Sound/SFX/Dialog/Dialog1.wav",0.5,1.0,&"Dialog")

## The time which the dialog sound plays.
@export var sound_type:SoundType = SoundType.PER_CHARACTER
