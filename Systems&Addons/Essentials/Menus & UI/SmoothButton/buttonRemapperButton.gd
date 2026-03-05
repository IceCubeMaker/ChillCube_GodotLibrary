@tool
extends SmoothButton
class_name smoothButtonRemapperButton

signal awaiting_input
signal button_remapped(action_name : String, input : InputEvent)

@export var action_to_rebind : String = "ui_left"

static var is_controller_mode : bool = false:
	set(val):
		if is_controller_mode == val: return
		is_controller_mode = val
		_update_all_buttons()

static var _all_remapper_buttons : Array[smoothButtonRemapperButton] = []

static func _update_all_buttons() -> void:
	for btn in _all_remapper_buttons:
		if is_instance_valid(btn):
			btn._refresh_display()

var button_remapper = ButtonRemapper.new()

func _ready() -> void:
	super()
	if not _all_remapper_buttons.has(self):
		_all_remapper_buttons.append(self)
		
	add_child(button_remapper)
	_refresh_display()
	
	self.connect("button_pressed", _on_pressed)
	button_remapper.connect("button_remapped", _on_button_remapped)

func _exit_tree() -> void:
	_all_remapper_buttons.erase(self)

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		is_controller_mode = false
	elif event is InputEventJoypadButton:
		if event.pressed: is_controller_mode = true
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.3: is_controller_mode = true

func _on_pressed() -> void:
	emit_signal("awaiting_input")
	button_text = "Press a button..."
	button_remapper.remap_keybind(action_to_rebind)

func _on_button_remapped(action_name : String, input : InputEvent) -> void:
	emit_signal("button_remapped", action_name, input)
	_update_all_buttons()

# Add this to SmoothButton.gd
func set_text_color(color: Color) -> void:
	if _label:
		_label.modulate = color

func _refresh_display() -> void:
	var human_action = action_to_rebind.replace("_", " ").capitalize()
	button_text = human_action + " => " + get_current_input_string()
	
	if _has_binding_conflict():
		set_text_color(Color.RED)
	else:
		set_text_color(Color.WHITE)

func _has_binding_conflict() -> bool:
	var my_active_input = _get_active_event()
	if not my_active_input: return false

	for other_action in InputMap.get_actions():
		if other_action == action_to_rebind: continue
		
		var other_events = InputMap.action_get_events(other_action)
		for e in other_events:
			if e.device == my_active_input.device and _is_event_match(e, my_active_input):
				return true
	return false

func _is_event_match(e1: InputEvent, e2: InputEvent) -> bool:
	if e1.get_class() != e2.get_class(): return false
	
	if e1 is InputEventKey:
		return e1.get_keycode_with_modifiers() == e2.get_keycode_with_modifiers()
	if e1 is InputEventJoypadButton:
		return e1.button_index == e2.button_index
	if e1 is InputEventJoypadMotion:
		return e1.axis == e2.axis and sign(e1.axis_value) == sign(e2.axis_value)
	if e1 is InputEventMouseButton:
		return e1.button_index == e2.button_index
	return false

func _get_active_event() -> InputEvent:
	var events = InputMap.action_get_events(action_to_rebind)
	var kb : InputEvent = null
	var joy : InputEvent = null
	for e in events:
		if e is InputEventKey or e is InputEventMouseButton: kb = e
		else: joy = e
	
	var active = joy if is_controller_mode else kb
	return active if active else (kb if joy else joy)

func get_current_input_string() -> String:
	var active_event = _get_active_event()
	if active_event:
		return _format_event_text(active_event)
	return "None"

func _format_event_text(event: InputEvent) -> String:
	if event is InputEventKey:
		var key_text = OS.get_keycode_string(event.physical_keycode if event.physical_keycode else event.keycode)
		return key_text.capitalize()
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT: return "LMB"
			MOUSE_BUTTON_RIGHT: return "RMB"
			MOUSE_BUTTON_MIDDLE: return "MMB"
			_: return "Mouse " + str(event.button_index)
	
	if event is InputEventJoypadButton:
		match event.button_index:
			JOY_BUTTON_A: return "A / Cross"
			JOY_BUTTON_B: return "B / Circle"
			JOY_BUTTON_X: return "X / Square"
			JOY_BUTTON_Y: return "Y / Triangle"
			JOY_BUTTON_LEFT_SHOULDER: return "LB / L1"
			JOY_BUTTON_RIGHT_SHOULDER: return "RB / R1"
			JOY_BUTTON_BACK: return "Back / Select"
			JOY_BUTTON_START: return "Start / Options"
			JOY_BUTTON_LEFT_STICK: return "L-Stick Click"
			JOY_BUTTON_RIGHT_STICK: return "R-Stick Click"
			JOY_BUTTON_DPAD_UP: return "D-Pad Up"
			JOY_BUTTON_DPAD_DOWN: return "D-Pad Down"
			JOY_BUTTON_DPAD_LEFT: return "D-Pad Left"
			JOY_BUTTON_DPAD_RIGHT: return "D-Pad Right"
			_: return "Button " + str(event.button_index)
			
	if event is InputEventJoypadMotion:
		var axis_name = ""
		match event.axis:
			JOY_AXIS_LEFT_X: axis_name = "L-Stick Horz"
			JOY_AXIS_LEFT_Y: axis_name = "L-Stick Vert"
			JOY_AXIS_RIGHT_X: axis_name = "R-Stick Horz"
			JOY_AXIS_RIGHT_Y: axis_name = "R-Stick Vert"
			JOY_AXIS_TRIGGER_LEFT: return "LT / L2"
			JOY_AXIS_TRIGGER_RIGHT: return "RT / R2"
			_: axis_name = "Axis " + str(event.axis)
		
		var dir = "+" if event.axis_value > 0 else "-"
		return axis_name + " " + dir
		
	return event.as_text().replace("_", " ").capitalize()
