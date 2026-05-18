import Dungeon/game_config as config
import Dungeon/default_ui as default_ui
import Dungeon as Dungeon
import Dungeon/App/state_helpers as M__Dungeon_App_state_helpers
import Dungeon/Run/upgrade_hero as M__Dungeon_Run_upgrade_hero
import Dungeon/hero_helpers as M__Dungeon_hero_helpers
import Dungeon/profile_helpers as M__Dungeon_profile_helpers

def _preview_profile(meta_state: Dungeon/Meta, hero_ref: U32, next_seed_value: U32, ui_value: Dungeon/UiState, profile: Dungeon/HeroProfile) -> Dungeon/DungeonState:
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      Dungeon/App/state_helpers/_state(meta_state, character_select{hero_ref}, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(Dungeon/profile_helpers/set_selection_confirmed(Dungeon/profile_helpers/set_selected_hero(meta_state, hero_ref), 1), character_select{hero_ref}, next_seed_value, default_ui())

def _preview_character(meta_state: Dungeon/Meta, hero_ref: U32, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  _preview_profile(meta_state, hero_ref, next_seed_value, ui_value, Dungeon/profile_helpers/profile_for_hero(meta_state, hero_ref))

def _upgrade_preview_character(meta_state: Dungeon/Meta, hero_ref: U32, next_seed_value: U32) -> Dungeon/DungeonState:
  Dungeon/App/state_helpers/_state(Dungeon/Run/upgrade_hero/upgrade_hero_ref(config(), meta_state, hero_ref), character_select{hero_ref}, next_seed_value, default_ui())

def update_character_select(evt: Dungeon/DungeonEvent, meta_state: Dungeon/Meta, preview_hero: U32, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match evt:
    case move{left{}}:
      _preview_character(meta_state, Dungeon/hero_helpers/prev_hero_ref(config(), preview_hero), next_seed_value, ui_value)
    case move{right{}}:
      _preview_character(meta_state, Dungeon/hero_helpers/next_hero_ref(config(), preview_hero), next_seed_value, ui_value)
    case preview_character{ref}:
      _preview_character(meta_state, Dungeon/hero_helpers/normalize_hero_ref(config(), ref), next_seed_value, ui_value)
    case upgrade{}:
      _upgrade_preview_character(meta_state, Dungeon/hero_helpers/normalize_hero_ref(config(), preview_hero), next_seed_value)
    case select_character{}:
      Dungeon/App/state_helpers/_state(meta_state, character_select{preview_hero}, next_seed_value, ui_value)
    case open_boosters{}:
      Dungeon/App/state_helpers/_state(meta_state, boosters{no_pack_reward{}, 0, booster_return_character_select{preview_hero}}, next_seed_value, default_ui())
    case close_character_select{}:
      Dungeon/App/state_helpers/_state(meta_state, setup{}, next_seed_value, default_ui())
    case _:
      Dungeon/App/state_helpers/_state(meta_state, character_select{preview_hero}, next_seed_value, ui_value)
