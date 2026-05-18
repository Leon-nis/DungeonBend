import Dungeon as Dungeon
import Dungeon/Run/apply_to_tile as M__Dungeon_Run_apply_to_tile
import Dungeon/Board/indexing as M__Dungeon_Board_indexing

def _keep_run(meta_state: Dungeon/Meta, run_value: Dungeon/Run) -> Dungeon/SwipeResult:
  swipe_result{meta_state, keep_running{run_value}}

def _apply_swipe_target(config_value: Dungeon/Config, meta_state: Dungeon/Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, weapon_value: Dungeon/Weapon, board_value: Dungeon/Board, deck_blueprint: List(Dungeon/DeckEntry), draw_counts: List(Dungeon/DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, dir: Dungeon/Direction, target: Maybe(Nat/V2)) -> Dungeon/SwipeResult:
  match target:
    case none{}:
      _keep_run(meta_state, run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref})
    case some{target_pos}:
      Dungeon/Run/apply_to_tile/_apply_to_tile(
        config_value,
        meta_state,
        dungeon_level,
        hero_hp,
        hero_max_hp,
        hero_ref,
        hero_index,
        weapon_value,
        board_value,
        deck_blueprint,
        draw_counts,
        remaining,
        capacity,
        seed,
        ult_charge,
        dir,
        Dungeon/Board/indexing/board_index(target_pos),
        Dungeon/Board/indexing/board_get_pos(board_value, target_pos)
      )

def apply_swipe(config_value: Dungeon/Config, meta_state: Dungeon/Meta, run_value: Dungeon/Run, dir: Dungeon/Direction) -> Dungeon/SwipeResult:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      _apply_swipe_target(
        config_value,
        meta_state,
        dungeon_level,
        hero_hp,
        hero_max_hp,
        hero_ref,
        hero_index,
        weapon_value,
        board_value,
        deck_blueprint,
        draw_counts,
        remaining,
        capacity,
        seed,
        ult_charge,
        dir,
        Dungeon/Board/indexing/adjacent_pos(hero_index, dir)
      )
