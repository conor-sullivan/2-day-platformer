extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var dash_sound: AudioStreamPlayer2D = $DashSound

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var ground_acceleration = 800.0
@export var ground_friction = 1000.0
@export var air_friction = 500.0
@export var better_jump_multiplier = 5.0
@export var dash_speed = 250.0
@export var flash_on_color = Vector4(0.957, 0.635, 0.349, 1.0)
@export var flash_off_color = Vector4(1, 1, 1, 1)
@export var flash_on_speed = 0.5
@export var flash_off_speed = 0


var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var air_jump = false
var can_dash = true
var just_wall_jumped = false
var facing_direction = 1
var starting_position
var was_wall_normal = Vector2.ZERO

func _ready() -> void:
	Events.checkpoint_entered.connect(checkpoint_entered)
	starting_position = global_position

	flash_disable()

func _physics_process(delta: float) -> void:
	var input_direction = Input.get_axis("left", "right")
	if input_direction != 0: facing_direction = input_direction
	
	handle_wall_jump()
	handle_jump(delta)
	apply_gravity(delta)
	handle_animations(input_direction, delta)
	handle_acceleration(input_direction, delta)
	apply_ground_friction(input_direction, delta)
	apply_air_friction(input_direction, delta)
	handle_dash(delta)
	
	move_and_slide()
	just_wall_jumped = false

func checkpoint_entered():
	starting_position = position

func handle_dash(delta):
	if Input.is_action_just_pressed("dash") and can_dash:
		dash_cooldown_timer.start()
		velocity.x += facing_direction * dash_speed * delta
		velocity.y -= gravity * 2 * delta
		can_dash = false
		play_dash_sound()
		flash()

func apply_air_friction(input_direction, delta):
	if is_on_floor(): return 
	if input_direction: return
	velocity.x = move_toward(velocity.x, 0, air_friction * delta)
	
func handle_acceleration(input_direction, delta):
	if not input_direction: return
	velocity.x = move_toward(velocity.x, input_direction * speed, ground_acceleration * delta)

func apply_ground_friction(input_direction, delta):
	if not input_direction: velocity.x = move_toward(velocity.x, 0, ground_friction * delta)

func apply_gravity(delta):
	if not is_on_floor(): velocity.y += gravity * delta

func handle_animations(input_direction, delta):
	if input_direction:
		flip(input_direction)
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")
	elif velocity.x != 0 and is_on_floor():
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")		

func handle_jump(delta):
	#if is_on_floor(): air_jump = true

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
			play_jump_sound()
			air_jump = true
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < jump_velocity / 2:
			velocity.y = jump_velocity / 2
		if Input.is_action_just_pressed("jump") and air_jump: # and not just_wall_jumped:
			air_jump = false
			velocity.y = jump_velocity * 0.8
			play_jump_sound()
func handle_wall_jump():
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0.0: return
	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left > 0.0: 
		wall_normal = was_wall_normal
	if Input.is_action_just_pressed("left") and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * speed
		velocity.y = jump_velocity
		play_jump_sound()
	if Input.is_action_just_pressed("right") and wall_normal == Vector2.RIGHT:
		velocity.x = wall_normal.x * speed
		velocity.y = jump_velocity
		play_jump_sound()
	just_wall_jumped = true
	
func flip(input_direction):
	if not input_direction: return
	if input_direction == -1:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false

func flash():
	material.set_shader_parameter("tint", flash_on_color)
	material.set_shader_parameter("speed", flash_on_speed)
	await dash_cooldown_timer.timeout
	flash_disable()
	
func flash_disable():
	material.set_shader_parameter("tint", flash_off_color)
	material.set_shader_parameter("speed", flash_off_speed)
	
func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

func _on_hazard_detector_area_entered(area: Area2D) -> void:
	position = starting_position
	flash_disable()
	
func play_jump_sound():
	jump_sound.play()

func play_dash_sound():
	dash_sound.play()
