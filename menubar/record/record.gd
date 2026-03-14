extends Control

@export var save_recording_popup : FileDialog
@export var record_button_texture : TextureRect
@export var record_button : Button
@export var accept_button : Button
@export var delete_button : Button
@export var waveform : ColorRect
@export var record_bg : TextureRect

@export var record_inactive : Texture
@export var record_active_1 : Texture
@export var record_active_2 : Texture

var record_effect: AudioEffectRecord
var analyze_effect: AudioEffectSpectrumAnalyzer
var master_bus_idx : int

var recording := false

func _on_record_pressed() -> void:
	if recording:
		recording = false
		record_bg.hide()
		waveform.hide()
		accept_button.show()
		delete_button.show()
		record_button.hide()
		end_recording()
		record_button_texture.texture = record_inactive
	else:
		recording = true
		record_bg.show()
		waveform.show()
		record_effect.set_recording_active(true)


func _on_accept_pressed() -> void:
	save_recording_popup.popup()
	accept_button.hide()
	delete_button.hide()
	record_button.show()


func _on_cancel_pressed() -> void:
	accept_button.hide()
	delete_button.hide()
	record_button.show()



func _ready():
	master_bus_idx = AudioServer.get_bus_index("Master")
	record_effect = AudioServer.get_bus_effect(master_bus_idx, 0)
	var documents_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	save_recording_popup.current_dir = documents_path

func end_recording():
	record_effect.set_recording_active(false)

func _process(delta: float) -> void:
	if recording:
		if int(floor(Constants.global_time * 3)) % 2 == 1:
			record_button_texture.texture = record_active_1
		else:
			record_button_texture.texture = record_active_2

		var left = AudioServer.get_bus_peak_volume_left_db(master_bus_idx, 0)
		var right = AudioServer.get_bus_peak_volume_right_db(master_bus_idx, 0)

		var loudness = max(left, right)

		waveform.size.x = floor(db_to_linear(loudness) * 11 )* 6
		waveform.position.x = 6 - (waveform.size.x - 66)

func _on_save_recording_file_selected(path: String) -> void:
	var wav_stream = record_effect.get_recording()
	wav_stream.save_to_wav(path)
