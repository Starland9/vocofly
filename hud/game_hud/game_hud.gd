extends CanvasLayer

signal onRecord(value: float)

@onready var progress_bar = $ProgressBar

var effect : AudioEffectRecord
var recording : AudioStreamWAV
var fft_thread : Thread = Thread.new()

const sample_rate = 44100.0  # Fréquence d'échantillonnage
const min_frequency = 80
const max_frequency = 3000



func _ready() -> void:
	var record_idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(record_idx, 0)
	effect.set_recording_active(true)
	fft_thread.start(_threaded_fft, Thread.PRIORITY_NORMAL )


func _process(_delta: float) -> void:
	pass

func set_progress_bar_value(value: float):
	progress_bar.value = value
	onRecord.emit(value)

func get_dominant_frequency(audio_data):
	# Utiliser seulement un sous-ensemble des données pour la FFT
	var window_size = 2048  # Fenêtre de 2048 échantillons
	var subset_data = audio_data.slice(0, min(window_size, len(audio_data)))
	
	# Implémentation simplifiée de la FFT (à remplacer par une bibliothèque plus performante)
	#var normalized_data = _normalize_audio(subset_data)
	var fft_result = FFT.fft(subset_data)
	

# Trouver la fréquence dominante dans le sous-ensemble
	var max_amplitude = 0
	var max_index = 0
	for i in range(1, len(fft_result)):
		var absx = _abs_complex(fft_result[i])
		if  absx > max_amplitude:
			max_amplitude = absx
			max_index = i
						
	return float(max_index) * sample_rate / float(window_size)

func _abs_complex(c: FFT.Complex):
	return sqrt(c.re * c.re + c.im * c.im)
	
func _remove_dc_offset(audio_data):
	var mean_value = 0
	for sample in audio_data:
		mean_value += sample
	mean_value /= len((audio_data))
	
	for i in range(len(audio_data)):
		audio_data[i] -= mean_value
	return audio_data

func _normalize_audio(audio_data):
	var max_value = 0
	for sample in audio_data:
		max_value = max(abs(sample), max_value)
		
	if max_value > 0:
		for i in range(len(audio_data)):
			audio_data[i] /= max_value
	return audio_data

func _on_fft_timer_timeout() -> void:
	pass
	

func _threaded_fft():
	while true:
		if effect.is_recording_active():
			recording = effect.get_recording()
			if recording:
				var data = recording.data
				data.reverse()
				var frequency = get_dominant_frequency(data)
				if min_frequency <= frequency and frequency <= max_frequency:
					print(frequency)
					call_deferred("set_progress_bar_value", frequency)
		await get_tree().create_timer(0.01).timeout	
