import HTML as HTML
import Dungeon/Meta as Meta
import Dungeon/DeckEntry as DeckEntry
import Dungeon/CardRef as CardRef
import Dungeon/DeckbuilderSelection as DeckbuilderSelection
import Dungeon/DungeonEvent as DungeonEvent
import Dungeon/View/menu_screen/_menu_screen_frame as _menu_screen_frame
import Dungeon/View/assets_and_labels/_card_name as _card_name
import Dungeon/View/assets_and_labels/_card_sprite as _card_sprite
import Dungeon/deck_counter_frames/idle_src as deck_counter_idle_src
import Dungeon/deckbuilder_helpers/card_ref_eq as card_ref_eq
import Dungeon/deckbuilder_helpers/card_tier_count as card_tier_count
import Dungeon/deckbuilder_helpers/deck_mode_label as deck_mode_label
import Dungeon/deckbuilder_helpers/deck_star_total as deck_star_total
import Dungeon/deckbuilder_helpers/deck_total as deck_total
import Dungeon/deckbuilder_helpers/deck_total_ready as deck_total_ready
import Dungeon/profile_helpers/deckbuilder_target_count as deckbuilder_target_count
import Dungeon/deckbuilder_helpers/selectable_cards as selectable_cards
import Dungeon/deckbuilder_helpers/stash_count as stash_count
import Midum/Layout/frame as layout_frame
import Midum/Layout/shell as layout_shell
import Midum/Button/primary as button_primary
import Midum/Button/secondary as button_secondary
import Midum/Text/Align as Align
import Midum/Text/h2 as text_h2

type DeckbuilderPanelKind {
  deck_panel_kind{}
  stash_panel_kind{}
}

def _deckbuilder_visible_rows() -> U32:
  6

def _render_deckbuilder(meta_state: Meta, draft_deck: List(DeckEntry), deck_selection: DeckbuilderSelection, stash_selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32) -> HTML(DungeonEvent):
  layout_shell(
    DungeonEvent,
    layout_frame(
      DungeonEvent,
      _menu_screen_frame(
        _deckbuilder_header(draft_deck),
        _deckbuilder_body(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll),
        _deckbuilder_footer(draft_deck)
      ),
      [width_full{}, height_full{}, inset_none{}]
    ),
    [
      max_width_px{value: 1180n},
      height_viewport{},
      overflow_hidden{},
      safe_area{},
      inset_px{top: 24n, right: 14n, bottom: 20n, left: 14n},
      compact_inset_px{top: 20n, right: 12n, bottom: 18n, left: 12n}
    ]
  )

def _deckbuilder_header(draft_deck: List(DeckEntry)) -> HTML(DungeonEvent):
  <div class="deckbuilder-header">
    <div class="deckbuilder-header__back">
      {_deckbuilder_back_button()}
    </div>
    <div class="deckbuilder-header__title">
      {text_h2(DungeonEvent, center{}, "Dungeon Deck", [])}
    </div>
    <div class="deckbuilder-header__mode">
      <span class={_mode_chip_class(deck_mode_label(draft_deck))}>{text{deck_mode_label(draft_deck)}}</span>
    </div>
  </div>

def _deckbuilder_body(meta_state: Meta, draft_deck: List(DeckEntry), deck_selection: DeckbuilderSelection, stash_selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32) -> HTML(DungeonEvent):
  <section class="deckbuilder-layout">
    {_deck_panel(meta_state, draft_deck, deck_selection, deck_scroll)}
    {_deckbuilder_transfer_controls()}
    {_stash_panel(meta_state, draft_deck, stash_selection, stash_scroll)}
  </section>

