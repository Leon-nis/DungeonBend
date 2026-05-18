import App as App
import Dungeon as Dungeon
import Dungeon/App/scene_flow as M__Dungeon_App_scene_flow
import Dungeon/App/persistence as M__Dungeon_App_persistence

def on_event(evt: Dungeon/DungeonEvent, state: Dungeon/DungeonState) -> App/Update(Dungeon/DungeonState, Dungeon/DungeonEvent):
  next = Dungeon/App/scene_flow/_next_state(evt, state);
  Dungeon/App/persistence/finalize_update(evt, state, next)
