
class_name Inventory
extends Control

@export var card_prefab:PackedScene
var current_cards: Array[Card]
@export var starting_ingredients: Array[Ingredient]
@export var ui:Control
@export var can_stack_uses:bool = true
@export var can_drag_cards:bool = false

#CACHED COMPS
@onready var abilities = get_tree().get_first_node_in_group("ability_manager")
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")

#SIGNALS
signal on_add_card(origin,card)
signal dropping_ingredient(origin, card)
signal on_remove_ingredient(origin,card)
signal checking_drop(origin,card)
signal destroying_ingredient(origin,card)
signal destroying_all(origin)
signal card_start_drag(origin,card)
signal card_stop_drag(origin)
#STATE
var can_drop_card = true
var dragging_card:Node = null

func init_inventory() -> void:
	if ui != null:
		ui.init_ui()
		ui.inventory = self
		ui.update_slots()
	for i in starting_ingredients:
		instantiate_card_and_add(i)

#region Signal Senders
func destroy_ingredient(card:Node):
	destroying_ingredient.emit(self,card)
	current_cards.erase(card)
	if ui != null:
		current_cards = ui.get_slots_cards_list()
		ui.update_slots()
		current_cards = ui.get_slots_cards_list()
	if card.get_parent() == self:
		card.queue_free()

func destroy_all_ingredients():
	destroying_all.emit(self)
	for i in current_cards:
		i.queue_free()
	current_cards.clear()
	if ui != null:
		ui.update_slots()
		current_cards = ui.get_slots_cards_list()

func remove_ingredient(card):
	if !current_cards.has(card):
		return
	card.clear_preview()
	if !card.stats.unlimited_uses:
		change_ingredient_uses(card, -1)
		current_cards.erase(card)
		distribute_uses(card)
	if ui != null:
		ui.update_slots()
		current_cards = ui.get_slots_cards_list()
	on_remove_ingredient.emit(self,card)

func drop_ingredient(card):
	player_inventory.remove_ingredient(card)
	add_card(card)
	dropping_ingredient.emit(self, card)

func add_card(card):
	var new_card:Node = card_prefab.instantiate()
	add_child(new_card)
	new_card.set_stats(card.stats, card.base_stats)
	#Check if ingredient is already in inventory
	if new_card.committed_stats.unlimited_uses:
		current_cards.append(new_card)
	else:
		distribute_uses(new_card)
	on_add_card.emit(self,new_card)
	if ui != null:
		ui.update_slots()
		current_cards = ui.get_slots_cards_list()
	
	return new_card
#endregion

#region Inventory Funcitons
func instantiate_card_and_add(resource:Ingredient):
	var temp_card:Node = card_prefab.instantiate()
	temp_card.set_stats(resource.duplicate(true), resource)
	var new_card = add_card(temp_card)
	temp_card.queue_free()
	return new_card

func distribute_uses(card):
	if card == null or card.is_queued_for_deletion():
		return
	var duplicates:Array[Node] = []
	for i in current_cards:
		if i.base_stats == card.base_stats:
			duplicates.append(i)
	#find duplicate with less than 4 uses and assign more uses until the added card has no more
	if can_stack_uses:
		for i in duplicates:
			while i.stats.uses < 4 and card.stats.uses > 0:
				change_ingredient_uses(i, 1)
				change_ingredient_uses(card, -1)
			if card.stats.uses == 0 or card == null or card.is_queued_for_deletion():
				return
				
	current_cards.append(card)

func change_ingredient_uses(ingredient_card,amount):
	ingredient_card.stats.uses += amount
	if ingredient_card.stats.uses <= 0:
		ingredient_card.queue_free()

func check_can_drop(data):
	checking_drop.emit(self,data)
	#check for requirements from signal
	if can_drop_card == false:
		can_drop_card = true
		return false
	#check abilities
	if abilities.on_try_add_ingredient_any_inventory(data) == false:
		return false
	
	return true

