# ----------------------------------------------
#            ~{ GitHub Integration }~
# [Author] Nicolò "fenix" Santilio 
# [github] fenix-hub/godot-engine.github-integration
# [version] 0.2.9
# [date] 09.13.2019





# -----------------------------------------------

tool
extends Control


onready var _message = $VBoxContainer2/HBoxContainer7/message
#onready var _file = $VBoxContainer/HBoxContainer/file
onready var _branch = $VBoxContainer2/HBoxContainer2/branch
onready var file_chooser = $FileDialog
onready var repository = $VBoxContainer2/HBoxContainer/repository
onready var _filters = $VBoxContainer2/HBoxContainer6/filters
onready var _only = $VBoxContainer2/HBoxContainer8/only
onready var Loading = $VBoxContainer2/loading2
onready var _start_from = $VBoxContainer2/HBoxContainer9/start_from

onready var Gitignore = $VBoxContainer2/HBoxContainer3/VBoxContainer2/gitignore
onready var gitignoreBtn = $VBoxContainer2/HBoxContainer3/VBoxContainer2/girignorebuttons/gitignoreBtn
onready var about_gitignoreBtn = $VBoxContainer2/HBoxContainer3/VBoxContainer2/girignorebuttons/about_gitignoreBtn

onready var SelectFiles = $ChooseFile
onready var selectfilesBtn = $VBoxContainer2/HBoxContainer3/VBoxContainer/HBoxContainer/choosefilesBtn
onready var removefileBtn = $VBoxContainer2/HBoxContainer3/VBoxContainer/HBoxContainer/removefileBtn
onready var selectdirectoryBtn = $VBoxContainer2/HBoxContainer3/VBoxContainer/HBoxContainer/choosedirectoryBtn

onready var Progress = $VBoxContainer2/ProgressBar

onready var Uncommitted = $VBoxContainer2/HBoxContainer3/VBoxContainer/uncommitted

enum REQUESTS { UPLOAD = 0, UPDATE = 1, BLOB = 2 , LATEST_COMMIT = 4, BASE_TREE = 5, NEW_TREE = 8, NEW_COMMIT = 6, PUSH = 7, COMMIT = 9, END = -1 }
var requesting
var new_repo = HTTPRequest.new()

var repo_selected
var branches = []
var branches_contents = []
var branch_idx = 0

var files : Array = []
var directories = []

onready var error = $VBoxContainer2/error

var sha_latest_commit 
var sha_base_tree
var sha_new_tree
var sha_new_commit

var list_file_sha = []

var gitignore_file : Dictionary

const DIRECTORY : String = "res://"
var EXCEPTIONS : PoolStringArray = []           # don't commit this stuff
var ONLY : PoolStringArray = []                 # commit only this stuff
var START_FROM : String = ""
const GITIGNOREPATH : String = "user://gitignores/"

var IGNORE_FILES : PoolStringArray = []
var IGNORE_FOLDERS : PoolStringArray = []

signal blob_created()

signal latest_commit()
signal base_tree()
signal new_commit()
signal new_tree()
signal file_blobbed()
signal file_committed()
signal pushed()
signal files_filtered()

func _ready():
	new_repo.use_threads = true
	connect_signals()
	
	Loading.hide()
	call_deferred("add_child",new_repo)
	error.hide()
	
	removefileBtn.set_disabled(true)


func connect_signals():
	new_repo.connect("request_completed",self,"request_completed")
	_branch.connect("item_selected",self,"selected_branch")
	gitignoreBtn.connect("toggled",self,"on_gitignore_toggled")
	selectfilesBtn.connect("pressed",self,"on_selectfiles_pressed")
#	SelectFiles.connect("confirmed",self,"on_confirm")
	SelectFiles.connect("files_selected",self,"on_files_selected")
	Uncommitted.connect("item_selected",self,"on_item_selected")
	removefileBtn.connect("pressed",self,"on_removefile_pressed")
	Uncommitted.connect("nothing_selected",self,"on_nothing_selected")
	SelectFiles.connect("dir_selected",self,"on_dir_selected")
	selectdirectoryBtn.connect("pressed",self,"on_selectdirectory_pressed")
	about_gitignoreBtn.connect("pressed",self,"about_gitignore_pressed")

