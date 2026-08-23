extends CharacterBody2D

const SPEED  = 200.0
const RADIUS = 24.0
const RING_RADIUS = 60.0
const REPATH_INTERVAL = 0.3
const STUCK_DISTANCE = 8.0
const WALL_MASK = 1

const BODY_COLOR  = Color(0.9, 0.2, 0.2)
const OUTLINE_COLOR = Color(1.0, 0.8, 0.8, 0.6)
const PATH_COLOR  = Color(1.0, 0.2, 0.2, 0.35)

var _player: Node2D
var _repath_timer := 0.0
var _ring_angle := 0.0
var _ring_offset := Vector2.ZERO
var _last_progress_pos := Vector2.ZERO
var _stuck_time := 0.0

@onready var _agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	var scene := get_tree().current_scene
	if scene:
		_player = scene.get_node_or_null("Player")
	_agent.radius = RADIUS
	_pick_ring_angle()
	_last_progress_pos = global_position

func _pick_ring_angle() -> void:
	var found := false
	for i in 12:
		var angle := randf() * TAU
		var candidate: Vector2 = _player.global_position + Vector2.from_angle(angle) * RING_RADIUS if _player else Vector2.from_angle(angle) * RING_RADIUS
		if not _point_blocked(candidate):
			_ring_angle = angle
			found = true
			break
	if not found:
		_ring_angle += PI + randf_range(-1.0, 1.0)
	_ring_offset = Vector2.from_angle(_ring_angle) * RING_RADIUS

func _point_blocked(point: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = point
	params.collision_mask = WALL_MASK
	return not space.intersect_point(params, 1).is_empty()

func _has_line_of_sight() -> bool:
	if not _player or not is_instance_valid(_player):
		return false
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, _player.global_position, WALL_MASK)
	return space.intersect_ray(query).is_empty()

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
		_agent.target_position = _player.global_position + _ring_offset

	# Stuck detection: barely moved while path not finished -> pick a new ring spot
	if not _agent.is_navigation_finished():
		if global_position.distance_to(_last_progress_pos) < STUCK_DISTANCE:
			_stuck_time += delta
			if _stuck_time > 0.6:
				_stuck_time = 0.0
				_pick_ring_angle()
				_agent.target_position = _player.global_position + _ring_offset
		else:
			_stuck_time = 0.0
		_last_progress_pos = global_position

	# Close range with clear sight: charge straight at the player
	if _has_line_of_sight():
		var to_player := global_position.distance_to(_player.global_position)
		if to_player > RADIUS + 30.0 + RING_RADIUS * 0.5:
			velocity = global_position.direction_to(_player.global_position) * SPEED
			move_and_slide()
			queue_redraw()
			return

	if not _agent.is_navigation_finished():
		var dir := global_position.direction_to(_agent.get_next_path_position())
		velocity = dir * SPEED
		move_and_slide()

	queue_redraw()
