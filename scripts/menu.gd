extends Control

signal campaign
signal vs_cpu
signal vs_player
signal mute_music(muted)
signal mute_audio(muted)

var music_muted = false
var audio_muted = false

func _on_campaign_button_pressed():
	$ControlsPanel.visible = false
	campaign.emit()

func _on_vs_cpu_button_pressed():
	$ControlsPanel.visible = false
	vs_cpu.emit()

func _on_vs_player_button_pressed():
	$ControlsPanel.visible = false
	vs_player.emit()

func _on_controls_pressed():
	$ControlsPanel.visible = not $ControlsPanel.visible

func _on_mute_music_toggled(button_pressed):
	music_muted = button_pressed
	mute_music.emit(music_muted)

func _on_mute_audio_toggled(button_pressed):
	audio_muted = button_pressed
	mute_audio.emit(audio_muted)
