extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (int) var width;
export (int) var height;
var perimeter = ((2*(width - 1)) + (2*(height - 3)));

var roomArr = [];
var roomType;

var roomBible = {"name": " ", "Letter": " ", "KeyWords": [], "Desc": " ", "onClick":" ", "Override": " " }; 

onready var RoomDisplay = $"../FullDisplay/RoomDisplayer"
signal room_done

#var Bed = {"name": "bed", "Letter": "b", "KeyWords": ["blue", "Leather", "old"], "Desc": "This is a blue bed", "onClick": "examine"};
var test = roomBible.duplicate(true);
enum ROOM{
	Bedroom
	}
	
enum ROOM_OBJ{
	empty,
	bed
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize();
	connect("room_done", RoomDisplay, "displayRoom")
	roomArr = make_2d_array()
#	for arr in roomArr:
#		for item in arr:
#			print(item.get("Desc", "no dice"));
	randi() % perimeter+ 1;
	makeDesk(roomArr,1);
	makeBed(roomArr, 1);
	makeRug(roomArr, (randi()%width-3), (randi()%height-3));
	makeMirror(roomArr, 1);
	#print(roomArr);
	#print(roomArr);
	var randRoom = rand_range(2,1)
	
	if(randRoom == 1):
		roomType = ROOM.Bedroom;
	else:
		roomType = ROOM.Bedroom;
	
	#roomType = ROOM_OBJ.values().shuffle()
	#print(ROOM_OBJ.bed);
	#print(ROOM_OBJ.empty);
	
	
	emit_signal("room_done",roomArr)
	#print(test);


func make_2d_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			if(i == 0 and j==0):
				array[i].append(3);
			elif(i == width-1 and j==0):
				array[i].append(4)
			elif(i == 0 and j==height-1):
				array[i].append(5)
			elif(i == width-1 and j==height-1):
				array[i].append(6)
			elif(i == 0 or i == width-1):
				array[i].append(1);
			elif(j == 0 or j == height-1):
				array[i].append(2);
			else:
				 array[i].append(null);
	return array;


func fillRoom():
	var randObj = randi() % ROOM_OBJ.size();
	
	var newObj = roomBible.duplicate(true);
	if(randObj >= 1):
		return editDict(newObj,"bed", "b", ["big", "blue"], "big blue", "view");
		
	else:
		return null;


func editDict(var dictionary, var name = null, var letter = null, var keyword = null, var desc = null, var onClick = null, var over = null):
		if(name != null):
			dictionary["name"] = name;
		if(letter != null):
			dictionary["Letter"] = letter;
		if(keyword != null):
			dictionary["KeyWords"] = keyword;
		if(desc != null):
			dictionary["Desc"] = createDesc(dictionary);
		if(onClick != null):
			dictionary["onClick"] = onClick;
		if(over != null):
			dictionary["Override"] = over;	
		return dictionary;
	
func createDesc(var dictionary):
	# A simple grammar - or read from a JSON file
	var grammarTest = Dictionary()
	grammarTest["bedsentence"] = ["The bed has #colour# sheets with a #pillowFeel# pillow."]
	grammarTest["rugsentence"] = ["A #colour# #rugtype# rug."]
	grammarTest["desksentence"] = ["A #colour# #woodtype# desk."]
	grammarTest["mirrorsentence"] = ["A #mirrordesc# mirror #mirrorlocation#."]
	grammarTest["windowsentence"] = ["Just out the window is a view of #windowview#."]
	grammarTest["pillowFeel"] = ["soft", "hard", "flat", "lumpy", "cool", "warm"]
	grammarTest["colour"] = ["#tone# #baseColour#"]
	grammarTest["tone"] = ["dark", "light", "pale"]
	grammarTest["baseColour"] = ["red", "green", "blue", "yellow"]
	grammarTest["rugtype"] = ["shaggy", "wool", "silk", "Persian"]
	grammarTest["woodtype"] = ["maple","oak","walnut","birch", "mahogany"]
	grammarTest["mirrordesc"] = ["prestine", "clean", "dirty", "dusty", "scratched", "broken"]
	grammarTest["mirrorlocation"] = ["hangs on the wall", "stands tall here"]
	grammarTest["windowview"] = ["a clear blue lake","a busy highway", "an untouched patch of wilderness", "an open yard", "a family gathering", "a billboard blocking your once nice view", "Christmas carollers slowly approaching"]
	var grammar = Tracery.Grammar.new(grammarTest)
	
