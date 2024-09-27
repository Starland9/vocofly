extends CanvasLayer

signal onRecord(value: float)

@onready var progress_bar = $ProgressBar

var effect : AudioEffectRecord
var recording : AudioStreamWAV

const sample_rate = 44100  # Fréquence d'échantillonnage



func _ready() -> void:
	var record_idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(record_idx, 0)
	effect.set_recording_active(true)


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
	var fft_result = FFT.fft(subset_data)

# Trouver la fréquence dominante dans le sous-ensemble
	var max_amplitude = 0
	var max_index = 0
	for i in range(len(fft_result)):
		if _abs_complex(fft_result[i]) > max_amplitude:
			max_amplitude = _abs_complex(fft_result[i])
			max_index = i

	return max_index * sample_rate / window_size

func _abs_complex(c: FFT.Complex):
	return sqrt(c.re * c.re + c.im * c.im)

func _on_fft_timer_timeout() -> void:
	if effect.is_recording_active():
		recording = effect.get_recording()
		if recording:
			var frequency = get_dominant_frequency(recording.data)
			print(frequency)
