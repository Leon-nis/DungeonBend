def deck_records() -> Unit:
  unit{}

import Dungeon as Dungeon

def initial_deck_id() -> U32:
  0

def initial_deck_name() -> String:
  "Initial Deck"

def is_initial_deck(deck_id: U32) -> U32:
  deck_id === initial_deck_id()

def deck_record_id(record: Dungeon/DeckRecord) -> U32:
  match record:
    case deck_record{id, name, sleeve, entries}:
      id

def deck_record_name(record: Dungeon/DeckRecord) -> String:
  match record:
    case deck_record{id, name, sleeve, entries}:
      name

def deck_record_sleeve(record: Dungeon/DeckRecord) -> Dungeon/DeckSleeve:
  match record:
    case deck_record{id, name, sleeve, entries}:
      sleeve

def deck_record_entries(record: Dungeon/DeckRecord) -> List(Dungeon/DeckEntry):
  match record:
    case deck_record{id, name, sleeve, entries}:
      entries

def deck_record_with_name(record: Dungeon/DeckRecord, next_name: String) -> Dungeon/DeckRecord:
  match record:
    case deck_record{id, name, sleeve, entries}:
      deck_record{id, next_name, sleeve, entries}

def deck_record_with_sleeve(record: Dungeon/DeckRecord, next_sleeve: Dungeon/DeckSleeve) -> Dungeon/DeckRecord:
  match record:
    case deck_record{id, name, sleeve, entries}:
      deck_record{id, name, next_sleeve, entries}

def deck_record_with_entries(record: Dungeon/DeckRecord, next_entries: List(Dungeon/DeckEntry)) -> Dungeon/DeckRecord:
  match record:
    case deck_record{id, name, sleeve, entries}:
      deck_record{id, name, sleeve, next_entries}

def _find_deck_match(matched: U32, current: Dungeon/DeckRecord, rest_result: Maybe(Dungeon/DeckRecord)) -> Maybe(Dungeon/DeckRecord):
  match matched:
    case 0:
      rest_result
    case _:
      some{current}

def find_deck(records: List(Dungeon/DeckRecord), deck_id: U32) -> Maybe(Dungeon/DeckRecord):
  match records:
    case []:
      none{}
    case current<>rest:
      _find_deck_match(deck_record_id(current) === deck_id, current, find_deck(rest, deck_id))

def find_deck_or(records: List(Dungeon/DeckRecord), deck_id: U32, fallback: Dungeon/DeckRecord) -> Dungeon/DeckRecord:
  match find_deck(records, deck_id):
    case some{record}:
      record
    case none{}:
      fallback

def deck_count(records: List(Dungeon/DeckRecord)) -> U32:
  match records:
    case []:
      0
    case current<>rest:
      1 + deck_count(rest)

def _replace_deck_match(matched: U32, current: Dungeon/DeckRecord, rest_result: List(Dungeon/DeckRecord), rest: List(Dungeon/DeckRecord), next_record: Dungeon/DeckRecord) -> List(Dungeon/DeckRecord):
  match matched:
    case 0:
      current<>rest_result
    case _:
      next_record<>rest

def replace_deck(records: List(Dungeon/DeckRecord), next_record: Dungeon/DeckRecord) -> List(Dungeon/DeckRecord):
  match records:
    case []:
      [next_record]
    case current<>rest:
      _replace_deck_match(deck_record_id(current) === deck_record_id(next_record), current, replace_deck(rest, next_record), rest, next_record)

def append_deck(records: List(Dungeon/DeckRecord), next_record: Dungeon/DeckRecord) -> List(Dungeon/DeckRecord):
  match records:
    case []:
      [next_record]
    case current<>rest:
      current<>append_deck(rest, next_record)

def _remove_deck_match(matched: U32, current: Dungeon/DeckRecord, rest_result: List(Dungeon/DeckRecord)) -> List(Dungeon/DeckRecord):
  match matched:
    case 0:
      current<>rest_result
    case _:
      rest_result

def remove_deck_by_id(records: List(Dungeon/DeckRecord), deck_id: U32) -> List(Dungeon/DeckRecord):
  match records:
    case []:
      []
    case current<>rest:
      _remove_deck_match(deck_record_id(current) === deck_id, current, remove_deck_by_id(rest, deck_id))

def _remove_decks_filter_initial(records: List(Dungeon/DeckRecord), head: U32, rest_result: List(Dungeon/DeckRecord)) -> List(Dungeon/DeckRecord):
  match head === initial_deck_id():
    case 1:
      rest_result
    case _:
      remove_deck_by_id(rest_result, head)

def remove_decks_by_ids(records: List(Dungeon/DeckRecord), ids: List(U32)) -> List(Dungeon/DeckRecord):
  match ids:
    case []:
      records
    case head<>rest:
      _remove_decks_filter_initial(records, head, remove_decks_by_ids(records, rest))

def _contains_id_match(matched: U32, rest_result: U32) -> U32:
  match matched:
    case 0:
      rest_result
    case _:
      1

def list_contains_id(ids: List(U32), value: U32) -> U32:
  match ids:
    case []:
      0
    case head<>rest:
      _contains_id_match(head === value, list_contains_id(rest, value))

def _remove_id_match(matched: U32, head: U32, rest: List(U32), rest_result: List(U32)) -> List(U32):
  match matched:
    case 0:
      head<>rest_result
    case _:
      rest

def _remove_id(ids: List(U32), value: U32) -> List(U32):
  match ids:
    case []:
      []
    case head<>rest:
      _remove_id_match(head === value, head, rest, _remove_id(rest, value))

def toggle_id_in_list(ids: List(U32), value: U32) -> List(U32):
  match list_contains_id(ids, value):
    case 1:
      _remove_id(ids, value)
    case _:
      value<>ids

def list_size(ids: List(U32)) -> U32:
  match ids:
    case []:
      0
    case head<>rest:
      1 + list_size(rest)
