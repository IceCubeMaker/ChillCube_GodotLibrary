## This is a button that players can use to remape buttons. It will be useful for keybinds settings in the game. 

extends Button
class_name button_to_remape_buttons

signal awaiting_input
signal button_remapped(action_name : String, input : InputEvent)

@export var action_to_rebind : String = "ui_left";
var button_remapper = ButtonRemapper.new()

func _ready() -> void:
	add_child(button_remapper)
	text = action_to_rebind
	self.connect("pressed", Callable(self, "_on_pressed"))
	button_remapper.connect("button_remapped", Callable(self, "_on_button_remapped"))

func _on_pressed() -> void:
	emit_signal("awaiting_input")
	button_remapper.remap_keybind(action_to_rebind)

func _on_button_remapped(action_name : String, input : InputEvent) -> void:
	emit_signal("button_remapped", action_name, input)
