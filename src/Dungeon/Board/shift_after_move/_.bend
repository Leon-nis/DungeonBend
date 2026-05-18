import Dungeon as Dungeon
import Dungeon/Board/indexing as M__Dungeon_Board_indexing

def _shift_after_move_back(board_value: Dungeon/Board, board1: Dungeon/Board, hero_pos: Nat/V2, back: Maybe(Nat/V2), spawn: Dungeon/Tile) -> Dungeon/Board:
  match back:
    case none{}:
      Dungeon/Board/indexing/board_set_pos(board1, hero_pos, spawn)
    case some{back_pos_value}:
      back_tile = Dungeon/Board/indexing/board_get_pos(board_value, back_pos_value);
      board2 = Dungeon/Board/indexing/board_set_pos(board1, hero_pos, back_tile);
      Dungeon/Board/indexing/board_set_pos(board2, back_pos_value, spawn)

def shift_after_move(board_value: Dungeon/Board, hero_index: U32, target_index: U32, dir: Dungeon/Direction, spawn: Dungeon/Tile) -> Dungeon/Board:
  _shift_after_move_back(
    board_value,
    Dungeon/Board/indexing/board_set_pos(board_value, Dungeon/Board/indexing/board_pos(target_index), none{}),
    Dungeon/Board/indexing/board_pos(hero_index),
    Dungeon/Board/indexing/back_pos(hero_index, dir),
    spawn
  )
