extends Node

class AbilityTrigger:
	var ability: Ability
	var source_card: Node      # the card that owns this ability instance
	var remaining: int   # how many more times it can trigger     

	func _init(a: Ability, card: Node, dur: int) -> void:
		ability = a
		source_card = card
		remaining = dur
#STATE

#CACHED COMPS
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
#STATE
var encounter_trigger:Array[AbilityTrigger]
var dish_triggers:Array[AbilityTrigger]
var dish_next_ingredient_trigger:Array
var current_dish
var dragged_card: Node = null
#SIGNALS
#------------Trigger Management-----------------------
#region Tracking
#DISH
func add_ability_to_encounter_trigger(ability, card):
	var t = AbilityTrigger.new(ability, card, ability.duration)
	encounter_trigger.append(t)
func add_ability_to_dish_triggers(ability, card):
	var t = AbilityTrigger.new(ability, card, ability.duration)
	dish_triggers.append(t)
func remove_all_from_dish_triggers():
	dish_triggers.clear()
	for card in player_inventory.current_cards:
		card.reset_preview()
func progress_dish_triggers_duration():
	# Handle duration / non‑continuous
	for t in dish_triggers:
		if !t.ability.continuous:
			t.remaining -= 1
			if t.remaining <= 0:
				dish_triggers.erase(t)
func dish_triggers_already_active(ability, card) -> bool:
	for t in dish_triggers:
		if t.ability == ability and t.source_card == card:
			#is already in list
			return true
	return false
func encounter_trigger_already_active(ability, card) -> bool:
	for t in encounter_trigger:
		if t.ability == ability and t.source_card == card:
			#is already in list
			return true
	return false
#endregion
#-----------------CONDITIONS_----------------------
#region Condition Checking
func check_dish_conditions_for_cards(ability:Ability, cards:Array[Node]) ->bool: #checks if conditions are met to activate triggers
	var tags: Array[GlobalEnums.Tags] = []
	
	for card in cards:
		for tag in card.committed_stats.tags:
			if not tags.has(tag):
				tags.append(tag)
	#if a condition is not met returns false
	# Get current dish node (you already store current_dish)
	var dish = current_dish
	if dish == null:
		return true
	#check sweet min/max
	if ability.sweet_cond_dish_max > -1 and dish.sweet >  ability.sweet_cond_dish_max:
		return false
	if ability.sweet_cond_dish_min > -1 and dish.sweet < ability.sweet_cond_dish_min:
		return false
	#check spicy minmax
	if ability.spicy_cond_dish_max > -1 and dish.spicy >  ability.spicy_cond_dish_max:
		return false
	if ability.spicy_cond_dish_min > -1 and dish.spicy < ability.spicy_cond_dish_min:
		return false
	#check hearty minmax
	if ability.hearty_cond_dish_max > -1 and dish.hearty >  ability.hearty_cond_dish_max:
		return false
	if ability.hearty_cond_dish_min > -1 and dish.hearty < ability.hearty_cond_dish_min:
		return false
		#check fresh minmax
	if ability.fresh_cond_dish_max > -1 and dish.fresh > ability.fresh_cond_dish_max:
		return false
	if ability.fresh_cond_dish_min > -1 and dish.fresh < ability.fresh_cond_dish_min:
		return false
	#nutrition check
	if ability.nutrition_cond_dish_max > -1 and dish.nutrition > ability.nutrition_cond_dish_max:
		return false
	if ability.nutrition_cond_dish_min > -1 and dish.nutrition < ability.nutrition_cond_dish_min:
		return false
	
	if ability.ingredient_count_cond_dish_max > -1:
		if dish.current_cards.size() > ability.ingredient_count_cond_dish_max:
			return false
	if ability.ingredient_count_cond_dish_min > -1:
		if dish.current_cards.size() < ability.ingredient_count_cond_dish_min:
			return false

	# Tags condition example:
	if not ability.dish_tags_cond.is_empty():
		var has_all = true
		for tag in ability.dish_tags_cond:
			if not tags.has(tag):
				has_all = false
				break
		if not has_all:
			return false

	# Ingredients in dish condition:
	if not ability.specific_ingredients_in_dish_cond.is_empty():
		# Compare against dish.current_cards or similar
		for req in ability.ingredients_in_dish_cond:
			if not cards.has(req):
				return false
	
	
	return true
