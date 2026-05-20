import String as String
import Dungeon as Dungeon
import Dungeon/Board/indexing as M__Dungeon_Board_indexing

def _parse_saved_deck_entries_empty(rest: List(String)) -> Maybe(List(Dungeon/DeckEntry)):
  match rest:
    case []:
      some{[]}
    case _:
      none{}

def _parse_saved_monster_entry_values(ref_maybe: Maybe(U32), count_maybe: Maybe(U32)) -> Maybe(Dungeon/DeckEntry):
  match ref_maybe count_maybe:
    case some{ref} some{count}:
      some{monster_entry{ref, count}}
    case _ _:
      none{}

def _parse_saved_monster_entry(rest: List(String)) -> Maybe(Dungeon/DeckEntry):
  match rest:
    case ref_str<>rest1:
      match rest1:
        case count_str<>rest2:
          match rest2:
            case []:
              _parse_saved_monster_entry_values(String/to_u32(ref_str), String/to_u32(count_str))
            case _:
              none{}
        case _:
          none{}
    case _:
      none{}

def _parse_saved_sword_entry_values(ref_maybe: Maybe(U32), count_maybe: Maybe(U32)) -> Maybe(Dungeon/DeckEntry):
  match ref_maybe count_maybe:
    case some{ref} some{count}:
      some{sword_entry{ref, count}}
    case _ _:
      none{}

def _parse_saved_sword_entry(rest: List(String)) -> Maybe(Dungeon/DeckEntry):
  match rest:
    case ref_str<>rest1:
      match rest1:
        case count_str<>rest2:
          match rest2:
            case []:
              _parse_saved_sword_entry_values(String/to_u32(ref_str), String/to_u32(count_str))
            case _:
              none{}
        case _:
          none{}
    case _:
      none{}

def _parse_saved_potion_entry_values(ref_maybe: Maybe(U32), count_maybe: Maybe(U32)) -> Maybe(Dungeon/DeckEntry):
  match ref_maybe count_maybe:
    case some{ref} some{count}:
      some{potion_entry{ref, count}}
    case _ _:
      none{}

def _parse_saved_potion_entry(rest: List(String)) -> Maybe(Dungeon/DeckEntry):
  match rest:
    case ref_str<>rest1:
      match rest1:
        case count_str<>rest2:
          match rest2:
            case []:
              _parse_saved_potion_entry_values(String/to_u32(ref_str), String/to_u32(count_str))
            case _:
              none{}
        case _:
          none{}
    case _:
      none{}

def _parse_saved_hero_entry_value(count_maybe: Maybe(U32)) -> Maybe(Dungeon/DeckEntry):
  match count_maybe:
    case some{count}:
      some{hero_entry{count}}
    case none{}:
      none{}

def _parse_saved_hero_entry(rest: List(String)) -> Maybe(Dungeon/DeckEntry):
  match rest:
    case count_str<>rest1:
      match rest1:
        case []:
          _parse_saved_hero_entry_value(String/to_u32(count_str))
        case _:
          none{}
    case _:
      none{}

def _parse_saved_deck_entry_kind(kind_maybe: Maybe(U32), rest: List(String)) -> Maybe(Dungeon/DeckEntry):
  match kind_maybe:
    case some{1}:
      _parse_saved_monster_entry(rest)
    case some{2}:
      _parse_saved_sword_entry(rest)
    case some{3}:
      _parse_saved_potion_entry(rest)
    case some{4}:
      _parse_saved_hero_entry(rest)
    case _:
      none{}

def _parse_saved_deck_entry(parts: List(String)) -> Maybe(Dungeon/DeckEntry):
  match parts:
    case kind_str<>rest:
      _parse_saved_deck_entry_kind(String/to_u32(kind_str), rest)
    case _:
      none{}

