import HTML as HTML
import Dungeon as Dungeon
import Dungeon/View/frame as M__Dungeon_View_frame

def render(state: Dungeon/DungeonState) -> HTML(Dungeon/DungeonEvent):
  match state:
    case dungeon{game_state{meta_state, scene_value, next_seed_value}, ui_value}:
      Dungeon/View/frame/_frame(Dungeon/View/frame/_screen_root(meta_state, scene_value, ui_value))
