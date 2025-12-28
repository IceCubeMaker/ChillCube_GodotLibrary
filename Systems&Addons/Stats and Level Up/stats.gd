extends Resource
class_name Stats

## IMPORTANT! Value needs to be a float! The key is the name of the stat
@export var stats : Dictionary = {
	"Attack" : 6,
	"Defense" : 8,
	"Speed" : 5,
	"Luck" : 7
}

func save_stats(entity_name_or_ID : String):
	var save_file = FileAccess.open("user://" + entity_name_or_ID + "_stats.save", FileAccess.WRITE)
	save_file.store_var(stats)
	save_file.close();
	print("file saved to " + "user://" + entity_name_or_ID + "_stats.save")

func load_stats(entity_name_or_ID : String):
	var save_file = FileAccess.open("user://" + entity_name_or_ID + "_stats.save", FileAccess.READ)
	if FileAccess.file_exists("user://" + entity_name_or_ID + "_stats.save"):
		var loaded_stats = save_file.get_var()
		save_file.close()
		print("file opened: " + "user://" + entity_name_or_ID + "_stats.save")
		stats = loaded_stats
		return loaded_stats
