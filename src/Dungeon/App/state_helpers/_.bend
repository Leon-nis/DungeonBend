def state_helpers() -> Unit:
  unit{}

import Dungeon/game_config as config
import Dungeon/default_ui as default_ui
import Dungeon/Run/start_run as start_run
import Dungeon as Dungeon
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick

def _state(meta_state: Dungeon/Meta, scene_value: Dungeon/Scene, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  dungeon{game_state{meta_state, scene_value, next_seed_value}, ui_value}

def _start(meta_state: Dungeon/Meta, seed: U32) -> Dungeon/DungeonState:
  _state(meta_state, running{start_run(config(), meta_state, seed)}, Dungeon/Deck/counts_pick/next_seed(seed), default_ui())
