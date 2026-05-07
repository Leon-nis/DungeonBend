import Dungeon/Run as Run
import Dungeon/PassiveDef as PassiveDef
import Dungeon/config as config
import Dungeon/hero_helpers/hero_at as hero_at
import Dungeon/hero_helpers/hero_passive as hero_passive

def _run_hero_ref(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state}:
      hero_ref

def run_passive(run_value: Run) -> PassiveDef:
  hero_passive(hero_at(config(), _run_hero_ref(run_value)))

def passive_is_none(passive_value: PassiveDef) -> U32:
  match passive_value:
    case passive_none{}:
      1
    case _:
      0
