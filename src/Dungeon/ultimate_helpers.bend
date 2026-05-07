import Dungeon/Run as Run
import Dungeon/Board as Board
import Dungeon/UltimateKind as UltimateKind
import Dungeon/UltimateState as UltimateState
import Dungeon/config as config
import Dungeon/hero_helpers/hero_at as hero_at
import Dungeon/hero_helpers/hero_ultimate_kind as hero_ultimate_kind
import Dungeon/hero_helpers/hero_ultimate_charge_required as hero_ultimate_charge_required
import Dungeon/shadow_step_helpers/find_shadow_index as find_shadow_index

def _run_hero_ref(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      hero_ref

def _run_board(run_value: Run) -> Board:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      board_value

def run_ultimate_kind(run_value: Run) -> UltimateKind:
  hero_ultimate_kind(hero_at(config(), _run_hero_ref(run_value)))

def run_ultimate_charge_required(run_value: Run) -> U32:
  hero_ultimate_charge_required(hero_at(config(), _run_hero_ref(run_value)))

def run_ultimate_state(run_value: Run) -> UltimateState:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      ultimate_state

def run_with_ultimate_charge(run_value: Run, next_ult_charge: U32) -> Run:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, next_ult_charge, hero_ref, ultimate_state, stats}

def run_with_ultimate_state(run_value: Run, next_ultimate_state: UltimateState) -> Run:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, next_ultimate_state, stats}

def run_with_ultimate_values(run_value: Run, next_ult_charge: U32, next_ultimate_state: UltimateState) -> Run:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, next_ult_charge, hero_ref, next_ultimate_state, stats}

def ultimate_kind_is_shadow(ultimate_kind: UltimateKind) -> U32:
  match ultimate_kind:
    case ultimate_shadow_step{}:
      1
    case _:
      0

def ultimate_state_is_idle(ultimate_state: UltimateState) -> U32:
  match ultimate_state:
    case ultimate_state_idle{}:
      1
    case _:
      0

def ultimate_state_is_shadow_armed(ultimate_state: UltimateState) -> U32:
  match ultimate_state:
    case ultimate_state_shadow_armed{}:
      1
    case _:
      0

def ultimate_state_is_shadow_live(ultimate_state: UltimateState) -> U32:
  match ultimate_state:
    case ultimate_state_shadow_live{}:
      1
    case _:
      0

def run_can_gain_ultimate_charge(run_value: Run) -> U32:
  _run_can_gain_shadow(ultimate_kind_is_shadow(run_ultimate_kind(run_value)), run_ultimate_state(run_value))

def _run_can_gain_shadow(is_shadow: U32, ultimate_state: UltimateState) -> U32:
  match is_shadow:
    case 0:
      1
    case _:
      ultimate_state_is_idle(ultimate_state)

def run_ultimate_ready(run_value: Run) -> U32:
  _run_ultimate_ready_shadow(ultimate_kind_is_shadow(run_ultimate_kind(run_value)), run_ultimate_state(run_value), run_ultimate_charge_required(run_value), _run_ult_charge(run_value))

def _run_ult_charge(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      ult_charge

def _run_ultimate_ready_shadow(is_shadow: U32, ultimate_state: UltimateState, required_charge: U32, current_charge: U32) -> U32:
  match is_shadow:
    case 0:
      _charge_ready(required_charge, current_charge)
    case _:
      _shadow_ready(ultimate_state, required_charge, current_charge)

def _shadow_ready(ultimate_state: UltimateState, required_charge: U32, current_charge: U32) -> U32:
  match ultimate_state:
    case ultimate_state_shadow_live{}:
      1
    case ultimate_state_shadow_armed{}:
      0
    case ultimate_state_idle{}:
      _charge_ready(required_charge, current_charge)

def _charge_ready(required_charge: U32, current_charge: U32) -> U32:
  _charge_ready_flag(current_charge < required_charge)

def _charge_ready_flag(charge_lt_required: U32) -> U32:
  match charge_lt_required:
    case 0:
      1
    case _:
      0

def run_shadow_index(run_value: Run) -> Maybe(U32):
  find_shadow_index(_run_board(run_value))
