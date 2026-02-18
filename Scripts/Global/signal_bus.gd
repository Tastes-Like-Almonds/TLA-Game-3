extends Node
## A script for managing signals within the project.
##
## Not required to use, but should be done to reduce coupling.

## Fired when main is fully loaded.
@warning_ignore("unused_signal")
signal MainLoaded()

#region Player
## Fired when a player's blade hits something.
@warning_ignore("unused_signal")
signal BladeHit(victim : Node2D)

## Fired when a player node is added to the tree.
@warning_ignore("unused_signal")
signal PlayerAdded(player : Player)

## Fired when a player node is removed from the tree. This is fired after its removal, thus the
## reference is not included in the signal (null).
@warning_ignore("unused_signal")
signal PlayerRemoved()

#endregion

#region level
## Fired when a level is loaded via LevelLoader.gd. Passes the string path of the level.
@warning_ignore("unused_signal")
signal LevelPathLoaded(level: Level)

## Firest when the game is paused/unpaused.
@warning_ignore("unused_signal")
signal PauseToggled()

## Request the game to be paused. Called from the pause menu to pause_manager.gd to avoid coupling.
@warning_ignore("unused_signal")
signal RequestUnpause()
#endregion

#region UI Requests

## Opens the settings menu.
@warning_ignore("unused_signal")
signal OpenSettings()
#endregion

func _ready() -> void:
	var tree : SceneTree = get_tree()
	tree.node_added.connect(
		func(player : Node) -> void:
			if player is Player: PlayerAdded.emit(player)
	)
	tree.node_removed.connect(
		func(player : Node) -> void:
			await player.tree_exited
			if player is Player: PlayerRemoved.emit()
	)
