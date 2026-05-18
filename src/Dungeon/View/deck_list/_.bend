def deck_list() -> Unit:
  unit{}

import HTML as HTML
import Dungeon/game_config as config
import Dungeon as Dungeon
import Dungeon/View/topbar_stats as M__Dungeon_View_topbar_stats
import Dungeon/View/selectors as M__Dungeon_View_selectors
import Dungeon/View/action_button as M__Dungeon_View_action_button
import Dungeon/View/deck_chrome as M__Dungeon_View_deck_chrome
import Dungeon/View/deck_sleeve_picker as M__Dungeon_View_deck_sleeve_picker
import Dungeon/View/assets_and_labels as M__Dungeon_View_assets_and_labels
import Midum/Image as M__Midum_Image
import Midum/Card as M__Midum_Card
import Midum/Layout as M__Midum_Layout
import Dungeon/profile_helpers as M__Dungeon_profile_helpers
import Dungeon/Deck/deck_records as M__Dungeon_Deck_deck_records
import Dungeon/Deck/deck_validation as M__Dungeon_Deck_deck_validation
import Dungeon/Deck/quotas as M__Dungeon_Deck_quotas

def _shell(body: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
  Midum/Layout/shell(
    Dungeon/DungeonEvent,
    body,
    [
      max_width_px{value: 1080n},
      height_viewport{},
      overflow_hidden{},
      safe_area{},
      inset_px{top: 24n, right: 14n, bottom: 20n, left: 14n},
      compact_inset_px{top: 20n, right: 12n, bottom: 18n, left: 12n}
    ]
  )

def _edit_toggle_button(mode: Dungeon/DeckListMode) -> HTML(Dungeon/DungeonEvent):
  match mode:
    case deck_list_view{}:
      Dungeon/View/action_button/secondary_fit(Dungeon/DungeonEvent, enter_deck_edit_mode{}, "EDIT", 1)
    case deck_list_edit{ids}:
      Dungeon/View/action_button/secondary_fit(Dungeon/DungeonEvent, exit_deck_edit_mode{}, "DONE", 1)
    case deck_list_confirm_delete{ids}:
      text{""}

def _show_edit_toggle_mode(mode: Dungeon/DeckListMode) -> U32:
  match mode:
    case deck_list_confirm_delete{ids}:
      0
    case _:
      1

def _show_edit_toggle(meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode) -> U32:
  match Dungeon/Deck/deck_records/deck_count(Dungeon/profile_helpers/meta_decks(meta_state)) > 1:
    case 1:
      _show_edit_toggle_mode(mode)
    case _:
      0

def _edit_toggle(meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode) -> HTML(Dungeon/DungeonEvent):
  match _show_edit_toggle(meta_state, mode):
    case 0:
      text{""}
    case _:
      <div class="menu-club-btn-wrap menu-club-btn-wrap--fit">
        {_edit_toggle_button(mode)}
      </div>

def _trailing(meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode) -> HTML(Dungeon/DungeonEvent):
  <div class="deck-chrome-trailing">
    {Dungeon/View/topbar_stats/boosters_stat(Dungeon/View/selectors/meta_pack_total(meta_state))}
    {Dungeon/View/topbar_stats/gold_stat(Dungeon/View/selectors/meta_gold(meta_state))}
    {_edit_toggle(meta_state, mode)}
  </div>

def _create_card(mode: Dungeon/DeckListMode) -> HTML(Dungeon/DungeonEvent):
  match mode:
    case deck_list_view{}:
      <button class="deck-list-card deck-list-card--create" type="button" on_click={create_new_deck{}}>
        <span class="deck-list-card__plus">+</span>
        <span class="deck-list-card__label">{text{"NEW DECK"}}</span>
      </button>
    case _:
      text{""}

def _card_click_event(mode: Dungeon/DeckListMode, deck_id: U32) -> Dungeon/DungeonEvent:
  match mode:
    case deck_list_view{}:
      open_deck_detail{deck_id}
    case deck_list_edit{ids}:
      toggle_deck_select{deck_id}
    case deck_list_confirm_delete{ids}:
      ignore{}

def _append_class(base: String, flag: U32, suffix: String) -> String:
  match flag:
    case 0:
      base
    case _:
      base ++ suffix

def _deck_card_class(is_active: U32, is_initial: U32, selected: U32) -> String:
  base = "deck-list-card";
  with_active = _append_class(base, is_active, " deck-list-card--active");
  with_initial = _append_class(with_active, is_initial, " deck-list-card--initial");
  _append_class(with_initial, selected, " deck-list-card--selected")

def _is_selected_in_mode(mode: Dungeon/DeckListMode, id: U32) -> U32:
  match mode:
    case deck_list_edit{ids}:
      Dungeon/Deck/deck_records/list_contains_id(ids, id)
    case deck_list_confirm_delete{ids}:
      Dungeon/Deck/deck_records/list_contains_id(ids, id)
    case _:
      0

def _count_text(record: Dungeon/DeckRecord) -> String:
  total = Dungeon/Deck/quotas/quotas_total(Dungeon/Deck/quotas/deck_quotas_default());
  current = Dungeon/Deck/deck_validation/deck_total_count(Dungeon/Deck/deck_records/deck_record_entries(record));
  U32/show(current) ++ "/" ++ U32/show(total)

def _show_bullet_mode(mode: Dungeon/DeckListMode) -> U32:
  match mode:
    case deck_list_edit{ids}:
      1
    case deck_list_confirm_delete{ids}:
      1
    case _:
      0

def _show_bullet(mode: Dungeon/DeckListMode, is_initial: U32) -> U32:
  match is_initial:
    case 1:
      0
    case _:
      _show_bullet_mode(mode)

def _bullet_class(selected: U32) -> String:
  match selected:
    case 0:
      "deck-list-card__bullet"
    case _:
      "deck-list-card__bullet deck-list-card__bullet--checked"

def _bullet_node(selected: U32, deck_id: U32) -> HTML(Dungeon/DungeonEvent):
  cls = _bullet_class(selected);
  <button class={cls} type="button" on_click={toggle_deck_select{deck_id}}>
    <span class="deck-list-card__bullet-dot"></span>
  </button>

def _select_bullet(mode: Dungeon/DeckListMode, deck_id: U32, is_initial: U32) -> HTML(Dungeon/DungeonEvent):
  match _show_bullet(mode, is_initial):
    case 0:
      text{""}
    case _:
      _bullet_node(_is_selected_in_mode(mode, deck_id), deck_id)

def _active_badge(is_active: U32) -> HTML(Dungeon/DungeonEvent):
  match is_active:
    case 0:
      text{""}
    case _:
      <span class="deck-list-card__active-badge">{text{"ACTIVE"}}</span>

def _show_sleeve_control(mode: Dungeon/DeckListMode) -> U32:
  match mode:
    case deck_list_view{}:
      1
    case _:
      0

def _is_sleeve_picker_open(sleeve_picker: Dungeon/DeckSleevePicker, deck_id: U32) -> U32:
  match sleeve_picker:
    case sleeve_picker_open{open_id}:
      open_id === deck_id
    case sleeve_picker_closed{}:
      0

def _sleeve_control(mode: Dungeon/DeckListMode, deck_id: U32, sleeve: Dungeon/DeckSleeve, sleeve_picker: Dungeon/DeckSleevePicker) -> HTML(Dungeon/DungeonEvent):
  match _show_sleeve_control(mode):
    case 0:
      text{""}
    case _:
      Dungeon/View/deck_sleeve_picker/render_card_control(deck_id, sleeve, _is_sleeve_picker_open(sleeve_picker, deck_id))

def _deck_card(record: Dungeon/DeckRecord, active_id: U32, mode: Dungeon/DeckListMode, sleeve_picker: Dungeon/DeckSleevePicker) -> HTML(Dungeon/DungeonEvent):
  id = Dungeon/Deck/deck_records/deck_record_id(record);
  is_active = id === active_id;
  is_initial = id === Dungeon/Deck/deck_records/initial_deck_id();
  selected = _is_selected_in_mode(mode, id);
  cls = _deck_card_class(is_active, is_initial, selected);
  sleeve = Dungeon/Deck/deck_records/deck_record_sleeve(record);
  <div class={cls}>
    <button class="deck-list-card__body" type="button" on_click={_card_click_event(mode, id)}>
      <span class="deck-list-card__cover">
        {Midum/Image/view(Dungeon/DungeonEvent, Dungeon/View/assets_and_labels/_deck_cover_sprite_for_sleeve(sleeve), Dungeon/Deck/deck_records/deck_record_name(record), [])}
      </span>
      <span class="deck-list-card__name">{text{Dungeon/Deck/deck_records/deck_record_name(record)}}</span>
      <span class="deck-list-card__count">{text{_count_text(record)}}</span>
    </button>
    {_sleeve_control(mode, id, sleeve, sleeve_picker)}
    {_select_bullet(mode, id, is_initial)}
    {_active_badge(is_active)}
  </div>

def _deck_cards(records: List(Dungeon/DeckRecord), active_id: U32, mode: Dungeon/DeckListMode, sleeve_picker: Dungeon/DeckSleevePicker) -> List(HTML(Dungeon/DungeonEvent)):
  match records:
    case []:
      []
    case current<>rest:
      _deck_card(current, active_id, mode, sleeve_picker)<>_deck_cards(rest, active_id, mode, sleeve_picker)

def _delete_enabled(count: U32) -> U32:
  match count:
    case 0:
      0
    case _:
      1

def _delete_button(count: U32) -> HTML(Dungeon/DungeonEvent):
  enabled = _delete_enabled(count);
  label = "DELETE (" ++ U32/show(count) ++ ")";
  <div class="deck-list-delete-action">
    {Dungeon/View/action_button/primary_full(Dungeon/DungeonEvent, request_delete_decks{}, label, enabled)}
  </div>

def _delete_action(mode: Dungeon/DeckListMode) -> HTML(Dungeon/DungeonEvent):
  match mode:
    case deck_list_edit{ids}:
      _delete_button(Dungeon/Deck/deck_records/list_size(ids))
    case _:
      text{""}

def _grid(meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode, sleeve_picker: Dungeon/DeckSleevePicker) -> HTML(Dungeon/DungeonEvent):
  <section class="deck-list">
    <div class="deck-list__grid">
      {_create_card(mode)}
      {..._deck_cards(Dungeon/profile_helpers/meta_decks(meta_state), Dungeon/profile_helpers/meta_active_deck_id(meta_state), mode, sleeve_picker)}
    </div>
    {_delete_action(mode)}
  </section>

def _confirm_body(count: U32) -> String:
  "This will permanently delete " ++ U32/show(count) ++ " deck(s)."

def _confirm_modal(count: U32) -> HTML(Dungeon/DungeonEvent):
  <div class="game-over-modal game-over-modal--visible deck-confirm-modal">
    {Midum/Card/neutral(
      Dungeon/DungeonEvent,
      <div class="game-over-card">
        <p class="game-over-card__eyebrow">{text{"CONFIRM"}}</p>
        <h2 class="game-over-card__title">{text{"Delete decks?"}}</h2>
        <p class="game-over-card__body">{text{_confirm_body(count)}}</p>
        <section class="game-over-card__actions">
          <div class="menu-secondary-action game-over-card__secondary">
            {Dungeon/View/action_button/secondary_full(Dungeon/DungeonEvent, cancel_delete_decks{}, "CANCEL", 1)}
          </div>
          <div class="menu-start-action game-over-card__primary">
            {Dungeon/View/action_button/primary_full(Dungeon/DungeonEvent, confirm_delete_decks{}, "DELETE", 1)}
          </div>
        </section>
      </div>,
      [padding_md{}]
    )}
  </div>

def _modal_layer(mode: Dungeon/DeckListMode) -> HTML(Dungeon/DungeonEvent):
  match mode:
    case deck_list_confirm_delete{ids}:
      _confirm_modal(Dungeon/Deck/deck_records/list_size(ids))
    case _:
      text{""}

def _render_deck_list(meta_state: Dungeon/Meta, mode: Dungeon/DeckListMode, sleeve_picker: Dungeon/DeckSleevePicker) -> HTML(Dungeon/DungeonEvent):
  _shell(
    Midum/Layout/frame(
      Dungeon/DungeonEvent,
      Dungeon/View/deck_chrome/render(
        close_deck_list{},
        close_deck_list{},
        _trailing(meta_state, mode),
        _trailing(meta_state, mode),
        [],
        <section class="deck-stage">
          <div class="deck-stage__content">
            {_grid(meta_state, mode, sleeve_picker)}
          </div>
          {_modal_layer(mode)}
        </section>
      ),
      [width_full{}, height_full{}, inset_none{}]
    )
  )
