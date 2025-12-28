## This class is used to store a list of packed scenes, (for example for a deck of cards, or an inventory), and spawn them into the tree when needed
extends Resource
class_name DeckOfNodes

@export var deck_of_scenes : Array[PackedScene]

func append_packed_scene(packed_scene : PackedScene) -> void:
	deck_of_scenes.append(packed_scene)

func insert_packed_scene(position : int, packed_scene : PackedScene) -> void:
	deck_of_scenes.insert(position, packed_scene)

## Shuffles the nodes stored in the deck
func shuffle_nodes() -> void:
	deck_of_scenes.shuffle();

## Takes out a random node in the deck, removing it from the deck
func get_node_random() -> Node:
	var new_scene : Node2D = deck_of_scenes.pop_at(randi_range(0, deck_of_scenes.size()-1))
	return new_scene.instantiate()

## Takes out a node in the deck from the front
func get_node_front() -> Node:
	return deck_of_scenes.pop_front().instantiate()

## Takes out a node from the deck from the back
func get_node_back() -> Node:
	return deck_of_scenes.pop_back().instantiate()
