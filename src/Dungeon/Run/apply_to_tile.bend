import Dungeon/DeckEntry as DeckEntry
import Dungeon/Weapon as Weapon
import Dungeon/Tile as Tile
import Dungeon/Board as Board
import Dungeon/DrawResult as DrawResult
import Dungeon/CombatResult as CombatResult
import Dungeon/Meta as Meta
import Dungeon/Config as Config
import Dungeon/Run as Run
import Dungeon/RunStats as RunStats
import Dungeon/SwipeResult as SwipeResult
import Dungeon/Direction as Direction
import Dungeon/UltimateState as UltimateState
import Dungeon/Deck/spawn_and_draw/draw_tile as draw_tile
import Dungeon/Board/shift_after_move as shift_after_move
import Dungeon/Combat/resolve_and_apply/resolve_monster as resolve_monster
import Dungeon/profile_helpers/meta_gold as meta_gold
import Dungeon/profile_helpers/set_meta_gold as set_meta_gold
import Dungeon/run_stats_helpers/run_stats_add_gold as run_stats_add_gold
import Dungeon/run_stats_helpers/run_stats_record_monster_combat as run_stats_record_monster_combat
import Dungeon/run_stats_helpers/run_stats_record_path as run_stats_record_path
import Dungeon/run_stats_helpers/run_stats_record_potion_pickup as run_stats_record_potion_pickup
import Dungeon/run_stats_helpers/run_stats_record_weapon_pickup as run_stats_record_weapon_pickup
import Dungeon/shadow_step_helpers/board_with_shadow_origin as board_with_shadow_origin
import Dungeon/shadow_step_helpers/board_after_shadow_return as board_after_shadow_return
import Dungeon/ultimate_helpers/ultimate_state_is_shadow_armed as ultimate_state_is_shadow_armed
import Dungeon/weapon_helpers/apply_weapon_pickup_rule as apply_weapon_pickup_rule

def _min_u32(a: U32, b: U32) -> U32:
  _min_u32_flag(a < b, a, b)

def _min_u32_flag(a_lt_b: U32, a: U32, b: U32) -> U32:
  match a_lt_b:
    case 0:
      b
    case _:
      a

def _add_gold(meta_state: Meta, amount: U32) -> Meta:
  set_meta_gold(meta_state, meta_gold(meta_state) + amount)

def _effective_heal(hero_hp: U32, hero_max_hp: U32, heal: U32) -> U32:
  _effective_heal_missing(hero_max_hp < hero_hp, hero_max_hp, hero_hp, heal)

def _effective_heal_missing(max_lt_current: U32, hero_max_hp: U32, hero_hp: U32, heal: U32) -> U32:
  match max_lt_current:
    case 0:
      _min_u32(hero_max_hp - hero_hp, heal)
    case _:
      0

def _keep_run(meta_state: Meta, run_value: Run) -> SwipeResult:
  swipe_result{meta_state, keep_running{run_value}}

def _end_run(meta_state: Meta, run_value: Run) -> SwipeResult:
  swipe_result{meta_state, end_run{run_value}}

def _run_value(dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, ultimate_state: UltimateState, stats: RunStats) -> Run:
  run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}

def _move_after_collect_from_draw(meta_state: Meta, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, target_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), capacity: U32, ult_charge: U32, ultimate_state: UltimateState, stats: RunStats, result: DrawResult, dir: Direction) -> SwipeResult:
  match result:
    case draw_result{spawn, next_counts, next_remaining, next_seed_value, next_level}:
      _keep_run(
        meta_state,
        _run_value(next_level, hero_hp, hero_max_hp, hero_ref, target_index, weapon_value, shift_after_move(board_value, hero_index, target_index, dir, spawn), deck_blueprint, next_counts, next_remaining, capacity, next_seed_value, ult_charge, ultimate_state, run_stats_record_path(stats, target_index))
      )

def _move_after_collect(config_value: Config, meta_state: Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, target_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, ultimate_state: UltimateState, stats: RunStats, dir: Direction) -> SwipeResult:
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
    ultimate_state,
    stats,
    draw_tile(config_value, deck_blueprint, draw_counts, remaining, seed, dungeon_level),
    dir
  )

def _move_after_shadow_collect(meta_state: Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, target_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, stats: RunStats) -> SwipeResult:
  _keep_run(meta_state, _run_value(dungeon_level, hero_hp, hero_max_hp, hero_ref, target_index, weapon_value, board_with_shadow_origin(board_value, hero_index, target_index), deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, ultimate_state_shadow_live{}, run_stats_record_path(stats, target_index)))

def _move_to_shadow_from_draw(meta_state: Meta, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, shadow_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), capacity: U32, stats: RunStats, result: DrawResult) -> SwipeResult:
  match result:
    case draw_result{spawn, next_counts, next_remaining, next_seed_value, next_level}:
      _keep_run(meta_state, _run_value(next_level, hero_hp, hero_max_hp, hero_ref, shadow_index, weapon_value, board_after_shadow_return(board_value, hero_index, shadow_index, spawn), deck_blueprint, next_counts, next_remaining, capacity, next_seed_value, 0, ultimate_state_idle{}, run_stats_record_path(stats, shadow_index)))

