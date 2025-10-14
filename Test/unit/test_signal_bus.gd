extends GutTest

func before_each() -> void:
	watch_signals(SignalBus)

func test_player_signals() -> void:
	
	var player : Player = load("res://Scenes/Player/player.tscn").instantiate()
	
	add_child_autoqfree(player)
	assert_signal_emitted(SignalBus.PlayerAdded, "Adding player did not fire SignalBus.PlayerAdded")
	
	remove_child(player)
	assert_signal_emitted(SignalBus.PlayerRemoved, "Removing player did not fire SignalBus.PlayerRemoved")

func test_main_signal() -> void:
	
	var main : Main = load("res://Scenes/main.tscn").instantiate()
	
	add_child_autoqfree(main)
	assert_signal_emitted(SignalBus.MainLoaded, "Loading main did not fire SignalBus.MainLoaded")