func die_matches_ability(die:Node, ability:Ability) -> bool:
	if not ability.flavour_filter.is_empty():
		if not ability.flavour_filter.has(die.flavour):
			return false
	if not ability.dice_number_filter.is_empty():
		if not ability.dice_number_filter.has(die.number):
			return false
	return true
func trigger_matches_context_card(trigger, context_card):
	var activates := false
	# Condition: this card’s ability triggers when this specific card is added
	if trigger.ability.this_add_to_dish_cond and trigger.source_card.base_stats == context_card.base_stats:
		activates = true
	# Condition: triggers when any card is added
	if trigger.ability.any_other_add_to_dish_cond and trigger.source_card.base_stats != context_card.base_stats:
		activates = true
	return activates
func check_target_filter(ability, context_card) -> bool:
	if ability.played_ingredient_target:
		#Tags filter (OR)
		if not ability.card_tags_filter.is_empty():
			var card_tags: Array[GlobalEnums.Tags] = context_card.committed_stats.tags  # ensure this exists
			var has_one = false
			for tag in card_tags:
				
				if ability.card_tags_filter.has(tag):
					has_one = true
					break
			if not has_one:
				return false
		#rarity filter
		if not ability.card_rarity_filter.is_empty():
			var card_rarity = context_card.committed_stats.rarity  # ensure this exists
			var has_all = true
			if not ability.card_rarity_filter.has(card_rarity):
				return false
		#Ability filter (OR)
		if not ability.card_abilities_filter.is_empty():
			var card_abilities: Array[Ability] = context_card.committed_stats.abilities  # ensure this exists
			var has_one = false
			for ab in card_abilities:
				if ability.card_abilities_filter.has(ab):
					has_one = true
					break
			if not has_one:
				return false
		# ingredient on card_cond:
		if ability.specific_ingredient_filter != null:
			if context_card.base_stats != ability.specific_ingredient_filter:
				return false
	# ingredient on card_cond:
	if ability.specific_ingredient_filter != null:
		if context_card.base_stats != ability.specific_ingredient_filter:
			return false
	return true
#endregion
#----------Trigger evaluation---------
#region trigger evaulation
func evaluate_add_to_dish_triggers(added_card: Node) -> void:
	# Iterate over a copy because we may remove elements
	for t in dish_triggers.slice(0):
		var ability = t.ability
		if t.source_card == null:
			continue
		if not trigger_matches_context_card(t,added_card):
			continue
		#Checking general conditions
		if not check_dish_conditions_for_cards(ability, current_dish.current_cards):
			continue
		activate_effects(t, added_card)
	
func evaluate_try_add_to_dish_triggers(try_card:Node) -> bool:
	var can_drop = true
	for t in dish_triggers.slice(0):
		var ability = t.ability
		
		var card = t.source_card
		var activates = true
		if not ability.try_add_to_dish_cond:
			activates = false
		if not check_dish_conditions_for_cards(ability, current_dish.current_cards):
			activates = false
		
		# Condition: this card’s ability triggers when any card is trying to be added to dish
		
		if not activates:
				continue
		if ability.played_ingredient_target:
			if ability.can_only_play:
				if not check_target_filter(ability,try_card):
					can_drop = false
			if ability.can_not_play:
				if check_target_filter(ability,try_card):
					can_drop = false
		#check targeting
		#if self target and its the same base ingredient
		if ability.self_target and card.base_stats == try_card.base_stats:
			#Check if ability restricts the card drop try
			if ability.limit_ingredients_int != -1:
				if ability.limit_ingredients_int <= current_dish.count_ingredient_in_dish(try_card.base_stats):
					can_drop = false
			if ability.can_not_play:
					can_drop = false
			#if all ingr in dish target
		if ability.all_ingredients_in_dish_target:
			if ability.can_not_play:
					can_drop = false
			if ability.limit_ingredients_int != -1:
				if ability.limit_ingredients_int <= current_dish.current_cards.size():
					can_drop = false
			
		
	
	return can_drop
