def deck_detail() -> Unit:
  unit{}

import HTML as HTML
import Dungeon/game_config as config
import Dungeon as Dungeon
import Dungeon/View/topbar_stats as M__Dungeon_View_topbar_stats
import Dungeon/View/selectors as M__Dungeon_View_selectors
import Dungeon/View/action_button as M__Dungeon_View_action_button
import Dungeon/View/deck_chrome as M__Dungeon_View_deck_chrome
import Dungeon/View/deck_sleeve_picker as M__Dungeon_View_deck_sleeve_picker
import Dungeon/View/deck_card_tile as M__Dungeon_View_deck_card_tile
import Midum/Card as M__Midum_Card
import Midum/Layout as M__Midum_Layout
import Dungeon/profile_helpers as M__Dungeon_profile_helpers
import Dungeon/Deck/draft_ops as M__Dungeon_Deck_draft_ops
import Dungeon/Deck/quotas as M__Dungeon_Deck_quotas
import Dungeon/Deck/card_collection as M__Dungeon_Deck_card_collection
import Dungeon/Deck/deck_validation as M__Dungeon_Deck_deck_validation

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

def _mobile_back(picker: Dungeon/DeckPickerMode) -> Dungeon/DungeonEvent:
  match picker:
    case picker_open{category}:
      close_category_picker{}
    case picker_none{}:
      request_close_deck_detail{}

def _trailing(meta_state: Dungeon/Meta) -> HTML(Dungeon/DungeonEvent):
  <div class="deck-chrome-trailing">
    {Dungeon/View/topbar_stats/boosters_stat(Dungeon/View/selectors/meta_pack_total(meta_state))}
    {Dungeon/View/topbar_stats/gold_stat(Dungeon/View/selectors/meta_gold(meta_state))}
  </div>

def _progress_text(used: U32, cap: U32) -> String:
  match used < cap:
    case 1:
      "Filling slot " ++ U32/show(used + 1) ++ "/" ++ U32/show(cap)
    case _:
      "Full · tap a card twice to remove"

def _upper_label(cat: Dungeon/DeckCategory) -> String:
  match cat:
    case cat_monsters{}:
      "MONSTER"
    case cat_swords{}:
      "SWORD"
    case cat_potions{}:
      "POTION"
    case cat_hero{}:
      "HERO"

def _picker_title_block(draft: Dungeon/DeckDraft, cat: Dungeon/DeckCategory) -> HTML(Dungeon/DungeonEvent):
  used = Dungeon/Deck/quotas/category_count(Dungeon/Deck/draft_ops/draft_entries(draft), cat);
  cap = Dungeon/Deck/quotas/quota_for_category(Dungeon/Deck/quotas/deck_quotas_default(), cat);
  <div class="deck-detail__picker-title-block">
    <span class="deck-detail__picker-title">{text{"YOUR " ++ _upper_label(cat) ++ " CARDS"}}</span>
    <span class="deck-detail__picker-progress">{text{_progress_text(used, cap)}}</span>
  </div>

def _mobile_title(meta_state: Dungeon/Meta, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode) -> HTML(Dungeon/DungeonEvent):
  match picker:
    case picker_open{category}:
      _picker_title_block(draft, category)
    case picker_none{}:
      _trailing(meta_state)

def _save_action(valid: U32, dirty: U32) -> List(HTML(Dungeon/DungeonEvent)):
  match dirty:
    case 0:
      []
    case _:
      [Dungeon/View/action_button/primary_full(Dungeon/DungeonEvent, save_deck_changes{}, "SAVE", valid)]

def _and(a: U32, b: U32) -> U32:
  match a:
    case 0:
      0
    case _:
      b

def _not(a: U32) -> U32:
  match a:
    case 0:
      1
    case _:
      0

def _set_active_visible(valid: U32, dirty: U32, is_active: U32) -> U32:
  match is_active:
    case 1:
      0
    case _:
      _and(valid, _not(dirty))

def _set_active_action(deck_id: U32, valid: U32, dirty: U32, is_active: U32) -> List(HTML(Dungeon/DungeonEvent)):
  match _set_active_visible(valid, dirty, is_active):
    case 0:
      []
    case _:
      [Dungeon/View/action_button/secondary_full(Dungeon/DungeonEvent, set_active_deck{deck_id}, "SET ACTIVE", 1)]

def _concat_html(a: List(HTML(Dungeon/DungeonEvent)), b: List(HTML(Dungeon/DungeonEvent))) -> List(HTML(Dungeon/DungeonEvent)):
  match a:
    case []:
      b
    case head<>rest:
      head<>_concat_html(rest, b)