func request_completed(result, response_code, headers, body ):
#	print(response_code," ",JSON.parse(body.get_string_from_utf8()).result)
	if result == 0:
		match requesting:
			REQUESTS.UPLOAD:
				if response_code == 201:
					hide()
					print(get_parent().plugin_name,"commited and pushed...")
					get_parent().UserPanel.request_repositories(get_parent().UserPanel.REQUESTS.UP_REPOS)
				elif response_code == 422:
					error.text = "Error: "+JSON.parse(body.get_string_from_utf8()).result.errors[0].message
					error.show()
			REQUESTS.UPDATE:
				if response_code == 200:
					pass
			REQUESTS.COMMIT:
				if response_code == 201:
					print(get_parent().plugin_name,"file committed!")
					print(get_parent().plugin_name," ")
					emit_signal("file_committed")
				if response_code == 200:
					print(get_parent().plugin_name,"file updated!")
					print(get_parent().plugin_name," ")
					emit_signal("file_committed")
				if response_code == 422:
					print(get_parent().plugin_name,"file already exists, skipping...")
					print(get_parent().plugin_name," ")
					emit_signal("file_committed")
			REQUESTS.LATEST_COMMIT:
				if response_code == 200:
					sha_latest_commit = JSON.parse(body.get_string_from_utf8()).result.object.sha
					print(get_parent().plugin_name,"got last commit")
					emit_signal("latest_commit")
			REQUESTS.BASE_TREE:
				if response_code == 200:
					sha_base_tree = JSON.parse(body.get_string_from_utf8()).result.tree.sha
					print(get_parent().plugin_name,"got base tree")
					emit_signal("base_tree")
			REQUESTS.BLOB:
				if response_code == 201:
					list_file_sha.append(JSON.parse(body.get_string_from_utf8()).result.sha)
					print(get_parent().plugin_name,"blobbed file")
#					OS.delay_msec(1000)
					emit_signal("file_blobbed")
			REQUESTS.NEW_TREE:
				if response_code == 201:
						sha_new_tree = JSON.parse(body.get_string_from_utf8()).result.sha
						print(get_parent().plugin_name,"created new tree of files")
						emit_signal("new_tree")
			REQUESTS.NEW_COMMIT:
				if response_code == 201:
					sha_new_commit = JSON.parse(body.get_string_from_utf8()).result.sha
					print(get_parent().plugin_name,"created new commit")
					emit_signal("new_commit")
			REQUESTS.PUSH:
				if response_code == 200:
					print(get_parent().plugin_name,"pushed and committed with success!")
					get_parent().loading(false)
					Loading.hide()
					emit_signal("pushed")

func load_branches(br : Array, s_r : Dictionary, ct : Array, gitignore : Dictionary) :
	_branch.clear()
	repo_selected = s_r
	branches_contents = ct
	branches = br
	for branch in branches:
		_branch.add_item(branch.name)
	
	gitignore_file = gitignore
	
	if gitignore:
		Gitignore.set_text(Marshalls.base64_to_utf8(gitignore.content))
	
	repository.set_text(repo_selected.name+"/"+_branch.get_item_text(branch_idx))

func selected_branch(id : int):
	branch_idx = id
	repository.set_text(repo_selected.name+"/"+_branch.get_item_text(branch_idx))

# |---------------------------------------------------------|

func _on_Button_pressed():
#	Loading.show()
	get_parent().loading(true)
	
	load_gitignore()
	print(get_parent().plugin_name,"fetching all files in project...")
	
	
	request_sha_latest_commit()

