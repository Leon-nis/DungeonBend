def collection() -> Unit:
  unit{}

import Dungeon as Dungeon
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick

def _bonus_deck_from_cards(bonus_deck: List(Dungeon/DeckEntry), cards: List(Dungeon/CardRef)) -> List(Dungeon/DeckEntry):
  match cards:
    case []:
      bonus_deck
    case card<>rest:
      _bonus_deck_from_cards(Dungeon/Deck/counts_pick/add_deck_entry(bonus_deck, Dungeon/Deck/counts_pick/card_ref_entry(card, 1)), rest)

def bonus_deck_after_reward(bonus_deck: List(Dungeon/DeckEntry), reward: Dungeon/PackReward) -> List(Dungeon/DeckEntry):
  match reward:
    case no_pack_reward{}:
      bonus_deck
    case pack_reward{cards}:
      _bonus_deck_from_cards(bonus_deck, cards)
