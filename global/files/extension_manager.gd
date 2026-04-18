extends Node

const SITE : String = "https://coolstopcode.github.io/PatchNodeExtensions/"

func download_extension(git_path : String, as_name : String):
	var request := HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_download_completed.bind(as_name))
	request.request(git_path)

func _on_download_completed(result, response_code, headers, body, as_name : String):
	if response_code != 200:
		print("Failed to download extension")
		return
	
	var zip_path = FileManager.EXTENSIONS_PATH.path_join(as_name + ".zip")
	var file = FileAccess.open(zip_path, FileAccess.WRITE)
	file.store_buffer(body)
	file.close()
	var extracted_root := FileManager.extract_zip(zip_path, FileManager.EXTENSIONS_PATH)
	DirAccess.remove_absolute(zip_path)
	
	var list_path = FileManager.EXTENSIONS_PATH.path_join(extracted_root).path_join("list.tres")
	var list = load(list_path)
	
	ConfigManager.add_default_pins(list)
	FileManager.EXTENSION_LIST.extension_list.append(
		list
	)

func install_embedded_extensions():
	FileManager.copy_dir_recursive("res://nodes/patch_notes", FileManager.EXTENSIONS_PATH)
	DirAccess.copy_absolute(
		"res://nodes".path_join("extension_list.tres"),
		FileManager.EXTENSIONS_PATH.path_join("extension_list.tres")
	)
	var list : ExtensionList = load(FileManager.EXTENSIONS_PATH.path_join("extension_list.tres"))
	for extension in list.extension_list:
		ConfigManager.add_default_pins(extension)

func rebuild_references_of_extension(extension : Extension):
	# loop through the extensions node_list
	for node_type in extension.node_list:
		pass

func rebuild_reference():
	# get resource_path of the resource
	# convert res:// path to global filesystem path
	# go to that location and set the resource there to a variable
	# go back to the reference and set it to that variable
	
	
	pass
