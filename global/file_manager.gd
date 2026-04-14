extends Node

const SITE : String = "https://coolstopcode.github.io/PatchNodeExtensions/"

var DOCUMENTS_PATH = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
var BASE_PATH = DOCUMENTS_PATH + "/patch_notes"
var EXTENSIONS_PATH = BASE_PATH + "/extensions"
var SOUNDS_PATH = BASE_PATH + "/sounds"
var PROJECTS_PATH = BASE_PATH + "/projects"

var EXTENSION_LIST : ExtensionList

func _ready() -> void:
	create_dir_if_not_exist(SOUNDS_PATH)
	create_dir_if_not_exist(PROJECTS_PATH)
	
	if not DirAccess.dir_exists_absolute(EXTENSIONS_PATH):
		DirAccess.make_dir_recursive_absolute(EXTENSIONS_PATH)
		initial_extension_setup()
	
	EXTENSION_LIST = load(EXTENSIONS_PATH + "/extension_list.tres")

func create_dir_if_not_exist(path : String):
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)

func download_extension(git_path : String, as_name : String):
	var request := HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_download_completed.bind(as_name))
	request.request(git_path)

func _on_download_completed(result, response_code, headers, body, as_name : String):
	if response_code != 200:
		print("Failed to download extension")
		return
	
	var zip_path = EXTENSIONS_PATH + ("/%s.zip" % as_name)
	var file = FileAccess.open(zip_path, FileAccess.WRITE)
	file.store_buffer(body)
	file.close()
	Constants.extract_zip(zip_path, EXTENSIONS_PATH)
	print("Extension extracted")
	
	EXTENSION_LIST.extension_list.append(
		load(EXTENSIONS_PATH + "/%s/list.tres" % as_name)
	)
	ResourceSaver.save(EXTENSION_LIST, EXTENSIONS_PATH + "/extension_list.tres")

func initial_extension_setup():
	var extension_list := ExtensionList.new()
	EXTENSION_LIST = extension_list
	ResourceSaver.save(EXTENSION_LIST, EXTENSIONS_PATH + "/extension_list.tres")
	
	download_extension(SITE + "extensions/control/control.zip", "control")
