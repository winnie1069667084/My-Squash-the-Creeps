extends CharacterBody3D

# 玩家移动速度，单位m/s
@export var speed: float = 14.0
# 滞空时的重力加速度，单位m/s^2
@export var fall_acceleration = 75
# 玩家跳跃时提供的垂直速度，单位m/s
@export var jump_impulse = 20
# 玩家踩怪物获得的垂直速度，单位m/s
@export var bounce_impulse = 16

var target_velocity = Vector3.ZERO

# 玩家被水平碰撞后发出的死亡信号
signal hit

func _physics_process(delta: float) -> void:
	# 局部变量direction用来存储输入方向
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	
	# 向量归一化，防止斜向运动速度过快
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1
	
	# 地面速度
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	# 垂直速度，离开地面后施加重力加速度
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		
	velocity = target_velocity
	
	# 跳跃相关
	if is_on_floor() and Input.is_action_pressed("jump"):
		target_velocity.y = jump_impulse

	move_and_slide()

	# 碰撞相关
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		# 未发生碰撞直接跳过
		if collision.get_collider() == null:
			continue
		
		# 与mob发生的碰撞
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# 使用点积判断是否降落在怪物身上
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# 发出踩踏信号
				mob.squash()
				# 踩踏后赋予玩家向上初速
				target_velocity.y = bounce_impulse
				# 使用break防止重复踩踏和发出踩踏信号
				break
	
	# 让玩家在跳跃时产生弧线（俯仰角）
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse

func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body: Node3D) -> void:
	die()
