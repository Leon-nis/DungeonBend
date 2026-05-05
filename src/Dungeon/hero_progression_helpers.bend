import Dungeon/HeroDef as HeroDef
import Dungeon/Upgrade as Upgrade
import Dungeon/hero_helpers/hero_upgrades as hero_upgrades
import Dungeon/Deck/counts_pick/nth_upgrade as nth_upgrade
import Dungeon/rules/max_hero_upgrade_level as max_hero_upgrade_level

def hero_visible_max_level() -> U32:
  max_hero_upgrade_level()

def hero_upgrade_step_limit() -> U32:
  _upgrade_step_limit_for_level(max_hero_upgrade_level())

def _upgrade_step_limit_for_level(max_level: U32) -> U32:
  match max_level < 2:
    case 1:
      0
    case _:
      max_level - 1

def clamp_hero_upgrade_level(hero_level: U32) -> U32:
  _min_u32(hero_level, hero_upgrade_step_limit())

def _min_u32(left: U32, right: U32) -> U32:
  match left < right:
    case 1:
      left
    case _:
      right

def hero_next_upgrade(hero_value: HeroDef, hero_level: U32) -> Upgrade:
  capped_level = clamp_hero_upgrade_level(hero_level);
  limit = hero_upgrade_step_limit();
  match capped_level < limit:
    case 1:
      nth_upgrade(hero_upgrades(hero_value), capped_level)
    case _:
      upgrade{0, 0}
