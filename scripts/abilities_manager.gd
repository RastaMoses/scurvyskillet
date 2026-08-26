extends Node
class AbilityTrigger:
	var ability: Ability
	var source_card: Node      # the card that owns this ability instance
	var remaining: int   # how many more times it can trigger
	var preview:bool       

	func _init(a: Ability, card: Node, dur: int, pre:bool) -> void:
		ability = a
		source_card = card
		remaining = dur
		preview = pre
#STATE

#CACHED COMPS
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
#STATE
var encounter_trigger:Array[AbilityTrigger]
var dish_trigger:Array[AbilityTrigger]
var dish_next_ingredient_trigger:Array
var current_dish
#SIGNALS
#------------Trigger Management-----------------------
#region Tracking
#DISH
func add_ability_to_encounter_trigger(ability, card, preview):
	var t = AbilityTrigger.new(ability, card, ability.duration, preview)
	encounter_trigger.append(t)
func add_ability_to_dish_trigger(ability, card, preview):
	var t = AbilityTrigger.new(ability, card, ability.duration, preview)
	dish_trigger.append(t)
func remove_all_from_dish_trigger():
	dish_trigger.clear()
	for card in player_inventory.current_cards:
		card.reset_preview()

func dish_trigger_already_active(ability, card) -> bool:
	for t in dish_trigger:
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
#region trigger evaulation
func check_dish_conditions(ability) ->bool: #checks if conditions are met to activate triggers
	#if a condition is not met returns false
	# Get current dish node (you already store current_dish)
	var dish = current_dish
	if dish == null:
		return true
	#check sweet min/max
	if ability.sweet_cond_dish_max > -1 and dish.sweet >=  ability.sweet_cond_dish_max:
		return false
	if ability.sweet_cond_dish_min > -1 and dish.sweet < ability.sweet_cond_dish_min:
		return false
	#check spicy minmax
	if ability.spicy_cond_dish_max > -1 and dish.spicy >=  ability.spicy_cond_dish_max:
		return false
	if ability.spicy_cond_dish_min > -1 and dish.spicy < ability.spicy_cond_dish_min:
		return false
	#check hearty minmax
	if ability.hearty_cond_dish_max > -1 and dish.hearty >=  ability.hearty_cond_dish_max:
		return false
	if ability.hearty_cond_dish_min > -1 and dish.hearty < ability.hearty_cond_dish_min:
		return false
		#check fresh minmax
	if ability.fresh_cond_dish_max > -1 and dish.fresh >= ability.fresh_cond_dish_max:
		return false
	if ability.fresh_cond_dish_min > -1 and dish.fresh < ability.fresh_cond_dish_min:
		return false
	#nutrition check
	if ability.nutrition_cond_dish_max > -1 and dish.nutrition >= ability.nutrition_cond_dish_max:
		return false
	if ability.nutrition_cond_dish_min > -1 and dish.nutrition < ability.nutrition_cond_dish_min:
		return false
	# You’ll need to expose those on your dish node.

	# Tags condition example:
	if not ability.dish_tags_cond.is_empty():
		var dish_tags: Array[GlobalEnums.Tags] = dish.tags  # ensure this exists
		var has_all = true
		for tag in ability.dish_tags_cond:
			if not dish_tags.has(tag):
				has_all = false
				break
		if not has_all:
			return false

	# Ingredients in dish condition:
	if not ability.specific_ingredients_in_dish_cond.is_empty():
		# Compare against dish.current_cards or similar
		var dish_base_ingr:Array[Ingredient]
		for card in dish.current_cards:
			dish_base_ingr.append(card.base_stats)
		for req in ability.ingredients_in_dish_cond:
			if not dish_base_ingr.has(req):
				return false
	return true

func evaluate_add_to_dish_triggers(added_card: Node, preview:bool = false, drag_preview:bool = false) -> void:
	# Iterate over a copy because we may remove elements
	for t in dish_trigger.slice(0):
		var ability = t.ability
		var card = t.source_card
		var activates = false
		if t.source_card == null:
			continue
		# Condition: this card’s ability triggers when this specific card is added
		if ability.this_add_to_dish_cond and card.base_stats == added_card.base_stats:
			activates = true
		# Condition: triggers when any card is added
		if ability.any_other_add_to_dish_cond and card.base_stats != added_card.base_stats:
			activates = true

		if not activates:
			continue

		#Checking general conditions
		if not check_dish_conditions(ability):
			continue
		if preview:
			set_card_preview_effects(t, added_card)
			if drag_preview:
				set_dice_preview_effects(t, added_card)
			continue
		activate_effects(t, added_card)
		# Handle duration / non‑continuous
		if not ability.continuous and !preview:
			t.remaining -= 1
			if t.remaining <= 0:
				dish_trigger.erase(t)
