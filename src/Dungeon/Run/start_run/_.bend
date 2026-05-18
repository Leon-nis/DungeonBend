import Dungeon as Dungeon
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick
import Dungeon/Deck/deck_records as M__Dungeon_Deck_deck_records
import Dungeon/Deck/deck_validation as M__Dungeon_Deck_deck_validation
import Dungeon/Board/indexing as M__Dungeon_Board_indexing
import Dungeon/Run/refill as M__Dungeon_Run_refill
import Dungeon/hero_helpers as M__Dungeon_hero_helpers
import Dungeon/profile_helpers as M__Dungeon_profile_helpers

def _start_from_board(hero_max: U32, blueprint: List(Dungeon/DeckEntry), capacity: U32, hero_ref: U32, stage: Dungeon/BoardDraw) -> Dungeon/Run:
  match stage:
    case board_draw{board_value, next_counts, next_remaining, next_seed_value, next_level}:
      run{next_level, hero_max, hero_max, 4, no_weapon{}, board_value, blueprint, next_counts, next_remaining, capacity, next_seed_value, 0, hero_ref}

def _config_deck(config_value: Dungeon/Config) -> List(Dungeon/DeckEntry):
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      deck

def _entries_or_fallback(config_value: Dungeon/Config, entries: List(Dungeon/DeckEntry), meta_state: Dungeon/Meta) -> List(Dungeon/DeckEntry):
  match Dungeon/Deck/deck_validation/is_deck_valid(config_value, meta_state, entries):
    case 1:
      entries
    case _:
      _config_deck(config_value)

def active_deck_entries(config_value: Dungeon/Config, meta_state: Dungeon/Meta) -> List(Dungeon/DeckEntry):
  match Dungeon/Deck/deck_records/find_deck(Dungeon/profile_helpers/meta_decks(meta_state), Dungeon/profile_helpers/meta_active_deck_id(meta_state)):
    case some{record}:
      _entries_or_fallback(config_value, Dungeon/Deck/deck_records/deck_record_entries(record), meta_state)
    case none{}:
      _config_deck(config_value)

def start_run(config_value: Dungeon/Config, meta_state: Dungeon/Meta, seed: U32) -> Dungeon/Run:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      hero_ref = Dungeon/profile_helpers/selected_hero(meta_state);
      hero_value = Dungeon/hero_helpers/hero_at(config_value, hero_ref);
      profile = Dungeon/profile_helpers/active_profile(meta_state);
      full_deck = active_deck_entries(config_value, meta_state);
      hero_max = Dungeon/Deck/counts_pick/hero_max_hp(Dungeon/hero_helpers/hero_base_max_hp(hero_value), Dungeon/hero_helpers/hero_upgrades(hero_value), Dungeon/profile_helpers/profile_hero_level(profile));
      blueprint = Dungeon/Deck/counts_pick/remove_hero_card(full_deck);
      remaining = Dungeon/Deck/counts_pick/sum_counts(blueprint);
      _start_from_board(hero_max, blueprint, Dungeon/Deck/counts_pick/sum_counts(full_deck), hero_ref, Dungeon/Run/refill/_refill_non_hero_slots(config_value, Dungeon/Board/indexing/empty_board(), 4, blueprint, blueprint, remaining, seed, starting_dungeon_level))
