import App as App
import Dungeon/initial_game as initial_game
import Dungeon/default_ui as default_ui
import Dungeon/_parse_meta as _parse_meta
import Dungeon as Dungeon

init : App/Update(Dungeon/DungeonState, Dungeon/DungeonEvent) =
  update{dungeon{initial_game(), default_ui()}, store_get{"dungeon_meta", _parse_meta, no_save{}}}