func evaluate_try_add_to_dish_triggers(try_card:Node, preview:bool = false) -> bool:
	var can_drop = true
	for t in dish_trigger.slice(0):
		var ability = t.ability
		var card = t.source_card
		var activates = false
		if ability.try_add_to_dish_cond:
			activates = true
		if not check_dish_conditions(ability):
			activates = false
		# Condition: this card’s ability triggers when any card is trying to be added to dish
		
		if not activates:
				continue
				
		
		#Check if ability restricts the card drop try
		if ability.limit_ingredients_int != -1:
			#check targeting
			
			#if self target and its the same base ingredient
			if ability.self_target and card.base_stats == try_card.base_stats:
				if ability.limit_ingredients_int <= current_dish.count_ingredient_in_dish(try_card.base_stats):
					can_drop = false
			#if all ingr in dish target
			if ability.all_ingredients_in_dish_target:
				if ability.limit_ingredients_int <= current_dish.current_cards.size():
					can_drop = false
			
		# Here you could also check dish stats (sweet, spicy, counts, tags, etc.)
		
		# Handle duration / non‑continuous
		if not ability.continuous and !preview:
			t.remaining -= 1
			if t.remaining <= 0:
				dish_trigger.erase(t)
	
	return can_drop
func evaluate_encounter_end_triggers(source_card):
	for t in encounter_trigger.slice(0):
		var ability = t.ability
		var card = t.source_card
		
		var activates = false
		if !ability.end_encounter_cond:
			continue
		activate_effects(t, t.source_card)
		# Handle duration / non‑continuous
		if not ability.continuous:
			t.remaining -= 1
			if t.remaining <= 0:
				encounter_trigger.erase(t)

#endregion
#-----------------CONDITIONS_----------------------
#region Conditions

func on_ingredient_add_to_dish(card): #after adding own stats to dish
	#for each ability on new card checks if already active and adds if supposed to
	for ability:Ability in card.stats.abilities:
		if ability == null:
			continue
		#check if already active
		if dish_trigger_already_active(ability, card):
				#add to trigger_list if stackable
			if ability.stackable:
				add_ability_to_dish_trigger(ability, card, false)
			#else: do nothing, already active and not stackable
		else:
			#first time ability is called
			add_ability_to_dish_trigger(ability, card, false)
	evaluate_add_to_dish_triggers(card)

func on_try_add_ingredient_any_inventory(card):
	pass

func on_try_add_to_dish(card) -> bool:
	for ability:Ability in card.stats.abilities:
		if ability == null:
			continue
	return evaluate_try_add_to_dish_triggers(card, true)

func on_ingredient_destroyed_from_dish(card):
	for t in dish_trigger.slice(0):
		if t.source_card == card:
			dish_trigger.erase(t)
		#inventory abilities recheck
		
func on_encounter_end():
	for card in player_inventory.current_cards:
		for ability:Ability in card.stats.abilities:
			if ability == null:
				continue
			#check if already active
			if encounter_trigger_already_active(ability, card):
					#add to trigger_list if stackable
				if ability.stackable:
					add_ability_to_encounter_trigger(ability, card, false)
				#else: do nothing, already active and not stackable
			else:
				#first time ability is called
				add_ability_to_encounter_trigger(ability, card, false)
		evaluate_encounter_end_triggers(card)

func on_dish_complete():
	remove_all_from_dish_trigger()
	current_dish = null
	pass

func on_challenge_start(dish):
	current_dish = dish

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
		#add stat effects
		ability_card.stats.sweet += ability.sweet_effect
		ability_card.stats.spicy += ability.spicy_effect
		ability_card.stats.hearty += ability.hearty_effect
		ability_card.stats.fresh += ability.fresh_effect
		ability_card.stats.nutrition += ability.nutrition_effect
		
	#can be played
	
	if ability.played_ingredient_target:
		var apply_effects = true
		#check for target filters
		apply_effects = check_target_filter(trigger, context_card)
		#modify other cards stats
		if apply_effects:
			#add stat effects
			context_card.stats.sweet += ability.sweet_effect
			context_card.stats.spicy += ability.spicy_effect
			context_card.stats.hearty += ability.hearty_effect
			context_card.stats.fresh += ability.fresh_effect
			context_card.stats.nutrition += ability.nutrition_effect
	
	
	#-----------NON- PREVIEW EFFECTS-----------
	
	#self card effects
	if ability.self_target:
		if ability.uses_effect > 0:
			for i in ability.uses_effect:
				player_inventory.instantiate_card_and_add(ability_card.base_stats)
		if ability.uses_effect < 0:
			for i in ability.uses_effect * -1:
				player_inventory.remove_ingredient(ability_card)
	
	if ability.played_ingredient_target:
		if ability.uses_effect > 0:
			for i in ability.uses_effect:
				player_inventory.instantiate_card_and_add(ability_card.base_stats)
		if ability.uses_effect < 0:
			for i in ability.uses_effect * -1:
				player_inventory.remove_ingredient(ability_card)
