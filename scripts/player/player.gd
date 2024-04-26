class_name Player
extends CharacterBody2D

signal life_changed
signal died

@export var gravity: int = 750
@export var run_speed: int = 150
@export var jump_speed: int = -300

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite2d: Sprite2D = $Sprite2D

enum { IDLE, RUN, JUMP, HURT, DEAD }
var state = IDLE

var life = 3: 
	set = set_life

func set_life(value: int):
	life = value
	life_changed.emit(life)
	if life <= 0:
		change_state(DEAD)

func _ready():
	change_state(IDLE)

func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	
	move_and_slide()
	
	if state == JUMP and is_on_floor():
		change_state(IDLE)
		
	if state == JUMP and velocity.y > 0:
		animation_player.play("jump_down")

func reset(pos: Vector2):
	life = 3
	self.position = pos

func hurt():
	if state != HURT:
		change_state(HURT)

func get_input():
	if state == HURT:
		return
	
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	
	# Movement occurs in all states
	velocity.x = 0
	
	if right:
		velocity.x += run_speed
		sprite2d.flip_h = false
	if left:
		velocity.x -= run_speed
		sprite2d.flip_h = true
		
	# Allow jumping when on the ground
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
	
	# IDLE transitions to RUN when moving
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
	
	# RUN transitions to IDLE when standing still
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
		
	# Transition to JUMP when in air
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			animation_player.play("idle")
		RUN:
			animation_player.play("run")
		HURT:
			animation_player.play("hurt")
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
			life -= 1
			await get_tree().create_timer(0.5).timeout
			change_state(IDLE)
		JUMP:
			animation_player.play("jump_up")
		DEAD:
			died.emit()
			hide()
