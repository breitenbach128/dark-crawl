extends Control
class_name MainMenu


func _on_btn_join_game_pressed() -> void:
	Network.join_game($CenterContainer/Panel/VBoxButtons/LineEdit.text)

func _on_btn_host_game_pressed() -> void:
	Network.host_game()