# Example: add specific ingredients to player inventory
	for ingr: Ingredient in trigger.ability.add_specific_ingredients_effect:
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
		if not ability.dice_flavour_filter.is_empty():
			for flavour in ability.dice_flavour_filter:
				for ingr in current_dish.current_cards:
					for die in ingr.dice:
						if die.flavour == flavour:
							#if flavour filter applies
							if ability.reroll:
								current_dish.reroll_die(die)
							if ability.set_dice_number != 0:
								die.display_number(ability.set_dice_number)
				
		if not ability.dice_number_filter.is_empty():
			for number in ability.dice_number_filter:
				for card in current_dish.current_cards:
					for die in card.dice:
						if die.number == number:
							#if dice filter applies
							if ability.reroll:
								current_dish.reroll_die(die)
							if ability.set_dice_number != 0:
								die.display_number(ability.set_dice_number)
	#limit amount possible in dish
	
	# Extend here for other effects:
	# - modify dish stats
	# - modify dice
	# - morale/money changes via event_manager, etc

func check_target_filter(trigger, context_card) -> bool:
	var ability = trigger.ability
	var source_card = trigger.source_card
	
	if ability.played_ingredient_target:
		#Tags filter (OR)
		if not ability.card_tags_filter.is_empty():
			var card_tags: Array[GlobalEnums.Tags] = context_card.stats.tags  # ensure this exists
			var has_one = false
			for tag in card_tags:
				if ability.card_tags_filter.has(tag):
					has_one = true
					break
			if not has_one:
				return false
		#rarity filter
		if not ability.card_rarity_filter.is_empty():
			var card_rarity = context_card.stats.rarity  # ensure this exists
			var has_all = true
			if not ability.card_rarity_filter.has(card_rarity):
				return false
		#Ability filter (OR)
		if not ability.card_abilities_filter.is_empty():
			var card_abilities: Array[Ability] = context_card.stats.abilities  # ensure this exists
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
	
	return true

#endregion

#region Preview
func preview_card_abilities_add_dish(card, drag:bool = false):
	if current_dish == null:
		return
	#for each ability on new card checks if already active and adds if supposed to
	card.set_preview()
	for ability:Ability in card.stats.abilities:
		if ability == null:
			continue
		#check if already active
		if dish_trigger_already_active(ability, card):
				#add to trigger_list if stackable
			if ability.stackable:
				add_ability_to_dish_trigger(ability, card, true)
			#else: do nothing, already active and not stackable
		else:
			#first time ability is called
			add_ability_to_dish_trigger(ability, card, true)
	evaluate_add_to_dish_triggers(card, true, drag)

func stop_preview_add_to_dish():
	if current_dish == null:
		return
	for i in player_inventory.current_cards:
		i.reset_preview()
		preview_card_abilities_add_dish(i)
	for i in current_dish.current_cards:
		i.reset_preview()
	for t in dish_trigger:
		if t.preview == true:
			dish_trigger.erase(t)
	

func set_dice_preview_effects(trigger, context_card):
	var ability = trigger.ability
	var ability_card = trigger.source_card
	#-----------PREVIEW EFFECTS-----------
	if ability.all_dice_target:
		if not ability.dice_flavour_filter.is_empty():
			for flavour in ability.dice_flavour_filter:
				for ingr in current_dish.current_cards:
					for die in ingr.dice:
						if die.flavour == flavour:
							#if flavour filter applies
							if ability.reroll:
								die.set_preview()
							if ability.set_dice_number != 0:
								die.set_preview()
				
		if not ability.dice_number_filter.is_empty():
			for number in ability.dice_number_filter:
				for card in current_dish.current_cards:
					for die in card.dice:
						if die.number == number:
							#if dice filter applies
							if ability.reroll:
								die.set_preview()
							if ability.set_dice_number != 0:
								die.set_preview()

func set_card_preview_effects(trigger, context_card):
	var ability = trigger.ability
	var ability_card = trigger.source_card
	#-----------PREVIEW EFFECTS-----------
	#self card effects
	if ability.self_target:
		#modify own stats
		#add stat effects
		ability_card.stats.sweet += ability.sweet_effect
		ability_card.stats.spicy += ability.spicy_effect
		ability_card.stats.hearty += ability.hearty_effect
		ability_card.stats.fresh += ability.fresh_effect
		ability_card.stats.nutrition += ability.nutrition_effect
		
	#can be played
	
	if ability.played_ingredient_target:
		var apply_effects = true
		#check for target filters
		apply_effects = check_target_filter(trigger, context_card)
		#modify other cards stats
		if apply_effects:
			#add stat effects
			context_card.stats.sweet += ability.sweet_effect
			context_card.stats.spicy += ability.spicy_effect
			context_card.stats.hearty += ability.hearty_effect
			context_card.stats.fresh += ability.fresh_effect
			context_card.stats.nutrition += ability.nutrition_effect
	
	
#endregion
