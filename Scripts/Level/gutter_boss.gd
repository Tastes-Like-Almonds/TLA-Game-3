extends Level

@onready var wizard : WizardBoss = $Wizard/AnimatableBody2D

func initialize(config : LevelConfig = null) -> void:
	super(config)
	current_ui.set_boss_bar_value(1)
	wizard.FightStarted.connect(current_ui.set_boss_bar_enabled.bind(true))
	wizard.FightEnded.connect(current_ui.set_boss_bar_enabled.bind(false))
	wizard.HealthChanged.connect(func(new:float) -> void:
		current_ui.set_boss_bar_value(new/wizard.start_health)
	)
	current_ui.set_boss_bar_name("The Wizard")
	wizard.Killed.connect(func() -> void:
		$Whiteout.modulate = Color.BLACK
		for player : Player in Helper.get_all_players():
			player.heal(10)
		current_ui.set_boss_bar_enabled(false)
		CosmeticLoader.give_cosmetic("res://Data/Cosmetic/wizard_hat.tres")
		get_tree().create_timer(2).timeout.connect(complete)
	)
