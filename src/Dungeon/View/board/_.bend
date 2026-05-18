def board() -> Unit:
  unit{}

import HTML as HTML
import Dungeon/game_config as config
import Dungeon as Dungeon
import Dungeon/App/ui_fx as M__Dungeon_App_ui_fx
import Dungeon/Content as M__Dungeon_Content
import Dungeon/Board/indexing as M__Dungeon_Board_indexing
import Dungeon/hero_helpers as M__Dungeon_hero_helpers
import Dungeon/profile_helpers as M__Dungeon_profile_helpers
import Dungeon/View/selectors as M__Dungeon_View_selectors
import Dungeon/View/menu as M__Dungeon_View_menu
import Dungeon/View/assets_and_labels as M__Dungeon_View_assets_and_labels
import Dungeon/deck_counter_frames as M__Dungeon_deck_counter_frames
import Dungeon/deck_counter_animation as M__Dungeon_deck_counter_animation
import Dungeon/View/cards as M__Dungeon_View_cards
import Midum/Button as M__Midum_Button
import Midum/Card as M__Midum_Card
import Midum/Grid as M__Midum_Grid
import Midum/Image as M__Midum_Image
import Midum/Layout as M__Midum_Layout

def _dungeon_shell(body: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
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

def _deck_counter_overrides() -> List(Midum/Image/Override):
  []

def _deck_counter_visual(ui_value: Dungeon/UiState) -> HTML(Dungeon/DungeonEvent):
  match ui_value:
    case ui_state{hp_fx, dmg_fx, impact, damage_overlay, deck_counter_fx, menu_background_state}:
      match deck_counter_fx:
        case deck_counter_idle{}:
          <div class="dungeon-resource__deck-visual">
            {Midum/Image/view(Dungeon/DungeonEvent, Dungeon/deck_counter_frames/idle_src(), Dungeon/Content/ui_topbar_cards(), _deck_counter_overrides())}
          </div>
        case deck_counter_playing{deck_counter_state}:
          <div class="dungeon-resource__deck-visual">
            {Midum/Image/animated(Dungeon/DungeonEvent, deck_counter_state, Dungeon/deck_counter_animation/clip(), Dungeon/Content/ui_topbar_cards(), _deck_counter_overrides())}
          </div>

def _dungeon_deck_counter(scene_value: Dungeon/Scene, ui_value: Dungeon/UiState) -> HTML(Dungeon/DungeonEvent):
  <p class="dungeon-resource dungeon-resource--deck">
    {_deck_counter_visual(ui_value)}
    <strong class="dungeon-resource__value">{text{Dungeon/View/selectors/remaining_value(scene_value)}}</strong>
  </p>

def _dungeon_resource(src: String, alt: String, value: String, role_class: String) -> HTML(Dungeon/DungeonEvent):
  <p class={"dungeon-resource " ++ role_class}>
    <img class="dungeon-resource__icon" src={src} alt={alt} />
    <strong class="dungeon-resource__value">{text{value}}</strong>
  </p>

def _dungeon_level(scene_value: Dungeon/Scene) -> HTML(Dungeon/DungeonEvent):
  <div class="dungeon-level">
    <div class="dungeon-level__badge-frame">
      <div class="dungeon-level__badge-art">
        {Midum/Image/view(Dungeon/DungeonEvent, Dungeon/View/assets_and_labels/_dungeon_level_badge_backdrop(), "", [])}
      </div>
      <span class="dungeon-level__badge-text">{text{Dungeon/Content/ui_dungeon_level()}}</span>
    </div>
    <div class="dungeon-level__value-frame">
      <div class="dungeon-level__value-art">
        {Midum/Image/view(Dungeon/DungeonEvent, Dungeon/View/assets_and_labels/_dungeon_level_value_backdrop(), "", [])}
      </div>
      <strong class="dungeon-level__value-text">{text{Dungeon/View/selectors/dungeon_level_value(scene_value)}}</strong>
    </div>
  </div>

def _dungeon_header(meta_state: Dungeon/Meta, scene_value: Dungeon/Scene, ui_value: Dungeon/UiState) -> HTML(Dungeon/DungeonEvent):
  <header class="topbar topbar--dungeon">
    <div class="dungeon-topbar__left">
      {_dungeon_deck_counter(scene_value, ui_value)}
    </div>
    <div class="dungeon-topbar__center">
      {_dungeon_level(scene_value)}
    </div>
    <div class="dungeon-topbar__right">
      {_dungeon_resource(Dungeon/View/assets_and_labels/_gold_icon(), Dungeon/Content/ui_topbar_gold(), Dungeon/View/selectors/meta_gold(meta_state), "dungeon-resource--gold")}
    </div>
  </header>

def _board_class(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case paused{run_value}:
      "board board--over"
    case resume_prompt{run_value}:
      "board board--over"
    case game_over{run_value}:
      "board board--over"
    case _:
      "board"

def _board_idx(x: U32, y: U32) -> U32:
  x + (y * 3)

def _board_card_identity(is_hero: U32, hero_value: Dungeon/HeroDef, hero_hp: U32, hero_max_hp: U32, weapon_value: Dungeon/Weapon, hp_fx: Dungeon/HpFx, dmg_fx: Dungeon/DmgFx, tile_value: Dungeon/Tile, pos: Nat/V2, damage_overlay: Dungeon/DamageOverlay) -> HTML(Dungeon/DungeonEvent):
  match is_hero:
    case 0:
      Dungeon/View/cards/_tile_card(tile_value, pos, damage_overlay)
    case _:
      Dungeon/View/cards/_hero_card_values(hero_value, hero_hp, hero_max_hp, weapon_value, hp_fx, dmg_fx)

def _board_card_at(run_value: Dungeon/Run, ui_value: Dungeon/UiState, hero_value: Dungeon/HeroDef, idx: U32, pos: Nat/V2) -> HTML(Dungeon/DungeonEvent):
  match run_value ui_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref} ui_state{hp_fx, dmg_fx, impact, damage_overlay, deck_counter_fx, menu_background_state}:
      _board_card_identity(hero_index === idx, hero_value, hero_hp, hero_max_hp, weapon, hp_fx, dmg_fx, Dungeon/Board/indexing/board_get(board_value, idx), pos, damage_overlay)

def _board_slot_impact_class(impact_fx: Dungeon/ImpactFx) -> String:
  match impact_fx:
    case impact_hit_a{}:
      "board-slot board-slot--impact-a"
    case impact_hit_b{}:
      "board-slot board-slot--impact-b"
    case impact_kill_a{}:
      "board-slot board-slot--kill-a"
    case impact_kill_b{}:
      "board-slot board-slot--kill-b"

def _board_slot_class_match(matched: U32, impact_fx: Dungeon/ImpactFx) -> String:
  match matched:
    case 0:
      "board-slot"
    case _:
      _board_slot_impact_class(impact_fx)

def _board_slot_class(pos: Nat/V2, impact_value: Dungeon/Impact) -> String:
  match impact_value:
    case no_impact{}:
      "board-slot"
    case impact{impact_pos, fx}:
      _board_slot_class_match(Dungeon/Board/indexing/same_pos(pos, impact_pos), fx)

def _board_slot_node(idx: U32, pos: Nat/V2, impact_value: Dungeon/Impact, body: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
  <div class={_board_slot_class(pos, impact_value)}>
    {body}
  </div>

def _board_slot_at(run_value: Dungeon/Run, ui_value: Dungeon/UiState, hero_value: Dungeon/HeroDef, idx: U32, pos: Nat/V2) -> HTML(Dungeon/DungeonEvent):
  match ui_value:
    case ui_state{hp_fx, dmg_fx, impact_value, damage_overlay, deck_counter_fx, menu_background_state}:
      _board_slot_node(idx, pos, impact_value, _board_card_at(run_value, ui_value, hero_value, idx, pos))

def _board_slot(run_value: Dungeon/Run, ui_value: Dungeon/UiState, hero_value: Dungeon/HeroDef, x: U32, y: U32) -> HTML(Dungeon/DungeonEvent):
  _board_slot_at(run_value, ui_value, hero_value, _board_idx(x, y), Dungeon/Board/indexing/board_xy_pos(x, y))

def _board_grid_cell(run_value: Dungeon/Run, ui_value: Dungeon/UiState, hero_value: Dungeon/HeroDef, x: U32, y: U32) -> Midum/Grid/Cell(Dungeon/DungeonEvent):
  Midum/Grid/cell(
    Dungeon/DungeonEvent,
    _board_slot(run_value, ui_value, hero_value, x, y),
    [
      trap_border_color{value: "rgba(255,255,255,0.82)"},
      trap_border_width_px{value: 1n},
      trap_fill_color{value: "transparent"}
    ]
  )

def _board_grid(scene_value: Dungeon/Scene, run_value: Dungeon/Run, ui_value: Dungeon/UiState, hero_value: Dungeon/HeroDef) -> HTML(Dungeon/DungeonEvent):
  <div class={_board_class(scene_value)}>
    {Midum/Grid/view(
      Dungeon/DungeonEvent,
      [
        _board_grid_cell(run_value, ui_value, hero_value, 0, 0),
        _board_grid_cell(run_value, ui_value, hero_value, 1, 0),
        _board_grid_cell(run_value, ui_value, hero_value, 2, 0),
        _board_grid_cell(run_value, ui_value, hero_value, 0, 1),
        _board_grid_cell(run_value, ui_value, hero_value, 1, 1),
        _board_grid_cell(run_value, ui_value, hero_value, 2, 1),
        _board_grid_cell(run_value, ui_value, hero_value, 0, 2),
        _board_grid_cell(run_value, ui_value, hero_value, 1, 2),
        _board_grid_cell(run_value, ui_value, hero_value, 2, 2)
      ],
      [
        perspective{value: 16n},
        grid_gap_x{value: 43n},
        grid_gap_y{value: 120n},
        max_transfer{value: 40n}
      ]
    )}
  </div>

def _ultimate_button(scene_value: Dungeon/Scene) -> HTML(Dungeon/DungeonEvent):
  Midum/Button/primary(
    Dungeon/DungeonEvent,
    ultimate{},
    large{},
    Dungeon/View/selectors/ultimate_label(scene_value),
    Dungeon/View/menu/_full_button_overrides(Dungeon/View/selectors/ultimate_enabled(scene_value))
  )

def _ultimate_action(scene_value: Dungeon/Scene) -> HTML(Dungeon/DungeonEvent):
  <div class="ultimate-action">
    {_ultimate_button(scene_value)}
  </div>

def _pause_button() -> HTML(Dungeon/DungeonEvent):
  Midum/Button/secondary(Dungeon/DungeonEvent, pause_dungeon{}, small{}, Dungeon/Content/ui_dungeon_pause(), [])

def _pause_action(scene_value: Dungeon/Scene) -> HTML(Dungeon/DungeonEvent):
  match scene_value:
    case running{run_value}:
      <div class="dungeon-pause-action">
        {_pause_button()}
      </div>
    case _:
      text{""}

def _pause_resume_button() -> HTML(Dungeon/DungeonEvent):
  Midum/Button/primary(Dungeon/DungeonEvent, resume_dungeon{}, large{}, Dungeon/Content/ui_pause_resume(), [width_full{}])

def _resume_menu_button() -> HTML(Dungeon/DungeonEvent):
  Midum/Button/secondary(Dungeon/DungeonEvent, abandon_dungeon{}, medium{}, Dungeon/Content/ui_game_over_main_menu(), [width_full{}])

def _pause_modal(scene_value: Dungeon/Scene) -> HTML(Dungeon/DungeonEvent):
  <div class={Dungeon/View/selectors/game_over_modal_class(scene_value)}>
    {Midum/Card/neutral(
      Dungeon/DungeonEvent,
      <div class="game-over-card">
        <p class="game-over-card__eyebrow">{text{Dungeon/Content/ui_pause_eyebrow()}}</p>
        <h2 class="game-over-card__title">{text{Dungeon/Content/ui_pause_title()}}</h2>
        <p class="game-over-card__body">{text{Dungeon/Content/ui_pause_body()}}</p>
        <section class="game-over-card__actions">
          <div class="menu-secondary-action game-over-card__secondary">
            {_resume_menu_button()}
          </div>
          <div class="menu-start-action game-over-card__primary">
            {_pause_resume_button()}
          </div>
        </section>
      </div>,
      [padding_md{}]
    )}
  </div>

def _resume_dungeon_button() -> HTML(Dungeon/DungeonEvent):
  Midum/Button/primary(Dungeon/DungeonEvent, resume_dungeon{}, large{}, Dungeon/Content/ui_game_over_resume_dungeon(), [width_full{}])

def _resume_prompt_modal(scene_value: Dungeon/Scene) -> HTML(Dungeon/DungeonEvent):
  <div class={Dungeon/View/selectors/game_over_modal_class(scene_value)}>
    {Midum/Card/neutral(
      Dungeon/DungeonEvent,
      <div class="game-over-card">
        <p class="game-over-card__eyebrow">{text{Dungeon/Content/ui_game_over_resume_eyebrow()}}</p>
        <h2 class="game-over-card__title">{text{Dungeon/Content/ui_game_over_resume_title()}}</h2>
        <p class="game-over-card__body">{text{Dungeon/Content/ui_game_over_resume_body()}}</p>
        <section class="game-over-card__actions">
          <div class="menu-secondary-action game-over-card__secondary">
            {_resume_menu_button()}
          </div>
          <div class="menu-start-action game-over-card__primary">
            {_resume_dungeon_button()}
          </div>
        </section>
      </div>,
      [padding_md{}]
    )}
  </div>

def _game_over_ok_button() -> HTML(Dungeon/DungeonEvent):
  Midum/Button/primary(Dungeon/DungeonEvent, ok{}, medium{}, Dungeon/Content/ui_game_over_ok(), [width_full{}])

def _game_over_modal(scene_value: Dungeon/Scene) -> HTML(Dungeon/DungeonEvent):
  <div class={Dungeon/View/selectors/game_over_modal_class(scene_value)}>
    {Midum/Card/neutral(
      Dungeon/DungeonEvent,
      <div class="game-over-card">
        <p class="game-over-card__eyebrow">{text{Dungeon/Content/ui_game_over_end_eyebrow()}}</p>
        <h2 class="game-over-card__title">{text{Dungeon/Content/ui_game_over_title()}}</h2>
        <div class="game-over-card__action">
          {_game_over_ok_button()}
        </div>
      </div>,
      [padding_md{}]
    )}
  </div>

def _board_modal_layer(scene_value: Dungeon/Scene) -> HTML(Dungeon/DungeonEvent):
  match scene_value:
    case setup{}:
      text{""}
    case character_select{preview_hero}:
      text{""}
    case boosters{reward, reveal_index, return_to}:
      text{""}
    case ultimate_preview{fx}:
      text{""}
    case ultimate_cinematic{run_value, ticks_remaining}:
      text{""}
    case running{run_value}:
      text{""}
    case paused{run_value}:
      Midum/Layout/center(Dungeon/DungeonEvent, _pause_modal(scene_value))
    case resume_prompt{run_value}:
      Midum/Layout/center(Dungeon/DungeonEvent, _resume_prompt_modal(scene_value))
    case game_over{run_value}:
      Midum/Layout/center(Dungeon/DungeonEvent, _game_over_modal(scene_value))
    case deck_list{mode, sleeve_picker}:
      text{""}
    case deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker}:
      text{""}

def _dungeon_tick_active_scene(scene_value: Dungeon/Scene, ui_value: Dungeon/UiState) -> U32:
  match scene_value:
    case ultimate_cinematic{run_value, ticks_remaining}:
      1
    case _:
      Dungeon/App/ui_fx/_dungeon_fx_active(ui_value)

def _dungeon_tick_wrapper(tick_active: U32, body: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
  match tick_active:
    case 0:
      body
    case _:
      <div every_ms={125, damage_tick{}}>
        {body}
      </div>

def _render_dungeon(meta_state: Dungeon/Meta, scene_value: Dungeon/Scene, run_value: Dungeon/Run, ui_value: Dungeon/UiState) -> HTML(Dungeon/DungeonEvent):
  hero_value = Dungeon/hero_helpers/hero_at(config(), Dungeon/profile_helpers/selected_hero(meta_state));
  _dungeon_tick_wrapper(_dungeon_tick_active_scene(scene_value, ui_value),
    <div class="dungeon-scene">
      {_dungeon_shell(
        Midum/Layout/frame(
          Dungeon/DungeonEvent,
          Midum/Layout/overlay(Dungeon/DungeonEvent, [
            Midum/Layout/top(Dungeon/DungeonEvent,
              Midum/Layout/frame(
                Dungeon/DungeonEvent,
                _dungeon_header(meta_state, scene_value, ui_value),
                [width_full{}, height_fit{}, inset_none{}]
              )
            ),
            Midum/Layout/top_right(Dungeon/DungeonEvent,
              _pause_action(scene_value)
            ),
            Midum/Layout/center(Dungeon/DungeonEvent,
              _board_grid(scene_value, run_value, ui_value, hero_value)
            ),
            Midum/Layout/bottom(Dungeon/DungeonEvent,
              _ultimate_action(scene_value)
            ),
            _board_modal_layer(scene_value)
            ]),
            [width_full{}, height_full{}, inset_none{}]
          )
      )}
    </div>
  )
