def packs() -> Unit:
  unit{}

import Dungeon as Dungeon

def pack_at(packs: List(Dungeon/PackDef), idx: U32) -> Dungeon/PackDef:
  match packs:
    case []:
      pack_def{"", 0, 0, 0, []}
    case pack_def{name, price, reveal_count, allow_duplicates, pool}<>rest:
      match idx:
        case 0:
          pack_def{name, price, reveal_count, allow_duplicates, pool}
        case _:
          pack_at(rest, idx - 1)

def active_pack(config_value: Dungeon/Config) -> Dungeon/PackDef:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      pack_at(booster_packs, 0)