def _deck_panel(meta_state: Meta, draft_deck: List(DeckEntry), selection: DeckbuilderSelection, scroll: U32) -> HTML(DungeonEvent):
  <section class="deckbuilder-panel deckbuilder-panel--deck">
    <div class="deckbuilder-panel__surface deckbuilder-panel__surface--deck">
      <div class="deckbuilder-panel__head">
        <div class="deckbuilder-panel__head-top">
          <h3 class="deckbuilder-panel__title">DECK</h3>
        </div>
        <div class="deckbuilder-panel__summary">
          <div class="deckbuilder-summary deckbuilder-summary--cards">
            <img class="deckbuilder-summary__icon" src={deck_counter_idle_src()} alt="" aria-hidden="true" />
            <span class="deckbuilder-summary__label">{text{_deck_cards_label(draft_deck)}}</span>
          </div>
          <div class="deckbuilder-summary deckbuilder-summary--stars">
            <span class="deckbuilder-summary__label">{text{"★ Total: " ++ U32/show(deck_star_total(draft_deck))}}</span>
          </div>
        </div>
      </div>
      {_table_header(deck_panel_kind{})}
      <div class="deckbuilder-table">
        {_render_rows(meta_state, draft_deck, selection, scroll, _deckbuilder_visible_rows(), deck_panel_kind{}, selectable_cards())}
        {_empty_notice(meta_state, draft_deck, deck_panel_kind{})}
      </div>
    </div>
    {_scroll_controls(meta_state, draft_deck, scroll, deck_panel_kind{})}
  </section>

def _stash_panel(meta_state: Meta, draft_deck: List(DeckEntry), selection: DeckbuilderSelection, scroll: U32) -> HTML(DungeonEvent):
  <section class="deckbuilder-panel deckbuilder-panel--stash">
    <div class="deckbuilder-panel__surface deckbuilder-panel__surface--stash">
      <div class="deckbuilder-panel__head">
        <div class="deckbuilder-panel__head-top">
          <h3 class="deckbuilder-panel__title">ARMAZEM</h3>
        </div>
      </div>
      {_table_header(stash_panel_kind{})}
      <div class="deckbuilder-table">
        {_render_rows(meta_state, draft_deck, selection, scroll, _deckbuilder_visible_rows(), stash_panel_kind{}, selectable_cards())}
        {_empty_notice(meta_state, draft_deck, stash_panel_kind{})}
      </div>
    </div>
    {_scroll_controls(meta_state, draft_deck, scroll, stash_panel_kind{})}
  </section>

def _table_header(kind: DeckbuilderPanelKind) -> HTML(DungeonEvent):
  <div class={_header_row_class(kind)}>
    <span class="deckbuilder-row__name">Nome</span>
    <span class="deckbuilder-row__sprite-col">Sprite</span>
    <span class="deckbuilder-row__qty">Qtd</span>
    {_table_header_meta(kind)}
  </div>

def _header_row_class(kind: DeckbuilderPanelKind) -> String:
  match kind:
    case deck_panel_kind{}:
      "deckbuilder-row deckbuilder-row--header deckbuilder-row--deck"
    case stash_panel_kind{}:
      "deckbuilder-row deckbuilder-row--header deckbuilder-row--stash"

def _table_header_meta(kind: DeckbuilderPanelKind) -> HTML(DungeonEvent):
  match kind:
    case deck_panel_kind{}:
      <span class="deckbuilder-row__meta-col">Tier</span>
    case _:
      text{""}

def _render_rows(meta_state: Meta, draft_deck: List(DeckEntry), selection: DeckbuilderSelection, scroll: U32, limit: U32, kind: DeckbuilderPanelKind, cards: List(CardRef)) -> HTML(DungeonEvent):
  match limit:
    case 0:
      text{""}
    case _:
      match cards:
        case []:
          text{""}
        case card<>rest:
          _render_row_step(meta_state, draft_deck, selection, scroll, limit, kind, card, rest)

def _render_row_step(meta_state: Meta, draft_deck: List(DeckEntry), selection: DeckbuilderSelection, scroll: U32, limit: U32, kind: DeckbuilderPanelKind, card: CardRef, rest: List(CardRef)) -> HTML(DungeonEvent):
  count = _row_count(meta_state, draft_deck, card, kind);
  _render_row_with_count(meta_state, draft_deck, selection, scroll, limit, kind, card, rest, count)

