extends Node2D

var dagger = preload("res://items/weapons/Dagger.tscn")
var player_scn = preload("res://entities/friendlies/Player.tscn")

var last_enemy_spawn = 3 # seconds
var enemy_spawn_rate = 2 # seconds
var max_enemies = 40
@onready var dungeon = $Dungeon
var dungeon_generated = false

func spawn_player(pid: int, player_name: String):
	if multiplayer.is_server() and not dungeon_generated:
		dungeon.seed = floor(randf() * 9999999)
		dungeon.rng.set_seed(dungeon.seed)
		dungeon.generate()
		dungeon_generated = true
	
	if multiplayer.is_server():
		dungeon.fix_client.rpc_id(pid, dungeon.seed)
	
	var player: Player = player_scn.instantiate()
	player.owner_id = pid
	player.player_name = player_name
	player.position = dungeon.get_player_spawn_point()
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
		ItemLookup.get_item([
			ItemLookup.WOODEN_HELMET,
			ItemLookup.IRON_HELMET,
			ItemLookup.GOLD_HELMET,
			ItemLookup.DEMON_HELMET,
			ItemLookup.SKULLMET
			
		][randi_range(0, 4)]),
		1
	)
	
	player.set_slot_item(
		Item.SlotType.QUICK_SWAP,
		Item.SLOT_CHESTPLATE,
		ItemLookup.get_item([
			ItemLookup.WOODEN_CHESTPLATE,
			ItemLookup.IRON_CHESTPLATE,
			ItemLookup.STONE_CHESTPLATE,
			ItemLookup.FLESH_PLATE,
			ItemLookup.GOLD_CHESTPLATE
			
		][randi_range(0, 4)]),
		1
	)
	
	player.set_slot_item(
		Item.SlotType.QUICK_SWAP,
		Item.SLOT_LEGGINGS,
		ItemLookup.get_item([
			ItemLookup.GOLD_LEGGINGS,
			ItemLookup.SILVER_LEGGINGS,
			ItemLookup.WOODEN_LEGGINGS,
			ItemLookup.DIAMOND_LEGGINGS,
			ItemLookup.JEANS
			
		][randi_range(0, 4)]),
		1
	)
	
	player.set_slot_item(
		Item.SlotType.QUICK_SWAP,
		Item.SLOT_BOOTS,
		ItemLookup.get_item([
			ItemLookup.WOODEN_BOOTS,
			
		][randi_range(0, 0)]),
		1
	)
	
	player.set_slot_item(
		Item.SlotType.QUICK_SWAP,
		Item.SLOT_ACCESSORY,
		ItemLookup.get_item([
			ItemLookup.AMETHYST,
			ItemLookup.CHEESE,
			ItemLookup.GOLD_RING,
			ItemLookup.SILVER_BLOOD_BOURNE,
			ItemLookup.WOOD_OPAL
			
		][randi_range(0, 4)]),
		1
	)
	
	player.set_slot_item(
		Item.SlotType.INVENTORY,
		0,
		ItemLookup.get_item(ItemLookup.WOODEN_HELMET),
		1
	)
	
	Players.register_player(pid, player)

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
	
	Players.unregister_player(pid)

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
		enemy.position = dungeon.get_player_spawn_point()
		$Enemies.add_child(enemy, true)
		last_enemy_spawn = 0
		
		for x in range(dungeon.get_used_rect().size.x):
			for y in range(dungeon.get_used_rect().size.y):
				var atlas_coords = dungeon.get_cell_atlas_coords(0, Vector2i(x, y))
				
				if atlas_coords == Vector2i(1, 0) and randf() < 0.0069420:
					var rand_enemy = load(scene).instantiate()
					rand_enemy.position = Vector2(x, y) * 16
					$Enemies.add_child(rand_enemy, true)
