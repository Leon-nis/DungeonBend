def apply_to_tile() -> Unit:
  unit{}

import Dungeon/Board/shift_after_move as shift_after_move
import Dungeon as Dungeon
import Dungeon/Deck/spawn_and_draw as M__Dungeon_Deck_spawn_and_draw
import Dungeon/Combat/resolve_and_apply as M__Dungeon_Combat_resolve_and_apply
import Dungeon/profile_helpers as M__Dungeon_profile_helpers

def _min_u32_flag(a_lt_b: U32, a: U32, b: U32) -> U32:
  match a_lt_b:
    case 0:
      b
    case _:
      a

def _min_u32(a: U32, b: U32) -> U32:
  _min_u32_flag(a < b, a, b)

def _add_gold(meta_state: Dungeon/Meta, amount: U32) -> Dungeon/Meta:
  Dungeon/profile_helpers/set_meta_gold(meta_state, Dungeon/profile_helpers/meta_gold(meta_state) + amount)

def _keep_run(meta_state: Dungeon/Meta, run_value: Dungeon/Run) -> Dungeon/SwipeResult:
  swipe_result{meta_state, keep_running{run_value}}

def _end_run(meta_state: Dungeon/Meta, run_value: Dungeon/Run) -> Dungeon/SwipeResult:
  swipe_result{meta_state, end_run{run_value}}

def _move_after_collect_from_draw(meta_state: Dungeon/Meta, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, target_index: U32, weapon_value: Dungeon/Weapon, board_value: Dungeon/Board, deck_blueprint: List(Dungeon/DeckEntry), capacity: U32, ult_charge: U32, result: Dungeon/DrawResult, dir: Dungeon/Direction) -> Dungeon/SwipeResult:
  match result:
    case draw_result{spawn, next_counts, next_remaining, next_seed_value, next_level}:
      _keep_run(
        meta_state,
        run{
          next_level,
          hero_hp,
          hero_max_hp,
          target_index,
          weapon_value,
          shift_after_move(board_value, hero_index, target_index, dir, spawn),
          deck_blueprint,
          next_counts,
          next_remaining,
          capacity,
          next_seed_value,
          ult_charge,
          hero_ref
        }
      )

def _move_after_collect(config_value: Dungeon/Config, meta_state: Dungeon/Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, target_index: U32, weapon_value: Dungeon/Weapon, board_value: Dungeon/Board, deck_blueprint: List(Dungeon/DeckEntry), draw_counts: List(Dungeon/DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, dir: Dungeon/Direction) -> Dungeon/SwipeResult:
  _move_after_collect_from_draw(
    meta_state,
    hero_hp,
    hero_max_hp,
    hero_ref,
    hero_index,
    target_index,
    weapon_value,
    board_value,
    deck_blueprint,
    capacity,
    ult_charge,
    Dungeon/Deck/spawn_and_draw/draw_tile(config_value, deck_blueprint, draw_counts, remaining, seed, dungeon_level),
    dir
  )

def _combat_run(dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, weapon_value: Dungeon/Weapon, board_value: Dungeon/Board, deck_blueprint: List(Dungeon/DeckEntry), draw_counts: List(Dungeon/DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32) -> Dungeon/Run:
  run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}

def _from_combat(meta_state: Dungeon/Meta, dungeon_level: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, deck_blueprint: List(Dungeon/DeckEntry), draw_counts: List(Dungeon/DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, result: Dungeon/CombatResult) -> Dungeon/SwipeResult:
  match result:
    case combat_result{next_hp, next_weapon, next_board, combat_continue{}}:
      _keep_run(meta_state, _combat_run(dungeon_level, next_hp, hero_max_hp, hero_ref, hero_index, next_weapon, next_board, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge))
    case combat_result{next_hp, next_weapon, next_board, combat_game_over{}}:
      _end_run(meta_state, _combat_run(dungeon_level, next_hp, hero_max_hp, hero_ref, hero_index, next_weapon, next_board, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge))

def _apply_to_tile(config_value: Dungeon/Config, meta_state: Dungeon/Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, weapon_value: Dungeon/Weapon, board_value: Dungeon/Board, deck_blueprint: List(Dungeon/DeckEntry), draw_counts: List(Dungeon/DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, dir: Dungeon/Direction, target_index: U32, tile_value: Dungeon/Tile) -> Dungeon/SwipeResult:
  match tile_value:
    case none{}:
      _keep_run(meta_state, run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref})
    case monster{ref, hp}:
      _from_combat(
        meta_state,
        dungeon_level,
        hero_max_hp,
        hero_ref,
        hero_index,
        deck_blueprint,
        draw_counts,
        remaining,
        capacity,
        seed,
        ult_charge,
        Dungeon/Combat/resolve_and_apply/resolve_monster(config_value, board_value, hero_hp, weapon_value, target_index, ref, hp)
      )
    case sword{ref, dmg}:
      _move_after_collect(config_value, meta_state, dungeon_level, hero_hp, hero_max_hp, hero_ref, hero_index, target_index, weapon{ref, dmg}, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, dir)
    case potion{ref, heal}:
      _move_after_collect(config_value, meta_state, dungeon_level, _min_u32(hero_max_hp, hero_hp + heal), hero_max_hp, hero_ref, hero_index, target_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, dir)
    case gold{amount}:
      _move_after_collect(config_value, _add_gold(meta_state, amount), dungeon_level, hero_hp, hero_max_hp, hero_ref, hero_index, target_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, dir)
