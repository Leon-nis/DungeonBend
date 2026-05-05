import Dungeon/Config as Config
import Dungeon/MonsterDef as MonsterDef
import Dungeon/MonsterClass as MonsterClass
import Dungeon/config as config

def monster_class(ref: U32) -> MonsterClass:
  _monster_class_from_config(config(), ref)

def monster_tier(ref: U32) -> U32:
  _monster_tier_from_config(config(), ref)

def monster_limit(ref: U32) -> U32:
  monster_class_limit(monster_class(ref))

def monster_class_label(ref: U32) -> String:
  monster_class_name(monster_class(ref))

def monster_class_limit(class_kind: MonsterClass) -> U32:
  match class_kind:
    case monster_normal{}:
      8
    case monster_champion{}:
      1
    case monster_boss{}:
      1

def monster_class_name(class_kind: MonsterClass) -> String:
  match class_kind:
    case monster_normal{}:
      "Normal"
    case monster_champion{}:
      "Champion"
    case monster_boss{}:
      "Boss"

def _monster_class_from_config(config_value: Config, ref: U32) -> MonsterClass:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _monster_class_from_list(monsters, ref)

def _monster_class_from_list(monsters: List(MonsterDef), ref: U32) -> MonsterClass:
  match monsters:
    case []:
      monster_normal{}
    case monster_def{name, sprite, class_kind, tier, rarity, gold_levels, hp_levels}<>rest:
      match ref:
        case 0:
          class_kind
        case _:
          _monster_class_from_list(rest, ref - 1)

def _monster_tier_from_config(config_value: Config, ref: U32) -> U32:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _monster_tier_from_list(monsters, ref)

def _monster_tier_from_list(monsters: List(MonsterDef), ref: U32) -> U32:
  match monsters:
    case []:
      0
    case monster_def{name, sprite, class_kind, tier, rarity, gold_levels, hp_levels}<>rest:
      match ref:
        case 0:
          tier
        case _:
          _monster_tier_from_list(rest, ref - 1)
