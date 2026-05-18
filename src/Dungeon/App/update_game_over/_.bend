import Dungeon/default_ui as default_ui
import Dungeon as Dungeon
import Dungeon/App/state_helpers as M__Dungeon_App_state_helpers
import Dungeon/App/ui_fx as M__Dungeon_App_ui_fx

def update_game_over(evt: Dungeon/DungeonEvent, meta_state: Dungeon/Meta, run_value: Dungeon/Run, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match evt:
    case damage_tick{}:
      Dungeon/App/state_helpers/_state(meta_state, game_over{run_value}, next_seed_value, Dungeon/App/ui_fx/_step_dungeon_fx(ui_value))
    case ok{}:
      Dungeon/App/state_helpers/_state(meta_state, setup{}, next_seed_value, default_ui())
    case _:
      Dungeon/App/state_helpers/_state(meta_state, game_over{run_value}, next_seed_value, ui_value)
