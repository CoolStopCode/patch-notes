extends Node

const SITE : String = "https://coolstopcode.github.io/PatchNodeExtensions/"

var DOCUMENTS_PATH = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
var BASE_PATH = DOCUMENTS_PATH + "/patch_notes"
var EXTENSIONS_PATH = BASE_PATH + "/extensions"
var SOUNDS_PATH = BASE_PATH + "/sounds"
var PROJECTS_PATH = BASE_PATH + "/projects"

func extract_zip(zip_path : String, dest_folder : String) -> String:
	var reader = ZIPReader.new()
	reader.open(zip_path)

	# Destination directory for the extracted files (this folder must exist before extraction).
	# Not all ZIP archives put everything in a single root folder,
	# which means several files/folders may be created in `root_dir` after extraction.
	var root_dir = DirAccess.open(dest_folder)

	var top_level_folders := {}
	var files = reader.get_files()
	for file_path in files:
		if file_path.begins_with("__MACOSX/"): continue
		var parts = file_path.split("/")
		if parts.size() > 0 and parts[0] != "":
			top_level_folders[parts[0]] = true # takes the root of each folder in the zip
		
		# If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)
	
	if top_level_folders.size() == 1: # if they all the same, then its the top
		return top_level_folders.keys()[0]
	else:
		print("Messy zip file, no root")
		print(top_level_folders)
		return ""

func copy_dir_recursive(from_path: String, to_path: String) -> void:
	var dir = DirAccess.open(from_path)

	# Create target directory if it doesn't exist
	if not DirAccess.dir_exists_absolute(to_path):
		DirAccess.make_dir_recursive_absolute(to_path)
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			# Recursively copy subdirectories
			copy_dir_recursive(from_path + "/" + file_name, to_path + "/" + file_name)
		else:
			# Copy individual files
			dir.copy(from_path + "/" + file_name, to_path + "/" + file_name)
		
		file_name = dir.get_next()

# Example Usage:
# copy_dir("res://source_folder", "user://destination_folder")


func _ready() -> void:
	create_dir_if_not_exist(SOUNDS_PATH)
	create_dir_if_not_exist(PROJECTS_PATH)
	
	if not DirAccess.dir_exists_absolute(EXTENSIONS_PATH):
		DirAccess.make_dir_recursive_absolute(EXTENSIONS_PATH)
		ExtensionManager.install_embedded_extensions()
	ConfigManager.load_config()
	ExtensionManager.build_extension_list()

func create_dir_if_not_exist(path : String):
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
