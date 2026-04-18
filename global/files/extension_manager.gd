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
	
	# Write the downloaded bytes to a .pck file
	var file = FileAccess.open(FileManager.EXTENSIONS_PATH.path_join(as_name + ".pck"), FileAccess.WRITE)
	if not file:
		push_error("Failed to write extension: " + as_name)
		return
	file.store_buffer(body)
	file.close()
	
	# Mount it immediately without needing a restart
	
	
	var extension = load("res://" + as_name + "/list.tres")
	if not extension:
		push_error("No list.tres found in extension: " + as_name)
		return
	
	FileManager.EXTENSION_LIST.extension_list.append(extension)
	FileManager.save_extension_list()
	
	print("Extension installed and mounted: " + as_name)
	
	#var zip_path = FileManager.EXTENSIONS_PATH.path_join(as_name + ".zip")
	#var file = FileAccess.open(zip_path, FileAccess.WRITE)
	#file.store_buffer(body)
	#file.close()
	#var extracted_root := FileManager.extract_zip(zip_path, FileManager.EXTENSIONS_PATH)
	#DirAccess.remove_absolute(zip_path)
	#
	#var list_path = FileManager.EXTENSIONS_PATH.path_join(extracted_root).path_join("list.tres")
	#var list = load(list_path)
	#
	#ConfigManager.add_default_pins(list)
	#FileManager.EXTENSION_LIST.extension_list.append(
		#list
	#)

func mount_extensions():
	for extension in FileManager.EXTENSION_LIST.extension_list:
		var success = ProjectSettings.load_resource_pack(FileManager.EXTENSIONS_PATH.path_join(as_name + ".pck"))
		if not success:
			push_error("Failed to mount extension: " + as_name)
			return

func install_embedded_extensions():
	#FileManager.copy_dir_recursive("res://nodes/patch_notes", FileManager.EXTENSIONS_PATH)
	#DirAccess.copy_absolute(
		#"res://nodes".path_join("extension_list.tres"),
		#FileManager.EXTENSIONS_PATH.path_join("extension_list.tres")
	#)
	#var list : ExtensionList = load(FileManager.EXTENSIONS_PATH.path_join("extension_list.tres"))
	#for extension in list.extension_list:
		#ConfigManager.add_default_pins(extension)
	var extension_list := ExtensionList.new()
	FileManager.EXTENSION_LIST = extension_list
	ResourceSaver.save(FileManager.EXTENSION_LIST, FileManager.EXTENSIONS_PATH + "/extension_list.tres")
	
	download_extension(SITE + "extensions/control.pck", "control")
