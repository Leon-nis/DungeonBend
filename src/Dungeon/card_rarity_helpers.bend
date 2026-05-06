import Dungeon/Config as Config
import Dungeon/CardRef as CardRef
import Dungeon/CardRarity as CardRarity
import Dungeon/LootRarity as LootRarity
import Dungeon/MonsterDef as MonsterDef
import Dungeon/SwordDef as SwordDef
import Dungeon/PotionDef as PotionDef
import Dungeon/config as config

def card_rarity(card: CardRef) -> CardRarity:
  match card:
    case monster_card{ref}:
      monster_card_rarity(ref)
    case sword_card{ref}:
      sword_card_rarity(ref)
    case potion_card{ref}:
      potion_card_rarity(ref)
    case hero_card{}:
      card_rarity_monster{}

def monster_card_rarity(ref: U32) -> CardRarity:
  _monster_card_rarity_from_config(config(), ref)

def sword_card_rarity(ref: U32) -> CardRarity:
  _sword_card_rarity_from_config(config(), ref)

def potion_card_rarity(ref: U32) -> CardRarity:
  _potion_card_rarity_from_config(config(), ref)

def _monster_card_rarity_from_config(config_value: Config, ref: U32) -> CardRarity:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _monster_card_rarity_from_list(monsters, ref)

def _monster_card_rarity_from_list(monsters: List(MonsterDef), ref: U32) -> CardRarity:
  match monsters:
    case []:
      card_rarity_monster{}
    case monster_def{name, sprite, class_kind, tier, rarity, gold_levels, hp_levels}<>rest:
      match ref:
        case 0:
          rarity
        case _:
          _monster_card_rarity_from_list(rest, ref - 1)

def _sword_card_rarity_from_config(config_value: Config, ref: U32) -> CardRarity:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _sword_card_rarity_from_list(swords, ref)

def _sword_card_rarity_from_list(swords: List(SwordDef), ref: U32) -> CardRarity:
  match swords:
    case []:
      card_rarity_equipment{loot_common{}}
    case sword_def{name, sprite, rarity, dmg}<>rest:
      match ref:
        case 0:
          rarity
        case _:
          _sword_card_rarity_from_list(rest, ref - 1)

def _potion_card_rarity_from_config(config_value: Config, ref: U32) -> CardRarity:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _potion_card_rarity_from_list(potions, ref)

def _potion_card_rarity_from_list(potions: List(PotionDef), ref: U32) -> CardRarity:
  match potions:
    case []:
      card_rarity_consumable{loot_common{}}
    case potion_def{name, sprite, rarity, heal}<>rest:
      match ref:
        case 0:
          rarity
        case _:
          _potion_card_rarity_from_list(rest, ref - 1)

def loot_rarity_label(rarity: LootRarity) -> String:
  match rarity:
    case loot_common{}:
      "Comum"
    case loot_uncommon{}:
      "Incomum"
    case loot_rare{}:
      "Raro"
    case loot_epic{}:
      "Epico"

def equipment_limit_for_rarity(rarity: LootRarity) -> U32:
  match rarity:
    case loot_common{}:
      3
    case loot_uncommon{}:
      3
    case _:
      1

def card_background(card: CardRef) -> String:
  _background_for_rarity(card_rarity(card))

def _background_for_rarity(rarity: CardRarity) -> String:
  match rarity:
    case card_rarity_monster{}:
      "assets/background-comum.png"
    case card_rarity_consumable{loot_rarity}:
      _background_for_loot_rarity(loot_rarity)
    case card_rarity_equipment{loot_rarity}:
      _background_for_loot_rarity(loot_rarity)

def _background_for_loot_rarity(rarity: LootRarity) -> String:
  match rarity:
    case loot_common{}:
      "assets/background-comum.png"
    case loot_uncommon{}:
      "assets/background-incomum.png"
    case loot_rare{}:
      "assets/background-rare.png"
    case loot_epic{}:
      "assets/background-epic.png"
