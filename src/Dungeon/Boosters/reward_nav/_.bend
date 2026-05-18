def reward_nav() -> Unit:
  unit{}

import Dungeon as Dungeon

def _card_count(cards: List(Dungeon/CardRef)) -> U32:
  match cards:
    case []:
      0
    case card<>rest:
      1 + _card_count(rest)

def reward_count(reward: Dungeon/PackReward) -> U32:
  match reward:
    case no_pack_reward{}:
      0
    case pack_reward{cards}:
      _card_count(cards)

def _card_at(cards: List(Dungeon/CardRef), idx: U32) -> Dungeon/CardRef:
  match cards:
    case []:
      hero_card{}
    case card<>rest:
      match idx:
        case 0:
          card
        case _:
          _card_at(rest, idx - 1)

def reward_card_at(reward: Dungeon/PackReward, idx: U32) -> Dungeon/CardRef:
  match reward:
    case no_pack_reward{}:
      hero_card{}
    case pack_reward{cards}:
      _card_at(cards, idx)

def _next_reward_index_match(can_advance: U32, idx: U32) -> U32:
  match can_advance:
    case 0:
      idx
    case _:
      idx + 1

def _next_reward_index(count: U32, idx: U32) -> U32:
  match count:
    case 0:
      0
    case _:
      _next_reward_index_match(idx + 1 < count, idx)

def next_reward_index(reward: Dungeon/PackReward, idx: U32) -> U32:
  _next_reward_index(reward_count(reward), idx)

def prev_reward_index(idx: U32) -> U32:
  match idx:
    case 0:
      0
    case _:
      idx - 1
