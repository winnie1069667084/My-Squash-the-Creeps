extends CharacterBody3D

@export var min_speed = 10
@export var max_speed = 18

signal squashed

func _physics_process(delta: float) -> void:
	move_and_slide()

# 这个函数将会被Main场景调用
func initialize(start_position, player_position):
	# 我们将会把mob放置在start_position
	# 然后将它转向player_position
	look_at_from_position(start_position, player_position, Vector3.UP)
	# 将mob在-45 ~ +45的角度范围内随机转向
	# 这样他将不会直接向玩家冲去
	rotate_y(randf_range(-PI / 4, PI / 4))
	
	# 计算随机速度（整形）
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	# 随机mob动画速度
	$AnimationPlayer.speed_scale = random_speed / min_speed

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()

# 踩踏信号发生器
func squash():
	squashed.emit()
	# 怪物被踩踏后死亡
	queue_free()
