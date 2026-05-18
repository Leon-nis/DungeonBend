import Dungeon/default_ui as default_ui
import Dungeon as Dungeon
import Dungeon/App/state_helpers as M__Dungeon_App_state_helpers

def _next_preview_fx(fx: Dungeon/UltimatePreviewFx) -> Dungeon/UltimatePreviewFx:
  match fx:
    case ultimate_preview_play_a{}:
      ultimate_preview_play_b{}
    case _:
      ultimate_preview_play_a{}

def update_ultimate_preview(evt: Dungeon/DungeonEvent, meta_state: Dungeon/Meta, fx: Dungeon/UltimatePreviewFx, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match evt:
    case close_ultimate_preview{}:
      Dungeon/App/state_helpers/_state(meta_state, setup{}, next_seed_value, default_ui())
    case play_ultimate_preview{}:
      Dungeon/App/state_helpers/_state(meta_state, ultimate_preview{_next_preview_fx(fx)}, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, ultimate_preview{fx}, next_seed_value, ui_value)
