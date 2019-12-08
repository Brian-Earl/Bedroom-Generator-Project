extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (int) var width;
export (int) var height;

var roomArr = [];
var roomType;
enum ROOM{
	Bedroom
	}
	
enum ROOM_OBJ{
	nothing,
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
	
	


func make_2d_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
