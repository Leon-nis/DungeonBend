import Dungeon/default_meta as default_meta
import Dungeon/initial_seed as initial_seed
import Dungeon as Dungeon

def initial_game() -> Dungeon/GameState:
  game_state{default_meta(), setup{}, initial_seed()}
