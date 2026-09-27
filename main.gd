extends Node

@export var mob_scene: PackedScene

func _ready():
	$UserInterface/Retry.hide()

func _on_mob_timer_timeout() -> void:
	# mob实例化
	var mob = mob_scene.instantiate()
	
	# 在SpawnPath上选择一个随机位置
	var mob_spawn_location = $SpawnPath/SpawnLocation
	mob_spawn_location.progress_ratio = randf()

	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)
	
	add_child(mob)
	
	# 实例化后立刻绑定
	# 当mob发出squashed信号时ScoreLabel节点会接收并调用_on_mob_squashed()函数
	mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())

func _on_player_hit() -> void:
	$MobTimer.stop()
	$UserInterface/Retry.show()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()
