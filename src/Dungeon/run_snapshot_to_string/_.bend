def run_snapshot_to_string() -> Unit:
  unit{}

import Dungeon as Dungeon
import Dungeon/Board/indexing as M__Dungeon_Board_indexing

def run_core_string(run_value: Dungeon/Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      String/join(
        [
          U32/show(dungeon_level),
          U32/show(hero_hp),
          U32/show(hero_max_hp),
          U32/show(hero_index),
          U32/show(remaining),
          U32/show(capacity),
          U32/show(seed),
          U32/show(ult_charge),
          U32/show(hero_ref)
        ],
        "~"
      )

def _weapon_string(weapon_value: Dungeon/Weapon) -> String:
  match weapon_value:
    case no_weapon{}:
      "0"
    case weapon{ref, dmg}:
      String/join(["1", U32/show(ref), U32/show(dmg)], "~")

def run_weapon_string(run_value: Dungeon/Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      _weapon_string(weapon_value)

def _tile_string(tile_value: Dungeon/Tile) -> String:
  match tile_value:
    case none{}:
      "0"
    case monster{ref, hp}:
      String/join(["1", U32/show(ref), U32/show(hp)], "~")
    case sword{ref, dmg}:
      String/join(["2", U32/show(ref), U32/show(dmg)], "~")
    case potion{ref, heal}:
      String/join(["3", U32/show(ref), U32/show(heal)], "~")
    case gold{amount}:
      String/join(["4", U32/show(amount)], "~")

def _board_tile_strings(board_value: Dungeon/Board, idx: U32) -> List(String):
  match idx:
    case 9:
      []
    case _:
      _tile_string(Dungeon/Board/indexing/board_get(board_value, idx))<>_board_tile_strings(board_value, idx + 1)

def run_board_string(run_value: Dungeon/Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      String/join(_board_tile_strings(board_value, 0), ";")

def _deck_entry_string(entry: Dungeon/DeckEntry) -> String:
  match entry:
    case monster_entry{ref, count}:
      String/join(["1", U32/show(ref), U32/show(count)], "~")
    case sword_entry{ref, count}:
      String/join(["2", U32/show(ref), U32/show(count)], "~")
    case potion_entry{ref, count}:
      String/join(["3", U32/show(ref), U32/show(count)], "~")
    case hero_entry{count}:
      String/join(["4", U32/show(count)], "~")

def _deck_entry_strings(entries: List(Dungeon/DeckEntry)) -> List(String):
  match entries:
    case []:
      []
    case entry<>rest:
      _deck_entry_string(entry)<>_deck_entry_strings(rest)

def deck_entries_string(entries: List(Dungeon/DeckEntry)) -> String:
  String/join(_deck_entry_strings(entries), ";")

def run_blueprint_string(run_value: Dungeon/Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      deck_entries_string(deck_blueprint)

def run_counts_string(run_value: Dungeon/Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      deck_entries_string(draw_counts)
