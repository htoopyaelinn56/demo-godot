extends NavigationRegion2D

const WORLD_SIZE = Vector2(2000.0, 2000.0)
const MARGIN = 40.0
const ARC_SEGMENTS = 24

var _obstacles: Array = preload("res://scripts/obstacles.gd").OBSTACLES

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var poly := NavigationPolygon.new()
	var source_geometry := NavigationMeshSourceGeometryData2D.new()
	source_geometry.add_traversable_outline(PackedVector2Array([
		Vector2(MARGIN, MARGIN),
		Vector2(WORLD_SIZE.x - MARGIN, MARGIN),
		Vector2(WORLD_SIZE.x - MARGIN, WORLD_SIZE.y - MARGIN),
		Vector2(MARGIN, WORLD_SIZE.y - MARGIN),
	]))

	for obs in _obstacles:
		var outline := _obstacle_outline(obs)
		if outline.size() >= 3:
			source_geometry.add_obstruction_outline(outline)

	NavigationServer2D.bake_from_source_geometry_data(poly, source_geometry)
	navigation_polygon = poly

func _obstacle_outline(obs: Dictionary) -> PackedVector2Array:
	var pts := PackedVector2Array()
	match obs["type"]:
		"rect":
			var half: Vector2 = obs["size"] / 2.0
			var pos: Vector2 = obs["pos"]
			pts.append(pos + Vector2(-half.x, -half.y))
			pts.append(pos + Vector2(half.x, -half.y))
			pts.append(pos + Vector2(half.x, half.y))
			pts.append(pos + Vector2(-half.x, half.y))
		"circle":
			var pos: Vector2 = obs["pos"]
			var radius: float = obs["radius"]
			for i in ARC_SEGMENTS:
				var a := TAU * float(i) / float(ARC_SEGMENTS)
				pts.append(pos + Vector2(cos(a), sin(a)) * radius)
		"polygon":
			for p: Vector2 in obs["points"]:
				pts.append(obs["pos"] + p)
	return pts
