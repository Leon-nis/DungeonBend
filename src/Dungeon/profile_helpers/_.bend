def profile_helpers() -> Unit:
  unit{}

import Dungeon as Dungeon
import Dungeon/hero_helpers as M__Dungeon_hero_helpers

def default_hero_profile() -> Dungeon/HeroProfile:
  hero_profile{0, 0}

def default_profile_for_hero(hero_ref: U32) -> Dungeon/HeroProfile:
  match hero_ref:
    case 0:
      hero_profile{1, 0}
    case _:
      default_hero_profile()

def default_profile_from_hero(hero_value: Dungeon/HeroDef) -> Dungeon/HeroProfile:
  hero_profile{Dungeon/hero_helpers/hero_starts_unlocked(hero_value), 0}

def _default_hero_profiles_from_list(heroes: List(Dungeon/HeroDef), hero_ref: U32) -> List(Dungeon/HeroProfile):
  match heroes:
    case []:
      []
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades}<>rest:
      default_profile_from_hero(hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades})<>_default_hero_profiles_from_list(rest, hero_ref + 1)

def default_hero_profiles(config_value: Dungeon/Config) -> List(Dungeon/HeroProfile):
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _default_hero_profiles_from_list(heroes, 0)

def selection_confirmed(meta_state: Dungeon/Meta) -> U32:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      confirmed

def hero_profiles(meta_state: Dungeon/Meta) -> List(Dungeon/HeroProfile):
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      profiles

def selected_hero(meta_state: Dungeon/Meta) -> U32:
  match meta_state:
    case meta{selected_hero_ref, selection_confirmed, gold, bonus_deck, pack_inventory, hero_profiles, decks, active_deck_id, next_deck_id}:
      selected_hero_ref

def meta_gold(meta_state: Dungeon/Meta) -> U32:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      gold

def meta_bonus_deck(meta_state: Dungeon/Meta) -> List(Dungeon/DeckEntry):
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      bonus_deck

def meta_pack_inventory(meta_state: Dungeon/Meta) -> List(Dungeon/PackInventoryEntry):
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      pack_inventory

def meta_decks(meta_state: Dungeon/Meta) -> List(Dungeon/DeckRecord):
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      decks

def meta_active_deck_id(meta_state: Dungeon/Meta) -> U32:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      active_deck_id

def meta_next_deck_id(meta_state: Dungeon/Meta) -> U32:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      next_deck_id

def _profile_at(profiles: List(Dungeon/HeroProfile), hero_ref: U32) -> Dungeon/HeroProfile:
  match profiles:
    case []:
      default_profile_for_hero(hero_ref)
    case hero_profile{unlocked, hero_level}<>rest:
      match hero_ref:
        case 0:
          hero_profile{unlocked, hero_level}
        case _:
          _profile_at(rest, hero_ref - 1)

def profile_for_hero(meta_state: Dungeon/Meta, hero_ref: U32) -> Dungeon/HeroProfile:
  _profile_at(hero_profiles(meta_state), hero_ref)

def active_profile(meta_state: Dungeon/Meta) -> Dungeon/HeroProfile:
  profile_for_hero(meta_state, selected_hero(meta_state))

def _update_profile_list_match(matched: U32, current: Dungeon/HeroProfile, rest_result: List(Dungeon/HeroProfile), rest: List(Dungeon/HeroProfile), next_profile: Dungeon/HeroProfile) -> List(Dungeon/HeroProfile):
  match matched:
    case 0:
      current<>rest_result
    case _:
      next_profile<>rest

def _update_profile_missing(hero_ref: U32, next_profile: Dungeon/HeroProfile, current_ref: U32) -> List(Dungeon/HeroProfile):
  match hero_ref:
    case 0:
      [next_profile]
    case _:
      default_profile_for_hero(current_ref)<>_update_profile_missing(hero_ref - 1, next_profile, current_ref + 1)

def _update_profile_list(profiles: List(Dungeon/HeroProfile), hero_ref: U32, next_profile: Dungeon/HeroProfile) -> List(Dungeon/HeroProfile):
  match profiles:
    case []:
      _update_profile_missing(hero_ref, next_profile, 0)
    case current<>rest:
      match hero_ref:
        case 0:
          next_profile<>rest
        case _:
          current<>_update_profile_list(rest, hero_ref - 1, next_profile)

def update_profile(meta_state: Dungeon/Meta, hero_ref: U32, next_profile: Dungeon/HeroProfile) -> Dungeon/Meta:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, _update_profile_list(profiles, hero_ref, next_profile), decks, active_deck_id, next_deck_id}

def set_selected_hero(meta_state: Dungeon/Meta, hero_ref: U32) -> Dungeon/Meta:
  match meta_state:
    case meta{current_selected, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      meta{hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}

def set_selection_confirmed(meta_state: Dungeon/Meta, confirmed: U32) -> Dungeon/Meta:
  match meta_state:
    case meta{selected_hero_ref, current_confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}

def set_meta_gold(meta_state: Dungeon/Meta, next_gold: U32) -> Dungeon/Meta:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      meta{selected_hero_ref, confirmed, next_gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}

def set_meta_bonus_deck(meta_state: Dungeon/Meta, next_bonus_deck: List(Dungeon/DeckEntry)) -> Dungeon/Meta:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      meta{selected_hero_ref, confirmed, gold, next_bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}

def set_meta_pack_inventory(meta_state: Dungeon/Meta, next_pack_inventory: List(Dungeon/PackInventoryEntry)) -> Dungeon/Meta:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      meta{selected_hero_ref, confirmed, gold, bonus_deck, next_pack_inventory, profiles, decks, active_deck_id, next_deck_id}

def set_meta_decks(meta_state: Dungeon/Meta, next_decks: List(Dungeon/DeckRecord)) -> Dungeon/Meta:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, next_decks, active_deck_id, next_deck_id}

def set_meta_active_deck_id(meta_state: Dungeon/Meta, next_active: U32) -> Dungeon/Meta:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, next_active, next_deck_id}

def set_meta_next_deck_id(meta_state: Dungeon/Meta, next_value: U32) -> Dungeon/Meta:
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_deck_id}:
      meta{selected_hero_ref, confirmed, gold, bonus_deck, pack_inventory, profiles, decks, active_deck_id, next_value}

def profile_unlocked(profile: Dungeon/HeroProfile) -> U32:
  match profile:
    case hero_profile{unlocked, hero_level}:
      unlocked

def profile_hero_level(profile: Dungeon/HeroProfile) -> U32:
  match profile:
    case hero_profile{unlocked, hero_level}:
      hero_level

def profile_with_unlocked(profile: Dungeon/HeroProfile, next_unlocked: U32) -> Dungeon/HeroProfile:
  match profile:
    case hero_profile{unlocked, hero_level}:
      hero_profile{next_unlocked, hero_level}

def profile_with_level(profile: Dungeon/HeroProfile, next_level: U32) -> Dungeon/HeroProfile:
  match profile:
    case hero_profile{unlocked, hero_level}:
      hero_profile{unlocked, next_level}

def profile_with_unlocked_and_level(profile: Dungeon/HeroProfile, next_unlocked: U32, next_level: U32) -> Dungeon/HeroProfile:
  match profile:
    case hero_profile{unlocked, hero_level}:
      hero_profile{next_unlocked, next_level}
