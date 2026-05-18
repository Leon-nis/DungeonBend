def reveal() -> Unit:
  unit{}

import Dungeon as Dungeon
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick

def _pool_weight(entry: Dungeon/PackPoolEntry) -> U32:
  match entry:
    case pack_pool_entry{card, weight}:
      weight

def _pool_card(entry: Dungeon/PackPoolEntry) -> Dungeon/CardRef:
  match entry:
    case pack_pool_entry{card, weight}:
      card

def sum_pool_weights(pool: List(Dungeon/PackPoolEntry)) -> U32:
  match pool:
    case []:
      0
    case entry<>rest:
      _pool_weight(entry) + sum_pool_weights(rest)

def _prepend_pool_entry(entry: Dungeon/PackPoolEntry, result: Dungeon/_PackPickResult) -> Dungeon/_PackPickResult:
  match result:
    case no_pack_pick{pool}:
      no_pack_pick{entry<>pool}
    case picked_pack_entry{card, pool}:
      picked_pack_entry{card, entry<>pool}

def _pick_pool_hit_keep(entry: Dungeon/PackPoolEntry, rest: List(Dungeon/PackPoolEntry)) -> Dungeon/_PackPickResult:
  picked_pack_entry{_pool_card(entry), entry<>rest}

def _pick_pool_hit_remove(entry: Dungeon/PackPoolEntry, rest: List(Dungeon/PackPoolEntry)) -> Dungeon/_PackPickResult:
  picked_pack_entry{_pool_card(entry), rest}

def _pick_pool_hit(entry: Dungeon/PackPoolEntry, rest: List(Dungeon/PackPoolEntry), allow_duplicates: U32) -> Dungeon/_PackPickResult:
  match allow_duplicates:
    case 0:
      _pick_pool_hit_remove(entry, rest)
    case _:
      _pick_pool_hit_keep(entry, rest)

def _pick_pool_entry(pool: List(Dungeon/PackPoolEntry), idx: U32, allow_duplicates: U32) -> Dungeon/_PackPickResult:
  match pool:
    case []:
      no_pack_pick{[]}
    case entry<>rest:
      weight = _pool_weight(entry);
      match idx < weight:
        case 0:
          _prepend_pool_entry(entry, _pick_pool_entry(rest, idx - weight, allow_duplicates))
        case _:
          _pick_pool_hit(entry, rest, allow_duplicates)

def _reverse_cards(cards: List(Dungeon/CardRef), acc: List(Dungeon/CardRef)) -> List(Dungeon/CardRef):
  match cards:
    case []:
      acc
    case card<>rest:
      _reverse_cards(rest, card<>acc)

def _reward_from_cards(cards: List(Dungeon/CardRef)) -> Dungeon/PackReward:
  match cards:
    case []:
      no_pack_reward{}
    case _:
      pack_reward{_reverse_cards(cards, [])}

def _draw_pack_cards(remaining: U32, allow_duplicates: U32, pool: List(Dungeon/PackPoolEntry), seed: U32, cards: List(Dungeon/CardRef)) -> Dungeon/PackOpenResult:
  match remaining:
    case 0:
      pack_open_result{_reward_from_cards(cards), seed}
    case _:
      total_weight = sum_pool_weights(pool);
      match total_weight:
        case 0:
          pack_open_result{_reward_from_cards(cards), seed}
        case _:
          idx = seed % total_weight;
          next = Dungeon/Deck/counts_pick/next_seed(seed);
          match _pick_pool_entry(pool, idx, allow_duplicates):
            case no_pack_pick{next_pool}:
              pack_open_result{_reward_from_cards(cards), next}
            case picked_pack_entry{card, next_pool}:
              _draw_pack_cards(remaining - 1, allow_duplicates, next_pool, next, card<>cards)

def open_pack(pack: Dungeon/PackDef, seed: U32) -> Dungeon/PackOpenResult:
  match pack:
    case pack_def{name, price, reveal_count, allow_duplicates, pool}:
      _draw_pack_cards(reveal_count, allow_duplicates, pool, seed, [])
