import Dungeon as Dungeon
import List/append as append

def generated_hero_0_upgrades_chunk_0() -> List(Dungeon/Upgrade):
  [
    upgrade{40, 14},
    upgrade{70, 16},
    upgrade{100, 18},
    upgrade{130, 20}
  ]

def generated_hero_1_upgrades_chunk_0() -> List(Dungeon/Upgrade):
  [
    upgrade{36, 12},
    upgrade{60, 14},
    upgrade{84, 17},
    upgrade{108, 20}
  ]

def generated_monster_0_gold_levels_chunk_0() -> List(U32):
  [
    0,
    0,
    1,
    2,
    3,
    3,
    4,
    5,
    6,
    6,
    6,
    6,
    6,
    6,
    6
  ]

def generated_monster_0_hp_levels_chunk_0() -> List(U32):
  [
    3,
    4,
    6,
    7,
    9,
    10,
    12,
    13,
    15,
    16,
    16,
    16,
    16,
    16,
    16
  ]

def generated_monster_1_gold_levels_chunk_0() -> List(U32):
  [
    1,
    1,
    1,
    2,
    2,
    2,
    3,
    3,
    4,
    4,
    4,
    5,
    5,
    5,
    6
  ]

def generated_monster_1_hp_levels_chunk_0() -> List(U32):
  [
    7,
    7,
    8,
    9,
    9,
    10,
    11,
    11,
    12,
    13,
    13,
    14,
    15,
    15,
    16
  ]

def generated_monster_2_gold_levels_chunk_0() -> List(U32):
  [
    1,
    1,
    1,
    2,
    2,
    2,
    3,
    3,
    4,
    4,
    4,
    5,
    5,
    5,
    6
  ]

def generated_monster_2_hp_levels_chunk_0() -> List(U32):
  [
    7,
    7,
    8,
    9,
    9,
    10,
    11,
    11,
    12,
    13,
    13,
    14,
    15,
    15,
    16
  ]

def generated_monster_3_gold_levels_chunk_0() -> List(U32):
  [
    5,
    5,
    5,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6
  ]

def generated_monster_3_hp_levels_chunk_0() -> List(U32):
  [
    10,
    12,
    14,
    16,
    18,
    18,
    18,
    18,
    18,
    18,
    18,
    18,
    18,
    18,
    18
  ]

def generated_monster_4_gold_levels_chunk_0() -> List(U32):
  [
    0,
    0,
    1,
    1,
    2,
    2,
    3,
    3,
    4,
    4,
    5,
    5,
    6,
    6,
    7
  ]

def generated_monster_4_hp_levels_chunk_0() -> List(U32):
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

def generated_monster_5_gold_levels_chunk_0() -> List(U32):
  [
    0,
    0,
    1,
    2,
    3,
    3,
    4,
    5,
    6,
    6,
    6,
    6,
    6,
    6,
    6
  ]

def generated_monster_5_hp_levels_chunk_0() -> List(U32):
  [
    3,
    4,
    6,
    7,
    9,
    10,
    12,
    13,
    15,
    16,
    16,
    16,
    16,
    16,
    16
  ]

def generated_monster_6_gold_levels_chunk_0() -> List(U32):
  [
    2,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    10,
    10,
    10,
    10,
    10
  ]

def generated_monster_6_hp_levels_chunk_0() -> List(U32):
  [
    8,
    9,
    11,
    12,
    14,
    15,
    17,
    18,
    20,
    21,
    21,
    21,
    21,
    21,
    21
  ]

def generated_monster_7_gold_levels_chunk_0() -> List(U32):
  [
    4,
    4,
    4,
    5,
    5,
    6,
    6,
    6,
    7,
    7,
    8,
    8,
    8,
    9,
    9
  ]

def generated_monster_7_hp_levels_chunk_0() -> List(U32):
  [
    14,
    14,
    14,
    15,
    15,
    16,
    16,
    16,
    17,
    17,
    18,
    18,
    18,
    19,
    19
  ]

