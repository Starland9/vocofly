extends CanvasLayer

signal onRecord(value: float)

@onready var progress_bar = $ProgressBar

var effect : AudioEffectRecord
var recording : AudioStreamWAV


func _ready() -> void:
	var record_idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(record_idx, 0)
	effect.set_recording_active(true)
	

func _process(_delta: float) -> void:
	if effect.is_recording_active():
		recording = effect.get_recording()
		if recording:
			var frequency = get_dominant_frequency(recording.data)
			print(frequency)
			

func set_progress_bar_value(value: float):
	progress_bar.value = value
	onRecord.emit(value)
	
func get_dominant_frequency(audio_data):
		# Paramètres de la FFT
	var sample_rate = 44100  # Fréquence d'échantillonnage
	var N = len(audio_data)  # Nombre d'échantillons
	
	

	# Implémentation simplifiée de la FFT (à remplacer par une bibliothèque plus performante)
	var result = FFT.fft(audio_data)
	var fft_result = FFT.fft(result)
	
	# Trouver l'indice de la fréquence maximale
	var max_amplitude = 0
	var max_index = 0
	for i in range(len(fft_result)):
		if _abs_complex(fft_result[i]) > max_amplitude:
			max_amplitude = _abs_complex(fft_result[i])
			max_index = i

	# Calculer la fréquence correspondante
	return max_index * sample_rate / N

func _abs_complex(c: FFT.Complex):
	return sqrt(c.re * c.re + c.im * c.im)