	grammar.addModifiers(Tracery.UniversalModifiers.getModifiers())
	
	var desc = grammar.flatten("#"+dictionary.name+"sentence#");
	return desc;


func makeBed(var array, orientation):
		#0 is vertical
		#1 is horizontal
		var startx = 0;
		var starty = 0;
		var placeable = true;
		
		var wallPlace = randi() % 4
		var orie = randi() % 2;
		
		if(wallPlace == 0):
			startx = randi() %(width-3) +1;
			starty = 1
			print("top", "x: ",startx, "y: ", starty);
		elif(wallPlace == 1):
			startx = 1;
			starty = randi() % (height - 2) + 1;
			print("LEft", "x: ", startx, "y: ", starty);	
		elif(wallPlace == 2):
			if(orie == 0):
				startx = randi() %(width-1) +1;
				starty = height - 4;
				print("bot vert", "x: ", startx, "y: ", starty);
			else:
				startx = randi() %(width-1) +1;
				starty = height - 3;
				print("bot hori", "x: ", startx, "y: ", starty);
		elif(wallPlace == 3):
			if(orie == 0):
				startx = width-3;
				starty = randi() % (height - 3) + 1;
				print("right vert", "x: " , startx, "y: " , starty);
			else:
				startx = width-4;
				starty = randi() % (height - 2) + 1;
				print("right hor", "x: " , startx, "y: " ,starty);
			
		if(orie == 0):
			if(startx > 0 && starty > 0):
				if(startx + 1 < width-1 && starty+2 < height - 1):
					var newObj = roomBible.duplicate(true);
					for x in [startx, startx+1, startx + 2]:
						for y in [starty, starty+1]:
							if(placeable):
								if(typeof(array[y][x]) != TYPE_NIL and typeof(array[y][x]) != 2):
									if(array[y][x].get("Override", true) == true):
										placeable = true;
									else:
										placeable = false;
					if(placeable):
						for x in [startx, startx+1]:
							for y in [starty, starty+1, starty + 2]:
								array[y][x] = editDict(newObj,"bed", "b", ["big", "blue"], "big blue", "view", false);
					else:
						makeBed(array,1);
						print("overlap");
				else:
					makeBed(array,1);
					print("can't fit");		
		elif(orie == 1):
			if(startx > 0 && starty > 0):
				if(startx + 2 < width-1 && starty+1 < height - 1):
					var newObj = roomBible.duplicate(true);
				
					for x in [startx, startx+1, startx + 2]:
						for y in [starty, starty+1]:
							if(placeable):
								if(typeof(array[y][x]) != TYPE_NIL && typeof(array[y][x])!= 2):
									if(array[y][x].get("Override", true) == true):
										placeable = true;
									else:
										placeable = false;
					if(placeable):
						for x in [startx, startx+1, startx + 2]:
							for y in [starty, starty+1]:
								array[y][x] = editDict(newObj,"bed", "b", ["big", "blue"], "big blue", "view", false);
					else:
						makeBed(array, 0);
						print("overlap");
				else:
					makeBed(array,0);
					print("can't fit");	
					
func makeRug(var array, var startx, var starty):
	if(startx > 0 && starty > 0):
		if(startx + 2 < width-1 && starty+2 < height - 1):
			var newObj = roomBible.duplicate(true);
			for x in [startx, startx+1, startx + 2]:
				for y in [starty, starty+1, starty + 2]:
					if(typeof(array[y][x]) == TYPE_NIL ):
						array[y][x] = editDict(newObj,"rug", "Checkerboard_2", ["big", "blue"], "big blue", "view", true);
#			if(startx - 1 > 0):
#				array[starty+1][startx -1] = editDict(newObj,"rug", "Checkerboard_2", ["big", "blue"], "big blue", "view", true);
#			if(starty - 1 > 0):
#				array[starty-1][startx +1] = editDict(newObj,"rug", "Checkerboard_2", ["big", "blue"], "big blue", "view", true);
#			if(startx +3 < width-1 ):
#				array[starty+1][startx +3] = editDict(newObj,"rug", "Checkerboard_2", ["big", "blue"], "big blue", "view", true);
#			if(starty +3 < height-1 ):
#				array[starty+3][startx +1] = editDict(newObj,"rug", "Checkerboard_2", ["big", "blue"], "big blue", "view", true);
			

func makeDesk(var array, orientation):
		#0 is vertical
		#1 is horizontal
		var startx = 0;
		var starty = 0;
		var placeable = true;
		
