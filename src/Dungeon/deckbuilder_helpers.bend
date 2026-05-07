import Dungeon/Meta as Meta
import Dungeon/Config as Config
import Dungeon/DeckEntry as DeckEntry
import Dungeon/CardRef as CardRef
import Dungeon/MonsterDef as MonsterDef
import Dungeon/SwordDef as SwordDef
import Dungeon/PotionDef as PotionDef
import Dungeon/DeckbuilderNotice as DeckbuilderNotice
import Dungeon/CardRarity as CardRarity
import Dungeon/config as config
import Dungeon/Deck/counts_pick/add_deck_entry as add_deck_entry
import Dungeon/Deck/counts_pick/card_ref_entry as card_ref_entry
import Dungeon/Deck/counts_pick/deck_count_for_card as deck_count_for_card
import Dungeon/Deck/counts_pick/merge_deck_entries as merge_deck_entries
import Dungeon/Deck/counts_pick/remove_hero_card as remove_hero_card
import Dungeon/Deck/counts_pick/sum_counts as sum_counts
import Dungeon/monster_helpers/monster_class_label as monster_class_label
import Dungeon/monster_helpers/monster_limit as monster_limit
import Dungeon/monster_helpers/monster_tier as monster_tier
import Dungeon/card_rarity_helpers/card_rarity as card_rarity
import Dungeon/card_rarity_helpers/equipment_limit_for_rarity as equipment_limit_for_rarity
import Dungeon/card_rarity_helpers/loot_rarity_label as loot_rarity_label
import Dungeon/profile_helpers/deckbuilder_target_count as deckbuilder_target_count
import Dungeon/profile_helpers/deckbuilder_min_monster_count as deckbuilder_min_monster_count

def card_ref_eq(left: CardRef, right: CardRef) -> U32:
  match left right:
    case monster_card{left_ref} monster_card{right_ref}:
      left_ref === right_ref
    case sword_card{left_ref} sword_card{right_ref}:
      left_ref === right_ref
    case potion_card{left_ref} potion_card{right_ref}:
      left_ref === right_ref
    case hero_card{} hero_card{}:
      1
    case _ _:
      0

def collection_deck(meta_state: Meta) -> List(DeckEntry):
  match config() meta_state:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level} meta{selected_hero_ref, confirmed, gold, bonus_deck, selected_deck, pack_inventory, profiles}:
      merge_deck_entries(remove_hero_card(deck), bonus_deck)

def selected_deck(meta_state: Meta) -> List(DeckEntry):
  match meta_state:
    case meta{selected_hero_ref, confirmed, gold, bonus_deck, selected_deck, pack_inventory, profiles}:
      selected_deck

def deck_total(entries: List(DeckEntry)) -> U32:
  sum_counts(entries)

def deck_monster_total(entries: List(DeckEntry)) -> U32:
  match entries:
    case []:
      0
    case entry<>rest:
      _entry_monster_total(entry) + deck_monster_total(rest)

def _entry_monster_total(entry: DeckEntry) -> U32:
  match entry:
    case monster_entry{ref, count}:
      count
    case _:
      0

def deck_total_ready(entries: List(DeckEntry)) -> U32:
  match deck_total(entries) === deckbuilder_target_count():
    case 1:
      _deck_monster_min_ready(deck_monster_total(entries))
    case _:
      0

def _deck_monster_min_ready(monster_total: U32) -> U32:
  match monster_total < deckbuilder_min_monster_count():
    case 1:
      0
    case _:
      1

def deck_invalid_notice(entries: List(DeckEntry)) -> DeckbuilderNotice:
  total = deck_total(entries);
  monsters = deck_monster_total(entries);
  target = deckbuilder_target_count();
  match total > target:
    case 1:
      deckbuilder_notice{"Acao bloqueada: limite de cartas excedido. Max: " ++ U32/show(target) ++ " no deck."}
    case _:
      match total < target:
        case 1:
          deckbuilder_notice{"Acao bloqueada: deck incompleto. Faltam " ++ U32/show(target - total) ++ " cartas."}
        case _:
          min_monsters = deckbuilder_min_monster_count();
          match monsters < min_monsters:
            case 1:
              deckbuilder_notice{"Acao bloqueada: minimo de " ++ U32/show(min_monsters) ++ " monsters no deck."}
            case _:
              no_deckbuilder_notice{}

def deck_star_total(entries: List(DeckEntry)) -> U32:
  match entries:
    case []:
      0
    case entry<>rest:
      _entry_star_total(entry) + deck_star_total(rest)

def _entry_star_total(entry: DeckEntry) -> U32:
  match entry:
    case monster_entry{ref, count}:
      monster_tier_value(ref) * count
    case _:
      0

def deck_mode_label(entries: List(DeckEntry)) -> String:
  _deck_mode_for_stars(deck_star_total(entries))