func set_card_drag(card):
	dragging_card = card
	card_start_drag.emit(self, card)

func stop_card_drag():
	dragging_card = null
	card_stop_drag.emit(self)

#endregion

#region Get Info
func count_ingredient_in_inventory(target:Ingredient) -> int:
	var count = 0
	for card in current_cards:
		if card.base_stats == target:
			count += 1
	return count

func get_cards_of_ingredient(search:Ingredient) -> Array[Card]:
	var cards:Array[Card]
	for card in current_cards:
		if card.base_stats == search:
			cards.append(card)
	return cards

func get_unique_base_ingredients() -> Array[Ingredient]:
	var unique_ingr:Array[Ingredient]
	for i in current_cards:
		if unique_ingr.has(i.base_stats):
			continue
		unique_ingr.append(i.base_stats)
	return unique_ingr

func get_rarity_amount_in_inventory(search) -> int:
	var rarity_ingr:Array[Card]
	for i in current_cards:
		if rarity_ingr.has(i):
			continue
		if i.committed_stats.rarity == search:
			rarity_ingr.append(i)
	return rarity_ingr.size()

#region Order
func get_card_index(card:Card) -> int:
	var index = current_cards.find(card)
	if index == -1:
		printerr("The card (" + card.committed_stats.name + ") doesnt exist in this inventory: " + self.name)
	return index

func get_indexes_of_ingredient(ingredient:Ingredient) -> Array[int]:
	var cards = get_cards_of_ingredient(ingredient)
	var indexes:Array[int]
	for card in cards:
		indexes.append(get_card_index(card))
	return indexes

#endregion
#region Tags
func get_tags_in_inventory() -> Array[GlobalEnums.Tags]:
	var tags:Array[GlobalEnums.Tags]
	for card in current_cards:
		for tag in card.committed_stats.tags:
			if not tags.has(tag):
				tags.append(tag)
	return tags

func get_all_cards_with_tag(search_tag:GlobalEnums.Tags) -> Array[Card]:
	var tag_ingr:Array[Card]
	for i in current_cards:
		if tag_ingr.has(i):
			continue
		if i.committed_stats.tags.has(search_tag):
			tag_ingr.append(i)
	return tag_ingr

func get_cards_with_tags(tags:Array[GlobalEnums.Tags]) -> Array[Card]:
	var cards_with_tags:Array[Card]
	for tag in tags:
		var tag_cards = get_all_cards_with_tag(tag)
		for card in tag_cards:
			if cards_with_tags.has(card):
				cards_with_tags.erase(card)
		cards_with_tags.append_array(tag_cards)
	return cards_with_tags

func can_cover_tags(required_tags:Array[GlobalEnums.Tags]) -> bool:
	#Check if cards can cover all required tags, with each card counting for only one tag.
	var cards = get_cards_with_tags(required_tags)
	var available_cards = cards.duplicate()
	var tags_to_cover = required_tags.duplicate()
	if cards.size() < required_tags.size():
		return false
	tags_to_cover.sort_custom(func(a, b): 
		var count_a = available_cards.count(func(card): return card.committed_stats.tags.has(a))
		var count_b = available_cards.count(func(card): return card.committed_stats.tags.has(b))
		return count_a < count_b)
	for tag in tags_to_cover:
		var found_card_idx = -1
		
		# Find first available card that has this tag
		for i in range(available_cards.size()):
			var card_tags = available_cards[i].committed_stats.tags
			if card_tags.has(tag):
				found_card_idx = i
				break
		
		# No card found for this tag → fail
		if found_card_idx == -1:
			return false
		
		# Remove the used card (each card counts once)
		available_cards.remove_at(found_card_idx)
	
	# All tags covered successfully
	return true

#endregion
#region Country
func get_countries_in_inventory() -> Array[GlobalEnums.Country]:
	var countries:Array[GlobalEnums.Country]
	for card in current_cards:
		for country in card.committed_stats.countries:
			if not countries.has(country):
				countries.append(country)
	return countries

