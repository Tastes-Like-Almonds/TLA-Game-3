extends Level

@onready var wizard : WizardBoss = $Wizard/AnimatableBody2D

func initialize(config : LevelConfig = null) -> void:
	super(config)
	current_ui.set_boss_bar_value(1)
	wizard.FightStarted.connect(current_ui.set_boss_bar_enabled.bind(true))
	wizard.FightEnded.connect(current_ui.set_boss_bar_enabled.bind(false))
	wizard.Hit.connect(func(_x:Variant) -> void:
		current_ui.set_boss_bar_value(wizard.health/wizard.start_health)
	)
