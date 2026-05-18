import Dungeon/game_config as config
import Dungeon/default_ui as default_ui
import Dungeon as Dungeon
import Dungeon/Board/indexing as M__Dungeon_Board_indexing
import Dungeon/Run/refill as M__Dungeon_Run_refill
import Dungeon/App/state_helpers as M__Dungeon_App_state_helpers

def _ultimate_run_from_values(hero_hp: U32, hero_max_hp: U32, hero_index: U32, weapon_value: Dungeon/Weapon, deck_blueprint: List(Dungeon/DeckEntry), capacity: U32, hero_ref: U32, stage: Dungeon/BoardDraw) -> Dungeon/Run:
  match stage:
    case board_draw{next_board, next_counts, next_remaining, next_seed_value, next_level}:
      run{next_level, hero_hp, hero_max_hp, hero_index, weapon_value, next_board, deck_blueprint, next_counts, next_remaining, capacity, next_seed_value, 0, hero_ref}

def use_ultimate(meta_state: Dungeon/Meta, run_value: Dungeon/Run, next_seed_value: U32) -> Dungeon/DungeonState:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      stage = Dungeon/Run/refill/_refill_non_hero_slots(config(), Dungeon/Board/indexing/empty_board(), hero_index, deck_blueprint, draw_counts, remaining, seed, dungeon_level);
      Dungeon/App/state_helpers/_state(meta_state, running{_ultimate_run_from_values(hero_hp, hero_max_hp, hero_index, weapon_value, deck_blueprint, capacity, hero_ref, stage)}, next_seed_value, default_ui())