func evaluate_encounter_end_triggers(source_card):
	for t in encounter_trigger.slice(0):
		var ability = t.ability
		var card = t.source_card
		
		var activates = false
		if !ability.end_encounter_cond:
			continue
		activate_effects(t, source_card)
		# Handle duration / non‑continuous
		if not ability.continuous:
			t.remaining -= 1
			if t.remaining <= 0:
				encounter_trigger.erase(t)

#endregion
#----------------SIGNAL MANAGEMENT------------
#region Signals

func on_ingredient_add_to_dish(card): #after adding own stats to dish
	#for each ability on new card checks if already active and adds if supposed to
	for ability:Ability in card.committed_stats.abilities:
		if ability == null:
			continue
		#check if already active
		if dish_triggers_already_active(ability, card):
				#add to trigger_list if stackable
			if ability.stackable:
				add_ability_to_dish_triggers(ability, card)
			#else: do nothing, already active and not stackable
		else:
			#first time ability is called
			add_ability_to_dish_triggers(ability, card)
	evaluate_add_to_dish_triggers(card)
	rebuild_inventory_previews()
	progress_dish_triggers_duration()
	
func on_try_add_ingredient_any_inventory(card):
	pass

func on_try_add_to_dish(card) -> bool:
	return evaluate_try_add_to_dish_triggers(card)

func on_ingredient_destroyed_from_dish(card):
	for t in dish_triggers.slice(0):
		if t.source_card == card:
			dish_triggers.erase(t)
	rebuild_inventory_previews()
func on_encounter_end():
	for card in player_inventory.current_cards:
		for ability:Ability in card.committed_stats.abilities:
			if ability == null:
				continue
			#check if already active
			if encounter_trigger_already_active(ability, card):
					#add to trigger_list if stackable
				if ability.stackable:
					add_ability_to_encounter_trigger(ability, card)
				#else: do nothing, already active and not stackable
			else:
				#first time ability is called
				add_ability_to_encounter_trigger(ability, card)
		evaluate_encounter_end_triggers(card)
	
	current_dish = null

func on_dish_complete():
	remove_all_from_dish_triggers()
	pass

func on_challenge_start(dish):
	current_dish = dish
	rebuild_inventory_previews()

func on_challenge_end():
	pass

func on_dice_roll(card):
	pass

func on_die_roll(card):
	pass



#endregion

#-----------------EFFECTS----------------
#region effects

func activate_effects(trigger, context_card):
	var ability = trigger.ability
	var ability_card = trigger.source_card
	#-----------PREVIEW EFFECTS-----------
	#self card effects
	if ability.self_target:
		#modify own stats
		if current_dish:
			var multiplier = get_ability_multiplier(ability, current_dish.current_cards)
			#add stat effects
			apply_stat_effect(ability_card.committed_stats, ability, multiplier)
		if ability.uses_effect > 0:
			for i in ability.uses_effect:
				player_inventory.instantiate_card_and_add(ability_card.base_stats)
		if ability.uses_effect < 0:
			for i in ability.uses_effect * -1:
				player_inventory.remove_ingredient(ability_card)
	#can be played
	
	if ability.played_ingredient_target and current_dish != null:
		
		var apply_effects = true
		#check for target filters
		apply_effects = check_target_filter(ability, context_card)
		#modify other cards stats
		
		if apply_effects:
			#add stat effects
			var multiplier = get_ability_multiplier(ability, current_dish.current_cards)
			apply_stat_effect(context_card.committed_stats, ability, multiplier)
			if ability.uses_effect > 0:
				for i in ability.uses_effect:
					player_inventory.instantiate_card_and_add(ability_card.base_stats)
			if ability.uses_effect < 0:
				for i in ability.uses_effect * -1:
					player_inventory.remove_ingredient(ability_card)
	
	if ability.dish_target and current_dish != null:
		if ability.add_stats_dish:
			if check_target_filter(ability, context_card):
				var multiplier = get_ability_multiplier(ability, current_dish.current_cards)
				current_dish.ability_sweet += ability.sweet_effect * multiplier
				current_dish.ability_spicy += ability.spicy_effect * multiplier
				current_dish.ability_hearty += ability.hearty_effect * multiplier
				current_dish.ability_fresh += ability.fresh_effect * multiplier
				current_dish.ability_nutrition += ability.nutrition_effect * multiplier
		if ability.multiply_dish:
			if check_target_filter(ability, context_card):
				var multiplier = get_ability_multiplier(ability, current_dish.current_cards)
				current_dish.sweet *= ability.sweet_effect + multiplier
				current_dish.spicy *= ability.spicy_effect + multiplier
				current_dish.hearty *= ability.hearty_effect + multiplier
				current_dish.fresh *= ability.fresh_effect + multiplier
				current_dish.nutrition *= ability.nutrition_effect + multiplier
		if ability.equal_stats_to_flavour != GlobalEnums.Flavour.NONE:
			var temp_stat:int = 0
			match ability.equal_stats_to_flavour:
				GlobalEnums.Flavour.SWEET:
					temp_stat = current_dish.sweet
				GlobalEnums.Flavour.SPICY:
					temp_stat = current_dish.spicy
				GlobalEnums.Flavour.HEARTY:
					temp_stat = current_dish.hearty
				GlobalEnums.Flavour.FRESH:
					temp_stat = current_dish.fresh
			for flavour in ability.flavour_filter:
				match flavour:
					GlobalEnums.Flavour.SWEET:
						current_dish.sweet = temp_stat
					GlobalEnums.Flavour.SPICY:
						current_dish.spicy = temp_stat
					GlobalEnums.Flavour.HEARTY:
						current_dish.hearty = temp_stat
					GlobalEnums.Flavour.FRESH:
						current_dish.fresh = temp_stat
			
