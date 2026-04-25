extends Node

const SITE : String = "https://coolstopcode.github.io/PatchNodeExtensions/"
var EXTENSION_LIST : ExtensionList

func download_extension(url : String, root_name : String):
	var request := HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_download_completed.bind(root_name))
	request.request(url)

func _on_download_completed(result, response_code, headers, body, root_name : String):
	if response_code != 200:
		print("Failed to download extension")
		return
	
	# Write the downloaded bytes to a .pck file
	var path := FileManager.EXTENSIONS_PATH.path_join(root_name + ".pck")
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("Failed to write extension: " + root_name)
		return
	file.store_buffer(body)
	file.close()
	
	# Mount it immediately without needing a restart
	var success = ProjectSettings.load_resource_pack(path)
	if not success:
		push_error("Failed to mount extension: " + path)
		return
	
	var extension = load("res://" + root_name + "/list.tres")
	if not extension:
		push_error("No list.tres found in root: " + root_name)
		return
	
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
