extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (int) var width;
export (int) var height;

var roomArr = [];
var roomType;

var roomBible = {"name": "", "Letter": "", "KeyWords": [], "Desc": "", "onClick":"" }; 

var Bed = {"name": "bed", "Letter": "b", "KeyWords": ["blue", "Leather", "old"], "Desc": "This is a blue bed", "onClick": "examine"};
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
	roomArr = make_2d_array();
	print(roomArr);
	var randRoom = rand_range(1,2)
	
	if(randRoom == 1):
		roomType = ROOM.Bedroom;
	else:
		roomType = ROOM.Bedroom;
	
	#roomType = ROOM_OBJ.values().shuffle()
	print(ROOM_OBJ.bed);
	print(ROOM_OBJ.empty);
	
	test = editDict(test, "test", "T", ["test","test"], "This is a test", "view");
	print(test);


func make_2d_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(fillRoom());
	return array;


func fillRoom():
	var randObj = rand_range(0, ROOM_OBJ.size())
	
	if(randObj >= 1):
		return ROOM_OBJ.bed;
		
	else:
		return ROOM_OBJ.empty;
		

func editDict(var dictionary, var name = null, var letter = null, var keyword = null, var desc = null, var onClick = null):
		if(name != null):
			dictionary["name"] = name;
		if(letter != null):
			dictionary["letter"] = letter;
		if(keyword != null):
			dictionary["KeyWords"] = keyword;
		if(desc != null):
			dictionary["Desc"] = desc;
		if(onClick != null):
			dictionary["onClick"] = onClick;
			
		return dictionary;
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
