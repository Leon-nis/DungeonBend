def refill() -> Unit:
  unit{}

import Dungeon as Dungeon
import Dungeon/Deck/spawn_and_draw as M__Dungeon_Deck_spawn_and_draw
import Dungeon/Board/indexing as M__Dungeon_Board_indexing

def _draw_into_slot(board_value: Dungeon/Board, slot: U32, result: Dungeon/DrawResult) -> Dungeon/BoardDraw:
  match result:
    case draw_result{tile, next_counts, next_remaining, next_seed, next_level}:
      board_draw{Dungeon/Board/indexing/board_set(board_value, slot, tile), next_counts, next_remaining, next_seed, next_level}

def _draw_step(config_value: Dungeon/Config, board_value: Dungeon/Board, slot: U32, deck_blueprint: List(Dungeon/DeckEntry), draw_counts: List(Dungeon/DeckEntry), remaining: U32, seed: U32, level: U32) -> Dungeon/BoardDraw:
  _draw_into_slot(board_value, slot, Dungeon/Deck/spawn_and_draw/draw_tile(config_value, deck_blueprint, draw_counts, remaining, seed, level))

def _draw_non_hero_step_match(is_hero_slot: U32, config_value: Dungeon/Config, board_value: Dungeon/Board, slot: U32, blueprint: List(Dungeon/DeckEntry), counts: List(Dungeon/DeckEntry), remaining: U32, seed: U32, level: U32) -> Dungeon/BoardDraw:
  match is_hero_slot:
    case 0:
      _draw_step(config_value, board_value, slot, blueprint, counts, remaining, seed, level)
    case _:
      board_draw{board_value, counts, remaining, seed, level}

def _draw_non_hero_step(config_value: Dungeon/Config, hero_index: U32, slot: U32, blueprint: List(Dungeon/DeckEntry), stage: Dungeon/BoardDraw) -> Dungeon/BoardDraw:
  match stage:
    case board_draw{board_value, counts, remaining, seed, level}:
      _draw_non_hero_step_match(slot === hero_index, config_value, board_value, slot, blueprint, counts, remaining, seed, level)

def _refill_after_8(config_value: Dungeon/Config, hero_index: U32, blueprint: List(Dungeon/DeckEntry), stage: Dungeon/BoardDraw) -> Dungeon/BoardDraw:
  match stage:
    case board_draw{board8, counts8, remaining8, seed8, level8}:
      _draw_non_hero_step(config_value, hero_index, 8, blueprint, board_draw{board8, counts8, remaining8, seed8, level8})

def _refill_after_7(config_value: Dungeon/Config, hero_index: U32, blueprint: List(Dungeon/DeckEntry), stage: Dungeon/BoardDraw) -> Dungeon/BoardDraw:
  match stage:
    case board_draw{board7, counts7, remaining7, seed7, level7}:
      _refill_after_8(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 7, blueprint, board_draw{board7, counts7, remaining7, seed7, level7}))

def _refill_after_6(config_value: Dungeon/Config, hero_index: U32, blueprint: List(Dungeon/DeckEntry), stage: Dungeon/BoardDraw) -> Dungeon/BoardDraw:
  match stage:
    case board_draw{board6, counts6, remaining6, seed6, level6}:
      _refill_after_7(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 6, blueprint, board_draw{board6, counts6, remaining6, seed6, level6}))

def _refill_after_5(config_value: Dungeon/Config, hero_index: U32, blueprint: List(Dungeon/DeckEntry), stage: Dungeon/BoardDraw) -> Dungeon/BoardDraw:
  match stage:
    case board_draw{board5, counts5, remaining5, seed5, level5}:
      _refill_after_6(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 5, blueprint, board_draw{board5, counts5, remaining5, seed5, level5}))

def _refill_after_4(config_value: Dungeon/Config, hero_index: U32, blueprint: List(Dungeon/DeckEntry), stage: Dungeon/BoardDraw) -> Dungeon/BoardDraw:
  match stage:
    case board_draw{board4, counts4, remaining4, seed4, level4}:
      _refill_after_5(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 4, blueprint, board_draw{board4, counts4, remaining4, seed4, level4}))

def _refill_after_3(config_value: Dungeon/Config, hero_index: U32, blueprint: List(Dungeon/DeckEntry), stage: Dungeon/BoardDraw) -> Dungeon/BoardDraw:
  match stage:
    case board_draw{board3, counts3, remaining3, seed3, level3}:
      _refill_after_4(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 3, blueprint, board_draw{board3, counts3, remaining3, seed3, level3}))

def _refill_after_2(config_value: Dungeon/Config, hero_index: U32, blueprint: List(Dungeon/DeckEntry), stage: Dungeon/BoardDraw) -> Dungeon/BoardDraw:
  match stage:
    case board_draw{board2, counts2, remaining2, seed2, level2}:
      _refill_after_3(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 2, blueprint, board_draw{board2, counts2, remaining2, seed2, level2}))

def _refill_after_1(config_value: Dungeon/Config, hero_index: U32, blueprint: List(Dungeon/DeckEntry), stage: Dungeon/BoardDraw) -> Dungeon/BoardDraw:
  match stage:
    case board_draw{board1, counts1, remaining1, seed1, level1}:
      _refill_after_2(config_value, hero_index, blueprint, _draw_non_hero_step(config_value, hero_index, 1, blueprint, board_draw{board1, counts1, remaining1, seed1, level1}))

def _refill_non_hero_slots(config_value: Dungeon/Config, board_value: Dungeon/Board, hero_index: U32, deck_blueprint: List(Dungeon/DeckEntry), draw_counts: List(Dungeon/DeckEntry), remaining: U32, seed: U32, level: U32) -> Dungeon/BoardDraw:
  _refill_after_1(
    config_value,
    hero_index,
    deck_blueprint,
    _draw_non_hero_step(config_value, hero_index, 0, deck_blueprint, board_draw{board_value, draw_counts, remaining, seed, level})
  )