def _render_row_with_count(meta_state: Meta, draft_deck: List(DeckEntry), selection: DeckbuilderSelection, scroll: U32, limit: U32, kind: DeckbuilderPanelKind, card: CardRef, rest: List(CardRef), count: U32) -> HTML(DungeonEvent):
  match count:
    case 0:
      _render_rows(meta_state, draft_deck, selection, scroll, limit, kind, rest)
    case _:
      _render_row_at_scroll(meta_state, draft_deck, selection, scroll, limit, kind, card, rest, count)

def _render_row_at_scroll(meta_state: Meta, draft_deck: List(DeckEntry), selection: DeckbuilderSelection, scroll: U32, limit: U32, kind: DeckbuilderPanelKind, card: CardRef, rest: List(CardRef), count: U32) -> HTML(DungeonEvent):
  match scroll:
    case 0:
      <div class="deckbuilder-rows-chunk">
        {_row_button(draft_deck, selection, card, count, kind)}
        {_render_rows(meta_state, draft_deck, selection, 0, limit - 1, kind, rest)}
      </div>
    case _:
      _render_rows(meta_state, draft_deck, selection, scroll - 1, limit, kind, rest)

def _row_button(draft_deck: List(DeckEntry), selection: DeckbuilderSelection, card: CardRef, count: U32, kind: DeckbuilderPanelKind) -> HTML(DungeonEvent):
  <button class={_row_class(selection, card, kind)} type="button" on_click={_row_event(card, kind)}>
    <span class="deckbuilder-row__name">{text{_card_name(card)}}</span>
    <span class="deckbuilder-row__sprite-col">
      <img class="deckbuilder-row__sprite" src={_card_sprite(card)} alt={_card_name(card)} />
    </span>
    <span class="deckbuilder-row__qty">{text{U32/show(count)}}</span>
    {_row_meta(kind, card)}
  </button>

def _row_class(selection: DeckbuilderSelection, card: CardRef, kind: DeckbuilderPanelKind) -> String:
  match _is_selected(selection, card):
    case 1:
      _selected_row_class(kind)
    case _:
      _base_row_class(kind)

def _base_row_class(kind: DeckbuilderPanelKind) -> String:
  match kind:
    case deck_panel_kind{}:
      "deckbuilder-row deckbuilder-row--button deckbuilder-row--deck"
    case stash_panel_kind{}:
      "deckbuilder-row deckbuilder-row--button deckbuilder-row--stash"

def _selected_row_class(kind: DeckbuilderPanelKind) -> String:
  _base_row_class(kind) ++ " deckbuilder-row--selected"

def _is_selected(selection: DeckbuilderSelection, card: CardRef) -> U32:
  match selection:
    case no_deckbuilder_selection{}:
      0
    case deckbuilder_selection{selected_card}:
      card_ref_eq(selected_card, card)

def _row_event(card: CardRef, kind: DeckbuilderPanelKind) -> DungeonEvent:
  match kind:
    case deck_panel_kind{}:
      deckbuilder_select_deck{card}
    case stash_panel_kind{}:
      deckbuilder_select_stash{card}

def _row_meta(kind: DeckbuilderPanelKind, card: CardRef) -> HTML(DungeonEvent):
  match kind:
    case deck_panel_kind{}:
      _deck_row_tier(card)
    case _:
      text{""}

def _deck_row_tier(card: CardRef) -> HTML(DungeonEvent):
  match card_tier_count(card):
    case 0:
      text{""}
    case tier:
      <span class="deckbuilder-row__meta-col">
        <span class="deckbuilder-tier">{_tier_sprites(tier)}</span>
      </span>

def _tier_sprites(tier: U32) -> HTML(DungeonEvent):
  match tier:
    case 0:
      text{""}
    case _:
      <span class="deckbuilder-tier__stack">
        <span class="deckbuilder-tier__star">★</span>
        {_tier_sprites(tier - 1)}
      </span>

def _empty_notice(meta_state: Meta, draft_deck: List(DeckEntry), kind: DeckbuilderPanelKind) -> HTML(DungeonEvent):
  match _has_visible_rows(meta_state, draft_deck, kind):
    case 1:
      text{""}
    case _:
      <div class="deckbuilder-empty">{text{_empty_notice_text(kind)}}</div>

