class_name Chest
extends Area2D

const CHEST_DESPAWN_TIME: float = 30.0

static var stack: Array[Chest] = []
static var global: Dictionary = {}

enum Type {
	BRONZE, SILVER,
	EMERALD, RUBY
}

@onready var animation_player = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var interact = $Interact

var size: int = 15
var type: Type = Type.BRONZE
var lifetime: float = CHEST_DESPAWN_TIME
var players_touching = 0
var backpack: Control
var is_open = false
var container_id: int
var contents: Dictionary = {}

var server_content: String
var old_server_content: String

func chest_type_to_string(type: Type) -> String:
	match(type):
		Type.BRONZE: return "bronze"
		Type.SILVER: return "silver"
		Type.EMERALD: return "emerald"
		Type.RUBY: return "ruby"
	return ""

func _ready():
	close()
	backpack = find_parent("Game").find_child("BackpackWindow")
	
	if multiplayer.is_server():
		container_id = floori(randf() * 99999999)
	
	Chest.global[container_id] = self

func open(force: bool = false):
	if is_open and not force:
		return
	
	var anim_name = "%s_open" % chest_type_to_string(type)
	
	animation_player.stop(true)
	sprite.play(anim_name)
	animation_player.play("squash")
	is_open = true

func close(force: bool = false):
	if not is_open and not force:
		return
	
	var anim_name = "%s_closed" % chest_type_to_string(type)
	
	animation_player.stop(true)
	sprite.play(anim_name)
	animation_player.play("squash")
	interact.visible = false
	is_open = false

func set_slot(set_index: int, set_item: Item):
	if set_item == null:
		contents.erase(set_index)
	else:
		contents[set_index] = set_item

	var serialized = {}
		
	for slot_index in contents:
		var item = contents[slot_index]
		
		serialized[slot_index] = {
			"id": ItemLookup.get_id(item),
			"quantity": item.quantity
		}
	
	server_content = JSON.stringify(serialized)
	
	if contents.size() == 0:
		pass
		# despawn after 5 seconds if still empty
		# get_tree().create_timer(5).timeout.connect(check_despawn)

func check_despawn():
	if contents.size() == 0:
		queue_free()

func update_contents():
	var parsed = JSON.parse_string(server_content)
	
	contents.clear()
	
	for slot_index in parsed:
		var item_simple = parsed.get(slot_index)
		var item = ItemLookup.get_item(item_simple.id)
		item.quantity = item_simple.quantity
		contents[int(slot_index)] = item
	
	var chest = Chest.get_current()
	
	if backpack.is_looking_at(chest):
		backpack.set_container(chest.contents)

func _process(delta: float):
	if multiplayer.is_server():
		lifetime -= delta
		
		if lifetime <= 0:
			queue_free()
	elif server_content != old_server_content:
		update_contents()
		old_server_content = server_content
		print(contents)

func push_chest(chest: Chest):
	if len(Chest.stack) > 0:
		var current = Chest.stack[len(Chest.stack) - 1]
		current.close()
	
	chest.open()
	Chest.stack.push_back(chest)

func pop_chest(chest: Chest, exiting_tree: bool = false):
	var index = Chest.stack.find(chest)
	
	if index == -1:
		return
	
	Chest.stack.pop_at(index)
	chest.close()
	
	if backpack.is_viewing_container():
		if exiting_tree:
			# just so its not jarring when you loot a chest completely
			# and the hud just disappears
			backpack.open_satchel()
		else:
			backpack.close()
	
	if len(Chest.stack) > 0:
		Chest.stack[len(Chest.stack) - 1].open()

static func get_current():
	if len(Chest.stack) == 0:
		return null
	
	return Chest.stack[len(Chest.stack) - 1]

func _on_area_2d_body_entered(body):
	if not (body is Player):
		return
	
	players_touching += 1
	
	if players_touching == 1:
		open()
	
	if body.owner_id == multiplayer.get_unique_id():
		interact.visible = true
		push_chest(self)


func _on_area_2d_body_exited(body):
	if not (body is Player):
		return
	
	players_touching -= 1
	
	if players_touching == 0:
		close()
	
	if body.owner_id == multiplayer.get_unique_id():
		pop_chest(self)

func _exit_tree():
	Chest.global.erase(container_id)
	pop_chest(self, true)
