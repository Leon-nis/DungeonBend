def inventory() -> Unit:
  unit{}

import Dungeon as Dungeon

def _pack_entry_count(entry: Dungeon/PackInventoryEntry) -> U32:
  match entry:
    case pack_inventory_entry{ref, count}:
      count

def _pack_entry_match(entry: Dungeon/PackInventoryEntry, ref: U32) -> U32:
  match entry:
    case pack_inventory_entry{entry_ref, count}:
      entry_ref === ref

def _pack_inventory_count_match(matched: U32, entry: Dungeon/PackInventoryEntry, rest_count: U32) -> U32:
  match matched:
    case 0:
      rest_count
    case _:
      _pack_entry_count(entry)

def pack_inventory_count(entries: List(Dungeon/PackInventoryEntry), ref: U32) -> U32:
  match entries:
    case []:
      0
    case entry<>rest:
      _pack_inventory_count_match(_pack_entry_match(entry, ref), entry, pack_inventory_count(rest, ref))

def pack_inventory_total(entries: List(Dungeon/PackInventoryEntry)) -> U32:
  match entries:
    case []:
      0
    case entry<>rest:
      _pack_entry_count(entry) + pack_inventory_total(rest)

def _increment_pack(entry: Dungeon/PackInventoryEntry) -> Dungeon/PackInventoryEntry:
  match entry:
    case pack_inventory_entry{ref, count}:
      pack_inventory_entry{ref, count + 1}

def _add_pack_match(matched: U32, entry: Dungeon/PackInventoryEntry, rest: List(Dungeon/PackInventoryEntry), rest_entries: List(Dungeon/PackInventoryEntry)) -> List(Dungeon/PackInventoryEntry):
  match matched:
    case 0:
      entry<>rest_entries
    case _:
      _increment_pack(entry)<>rest

def add_pack(entries: List(Dungeon/PackInventoryEntry), ref: U32) -> List(Dungeon/PackInventoryEntry):
  match entries:
    case []:
      [pack_inventory_entry{ref, 1}]
    case entry<>rest:
      _add_pack_match(_pack_entry_match(entry, ref), entry, rest, add_pack(rest, ref))

def _consume_pack_entry(entry: Dungeon/PackInventoryEntry, rest: List(Dungeon/PackInventoryEntry)) -> List(Dungeon/PackInventoryEntry):
  match entry:
    case pack_inventory_entry{ref, count}:
      match count:
        case 1:
          rest
        case _:
          pack_inventory_entry{ref, count - 1}<>rest

def _consume_pack_match(matched: U32, entry: Dungeon/PackInventoryEntry, rest: List(Dungeon/PackInventoryEntry), rest_entries: List(Dungeon/PackInventoryEntry)) -> List(Dungeon/PackInventoryEntry):
  match matched:
    case 0:
      entry<>rest_entries
    case _:
      _consume_pack_entry(entry, rest)

def consume_pack(entries: List(Dungeon/PackInventoryEntry), ref: U32) -> List(Dungeon/PackInventoryEntry):
  match entries:
    case []:
      []
    case entry<>rest:
      _consume_pack_match(_pack_entry_match(entry, ref), entry, rest, consume_pack(rest, ref))