		var wallPlace = randi() % 4
		var orie = randi() % 2;
		
		if(wallPlace == 0):
			startx = randi() %(width-3) +1;
			starty = 1;
			orie = 1;
			print("top", "x: ",startx, "y: ", starty);
		elif(wallPlace == 1):
			startx = 1;
			starty = randi() % (height - 2) + 1;
			orie = 0
			print("LEft", "x: ", startx, "y: ", starty);	
		elif(wallPlace == 2):
			startx = randi() %(width-1) +1;
			starty = height - 2;
			orie = 1;
			print("bot hori", "x: ", startx, "y: ", starty);
		elif(wallPlace == 3):
			orie = 0;
			startx = width-2;
			starty = randi() % (height - 2) + 1;
			print("right vert", "x: " , startx, "y: " , starty);
			
		if(orie == 0):
			if(startx > 0 && starty > 0):
				if(startx + 0 < width-1 && starty+1 < height - 1):
					var newObj = roomBible.duplicate(true);
					for x in [startx]:
						for y in [starty, starty+1]:
							if(placeable):
								if(typeof(array[y][x]) != TYPE_NIL and typeof(array[y][x]) != 2):
									if(array[y][x].get("Override", true) == true):
										placeable = true;
									else:
										placeable = false;
					if(placeable):
						for x in [startx]:
							for y in [starty, starty+1, ]:
								array[y][x] = editDict(newObj,"desk", "d", ["big", "blue"], "big blue", "view", false);
					else:
						makeDesk(array,1);
						print("overlap");
				else:
					makeDesk(array,1);
					print("can't fit");		
		elif(orie == 1):
			if(startx > 0 && starty > 0):
				if(startx + 1 < width-1 && starty+0 < height - 1):
					var newObj = roomBible.duplicate(true);
				
					for x in [startx, startx+1]:
						for y in [starty]:
							if(placeable):
								if(typeof(array[y][x]) != TYPE_NIL && typeof(array[y][x])!= 2):
									if(array[y][x].get("Override", true) == true):
										placeable = true;
									else:
										placeable = false;
					if(placeable):
						for x in [startx, startx+1]:
							for y in [starty]:
								array[y][x] = editDict(newObj,"desk", "d", ["big", "blue"], "big blue", "view", false);
					else:
						makeDesk(array, 0);
						print("overlap");
				else:
					makeDesk(array,0);
					print("can't fit");	
					
func makeMirror(var array, orientation):
		#0 is vertical
		#1 is horizontal
		var startx = 0;
		var starty = 0;
		var placeable = true;
		
		var wallPlace = randi() % 4
		
		
		if(wallPlace == 0):
			startx = randi() %(width-1) +1;
			starty = 1;
			
			print("top", "x: ",startx, "y: ", starty);
		elif(wallPlace == 1):
			startx = 1;
			starty = randi() % (height - 1) + 1;
			
			print("LEft", "x: ", startx, "y: ", starty);	
		elif(wallPlace == 2):
			startx = randi() %(width-2) +1;
			starty = height - 2;
			
			print("bot hori", "x: ", startx, "y: ", starty);
		elif(wallPlace == 3):
			
			startx = width-2;
			starty = randi() % (height - 2) + 1;
			print("right vert", "x: " , startx, "y: " , starty);
			
		
		if(startx > 0 && starty > 0):
			if(startx + 0 < width-1 && starty+0 < height - 1):
				var newObj = roomBible.duplicate(true);
				for x in [startx]:
					for y in [starty]:
						if(placeable):
							if(typeof(array[y][x]) != TYPE_NIL and typeof(array[y][x]) != 2):
								if(array[y][x].get("Override", true) == true):
									placeable = true;
								else:
									placeable = false;
				if(placeable):
					for x in [startx]:
						for y in [starty ]:
							array[y][x] = editDict(newObj,"mirror", "m", ["big", "blue"], "big blue", "view", false);
				else:
					makeMirror(array,1);
					print("overlap");
			else:
				makeMirror(array,1);
				print("can't fit");		
		
					

					
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene("res://MainMenu.tscn")
