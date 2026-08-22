extends Node
#STATE
@export var debug_inactive:bool = false
@export_group("Leftovers")
@export var leftovers_bone:Ingredient

#CACHED COMPS
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
#STATE
var dish_trigger:Array
var dish_next_ingredient_trigger:Array
var current_dish
#SIGNALS
#------------ACTIVE TRACKING-----------------------
#region Tracking
#DISH
func add_ability_to_dish_trigger(ability, card):
	dish_trigger.append([ability, card, ability.duration])
func remove_ability_from_dish_trigger(ability, card):
	dish_trigger.erase([ability, card, ability.duration])
func remove_all_from_dish_trigger():
	dish_trigger.clear()
func dish_trigger_already_active(ability, card) -> bool:
	for actives in dish_trigger:
		if actives[0] == ability and actives[1] == card:
			#is already in list
			return true
	return false

func check_dish_ability_stackable(ability,card) -> bool:
	if ability.stackable:
		return true
	return false
	
func check_dish_ability_activates(ability, card) ->bool: #checks if conditions are met to activate triggers
	return false
	
#endregion
#-----------------CONDITIONS_----------------------
#region Conditions

func on_ingredient_add_to_dish(card): #after adding own stats to dish
	#for each ability on new card checks if already active and adds if supposed to
	for ability in card.stats.abilities:
		#check if already active
		if dish_trigger_already_active(ability, card):
				#add to trigger_list if stackable
			if check_dish_ability_stackable(ability, card):
				add_ability_to_dish_trigger(ability, card)
		else:
			#first time ability is called
			add_ability_to_dish_trigger(ability, card)

#cycle through triggers and check if they activate
	for trigger in dish_trigger:
		var activates = false
		#check if this card was added now
		if trigger[0].this_add_to_dish_cond and trigger[1] == card:
			activates = true
		#check if this triggers when any card is added
		if trigger[0].any_add_to_dish_cond:
			activates = true
			#If trigger with next ability and this is the card
		if trigger[0].next_ingredient_target and trigger[1] == card:
			activates = false
		if trigger[0].next_ingredient_target and trigger[1] != card:
			activates = true

		if activates:
			activate_effects(trigger[0])
			#if ability not continuous delete from trigger list
			if !trigger[0].continuous:
				trigger[2] -= 1
				if trigger[2] <= 0:
					remove_ability_from_dish_trigger(trigger[0], trigger[1])

func on_try_add_ingredient_any_inventory(card):
	pass

func on_try_add_to_dish(card):
	return true

func on_ingredient_destroyed_from_dish(card):
	if debug_inactive:
		return
	for i in dish_trigger:
		if i[1] == card:
			dish_trigger.erase(i)
		#inventory abilities recheck

func on_encounter_end():
	pass

func on_dish_complete():
	remove_all_from_dish_trigger()
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

func activate_effects(ability):
	pass

#endregion
