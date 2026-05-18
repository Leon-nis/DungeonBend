import Dungeon/meta_to_string as meta_to_string
import Dungeon as Dungeon
import Dungeon/run_snapshot_to_string as M__Dungeon_run_snapshot_to_string

def _saved_scene_kind(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      "1"
    case running{run_value}:
      "1"
    case paused{run_value}:
      "1"
    case resume_prompt{run_value}:
      "1"
    case _:
      "0"

def _saved_run_core(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      Dungeon/run_snapshot_to_string/run_core_string(run_value)
    case running{run_value}:
      Dungeon/run_snapshot_to_string/run_core_string(run_value)
    case paused{run_value}:
      Dungeon/run_snapshot_to_string/run_core_string(run_value)
    case resume_prompt{run_value}:
      Dungeon/run_snapshot_to_string/run_core_string(run_value)
    case _:
      ""

def _saved_run_weapon(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      Dungeon/run_snapshot_to_string/run_weapon_string(run_value)
    case running{run_value}:
      Dungeon/run_snapshot_to_string/run_weapon_string(run_value)
    case paused{run_value}:
      Dungeon/run_snapshot_to_string/run_weapon_string(run_value)
    case resume_prompt{run_value}:
      Dungeon/run_snapshot_to_string/run_weapon_string(run_value)
    case _:
      "0"

def _saved_run_board(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      Dungeon/run_snapshot_to_string/run_board_string(run_value)
    case running{run_value}:
      Dungeon/run_snapshot_to_string/run_board_string(run_value)
    case paused{run_value}:
      Dungeon/run_snapshot_to_string/run_board_string(run_value)
    case resume_prompt{run_value}:
      Dungeon/run_snapshot_to_string/run_board_string(run_value)
    case _:
      ""

def _saved_run_blueprint(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      Dungeon/run_snapshot_to_string/run_blueprint_string(run_value)
    case running{run_value}:
      Dungeon/run_snapshot_to_string/run_blueprint_string(run_value)
    case paused{run_value}:
      Dungeon/run_snapshot_to_string/run_blueprint_string(run_value)
    case resume_prompt{run_value}:
      Dungeon/run_snapshot_to_string/run_blueprint_string(run_value)
    case _:
      ""

def _saved_run_counts(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      Dungeon/run_snapshot_to_string/run_counts_string(run_value)
    case running{run_value}:
      Dungeon/run_snapshot_to_string/run_counts_string(run_value)
    case paused{run_value}:
      Dungeon/run_snapshot_to_string/run_counts_string(run_value)
    case resume_prompt{run_value}:
      Dungeon/run_snapshot_to_string/run_counts_string(run_value)
    case _:
      ""

def save_to_string(state: Dungeon/DungeonState) -> String:
  match state:
    case dungeon{game_state{meta_state, scene_value, next_seed}, ui_value}:
      String/join(
        [
          meta_to_string(meta_state),
          U32/show(next_seed),
          _saved_scene_kind(scene_value),
          _saved_run_core(scene_value),
          _saved_run_weapon(scene_value),
          _saved_run_board(scene_value),
          _saved_run_blueprint(scene_value),
          _saved_run_counts(scene_value)
        ],
        "|"
      )
