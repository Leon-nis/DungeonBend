def rules() -> Unit:
  unit{}

import Dungeon/generated_rules as M__Dungeon_generated_rules

def initial_seed_value() -> U32:
  Dungeon/generated_rules/generated_initial_seed()

def starting_gold() -> U32:
  Dungeon/generated_rules/generated_starting_gold()

def starting_selected_hero() -> U32:
  Dungeon/generated_rules/generated_starting_selected_hero()

def starting_selection_confirmed() -> U32:
  Dungeon/generated_rules/generated_starting_selection_confirmed()

def starting_dungeon_level() -> U32:
  Dungeon/generated_rules/generated_starting_dungeon_level()

def dungeon_level_increment_per_refill() -> U32:
  Dungeon/generated_rules/generated_dungeon_level_increment_per_refill()

def ultimate_charge_required() -> U32:
  Dungeon/generated_rules/generated_ultimate_charge_required()

def ultimate_charge_per_move() -> U32:
  Dungeon/generated_rules/generated_ultimate_charge_per_move()
