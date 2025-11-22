@tool
extends Control
class_name TextBox

signal textbox_start
signal textbox_stop

static var textbox_actions: Array[String] = ["ui_accept"]

@export var display_text: Array[String] = []:						## Text to be displayed in the textbox 
	set(new_text):
		display_text = new_text
		if Engine.is_editor_hint():
			_ready()
@export var scroll: bool = true
@export var scroll_speed: float = 0.01								## Scroll speed of the text

@onready var label: RichTextLabel = %RichTextLabel
@export var animation_player: AnimationPlayer
@export var open_animation_name: String = "open"
@export var close_animation_name: String = "close"

var debug: bool = false

var _scrolling: bool = false
var _current_text_index: int = 0
var _num_texts: int = 0
var _activated: bool = false


func _unhandled_input(_event: InputEvent) -> void:
	var _pressed_flag: bool = false
	for action in textbox_actions:
		if Input.is_action_just_pressed(action) and _activated:
			_pressed_flag = true
			if !_scrolling:
				next_text()
			else:
				var length_of_current_text: int = display_text[_current_text_index].length()
				label.visible_characters = length_of_current_text
				_scrolling = false


func next_text():
	if _current_text_index < _num_texts - 1:
		_load_next_text()
		scroll_text()
	else:
		close_textbox()


func _load_next_text():
	_current_text_index += 1
	label.text = display_text[_current_text_index]
	label.visible_characters = 0


func close_textbox():
	label.visible_characters = 0
	if animation_player and animation_player.has_animation(close_animation_name):
		animation_player.play(close_animation_name)
		await animation_player.animation_finished
	else:
		if debug: printerr("Animation player was not added or the animation ", close_animation_name, " does not exist.")
	
	textbox_stop.emit()
	queue_free()


func _ready() -> void:
	if !Engine.is_editor_hint():
		visible = false
	_num_texts = display_text.size()
	if _num_texts < 1:
		printerr("No display text has been entered in TextBox ", self, ".")
	_initialize_button_events()
	label.visible_characters = 0
	label.text = display_text[0]


func trigger_dialogue():
	if _activated:
		if debug: printerr("TextBox has been triggered twice.")
		return
	textbox_start.emit()
	visible = true
	_activated = true
	scroll_text()
	if animation_player and animation_player.has_animation(open_animation_name):
		animation_player.play(open_animation_name)
		await animation_player.animation_finished
	else:
		if debug: printerr("Animation player was not added or the animation ", open_animation_name, " does not exist.")


func scroll_text():
	_scrolling = true
	for letter in label.get_parsed_text():
		label.visible_characters += 1
		await get_tree().create_timer(scroll_speed).timeout
	_scrolling = false


func _initialize_button_events() -> void:
	for action in textbox_actions:
		if !InputMap.has_action(action):
			printerr("The action ", action, "has not been assigned.")
