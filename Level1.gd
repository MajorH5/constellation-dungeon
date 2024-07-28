extends Node2D

var dagger = preload("res://items/weapons/Dagger.tscn")
var player_scn = preload("res://entities/Player.tscn")
#var player_scn = preload("res://Character.tscn")

func spawn_player(pid: int, player_name: String):	
	var player = player_scn.instantiate()
	player.owner_id = pid
	#player.pid = pid
	print(player_name)
	player.player_name = player_name
	player.position = $SpawnPoints.get_children().pick_random().position
	player.name = str(pid)
	$Players.add_child(player, true)
	
	call_deferred("test", player)

	#if multiplayer.is_server():
		#print("we put on dagger")
#
	#if pid == multiplayer.get_unique_id():
		#print("we set the thang")

func test (player):
	var dag = dagger.instantiate()
	player.equip_weapon(dag)
	
	if not multiplayer.is_server():
		print("ok no server")
		$CanvasLayer/GameHud.set_slot_item(Item.SLOT_WEAPON, dag)

func remove_player(pid):
	var p = $Players.get_node(str(pid))
	if p != null:
		p.queue_free()

func get_players():
	return $Players.get_children()

func reset():
	for p in $Players.get_children():
		p.queue_free()
