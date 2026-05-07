import Dungeon/RunStats as RunStats
import Dungeon/Weapon as Weapon

def empty_run_stats() -> RunStats:
  run_stats{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

def run_stats_gold_collected(stats: RunStats) -> U32:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      gold_collected

def run_stats_items_collected(stats: RunStats) -> U32:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      items_collected

def run_stats_weapon_damage_gained(stats: RunStats) -> U32:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      weapon_damage_gained

def run_stats_potion_heal_effective(stats: RunStats) -> U32:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      potion_heal_effective

def run_stats_monsters_defeated(stats: RunStats) -> U32:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      monsters_defeated

def run_stats_damage_dealt(stats: RunStats) -> U32:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      damage_dealt

def run_stats_monster_level_sum(stats: RunStats) -> U32:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      monster_level_sum

def run_stats_monster_level_count(stats: RunStats) -> U32:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      monster_level_count

def run_stats_path_center(stats: RunStats) -> U32:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      path_center

def run_stats_path_edge(stats: RunStats) -> U32:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      path_edge

def run_stats_path_corner(stats: RunStats) -> U32:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      path_corner

def run_stats_add_gold(stats: RunStats, amount: U32) -> RunStats:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      run_stats{gold_collected + amount, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}

def run_stats_record_weapon_pickup(stats: RunStats, dmg: U32) -> RunStats:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      run_stats{gold_collected, items_collected + 1, weapon_damage_gained + dmg, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}

def run_stats_record_potion_pickup(stats: RunStats, effective_heal: U32) -> RunStats:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      run_stats{gold_collected, items_collected + 1, weapon_damage_gained, potion_heal_effective + effective_heal, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}

def run_stats_record_path(stats: RunStats, hero_index: U32) -> RunStats:
  _run_stats_record_path_match(stats, hero_index === 4, _path_edge_match(hero_index), _path_corner_match(hero_index))

def _run_stats_record_path_match(stats: RunStats, is_center: U32, is_edge: U32, is_corner: U32) -> RunStats:
  match is_center is_edge is_corner stats:
    case 1 _ _ run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center + 1, path_edge, path_corner}
    case _ 1 _ run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge + 1, path_corner}
    case _ _ 1 run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner + 1}
    case _ _ _ run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      stats

def _path_edge_match(hero_index: U32) -> U32:
  _path_edge_match_inner(hero_index === 1, hero_index === 3, hero_index === 5, hero_index === 7)

def _path_edge_match_inner(is_1: U32, is_3: U32, is_5: U32, is_7: U32) -> U32:
  match is_1 is_3 is_5 is_7:
    case 1 _ _ _:
      1
    case _ 1 _ _:
      1
    case _ _ 1 _:
      1
    case _ _ _ 1:
      1
    case _ _ _ _:
      0

def _path_corner_match(hero_index: U32) -> U32:
  _path_corner_match_inner(hero_index === 0, hero_index === 2, hero_index === 6, hero_index === 8)

def _path_corner_match_inner(is_0: U32, is_2: U32, is_6: U32, is_8: U32) -> U32:
  match is_0 is_2 is_6 is_8:
    case 1 _ _ _:
      1
    case _ 1 _ _:
      1
    case _ _ 1 _:
      1
    case _ _ _ 1:
      1
    case _ _ _ _:
      0

def run_stats_record_monster_combat(stats: RunStats, hero_hp_before: U32, weapon_value: Weapon, monster_hp: U32, spawn_level: U32) -> RunStats:
  _run_stats_record_monster_result(stats, _combat_damage_dealt(hero_hp_before, weapon_value, monster_hp), _monster_defeated(hero_hp_before, weapon_value, monster_hp), spawn_level)

def _run_stats_record_monster_result(stats: RunStats, damage: U32, defeated: U32, spawn_level: U32) -> RunStats:
  match stats defeated:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner} 0:
      run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt + damage, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner} _:
      run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated + 1, damage_dealt + damage, monster_level_sum + spawn_level, monster_level_count + 1, path_center, path_edge, path_corner}

def _combat_damage_dealt(hero_hp_before: U32, weapon_value: Weapon, monster_hp: U32) -> U32:
  match weapon_value:
    case no_weapon{}:
      _combat_damage_unarmed(hero_hp_before > monster_hp, monster_hp)
    case weapon{class_kind, dmg}:
      _combat_damage_armed(dmg > monster_hp, dmg, monster_hp)

def _combat_damage_unarmed(hero_wins: U32, monster_hp: U32) -> U32:
  match hero_wins:
    case 0:
      0
    case _:
      monster_hp

def _combat_damage_armed(overkill: U32, dmg: U32, monster_hp: U32) -> U32:
  match overkill:
    case 0:
      dmg
    case _:
      monster_hp

def _monster_defeated(hero_hp_before: U32, weapon_value: Weapon, monster_hp: U32) -> U32:
  match weapon_value:
    case no_weapon{}:
      _monster_defeated_unarmed(hero_hp_before > monster_hp)
    case weapon{class_kind, dmg}:
      _monster_defeated_armed(dmg < monster_hp)

def _monster_defeated_unarmed(hero_wins: U32) -> U32:
  match hero_wins:
    case 0:
      0
    case _:
      1

def _monster_defeated_armed(dmg_lt_hp: U32) -> U32:
  match dmg_lt_hp:
    case 0:
      1
    case _:
      0
