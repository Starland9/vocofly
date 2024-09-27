extends CanvasLayer

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
			print(recording.get_length())

func set_progress_bar_value(value: float):
	progress_bar.value = value
