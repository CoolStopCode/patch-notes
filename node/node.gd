extends Node2D

@export var node : PackedScene

@export_group("Sizing")
@export var body_size : Vector2

@export_group("Sprites")
@export var body_sprite : Texture2D
@export var connection_sprite : Texture2D

@export_group("Connections")
@export var connections_in : Array[Vector2]
@export var connections_out : Array[Vector2]

@export_group("Nodes (private)")
@export var hover_rectangle_node : ColorRect
@export var body_sprite_node : Sprite2D
@export var area_node : Area2D
@export var area_collision_node : CollisionShape2D

signal actuated
var hovering := false



func _ready() -> void:
	load_sprites()

func load_sprites():
	hover_rectangle_node.size = body_size
	hover_rectangle_node.position = -body_size * 0.5
	
	body_sprite_node.texture = body_sprite
	
	var shape := RectangleShape2D.new()
	shape.set_size(body_size)
	area_collision_node.shape = shape



func _on_hitbox_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	pass # Replace with function body.

func _on_hitbox_mouse_entered() -> void:
	hovering = true
	hover_rectangle_node.show()

func _on_hitbox_mouse_exited() -> void:
	hovering = false
	hover_rectangle_node.hide()