# Example: add specific ingredients to player inventory
	if ability.add_ingredient_by_name != "":
		var ingr  = item_pool.get_ingredient_by_name(ability.add_ingredient_by_name)
		player_inventory.instantiate_card_and_add(ingr)
	for ingr: Ingredient in ability.add_specific_ingredients_effect:
		player_inventory.instantiate_card_and_add(ingr)

	# Example: add random ingredients
	if ability.add_random_ingredients_amount_effect > 0:
		for i in range(ability.add_random_ingredients_amount_effect):
			var req_tag: Array[GlobalEnums.Tags] = ability.rand_ingr_tag_filter
			var req_rarity: Array[GlobalEnums.Rarity] = ability.rand_ingr_rarity_filter
			var ing = item_pool.get_random_ingredient(false, req_tag, [], req_rarity)
			if ing:
				player_inventory.instantiate_card_and_add(ing)

	#Dice Reroll
	if ability.all_dice_target:
		for card in current_dish.current_cards:
			for die in card.dice:
				if not die_matches_ability(die, ability):
					continue
				#if flavour filter applies
				if ability.reroll:
					current_dish.reroll_die(die)
				if ability.set_dice_number != 0:
					die.display_number(ability.set_dice_number)
	#limit amount possible in dish
	if ability.morale_gain != 0:
		player_inventory.add_morale(ability.morale_gain)
	# Extend here for other effects:
	# - modify dish stats
	# - modify dice
	# - morale/money changes via event_manager, etc
	
func apply_stat_effect(target_stats: Ingredient,ability: Ability,multiplier: int) -> void:
	target_stats.sweet += ability.sweet_effect * multiplier
	target_stats.spicy += ability.spicy_effect * multiplier
	target_stats.hearty += ability.hearty_effect * multiplier
	target_stats.fresh += ability.fresh_effect * multiplier
	target_stats.nutrition += ability.nutrition_effect * multiplier

func get_ability_multiplier(ability, cards) -> int:
	var multiplier:int = 1
	if !ability.times_tag_in_dish.is_empty() and current_dish != null:
		multiplier = 0
		for card in cards:
			for tag in ability.times_tag_in_dish:
				if card.committed_stats.tags.has(tag):
					multiplier += 1
					break
	if ability.times_dice_amount != 0 and current_dish != null:
		multiplier = floor(current_dish.dice.size()/ability.times_dice_amount)
	return multiplier
#endregion

