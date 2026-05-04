import Dungeon/Meta as Meta
import Dungeon/DeckEntry as DeckEntry
import Dungeon/DeckbuilderSelection as DeckbuilderSelection
import Dungeon/CardRef as CardRef
import Dungeon/UiState as UiState
import Dungeon/DungeonEvent as DungeonEvent
import Dungeon/DungeonState as DungeonState
import Dungeon/default_ui as default_ui
import Dungeon/App/state_helpers/_state as _state
import Dungeon/deckbuilder_helpers/card_ref_eq as card_ref_eq
import Dungeon/profile_helpers/set_meta_selected_deck as set_meta_selected_deck
import Dungeon/profile_helpers/meta_selected_deck as meta_selected_deck
import Dungeon/deckbuilder_helpers/add_all_to_draft as add_all_to_draft
import Dungeon/deckbuilder_helpers/add_one_to_draft as add_one_to_draft
import Dungeon/Deck/counts_pick/deck_count_for_card as deck_count_for_card
import Dungeon/deckbuilder_helpers/deck_list_count as deck_list_count
import Dungeon/deckbuilder_helpers/deck_total_ready as deck_total_ready
import Dungeon/deckbuilder_helpers/remove_all_from_draft as remove_all_from_draft
import Dungeon/deckbuilder_helpers/remove_one_from_draft as remove_one_from_draft
import Dungeon/deckbuilder_helpers/selectable_cards as selectable_cards
import Dungeon/deckbuilder_helpers/stash_count as stash_count
import Dungeon/deckbuilder_helpers/stash_list_count as stash_list_count

def deckbuilder_visible_rows() -> U32:
  6

