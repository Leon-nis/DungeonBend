import Dungeon as Dungeon
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick
import Dungeon/hero_helpers as M__Dungeon_hero_helpers
import Dungeon/profile_helpers as M__Dungeon_profile_helpers

def _upgrade_if_affordable_flag(gold_lt_cost: U32, meta_state: Dungeon/Meta, hero_ref: U32, profile: Dungeon/HeroProfile, cost: U32) -> Dungeon/Meta:
  match gold_lt_cost:
    case 0:
      Dungeon/profile_helpers/set_meta_gold(
        Dungeon/profile_helpers/update_profile(meta_state, hero_ref, Dungeon/profile_helpers/profile_with_level(profile, Dungeon/profile_helpers/profile_hero_level(profile) + 1)),
        Dungeon/profile_helpers/meta_gold(meta_state) - cost
      )
    case _:
      meta_state

def _upgrade_if_affordable(meta_state: Dungeon/Meta, hero_ref: U32, profile: Dungeon/HeroProfile, cost: U32) -> Dungeon/Meta:
  _upgrade_if_affordable_flag(Dungeon/profile_helpers/meta_gold(meta_state) < cost, meta_state, hero_ref, profile, cost)

def _upgrade_from_step(meta_state: Dungeon/Meta, hero_ref: U32, profile: Dungeon/HeroProfile, step: Dungeon/Upgrade) -> Dungeon/Meta:
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      meta_state
    case _:
      match step:
        case upgrade{cost, max_hp}:
          match max_hp:
            case 0:
              meta_state
            case _:
              _upgrade_if_affordable(meta_state, hero_ref, profile, cost)

def upgrade_hero_ref(config_value: Dungeon/Config, meta_state: Dungeon/Meta, hero_ref: U32) -> Dungeon/Meta:
  hero_value = Dungeon/hero_helpers/hero_at(config_value, hero_ref);
  profile = Dungeon/profile_helpers/profile_for_hero(meta_state, hero_ref);
  _upgrade_from_step(meta_state, hero_ref, profile, Dungeon/Deck/counts_pick/nth_upgrade(Dungeon/hero_helpers/hero_upgrades(hero_value), Dungeon/profile_helpers/profile_hero_level(profile)))

def upgrade_hero(config_value: Dungeon/Config, meta_state: Dungeon/Meta) -> Dungeon/Meta:
  hero_ref = Dungeon/profile_helpers/selected_hero(meta_state);
  upgrade_hero_ref(config_value, meta_state, hero_ref)