def _move_to_shadow(config_value: Config, meta_state: Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, shadow_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, stats: RunStats) -> SwipeResult:
  _move_to_shadow_from_draw(meta_state, hero_hp, hero_max_hp, hero_ref, hero_index, shadow_index, weapon_value, board_value, deck_blueprint, capacity, stats, draw_tile(config_value, deck_blueprint, draw_counts, remaining, seed, dungeon_level))

def _combat_run(dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, ultimate_state: UltimateState, stats: RunStats) -> Run:
  _run_value(dungeon_level, hero_hp, hero_max_hp, hero_ref, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, ultimate_state, stats)

def _from_combat(meta_state: Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, weapon_value: Weapon, monster_hp: U32, spawn_level: U32, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, ultimate_state: UltimateState, stats: RunStats, result: CombatResult) -> SwipeResult:
  next_stats = run_stats_record_monster_combat(stats, hero_hp, weapon_value, monster_hp, spawn_level);
  match result:
    case combat_result{next_hp, next_weapon, next_board, combat_continue{}}:
      _keep_run(meta_state, _combat_run(dungeon_level, next_hp, hero_max_hp, hero_ref, hero_index, next_weapon, next_board, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, ultimate_state, next_stats))
    case combat_result{next_hp, next_weapon, next_board, combat_game_over{}}:
      _end_run(meta_state, _combat_run(dungeon_level, next_hp, hero_max_hp, hero_ref, hero_index, next_weapon, next_board, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, ultimate_state, next_stats))

def _apply_to_tile(config_value: Config, meta_state: Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, ultimate_state: UltimateState, stats: RunStats, dir: Direction, target_index: U32, tile_value: Tile) -> SwipeResult:
  match tile_value:
    case none{}:
      _keep_run(meta_state, _run_value(dungeon_level, hero_hp, hero_max_hp, hero_ref, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, ultimate_state, stats))
    case shadow{}:
      _move_to_shadow(config_value, meta_state, dungeon_level, hero_hp, hero_max_hp, hero_ref, hero_index, target_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, stats)
    case monster{ref, hp, spawn_level}:
      _from_combat(
        meta_state,
        dungeon_level,
        hero_hp,
        hero_max_hp,
        hero_ref,
        hero_index,
        weapon_value,
        hp,
        spawn_level,
        deck_blueprint,
        draw_counts,
        remaining,
        capacity,
        seed,
        ult_charge,
        ultimate_state,
        stats,
        resolve_monster(config_value, board_value, hero_hp, weapon_value, target_index, ref, hp, spawn_level)
      )
    case sword{ref, dmg}:
      _apply_collect_shadow(ultimate_state_is_shadow_armed(ultimate_state), config_value, meta_state, dungeon_level, hero_hp, hero_max_hp, hero_ref, hero_index, target_index, apply_weapon_pickup_rule(config_value, hero_ref, weapon_value, ref, dmg), board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, ultimate_state, run_stats_record_weapon_pickup(stats, dmg), dir)
    case potion{ref, heal}:
      _apply_collect_shadow(ultimate_state_is_shadow_armed(ultimate_state), config_value, meta_state, dungeon_level, _min_u32(hero_max_hp, hero_hp + heal), hero_max_hp, hero_ref, hero_index, target_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, ultimate_state, run_stats_record_potion_pickup(stats, _effective_heal(hero_hp, hero_max_hp, heal)), dir)
    case gold{amount}:
      _apply_collect_shadow(ultimate_state_is_shadow_armed(ultimate_state), config_value, _add_gold(meta_state, amount), dungeon_level, hero_hp, hero_max_hp, hero_ref, hero_index, target_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, ultimate_state, run_stats_add_gold(stats, amount), dir)

def _apply_collect_shadow(shadow_armed: U32, config_value: Config, meta_state: Meta, dungeon_level: U32, hero_hp: U32, hero_max_hp: U32, hero_ref: U32, hero_index: U32, target_index: U32, weapon_value: Weapon, board_value: Board, deck_blueprint: List(DeckEntry), draw_counts: List(DeckEntry), remaining: U32, capacity: U32, seed: U32, ult_charge: U32, ultimate_state: UltimateState, stats: RunStats, dir: Direction) -> SwipeResult:
  match shadow_armed:
    case 0:
      _move_after_collect(config_value, meta_state, dungeon_level, hero_hp, hero_max_hp, hero_ref, hero_index, target_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, ultimate_state, stats, dir)
    case _:
      _move_after_shadow_collect(meta_state, dungeon_level, hero_hp, hero_max_hp, hero_ref, hero_index, target_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, stats)
