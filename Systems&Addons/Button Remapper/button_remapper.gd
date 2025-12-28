## This node is used to let the player remap the keybinds in the games settings. 
## The node contains a function that lets it remap a certain keybind by waiting for the player input.
extends Node
class_name ButtonRemapper

## sends a signal once when the node starts waiting for input
signal awaiting_input
## sends a signal once, when a key is pressed. This is used internally, and isn't recommended for other nodes. You should use button_remapped instead
signal _key_chosen(index : int)
## sends a signal once the button has been remapped
signal button_remapped(action_name : String, input : InputEvent)

## This is the default action this node will use when rebinding
@export var action_to_rebind : String = "ui_up"
var is_waiting_for_input : bool = true;

## This is the function used to remap a key, it will return the key that was being used for the remap
func remap_keybind(action : String = action_to_rebind) -> InputEvent:
	var chosen_value = await self._key_chosen

	# Remove old events
	InputMap.action_erase_events(action)
	InputMap.add_action(action)

	var event : InputEvent

	# Create the correct event type
	if typeof(chosen_value) == TYPE_INT: # keyboard keycodes or joystick buttons are ints
		if Input.is_key_pressed(chosen_value): # keyboard
			event = InputEventKey.new()
			event.physical_keycode = chosen_value
		else: # assume joystick button
			event = InputEventJoypadButton.new()
			event.button_index = chosen_value
	else:
		push_error("Unknown input type!")

	InputMap.action_add_event(action, event)
	print("Bound '%s' to %s" % [action, _get_input_name(event)])
	emit_signal("button_remapped", action, event)
	return event

## This is used to get the input and send it to the remap_keybind() function
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and is_waiting_for_input:
		emit_signal("_key_chosen", event.physical_keycode)
	elif event is InputEventJoypadButton and event.pressed:
		emit_signal("_key_chosen", event.button_index)

## This is used to get the name of the input. This is mostly for debugging in the console. 
func _get_input_name(event) -> String:
	if event is InputEventKey:
		return OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventJoypadButton:
		return "Joypad Button %d" % event.button_index
	else:
		return "Button Unknown"