def _deck_mode_for_stars(stars: U32) -> String:
  match stars <= 45:
    case 1:
      "Casual"
    case _:
      match stars <= 70:
        case 1:
          "Veterano"
        case _:
          "Insalubre"

def selectable_cards() -> List(CardRef):
  _selectable_cards_from_config(config())

def _selectable_cards_from_config(config_value: Config) -> List(CardRef):
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _append_cards(_monster_cards(monsters, 0), _append_cards(_sword_cards(swords, 0), _potion_cards(potions, 0)))

def _append_cards(left: List(CardRef), right: List(CardRef)) -> List(CardRef):
  match left:
    case []:
      right
    case card<>rest:
      card<>_append_cards(rest, right)

def _monster_cards(monsters: List(MonsterDef), ref: U32) -> List(CardRef):
  match monsters:
    case []:
      []
    case monster_def{name, sprite, class_kind, tier, rarity, gold_levels, hp_levels}<>rest:
      monster_card{ref}<>_monster_cards(rest, ref + 1)

def _sword_cards(swords: List(SwordDef), ref: U32) -> List(CardRef):
  match swords:
    case []:
      []
    case sword_def{name, sprite, rarity, class_kind, dmg}<>rest:
      sword_card{ref}<>_sword_cards(rest, ref + 1)

def _potion_cards(potions: List(PotionDef), ref: U32) -> List(CardRef):
  match potions:
    case []:
      []
    case potion_def{name, sprite, rarity, heal}<>rest:
      potion_card{ref}<>_potion_cards(rest, ref + 1)

def deck_list_count(entries: List(DeckEntry)) -> U32:
  _visible_card_count(selectable_cards(), entries, entries, deck_list_kind{})

def stash_list_count(meta_state: Meta, draft_deck: List(DeckEntry)) -> U32:
  _visible_card_count(selectable_cards(), collection_deck(meta_state), draft_deck, stash_list_kind{})

type DeckbuilderListKind {
  deck_list_kind{}
  stash_list_kind{}
}

def _visible_card_count(cards: List(CardRef), collection: List(DeckEntry), draft_deck: List(DeckEntry), kind: DeckbuilderListKind) -> U32:
  match cards:
    case []:
      0
    case card<>rest:
      _visible_card_count_match(_card_list_count(collection, draft_deck, card, kind), rest, collection, draft_deck, kind)

def _visible_card_count_match(count: U32, rest: List(CardRef), collection: List(DeckEntry), draft_deck: List(DeckEntry), kind: DeckbuilderListKind) -> U32:
  match count:
    case 0:
      _visible_card_count(rest, collection, draft_deck, kind)
    case _:
      1 + _visible_card_count(rest, collection, draft_deck, kind)

def _card_list_count(collection: List(DeckEntry), draft_deck: List(DeckEntry), card: CardRef, kind: DeckbuilderListKind) -> U32:
  match kind:
    case deck_list_kind{}:
      deck_count_for_card(draft_deck, card)
    case stash_list_kind{}:
      stash_count_from_entries(collection, draft_deck, card)

def stash_count(meta_state: Meta, draft_deck: List(DeckEntry), card: CardRef) -> U32:
  stash_count_from_entries(collection_deck(meta_state), draft_deck, card)

def stash_count_from_entries(collection: List(DeckEntry), draft_deck: List(DeckEntry), card: CardRef) -> U32:
  total = deck_count_for_card(collection, card);
  used = deck_count_for_card(draft_deck, card);
  match used < total:
    case 1:
      total - used
    case _:
      0

def add_one_to_draft(meta_state: Meta, draft_deck: List(DeckEntry), card: CardRef) -> List(DeckEntry):
  _add_count_to_draft(meta_state, draft_deck, card, _min_u32(1, _allowed_additions(meta_state, draft_deck, card)))

def add_all_to_draft(meta_state: Meta, draft_deck: List(DeckEntry), card: CardRef) -> List(DeckEntry):
  _add_count_to_draft(meta_state, draft_deck, card, _allowed_additions(meta_state, draft_deck, card))

def _add_count_to_draft(meta_state: Meta, draft_deck: List(DeckEntry), card: CardRef, amount: U32) -> List(DeckEntry):
  match amount:
    case 0:
      draft_deck
    case _:
      add_deck_entry(draft_deck, card_ref_entry(card, amount))

def _allowed_additions(meta_state: Meta, draft_deck: List(DeckEntry), card: CardRef) -> U32:
  available = stash_count(meta_state, draft_deck, card);
  current = deck_count_for_card(draft_deck, card);
  limit = card_limit(card);
  match limit:
    case 0:
      available
    case _:
      _allowed_with_limit(available, current, limit)

def _allowed_with_limit(available: U32, current: U32, limit: U32) -> U32:
  match current < limit:
    case 0:
      0
    case _:
      _min_u32(available, limit - current)