def _main_actions(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft) -> List(HTML(Dungeon/DungeonEvent)):
  valid = Dungeon/Deck/deck_validation/is_deck_valid(config(), meta_state, Dungeon/Deck/draft_ops/draft_entries(draft));
  dirty = Dungeon/Deck/draft_ops/draft_dirty(draft);
  is_active = Dungeon/profile_helpers/meta_active_deck_id(meta_state) === deck_id;
  _concat_html(_save_action(valid, dirty), _set_active_action(deck_id, valid, dirty, is_active))

def _actions(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode) -> List(HTML(Dungeon/DungeonEvent)):
  match picker:
    case picker_open{category}:
      []
    case picker_none{}:
      _main_actions(meta_state, deck_id, draft)

def _stage_class(picker: Dungeon/DeckPickerMode) -> String:
  match picker:
    case picker_open{category}:
      "deck-stage deck-stage--picker-open"
    case picker_none{}:
      "deck-stage"

def _is_sleeve_picker_open(sleeve_picker: Dungeon/DeckSleevePicker, deck_id: U32) -> U32:
  match sleeve_picker:
    case sleeve_picker_open{open_id}:
      open_id === deck_id
    case sleeve_picker_closed{}:
      0

def _title_row(draft: Dungeon/DeckDraft, sleeve_picker: Dungeon/DeckSleevePicker) -> HTML(Dungeon/DungeonEvent):
  q = Dungeon/Deck/quotas/deck_quotas_default();
  entries = Dungeon/Deck/draft_ops/draft_entries(draft);
  total_q = Dungeon/Deck/quotas/quotas_total(q);
  count_text = U32/show(Dungeon/Deck/deck_validation/deck_total_count(entries)) ++ "/" ++ U32/show(total_q);
  <div class="deck-detail__title-row">
    <div class="deck-detail__deck-name-row">
      <h2 class="deck-detail__deck-name">{text{Dungeon/Deck/draft_ops/draft_name(draft)}}</h2>
      {Dungeon/View/deck_sleeve_picker/render_detail_control(Dungeon/Deck/draft_ops/draft_id(draft), Dungeon/Deck/draft_ops/draft_sleeve(draft), _is_sleeve_picker_open(sleeve_picker, Dungeon/Deck/draft_ops/draft_id(draft)))}
    </div>
    <span class="deck-detail__deck-count">{text{"DECK " ++ count_text}}</span>
  </div>

def _main_class(picker: Dungeon/DeckPickerMode) -> String:
  match picker:
    case picker_open{category}:
      "deck-detail__main deck-detail__main--picker-open"
    case picker_none{}:
      "deck-detail__main"

def _side_class(picker: Dungeon/DeckPickerMode) -> String:
  match picker:
    case picker_open{category}:
      "deck-detail__side deck-detail__side--picker-open"
    case picker_none{}:
      "deck-detail__side"

def _is_monsters(c: Dungeon/DeckCategory) -> U32:
  match c:
    case cat_monsters{}:
      1
    case _:
      0

def _is_swords(c: Dungeon/DeckCategory) -> U32:
  match c:
    case cat_swords{}:
      1
    case _:
      0

def _is_potions(c: Dungeon/DeckCategory) -> U32:
  match c:
    case cat_potions{}:
      1
    case _:
      0

def _is_hero(c: Dungeon/DeckCategory) -> U32:
  match c:
    case cat_hero{}:
      1
    case _:
      0

def _category_eq(a: Dungeon/DeckCategory, b: Dungeon/DeckCategory) -> U32:
  match a:
    case cat_monsters{}:
      _is_monsters(b)
    case cat_swords{}:
      _is_swords(b)
    case cat_potions{}:
      _is_potions(b)
    case cat_hero{}:
      _is_hero(b)

def _is_target_section(picker: Dungeon/DeckPickerMode, cat: Dungeon/DeckCategory) -> U32:
  match picker:
    case picker_none{}:
      0
    case picker_open{category}:
      _category_eq(category, cat)

def _saturating_sub(a: U32, b: U32) -> U32:
  match a < b:
    case 1:
      0
    case _:
      a - b

def _card_ref_eq_local(left: Dungeon/CardRef, right: Dungeon/CardRef) -> U32:
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

def _is_armed(detail_mode: Dungeon/DeckDetailMode, card: Dungeon/CardRef, occurrence: U32) -> U32:
  match detail_mode:
    case detail_pending_delete{armed, armed_occurrence}:
      _and(_card_ref_eq_local(armed, card), armed_occurrence === occurrence)
    case _:
      0

