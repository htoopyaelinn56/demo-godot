# DemoGodot

A simple 2D Godot demo project built with **AI-agent-first development** — every scene, script, and asset in this repo was authored and iterated on entirely through an AI coding agent (opencode + Godot MCP server), not by hand in the editor.

## About

The project is a minimal top-down movement playground:

- A player circle (`CharacterBody2D`) moves with **WASD / arrow keys** and boosts with **Shift**.
- Red enemy circles chase the player using **A* pathfinding** (`NavigationAgent2D`), navigating around obstacles, surrounding the player from different sides via per-enemy ring offsets, re-routing when stuck, and charging straight in when they have line-of-sight.
- A 2000×2000 world filled with procedurally drawn obstacles: walls, squares, circles, triangles, and irregular polygons.
- Obstacles are declared as data in `scripts/obstacles.gd` and get matching `StaticBody2D` colliders generated at runtime, so visuals and physics always stay in sync. The navigation mesh is also built from this same data at runtime (world bounds minus obstacle outlines as holes).
- All rendering is done via custom `_draw()` calls — no image assets required.
- A smoothed `Camera2D` follows the player, and a HUD shows the controls.

## Requirements

- [Godot 4.7](https://godotengine.org) (built/tested with 4.7.2.stable.steam)

## Running

Open the project folder in Godot, or run from the CLI:

```sh
godot --path . scenes/main.tscn
```

## Project structure

```
project.godot            # Project config
scenes/main.tscn         # Main scene (player, obstacles, navigation, camera, HUD)
scenes/enemy.tscn        # Enemy scene (CharacterBody2D + NavigationAgent2D)
scripts/main.gd          # Enemy spawning
scripts/player.gd        # Player movement + custom drawing
scripts/enemy.gd         # Pathfinding chase AI + custom drawing
scripts/nav_region.gd    # Runtime navmesh generation from obstacle data
scripts/obstacles.gd     # Obstacle data, drawing, and collider generation
```

## AI-agent-first development

This repository demonstrates a workflow where the AI agent drives development directly:

1. **MCP tooling** – The agent interacts with Godot through an MCP server (create scenes/scripts, attach nodes, run the project headless, take screenshots).
2. **Code-first scenes** – Scenes are kept simple; behavior lives in scripts so it's easy for the agent to read, diff, and edit text files.
3. **Data-driven content** – Obstacles are plain dictionaries in code rather than hand-placed editor nodes, making them trivially generatable and modifiable by the agent.
4. **Headless validation** – Scripts can be syntax/type-checked and projects run headlessly to verify changes without opening the editor.

Feel free to use this as a template for building Godot projects collaboratively with AI agents.
