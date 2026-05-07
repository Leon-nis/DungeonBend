import Dungeon/DeckEntry as DeckEntry
import Dungeon/Weapon as Weapon
import Dungeon/Board as Board
import Dungeon/BoardDraw as BoardDraw
import Dungeon/DrawResult as DrawResult
import Dungeon/Meta as Meta
import Dungeon/Run as Run
import Dungeon/RunStats as RunStats
import Dungeon/DungeonState as DungeonState
import Dungeon/config as config
import Dungeon/default_ui as default_ui
import Dungeon/Board/indexing/empty_board as empty_board
import Dungeon/Run/refill/_refill_non_hero_slots as _refill_non_hero_slots
import Dungeon/App/state_helpers/_state as _state
import Dungeon/Deck/spawn_and_draw/draw_tile as draw_tile
import Dungeon/run_stats_helpers/run_stats_record_path as run_stats_record_path
import Dungeon/ultimate_helpers/run_ultimate_kind as run_ultimate_kind
import Dungeon/ultimate_helpers/run_ultimate_state as run_ultimate_state
import Dungeon/ultimate_helpers/run_shadow_index as run_shadow_index
import Dungeon/shadow_step_helpers/board_after_shadow_return as board_after_shadow_return
import Dungeon/shadow_clone_helpers/find_anchor_index as find_anchor_index
import Dungeon/shadow_clone_helpers/board_after_clone_return as board_after_clone_return
import Dungeon/shadow_clone_helpers/merge_clone_return_hp as merge_clone_return_hp

def _ultimate_run_from_values(hero_hp: U32, hero_max_hp: U32, hero_index: U32, weapon_value: Weapon, deck_blueprint: List(DeckEntry), capacity: U32, hero_ref: U32, stats: RunStats, stage: BoardDraw) -> Run:
  match stage:
    case board_draw{next_board, next_counts, next_remaining, next_seed_value, next_level}:
      run{next_level, hero_hp, hero_max_hp, hero_index, weapon_value, next_board, deck_blueprint, next_counts, next_remaining, capacity, next_seed_value, 0, hero_ref, ultimate_state_idle{}, stats}

def _shadow_armed_run(run_value: Run) -> Run:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, 0, hero_ref, ultimate_state_projection_armed{}, stats}

def _shadow_idle_run(run_value: Run) -> Run:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, 0, hero_ref, ultimate_state_idle{}, stats}

def _shadow_return_run(run_value: Run, shadow_index: U32, result: DrawResult) -> Run:
  match run_value result:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats} draw_result{spawn, next_counts, next_remaining, next_seed_value, next_level}:
      run{next_level, hero_hp, hero_max_hp, shadow_index, weapon_value, board_after_shadow_return(board_value, hero_index, shadow_index, spawn), deck_blueprint, next_counts, next_remaining, capacity, next_seed_value, 0, hero_ref, ultimate_state_idle{}, run_stats_record_path(stats, shadow_index)}

def _shadow_clone_return_run(run_value: Run, anchor_index: U32, anchor_hp: U32, result: DrawResult) -> Run:
  match run_value result:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats} draw_result{spawn, next_counts, next_remaining, next_seed_value, next_level}:
      run{next_level, merge_clone_return_hp(anchor_hp, hero_hp), hero_max_hp, anchor_index, weapon_value, board_after_clone_return(board_value, hero_index, anchor_index, spawn), deck_blueprint, next_counts, next_remaining, capacity, next_seed_value, 0, hero_ref, ultimate_state_idle{}, run_stats_record_path(stats, anchor_index)}

def _use_shadow_ultimate(meta_state: Meta, run_value: Run, next_seed_value: U32) -> DungeonState:
  match run_ultimate_state(run_value):
    case ultimate_state_shadow_step_live{}:
      _use_shadow_return(meta_state, run_value, next_seed_value, run_shadow_index(run_value))
    case _:
      _state(meta_state, running{_shadow_armed_run(run_value)}, next_seed_value, default_ui())

def _use_shadow_return(meta_state: Meta, run_value: Run, next_seed_value: U32, shadow_index_maybe: Maybe(U32)) -> DungeonState:
  match shadow_index_maybe:
    case some{shadow_index}:
      _state(meta_state, running{_shadow_return_run(run_value, shadow_index, _shadow_return_draw(run_value))}, next_seed_value, default_ui())
    case none{}:
      _state(meta_state, running{_shadow_idle_run(run_value)}, next_seed_value, default_ui())

def _use_shadow_clone_ultimate(meta_state: Meta, run_value: Run, next_seed_value: U32) -> DungeonState:
  match run_ultimate_state(run_value):
    case ultimate_state_shadow_clone_live{anchor_hp}:
      _use_shadow_clone_return(meta_state, run_value, next_seed_value, anchor_hp, find_anchor_index(_run_board(run_value)))
    case _:
      _state(meta_state, running{_shadow_armed_run(run_value)}, next_seed_value, default_ui())

def _run_board(run_value: Run) -> Board:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      board_value

def _use_shadow_clone_return(meta_state: Meta, run_value: Run, next_seed_value: U32, anchor_hp: U32, anchor_index_maybe: Maybe(U32)) -> DungeonState:
  match anchor_index_maybe:
    case some{anchor_index}:
      _state(meta_state, running{_shadow_clone_return_run(run_value, anchor_index, anchor_hp, _shadow_return_draw(run_value))}, next_seed_value, default_ui())
    case none{}:
      _state(meta_state, running{_shadow_idle_run(run_value)}, next_seed_value, default_ui())

def _shadow_return_draw(run_value: Run) -> DrawResult:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      draw_tile(config(), deck_blueprint, draw_counts, remaining, seed, dungeon_level)

def use_ultimate(meta_state: Meta, run_value: Run, next_seed_value: U32) -> DungeonState:
  match run_ultimate_kind(run_value):
    case ultimate_shadow_step{}:
      _use_shadow_ultimate(meta_state, run_value, next_seed_value)
    case ultimate_shadow_clone{}:
      _use_shadow_clone_ultimate(meta_state, run_value, next_seed_value)
    case _:
      match run_value:
        case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
          stage = _refill_non_hero_slots(config(), empty_board(), hero_index, deck_blueprint, draw_counts, remaining, seed, dungeon_level);
          _state(meta_state, running{_ultimate_run_from_values(hero_hp, hero_max_hp, hero_index, weapon_value, deck_blueprint, capacity, hero_ref, stats, stage)}, next_seed_value, default_ui())