def _parse_saved_deck_entries_head(is_empty: Bool, part: String, rest: List(String), rest_entries_result: Maybe(List(Dungeon/DeckEntry))) -> Maybe(List(Dungeon/DeckEntry)):
  match is_empty:
    case true{}:
      _parse_saved_deck_entries_empty(rest)
    case false{}:
      match _parse_saved_deck_entry(String/split(part, '~')) rest_entries_result:
        case some{entry} some{rest_entries}:
          some{entry<>rest_entries}
        case _ _:
          none{}

def _parse_saved_deck_entries(parts: List(String)) -> Maybe(List(Dungeon/DeckEntry)):
  match parts:
    case []:
      some{[]}
    case part<>rest:
      _parse_saved_deck_entries_head(String/eq(part, ""), part, rest, _parse_saved_deck_entries(rest))

def _parse_run_with_blueprint(dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_index: U32, remaining: U32, capacity: U32, seed: U32, ult_charge: U32, hero_ref: U32, weapon_value: Dungeon/Weapon, current_board: Dungeon/Board, deck_blueprint: List(Dungeon/DeckEntry), draw_counts: String) -> Maybe(Dungeon/Run):
  match _parse_saved_deck_entries(String/split(draw_counts, ';')):
    case some{counts_value}:
      some{run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, current_board, deck_blueprint, counts_value, remaining, capacity, seed, ult_charge, hero_ref}}
    case none{}:
      none{}

def _parse_run_with_board(dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_index: U32, remaining: U32, capacity: U32, seed: U32, ult_charge: U32, hero_ref: U32, weapon_value: Dungeon/Weapon, current_board: Dungeon/Board, blueprint: String, draw_counts: String) -> Maybe(Dungeon/Run):
  match _parse_saved_deck_entries(String/split(blueprint, ';')):
    case some{deck_blueprint}:
      _parse_run_with_blueprint(dungeon_level, hero_hp, hero_max_hp, hero_index, remaining, capacity, seed, ult_charge, hero_ref, weapon_value, current_board, deck_blueprint, draw_counts)
    case none{}:
      none{}

def _parse_saved_none_tile(rest: List(String)) -> Maybe(Dungeon/Tile):
  match rest:
    case []:
      some{none{}}
    case _:
      none{}

def _parse_saved_monster_tile_values(ref_maybe: Maybe(U32), hp_maybe: Maybe(U32), spawn_level_maybe: Maybe(U32)) -> Maybe(Dungeon/Tile):
  match ref_maybe hp_maybe spawn_level_maybe:
    case some{ref} some{hp} some{spawn_level}:
      some{monster{ref, hp, spawn_level}}
    case _ _ _:
      none{}

def _parse_saved_monster_tile(rest: List(String)) -> Maybe(Dungeon/Tile):
  match rest:
    case ref_str<>rest1:
      match rest1:
        case hp_str<>rest2:
          match rest2:
            case []:
              _parse_saved_monster_tile_values(String/to_u32(ref_str), String/to_u32(hp_str), some{1})
            case spawn_level_str<>rest3:
              match rest3:
                case []:
                  _parse_saved_monster_tile_values(String/to_u32(ref_str), String/to_u32(hp_str), String/to_u32(spawn_level_str))
                case _:
                  none{}
            case _:
              none{}
        case _:
          none{}
    case _:
      none{}

def _parse_saved_sword_tile_values(ref_maybe: Maybe(U32), dmg_maybe: Maybe(U32)) -> Maybe(Dungeon/Tile):
  match ref_maybe dmg_maybe:
    case some{ref} some{dmg}:
      some{sword{ref, dmg}}
    case _ _:
      none{}

def _parse_saved_sword_tile(rest: List(String)) -> Maybe(Dungeon/Tile):
  match rest:
    case ref_str<>rest1:
      match rest1:
        case dmg_str<>rest2:
          match rest2:
            case []:
              _parse_saved_sword_tile_values(String/to_u32(ref_str), String/to_u32(dmg_str))
            case _:
              none{}
        case _:
          none{}
    case _:
      none{}

