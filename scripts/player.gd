@tool
extends CharacterBody2D

const SPEED       = 300.0
const BOOST_SPEED = 700.0
const RADIUS      = 30.0
const WORLD_SIZE  = Vector2(2000.0, 2000.0)

const CIRCLE_COLOR  = Color(0.2, 0.6, 1.0)
const BOOST_COLOR   = Color(1.0, 0.4, 0.1)
const OUTLINE_COLOR = Color(1.0, 1.0, 1.0, 0.5)

var _boosting := false

func _draw() -> void:
	var color := BOOST_COLOR if _boosting else CIRCLE_COLOR
	draw_circle(Vector2.ZERO, RADIUS, color)
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 64, OUTLINE_COLOR, 2.0)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_left")  or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_down")  or Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_action_pressed("ui_up")    or Input.is_key_pressed(KEY_W):
		direction.y -= 1

	if direction.length() > 0:
		direction = direction.normalized()

	_boosting = Input.is_key_pressed(KEY_SHIFT)
	var speed  := BOOST_SPEED if _boosting else SPEED

	velocity = direction * speed
	move_and_slide()

	# Clamp inside world bounds
	position = position.clamp(Vector2(RADIUS, RADIUS), WORLD_SIZE - Vector2(RADIUS, RADIUS))

	queue_redraw()