def _empty_notice_text(kind: DeckbuilderPanelKind) -> String:
  match kind:
    case deck_panel_kind{}:
      "Nenhuma carta no deck."
    case stash_panel_kind{}:
      "Nenhuma carta disponivel."

def _has_visible_rows(meta_state: Meta, draft_deck: List(DeckEntry), kind: DeckbuilderPanelKind) -> U32:
  match _visible_total(meta_state, draft_deck, kind):
    case 0:
      0
    case _:
      1

def _scroll_controls(meta_state: Meta, draft_deck: List(DeckEntry), scroll: U32, kind: DeckbuilderPanelKind) -> HTML(DungeonEvent):
  <aside class="deckbuilder-scroll">
    {_scroll_button("^", _scroll_up_event(kind), _scroll_up_enabled(scroll))}
    <div class="deckbuilder-scroll__track">
      <div class="deckbuilder-scroll__slot" aria-hidden="true"></div>
      <div class="deckbuilder-scroll__bar" aria-hidden="true" style={_scroll_bar_style(meta_state, draft_deck, scroll, kind)}></div>
    </div>
    {_scroll_button("v", _scroll_down_event(kind), _scroll_down_enabled(meta_state, draft_deck, scroll, kind))}
  </aside>

def _scroll_button(label: String, evt: DungeonEvent, enabled: U32) -> HTML(DungeonEvent):
  <div class="deckbuilder-scroll__btn-wrap">
    {button_secondary(DungeonEvent, evt, small{}, label, _deckbuilder_button_overrides(enabled))}
  </div>

def _scroll_up_enabled(scroll: U32) -> U32:
  match scroll:
    case 0:
      0
    case _:
      1

def _scroll_down_enabled(meta_state: Meta, draft_deck: List(DeckEntry), scroll: U32, kind: DeckbuilderPanelKind) -> U32:
  total = _visible_total(meta_state, draft_deck, kind);
  visible = _deckbuilder_visible_rows();
  match total <= visible:
    case 1:
      0
    case _:
      match scroll + visible < total:
        case 1:
          1
        case _:
          0

def _scroll_up_event(kind: DeckbuilderPanelKind) -> DungeonEvent:
  match kind:
    case deck_panel_kind{}:
      deckbuilder_scroll_deck_up{}
    case stash_panel_kind{}:
      deckbuilder_scroll_stash_up{}

def _scroll_down_event(kind: DeckbuilderPanelKind) -> DungeonEvent:
  match kind:
    case deck_panel_kind{}:
      deckbuilder_scroll_deck_down{}
    case stash_panel_kind{}:
      deckbuilder_scroll_stash_down{}

def _scroll_bar_style(meta_state: Meta, draft_deck: List(DeckEntry), scroll: U32, kind: DeckbuilderPanelKind) -> String:
  total = _visible_total(meta_state, draft_deck, kind);
  visible = _deckbuilder_visible_rows();
  match total <= visible:
    case 1:
      "top:0%;"
    case _:
      max_scroll = total - visible;
      match max_scroll:
        case 0:
          "top:0%;"
        case _:
          "top:" ++ U32/show(scroll * 18) ++ "px;"

def _visible_total(meta_state: Meta, draft_deck: List(DeckEntry), kind: DeckbuilderPanelKind) -> U32:
  _visible_total_from_cards(meta_state, draft_deck, kind, selectable_cards())

def _visible_total_from_cards(meta_state: Meta, draft_deck: List(DeckEntry), kind: DeckbuilderPanelKind, cards: List(CardRef)) -> U32:
  match cards:
    case []:
      0
    case card<>rest:
      match _row_count(meta_state, draft_deck, card, kind):
        case 0:
          _visible_total_from_cards(meta_state, draft_deck, kind, rest)
        case _:
          1 + _visible_total_from_cards(meta_state, draft_deck, kind, rest)

def _row_count(meta_state: Meta, draft_deck: List(DeckEntry), card: CardRef, kind: DeckbuilderPanelKind) -> U32:
  match kind:
    case deck_panel_kind{}:
      _deck_count(draft_deck, card)
    case stash_panel_kind{}:
      stash_count(meta_state, draft_deck, card)

