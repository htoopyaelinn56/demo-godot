@tool
extends Node2D

const OBSTACLES: Array[Dictionary] = [
	# --- Horizontal walls ---
	{"type": "rect", "pos": Vector2(400, 300),   "size": Vector2(250, 70),  "color": Color(0.22, 0.22, 0.22)},
	{"type": "rect", "pos": Vector2(1100, 200),  "size": Vector2(300, 60),  "color": Color(0.28, 0.28, 0.28)},
	{"type": "rect", "pos": Vector2(800, 1400),  "size": Vector2(350, 70),  "color": Color(0.20, 0.20, 0.20)},
	{"type": "rect", "pos": Vector2(1500, 1600), "size": Vector2(280, 60),  "color": Color(0.25, 0.25, 0.25)},
	# --- Vertical walls ---
	{"type": "rect", "pos": Vector2(1700, 600),  "size": Vector2(60, 300),  "color": Color(0.22, 0.22, 0.22)},
	{"type": "rect", "pos": Vector2(300, 1700),  "size": Vector2(70, 280),  "color": Color(0.27, 0.27, 0.27)},
	# --- Squares ---
	{"type": "rect", "pos": Vector2(600, 700),   "size": Vector2(100, 100), "color": Color(0.18, 0.18, 0.18)},
	{"type": "rect", "pos": Vector2(1400, 900),  "size": Vector2(120, 120), "color": Color(0.23, 0.23, 0.23)},
	{"type": "rect", "pos": Vector2(1800, 1400), "size": Vector2(90, 90),   "color": Color(0.26, 0.26, 0.26)},
	# --- Circles ---
	{"type": "circle", "pos": Vector2(900, 500),   "radius": 80.0, "color": Color(0.20, 0.20, 0.20)},
	{"type": "circle", "pos": Vector2(300, 1100),  "radius": 60.0, "color": Color(0.25, 0.25, 0.25)},
	{"type": "circle", "pos": Vector2(1600, 1300), "radius": 70.0, "color": Color(0.18, 0.18, 0.18)},
	{"type": "circle", "pos": Vector2(1200, 1700), "radius": 50.0, "color": Color(0.28, 0.28, 0.28)},
	# --- Triangles ---
	{"type": "polygon", "pos": Vector2(700, 1100),  "points": [Vector2(0, -90), Vector2(78, 45), Vector2(-78, 45)],                                                         "color": Color(0.21, 0.21, 0.21)},
	{"type": "polygon", "pos": Vector2(1300, 400),  "points": [Vector2(0, -80), Vector2(70, 80), Vector2(-70, 80)],                                                          "color": Color(0.24, 0.24, 0.24)},
	{"type": "polygon", "pos": Vector2(1800, 200),  "points": [Vector2(-60, 60), Vector2(60, 60), Vector2(0, -80)],                                                          "color": Color(0.19, 0.19, 0.19)},
	# --- Irregular polygons ---
	{"type": "polygon", "pos": Vector2(500, 1500),  "points": [Vector2(-80, -60), Vector2(20, -60), Vector2(20, -20), Vector2(80, -20), Vector2(80, 60), Vector2(-80, 60)],  "color": Color(0.23, 0.23, 0.23)},
	{"type": "polygon", "pos": Vector2(1100, 1200), "points": [Vector2(-90, -30), Vector2(30, -90), Vector2(90, 30), Vector2(-30, 90)],                                      "color": Color(0.26, 0.26, 0.26)},
]

const OUTLINE := Color(1, 1, 1, 0.35)

func _draw() -> void:
	for obs in OBSTACLES:
		match obs["type"]:
			"rect":
				var half: Vector2 = obs["size"] / 2.0
				var rect := Rect2(obs["pos"] - half, obs["size"])
				draw_rect(rect, obs["color"])
				draw_rect(rect, OUTLINE, false, 2.0)
			"circle":
				draw_circle(obs["pos"], obs["radius"], obs["color"])
				draw_arc(obs["pos"], obs["radius"], 0.0, TAU, 64, OUTLINE, 2.0)
			"polygon":
				var pts := PackedVector2Array()
				for p: Vector2 in obs["points"]:
					pts.append(obs["pos"] + p)
				draw_polygon(pts, PackedColorArray([obs["color"]]))
				pts.append(pts[0])
				draw_polyline(pts, OUTLINE, 2.0)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_build_colliders()

func _build_colliders() -> void:
	for obs in OBSTACLES:
		var body := StaticBody2D.new()
		body.position = obs["pos"]
		add_child(body)
		var col := CollisionShape2D.new()
		body.add_child(col)
		match obs["type"]:
			"rect":
				var shape := RectangleShape2D.new()
				shape.size = obs["size"]
				col.shape = shape
			"circle":
				var shape := CircleShape2D.new()
				shape.radius = obs["radius"]
				col.shape = shape
			"polygon":
				var shape := ConvexPolygonShape2D.new()
				shape.points = PackedVector2Array(obs["points"])
				col.shape = shape
