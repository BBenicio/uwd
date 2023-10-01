extends Control

var fight_countdown = 3:
	set(value):
		$FightCountdown.text = var_to_str(value) if value > 0 else 'FIGHT'
		$FightCountdown.visible = value >= 0
		fight_countdown = value

var total_rounds = 3
var current_round = 0:
	set(value):
		$RoundLabel.text = 'Round {0} of {1}'.format([value, total_rounds])
		$RoundLabel.visible = value > 0
		current_round = value

var winner = null:
	set(value):
		if value != null:
			set_win_text('{0} WINS'.format([value]))
			$WinAnnouncer.visible = true
		else:
			$WinAnnouncer.visible = false

signal main_menu
signal next_fight

func set_win_text(text):
	$WinAnnouncer.text = text
	$WinAnnouncer.visible = true

func _on_main_menu_button_pressed():
	main_menu.emit()

func _on_next_fight_button_pressed():
	next_fight.emit()
