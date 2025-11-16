extends Stats
class_name StatsAndHealth

signal took_damage
signal gained_health
signal fully_restored
signal died

@export var max_hp = 100:
	set(new_value):
		stats["max_hp"] = new_value;
		max_hp = new_value;
@export var hp = 100;

func gain_health(amount : float):
	emit_signal("gained_health", amount)
	hp += amount;
	if hp > max_hp:
		emit_signal("fully_restored")
		hp =  stats["max_hp"];

func fully_restore():
	emit_signal("fully_restored")
	hp = stats["max_hp"];

func receive_damage(amount : float):
	emit_signal("took_damage", amount)
	hp -= amount
	if hp <= 0:
		emit_signal("died")

func save_hp(entity_name_or_ID : String):
	var save_file = FileAccess.open("user://" + entity_name_or_ID + "_hp.save", FileAccess.WRITE)
	save_file.store_var(hp)
	save_file.close();
	print("file saved to " + "user://" + entity_name_or_ID + "_hp.save")

func load_hp(entity_name_or_ID : String) -> float:
	var save_file = FileAccess.open("user://" + entity_name_or_ID + "_hp.save", FileAccess.READ)
	if FileAccess.file_exists("user://" + entity_name_or_ID + "_hp.save"):
		var loaded_hp = save_file.get_var()
		save_file.close()
		print("file opened: " + "user://" + entity_name_or_ID + "_hp.save")
		stats = loaded_hp
		return loaded_hp
	return stats["max_hp"]
