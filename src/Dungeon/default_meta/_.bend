import Dungeon/game_config as config
import Dungeon as Dungeon
import Dungeon/profile_helpers as M__Dungeon_profile_helpers
import Dungeon/rules as M__Dungeon_rules
import Dungeon/Deck/deck_records as M__Dungeon_Deck_deck_records
import Dungeon/Deck/sleeves as M__Dungeon_Deck_sleeves

def _initial_deck_record(cfg: Dungeon/Config) -> Dungeon/DeckRecord:
  match cfg:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      deck_record{Dungeon/Deck/deck_records/initial_deck_id(), Dungeon/Deck/deck_records/initial_deck_name(), Dungeon/Deck/sleeves/default_sleeve(), deck}

def default_meta() -> Dungeon/Meta:
  cfg = config();
  initial = _initial_deck_record(cfg);
  meta{
    Dungeon/rules/starting_selected_hero(),
    Dungeon/rules/starting_selection_confirmed(),
    Dungeon/rules/starting_gold(),
    [],
    [],
    Dungeon/profile_helpers/default_hero_profiles(cfg),
    [initial],
    Dungeon/Deck/deck_records/initial_deck_id(),
    Dungeon/Deck/deck_records/initial_deck_id() + 1
  }
