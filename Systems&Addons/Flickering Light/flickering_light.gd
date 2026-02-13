extends OmniLight3D
class_name FlickeringFireLight

@export var base_energy: float = 2.0
@export var energy_variance: float = 0.5
@export var base_range: float = 5.0
@export var range_variance: float = 1.0
@export var speed: float = 5.0

var noise = FastNoiseLite.new()
var time: float = 0.0

func _ready():
	noise.seed = randi()
	noise.frequency = 0.5 # Lower = slower "licks" of flame

func _process(delta):
	time += delta * speed
	var noise_val = noise.get_noise_1d(time) # Returns value between -1 and 1
	
	# Map noise to light properties
	light_energy = base_energy + (noise_val * energy_variance)
	omni_range = base_range + (noise_val * range_variance)