func get_all_cards_with_country(search_country:GlobalEnums.Country) -> Array[Card]:
	var country_ingr:Array[Card]
	for i in current_cards:
		if country_ingr.has(i):
			continue
		if i.committed_stats.countries.has(search_country):
			country_ingr.append(i)
	return country_ingr

func get_cards_with_countries(countries:Array[GlobalEnums.Country]) -> Array[Card]:
	var cards_with_countries:Array[Card]
	for country in countries:
		var country_cards = get_all_cards_with_country(country)
		for card in country_cards:
			if cards_with_countries.has(card):
				cards_with_countries.erase(card)
		cards_with_countries.append_array(country_cards)
	return cards_with_countries

func can_cover_countries(required_countries:Array[GlobalEnums.Country]) -> bool:
	#Check if cards can cover all required countries, with each card counting for only one country.
	var cards = get_cards_with_countries(required_countries)
	var available_cards = cards.duplicate()
	var countries_to_cover = required_countries.duplicate()
	if cards.size() < required_countries.size():
		return false
	countries_to_cover.sort_custom(func(a, b): 
		var count_a = available_cards.count(func(card): return card.committed_stats.countries.has(a))
		var count_b = available_cards.count(func(card): return card.committed_stats.countries.has(b))
		return count_a < count_b)
	for country in countries_to_cover:
		var found_card_idx = -1
		
		# Find first available card that has this country
		for i in range(available_cards.size()):
			var card_countries = available_cards[i].committed_stats.countries
			if card_countries.has(country):
				found_card_idx = i
				break
		
		# No card found for this country → fail
		if found_card_idx == -1:
			return false
		
		# Remove the used card (each card counts once)
		available_cards.remove_at(found_card_idx)
	
	# All countries covered successfully
	return true


#endregion
#region Abilities
func get_abilities_in_inventory() -> Array[Ability]:
	var abilities:Array[Ability]
	for card in current_cards:
		for ability in card.committed_stats.abilities:
			if not abilities.has(ability):
				abilities.append(ability)
	return abilities

func get_all_cards_with_ability(search_ability:Ability) -> Array[Card]:
	var ability_ingr:Array[Card]
	for i in current_cards:
		if ability_ingr.has(i):
			continue
		if i.committed_stats.abilities.has(search_ability):
			ability_ingr.append(i)
	return ability_ingr

func get_cards_with_abilities(abilities:Array[Ability]) -> Array[Card]:
	var cards_with_abilities:Array[Card]
	for ability in abilities:
		var ability_cards = get_all_cards_with_ability(ability)
		for card in ability_cards:
			if cards_with_abilities.has(card):
				cards_with_abilities.erase(card)
		cards_with_abilities.append_array(ability_cards)
	return cards_with_abilities

func can_cover_abilities(required_abilities:Array[Ability]) -> bool:
	#Check if cards can cover all required abilities, with each card counting for only one ability.
	var cards = get_cards_with_abilities(required_abilities)
	var available_cards = cards.duplicate()
	var abilities_to_cover = required_abilities.duplicate()
	if cards.size() < required_abilities.size():
		return false
	abilities_to_cover.sort_custom(func(a, b): 
		var count_a = available_cards.count(func(card): return card.committed_stats.abilities.has(a))
		var count_b = available_cards.count(func(card): return card.committed_stats.abilities.has(b))
		return count_a < count_b)
	for ability in abilities_to_cover:
		var found_card_idx = -1
		
		# Find first available card that has this ability
		for i in range(available_cards.size()):
			var card_abilities = available_cards[i].committed_stats.abilities
			if card_abilities.has(ability):
				found_card_idx = i
				break
		
		# No card found for this ability → fail
		if found_card_idx == -1:
			return false
		
		# Remove the used card (each card counts once)
		available_cards.remove_at(found_card_idx)
	
	# All abilities covered successfully
	return true

#endregion


#endregion