def remove_one_from_draft(draft_deck: List(DeckEntry), card: CardRef) -> List(DeckEntry):
  current = deck_count_for_card(draft_deck, card);
  match current:
    case 0:
      draft_deck
    case _:
      set_card_count(draft_deck, card, current - 1)

def remove_all_from_draft(draft_deck: List(DeckEntry), card: CardRef) -> List(DeckEntry):
  set_card_count(draft_deck, card, 0)

def set_card_count(entries: List(DeckEntry), card: CardRef, next_count: U32) -> List(DeckEntry):
  _set_card_count_clean(_remove_card(entries, card), card, next_count)

def _set_card_count_clean(entries: List(DeckEntry), card: CardRef, next_count: U32) -> List(DeckEntry):
  match next_count:
    case 0:
      entries
    case _:
      add_deck_entry(entries, card_ref_entry(card, next_count))

def _remove_card(entries: List(DeckEntry), card: CardRef) -> List(DeckEntry):
  match entries:
    case []:
      []
    case entry<>rest:
      _remove_card_match(_entry_matches_card(entry, card), entry, rest, card)

def _remove_card_match(matched: U32, entry: DeckEntry, rest: List(DeckEntry), card: CardRef) -> List(DeckEntry):
  match matched:
    case 0:
      entry<>_remove_card(rest, card)
    case _:
      _remove_card(rest, card)

def _entry_matches_card(entry: DeckEntry, card: CardRef) -> U32:
  match entry card:
    case monster_entry{entry_ref, count} monster_card{card_ref}:
      entry_ref === card_ref
    case sword_entry{entry_ref, count} sword_card{card_ref}:
      entry_ref === card_ref
    case potion_entry{entry_ref, count} potion_card{card_ref}:
      entry_ref === card_ref
    case hero_entry{count} hero_card{}:
      1
    case _ _:
      0

def card_limit(card: CardRef) -> U32:
  match card:
    case monster_card{ref}:
      monster_limit(ref)
    case sword_card{ref}:
      sword_limit(ref)
    case potion_card{ref}:
      0
    case hero_card{}:
      0

def sword_limit(ref: U32) -> U32:
  _equipment_limit_from_card_rarity(card_rarity(sword_card{ref}))

def _equipment_limit_from_card_rarity(rarity: CardRarity) -> U32:
  match rarity:
    case card_rarity_equipment{loot_rarity}:
      equipment_limit_for_rarity(loot_rarity)
    case _:
      1

def card_id(card: CardRef) -> String:
  match card:
    case monster_card{ref}:
      monster_id(ref)
    case sword_card{ref}:
      sword_id(ref)
    case potion_card{ref}:
      potion_id(ref)
    case hero_card{}:
      "hero"

def monster_id(ref: U32) -> String:
  match ref:
    case 0:
      "rat"
    case 1:
      "spider"
    case 2:
      "venom_spider"
    case _:
      "orc"

def sword_id(ref: U32) -> String:
  match ref:
    case 0:
      "sword_1"
    case 1:
      "sword_2"
    case _:
      "sword_3"

def potion_id(ref: U32) -> String:
  match ref:
    case 0:
      "potion_1"
    case 1:
      "potion_2"
    case _:
      "potion_3"

def card_rule_label(card: CardRef) -> String:
  match card:
    case monster_card{ref}:
      monster_rule_label(ref)
    case sword_card{ref}:
      sword_rule_label(ref)
    case potion_card{ref}:
      "Consumivel"
    case hero_card{}:
      ""

def monster_rule_label(ref: U32) -> String:
  monster_class_label(ref)

def sword_rule_label(ref: U32) -> String:
  _sword_rule_label_from_card_rarity(card_rarity(sword_card{ref}))

def _sword_rule_label_from_card_rarity(rarity: CardRarity) -> String:
  match rarity:
    case card_rarity_equipment{loot_rarity}:
      loot_rarity_label(loot_rarity)
    case _:
      ""

def card_limit_notice(card: CardRef) -> DeckbuilderNotice:
  match card:
    case sword_card{ref}:
      sword_limit_notice(ref)
    case _:
      no_deckbuilder_notice{}

def sword_limit_notice(ref: U32) -> DeckbuilderNotice:
  match card_rarity(sword_card{ref}):
    case card_rarity_equipment{loot_rare{}}:
      deckbuilder_notice{"Acao bloqueada: equipamentos raros e epicos aceitam apenas 1 copia por ID."}
    case card_rarity_equipment{loot_epic{}}:
      deckbuilder_notice{"Acao bloqueada: equipamentos raros e epicos aceitam apenas 1 copia por ID."}
    case _:
      no_deckbuilder_notice{}

def card_tier_count(card: CardRef) -> U32:
  match card:
    case monster_card{ref}:
      monster_tier_value(ref)
    case _:
      0

def monster_tier_value(ref: U32) -> U32:
  monster_tier(ref)

def _min_u32(left: U32, right: U32) -> U32:
  match left < right:
    case 1:
      left
    case _:
      right
