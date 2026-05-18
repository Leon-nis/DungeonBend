def persistence() -> Unit:
  unit{}

import App as App
import Dungeon/save_to_string as save_to_string
import Dungeon as Dungeon

def finalize_update(evt: Dungeon/DungeonEvent, prev_state: Dungeon/DungeonState, next_state: Dungeon/DungeonState) -> App/Update(Dungeon/DungeonState, Dungeon/DungeonEvent):
  match evt:
    case damage_tick{}:
      update{next_state, none{}}
    case ignore{}:
      update{next_state, none{}}
    case no_save{}:
      update{next_state, none{}}
    case _:
      update{next_state, store_set{"dungeon_meta", save_to_string(next_state), ignore{}}}
