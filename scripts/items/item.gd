class_name Item
extends Area2D

signal picked_up

@export var sprite2d: Sprite2D

var textures = {
	"cherry": "res://assets/sprites/cherry.png",
	"gem": "res://assets/sprites/gem.png"
}

func init(type: String, pos: Vector2):
	sprite2d.texture = load(textures[type])
	position = pos


func _on_body_entered(body):
	picked_up.emit()
	queue_free()
