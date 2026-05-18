import Dungeon/game_config as config
import Dungeon/default_ui as default_ui
import Dungeon as Dungeon
import Dungeon/App/state_helpers as M__Dungeon_App_state_helpers
import Dungeon/profile_helpers as M__Dungeon_profile_helpers
import Dungeon/Deck/deck_records as M__Dungeon_Deck_deck_records
import Dungeon/Deck/draft_ops as M__Dungeon_Deck_draft_ops
import Dungeon/Deck/sleeves as M__Dungeon_Deck_sleeves

def _mode_with_toggle(mode: Dungeon/DeckListMode, deck_id: U32) -> Dungeon/DeckListMode:
  match mode:
    case deck_list_edit{ids}:
      deck_list_edit{Dungeon/Deck/deck_records/toggle_id_in_list(ids, deck_id)}
    case _:
      mode

def _toggle(meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode, deck_id: U32, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match deck_id === Dungeon/Deck/deck_records/initial_deck_id():
    case 1:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{mode, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{_mode_with_toggle(mode, deck_id), sleeve_picker_closed{}}, next_seed_value, ui_value)

def _request_delete_check(meta_state: Dungeon/Meta, ids: List(U32), next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match Dungeon/Deck/deck_records/list_size(ids):
    case 0:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{deck_list_edit{ids}, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{deck_list_confirm_delete{ids}, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _request_delete(meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match mode:
    case deck_list_edit{ids}:
      _request_delete_check(meta_state, ids, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{mode, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _cancel_delete(meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match mode:
    case deck_list_confirm_delete{ids}:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{deck_list_edit{ids}, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{mode, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _resolve_active(current_active: U32, deleted_ids: List(U32)) -> U32:
  match Dungeon/Deck/deck_records/list_contains_id(deleted_ids, current_active):
    case 1:
      Dungeon/Deck/deck_records/initial_deck_id()
    case _:
      current_active

def _apply_delete(meta_state: Dungeon/Meta, ids: List(U32), next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  next_decks = Dungeon/Deck/deck_records/remove_decks_by_ids(Dungeon/profile_helpers/meta_decks(meta_state), ids);
  next_meta = Dungeon/profile_helpers/set_meta_decks(meta_state, next_decks);
  next_active = _resolve_active(Dungeon/profile_helpers/meta_active_deck_id(meta_state), ids);
  next_meta2 = Dungeon/profile_helpers/set_meta_active_deck_id(next_meta, next_active);
  Dungeon/App/state_helpers/_state(next_meta2, deck_list{deck_list_view{}, sleeve_picker_closed{}}, next_seed_value, default_ui())

def _confirm_delete(meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match mode:
    case deck_list_confirm_delete{ids}:
      _apply_delete(meta_state, ids, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{mode, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _new_deck_name(new_id: U32) -> String:
  "Deck " ++ U32/show(new_id)

def _create_deck(meta_state: Dungeon/Meta, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  new_id = Dungeon/profile_helpers/meta_next_deck_id(meta_state);
  new_record : Dungeon/DeckRecord = deck_record{new_id, _new_deck_name(new_id), Dungeon/Deck/sleeves/default_sleeve(), [] :: List(Dungeon/DeckEntry)};
  next_meta = Dungeon/profile_helpers/set_meta_next_deck_id(meta_state, new_id + 1);
  Dungeon/App/state_helpers/_state(next_meta, deck_detail{new_id, Dungeon/Deck/draft_ops/draft_from_record(new_record), picker_none{}, detail_view{}, sleeve_picker_closed{}}, next_seed_value, default_ui())

def _open_detail(meta_state: Dungeon/Meta, deck_id: U32, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match Dungeon/Deck/deck_records/find_deck(Dungeon/profile_helpers/meta_decks(meta_state), deck_id):
    case some{record}:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, Dungeon/Deck/draft_ops/draft_from_record(record), picker_none{}, detail_view{}, sleeve_picker_closed{}}, next_seed_value, default_ui())
    case none{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{deck_list_view{}, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _set_active(meta_state: Dungeon/Meta, deck_id: U32, mode: Dungeon/DeckListMode, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match Dungeon/Deck/deck_records/find_deck(Dungeon/profile_helpers/meta_decks(meta_state), deck_id):
    case some{record}:
      Dungeon/App/state_helpers/_state(Dungeon/profile_helpers/set_meta_active_deck_id(meta_state, deck_id), deck_list{mode, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case none{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{mode, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _next_sleeve_picker(current: Dungeon/DeckSleevePicker, deck_id: U32) -> Dungeon/DeckSleevePicker:
  match current:
    case sleeve_picker_open{open_id}:
      match open_id === deck_id:
        case 1:
          sleeve_picker_closed{}
        case _:
          sleeve_picker_open{deck_id}
    case sleeve_picker_closed{}:
      sleeve_picker_open{deck_id}

def _toggle_sleeve_picker(meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode, sleeve_picker: Dungeon/DeckSleevePicker, deck_id: U32, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match mode:
    case deck_list_view{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{mode, _next_sleeve_picker(sleeve_picker, deck_id)}, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{mode, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _set_sleeve(meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode, deck_id: U32, sleeve: Dungeon/DeckSleeve, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match Dungeon/Deck/deck_records/find_deck(Dungeon/profile_helpers/meta_decks(meta_state), deck_id):
    case some{record}:
      next_record = Dungeon/Deck/deck_records/deck_record_with_sleeve(record, sleeve);
      next_meta = Dungeon/profile_helpers/set_meta_decks(meta_state, Dungeon/Deck/deck_records/replace_deck(Dungeon/profile_helpers/meta_decks(meta_state), next_record));
      Dungeon/App/state_helpers/_state(next_meta, deck_list{mode, sleeve_picker_closed{}}, next_seed_value, default_ui())
    case none{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{mode, sleeve_picker_closed{}}, next_seed_value, ui_value)

def update_deck_list(evt: Dungeon/DungeonEvent, meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode, sleeve_picker: Dungeon/DeckSleevePicker, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match evt:
    case close_deck_list{}:
      Dungeon/App/state_helpers/_state(meta_state, setup{}, next_seed_value, default_ui())
    case enter_deck_edit_mode{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{deck_list_edit{[]}, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case exit_deck_edit_mode{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{deck_list_view{}, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case toggle_deck_select{deck_id}:
      _toggle(meta_state, mode, deck_id, next_seed_value, ui_value)
    case request_delete_decks{}:
      _request_delete(meta_state, mode, next_seed_value, ui_value)
    case cancel_delete_decks{}:
      _cancel_delete(meta_state, mode, next_seed_value, ui_value)
    case confirm_delete_decks{}:
      _confirm_delete(meta_state, mode, next_seed_value, ui_value)
    case create_new_deck{}:
      _create_deck(meta_state, next_seed_value, ui_value)
    case open_deck_detail{deck_id}:
      _open_detail(meta_state, deck_id, next_seed_value, ui_value)
    case set_active_deck{deck_id}:
      _set_active(meta_state, deck_id, mode, next_seed_value, ui_value)
    case toggle_deck_sleeve_picker{deck_id}:
      _toggle_sleeve_picker(meta_state, mode, sleeve_picker, deck_id, next_seed_value, ui_value)
    case close_deck_sleeve_picker{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{mode, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case set_deck_sleeve{deck_id, sleeve}:
      _set_sleeve(meta_state, mode, deck_id, sleeve, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{mode, sleeve_picker}, next_seed_value, ui_value)
