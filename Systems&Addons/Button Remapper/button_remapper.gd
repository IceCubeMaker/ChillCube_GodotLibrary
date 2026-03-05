extends Node
class_name ButtonRemapper

signal awaiting_input
signal _key_chosen(index : int)
signal button_remapped(action_name : String, input : InputEvent)

@export var action_to_rebind : String = "ui_up"
var is_waiting_for_input : bool = true;

func remap_keybind(action : String = action_to_rebind) -> InputEvent:
	var chosen_value = await self._key_chosen
	var event : InputEvent

	if typeof(chosen_value) == TYPE_INT:
		if Input.is_key_pressed(chosen_value): 
			event = InputEventKey.new()
			event.physical_keycode = chosen_value
		else: 
			event = InputEventJoypadButton.new()
			event.button_index = chosen_value
	else:
		push_error("Unknown input type!")
		return null

	var current_events = InputMap.action_get_events(action)
	for e in current_events:
		if _is_same_category(e, event):
			InputMap.action_erase_event(action, e)

	InputMap.action_add_event(action, event)
	emit_signal("button_remapped", action, event)
	return event

func _is_same_category(e1: InputEvent, e2: InputEvent) -> bool:
	var e1_is_pc = e1 is InputEventKey or e1 is InputEventMouseButton
	var e2_is_pc = e2 is InputEventKey or e2 is InputEventMouseButton
	var e1_is_joy = e1 is InputEventJoypadButton or e1 is InputEventJoypadMotion
	var e2_is_joy = e2 is InputEventJoypadButton or e2 is InputEventJoypadMotion
	
	return (e1_is_pc and e2_is_pc) or (e1_is_joy and e2_is_joy)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and is_waiting_for_input:
		emit_signal("_key_chosen", event.physical_keycode)
	elif event is InputEventJoypadButton and event.pressed:
		emit_signal("_key_chosen", event.button_index)

func _get_input_name(event) -> String:
	if event is InputEventKey:
		return OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventJoypadButton:
		return "Joypad Button %d" % event.button_index
	return "Button Unknown"
