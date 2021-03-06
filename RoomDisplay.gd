extends ColorRect

onready var tileMap = get_node("TileMap")
onready var textDisplay = get_node("../TextDisplay")
var room;
signal send_disc

func displayRoom(var roomAr):
	room = roomAr;
	if tileMap == null:
		tileMap = get_node("TileMap")
	if textDisplay == null:
		textDisplay = get_node("../TextDisplay")
	tileMap.get_parent().rect_global_position.x = (1920/2) - (64 * roomAr.size()/2)
	var x = 0
	var y = 0
	for arr in roomAr:
		x = 0
		for item in arr:
			if(item != null):
				if(typeof(item) == 2 ):
					if(item == 1):
						tileMap.set_cell(x,y, tileMap.tile_set.find_tile_by_name("HorizontalBorder"))
					elif(item == 2):
						tileMap.set_cell(x,y, tileMap.tile_set.find_tile_by_name("VerticalBorder"))
					elif(item == 3):
						tileMap.set_cell(x,y, tileMap.tile_set.find_tile_by_name("TopLeftBorder"))
					elif(item == 5):
						tileMap.set_cell(x,y, tileMap.tile_set.find_tile_by_name("TopRightBorder"))
					elif(item == 4):
						tileMap.set_cell(x,y, tileMap.tile_set.find_tile_by_name("BottomLeftBorder"))
					elif(item == 6):
						tileMap.set_cell(x,y, tileMap.tile_set.find_tile_by_name("BottomRightBorder"))
				else:
					tileMap.set_cell(x,y, tileMap.tile_set.find_tile_by_name(item.get("Letter")))
					var button = Button.new()
					button.set_position(Vector2(x*64*tileMap.get_scale().x, y*64*tileMap.get_scale().y))
					button.set_size(Vector2(64*tileMap.get_scale().x,64*tileMap.get_scale().y))
					button.show()
					button.modulate = Color(255,255,255,0)
					button.connect("pressed",textDisplay,"changeText")
					button.set_script(load("res://ItemButton.gd"))
					button.set_desc(item.get("Desc"))
					add_child(button)
			x=x+1
		y=y+1
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
