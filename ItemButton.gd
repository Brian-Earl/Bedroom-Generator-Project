extends Button

var desc

func _pressed():
	emit_signal("pressed", desc)

func set_desc(new_desc):
	desc = new_desc