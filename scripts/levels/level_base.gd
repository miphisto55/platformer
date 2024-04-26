extends Node2D

signal score_changed

@export var world_tile_map: TileMap
@export var items_tile_map: TileMap
@export var danger_tile_map: TileMap
@export var player: CharacterBody2D
@export var spawn_point: Marker2D

var item_scene: PackedScene = load("res://scenes/items/item.tscn")
var score = 0:
	set = set_score

func set_score(value):
	score = value
	score_changed.emit()

func _ready():
	items_tile_map.hide()
	player.reset(spawn_point.position)
	set_camera_limits()
	spawn_items()

func spawn_items():
	var item_cells = items_tile_map.get_used_cells(0)
	for cell in item_cells:
		var data = items_tile_map.get_cell_tile_data(0, cell)
		var type = data.get_custom_data("type")
		var item = item_scene.instantiate() as Item
		add_child(item)
		item.init(type, items_tile_map.map_to_local(cell))
		item.picked_up.connect(self._on_item_picked_up)
	
func set_camera_limits():
	var map_size = world_tile_map.get_used_rect()
	var cell_size = world_tile_map.tile_set.tile_size
	var camera = player.find_child("Camera2D") as Camera2D
	camera.limit_left = (map_size.position.x - 5) * cell_size.x
	camera.limit_right = (map_size.end.x + 5) * cell_size.x
	
func _on_item_picked_up():
	score += 1
