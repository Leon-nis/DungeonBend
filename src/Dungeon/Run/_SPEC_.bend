import Dungeon/RunStats as RunStats
import Dungeon/Weapon as Weapon
import Dungeon/run_stats_helpers/empty_run_stats as empty_run_stats
import Dungeon/run_stats_helpers/run_stats_add_gold as run_stats_add_gold
import Dungeon/run_stats_helpers/run_stats_record_monster_combat as run_stats_record_monster_combat
import Dungeon/run_stats_helpers/run_stats_record_path as run_stats_record_path
import Dungeon/run_stats_helpers/run_stats_record_potion_pickup as run_stats_record_potion_pickup
import Dungeon/run_stats_helpers/run_stats_record_weapon_pickup as run_stats_record_weapon_pickup

assert run_stats_start_empty:
  empty_run_stats()
    == run_stats{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    :: RunStats

assert run_stats_gold_pickup_adds_gold_only:
  run_stats_add_gold(empty_run_stats(), 7)
    == run_stats{7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    :: RunStats

assert run_stats_weapon_pickup_tracks_item_and_damage:
  run_stats_record_weapon_pickup(empty_run_stats(), 5)
    == run_stats{0, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0}
    :: RunStats

assert run_stats_potion_pickup_uses_effective_heal_input:
  run_stats_record_potion_pickup(empty_run_stats(), 3)
    == run_stats{0, 1, 0, 3, 0, 0, 0, 0, 0, 0, 0}
    :: RunStats

assert run_stats_path_center_bucket:
  run_stats_record_path(empty_run_stats(), 4)
    == run_stats{0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0}
    :: RunStats

assert run_stats_path_edge_bucket:
  run_stats_record_path(empty_run_stats(), 1)
    == run_stats{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0}
    :: RunStats

assert run_stats_path_corner_bucket:
  run_stats_record_path(empty_run_stats(), 0)
    == run_stats{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
    :: RunStats

assert run_stats_unarmed_kill_tracks_damage_and_level:
  run_stats_record_monster_combat(empty_run_stats(), 5, no_weapon{}, 4, 3)
    == run_stats{0, 0, 0, 0, 1, 4, 3, 1, 0, 0, 0}
    :: RunStats

assert run_stats_weapon_partial_hit_tracks_damage_only:
  run_stats_record_monster_combat(empty_run_stats(), 5, weapon{weapon_sword{}, 2}, 4, 3)
    == run_stats{0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0}
    :: RunStats
