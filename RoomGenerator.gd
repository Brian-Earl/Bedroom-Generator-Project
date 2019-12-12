extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (int) var width;
export (int) var height;

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
		
	makeRug(roomArr, 1,1);
	makeBed(roomArr, 1,4);
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
	grammarTest["bedsentence"] 	= ["The bed has #colour# sheets with a #pillowFeel# pillow."]
	grammarTest["pillowFeel"] 		= ["soft", "hard", "flat", "lumpy", "cool", "warm"]
	grammarTest["colour"]		= ["#tone# #baseColour#"]
	grammarTest["tone"] 		= ["dark", "light", "pale"]
	grammarTest["baseColour"] 	= ["red", "green", "blue", "yellow"]
	var grammar = Tracery.Grammar.new(grammarTest)
	
	grammar.addModifiers(Tracery.UniversalModifiers.getModifiers())
	
	var desc = grammar.flatten("#bedsentence#");
	return desc;


func makeBed(var array, var startx, var starty):
		
		var orientation = randi() % 2;
		var placeable = true;
		if(orientation == 0):
			if(startx > 0 && starty > 0):
				if(startx + 1 < width-1 && starty+2 < height - 1):
					var newObj = roomBible.duplicate(true);
					for x in [startx, startx+1, startx + 2]:
						for y in [starty, starty+1]:
							if(placeable):
								if(typeof(array[y][x]) != TYPE_NIL):
									if(array[y][x].get("Override", true) == true):
										placeable = true;
									else:
										placeable = false;
					if(placeable):
						for x in [startx, startx+1]:
							for y in [starty, starty+1, starty + 2]:
								array[y][x] = editDict(newObj,"bed", "b", ["big", "blue"], "big blue", "view", false);
					else:
						makeBed(array,startx,starty);
						print("overlap");
				else:
					makeBed(array,startx,starty);
					print("can't fit");		
		elif(orientation == 1):
			if(startx > 0 && starty > 0):
				if(startx + 2 < width-1 && starty+1 < height - 1):
					var newObj = roomBible.duplicate(true);
				
					for x in [startx, startx+1, startx + 2]:
						for y in [starty, starty+1]:
							if(placeable):
								if(typeof(array[y][x]) != TYPE_NIL):
									if(array[y][x].get("Override", true) == true):
										placeable = true;
									else:
										placeable = false;
					if(placeable):
						for x in [startx, startx+1, startx + 2]:
							for y in [starty, starty+1]:
								array[y][x] = editDict(newObj,"bed", "b", ["big", "blue"], "big blue", "view", false);
					else:
						makeBed(array,startx,starty);
						print("overlap");
				else:
					makeBed(array,startx,starty);
					print("can't fit");	
					
func makeRug(var array, var startx, var starty):
		
		var orientation = randi() % 2;
		if(orientation == 0):
			if(startx > 0 && starty > 0):
				if(startx + 2 < width-1 && starty+2 < height - 1):
					var newObj = roomBible.duplicate(true);
					for x in [startx, startx+1, startx + 2]:
						for y in [starty, starty+1, starty + 2]:
							if(typeof(array[y][x]) == TYPE_NIL):
								array[y][x] = editDict(newObj,"rug", "r", ["big", "blue"], "big blue", "view", true);
					
					
		elif(orientation == 1):
			if(startx > 0 && starty > 0):
				if(startx + 2 < width-1 && starty+2 < height - 1):
					var newObj = roomBible.duplicate(true);
					for x in [startx, startx+1, startx + 2]:
						for y in [starty, starty+1, starty + 2]:
							if(typeof(array[y][x]) == TYPE_NIL):
								array[y][x] = editDict(newObj,"rug", "r", ["big", "blue"], "big blue", "view", true);
					
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