def _parse_saved_potion_tile_values(ref_maybe: Maybe(U32), heal_maybe: Maybe(U32)) -> Maybe(Dungeon/Tile):
  match ref_maybe heal_maybe:
    case some{ref} some{heal}:
      some{potion{ref, heal}}
    case _ _:
      none{}

def _parse_saved_potion_tile(rest: List(String)) -> Maybe(Dungeon/Tile):
  match rest:
    case ref_str<>rest1:
      match rest1:
        case heal_str<>rest2:
          match rest2:
            case []:
              _parse_saved_potion_tile_values(String/to_u32(ref_str), String/to_u32(heal_str))
            case _:
              none{}
        case _:
          none{}
    case _:
      none{}

def _parse_saved_gold_tile_value(amount_maybe: Maybe(U32)) -> Maybe(Dungeon/Tile):
  match amount_maybe:
    case some{amount}:
      some{gold{amount}}
    case none{}:
      none{}

def _parse_saved_gold_tile(rest: List(String)) -> Maybe(Dungeon/Tile):
  match rest:
    case amount_str<>rest1:
      match rest1:
        case []:
          _parse_saved_gold_tile_value(String/to_u32(amount_str))
        case _:
          none{}
    case _:
      none{}

def _parse_saved_tile_kind(kind_maybe: Maybe(U32), rest: List(String)) -> Maybe(Dungeon/Tile):
  match kind_maybe:
    case some{0}:
      _parse_saved_none_tile(rest)
    case some{1}:
      _parse_saved_monster_tile(rest)
    case some{2}:
      _parse_saved_sword_tile(rest)
    case some{3}:
      _parse_saved_potion_tile(rest)
    case some{4}:
      _parse_saved_gold_tile(rest)
    case _:
      none{}

def _parse_saved_tile(parts: List(String)) -> Maybe(Dungeon/Tile):
  match parts:
    case kind_str<>rest:
      _parse_saved_tile_kind(String/to_u32(kind_str), rest)
    case _:
      none{}

def _parse_saved_board_done(parts: List(String), current_board: Dungeon/Board) -> Maybe(Dungeon/Board):
  match parts:
    case []:
      some{current_board}
    case _:
      none{}

def _parse_saved_board(parts: List(String), idx: U32, current_board: Dungeon/Board) -> Maybe(Dungeon/Board):
  match idx === 9:
    case 0:
      match parts:
        case part<>rest:
          match _parse_saved_tile(String/split(part, '~')):
            case some{tile_value}:
              _parse_saved_board(rest, idx + 1, Dungeon/Board/indexing/board_set(current_board, idx, tile_value))
            case none{}:
              none{}
        case _:
          none{}
    case _:
      _parse_saved_board_done(parts, current_board)

def _parse_run_with_weapon(dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_index: U32, remaining: U32, capacity: U32, seed: U32, ult_charge: U32, hero_ref: U32, weapon_value: Dungeon/Weapon, board_snapshot: String, blueprint: String, draw_counts: String) -> Maybe(Dungeon/Run):
  match _parse_saved_board(String/split(board_snapshot, ';'), 0, Dungeon/Board/indexing/empty_board()):
    case some{current_board}:
      _parse_run_with_board(dungeon_level, hero_hp, hero_max_hp, hero_index, remaining, capacity, seed, ult_charge, hero_ref, weapon_value, current_board, blueprint, draw_counts)
    case none{}:
      none{}

def _parse_saved_no_weapon(rest: List(String)) -> Maybe(Dungeon/Weapon):
  match rest:
    case []:
      some{no_weapon{}}
    case _:
      none{}

def _parse_saved_weapon_result(ref_maybe: Maybe(U32), dmg_maybe: Maybe(U32)) -> Maybe(Dungeon/Weapon):
  match ref_maybe dmg_maybe:
    case some{ref} some{dmg}:
      some{weapon{ref, dmg}}
    case _ _:
      none{}

