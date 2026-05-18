def card_collection() -> Unit:
  unit{}

import Dungeon/game_config as config
import Dungeon as Dungeon
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick
import Dungeon/profile_helpers as M__Dungeon_profile_helpers

def collection_entries(cfg: Dungeon/Config, meta_state: Dungeon/Meta) -> List(Dungeon/DeckEntry):
  match cfg:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      Dungeon/Deck/counts_pick/merge_deck_entries(deck, Dungeon/profile_helpers/meta_bonus_deck(meta_state))

def collection_entries_default(meta_state: Dungeon/Meta) -> List(Dungeon/DeckEntry):
  collection_entries(config(), meta_state)

def pool_quantity(meta_state: Dungeon/Meta, card: Dungeon/CardRef) -> U32:
  Dungeon/Deck/counts_pick/deck_count_for_card(collection_entries_default(meta_state), card)

def deck_quantity(entries: List(Dungeon/DeckEntry), card: Dungeon/CardRef) -> U32:
  Dungeon/Deck/counts_pick/deck_count_for_card(entries, card)

def _saturating_sub(a: U32, b: U32) -> U32:
  match a < b:
    case 1:
      0
    case _:
      a - b

def available_for_add(meta_state: Dungeon/Meta, draft_entries: List(Dungeon/DeckEntry), card: Dungeon/CardRef) -> U32:
  pool = pool_quantity(meta_state, card);
  used = deck_quantity(draft_entries, card);
  _saturating_sub(pool, used)

def entry_card_ref(entry: Dungeon/DeckEntry) -> Dungeon/CardRef:
  match entry:
    case monster_entry{ref, count}:
      monster_card{ref}
    case sword_entry{ref, count}:
      sword_card{ref}
    case potion_entry{ref, count}:
      potion_card{ref}
    case hero_entry{count}:
      hero_card{}

def entry_count(entry: Dungeon/DeckEntry) -> U32:
  match entry:
    case monster_entry{ref, count}:
      count
    case sword_entry{ref, count}:
      count
    case potion_entry{ref, count}:
      count
    case hero_entry{count}:
      count

def entry_category(entry: Dungeon/DeckEntry) -> Dungeon/DeckCategory:
  match entry:
    case monster_entry{ref, count}:
      cat_monsters{}
    case sword_entry{ref, count}:
      cat_swords{}
    case potion_entry{ref, count}:
      cat_potions{}
    case hero_entry{count}:
      cat_hero{}

def card_category(card: Dungeon/CardRef) -> Dungeon/DeckCategory:
  match card:
    case monster_card{ref}:
      cat_monsters{}
    case sword_card{ref}:
      cat_swords{}
    case potion_card{ref}:
      cat_potions{}
    case hero_card{}:
      cat_hero{}

def _filter_match(matches: U32, current: Dungeon/DeckEntry, rest_result: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match matches:
    case 0:
      rest_result
    case _:
      current<>rest_result

def _entry_in_category(entry: Dungeon/DeckEntry, cat: Dungeon/DeckCategory) -> U32:
  match entry cat:
    case monster_entry{ref, count} cat_monsters{}:
      1
    case sword_entry{ref, count} cat_swords{}:
      1
    case potion_entry{ref, count} cat_potions{}:
      1
    case hero_entry{count} cat_hero{}:
      1
    case _ _:
      0

def filter_entries_by_category(entries: List(Dungeon/DeckEntry), cat: Dungeon/DeckCategory) -> List(Dungeon/DeckEntry):
  match entries:
    case []:
      []
    case current<>rest:
      _filter_match(_entry_in_category(current, cat), current, filter_entries_by_category(rest, cat))
