import Dungeon/Upgrade as Upgrade
import Dungeon/HeroDef as HeroDef
import Dungeon/PassiveDef as PassiveDef
import Dungeon/UltimateKind as UltimateKind
import Dungeon/Config as Config

def hero_count(config_value: Config) -> U32:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _hero_count_from_list(heroes)

def _hero_count_from_list(heroes: List(HeroDef)) -> U32:
  match heroes:
    case []:
      0
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}<>rest:
      1 + _hero_count_from_list(rest)

def normalize_hero_ref(config_value: Config, hero_ref: U32) -> U32:
  _normalize_hero_ref_from_count(hero_count(config_value), hero_ref)

def _normalize_hero_ref_from_count(count: U32, hero_ref: U32) -> U32:
  match count:
    case 0:
      0
    case _:
      _normalize_hero_ref_in_range(hero_ref < count, count, hero_ref)

def _normalize_hero_ref_in_range(in_range: U32, count: U32, hero_ref: U32) -> U32:
  match in_range:
    case 0:
      count - 1
    case _:
      hero_ref

def hero_at(config_value: Config, hero_ref: U32) -> HeroDef:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _hero_at_from_list(heroes, normalize_hero_ref(config_value, hero_ref))

def _hero_at_from_list(heroes: List(HeroDef), hero_ref: U32) -> HeroDef:
  match heroes:
    case []:
      hero_def{"hero", "Hero", "", 1, 0, 1, [], ultimate_refill{}, 1, passive_none{}}
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}<>rest:
      match hero_ref:
        case 0:
          hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}
        case _:
          _hero_at_from_list(rest, hero_ref - 1)

def next_hero_ref(config_value: Config, hero_ref: U32) -> U32:
  count = hero_count(config_value);
  safe_ref = normalize_hero_ref(config_value, hero_ref);
  _next_hero_ref_from_count(count, safe_ref)

def _next_hero_ref_from_count(count: U32, hero_ref: U32) -> U32:
  match count:
    case 0:
      0
    case _:
      _next_hero_ref_in_range(hero_ref + 1 < count, hero_ref)

def _next_hero_ref_in_range(in_range: U32, hero_ref: U32) -> U32:
  match in_range:
    case 0:
      0
    case _:
      hero_ref + 1

def prev_hero_ref(config_value: Config, hero_ref: U32) -> U32:
  count = hero_count(config_value);
  safe_ref = normalize_hero_ref(config_value, hero_ref);
  _prev_hero_ref_from_count(count, safe_ref)

def _prev_hero_ref_from_count(count: U32, hero_ref: U32) -> U32:
  match count:
    case 0:
      0
    case _:
      _prev_hero_ref_at_start(hero_ref === 0, count, hero_ref)

def _prev_hero_ref_at_start(at_start: U32, count: U32, hero_ref: U32) -> U32:
  match at_start:
    case 0:
      hero_ref - 1
    case _:
      count - 1

def hero_id(hero_value: HeroDef) -> String:
  match hero_value:
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}:
      id

def hero_name(hero_value: HeroDef) -> String:
  match hero_value:
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}:
      name

def hero_sprite(hero_value: HeroDef) -> String:
  match hero_value:
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}:
      sprite

def hero_base_max_hp(hero_value: HeroDef) -> U32:
  match hero_value:
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}:
      base_max_hp

def hero_unlock_cost(hero_value: HeroDef) -> U32:
  match hero_value:
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}:
      unlock_cost

def hero_starts_unlocked(hero_value: HeroDef) -> U32:
  match hero_value:
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}:
      starts_unlocked

def hero_upgrades(hero_value: HeroDef) -> List(Upgrade):
  match hero_value:
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}:
      upgrades

def hero_ultimate_kind(hero_value: HeroDef) -> UltimateKind:
  match hero_value:
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}:
      ultimate_kind

def hero_ultimate_charge_required(hero_value: HeroDef) -> U32:
  match hero_value:
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}:
      ultimate_charge_required

def hero_passive(hero_value: HeroDef) -> PassiveDef:
  match hero_value:
    case hero_def{id, name, sprite, base_max_hp, unlock_cost, starts_unlocked, upgrades, ultimate_kind, ultimate_charge_required, passive}:
      passive

def hero_has_passive(hero_value: HeroDef) -> U32:
  match hero_passive(hero_value):
    case passive_none{}:
      0
    case _:
      1
