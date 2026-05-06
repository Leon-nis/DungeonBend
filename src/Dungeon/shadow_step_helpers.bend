import Dungeon/Board as Board
import Dungeon/Tile as Tile
import Dungeon/Board/indexing/board_get as board_get
import Dungeon/Board/indexing/board_set as board_set

def board_with_shadow_origin(board_value: Board, hero_index: U32, target_index: U32) -> Board:
  board1 = board_set(board_value, target_index, none{});
  board_set(board1, hero_index, shadow{})

def board_after_shadow_return(board_value: Board, hero_index: U32, shadow_index: U32, spawn: Tile) -> Board:
  board1 = board_set(board_value, shadow_index, none{});
  board_set(board1, hero_index, spawn)

def find_shadow_index(board_value: Board) -> Maybe(U32):
  _find_shadow_index(board_value, 0)

def _find_shadow_index(board_value: Board, idx: U32) -> Maybe(U32):
  match idx:
    case 9:
      none{}
    case _:
      _find_shadow_index_tile(board_get(board_value, idx), board_value, idx)

def _find_shadow_index_tile(tile_value: Tile, board_value: Board, idx: U32) -> Maybe(U32):
  match tile_value:
    case shadow{}:
      some{idx}
    case _:
      _find_shadow_index(board_value, idx + 1)
