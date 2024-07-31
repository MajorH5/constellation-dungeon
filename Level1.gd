extends Node2D

var dagger = preload("res://items/weapons/Dagger.tscn")
var player_scn = preload("res://entities/friendlies/Player.tscn")

var last_enemy_spawn = 3 # seconds
var enemy_spawn_rate = 2 # seconds
var max_enemies = 10

func spawn_player(pid: int, player_name: String):	
	var player: Player = player_scn.instantiate()
	player.owner_id = pid
	player.player_name = player_name
	player.position = $SpawnPoints.get_children().pick_random().position
	player.server_position = player.position
	player.name = str(pid)
	$Players.add_child(player, true)

	player.set_slot_item(
		Item.SlotType.QUICK_SWAP,
		Item.SLOT_WEAPON,
		ItemLookup.get_item(ItemLookup.GOLD_BOW),
		1
	)
	
	player.set_slot_item(
		Item.SlotType.QUICK_SWAP,
		Item.SLOT_HELMET,
		ItemLookup.get_item(ItemLookup.WOODEN_HELMET),
		1
	)
	
	player.set_slot_item(
		Item.SlotType.INVENTORY,
		0,
		ItemLookup.get_item(ItemLookup.WOODEN_HELMET),
		1
	)

@rpc("any_peer")
func equip_weapon(weapon_id: int):
	var pid = multiplayer.get_remote_sender_id()
	var player = $Players.get_node(str(pid))
	var weapon = ItemLookup.get_item(weapon_id)
	
	if weapon == null or player == null:
		return
	
	player.set_slot_item(
		Item.SlotType.QUICK_SWAP,
		Item.SLOT_WEAPON,
		weapon,
		1
	)

@rpc("any_peer")
func respawn_player():
	var pid = multiplayer.get_remote_sender_id()
	var player = $Players.get_node(str(pid))
	
	if player == null:
		return
	
	player.health = player.max_health
	player.controls_locked = false
	

func remove_player(pid):
	var p = $Players.get_node(str(pid))
	if p != null:
		p.queue_free()

func get_players():
	return $Players.get_children()

func reset():
	for p in $Players.get_children():
		p.queue_free()

func _process(delta):
	if not multiplayer.is_server() or len(get_players()) == 0:
		return
	last_enemy_spawn += delta
	
	if last_enemy_spawn >= enemy_spawn_rate and len($Enemies.get_children()) < max_enemies:
		var scene = "res://entities/hostiles/AsteroidConstruct.tscn"
		
		if randf() < 0.5:
			scene = "res://entities/hostiles/BadOmen.tscn"
		
		var enemy = load(scene).instantiate()
		enemy.position = $SpawnPoints.get_children().pick_random().position
		$Enemies.add_child(enemy, true)
		last_enemy_spawn = 0
