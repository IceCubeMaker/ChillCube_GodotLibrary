extends RichTextEffect
class_name TypedEffect

var bbcode = "typed"
var speed : float = 16.0
var delay : float = 0.0
var punctuation_delay : float = .25
var cumulative_punctuation_delay : float = 0.0
var last_processed_index : int = -1

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if char_fx.env.get("speed") != null:
		speed = char_fx.env.get("speed")
	if char_fx.env.get("delay") != null:
		delay = char_fx.env.get("delay")
	if char_fx.env.get("punctuation_delay") != null:
		punctuation_delay = char_fx.env.get("punctuation_delay")
	
	# Reset cumulative delay when starting over
	if char_fx.relative_index == 0:
		cumulative_punctuation_delay = 0.0
		last_processed_index = -1
	
	# Check if the PREVIOUS character was punctuation
	# If so, add delay to the cumulative total
	if char_fx.relative_index > 0 and char_fx.relative_index > last_processed_index:
		# We need to check the previous character somehow
		# Since we can't easily access it, we'll track it
		last_processed_index = char_fx.relative_index
	
	var target_time = (char_fx.relative_index / speed) + delay + cumulative_punctuation_delay
	
	# If THIS character is punctuation, don't add delay to it
	# Add the delay to cumulative for NEXT characters
	if char_fx.glyph_flags == 257:
		cumulative_punctuation_delay += punctuation_delay
	
	char_fx.visible = char_fx.elapsed_time >= target_time
	
	return true
