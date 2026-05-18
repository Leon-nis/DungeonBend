import Dungeon/game_config as config
import Dungeon/default_ui as default_ui
import Dungeon as Dungeon
import Dungeon/App/state_helpers as M__Dungeon_App_state_helpers
import Dungeon/profile_helpers as M__Dungeon_profile_helpers
import Dungeon/Deck/deck_records as M__Dungeon_Deck_deck_records
import Dungeon/Deck/deck_validation as M__Dungeon_Deck_deck_validation
import Dungeon/Deck/draft_ops as M__Dungeon_Deck_draft_ops
import Dungeon/Deck/card_collection as M__Dungeon_Deck_card_collection
import Dungeon/Deck/quotas as M__Dungeon_Deck_quotas

def _request_close(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match Dungeon/Deck/draft_ops/draft_dirty(draft):
    case 0:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{deck_list_view{}, sleeve_picker_closed{}}, next_seed_value, default_ui())
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker, detail_confirm_discard{}, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _next_picker_after_add(draft: Dungeon/DeckDraft, card: Dungeon/CardRef) -> Dungeon/DeckPickerMode:
  cat = Dungeon/Deck/card_collection/card_category(card);
  used = Dungeon/Deck/quotas/category_count(Dungeon/Deck/draft_ops/draft_entries(draft), cat);
  cap = Dungeon/Deck/quotas/quota_for_category(Dungeon/Deck/quotas/deck_quotas_default(), cat);
  match used < cap:
    case 1:
      picker_open{cat}
    case _:
      picker_none{}

