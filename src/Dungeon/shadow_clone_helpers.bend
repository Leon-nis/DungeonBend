import Dungeon/Board as Board
import Dungeon/Tile as Tile
import Dungeon/Board/indexing/board_get as board_get
import Dungeon/Board/indexing/board_set as board_set

def board_with_anchor_origin(board_value: Board, hero_ref: U32, hero_index: U32, target_index: U32) -> Board:
  board1 = board_set(board_value, target_index, none{});
  board_set(board1, hero_index, anchor_hero{hero_ref})

def board_with_anchor_slot(board_value: Board, hero_ref: U32, hero_index: U32) -> Board:
  board_set(board_value, hero_index, anchor_hero{hero_ref})

def board_after_clone_return(board_value: Board, shadow_index: U32, anchor_index: U32, spawn: Tile) -> Board:
  board1 = board_set(board_value, anchor_index, none{});
  board_set(board1, shadow_index, spawn)

def board_after_clone_faint(board_value: Board, shadow_index: U32, anchor_index: U32, spawn: Tile) -> Board:
  board1 = board_set(board_value, anchor_index, none{});
  board_set(board1, shadow_index, spawn)

def find_anchor_index(board_value: Board) -> Maybe(U32):
  _find_anchor_index(board_value, 0)

def _find_anchor_index(board_value: Board, idx: U32) -> Maybe(U32):
  match idx:
    case 9:
      none{}
    case _:
      _find_anchor_index_tile(board_get(board_value, idx), board_value, idx)

def _find_anchor_index_tile(tile_value: Tile, board_value: Board, idx: U32) -> Maybe(U32):
  match tile_value:
    case anchor_hero{hero_ref}:
      some{idx}
    case _:
      _find_anchor_index(board_value, idx + 1)

def merge_clone_return_hp(anchor_hp: U32, shadow_hp: U32) -> U32:
  _merge_clone_return_hp_shadow(shadow_hp > anchor_hp, anchor_hp, shadow_hp)

def _merge_clone_return_hp_shadow(shadow_above_anchor: U32, anchor_hp: U32, shadow_hp: U32) -> U32:
  match shadow_above_anchor:
    case 0:
      anchor_hp
    case _:
      shadow_hp