def _filled_modifier(detail_mode: Dungeon/DeckDetailMode, card: Dungeon/CardRef, occurrence: U32) -> String:
  match _is_armed(detail_mode, card, occurrence):
    case 0:
      " deck-tile--filled"
    case _:
      " deck-tile--filled deck-tile--armed"

def _filled_tile(card: Dungeon/CardRef, occurrence: U32, detail_mode: Dungeon/DeckDetailMode) -> HTML(Dungeon/DungeonEvent):
  Dungeon/View/deck_card_tile/render_tile(card, _filled_modifier(detail_mode, card, occurrence), "", remove_card_from_deck{card, occurrence})

def _repeat_tile(card: Dungeon/CardRef, count: U32, occurrence: U32, detail_mode: Dungeon/DeckDetailMode) -> List(HTML(Dungeon/DungeonEvent)):
  match count:
    case 0:
      []
    case _:
      _filled_tile(card, occurrence, detail_mode)<>_repeat_tile(card, count - 1, occurrence + 1, detail_mode)

def _entry_to_tiles(entry: Dungeon/DeckEntry, detail_mode: Dungeon/DeckDetailMode) -> List(HTML(Dungeon/DungeonEvent)):
  _repeat_tile(Dungeon/Deck/card_collection/entry_card_ref(entry), Dungeon/Deck/card_collection/entry_count(entry), 0, detail_mode)

def _filled_slots(entries: List(Dungeon/DeckEntry), detail_mode: Dungeon/DeckDetailMode) -> List(HTML(Dungeon/DungeonEvent)):
  match entries:
    case []:
      []
    case current<>rest:
      _concat_html(_entry_to_tiles(current, detail_mode), _filled_slots(rest, detail_mode))

def _rest_empty_slots(count: U32, cat: Dungeon/DeckCategory) -> List(HTML(Dungeon/DungeonEvent)):
  match count:
    case 0:
      []
    case _:
      Dungeon/View/deck_card_tile/render_empty(open_category_picker{cat}, "")<>_rest_empty_slots(count - 1, cat)

def _empty_modifier(is_target: U32) -> String:
  match is_target:
    case 0:
      ""
    case _:
      " deck-tile--target"

def _empty_slots(count: U32, cat: Dungeon/DeckCategory, is_target: U32) -> List(HTML(Dungeon/DungeonEvent)):
  match count:
    case 0:
      []
    case _:
      Dungeon/View/deck_card_tile/render_empty(open_category_picker{cat}, _empty_modifier(is_target))<>_rest_empty_slots(count - 1, cat)

def _slots(entries: List(Dungeon/DeckEntry), cat: Dungeon/DeckCategory, used: U32, cap: U32, is_target: U32, detail_mode: Dungeon/DeckDetailMode) -> List(HTML(Dungeon/DungeonEvent)):
  filled = Dungeon/Deck/card_collection/filter_entries_by_category(entries, cat);
  filled_html = _filled_slots(filled, detail_mode);
  empty_count = _saturating_sub(cap, used);
  _concat_html(filled_html, _empty_slots(empty_count, cat, is_target))

def _section_render(meta_state: Dungeon/Meta, entries: List(Dungeon/DeckEntry), cat: Dungeon/DeckCategory, used: U32, cap: U32, is_target: U32, detail_mode: Dungeon/DeckDetailMode) -> HTML(Dungeon/DungeonEvent):
  <section class="deck-section">
    <div class="deck-section__header">
      <button class="deck-section__title" type="button" on_click={open_category_picker{cat}}>
        <span class="deck-section__label">{text{Dungeon/Deck/quotas/category_label(cat)}}</span>
        <span class="deck-section__count">{text{U32/show(used) ++ "/" ++ U32/show(cap)}}</span>
      </button>
    </div>
    <div class="deck-section__grid">
      {..._slots(entries, cat, used, cap, is_target, detail_mode)}
    </div>
  </section>

def _section(meta_state: Dungeon/Meta, entries: List(Dungeon/DeckEntry), q: Dungeon/DeckQuotas, cat: Dungeon/DeckCategory, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode) -> HTML(Dungeon/DungeonEvent):
  used = Dungeon/Deck/quotas/category_count(entries, cat);
  cap = Dungeon/Deck/quotas/quota_for_category(q, cat);
  match cap:
    case 0:
      text{""}
    case _:
      _section_render(meta_state, entries, cat, used, cap, _is_target_section(picker, cat), detail_mode)

