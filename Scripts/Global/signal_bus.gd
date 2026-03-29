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

## Fires when a level is fully loaded.
@warning_ignore("unused_signal")
signal LevelLoaded()

## Fires when the level selector is loaded.
@warning_ignore("unused_signal")
signal SelectorLoaded()

## Firest when the game is paused/unpaused.
@warning_ignore("unused_signal")
signal PauseToggled()

## Request the game to be paused. Called from the pause menu to pause_manager.gd to avoid coupling.
@warning_ignore("unused_signal")
signal RequestUnpause()

## Called when the camera changes.
@warning_ignore("unused_signal")
signal CameraChanged(camera:Camera2D)

## Called when the level is fully loaded and any transition animations complete.
@warning_ignore("unused_signal")
signal TransitionFinished()

## Called when any player dies.
@warning_ignore("unused_signal")
signal PlayerKilled(player : Player)
#endregion

#region UI Requests

## Opens the settings menu.
@warning_ignore("unused_signal")
signal OpenSettings()

## Fires when the dialog queue ends.
@warning_ignore("unused_signal")
signal DialogStart

## Fires when the dialog queue is no longer empty.
@warning_ignore("unused_signal")
signal DialogEnd
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
