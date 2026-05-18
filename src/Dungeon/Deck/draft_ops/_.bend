def draft_ops() -> Unit:
  unit{}

import Dungeon as Dungeon
import Dungeon/Deck/sleeves as M__Dungeon_Deck_sleeves
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick
import Dungeon/Deck/quotas as M__Dungeon_Deck_quotas
import Dungeon/Deck/card_collection as M__Dungeon_Deck_card_collection

def draft_from_record(record: Dungeon/DeckRecord) -> Dungeon/DeckDraft:
  match record:
    case deck_record{id, name, sleeve, entries}:
      deck_draft{id, name, sleeve, entries, 0}

def empty_draft(deck_id: U32, name: String) -> Dungeon/DeckDraft:
  deck_draft{deck_id, name, Dungeon/Deck/sleeves/default_sleeve(), [], 0}

def draft_id(draft: Dungeon/DeckDraft) -> U32:
  match draft:
    case deck_draft{deck_id, name, sleeve, entries, dirty}:
      deck_id

def draft_name(draft: Dungeon/DeckDraft) -> String:
  match draft:
    case deck_draft{deck_id, name, sleeve, entries, dirty}:
      name

def draft_sleeve(draft: Dungeon/DeckDraft) -> Dungeon/DeckSleeve:
  match draft:
    case deck_draft{deck_id, name, sleeve, entries, dirty}:
      sleeve

def draft_entries(draft: Dungeon/DeckDraft) -> List(Dungeon/DeckEntry):
  match draft:
    case deck_draft{deck_id, name, sleeve, entries, dirty}:
      entries

def draft_dirty(draft: Dungeon/DeckDraft) -> U32:
  match draft:
    case deck_draft{deck_id, name, sleeve, entries, dirty}:
      dirty

def draft_with_entries(draft: Dungeon/DeckDraft, next_entries: List(Dungeon/DeckEntry)) -> Dungeon/DeckDraft:
  match draft:
    case deck_draft{deck_id, name, sleeve, entries, dirty}:
      deck_draft{deck_id, name, sleeve, next_entries, 1}

def draft_with_name(draft: Dungeon/DeckDraft, next_name: String) -> Dungeon/DeckDraft:
  match draft:
    case deck_draft{deck_id, name, sleeve, entries, dirty}:
      deck_draft{deck_id, next_name, sleeve, entries, 1}

def draft_with_sleeve(draft: Dungeon/DeckDraft, next_sleeve: Dungeon/DeckSleeve) -> Dungeon/DeckDraft:
  match draft:
    case deck_draft{deck_id, name, sleeve, entries, dirty}:
      deck_draft{deck_id, name, next_sleeve, entries, dirty}

def draft_to_record(draft: Dungeon/DeckDraft) -> Dungeon/DeckRecord:
  match draft:
    case deck_draft{deck_id, name, sleeve, entries, dirty}:
      deck_record{deck_id, name, sleeve, entries}

def _pool_match(pool_left: U32) -> U32:
  match pool_left:
    case 0:
      0
    case _:
      1

def _can_add_match(cat_has_room: U32, pool_left: U32) -> U32:
  match cat_has_room:
    case 0:
      0
    case _:
      _pool_match(pool_left)

def can_add_card(cfg: Dungeon/Config, meta_state: Dungeon/Meta, draft: Dungeon/DeckDraft, card: Dungeon/CardRef) -> U32:
  q = Dungeon/Deck/quotas/quotas_from_config(cfg);
  cat = Dungeon/Deck/card_collection/card_category(card);
  cat_now = Dungeon/Deck/quotas/category_count(draft_entries(draft), cat);
  cat_max = Dungeon/Deck/quotas/quota_for_category(q, cat);
  pool_left = Dungeon/Deck/card_collection/available_for_add(meta_state, draft_entries(draft), card);
  _can_add_match(cat_now < cat_max, pool_left)

def add_card(draft: Dungeon/DeckDraft, card: Dungeon/CardRef) -> Dungeon/DeckDraft:
  next_entries = Dungeon/Deck/counts_pick/add_deck_entry(draft_entries(draft), Dungeon/Deck/counts_pick/card_ref_entry(card, 1));
  draft_with_entries(draft, next_entries)

def _drop_or_keep_monster(ref: U32, count: U32, rest: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match count:
    case 0:
      rest
    case 1:
      rest
    case _:
      monster_entry{ref, count - 1}<>rest

def _drop_or_keep_sword(ref: U32, count: U32, rest: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match count:
    case 0:
      rest
    case 1:
      rest
    case _:
      sword_entry{ref, count - 1}<>rest

def _drop_or_keep_potion(ref: U32, count: U32, rest: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match count:
    case 0:
      rest
    case 1:
      rest
    case _:
      potion_entry{ref, count - 1}<>rest

def _drop_or_keep_hero(count: U32, rest: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match count:
    case 0:
      rest
    case 1:
      rest
    case _:
      hero_entry{count - 1}<>rest

def _decrement_or_drop(entry: Dungeon/DeckEntry, rest: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match entry:
    case monster_entry{ref, count}:
      _drop_or_keep_monster(ref, count, rest)
    case sword_entry{ref, count}:
      _drop_or_keep_sword(ref, count, rest)
    case potion_entry{ref, count}:
      _drop_or_keep_potion(ref, count, rest)
    case hero_entry{count}:
      _drop_or_keep_hero(count, rest)

def _remove_match(matched: U32, current: Dungeon/DeckEntry, rest: List(Dungeon/DeckEntry), rest_entries: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match matched:
    case 0:
      current<>rest_entries
    case _:
      _decrement_or_drop(current, rest)

def _entry_matches(entry: Dungeon/DeckEntry, card: Dungeon/CardRef) -> U32:
  match entry card:
    case monster_entry{eref, count} monster_card{cref}:
      eref === cref
    case sword_entry{eref, count} sword_card{cref}:
      eref === cref
    case potion_entry{eref, count} potion_card{cref}:
      eref === cref
    case hero_entry{count} hero_card{}:
      1
    case _ _:
      0

def _remove_card_from(entries: List(Dungeon/DeckEntry), card: Dungeon/CardRef) -> List(Dungeon/DeckEntry):
  match entries:
    case []:
      []
    case current<>rest:
      _remove_match(_entry_matches(current, card), current, rest, _remove_card_from(rest, card))

def remove_card(draft: Dungeon/DeckDraft, card: Dungeon/CardRef) -> Dungeon/DeckDraft:
  next_entries = _remove_card_from(draft_entries(draft), card);
  draft_with_entries(draft, next_entries)
