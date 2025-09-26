extends Node
## A script for managing signals within the project.
##
## Not required to use, but should be done to reduce coupling.

#region Player
@warning_ignore("unused_signal")
signal BladeHit(victim : Node2D)

@warning_ignore("unused_signal")
signal PlayerAdded(player : Player) # TODO Test emit

@warning_ignore("unused_signal")
signal PlayerRemoved(player : Player) # TODO Test emit
#endregion

func _ready() -> void:
	var tree = get_tree()
	tree.node_added.connect(
		func(player):
			if player is Player: PlayerAdded.emit(player)
	)
	tree.node_removed.connect(
		func(player):
			if player is Player: PlayerRemoved.emit(player)
	)
