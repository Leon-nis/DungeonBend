def resolve_and_apply() -> Unit:
  unit{}

import Dungeon as Dungeon
import Dungeon/Board/indexing as M__Dungeon_Board_indexing
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick

def _resolve_unarmed_hit(hero_wins: U32, monsters: List(Dungeon/MonsterDef), board_value: Dungeon/Board, hero_hp: U32, target_idx: U32, monster_ref: U32, monster_hp: U32, spawn_level: U32) -> Dungeon/CombatResult:
  match hero_wins:
    case 0:
      combat_result{0, no_weapon{}, board_value, combat_game_over{}}
    case _:
      gold_drop = Dungeon/Deck/counts_pick/monster_gold(monsters, monster_ref, spawn_level);
      next_board = Dungeon/Board/indexing/board_set(board_value, target_idx, gold{gold_drop});
      combat_result{hero_hp - monster_hp, no_weapon{}, next_board, combat_continue{}}

def _resolve_unarmed(monsters: List(Dungeon/MonsterDef), board_value: Dungeon/Board, hero_hp: U32, target_idx: U32, monster_ref: U32, monster_hp: U32, spawn_level: U32) -> Dungeon/CombatResult:
  _resolve_unarmed_hit(hero_hp > monster_hp, monsters, board_value, hero_hp, target_idx, monster_ref, monster_hp, spawn_level)

def _resolve_armed_finish(exact_kill: U32, monsters: List(Dungeon/MonsterDef), board_value: Dungeon/Board, hero_hp: U32, target_idx: U32, monster_ref: U32, monster_hp: U32, spawn_level: U32, dmg: U32) -> Dungeon/CombatResult:
  match exact_kill:
    case 0:
      next_board = Dungeon/Board/indexing/board_set(board_value, target_idx, monster{monster_ref, monster_hp - dmg, spawn_level});
      combat_result{hero_hp, no_weapon{}, next_board, combat_continue{}}
    case _:
      gold_drop = Dungeon/Deck/counts_pick/monster_gold(monsters, monster_ref, spawn_level);
      next_board = Dungeon/Board/indexing/board_set(board_value, target_idx, gold{gold_drop});
      combat_result{hero_hp, no_weapon{}, next_board, combat_continue{}}

def _resolve_armed_equal_or_less(monsters: List(Dungeon/MonsterDef), board_value: Dungeon/Board, hero_hp: U32, target_idx: U32, monster_ref: U32, monster_hp: U32, spawn_level: U32, weapon_ref: U32, dmg: U32) -> Dungeon/CombatResult:
  _resolve_armed_finish(dmg === monster_hp, monsters, board_value, hero_hp, target_idx, monster_ref, monster_hp, spawn_level, dmg)

def _resolve_armed_hit(overkill: U32, monsters: List(Dungeon/MonsterDef), board_value: Dungeon/Board, hero_hp: U32, target_idx: U32, monster_ref: U32, monster_hp: U32, spawn_level: U32, weapon_ref: U32, dmg: U32) -> Dungeon/CombatResult:
  match overkill:
    case 0:
      _resolve_armed_equal_or_less(monsters, board_value, hero_hp, target_idx, monster_ref, monster_hp, spawn_level, weapon_ref, dmg)
    case _:
      gold_drop = Dungeon/Deck/counts_pick/monster_gold(monsters, monster_ref, spawn_level);
      next_board = Dungeon/Board/indexing/board_set(board_value, target_idx, gold{gold_drop});
      combat_result{hero_hp, weapon{weapon_ref, dmg - monster_hp}, next_board, combat_continue{}}

def _resolve_armed(monsters: List(Dungeon/MonsterDef), board_value: Dungeon/Board, hero_hp: U32, target_idx: U32, monster_ref: U32, monster_hp: U32, spawn_level: U32, weapon_ref: U32, dmg: U32) -> Dungeon/CombatResult:
  _resolve_armed_hit(dmg > monster_hp, monsters, board_value, hero_hp, target_idx, monster_ref, monster_hp, spawn_level, weapon_ref, dmg)

def resolve_monster(config_value: Dungeon/Config, board_value: Dungeon/Board, hero_hp: U32, weapon_value: Dungeon/Weapon, target_idx: U32, monster_ref: U32, monster_hp: U32, spawn_level: U32) -> Dungeon/CombatResult:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      match weapon_value:
        case no_weapon{}:
          _resolve_unarmed(monsters, board_value, hero_hp, target_idx, monster_ref, monster_hp, spawn_level)
        case weapon{ref, dmg}:
          _resolve_armed(monsters, board_value, hero_hp, target_idx, monster_ref, monster_hp, spawn_level, ref, dmg)
