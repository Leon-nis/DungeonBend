import Dungeon/game_config as config
import Dungeon as Dungeon
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick
import Dungeon/Boosters/inventory as M__Dungeon_Boosters_inventory
import Dungeon/profile_helpers as M__Dungeon_profile_helpers
import Dungeon/Deck/deck_records as M__Dungeon_Deck_deck_records
import Dungeon/Deck/sleeves as M__Dungeon_Deck_sleeves

def _profile_string(profile: Dungeon/HeroProfile) -> String:
  String/join(
    [
      U32/show(Dungeon/profile_helpers/profile_unlocked(profile)),
      U32/show(Dungeon/profile_helpers/profile_hero_level(profile))
    ],
    "~"
  )

def _profile_strings(heroes: List(Dungeon/HeroDef), profiles: List(Dungeon/HeroProfile), hero_ref: U32) -> List(String):
  match heroes profiles:
    case [] _:
      []
    case hero_value<>hero_rest []:
      _profile_string(Dungeon/profile_helpers/default_profile_for_hero(hero_ref))<>_profile_strings(hero_rest, [], hero_ref + 1)
    case hero_value<>hero_rest profile<>profile_rest:
      _profile_string(profile)<>_profile_strings(hero_rest, profile_rest, hero_ref + 1)

def _monster_bonus_counts(monsters: List(Dungeon/MonsterDef), bonus_deck: List(Dungeon/DeckEntry), idx: U32) -> List(String):
  match monsters:
    case []:
      []
    case monster_def{name, sprite, gold_drop, hp_levels}<>rest:
      U32/show(Dungeon/Deck/counts_pick/deck_count_for_card(bonus_deck, monster_card{idx}))<>_monster_bonus_counts(rest, bonus_deck, idx + 1)

def _sword_bonus_counts(swords: List(Dungeon/SwordDef), bonus_deck: List(Dungeon/DeckEntry), idx: U32) -> List(String):
  match swords:
    case []:
      []
    case sword_def{name, sprite, dmg}<>rest:
      U32/show(Dungeon/Deck/counts_pick/deck_count_for_card(bonus_deck, sword_card{idx}))<>_sword_bonus_counts(rest, bonus_deck, idx + 1)

def _potion_bonus_counts(potions: List(Dungeon/PotionDef), bonus_deck: List(Dungeon/DeckEntry), idx: U32) -> List(String):
  match potions:
    case []:
      []
    case potion_def{name, sprite, heal}<>rest:
      U32/show(Dungeon/Deck/counts_pick/deck_count_for_card(bonus_deck, potion_card{idx}))<>_potion_bonus_counts(rest, bonus_deck, idx + 1)

def _pack_inventory_counts(packs: List(Dungeon/PackDef), pack_inventory: List(Dungeon/PackInventoryEntry), idx: U32) -> List(String):
  match packs:
    case []:
      []
    case pack_def{name, price, reveal_count, allow_duplicates, pool}<>rest:
      U32/show(Dungeon/Boosters/inventory/pack_inventory_count(pack_inventory, idx))<>_pack_inventory_counts(rest, pack_inventory, idx + 1)

def _sanitize_name(name: String) -> String:
  String/replace(String/replace(String/replace(String/replace(name, "|", " "), ";", " "), "~", " "), ",", " ")

def _deck_record_string(monsters: List(Dungeon/MonsterDef), swords: List(Dungeon/SwordDef), potions: List(Dungeon/PotionDef), record: Dungeon/DeckRecord) -> String:
  entries = Dungeon/Deck/deck_records/deck_record_entries(record);
  String/join(
    [
      U32/show(Dungeon/Deck/deck_records/deck_record_id(record)),
      _sanitize_name(Dungeon/Deck/deck_records/deck_record_name(record)),
      Dungeon/Deck/sleeves/sleeve_code(Dungeon/Deck/deck_records/deck_record_sleeve(record)),
      String/join(_monster_bonus_counts(monsters, entries, 0), ","),
      String/join(_sword_bonus_counts(swords, entries, 0), ","),
      String/join(_potion_bonus_counts(potions, entries, 0), ","),
      U32/show(Dungeon/Deck/counts_pick/deck_count_for_card(entries, hero_card{}))
    ],
    "~"
  )

def _deck_records_strings(monsters: List(Dungeon/MonsterDef), swords: List(Dungeon/SwordDef), potions: List(Dungeon/PotionDef), records: List(Dungeon/DeckRecord)) -> List(String):
  match records:
    case []:
      []
    case current<>rest:
      _deck_record_string(monsters, swords, potions, current)<>_deck_records_strings(monsters, swords, potions, rest)

def _meta_to_string_from_config(config_value: Dungeon/Config, meta_state: Dungeon/Meta) -> String:
  match config_value meta_state:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} meta{selected_hero_ref, selection_confirmed_value, gold, bonus_deck, pack_inventory, hero_profiles, decks, active_deck_id, next_deck_id}:
      String/join(
        [
          "v7",
          U32/show(selected_hero_ref),
          U32/show(selection_confirmed_value),
          U32/show(gold),
          String/join(_monster_bonus_counts(monsters, bonus_deck, 0), ","),
          String/join(_sword_bonus_counts(swords, bonus_deck, 0), ","),
          String/join(_potion_bonus_counts(potions, bonus_deck, 0), ","),
          String/join(_pack_inventory_counts(booster_packs, pack_inventory, 0), ","),
          String/join(_profile_strings(heroes, hero_profiles, 0), ";"),
          U32/show(active_deck_id),
          U32/show(next_deck_id),
          String/join(_deck_records_strings(monsters, swords, potions, decks), ";")
        ],
        "|"
      )

def meta_to_string(meta_state: Dungeon/Meta) -> String:
  _meta_to_string_from_config(config(), meta_state)
