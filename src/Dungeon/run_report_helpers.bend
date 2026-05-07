import Dungeon/Run as Run
import Dungeon/RunStats as RunStats
import Nat/div as div_nat
import Nat/to_u32 as nat_to_u32
import U32/to_nat as u32_to_nat

def run_report_stats(run_value: Run) -> RunStats:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      stats

def run_report_average_level_text(run_value: Run) -> String:
  _average_level_text_from_stats(run_report_stats(run_value))

def _average_level_text_from_stats(stats: RunStats) -> String:
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      _average_level_text(monster_level_count === 0, monster_level_sum, monster_level_count)

def _average_level_text(no_levels: U32, level_sum: U32, level_count: U32) -> String:
  match no_levels:
    case 1:
      "0.0"
    case _:
      _average_level_scaled_text(_scaled_average_tenths(level_sum, level_count))

def _scaled_average_tenths(level_sum: U32, level_count: U32) -> U32:
  nat_to_u32(div_nat(u32_to_nat(level_sum * 10), u32_to_nat(level_count)))

def _average_level_scaled_text(tenths: U32) -> String:
  whole = nat_to_u32(div_nat(u32_to_nat(tenths), 10n));
  fractional = tenths - (whole * 10);
  U32/show(whole) ++ "." ++ U32/show(fractional)