def _deck_panel(meta_state: Dungeon/Meta, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode) -> HTML(Dungeon/DungeonEvent):
  q = Dungeon/Deck/quotas/deck_quotas_default();
  entries = Dungeon/Deck/draft_ops/draft_entries(draft);
  <div class="deck-detail__deck-panel">
    {_section(meta_state, entries, q, cat_monsters{}, picker, detail_mode)}
    {_section(meta_state, entries, q, cat_swords{}, picker, detail_mode)}
    {_section(meta_state, entries, q, cat_potions{}, picker, detail_mode)}
    {_section(meta_state, entries, q, cat_hero{}, picker, detail_mode)}
  </div>

def _pool_placeholder() -> HTML(Dungeon/DungeonEvent):
  <div class="deck-pool-empty">
    <p class="deck-pool-empty__text">{text{"Tap a slot to start editing."}}</p>
  </div>

def _list_size_monsters(xs: List(Dungeon/MonsterDef)) -> U32:
  match xs:
    case []:
      0
    case head<>rest:
      1 + _list_size_monsters(rest)

def _count_monsters(cfg: Dungeon/Config) -> U32:
  match cfg:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _list_size_monsters(monsters)

def _monster_count_in_config() -> U32:
  _count_monsters(config())

def _list_size_swords(xs: List(Dungeon/SwordDef)) -> U32:
  match xs:
    case []:
      0
    case head<>rest:
      1 + _list_size_swords(rest)

def _count_swords(cfg: Dungeon/Config) -> U32:
  match cfg:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _list_size_swords(swords)

def _sword_count_in_config() -> U32:
  _count_swords(config())

def _list_size_potions(xs: List(Dungeon/PotionDef)) -> U32:
  match xs:
    case []:
      0
    case head<>rest:
      1 + _list_size_potions(rest)

def _count_potions(cfg: Dungeon/Config) -> U32:
  match cfg:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _list_size_potions(potions)

def _potion_count_in_config() -> U32:
  _count_potions(config())

def _monster_cards_from(idx: U32, n: U32) -> List(Dungeon/CardRef):
  match idx < n:
    case 0:
      []
    case _:
      monster_card{idx}<>_monster_cards_from(idx + 1, n)

def _monster_cards(n: U32) -> List(Dungeon/CardRef):
  _monster_cards_from(0, n)

def _sword_cards_from(idx: U32, n: U32) -> List(Dungeon/CardRef):
  match idx < n:
    case 0:
      []
    case _:
      sword_card{idx}<>_sword_cards_from(idx + 1, n)

def _sword_cards(n: U32) -> List(Dungeon/CardRef):
  _sword_cards_from(0, n)

def _potion_cards_from(idx: U32, n: U32) -> List(Dungeon/CardRef):
  match idx < n:
    case 0:
      []
    case _:
      potion_card{idx}<>_potion_cards_from(idx + 1, n)

def _potion_cards(n: U32) -> List(Dungeon/CardRef):
  _potion_cards_from(0, n)

def _pool_cards_for(cat: Dungeon/DeckCategory) -> List(Dungeon/CardRef):
  match cat:
    case cat_monsters{}:
      _monster_cards(_monster_count_in_config())
    case cat_swords{}:
      _sword_cards(_sword_count_in_config())
    case cat_potions{}:
      _potion_cards(_potion_count_in_config())
    case cat_hero{}:
      [hero_card{}]

def _pool_tile_modifier(available: U32) -> String:
  match available:
    case 0:
      " deck-tile--depleted"
    case _:
      ""

def _pool_click(card: Dungeon/CardRef, available: U32) -> Dungeon/DungeonEvent:
  match available:
    case 0:
      ignore{}
    case _:
      add_card_to_deck{card}

def _pool_tile_visible(card: Dungeon/CardRef, available: U32, pool: U32) -> HTML(Dungeon/DungeonEvent):
  modifier = _pool_tile_modifier(available);
  badge = U32/show(available) ++ "/" ++ U32/show(pool);
  Dungeon/View/deck_card_tile/render_tile(card, modifier, badge, _pool_click(card, available))

def _pool_tile(meta_state: Dungeon/Meta, draft: Dungeon/DeckDraft, card: Dungeon/CardRef) -> HTML(Dungeon/DungeonEvent):
  pool = Dungeon/Deck/card_collection/pool_quantity(meta_state, card);
  available = Dungeon/Deck/card_collection/available_for_add(meta_state, Dungeon/Deck/draft_ops/draft_entries(draft), card);
  match pool:
    case 0:
      text{""}
    case _:
      _pool_tile_visible(card, available, pool)

def _pool_tiles(meta_state: Dungeon/Meta, draft: Dungeon/DeckDraft, cards: List(Dungeon/CardRef)) -> List(HTML(Dungeon/DungeonEvent)):
  match cards:
    case []:
      []
    case current<>rest:
      _pool_tile(meta_state, draft, current)<>_pool_tiles(meta_state, draft, rest)

