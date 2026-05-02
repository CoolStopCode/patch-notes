extends Node

const SITE : String = "https://coolstopcode.github.io/PatchNodeExtensions/"
var EXTENSION_LIST : ExtensionList

func download_extension(url : String, root_name : String):
	var request := HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_download_completed.bind(root_name))
	request.request(url)

func _on_download_completed(result, response_code, headers, body, root_name: String):
	if response_code != 200:
		print("Failed to download extension")
		return
	
	var path := _save_pck(body, root_name)
	if path == "":
		return
	
	if not _mount_pck(path):
		return
	
	var extension = _load_extension(root_name)
	if extension == null:
		return
	
	_register_extension(extension, path, root_name)

func _save_pck(body: PackedByteArray, root_name: String) -> String:
	var path := FileManager.EXTENSIONS_PATH.path_join(root_name + ".pck")
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if not file:
		push_error("Failed to write extension: " + root_name)
		return ""
	
	file.store_buffer(body)
	file.close()
	return path

func _mount_pck(path: String) -> bool:
	print("LOADING ", path)
	
	var success = ProjectSettings.load_resource_pack(path)
	if not success:
		push_error("Failed to mount extension: " + path)
		return false
	
	return true

func _load_extension(root_name: String):
	var extension = load("res://" + root_name + "/list.tres")
	
	if not extension:
		push_error("No list.tres found in root: " + root_name)
		return null
	
	return extension

func _register_extension(extension, path: String, root_name: String) -> void:
	EXTENSION_LIST.extension_list.append(extension)
	ConfigManager.new_extension_data(path, root_name)
	
	print("Extension installed and mounted to root: " + root_name)

func build_extension_list():
	EXTENSION_LIST = ExtensionList.new()
	for extension_data_dict in ConfigManager.extension_data_list:
		var extension_data = ConfigManager.ExtensionData.from_dict(extension_data_dict)
		var success = ProjectSettings.load_resource_pack(extension_data.path)
		if not success:
			push_error("Failed to mount extension: " + extension_data.path)
			return
		EXTENSION_LIST.extension_list.append(load("res://" + extension_data.root_name + "/list.tres"))

func install_embedded_extensions():
	download_extension(SITE + "extensions/control.pck", "control")
	download_extension(SITE + "extensions/input.pck", "input")
	download_extension(SITE + "extensions/output.pck", "output")
	download_extension(SITE + "extensions/other.pck", "other")