# ------- gitignore ----
func load_gitignore():
	var gitignore_filepath = GITIGNOREPATH+repo_selected.name+"/"+_branch.get_item_text(branch_idx)+"/"
	
	var dir = Directory.new()
	if not dir.dir_exists(gitignore_filepath):
		dir.make_dir_recursive(gitignore_filepath)
		get_parent().print_debug_message(0,"made directory in user folder for this .gitignore file, at %s"%gitignore_filepath)
	
	var ignorefile = File.new()
	var error = ignorefile.open(gitignore_filepath+"gitignore.txt",File.WRITE)
	for line in range(0,Gitignore.get_line_count()):
		var gitline = Gitignore.get_line(line)
		ignorefile.store_line(gitline)
		if gitline.begins_with("*"):
			IGNORE_FILES.append(gitline.lstrip("*."))
		elif gitline.ends_with("/"):
			IGNORE_FOLDERS.append(gitline.rstrip("/"))
		elif gitline.begins_with("#") or gitline.begins_with("!"):
			pass
	ignorefile.close()
	
	files.push_front(gitignore_filepath+"gitignore.txt")
	
	var filtered_files : Array = []
	
	for file in files:
		var filter_file = false
		
		if file in IGNORE_FILES or file.get_file() in IGNORE_FILES or file.get_extension() in IGNORE_FILES:
			continue
		else:
			for folder in IGNORE_FOLDERS:
				if file.get_base_dir() == folder or folder in file.get_base_dir():
					filter_file = true
		
		if not filter_file:
			filtered_files.append(file)
	
	files.clear()
	files = filtered_files
	files.push_front(gitignore_filepath+"gitignore.txt")
	emit_signal("files_filtered")

# |---------------------------------------------------------|

func request_sha_latest_commit():
	requesting = REQUESTS.LATEST_COMMIT
	new_repo.request("https://api.github.com/repos/"+UserData.USER.login+"/"+repo_selected.name+"/git/refs/heads/"+_branch.get_item_text(branch_idx),UserData.header,false,HTTPClient.METHOD_GET,"")
	yield(self,"latest_commit")
	request_base_tree()

func request_base_tree():
	requesting = REQUESTS.BASE_TREE
	new_repo.request("https://api.github.com/repos/"+UserData.USER.login+"/"+repo_selected.name+"/git/commits/"+sha_latest_commit,UserData.header,false,HTTPClient.METHOD_GET,"")
	yield(self,"base_tree")
	request_blobs()

func request_blobs():
	requesting = REQUESTS.BLOB
	list_file_sha.clear()
	
	for file in files:
		var content = ""
		var sha = "" # is set to update a file
		
		## this cases are not really necessary, will be used in future versions
		
		if file.get_extension()=="png" or file[0].get_extension()=="jpg":
			## for images
			var img_src = File.new()
			img_src.open(file,File.READ)
			content = Marshalls.raw_to_base64(img_src.get_buffer(img_src.get_len()))
			
		elif file.get_extension()=="ttf":
			## for fonts
			var font = File.new()
			font.open(file,File.READ)
			content = Marshalls.raw_to_base64(font.get_buffer(font.get_len()))
		else:
			## for readable files
			var f = File.new()
			f.open(file,File.READ)
			content = Marshalls.raw_to_base64(f.get_buffer(f.get_len()))
		
#		for content in branches_contents:
#			if content.path == file[0].lstrip(DIRECTORY+START_FROM+"/"):
#				sha = content.sha
		
		print(get_parent().plugin_name,"blobbing ~> "+file.get_file())
		
		var bod = {
			"content":content,
			"encoding":"base64",
		}
		
		new_repo.request("https://api.github.com/repos/"+UserData.USER.login+"/"+repo_selected.name+"/git/blobs",UserData.header,false,HTTPClient.METHOD_POST,JSON.print(bod))
		yield(self,"file_blobbed")
		
		Progress.set_value(range_lerp(files.find(file),0,files.size(),0,100))
	
	print(get_parent().plugin_name,"blobbed each file with success, start committing...")
	Progress.set_value(100)
	request_commit_tree()

func request_commit_tree():
	requesting = REQUESTS.NEW_TREE
	var tree = []
	for i in range(0,files.size()):
		if files[i].get_file() == "gitignore.txt":
			tree.append({
					"path":".gitignore",
					"mode":"100644",
					"type":"blob",
					"sha":list_file_sha[i],
					})
		else:
			tree.append({
				"path":files[i].right((DIRECTORY).length()),
				"mode":"100644",
				"type":"blob",
				"sha":list_file_sha[i],
				})
	
	var bod = {
		"base_tree": sha_base_tree,
		"tree":tree
		}
	
	new_repo.request("https://api.github.com/repos/"+UserData.USER.login+"/"+repo_selected.name+"/git/trees",UserData.header,false,HTTPClient.METHOD_POST,JSON.print(bod))
	yield(self,"new_tree")
	request_new_commit()

