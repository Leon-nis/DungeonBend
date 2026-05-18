import Dungeon/game_config as config
import Dungeon/Run/apply_swipe as apply_swipe
import Dungeon/UltimateCutins/duration_ticks_for_hero_ref as duration_ticks_for_hero_ref
import Dungeon as Dungeon
import Dungeon/App/state_helpers as M__Dungeon_App_state_helpers
import Dungeon/App/ui_fx as M__Dungeon_App_ui_fx
import Dungeon/rules as M__Dungeon_rules

def _state_from_advance(advance: Dungeon/RunAdvance, next_meta: Dungeon/Meta, current_run: Dungeon/Run, next_seed_value: U32, current_ui: Dungeon/UiState, dir: Dungeon/Direction) -> Dungeon/DungeonState:
  match advance:
    case keep_running{next_run}:
      Dungeon/App/state_helpers/_state(next_meta, running{next_run}, next_seed_value, Dungeon/App/ui_fx/_next_ui_from_turn(current_run, next_run, current_ui, dir))
    case end_run{next_run}:
      Dungeon/App/state_helpers/_state(next_meta, game_over{next_run}, next_seed_value, Dungeon/App/ui_fx/_next_ui_from_turn(current_run, next_run, current_ui, dir))

def _state_from_swipe(result: Dungeon/SwipeResult, current_run: Dungeon/Run, next_seed_value: U32, current_ui: Dungeon/UiState, dir: Dungeon/Direction) -> Dungeon/DungeonState:
  match result:
    case swipe_result{next_meta, next_advance}:
      _state_from_advance(Dungeon/App/ui_fx/_advance_with_charge(current_run, next_advance), next_meta, current_run, next_seed_value, current_ui, dir)

def _apply_turn(meta_state: Dungeon/Meta, run_value: Dungeon/Run, next_seed_value: U32, dir: Dungeon/Direction, current_ui: Dungeon/UiState) -> Dungeon/DungeonState:
  _state_from_swipe(apply_swipe(config(), meta_state, run_value, dir), run_value, next_seed_value, current_ui, dir)

def _run_hero_ref(run_value: Dungeon/Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      hero_ref

def _start_ultimate_cinematic(meta_state: Dungeon/Meta, run_value: Dungeon/Run, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  Dungeon/App/state_helpers/_state(meta_state, ultimate_cinematic{run_value, duration_ticks_for_hero_ref(_run_hero_ref(run_value))}, next_seed_value, ui_value)

def _ultimate_ready_charge_flag(charge_lt_required: U32) -> U32:
  match charge_lt_required:
    case 0:
      1
    case _:
      0

def _ultimate_ready_charge(ult_charge: U32) -> U32:
  _ultimate_ready_charge_flag(ult_charge < Dungeon/rules/ultimate_charge_required())

def _ultimate_ready_match(run_value: Dungeon/Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      _ultimate_ready_charge(ult_charge)

def _ultimate_ready(run_value: Dungeon/Run) -> U32:
  _ultimate_ready_match(run_value)

def _update_running_ultimate_ready(ultimate_ready_value: U32, meta_state: Dungeon/Meta, run_value: Dungeon/Run, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match ultimate_ready_value:
    case 0:
      Dungeon/App/state_helpers/_state(meta_state, running{run_value}, next_seed_value, ui_value)
    case _:
      _start_ultimate_cinematic(meta_state, run_value, next_seed_value, ui_value)

def _update_running_ultimate(meta_state: Dungeon/Meta, run_value: Dungeon/Run, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  _update_running_ultimate_ready(_ultimate_ready(run_value), meta_state, run_value, next_seed_value, ui_value)

def update_running(evt: Dungeon/DungeonEvent, meta_state: Dungeon/Meta, run_value: Dungeon/Run, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match evt:
    case damage_tick{}:
      Dungeon/App/state_helpers/_state(meta_state, running{run_value}, next_seed_value, Dungeon/App/ui_fx/_step_dungeon_fx(ui_value))
    case pause_dungeon{}:
      Dungeon/App/state_helpers/_state(meta_state, paused{run_value}, next_seed_value, ui_value)
    case ultimate{}:
      _update_running_ultimate(meta_state, run_value, next_seed_value, ui_value)
    case move{dir}:
      _apply_turn(meta_state, run_value, next_seed_value, dir, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, running{run_value}, next_seed_value, ui_value)