def _apply_add(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, card: Dungeon/CardRef, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  next_draft = Dungeon/Deck/draft_ops/add_card(draft, card);
  next_picker = _next_picker_after_add(next_draft, card);
  Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, next_draft, next_picker, detail_view{}, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _try_add(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, card: Dungeon/CardRef, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match Dungeon/Deck/draft_ops/can_add_card(config(), meta_state, draft, card):
    case 1:
      _apply_add(meta_state, deck_id, draft, card, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker, detail_view{}, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _and(a: U32, b: U32) -> U32:
  match a:
    case 0:
      0
    case _:
      b

def _card_ref_eq(left: Dungeon/CardRef, right: Dungeon/CardRef) -> U32:
  match left right:
    case hero_card{} hero_card{}:
      1
    case monster_card{l} monster_card{r}:
      l === r
    case sword_card{l} sword_card{r}:
      l === r
    case potion_card{l} potion_card{r}:
      l === r
    case _ _:
      0

def _is_armed_for(detail_mode: Dungeon/DeckDetailMode, card: Dungeon/CardRef, occurrence: U32) -> U32:
  match detail_mode:
    case detail_pending_delete{armed, armed_occurrence}:
      _and(_card_ref_eq(armed, card), armed_occurrence === occurrence)
    case _:
      0

def _try_remove(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode, card: Dungeon/CardRef, occurrence: U32, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match _is_armed_for(detail_mode, card, occurrence):
    case 1:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, Dungeon/Deck/draft_ops/remove_card(draft, card), picker, detail_view{}, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker, detail_pending_delete{card, occurrence}, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _draft_name(draft: Dungeon/DeckDraft) -> String:
  match draft:
    case deck_draft{id, name, sleeve, entries, dirty}:
      name

def _record_id_of(record: Dungeon/DeckRecord) -> U32:
  match record:
    case deck_record{id, name, sleeve, entries}:
      id

def _upsert_deck(records: List(Dungeon/DeckRecord), next_record: Dungeon/DeckRecord) -> List(Dungeon/DeckRecord):
  match Dungeon/Deck/deck_records/find_deck(records, _record_id_of(next_record)):
    case some{existing}:
      Dungeon/Deck/deck_records/replace_deck(records, next_record)
    case none{}:
      Dungeon/Deck/deck_records/append_deck(records, next_record)

def _apply_save(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode, next_seed_value: U32) -> Dungeon/DungeonState:
  next_record = Dungeon/Deck/draft_ops/draft_to_record(draft);
  next_decks = _upsert_deck(Dungeon/profile_helpers/meta_decks(meta_state), next_record);
  next_meta = Dungeon/profile_helpers/set_meta_decks(meta_state, next_decks);
  reset_draft : Dungeon/DeckDraft = deck_draft{deck_id, _draft_name(draft), Dungeon/Deck/draft_ops/draft_sleeve(draft), Dungeon/Deck/draft_ops/draft_entries(draft), 0};
  Dungeon/App/state_helpers/_state(next_meta, deck_detail{deck_id, reset_draft, picker, detail_mode, sleeve_picker_closed{}}, next_seed_value, default_ui())

def _try_save(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match Dungeon/Deck/deck_validation/is_deck_valid(config(), meta_state, Dungeon/Deck/draft_ops/draft_entries(draft)):
    case 1:
      _apply_save(meta_state, deck_id, draft, picker, detail_mode, next_seed_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker_closed{}}, next_seed_value, ui_value)

def _set_active_if_valid(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode, target_id: U32, next_seed_value: U32) -> Dungeon/DungeonState:
  match Dungeon/Deck/deck_records/find_deck(Dungeon/profile_helpers/meta_decks(meta_state), target_id):
    case some{record}:
      Dungeon/App/state_helpers/_state(Dungeon/profile_helpers/set_meta_active_deck_id(meta_state, target_id), deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker_closed{}}, next_seed_value, default_ui())
    case none{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker_closed{}}, next_seed_value, default_ui())

def _try_set_active(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode, target_id: U32, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match Dungeon/Deck/draft_ops/draft_dirty(draft):
    case 0:
      _set_active_if_valid(meta_state, deck_id, draft, picker, detail_mode, target_id, next_seed_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker_closed{}}, next_seed_value, ui_value)

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

def _save_sleeve_meta(meta_state: Dungeon/Meta, draft: Dungeon/DeckDraft, target_id: U32, sleeve: Dungeon/DeckSleeve) -> Dungeon/Meta:
  match Dungeon/Deck/deck_records/find_deck(Dungeon/profile_helpers/meta_decks(meta_state), target_id):
    case some{record}:
      updated = Dungeon/Deck/deck_records/deck_record_with_sleeve(record, sleeve);
      Dungeon/profile_helpers/set_meta_decks(meta_state, Dungeon/Deck/deck_records/replace_deck(Dungeon/profile_helpers/meta_decks(meta_state), updated))
    case none{}:
      created : Dungeon/DeckRecord = deck_record{target_id, Dungeon/Deck/draft_ops/draft_name(draft), sleeve, []};
      Dungeon/profile_helpers/set_meta_decks(meta_state, Dungeon/Deck/deck_records/append_deck(Dungeon/profile_helpers/meta_decks(meta_state), created))

def _save_sleeve_draft(draft: Dungeon/DeckDraft, target_id: U32, sleeve: Dungeon/DeckSleeve) -> Dungeon/DeckDraft:
  match Dungeon/Deck/draft_ops/draft_id(draft) === target_id:
    case 1:
      Dungeon/Deck/draft_ops/draft_with_sleeve(draft, sleeve)
    case _:
      draft

def _set_sleeve(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode, target_id: U32, sleeve: Dungeon/DeckSleeve, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  next_meta = _save_sleeve_meta(meta_state, draft, target_id, sleeve);
  next_draft = _save_sleeve_draft(draft, target_id, sleeve);
  Dungeon/App/state_helpers/_state(next_meta, deck_detail{deck_id, next_draft, picker, detail_mode, sleeve_picker_closed{}}, next_seed_value, default_ui())

def update_deck_detail(evt: Dungeon/DungeonEvent, meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode, sleeve_picker: Dungeon/DeckSleevePicker, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match evt:
    case request_close_deck_detail{}:
      _request_close(meta_state, deck_id, draft, picker, next_seed_value, ui_value)
    case close_deck_detail{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{deck_list_view{}, sleeve_picker_closed{}}, next_seed_value, default_ui())
    case discard_deck_changes{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_list{deck_list_view{}, sleeve_picker_closed{}}, next_seed_value, default_ui())
    case cancel_discard_deck_changes{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker, detail_view{}, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case add_card_to_deck{card}:
      _try_add(meta_state, deck_id, draft, picker, card, next_seed_value, ui_value)
    case remove_card_from_deck{card, occurrence}:
      _try_remove(meta_state, deck_id, draft, picker, detail_mode, card, occurrence, next_seed_value, ui_value)
    case save_deck_changes{}:
      _try_save(meta_state, deck_id, draft, picker, detail_mode, next_seed_value, ui_value)
    case set_active_deck{target_id}:
      _try_set_active(meta_state, deck_id, draft, picker, detail_mode, target_id, next_seed_value, ui_value)
    case open_category_picker{category}:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker_open{category}, detail_view{}, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case close_category_picker{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker_none{}, detail_view{}, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case toggle_deck_sleeve_picker{target_id}:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker, detail_mode, _next_sleeve_picker(sleeve_picker, target_id)}, next_seed_value, ui_value)
    case close_deck_sleeve_picker{}:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker_closed{}}, next_seed_value, ui_value)
    case set_deck_sleeve{target_id, sleeve}:
      _set_sleeve(meta_state, deck_id, draft, picker, detail_mode, target_id, sleeve, next_seed_value, ui_value)
    case _:
      Dungeon/App/state_helpers/_state(meta_state, deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker}, next_seed_value, ui_value)
