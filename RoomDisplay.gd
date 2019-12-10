extends ColorRect

onready var tileMap = get_node("TileMap")

func displayRoom(var roomAr):
	if tileMap == null:
		tileMap = get_node("TileMap")
	var x = 0
	var y = 0
	for arr in roomAr:
		x = 0
		for item in arr:
			if(item != null):
				if(typeof(item) == 2 && item == 1):
					tileMap.set_cell(x,y, tileMap.tile_set.find_tile_by_name("HorizontalBorder"))
				else:
					tileMap.set_cell(x,y, tileMap.tile_set.find_tile_by_name(item.get("Letter")))
			x=x+1
		y=y+1
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
