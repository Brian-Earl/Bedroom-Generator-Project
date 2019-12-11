extends ColorRect

onready var tileMap = get_node("TileMap")
onready var text = get_node("RichTextLabel")

func changeText(new_text):
	print(new_text)
	text.set_text(new_text)