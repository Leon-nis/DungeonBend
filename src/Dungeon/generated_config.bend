import Dungeon/Config as Config
import Dungeon/HeroDef as HeroDef
import Dungeon/Upgrade as Upgrade
import Dungeon/MonsterClass as MonsterClass
import Dungeon/CardRarity as CardRarity
import Dungeon/LootRarity as LootRarity
import Dungeon/MonsterDef as MonsterDef
import Dungeon/SwordDef as SwordDef
import Dungeon/PotionDef as PotionDef
import Dungeon/DeckEntry as DeckEntry
import Dungeon/CardRef as CardRef
import Dungeon/PackPoolEntry as PackPoolEntry
import Dungeon/PackDef as PackDef
import List/append as append

def generated_hero_0_upgrades_chunk_0() -> List(Upgrade):
  [
    upgrade{40, 14},
    upgrade{80, 16},
    upgrade{120, 18},
    upgrade{160, 20},
    upgrade{200, 22},
    upgrade{240, 24},
    upgrade{280, 26},
    upgrade{320, 28},
    upgrade{360, 30}
  ]

def generated_hero_1_upgrades_chunk_0() -> List(Upgrade):
  [
    upgrade{40, 14},
    upgrade{80, 16},
    upgrade{120, 18},
    upgrade{160, 20},
    upgrade{200, 22},
    upgrade{240, 24},
    upgrade{280, 26},
    upgrade{320, 28},
    upgrade{360, 30}
  ]

def generated_monster_0_gold_levels_chunk_0() -> List(U32):
  [
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17
  ]

def generated_monster_0_hp_levels_chunk_0() -> List(U32):
  [
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17
  ]

def generated_monster_1_gold_levels_chunk_0() -> List(U32):
  [
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18
  ]

def generated_monster_1_hp_levels_chunk_0() -> List(U32):
  [
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19
  ]

def generated_monster_2_gold_levels_chunk_0() -> List(U32):
  [
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19
  ]

def generated_monster_2_hp_levels_chunk_0() -> List(U32):
  [
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21
  ]

def generated_monster_3_gold_levels_chunk_0() -> List(U32):
  [
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20
  ]

def generated_monster_3_hp_levels_chunk_0() -> List(U32):
  [
    9,
    11,
    13,
    15,
    17,
    19,
    21,
    23,
    25,
    27,
    29,
    31,
    33,
    35,
    37
  ]

def generated_pack_0_pool_chunk_0() -> List(PackPoolEntry):
  [
    pack_pool_entry{monster_card{1}, 4},
    pack_pool_entry{monster_card{3}, 4},
    pack_pool_entry{sword_card{0}, 3},
    pack_pool_entry{sword_card{1}, 2},
    pack_pool_entry{sword_card{2}, 1},
    pack_pool_entry{potion_card{0}, 3},
    pack_pool_entry{potion_card{1}, 2},
    pack_pool_entry{potion_card{2}, 1}
  ]

def generated_config_heroes_chunk_0() -> List(HeroDef):
  [
    hero_def{"adventurer", "Adventurer", "assets/player-boy.png", 12, 0, 1, generated_hero_0_upgrades_chunk_0(), ultimate_refill{}, 8},
    hero_def{"gato_de_botas", "Gato de Botas", "assets/player-gato-de-botas.png", 12, 0, 1, generated_hero_1_upgrades_chunk_0(), ultimate_shadow_step{}, 4}
  ]

def generated_config_monsters_chunk_0() -> List(MonsterDef):
  [
    monster_def{"Rat", "assets/enemy-rat.png", monster_normal{}, 3, card_rarity_monster{}, generated_monster_0_gold_levels_chunk_0(), generated_monster_0_hp_levels_chunk_0()},
    monster_def{"Spider", "assets/enemy-spider.png", monster_normal{}, 4, card_rarity_monster{}, generated_monster_1_gold_levels_chunk_0(), generated_monster_1_hp_levels_chunk_0()},
    monster_def{"Venom Spider", "assets/enemy-spider2.png", monster_normal{}, 5, card_rarity_monster{}, generated_monster_2_gold_levels_chunk_0(), generated_monster_2_hp_levels_chunk_0()},
    monster_def{"Orc", "assets/enemy-orc.png", monster_normal{}, 6, card_rarity_monster{}, generated_monster_3_gold_levels_chunk_0(), generated_monster_3_hp_levels_chunk_0()}
  ]

def generated_config_swords_chunk_0() -> List(SwordDef):
  [
    sword_def{"Sword A", "assets/item-sword.png", card_rarity_equipment{loot_common{}}, weapon_sword{}, 5},
    sword_def{"Sword S", "assets/item-sword.png", card_rarity_equipment{loot_uncommon{}}, weapon_sword{}, 7},
    sword_def{"Sword S+", "assets/item-sword.png", card_rarity_equipment{loot_rare{}}, weapon_sword{}, 9}
  ]

def generated_config_potions_chunk_0() -> List(PotionDef):
  [
    potion_def{"Health Potion", "assets/item-potion.png", card_rarity_consumable{loot_common{}}, 3},
    potion_def{"Big Health Potion", "assets/item-potion.png", card_rarity_consumable{loot_uncommon{}}, 7},
    potion_def{"Giant Health Potion", "assets/item-potion.png", card_rarity_consumable{loot_rare{}}, 12}
  ]

def generated_config_base_deck_chunk_0() -> List(DeckEntry):
  [
    monster_entry{0, 7},
    monster_entry{1, 3},
    monster_entry{2, 3},
    monster_entry{3, 2},
    sword_entry{0, 1},
    sword_entry{1, 1},
    potion_entry{0, 2},
    potion_entry{1, 1},
    hero_entry{1}
  ]

def generated_config_packs_chunk_0() -> List(PackDef):
  [
    pack_def{"Starter Booster", 60, 4, 1, generated_pack_0_pool_chunk_0()}
  ]

def generated_config() -> Config:
  config{
    generated_config_heroes_chunk_0(),
    generated_config_monsters_chunk_0(),
    generated_config_swords_chunk_0(),
    generated_config_potions_chunk_0(),
    generated_config_base_deck_chunk_0(),
    generated_config_packs_chunk_0(),
    1
  }