#region Preview
func calculate_dish_preview() -> Dictionary:
	if current_dish == null:
		return {}
	
	var preview_stats: Dictionary = {}
	var dish_cards = current_dish.current_cards
	
	for card in player_inventory.current_cards:
		if not is_instance_valid(card):
			continue
		preview_stats[card] = card.committed_stats.duplicate(true)
		
	
	#apply abilities belonging to dragged card
	if dragged_card != null:
		for ability: Ability in dragged_card.committed_stats.abilities:
			if ability == null:
				continue
			apply_drag_ability_preview(ability, dragged_card, dish_cards, preview_stats)
	for trigger in dish_triggers:
		apply_existing_trigger_preview_to_all(trigger, preview_stats)
	apply_card_ability_previews(preview_stats)
	
	return {"stats": preview_stats}
func apply_card_ability_previews(preview_stats):
	for target_card:Node in preview_stats.keys():
		var hypothetical_cards = current_dish.current_cards.duplicate(true)
		hypothetical_cards.append(target_card)
		for ability in target_card.stats.abilities:
			
			var temp_trigger = AbilityTrigger.new(ability,target_card,ability.duration)
			if not trigger_matches_context_card(temp_trigger,target_card):
				continue
			
			#Checking general conditions
			if not check_dish_conditions_for_cards(ability, hypothetical_cards):
				continue
			
			#Apply preview effects
			var multiplier = get_ability_multiplier(ability, hypothetical_cards)
			
			if ability.self_target:
				apply_stat_effect(preview_stats[target_card],ability, multiplier)

func apply_existing_trigger_preview_to_all(trigger, preview_stats):
	var ability = trigger.ability
	var source_card:Node  = trigger.source_card
	
	for target_card in preview_stats.keys():
		
		if not trigger_matches_context_card(trigger,target_card):
			continue

		#Checking general conditions
		if not check_dish_conditions_for_cards(ability, current_dish.current_cards):
			continue
		
		#Apply preview effects
		var multiplier = get_ability_multiplier(ability, current_dish.current_cards)
		
		if ability.played_ingredient_target:
			var apply_effects = true
			#check for target filters
			apply_effects = check_target_filter(ability, target_card)
			#modify other stats
			if apply_effects:
				apply_stat_effect(preview_stats[target_card],ability, multiplier)

func apply_drag_ability_preview(ability, dragged_card, dish_cards, preview_stats):
	
	if not check_dish_conditions_for_cards(ability, dish_cards):
		return
	
	var multiplier := get_ability_multiplier(ability, current_dish.current_cards)
		
	if ability.played_ingredient_target:
		for target_card in preview_stats.keys():
			if not check_target_filter(ability, target_card):
				continue
			apply_stat_effect(preview_stats[target_card], ability, multiplier)
		#check for target filters
		#modify other stats
	if ability.all_dice_target:
			set_dice_preview_effects(ability)
	
func set_dice_preview_effects(ability):
	#-----------PREVIEW EFFECTS-----------
	if not ability.all_dice_target:
		return
	for card in current_dish.current_cards:
		for die in card.dice:
			if die_matches_ability(die, ability):
				die.set_preview()

func rebuild_inventory_previews():
	if current_dish == null:
		return
	clear_all_card_previews()
	clear_dice_preview()
	
	#if not on_try_add_to_dish(dragged_card):
		#return
	
	var result:= calculate_dish_preview()
	var preview_stats: Dictionary = result.get("stats", {})
	
	for target_card in preview_stats.keys():
			if not is_instance_valid(target_card):
				continue
			target_card.begin_preview(preview_stats[target_card])
	player_inventory.update_ui()
	
func clear_dice_preview() -> void:
	if current_dish == null:
		return

	for card in current_dish.current_cards:
		for die in card.dice:
			die.reset_preview()

func start_drag_preview(card):
	dragged_card = card
	rebuild_inventory_previews()

func stop_drag_preview():
	dragged_card = null
	rebuild_inventory_previews()

func clear_all_card_previews():
	for card in player_inventory.current_cards:
		if is_instance_valid(card):
			card.clear_preview()

func clear_all_previews():
	clear_all_card_previews()
	clear_dice_preview()
#endregion
