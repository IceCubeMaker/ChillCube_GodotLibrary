@tool
extends Control
class_name TextBox
## Simple TextBox component that can be added and placed into a scene.
## Add the actions that control the textbox to the [member TextBox.textbox_actions] array.
## Trigger the TextBox by calling the [method TextBox.trigger_dialogue] function.
## Call the next text by calling the [method TextBox.next_text] function. (Note: This is normally done automatically.)
## Scroll the text by calling the [method TextBox.scroll_text] function. (Note: This is normally done automatically.)
## Close the TextBox by calling the [method TextBox.close_textbox] function. (Note: This is normally done automatically.)


signal textbox_start 	## Emitted when the TextBox has been opened.
signal textbox_close 	## Emitted when the TextBox has been closed.

static var textbox_actions: Array[String] = ["ui_accept"] ## Actions, that control the current TextBox.

@export var display_text: Array[String] = []:		## Text to be displayed in the TextBox 
	set(new_text):
		display_text = new_text
		if Engine.is_editor_hint():
			_ready()
#@export var scroll: bool = true					## TODO: Sets, whether the text should be scrolling or not
@export var scroll_speed: float = 0.01				## Scroll speed of the text.

@onready var label: RichTextLabel = %RichTextLabel	## The label, where the text is to be displayed.
@export var animation_player: AnimationPlayer		## The Animationplayer for opening and closing animations.
@export var open_animation_name: String = "open"	## Name of the opening animation.
@export var close_animation_name: String = "close"	## Name of the closing animation.

var debug: bool = false		## Prints additional debug information when necessary.

var _scrolling: bool = false
var _current_text_index: int = 0
var _num_texts: int = 0
var _activated: bool = false


func _ready() -> void:
	if !Engine.is_editor_hint():
		visible = false
	_num_texts = display_text.size() # set the number of the texts that should be displayed
	if _num_texts < 1:
		printerr("No display text has been entered in TextBox ", self, ".")
	_initialize_button_events()
	label.visible_characters = 0
	label.text = display_text[0]


## Start the TextBox by calling this function.
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
	

## Go to the next text and display it.
## This is automatically called when using one of the declared [member TextBox.textbox_actions] actions.
func next_text():
	if _current_text_index < _num_texts - 1:
		_load_next_text()
		scroll_text()
	else:
		close_textbox()


## Starts the scrolling of the text, using the set parameters.
func scroll_text():
	_scrolling = true
	for letter in label.get_parsed_text():
		label.visible_characters += 1
		await get_tree().create_timer(scroll_speed).timeout
	_scrolling = false


## Prepares the next text, that should be displayed.
func _load_next_text():
	_current_text_index += 1
	label.text = display_text[_current_text_index]
	label.visible_characters = 0


## Closes the current TextBox. This is automatically called, when the entire text has been gone gone through.
func close_textbox():
	label.visible_characters = 0
	if animation_player and animation_player.has_animation(close_animation_name):
		animation_player.play(close_animation_name)
		await animation_player.animation_finished
	else:
		if debug: printerr("Animation player was not added or the animation ", close_animation_name, " does not exist.")
	
	textbox_close.emit()
	queue_free()


## Prints an error message, if the actions that have been declared as 
## text UI buttons are not assigned correctly.
func _initialize_button_events() -> void:
	for action in textbox_actions:
		if !InputMap.has_action(action):
			printerr("The action ", action, "has not been assigned.")


func _unhandled_input(_event: InputEvent) -> void:
	var _pressed_flag: bool = false  # probably unnecessary?
	for action in textbox_actions:
		if Input.is_action_just_pressed(action) and _activated:
			_pressed_flag = true
			if !_scrolling: # go to the next text
				next_text()
			else: # skip to the end of the current text
				var length_of_current_text: int = display_text[_current_text_index].length()
				label.visible_characters = length_of_current_text
				_scrolling = false