func request_new_commit():
	requesting = REQUESTS.NEW_COMMIT
	var message = _message.text
	var bod = {
		"parents": [sha_latest_commit],
		"tree": sha_new_tree,
		"message": message
		}

	new_repo.request("https://api.github.com/repos/"+UserData.USER.login+"/"+repo_selected.name+"/git/commits",UserData.header,false,HTTPClient.METHOD_POST,JSON.print(bod))
	yield(self,"new_commit")
	request_push_commit()

func request_push_commit():
	requesting = REQUESTS.PUSH
	var bod = {
		"sha": sha_new_commit
		}
	new_repo.request("https://api.github.com/repos/"+UserData.USER.login+"/"+repo_selected.name+"/git/refs/heads/"+_branch.get_item_text(branch_idx),UserData.header,false,HTTPClient.METHOD_POST,JSON.print(bod))
	yield(self,"pushed")
	
	empty_fileds()
	Progress.set_value(0)
	get_parent().Repo._on_reload_pressed()

# --------------------------------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


func _on_filters_pressed():
	$filters_dialog.popup()


func _on_only_pressed():
	$only_dialog.popup()

func _on_start_from_pressed():
	$start_from.popup()

func _on_loading2_visibility_changed():
	var Mat = Loading.get_material()
	if Loading.visible:
		Mat.set_shader_param("speed",5)
	else:
		Mat.set_shader_param("speed",0)

func _on_close2_pressed():
	empty_fileds()
	hide()
	get_parent().Repo.show()

func empty_fileds():
	files.clear()
	directories.clear()
	sha_latest_commit = ""
	sha_base_tree = ""
	sha_new_tree = ""
	sha_new_commit = ""
	list_file_sha.clear()
	EXCEPTIONS.resize(0)
	IGNORE_FILES.resize(0)
	IGNORE_FOLDERS.resize(0)
	ONLY.resize(0)
	START_FROM = ""
	
	_filters.text = ""
	_only.text = ""
	_start_from.text = ""
	
	_message.text = ""
	
	Uncommitted.clear()
	
#	hide()
#	get_parent().Repo.show()

func on_gitignore_toggled(toggle : bool):
	Gitignore.set_readonly(!toggle)

func on_confirm():
	pass

func on_files_selected(paths : PoolStringArray):
	for path in paths:
		if not files.has(path):
			files.append(path)
		else:
			files.erase(path)
	
	show_files(paths,true,false)

func on_dir_selected(path : String):
	var directories = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true,false)
	var file = dir.get_next()
	while (file != ""):
		if dir.current_is_dir():
			var directorypath = dir.get_current_dir()+"/"+file
			directories.append(directorypath)
		else:
			var filepath = dir.get_current_dir()+"/"+file
			if not files.has(filepath):
				files.append(filepath)
		
		file = dir.get_next()
	
	dir.list_dir_end()
	
	show_files(files,true,false)
	
	for directory in directories:
		on_dir_selected(directory)

func show_files(paths : PoolStringArray, isfile : bool = false , isdir : bool = false):
	Uncommitted.clear()
	
	for file in files:
		if isfile:
			Uncommitted.add_item(file,IconLoaderGithub.load_icon_from_name("file"))
	
#	if isdir:
#		for dir in paths:
#			Uncommitted.add_item(dir,IconLoaderGithub.load_icon_from_name("dir"))

func on_removefile_pressed():
	var filestoremove = Uncommitted.get_selected_items()
	for file in filestoremove:
		var file_name = Uncommitted.get_item_text(file)
		files.erase(file_name)
		Uncommitted.remove_item(file)

func on_selectfiles_pressed():
	SelectFiles.set_mode(FileDialog.MODE_OPEN_FILES)
	SelectFiles.invalidate()
	SelectFiles.popup()

func on_selectdirectory_pressed():
	SelectFiles.set_mode(FileDialog.MODE_OPEN_DIR)
	SelectFiles.invalidate()
	SelectFiles.popup()

func on_item_selected(idx : int):
	removefileBtn.set_disabled(true)

func on_nothing_selected():
	removefileBtn.set_disabled(false)

func about_gitignore_pressed():
	OS.shell_open("https://git-scm.com/docs/gitignore")