def generated_pack_0_pool_chunk_0() -> List(Dungeon/PackPoolEntry):
  [
    pack_pool_entry{monster_card{6}, 4},
    pack_pool_entry{monster_card{3}, 4},
    pack_pool_entry{sword_card{0}, 3},
    pack_pool_entry{sword_card{1}, 2},
    pack_pool_entry{sword_card{2}, 1},
    pack_pool_entry{potion_card{0}, 3},
    pack_pool_entry{potion_card{1}, 2},
    pack_pool_entry{potion_card{2}, 1}
  ]

def generated_config_heroes_chunk_0() -> List(Dungeon/HeroDef):
  [
    hero_def{"adventurer", "Adventurer", "assets/player-boy.png", 15, 0, 1, generated_hero_0_upgrades_chunk_0()},
    hero_def{"gato_de_botas", "Gato de Botas", "assets/player-gato-de-botas.png", 10, 45, 0, generated_hero_1_upgrades_chunk_0()}
  ]

def generated_config_monsters_chunk_0() -> List(Dungeon/MonsterDef):
  [
    monster_def{"Rat", "assets/enemy-rat.png", generated_monster_0_gold_levels_chunk_0(), generated_monster_0_hp_levels_chunk_0()},
    monster_def{"Black Widow", "assets/enemy-spider2.png", generated_monster_1_gold_levels_chunk_0(), generated_monster_1_hp_levels_chunk_0()},
    monster_def{"Venom Spider", "assets/enemy-spider.png", generated_monster_2_gold_levels_chunk_0(), generated_monster_2_hp_levels_chunk_0()},
    monster_def{"Orc", "assets/enemy-orc.png", generated_monster_3_gold_levels_chunk_0(), generated_monster_3_hp_levels_chunk_0()},
    monster_def{"Angry Plant", "assets/enemy-plant.png", generated_monster_4_gold_levels_chunk_0(), generated_monster_4_hp_levels_chunk_0()},
    monster_def{"Bat", "assets/enemy-bat.png", generated_monster_5_gold_levels_chunk_0(), generated_monster_5_hp_levels_chunk_0()},
    monster_def{"Zombie Dog", "assets/enemy-dog.png", generated_monster_6_gold_levels_chunk_0(), generated_monster_6_hp_levels_chunk_0()},
    monster_def{"Mimic", "assets/enemy-mimic.png", generated_monster_7_gold_levels_chunk_0(), generated_monster_7_hp_levels_chunk_0()}
  ]

def generated_config_swords_chunk_0() -> List(Dungeon/SwordDef):
  [
    sword_def{"Cleaver", "assets/item_small_cleaver.png", 4},
    sword_def{"Machete Sword", "assets/item-machete.png", 9},
    sword_def{"Vampire Sword", "assets/item-vampire_sword.png", 5},
    sword_def{"Giant Cleaver", "assets/item-big-cleaver.png", 16}
  ]

def generated_config_potions_chunk_0() -> List(Dungeon/PotionDef):
  [
    potion_def{"Health Potion", "assets/item-hp1.png", 3},
    potion_def{"Big Health Potion", "assets/item-hp2.png", 7},
    potion_def{"Giant Health Potion", "assets/item-hp3.png", 12}
  ]

def generated_config_base_deck_chunk_0() -> List(Dungeon/DeckEntry):
  [
    monster_entry{5, 7},
    monster_entry{4, 3},
    monster_entry{1, 3},
    monster_entry{6, 1},
    sword_entry{0, 1},
    sword_entry{1, 1},
    potion_entry{0, 3},
    potion_entry{1, 1},
    hero_entry{1}
  ]

def generated_config_packs_chunk_0() -> List(Dungeon/PackDef):
  [
    pack_def{"Starter Booster", 10, 4, 0, generated_pack_0_pool_chunk_0()}
  ]

def generated_config() -> Dungeon/Config:
  config{
    generated_config_heroes_chunk_0(),
    generated_config_monsters_chunk_0(),
    generated_config_swords_chunk_0(),
    generated_config_potions_chunk_0(),
    generated_config_base_deck_chunk_0(),
    generated_config_packs_chunk_0(),
    1
  }
