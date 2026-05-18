import Dungeon/App/use_ultimate as use_ultimate
import Dungeon as Dungeon
import Dungeon/App/state_helpers as M__Dungeon_App_state_helpers
import Dungeon/App/ui_fx as M__Dungeon_App_ui_fx

def _advance_ultimate_cinematic_done(done: U32, meta_state: Dungeon/Meta, run_value: Dungeon/Run, ticks_remaining: U32, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match done:
    case 0:
      Dungeon/App/state_helpers/_state(meta_state, ultimate_cinematic{run_value, ticks_remaining - 1}, next_seed_value, ui_value)
    case _:
      use_ultimate(meta_state, run_value, next_seed_value)

def _advance_ultimate_cinematic(meta_state: Dungeon/Meta, run_value: Dungeon/Run, ticks_remaining: U32, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  _advance_ultimate_cinematic_done(ticks_remaining < 2, meta_state, run_value, ticks_remaining, next_seed_value, ui_value)

def update_ultimate_cinematic(evt: Dungeon/DungeonEvent, meta_state: Dungeon/Meta, run_value: Dungeon/Run, ticks_remaining: U32, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match evt:
    case damage_tick{}:
      _advance_ultimate_cinematic(meta_state, run_value, ticks_remaining, next_seed_value, Dungeon/App/ui_fx/_step_dungeon_fx(ui_value))
    case _:
      Dungeon/App/state_helpers/_state(meta_state, ultimate_cinematic{run_value, ticks_remaining}, next_seed_value, ui_value)
