import Dungeon/DeckEntry as DeckEntry
import Dungeon/Weapon as Weapon
import Dungeon/BoardDraw as BoardDraw
import Dungeon/DrawResult as DrawResult
import Dungeon/Meta as Meta
import Dungeon/Run as Run
import Dungeon/DungeonState as DungeonState
import Dungeon/config as config
import Dungeon/default_ui as default_ui
import Dungeon/Board/indexing/empty_board as empty_board
import Dungeon/Run/refill/_refill_non_hero_slots as _refill_non_hero_slots
import Dungeon/App/state_helpers/_state as _state
import Dungeon/Deck/spawn_and_draw/draw_tile as draw_tile
import Dungeon/ultimate_helpers/run_ultimate_kind as run_ultimate_kind
import Dungeon/ultimate_helpers/run_ultimate_state as run_ultimate_state
import Dungeon/ultimate_helpers/run_shadow_index as run_shadow_index
import Dungeon/shadow_step_helpers/board_after_shadow_return as board_after_shadow_return

def _ultimate_run_from_values(hero_hp: U32, hero_max_hp: U32, hero_index: U32, weapon_value: Weapon, deck_blueprint: List(DeckEntry), capacity: U32, hero_ref: U32, stage: BoardDraw) -> Run:
  match stage:
    case board_draw{next_board, next_counts, next_remaining, next_seed_value, next_level}:
      run{next_level, hero_hp, hero_max_hp, hero_index, weapon_value, next_board, deck_blueprint, next_counts, next_remaining, capacity, next_seed_value, 0, hero_ref, ultimate_state_idle{}}

def _shadow_armed_run(run_value: Run) -> Run:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state}:
      run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, 0, hero_ref, ultimate_state_shadow_armed{}}

def _shadow_idle_run(run_value: Run) -> Run:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state}:
      run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, 0, hero_ref, ultimate_state_idle{}}

def _shadow_return_run(run_value: Run, shadow_index: U32, result: DrawResult) -> Run:
  match run_value result:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state} draw_result{spawn, next_counts, next_remaining, next_seed_value, next_level}:
      run{next_level, hero_hp, hero_max_hp, shadow_index, weapon_value, board_after_shadow_return(board_value, hero_index, shadow_index, spawn), deck_blueprint, next_counts, next_remaining, capacity, next_seed_value, 0, hero_ref, ultimate_state_idle{}}

def _use_shadow_ultimate(meta_state: Meta, run_value: Run, next_seed_value: U32) -> DungeonState:
  match run_ultimate_state(run_value):
    case ultimate_state_shadow_live{}:
      _use_shadow_return(meta_state, run_value, next_seed_value, run_shadow_index(run_value))
    case _:
      _state(meta_state, running{_shadow_armed_run(run_value)}, next_seed_value, default_ui())

def _use_shadow_return(meta_state: Meta, run_value: Run, next_seed_value: U32, shadow_index_maybe: Maybe(U32)) -> DungeonState:
  match shadow_index_maybe:
    case some{shadow_index}:
      _state(meta_state, running{_shadow_return_run(run_value, shadow_index, _shadow_return_draw(run_value))}, next_seed_value, default_ui())
    case none{}:
      _state(meta_state, running{_shadow_idle_run(run_value)}, next_seed_value, default_ui())

def _shadow_return_draw(run_value: Run) -> DrawResult:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state}:
      draw_tile(config(), deck_blueprint, draw_counts, remaining, seed, dungeon_level)

def use_ultimate(meta_state: Meta, run_value: Run, next_seed_value: U32) -> DungeonState:
  match run_ultimate_kind(run_value):
    case ultimate_shadow_step{}:
      _use_shadow_ultimate(meta_state, run_value, next_seed_value)
    case _:
      match run_value:
        case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state}:
          stage = _refill_non_hero_slots(config(), empty_board(), hero_index, deck_blueprint, draw_counts, remaining, seed, dungeon_level);
          _state(meta_state, running{_ultimate_run_from_values(hero_hp, hero_max_hp, hero_index, weapon_value, deck_blueprint, capacity, hero_ref, stage)}, next_seed_value, default_ui())
