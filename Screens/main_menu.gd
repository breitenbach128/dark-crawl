extends Control
class_name MainMenu


func _ready() -> void:
	Network.update_lobby_names.connect(refresh_lobby_names)
	Network.update_lobby_loading.connect(refresh_lobby_loading);
	
func _on_btn_join_game_pressed() -> void:
	$CenterContainer/PanelMainMenu.visible = false
	$PanelLoading.visible = true
	$PanelLoading/CanvasLayer.visible = true
	$PanelLoading/LblLoading.text = "Connecting..."
	Network.join_game($CenterContainer/PanelMainMenu/VBoxButtons/TxtIpAddress.text)
	
	
func _on_btn_host_game_pressed() -> void:
	$CenterContainer/PanelMainMenu.visible = false
	$CenterContainer/PanelLobby.visible = true
	Network.host_game()
	$CenterContainer/PanelLobby/BtnStartGame.disabled = false
	
func update_join_button_state():
	var ready = (
		is_name_valid($CenterContainer/PanelMainMenu/VBoxButtons/TxtPlayerName.text) &&
		is_valid_ip($CenterContainer/PanelMainMenu/VBoxButtons/TxtIpAddress.text)
	)
	
	$CenterContainer/PanelMainMenu/VBoxButtons/BtnJoinGame.disabled = !ready

func _on_txt_player_name_text_changed(new_text: String) -> void:
	Globals.local_player_name = new_text
	var name_ready = len(new_text) > 0
	$CenterContainer/PanelMainMenu/VBoxButtons/BtnHostGame.disabled = !name_ready
	update_join_button_state()	
	$CenterContainer/PanelMainMenu/VBoxButtons/LblPlayerNameWarning.visible = !name_ready

func refresh_lobby_names() -> void:
	for child in $CenterContainer/PanelLobby/PlayerList.get_children():
		$CenterContainer/PanelLobby/PlayerList.remove_child(child)
	for np : NetworkPlayerData in Network.network_players:		
		var player_name_label  = Label.new()
		player_name_label.text = str(np.name,(" (Host) " if np.id == 1 else ""))
		
		$CenterContainer/PanelLobby/PlayerList.add_child(player_name_label)

func refresh_lobby_loading(isconnected: bool):
	if isconnected:
			$PanelLoading.visible = false
			$PanelLoading/CanvasLayer.visible = false
			$CenterContainer/PanelLobby.visible = true
	else:
		$PanelLoading/CanvasLayer/AnimSpriteLoading.play("dead")
		$PanelLoading/LblLoading.text = str("Connection failed to: ",$CenterContainer/PanelMainMenu/VBoxButtons/TxtIpAddress.text)
		$CenterContainer/PanelMainMenu.visible = true

func _on_btn_start_game_pressed() -> void:
	Network.start_network_game()


func _on_panel_loading_resized() -> void:
	var new_loading_position = Vector2($PanelLoading.position.x + $PanelLoading.size.x/2,$PanelLoading.position.y + $PanelLoading.size.y/2)
	$PanelLoading/CanvasLayer/AnimSpriteLoading.position = new_loading_position

func is_name_valid(name: String):
	var name_ready = len(name) > 0
	return name_ready

func is_valid_ip(ip_address: String) -> bool:
	# Define the strict validation regex pattern
	var pattern = r"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
	
	# Create and compile the RegEx object
	var regex = RegEx.create_from_string(pattern) #
	
	# Search the string 
	var result = regex.search(ip_address)
	
	# If a match is found and it spans the whole string length, it's valid
	return result != null


func _on_txt_ip_address_text_changed(new_text: String) -> void:
	if is_valid_ip(new_text) == false:
		$CenterContainer/PanelMainMenu/VBoxButtons/TxtIpAddress.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
	else:
		$CenterContainer/PanelMainMenu/VBoxButtons/TxtIpAddress.set("theme_override_colors/font_color", Color(1.0, 1.0, 1.0, 1.0))
	update_join_button_state()	