def _parse_saved_weapon_values(rest: List(String)) -> Maybe(Dungeon/Weapon):
  match rest:
    case ref_str<>rest1:
      match rest1:
        case dmg_str<>rest2:
          match rest2:
            case []:
              _parse_saved_weapon_result(String/to_u32(ref_str), String/to_u32(dmg_str))
            case _:
              none{}
        case _:
          none{}
    case _:
      none{}

def _parse_saved_weapon_kind(kind_maybe: Maybe(U32), rest: List(String)) -> Maybe(Dungeon/Weapon):
  match kind_maybe:
    case some{0}:
      _parse_saved_no_weapon(rest)
    case some{1}:
      _parse_saved_weapon_values(rest)
    case _:
      none{}

def _parse_saved_weapon(parts: List(String)) -> Maybe(Dungeon/Weapon):
  match parts:
    case kind_str<>rest:
      _parse_saved_weapon_kind(String/to_u32(kind_str), rest)
    case _:
      none{}

def _parse_run_with_core_values(dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_index: U32, remaining: U32, capacity: U32, seed: U32, ult_charge: U32, hero_ref: U32, weapon: String, board_snapshot: String, blueprint: String, draw_counts: String) -> Maybe(Dungeon/Run):
  match _parse_saved_weapon(String/split(weapon, '~')):
    case some{weapon_value}:
      _parse_run_with_weapon(dungeon_level, hero_hp, hero_max_hp, hero_index, remaining, capacity, seed, ult_charge, hero_ref, weapon_value, board_snapshot, blueprint, draw_counts)
    case none{}:
      none{}

def _parse_run_values(dungeon_level_maybe: Maybe(U32), hero_hp_maybe: Maybe(U32), hero_max_hp_maybe: Maybe(U32), hero_index_maybe: Maybe(U32), remaining_maybe: Maybe(U32), capacity_maybe: Maybe(U32), seed_maybe: Maybe(U32), ult_charge_maybe: Maybe(U32), hero_ref_maybe: Maybe(U32), weapon: String, board_snapshot: String, blueprint: String, draw_counts: String) -> Maybe(Dungeon/Run):
  match dungeon_level_maybe hero_hp_maybe hero_max_hp_maybe hero_index_maybe remaining_maybe capacity_maybe seed_maybe ult_charge_maybe hero_ref_maybe:
    case some{dungeon_level} some{hero_hp} some{hero_max_hp} some{hero_index} some{remaining} some{capacity} some{seed} some{ult_charge} some{hero_ref}:
      _parse_run_with_core_values(dungeon_level, hero_hp, hero_max_hp, hero_index, remaining, capacity, seed, ult_charge, hero_ref, weapon, board_snapshot, blueprint, draw_counts)
    case _ _ _ _ _ _ _ _ _:
      none{}

def _parse_run_core(parts: List(String), weapon: String, board_snapshot: String, blueprint: String, draw_counts: String) -> Maybe(Dungeon/Run):
  match parts:
    case dungeon_level_str<>hero_hp_str<>hero_max_hp_str<>hero_index_str<>remaining_str<>capacity_str<>seed_str<>ult_charge_str<>hero_ref_str<>[]:
      _parse_run_values(
        String/to_u32(dungeon_level_str),
        String/to_u32(hero_hp_str),
        String/to_u32(hero_max_hp_str),
        String/to_u32(hero_index_str),
        String/to_u32(remaining_str),
        String/to_u32(capacity_str),
        String/to_u32(seed_str),
        String/to_u32(ult_charge_str),
        String/to_u32(hero_ref_str),
        weapon,
        board_snapshot,
        blueprint,
        draw_counts
      )
    case _:
      none{}

def parse_saved_run(core: String, weapon: String, board_snapshot: String, blueprint: String, draw_counts: String) -> Maybe(Dungeon/Run):
  _parse_run_core(String/split(core, '~'), weapon, board_snapshot, blueprint, draw_counts)