def _deck_count(draft_deck: List(DeckEntry), card: CardRef) -> U32:
  match draft_deck:
    case []:
      0
    case monster_entry{ref, count}<>rest:
      match card:
        case monster_card{card_ref}:
          match ref === card_ref:
            case 1:
              count
            case _:
              _deck_count(rest, card)
        case _:
          _deck_count(rest, card)
    case sword_entry{ref, count}<>rest:
      match card:
        case sword_card{card_ref}:
          match ref === card_ref:
            case 1:
              count
            case _:
              _deck_count(rest, card)
        case _:
          _deck_count(rest, card)
    case potion_entry{ref, count}<>rest:
      match card:
        case potion_card{card_ref}:
          match ref === card_ref:
            case 1:
              count
            case _:
              _deck_count(rest, card)
        case _:
          _deck_count(rest, card)
    case hero_entry{count}<>rest:
      _deck_count(rest, card)

def _stash_total(meta_state: Meta, draft_deck: List(DeckEntry)) -> U32:
  _stash_total_from_cards(meta_state, draft_deck, selectable_cards())

def _stash_total_from_cards(meta_state: Meta, draft_deck: List(DeckEntry), cards: List(CardRef)) -> U32:
  match cards:
    case []:
      0
    case card<>rest:
      stash_count(meta_state, draft_deck, card) + _stash_total_from_cards(meta_state, draft_deck, rest)

def _deckbuilder_transfer_controls() -> HTML(DungeonEvent):
  <div class="deckbuilder-transfer">
    {_transfer_button(">", deckbuilder_remove_one{})}
    {_transfer_button(">>", deckbuilder_remove_all{})}
    {_transfer_button("<", deckbuilder_add_one{})}
    {_transfer_button("<<", deckbuilder_add_all{})}
  </div>

def _transfer_button(label: String, evt: DungeonEvent) -> HTML(DungeonEvent):
  <div class="deckbuilder-transfer__btn-wrap">
    {button_secondary(DungeonEvent, evt, medium{}, label, [width_fit{}])}
  </div>

def _deckbuilder_footer(draft_deck: List(DeckEntry)) -> HTML(DungeonEvent):
  ready = deck_total_ready(draft_deck);
  <div class="deckbuilder-footer-layout">
    <div class="deckbuilder-footer">
      <p class="deckbuilder-footer__note">{text{_save_note(draft_deck)}}</p>
      <div class="deckbuilder-save-wrap">
        {button_primary(DungeonEvent, _save_event(ready), large{}, "SAVE", _deckbuilder_save_overrides(ready))}
      </div>
    </div>
  </div>

def _save_note(draft_deck: List(DeckEntry)) -> String:
  match deck_total_ready(draft_deck):
    case 1:
      "Deck pronto para salvar."
    case _:
      "Deck deve ter exatamente 20 cartas."

def _deck_cards_label(draft_deck: List(DeckEntry)) -> String:
  U32/show(deck_total(draft_deck)) ++ "/" ++ U32/show(deckbuilder_target_count()) ++ " cards"

def _deckbuilder_back_button() -> HTML(DungeonEvent):
  <div class="deckbuilder-back-wrap">
    {button_secondary(DungeonEvent, close_deckbuilder{}, small{}, "VOLTAR", [width_fit{}])}
  </div>

def _deckbuilder_button_overrides(enabled: U32) -> List(Midum/Button/Override):
  match enabled:
    case 0:
      [width_fit{}, state_disabled{}]
    case _:
      [width_fit{}]

def _deckbuilder_save_overrides(enabled: U32) -> List(Midum/Button/Override):
  match enabled:
    case 0:
      [width_fit{}, state_disabled{}]
    case _:
      [width_fit{}]

def _save_event(ready: U32) -> DungeonEvent:
  match ready:
    case 1:
      save_deckbuilder{}
    case _:
      ignore{}

def _mode_chip_class(label: String) -> String:
  match label:
    case "Casual":
      "deckbuilder-mode deckbuilder-mode--casual"
    case "Veterano":
      "deckbuilder-mode deckbuilder-mode--veterano"
    case _:
      "deckbuilder-mode deckbuilder-mode--insalubre"
