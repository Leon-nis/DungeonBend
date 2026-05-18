import Dungeon/game_config as config
import Dungeon/default_ui as default_ui
import Dungeon as Dungeon
import Dungeon/App/state_helpers as M__Dungeon_App_state_helpers
import Dungeon/App/ui_fx as M__Dungeon_App_ui_fx
import Dungeon/hero_helpers as M__Dungeon_hero_helpers
import Dungeon/profile_helpers as M__Dungeon_profile_helpers

def update_setup(evt: Dungeon/DungeonEvent, meta_state: Dungeon/Meta, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match evt:
    case damage_tick{}:
      Dungeon/App/state_helpers/_state(meta_state, setup{}, next_seed_value, Dungeon/App/ui_fx/_step_menu_fx(ui_value))
    case start{}:
      Dungeon/App/state_helpers/_start(meta_state, next_seed_value)
    case open_character_select{}:
      Dungeon/App/state_helpers/_state(meta_state, character_select{Dungeon/hero_helpers/normalize_hero_ref(config(), Dungeon/profile_helpers/selected_hero(meta_state))}, next_seed_value, default_ui())
    case open_ultimate_preview{}:
      Dungeon/App/state_helpers/_state(meta_state, ultimate_preview{ultimate_preview_idle{}}, next_seed_value, default_ui())
    case open_boosters{}:
      Dungeon/App/state_helpers/_state(meta_state, boosters{no_pack_reward{}, 0, booster_return_setup{}}, next_seed_value, default_ui())
    case open_deck_list{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{deck_list_view{}, sleeve_picker_closed{}}, next_seed_value, default_ui())
    case _:
      Dungeon/App/state_helpers/_state(meta_state, setup{}, next_seed_value, ui_value)