def update_deckbuilder(evt: DungeonEvent, meta_state: Meta, draft_deck: List(DeckEntry), deck_selection: DeckbuilderSelection, stash_selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match evt:
    case close_deckbuilder{}:
      _state(meta_state, setup{}, next_seed_value, default_ui())
    case save_deckbuilder{}:
      _save_deck(meta_state, draft_deck, next_seed_value, ui_value)
    case deckbuilder_toggle_list{}:
      _toggle_active_list(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value)
    case deckbuilder_select_deck{card}:
      _activate_deck_selection(meta_state, draft_deck, deckbuilder_selection{card}, deck_scroll, stash_scroll, next_seed_value, ui_value)
    case deckbuilder_select_stash{card}:
      _activate_stash_selection(meta_state, draft_deck, deckbuilder_selection{card}, deck_scroll, stash_scroll, next_seed_value, ui_value)
    case deckbuilder_scroll_deck_up{}:
      _deckbuilder_state(meta_state, draft_deck, deck_selection, stash_selection, _scroll_up(deck_scroll), stash_scroll, next_seed_value, ui_value)
    case deckbuilder_scroll_deck_down{}:
      _deckbuilder_state(meta_state, draft_deck, deck_selection, stash_selection, _scroll_down(deck_scroll, deck_list_count(draft_deck)), stash_scroll, next_seed_value, ui_value)
    case deckbuilder_scroll_stash_up{}:
      _deckbuilder_state(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, _scroll_up(stash_scroll), next_seed_value, ui_value)
    case deckbuilder_scroll_stash_down{}:
      _deckbuilder_state(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, _scroll_down(stash_scroll, stash_list_count(meta_state, draft_deck)), next_seed_value, ui_value)
    case deckbuilder_add_one{}:
      _update_draft(meta_state, _selection_card(stash_selection), draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value, add_one_action{})
    case deckbuilder_add_all{}:
      _update_draft(meta_state, _selection_card(stash_selection), draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value, add_all_action{})
    case deckbuilder_remove_one{}:
      _update_draft(meta_state, _selection_card(deck_selection), draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value, remove_one_action{})
    case deckbuilder_remove_all{}:
      _update_draft(meta_state, _selection_card(deck_selection), draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value, remove_all_action{})
    case move{up{}}:
      _move_selection(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value, previous_selection{})
    case move{down{}}:
      _move_selection(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value, next_selection{})
    case move{left{}}:
      _move_left(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value)
    case move{right{}}:
      _move_right(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value)
    case _:
      _deckbuilder_state(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value)

type DeckbuilderAction {
  add_one_action{}
  add_all_action{}
  remove_one_action{}
  remove_all_action{}
}

type DeckbuilderFocus {
  deck_focus{}
  stash_focus{}
}

type DeckbuilderSelectionStep {
  previous_selection{}
  next_selection{}
}

type CardIndex {
  no_card_index{}
  card_index{value: U32}
}

def _selection_card(selection: DeckbuilderSelection) -> DeckbuilderSelection:
  selection

def _update_draft(meta_state: Meta, selection: DeckbuilderSelection, draft_deck: List(DeckEntry), deck_selection: DeckbuilderSelection, stash_selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32, next_seed_value: U32, ui_value: UiState, action: DeckbuilderAction) -> DungeonState:
  match _valid_action_selection(meta_state, draft_deck, selection, action):
    case no_deckbuilder_selection{}:
      _deckbuilder_state(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value)
    case deckbuilder_selection{card}:
      _update_draft_card(meta_state, card, draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value, action)

def _update_draft_card(meta_state: Meta, card: CardRef, draft_deck: List(DeckEntry), deck_selection: DeckbuilderSelection, stash_selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32, next_seed_value: U32, ui_value: UiState, action: DeckbuilderAction) -> DungeonState:
  next_draft = _apply_draft_action(meta_state, card, draft_deck, action);
  _state_after_action(meta_state, next_draft, card, deck_scroll, stash_scroll, next_seed_value, ui_value, action)

def _apply_draft_action(meta_state: Meta, card: CardRef, draft_deck: List(DeckEntry), action: DeckbuilderAction) -> List(DeckEntry):
  match action:
    case add_one_action{}:
      add_one_to_draft(meta_state, draft_deck, card)
    case add_all_action{}:
      add_all_to_draft(meta_state, draft_deck, card)
    case remove_one_action{}:
      remove_one_from_draft(draft_deck, card)
    case remove_all_action{}:
      remove_all_from_draft(draft_deck, card)

def _save_deck(meta_state: Meta, draft_deck: List(DeckEntry), next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match deck_total_ready(draft_deck):
    case 1:
      _state(set_meta_selected_deck(meta_state, draft_deck), setup{}, next_seed_value, default_ui())
    case _:
      _deckbuilder_state(meta_state, draft_deck, no_deckbuilder_selection{}, no_deckbuilder_selection{}, 0, 0, next_seed_value, ui_value)

def _deckbuilder_state(meta_state: Meta, draft_deck: List(DeckEntry), deck_selection: DeckbuilderSelection, stash_selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  next_deck_selection = _normalize_selection(meta_state, draft_deck, deck_selection, deck_focus{});
  next_stash_selection = _normalize_selection(meta_state, draft_deck, stash_selection, stash_focus{});
  _state(
    meta_state,
    deckbuilder{
      draft_deck,
      next_deck_selection,
      next_stash_selection,
      _normalize_scroll(deck_scroll, deck_list_count(draft_deck)),
      _normalize_scroll(stash_scroll, stash_list_count(meta_state, draft_deck))
    },
    next_seed_value,
    ui_value
  )

def initial_deckbuilder_state(meta_state: Meta, next_seed_value: U32) -> DungeonState:
  draft_deck = meta_selected_deck(meta_state);
  _state(meta_state, deckbuilder{draft_deck, no_deckbuilder_selection{}, no_deckbuilder_selection{}, 0, 0}, next_seed_value, default_ui())

def _move_selection(meta_state: Meta, draft_deck: List(DeckEntry), deck_selection: DeckbuilderSelection, stash_selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32, next_seed_value: U32, ui_value: UiState, step: DeckbuilderSelectionStep) -> DungeonState:
  match _active_focus(deck_selection, stash_selection):
    case deck_focus{}:
      _move_list_selection(meta_state, draft_deck, deck_selection, deck_focus{}, deck_scroll, stash_scroll, next_seed_value, ui_value, step)
    case stash_focus{}:
      _move_list_selection(meta_state, draft_deck, stash_selection, stash_focus{}, stash_scroll, deck_scroll, next_seed_value, ui_value, step)

def _move_list_selection(meta_state: Meta, draft_deck: List(DeckEntry), selection: DeckbuilderSelection, focus: DeckbuilderFocus, active_scroll: U32, other_scroll: U32, next_seed_value: U32, ui_value: UiState, step: DeckbuilderSelectionStep) -> DungeonState:
  cards = _visible_cards(meta_state, draft_deck, focus, selectable_cards());
  next_selection = _step_selection(cards, selection, step);
  next_scroll = _scroll_for_selection(active_scroll, cards, next_selection);
  _state_for_focus(meta_state, draft_deck, focus, next_selection, next_scroll, other_scroll, next_seed_value, ui_value)

def _move_left(meta_state: Meta, draft_deck: List(DeckEntry), deck_selection: DeckbuilderSelection, stash_selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match _active_focus(deck_selection, stash_selection):
    case stash_focus{}:
      _update_draft(meta_state, _selection_card(stash_selection), draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value, add_one_action{})
    case _:
      _deckbuilder_state(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value)

def _move_right(meta_state: Meta, draft_deck: List(DeckEntry), deck_selection: DeckbuilderSelection, stash_selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match _active_focus(deck_selection, stash_selection):
    case deck_focus{}:
      _update_draft(meta_state, _selection_card(deck_selection), draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value, remove_one_action{})
    case _:
      _deckbuilder_state(meta_state, draft_deck, deck_selection, stash_selection, deck_scroll, stash_scroll, next_seed_value, ui_value)

def _toggle_active_list(meta_state: Meta, draft_deck: List(DeckEntry), deck_selection: DeckbuilderSelection, stash_selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match _active_focus(deck_selection, stash_selection):
    case deck_focus{}:
      _activate_stash_selection(meta_state, draft_deck, _preferred_target_selection(meta_state, draft_deck, stash_selection, deck_selection, stash_focus{}), deck_scroll, stash_scroll, next_seed_value, ui_value)
    case stash_focus{}:
      _activate_deck_selection(meta_state, draft_deck, _preferred_target_selection(meta_state, draft_deck, deck_selection, stash_selection, deck_focus{}), deck_scroll, stash_scroll, next_seed_value, ui_value)

def _activate_deck_selection(meta_state: Meta, draft_deck: List(DeckEntry), selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  cards = _visible_cards(meta_state, draft_deck, deck_focus{}, selectable_cards());
  next_selection = _preferred_or_first_selection(cards, selection);
  _deckbuilder_state(
    meta_state,
    draft_deck,
    next_selection,
    no_deckbuilder_selection{},
    _scroll_for_selection(deck_scroll, cards, next_selection),
    stash_scroll,
    next_seed_value,
    ui_value
  )

def _activate_stash_selection(meta_state: Meta, draft_deck: List(DeckEntry), selection: DeckbuilderSelection, deck_scroll: U32, stash_scroll: U32, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  cards = _visible_cards(meta_state, draft_deck, stash_focus{}, selectable_cards());
  next_selection = _preferred_or_first_selection(cards, selection);
  _deckbuilder_state(
    meta_state,
    draft_deck,
    no_deckbuilder_selection{},
    next_selection,
    deck_scroll,
    _scroll_for_selection(stash_scroll, cards, next_selection),
    next_seed_value,
    ui_value
  )

def _active_focus(deck_selection: DeckbuilderSelection, stash_selection: DeckbuilderSelection) -> DeckbuilderFocus:
  match deck_selection:
    case deckbuilder_selection{card}:
      deck_focus{}
    case _:
      match stash_selection:
        case deckbuilder_selection{card}:
          stash_focus{}
        case _:
          stash_focus{}

def _valid_action_selection(meta_state: Meta, draft_deck: List(DeckEntry), selection: DeckbuilderSelection, action: DeckbuilderAction) -> DeckbuilderSelection:
  match action:
    case add_one_action{}:
      _normalize_selection(meta_state, draft_deck, selection, stash_focus{})
    case add_all_action{}:
      _normalize_selection(meta_state, draft_deck, selection, stash_focus{})
    case remove_one_action{}:
      _normalize_selection(meta_state, draft_deck, selection, deck_focus{})
    case remove_all_action{}:
      _normalize_selection(meta_state, draft_deck, selection, deck_focus{})

def _state_after_action(meta_state: Meta, draft_deck: List(DeckEntry), card: CardRef, deck_scroll: U32, stash_scroll: U32, next_seed_value: U32, ui_value: UiState, action: DeckbuilderAction) -> DungeonState:
  match action:
    case add_one_action{}:
      _activate_stash_selection(meta_state, draft_deck, deckbuilder_selection{card}, deck_scroll, stash_scroll, next_seed_value, ui_value)
    case add_all_action{}:
      _activate_stash_selection(meta_state, draft_deck, deckbuilder_selection{card}, deck_scroll, stash_scroll, next_seed_value, ui_value)
    case remove_one_action{}:
      _activate_deck_selection(meta_state, draft_deck, deckbuilder_selection{card}, deck_scroll, stash_scroll, next_seed_value, ui_value)
    case remove_all_action{}:
      _activate_deck_selection(meta_state, draft_deck, deckbuilder_selection{card}, deck_scroll, stash_scroll, next_seed_value, ui_value)

def _normalize_selection(meta_state: Meta, draft_deck: List(DeckEntry), selection: DeckbuilderSelection, focus: DeckbuilderFocus) -> DeckbuilderSelection:
  match selection:
    case no_deckbuilder_selection{}:
      no_deckbuilder_selection{}
    case deckbuilder_selection{card}:
      _normalize_selection_card(meta_state, draft_deck, card, focus)

def _normalize_selection_card(meta_state: Meta, draft_deck: List(DeckEntry), card: CardRef, focus: DeckbuilderFocus) -> DeckbuilderSelection:
  match _card_count_in_focus(meta_state, draft_deck, card, focus):
    case 0:
      no_deckbuilder_selection{}
    case _:
      deckbuilder_selection{card}

def _preferred_target_selection(meta_state: Meta, draft_deck: List(DeckEntry), target_selection: DeckbuilderSelection, source_selection: DeckbuilderSelection, focus: DeckbuilderFocus) -> DeckbuilderSelection:
  target_cards = _visible_cards(meta_state, draft_deck, focus, selectable_cards());
  match _normalize_selection(meta_state, draft_deck, target_selection, focus):
    case deckbuilder_selection{card}:
      deckbuilder_selection{card}
    case _:
      _preferred_or_first_selection(target_cards, source_selection)

def _preferred_or_first_selection(cards: List(CardRef), preferred: DeckbuilderSelection) -> DeckbuilderSelection:
  match preferred:
    case deckbuilder_selection{card}:
      match _card_in_list(cards, card):
        case 1:
          deckbuilder_selection{card}
        case _:
          _first_selection(cards)
    case _:
      _first_selection(cards)

def _state_for_focus(meta_state: Meta, draft_deck: List(DeckEntry), focus: DeckbuilderFocus, selection: DeckbuilderSelection, active_scroll: U32, other_scroll: U32, next_seed_value: U32, ui_value: UiState) -> DungeonState:
  match focus:
    case deck_focus{}:
      _deckbuilder_state(meta_state, draft_deck, selection, no_deckbuilder_selection{}, active_scroll, other_scroll, next_seed_value, ui_value)
    case stash_focus{}:
      _deckbuilder_state(meta_state, draft_deck, no_deckbuilder_selection{}, selection, other_scroll, active_scroll, next_seed_value, ui_value)

def _visible_cards(meta_state: Meta, draft_deck: List(DeckEntry), focus: DeckbuilderFocus, cards: List(CardRef)) -> List(CardRef):
  match cards:
    case []:
      []
    case card<>rest:
      _visible_cards_step(meta_state, draft_deck, focus, card, rest, _card_count_in_focus(meta_state, draft_deck, card, focus))

def _visible_cards_step(meta_state: Meta, draft_deck: List(DeckEntry), focus: DeckbuilderFocus, card: CardRef, rest: List(CardRef), count: U32) -> List(CardRef):
  match count:
    case 0:
      _visible_cards(meta_state, draft_deck, focus, rest)
    case _:
      card<>_visible_cards(meta_state, draft_deck, focus, rest)

def _card_count_in_focus(meta_state: Meta, draft_deck: List(DeckEntry), card: CardRef, focus: DeckbuilderFocus) -> U32:
  match focus:
    case deck_focus{}:
      deck_count_for_card(draft_deck, card)
    case stash_focus{}:
      stash_count(meta_state, draft_deck, card)

def _step_selection(cards: List(CardRef), selection: DeckbuilderSelection, step: DeckbuilderSelectionStep) -> DeckbuilderSelection:
  match selection:
    case deckbuilder_selection{card}:
      _step_selection_card(cards, card, step)
    case _:
      _step_selection_fallback(cards, step)

def _step_selection_card(cards: List(CardRef), card: CardRef, step: DeckbuilderSelectionStep) -> DeckbuilderSelection:
  match step:
    case previous_selection{}:
      _selection_or_fallback(_previous_selection(cards, card, no_deckbuilder_selection{}), _last_selection(cards))
    case next_selection{}:
      _selection_or_fallback(_next_selection(cards, card), _first_selection(cards))

def _step_selection_fallback(cards: List(CardRef), step: DeckbuilderSelectionStep) -> DeckbuilderSelection:
  match step:
    case previous_selection{}:
      _last_selection(cards)
    case next_selection{}:
      _first_selection(cards)

def _next_selection(cards: List(CardRef), current: CardRef) -> DeckbuilderSelection:
  match cards:
    case []:
      no_deckbuilder_selection{}
    case card<>rest:
      match card_ref_eq(card, current):
        case 1:
          _next_selection_match(rest, current)
        case _:
          _next_selection(rest, current)

def _next_selection_match(rest: List(CardRef), current: CardRef) -> DeckbuilderSelection:
  match rest:
    case []:
      deckbuilder_selection{current}
    case card<>tail:
      deckbuilder_selection{card}

def _previous_selection(cards: List(CardRef), current: CardRef, previous: DeckbuilderSelection) -> DeckbuilderSelection:
  match cards:
    case []:
      no_deckbuilder_selection{}
    case card<>rest:
      match card_ref_eq(card, current):
        case 1:
          _previous_selection_match(previous, current)
        case _:
          _previous_selection(rest, current, deckbuilder_selection{card})

def _previous_selection_match(previous: DeckbuilderSelection, current: CardRef) -> DeckbuilderSelection:
  match previous:
    case no_deckbuilder_selection{}:
      deckbuilder_selection{current}
    case deckbuilder_selection{card}:
      deckbuilder_selection{card}

def _selection_or_fallback(selection: DeckbuilderSelection, fallback: DeckbuilderSelection) -> DeckbuilderSelection:
  match selection:
    case no_deckbuilder_selection{}:
      fallback
    case deckbuilder_selection{card}:
      deckbuilder_selection{card}

def _first_selection(cards: List(CardRef)) -> DeckbuilderSelection:
  match cards:
    case []:
      no_deckbuilder_selection{}
    case card<>rest:
      deckbuilder_selection{card}

def _last_selection(cards: List(CardRef)) -> DeckbuilderSelection:
  match cards:
    case []:
      no_deckbuilder_selection{}
    case card<>rest:
      _last_selection_match(_last_selection(rest), card)

def _last_selection_match(last: DeckbuilderSelection, card: CardRef) -> DeckbuilderSelection:
  match last:
    case no_deckbuilder_selection{}:
      deckbuilder_selection{card}
    case deckbuilder_selection{selected_card}:
      deckbuilder_selection{selected_card}

def _card_in_list(cards: List(CardRef), target: CardRef) -> U32:
  match cards:
    case []:
      0
    case card<>rest:
      match card_ref_eq(card, target):
        case 1:
          1
        case _:
          _card_in_list(rest, target)

def _scroll_for_selection(scroll: U32, cards: List(CardRef), selection: DeckbuilderSelection) -> U32:
  total = _card_list_size(cards);
  match _selection_index(cards, selection):
    case no_card_index{}:
      _normalize_scroll(scroll, total)
    case card_index{value}:
      _scroll_for_index(scroll, value, total)

def _selection_index(cards: List(CardRef), selection: DeckbuilderSelection) -> CardIndex:
  match selection:
    case no_deckbuilder_selection{}:
      no_card_index{}
    case deckbuilder_selection{card}:
      _card_index(cards, card, 0)

def _card_index(cards: List(CardRef), target: CardRef, index: U32) -> CardIndex:
  match cards:
    case []:
      no_card_index{}
    case card<>rest:
      match card_ref_eq(card, target):
        case 1:
          card_index{index}
        case _:
          _card_index(rest, target, index + 1)

def _scroll_for_index(scroll: U32, index: U32, total: U32) -> U32:
  current = _normalize_scroll(scroll, total);
  visible = deckbuilder_visible_rows();
  match index < current:
    case 1:
      index
    case _:
      match index < current + visible:
        case 1:
          current
        case _:
          _normalize_scroll(index + 1 - visible, total)

def _card_list_size(cards: List(CardRef)) -> U32:
  match cards:
    case []:
      0
    case card<>rest:
      1 + _card_list_size(rest)

def _scroll_up(scroll: U32) -> U32:
  match scroll:
    case 0:
      0
    case _:
      scroll - 1

def _scroll_down(scroll: U32, total: U32) -> U32:
  max_scroll = _max_scroll(total);
  match scroll < max_scroll:
    case 1:
      scroll + 1
    case _:
      max_scroll

def _normalize_scroll(scroll: U32, total: U32) -> U32:
  max_scroll = _max_scroll(total);
  match scroll < max_scroll:
    case 1:
      scroll
    case _:
      max_scroll

def _max_scroll(total: U32) -> U32:
  visible = deckbuilder_visible_rows();
  match total <= visible:
    case 1:
      0
    case _:
      total - visible