def _pool_for_category(meta_state: Dungeon/Meta, draft: Dungeon/DeckDraft, cat: Dungeon/DeckCategory) -> HTML(Dungeon/DungeonEvent):
  cards = _pool_cards_for(cat);
  <div class="deck-pool">
    <div class="deck-pool__header">
      <h3 class="deck-pool__title">{text{"your " ++ Dungeon/Deck/quotas/category_label(cat) ++ " cards"}}</h3>
    </div>
    <div class="deck-pool__grid">
      {..._pool_tiles(meta_state, draft, cards)}
    </div>
  </div>

def _picker_panel(meta_state: Dungeon/Meta, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode, cat: Dungeon/DeckCategory) -> HTML(Dungeon/DungeonEvent):
  q = Dungeon/Deck/quotas/deck_quotas_default();
  entries = Dungeon/Deck/draft_ops/draft_entries(draft);
  <div class="deck-picker">
    <div class="deck-picker__preview">
      {_section(meta_state, entries, q, cat, picker, detail_mode)}
    </div>
    <div class="deck-picker__pool">
      {_pool_for_category(meta_state, draft, cat)}
    </div>
  </div>

def _pool_panel(meta_state: Dungeon/Meta, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode) -> HTML(Dungeon/DungeonEvent):
  match picker:
    case picker_none{}:
      _pool_placeholder()
    case picker_open{category}:
      _picker_panel(meta_state, draft, picker, detail_mode, category)

def _main_layout(meta_state: Dungeon/Meta, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode, sleeve_picker: Dungeon/DeckSleevePicker) -> HTML(Dungeon/DungeonEvent):
  <section class="deck-detail">
    {_title_row(draft, sleeve_picker)}
    <div class={_main_class(picker)}>
      {_deck_panel(meta_state, draft, picker, detail_mode)}
    </div>
    <aside class={_side_class(picker)}>
      {_pool_panel(meta_state, draft, picker, detail_mode)}
    </aside>
  </section>

def _discard_modal() -> HTML(Dungeon/DungeonEvent):
  <div class="game-over-modal game-over-modal--visible deck-confirm-modal">
    {Midum/Card/neutral(
      Dungeon/DungeonEvent,
      <div class="game-over-card">
        <p class="game-over-card__eyebrow">{text{"UNSAVED"}}</p>
        <h2 class="game-over-card__title">{text{"Discard changes?"}}</h2>
        <p class="game-over-card__body">{text{"You have unsaved deck edits."}}</p>
        <section class="game-over-card__actions">
          <div class="menu-secondary-action game-over-card__secondary">
            {Dungeon/View/action_button/secondary_full(Dungeon/DungeonEvent, cancel_discard_deck_changes{}, "KEEP EDITING", 1)}
          </div>
          <div class="menu-start-action game-over-card__primary">
            {Dungeon/View/action_button/primary_full(Dungeon/DungeonEvent, discard_deck_changes{}, "DISCARD", 1)}
          </div>
        </section>
      </div>,
      [padding_md{}]
    )}
  </div>

def _modal_layer(detail_mode: Dungeon/DeckDetailMode) -> HTML(Dungeon/DungeonEvent):
  match detail_mode:
    case detail_view{}:
      text{""}
    case detail_confirm_discard{}:
      _discard_modal()
    case detail_pending_delete{card, occurrence}:
      text{""}

def _body(meta_state: Dungeon/Meta, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode, sleeve_picker: Dungeon/DeckSleevePicker) -> HTML(Dungeon/DungeonEvent):
  <section class={_stage_class(picker)}>
    <div class="deck-stage__content">
      {_main_layout(meta_state, draft, picker, detail_mode, sleeve_picker)}
    </div>
    {_modal_layer(detail_mode)}
  </section>

def _render_deck_detail(meta_state: Dungeon/Meta, deck_id: U32, draft: Dungeon/DeckDraft, picker: Dungeon/DeckPickerMode, detail_mode: Dungeon/DeckDetailMode, sleeve_picker: Dungeon/DeckSleevePicker) -> HTML(Dungeon/DungeonEvent):
  _shell(
    Midum/Layout/frame(
      Dungeon/DungeonEvent,
      Dungeon/View/deck_chrome/render(
        request_close_deck_detail{},
        _mobile_back(picker),
        _trailing(meta_state),
        _mobile_title(meta_state, draft, picker),
        _actions(meta_state, deck_id, draft, picker),
        _body(meta_state, draft, picker, detail_mode, sleeve_picker)
      ),
      [width_full{}, height_full{}, inset_none{}]
    )
  )
