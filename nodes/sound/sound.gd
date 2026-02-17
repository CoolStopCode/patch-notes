extends Node2D

signal actuate_output(port : int)

@export var base_node : Node

@export var audio_node : AudioStreamPlayer
@export var waveform_node : Node2D
@export var waveform_texture : Texture

@export var VU_COUNT_VALUE := 14
@export var FREQ_MAX_VALUE := 10000.0
@export var TIME_SLICE_VALUE := 0.05
@export var WAVEFORM_POW := 1.5

@export var waveform_count := 14
@export var waveform_node_width := 1
@export var waveform_left := -7
@export var audio_file : AudioStream

var waveform_nodes : Array[Sprite2D] = []
var spectra := []
var playing := false
var playhead := 0.0
var properties : Array[InspectorProperty]

func _process(delta: float) -> void:
	if not playing: return
	playhead += delta *  properties[2].value
	var frame_int := int(floor(playhead / TIME_SLICE_VALUE))
	
	for point in range(VU_COUNT_VALUE):
		if frame_int >= spectra.size():
			playing = false
			return
		waveform_nodes[point].scale.y = round(pow(spectra[frame_int][point - 1], WAVEFORM_POW) / 2) * 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	properties = base_node.properties
	audio_node.stream = load(properties[0].path) if properties[0].path else audio_file
	Constants.clear_children(waveform_node)
	for i in range(waveform_count):
		var node := Sprite2D.new()
		node.texture = waveform_texture
		node.position = Vector2((i * waveform_node_width) + waveform_left + 0.5, 0)
		node.scale.y = 0
		waveform_node.add_child(node)
		waveform_nodes.append(node)
	
	spectra = compile_waveform(
		audio_file,
		TIME_SLICE_VALUE, 
		VU_COUNT_VALUE, 
		FREQ_MAX_VALUE
	)

func property_changed(property : InspectorProperty):
	if property == properties[0]:
		audio_file = load(property.path)
		audio_node.stream = audio_file
		if (audio_file is AudioStreamWAV)\
		 and (audio_file.format == AudioStreamWAV.FORMAT_8_BITS\
		 or audio_file.format == AudioStreamWAV.FORMAT_16_BITS):
			spectra = compile_waveform(
				audio_file,
				TIME_SLICE_VALUE, 
				VU_COUNT_VALUE, 
				FREQ_MAX_VALUE
			)
		else:
			spectra = generate_random_waveform(
				TIME_SLICE_VALUE,
				VU_COUNT_VALUE,
				audio_file.get_length()
			)

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	audio_node.pitch_scale = properties[2].value
	audio_node.volume_linear = properties[1].value
	audio_node.play()
	playhead = 0.0
	playing = true
	emit_output(0)

func generate_random_waveform(
	TIME_SLICE: float,
	VU_COUNT: int,
	length: float # seconds
) -> Array:
	var output: Array = []
	var slice_count := int(ceil(length / TIME_SLICE))
	
	# Setup noise for smooth transitions between slices
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.1 # Adjust for "speed" of change
	
	for slice_i in range(slice_count):
		var magnitudes: Array = []
		magnitudes.resize(VU_COUNT)
		
		for f_i in range(VU_COUNT):
			# Get a noise value between 0.0 and 1.0
			# We use f_i and slice_i as coordinates to ensure 
			# the "sound" is continuous across time and frequency.
			var n = (noise.get_noise_2d(float(f_i) * 2.0, float(slice_i)) + 1.0) / 2.0
			
			# Apply a curve so lower frequencies tend to have more "energy"
			# mimicking real audio spectra.
			var freq_bias = lerp(1.0, 0.3, float(f_i) / VU_COUNT)
			var val = n * freq_bias
			
			var t := float(slice_i) / float(slice_count)   # 0 → 1
			var falloff := 1.0 - t                        # 1 → 0 (linear)
			# Apply the same power curve used in your compiler for consistency
			magnitudes[f_i] = pow(val * 4, WAVEFORM_POW * 1.15) * falloff
			
		output.append(magnitudes)
	
	var silence: Array = []
	silence.resize(VU_COUNT)
	silence.fill(0.0)
	
	output.append(silence)
	
	return output

func compile_waveform(
	wav: AudioStreamWAV,
	TIME_SLICE: float,
	VU_COUNT: int,
	FREQ_MAX: float
) -> Array:

	var output: Array = []

	var sample_rate := wav.get_mix_rate()
	var pcm: PackedByteArray = wav.get_data()

	var bytes_per_sample := 2
	var channel_count := 2 if wav.is_stereo() else 1
	var total_samples := float(pcm.size()) / (bytes_per_sample * channel_count)

	var samples_per_slice := int(TIME_SLICE * sample_rate)
	if samples_per_slice <= 0:
		return []

	var slice_count := int(ceil(float(total_samples) / samples_per_slice))

	# --- Log-spaced frequency bins (no DC) ---
	var min_freq := 60.0
	var freqs := []
	for i in range(VU_COUNT):
		var t := float(i) / (VU_COUNT - 1)
		freqs.append(exp(lerp(log(min_freq), log(FREQ_MAX), t)))

	# --- MAIN LOOP ---
	for slice_i in range(slice_count):

		var slice_start := slice_i * samples_per_slice
		if slice_start >= total_samples:
			break

		var slice := PackedFloat32Array()
		slice.resize(samples_per_slice)

		# --- Load slice + remove DC ---
		var mean := 0.0

		for n in range(samples_per_slice):

			var idx := slice_start + n
			if idx >= total_samples:
				break

			var base := idx * bytes_per_sample * channel_count
			var sample := 0.0

			for c in range(channel_count):
				var lo := pcm[base + c * 2]
				var hi := pcm[base + c * 2 + 1]
				var s := (hi << 8) | lo
				if s & 0x8000:
					s -= 0x10000
				sample += float(s) / 32768.0

			sample /= channel_count
			slice[n] = sample
			mean += sample

		mean /= samples_per_slice

		for i in range(samples_per_slice):
			slice[i] -= mean

		# --- Hann window ---
		for i in range(samples_per_slice):
			var w := 0.5 * (1.0 - cos(TAU * i / (samples_per_slice - 1)))
			slice[i] *= w

		# --- Frequency analysis ---
		var magnitudes := []
		magnitudes.resize(VU_COUNT)
		magnitudes.fill(0.0)

		for f_i in range(VU_COUNT):

			var freq = freqs[f_i]
			var real := 0.0
			var imag := 0.0

			for n in range(samples_per_slice):
				var angle = TAU * freq * n / sample_rate
				real += slice[n] * cos(angle)
				imag -= slice[n] * sin(angle)

			magnitudes[f_i] = sqrt(real * real + imag * imag)

		# --- Noise floor ---
		var noise_floor := 0.005

		for i in range(VU_COUNT):
			if magnitudes[i] < noise_floor:
				magnitudes[i] = 0.0

		# --- Dynamic range compression (visual smoothing) ---
		for i in range(VU_COUNT):
			magnitudes[i] = pow(magnitudes[i], 0.5)

		output.append(magnitudes)

	# --- Append silence frame ---
	var silence: Array = []
	silence.resize(VU_COUNT)
	silence.fill(0.0)
	output.append(silence)

	# ==========================================================
	# GLOBAL NORMALIZATION (Peak = 3.0)
	# ==========================================================

	var global_max := 0.0

	for slice in output:
		for v in slice:
			if v > global_max:
				global_max = v

	if global_max > 0.0:
		var scaler := 6.0 / global_max

		for s in range(output.size()):
			for i in range(output[s].size()):
				output[s][i] *= scaler

	return output
