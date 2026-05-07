import Dungeon/Run as Run
import Dungeon/Weapon as Weapon
import Dungeon/Board as Board
import Dungeon/DeckEntry as DeckEntry
import Dungeon/Tile as Tile
import Dungeon/UltimateState as UltimateState
import Dungeon/WeaponClass as WeaponClass
import Dungeon/RunStats as RunStats
import Dungeon/Board/indexing/board_get as board_get

def run_core_string(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      String/join(
        _append_string_lists(
          _run_core_base_parts(dungeon_level, hero_hp, hero_max_hp, hero_index, remaining, capacity, seed, ult_charge, hero_ref),
          _append_string_lists(_ultimate_state_parts(ultimate_state), _run_stats_parts(stats))
        ),
        "~"
      )

def _run_core_base_parts(dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_index: U32, remaining: U32, capacity: U32, seed: U32, ult_charge: U32, hero_ref: U32) -> List(String):
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
  ]

def _append_string_lists(a: List(String), b: List(String)) -> List(String):
  match a:
    case []:
      b
    case head<>tail:
      head<>_append_string_lists(tail, b)

def run_weapon_string(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      _weapon_string(weapon_value)

def _weapon_string(weapon_value: Weapon) -> String:
  match weapon_value:
    case no_weapon{}:
      "0"
    case weapon{class_kind, dmg}:
      String/join(["1", _weapon_class_string(class_kind), U32/show(dmg)], "~")

def _weapon_class_string(class_kind: WeaponClass) -> String:
  match class_kind:
    case weapon_sword{}:
      "10"
    case weapon_axe{}:
      "11"
    case weapon_bow{}:
      "12"

def run_board_string(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      String/join(_board_tile_strings(board_value, 0), ";")

def _board_tile_strings(board_value: Board, idx: U32) -> List(String):
  match idx:
    case 9:
      []
    case _:
      _tile_string(board_get(board_value, idx))<>_board_tile_strings(board_value, idx + 1)

def _tile_string(tile_value: Tile) -> String:
  match tile_value:
    case none{}:
      "0"
    case shadow{}:
      "5"
    case anchor_hero{hero_ref}:
      String/join(["6", U32/show(hero_ref)], "~")
    case monster{ref, hp, spawn_level}:
      String/join(["1", U32/show(ref), U32/show(hp), U32/show(spawn_level)], "~")
    case sword{ref, dmg}:
      String/join(["2", U32/show(ref), U32/show(dmg)], "~")
    case potion{ref, heal}:
      String/join(["3", U32/show(ref), U32/show(heal)], "~")
    case gold{amount}:
      String/join(["4", U32/show(amount)], "~")

def run_blueprint_string(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      deck_entries_string(deck_blueprint)

def run_counts_string(run_value: Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      deck_entries_string(draw_counts)

def _ultimate_state_parts(ultimate_state: UltimateState) -> List(String):
  match ultimate_state:
    case ultimate_state_idle{}:
      ["0"]
    case ultimate_state_projection_armed{}:
      ["1"]
    case ultimate_state_shadow_step_live{}:
      ["2"]
    case ultimate_state_shadow_clone_live{anchor_hp}:
      ["3", U32/show(anchor_hp)]

def _run_stats_parts(stats: RunStats) -> List(String):
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      [
        U32/show(gold_collected),
        U32/show(items_collected),
        U32/show(weapon_damage_gained),
        U32/show(potion_heal_effective),
        U32/show(monsters_defeated),
        U32/show(damage_dealt),
        U32/show(monster_level_sum),
        U32/show(monster_level_count),
        U32/show(path_center),
        U32/show(path_edge),
        U32/show(path_corner)
      ]

def deck_entries_string(entries: List(DeckEntry)) -> String:
  String/join(_deck_entry_strings(entries), ";")

def _deck_entry_strings(entries: List(DeckEntry)) -> List(String):
  match entries:
    case []:
      []
    case entry<>rest:
      _deck_entry_string(entry)<>_deck_entry_strings(rest)

def _deck_entry_string(entry: DeckEntry) -> String:
  match entry:
    case monster_entry{ref, count}:
      String/join(["1", U32/show(ref), U32/show(count)], "~")
    case sword_entry{ref, count}:
      String/join(["2", U32/show(ref), U32/show(count)], "~")
    case potion_entry{ref, count}:
      String/join(["3", U32/show(ref), U32/show(count)], "~")
    case hero_entry{count}:
      String/join(["4", U32/show(count)], "~")
