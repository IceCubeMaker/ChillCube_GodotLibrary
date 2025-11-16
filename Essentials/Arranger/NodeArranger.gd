## This node will sort / arrange the child nodes in a certain way, that you can define yourself with the variables.
extends Node2D
class_name NodeArranger

@export var nodes_to_exclude : Array[Node]
## Use if the nodes being sorted are not the child nodes (like sub-children)
@export var alternative_node_list : Array[Node] = []

@export var continous_arranging = true;

@export var max_vertical : int = 1
@export var max_horizontal : int = 10
@export var centered : bool = true;

@export var distance_vertical : float = 100;
@export var distance_horizontal : float = 100;

@export var left_to_right : bool = true;
@export var right_to_left : bool = true;

func _process(delta: float) -> void:
	if continous_arranging:
		arrange()

func arrange() -> void:
	var nodes_to_arrange : Array[Node]
	if alternative_node_list.size() == 0:
		nodes_to_arrange  = get_children()
	else:
		nodes_to_arrange = alternative_node_list
	for node in nodes_to_exclude:
		if node in nodes_to_arrange:
			nodes_to_arrange.erase(node)
	_arrange_nodes(nodes_to_arrange)

func _arrange_nodes(nodes : Array[Node]) -> void:
	var node_count_horizontal : int = 0;
	var node_count_vertical : int = 0;
	var place_node : bool = true 
	for node in nodes:
		if node_count_horizontal < max_horizontal:
			node_count_horizontal += 1;
		else:
			node_count_horizontal = 1;
			node_count_vertical += 1;
			if node_count_vertical >= max_vertical:
				place_node = false;
		if place_node:
			var placement : Vector2 
			if centered:
				placement = global_position + Vector2(distance_horizontal * (node_count_horizontal - (max_horizontal/2)), distance_vertical * (node_count_vertical - (max_vertical/2)))
			else:
				placement = global_position + Vector2(distance_horizontal * node_count_horizontal, distance_vertical * node_count_vertical)
			_arrange_node(node, placement, 0)

func _arrange_node(node : Node, global_pos, global_rot):
	if node.has_node("SmoothMovement"):
		node.get_node("SmoothMovement").global_target_position = global_pos
		node.get_node("SmoothMovement").global_target_rotation = global_rot
	else:
		node.global_position = global_pos
		node.global_rotation = global_rot
