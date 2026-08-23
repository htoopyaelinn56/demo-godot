extends CharacterBody2D

const SPEED  = 200.0
const RADIUS = 24.0
const REPATH_INTERVAL = 0.3

const BODY_COLOR  = Color(0.9, 0.2, 0.2)
const OUTLINE_COLOR = Color(1.0, 0.8, 0.8, 0.6)
const PATH_COLOR  = Color(1.0, 0.2, 0.2, 0.35)

var _player: Node2D
var _repath_timer := 0.0

@onready var _agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	var scene := get_tree().current_scene
	if scene:
		_player = scene.get_node_or_null("Player")
	_agent.radius = RADIUS

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, BODY_COLOR)
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 48, OUTLINE_COLOR, 2.0)
	var look := Vector2.RIGHT
	if _player and is_instance_valid(_player):
		look = (_player.global_position - global_position).normalized()
	for side in [-1.0, 1.0]:
		var base := Vector2(look.x * 8.0 - look.y * 7.0 * side, look.y * 8.0 + look.x * 7.0 * side)
		draw_circle(base, 4.5, Color.WHITE)
	if not _agent.is_navigation_finished():
		var next := to_local(_agent.get_next_path_position())
		draw_line(Vector2.ZERO, next.limit_length(RADIUS * 3.0), PATH_COLOR, 3.0)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not _player or not is_instance_valid(_player):
		return

	_repath_timer -= delta
	if _repath_timer <= 0.0:
		_repath_timer = REPATH_INTERVAL
		_agent.target_position = _player.global_position

	if not _agent.is_navigation_finished():
		var dir := global_position.direction_to(_agent.get_next_path_position())
		velocity = dir * SPEED
		move_and_slide()

	queue_redraw()
