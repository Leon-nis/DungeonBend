def deck_validation() -> Unit:
  unit{}

import Dungeon as Dungeon
import Dungeon/Deck/quotas as M__Dungeon_Deck_quotas
import Dungeon/Deck/card_collection as M__Dungeon_Deck_card_collection

def category_match(entries: List(Dungeon/DeckEntry), q: Dungeon/DeckQuotas, cat: Dungeon/DeckCategory) -> U32:
  Dungeon/Deck/quotas/category_count(entries, cat) === Dungeon/Deck/quotas/quota_for_category(q, cat)

def _and(a: U32, b: U32) -> U32:
  match a:
    case 0:
      0
    case _:
      b

def all_quotas_match(entries: List(Dungeon/DeckEntry), q: Dungeon/DeckQuotas) -> U32:
  m = category_match(entries, q, cat_monsters{});
  s = category_match(entries, q, cat_swords{});
  p = category_match(entries, q, cat_potions{});
  h = category_match(entries, q, cat_hero{});
  _and(_and(m, s), _and(p, h))

def _entry_within_match(within: U32, rest_result: U32) -> U32:
  match within:
    case 0:
      0
    case _:
      rest_result

def _entry_within_pool(current: Dungeon/DeckEntry, meta_state: Dungeon/Meta, rest_result: U32) -> U32:
  card = Dungeon/Deck/card_collection/entry_card_ref(current);
  used = Dungeon/Deck/card_collection/entry_count(current);
  pool = Dungeon/Deck/card_collection/pool_quantity(meta_state, card);
  _entry_within_match(used <= pool, rest_result)

def entries_within_pool(entries: List(Dungeon/DeckEntry), meta_state: Dungeon/Meta) -> U32:
  match entries:
    case []:
      1
    case current<>rest:
      _entry_within_pool(current, meta_state, entries_within_pool(rest, meta_state))

def is_deck_valid(cfg: Dungeon/Config, meta_state: Dungeon/Meta, entries: List(Dungeon/DeckEntry)) -> U32:
  q = Dungeon/Deck/quotas/quotas_from_config(cfg);
  _and(all_quotas_match(entries, q), entries_within_pool(entries, meta_state))

def deck_total_count(entries: List(Dungeon/DeckEntry)) -> U32:
  match entries:
    case []:
      0
    case current<>rest:
      Dungeon/Deck/card_collection/entry_count(current) + deck_total_count(rest)
