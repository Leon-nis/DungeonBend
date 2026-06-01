def menu() -> Unit:
  unit{}

import HTML as HTML
import Dungeon/game_config as config
import Midum/Text/Align as Align
import Dungeon as Dungeon
import Dungeon/Content as M__Dungeon_Content
import Dungeon/hero_helpers as M__Dungeon_hero_helpers
import Dungeon/hero_presentation as M__Dungeon_hero_presentation
import Dungeon/profile_helpers as M__Dungeon_profile_helpers
import Dungeon/View/selectors as M__Dungeon_View_selectors
import Dungeon/View/assets_and_labels as M__Dungeon_View_assets_and_labels
import Dungeon/View/action_button as M__Dungeon_View_action_button
import Dungeon/View/menu_screen as M__Dungeon_View_menu_screen
import Dungeon/View/menu_topbar as M__Dungeon_View_menu_topbar
import Dungeon/menu_background_animation as M__Dungeon_menu_background_animation
import Dungeon/View/topbar_stats as M__Dungeon_View_topbar_stats
import Dungeon/View/character_roster_card as M__Dungeon_View_character_roster_card
import Midum/Image as M__Midum_Image
import Midum/Layout as M__Midum_Layout
import Midum/Text as M__Midum_Text

def _menu_resources(meta_state: Dungeon/Meta) -> HTML(Dungeon/DungeonEvent):
  <div class="topbar-resource-row">
    {Dungeon/View/topbar_stats/boosters_stat(Dungeon/View/selectors/meta_pack_total(meta_state))}
    {Dungeon/View/topbar_stats/gold_stat(Dungeon/View/selectors/meta_gold(meta_state))}
  </div>

def _header_characters_action() -> HTML(Dungeon/DungeonEvent):
  <div class="menu-club-btn-wrap menu-club-btn-wrap--fit">
    {Dungeon/View/action_button/secondary_fit(Dungeon/DungeonEvent, open_character_select{}, Dungeon/Content/ui_menu_characters(), 1)}
  </div>

def _menu_header(meta_state: Dungeon/Meta) -> HTML(Dungeon/DungeonEvent):
  <div class="menu-home-headers">
    {Dungeon/View/menu_topbar/render("topbar--menu-home topbar--menu-home-desktop", text{""}, _menu_resources(meta_state))}
    {Dungeon/View/menu_topbar/render("topbar--menu-home topbar--menu-home-mobile", _header_characters_action(), _menu_resources(meta_state))}
  </div>

def _menu_background_image_overrides() -> List(Midum/Image/Override):
  [fit_cover{}]

def _menu_background(ui_value: Dungeon/UiState) -> HTML(Dungeon/DungeonEvent):
  match ui_value:
    case ui_state{hp_fx, dmg_fx, impact, damage_overlay, deck_counter_fx, menu_background_state}:
      <div class="menu-home-bg" aria-hidden="true">
        {Midum/Image/animated(Dungeon/DungeonEvent, menu_background_state, Dungeon/menu_background_animation/clip(), "", _menu_background_image_overrides())}
      </div>

def _menu_shell(body: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
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

def _menu_start_button() -> HTML(Dungeon/DungeonEvent):
  <div class="menu-play-btn-wrap menu-play-btn-wrap--full">
    {Dungeon/View/action_button/primary_full(Dungeon/DungeonEvent, start{}, Dungeon/Content/ui_menu_start(), Dungeon/View/selectors/start_enabled(setup{}))}
  </div>

def _menu_boosters_button() -> HTML(Dungeon/DungeonEvent):
  <div class="menu-club-btn-wrap menu-club-btn-wrap--full">
    {Dungeon/View/action_button/secondary_full(Dungeon/DungeonEvent, open_boosters{}, Dungeon/Content/ui_menu_boosters(), 1)}
  </div>

def _menu_deck_button() -> HTML(Dungeon/DungeonEvent):
  <div class="menu-club-btn-wrap menu-club-btn-wrap--full">
    {Dungeon/View/action_button/secondary_full(Dungeon/DungeonEvent, open_deck_list{}, "EDIT DECKS", 1)}
  </div>

def _menu_reset_save_button() -> HTML(Dungeon/DungeonEvent):
  <div class="menu-club-btn-wrap menu-club-btn-wrap--full">
    {Dungeon/View/action_button/secondary_full(Dungeon/DungeonEvent, reset_save{}, "RESET SAVE", 1)}
  </div>

def _menu_actions_layout(meta_state: Dungeon/Meta) -> HTML(Dungeon/DungeonEvent):
  Midum/Layout/frame(
    Dungeon/DungeonEvent,
    <section class="menu-actions">
      <div class="menu-actions__booster">
        {_menu_boosters_button()}
      </div>
      <div class="menu-actions__primary">
        <div class="menu-actions__slot">
          {_menu_deck_button()}
        </div>
        <div class="menu-actions__slot">
          {_menu_start_button()}
        </div>
        <div class="menu-actions__slot">
          {_menu_reset_save_button()}
        </div>
      </div>
    </section>,
    [width_full{}, height_fit{}, inset_none{}]
  )

def _level_star_icon(at_max: U32) -> String:
  match at_max:
    case 0:
      "assets/ui/characters/selection/icon-star-silver.png"
    case _:
      "assets/ui/characters/selection/icon-star-gold.png"

def _level_chip(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  <div class="hero-hud__level-chip">
    <img class="hero-hud__level-image" src={_level_star_icon(Dungeon/View/selectors/hero_at_max_level(hero_value, profile))} alt="" />
    <span class="hero-hud__level-value">{text{Dungeon/View/selectors/hero_menu_level_chip_text(profile)}}</span>
  </div>

def _menu_home_hud(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  <div class="hero-hud hero-hud--menu-home">
    {_level_chip(hero_value, profile)}
    <div class="hero-hud__hp">
      <div class="hero-hud__heart">
        <img class="hero-hud__heart-image" src="assets/ui/characters/selection/icon-heart.png" alt="" />
        <span class="hero-hud__heart-value">{text{Dungeon/View/selectors/hero_menu_max_hp_text(hero_value, profile)}}</span>
      </div>
    </div>
  </div>

def _menu_home_info(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  <div class="menu-home-info">
    <div class="menu-home-info__default menu-home-info__default--hud">
      {_menu_home_hud(hero_value, profile)}
    </div>
    <div class="menu-home-info__change">
      <span class="menu-home-info__change-label">{text{"CHANGE HERO"}}</span>
    </div>
  </div>

def _menu_home_portrait(hero_value: Dungeon/HeroDef) -> HTML(Dungeon/DungeonEvent):
  <div class="menu-hero-panel__portrait">
    <img class="menu-hero-panel__image" src={Dungeon/hero_helpers/hero_sprite(hero_value)} alt={Dungeon/hero_helpers/hero_name(hero_value)} />
  </div>

def _menu_hero_panel_desktop(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  <button class="menu-hero-panel menu-hero-panel--desktop" type="button" on_click={open_character_select{}}>
    {_menu_home_info(hero_value, profile)}
    {_menu_home_portrait(hero_value)}
  </button>

def _menu_hero_panel_mobile(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  <section class="menu-hero-panel menu-hero-panel--mobile">
    {_menu_home_info(hero_value, profile)}
    {_menu_home_portrait(hero_value)}
  </section>

def _menu_upgrade_button() -> HTML(Dungeon/DungeonEvent):
  Dungeon/View/action_button/upgrade_icon_fit(Dungeon/DungeonEvent, open_character_select{}, Dungeon/View/assets_and_labels/_menu_upgrade_icon(), 1)

def _menu_upgrade_overlay(meta_state: Dungeon/Meta, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  match Dungeon/View/selectors/character_upgrade_enabled(meta_state, hero_value, profile):
    case 1:
      <div class="menu-home__upgrade">
        {_menu_upgrade_button()}
      </div>
    case _:
      text{""}

def _menu_home(meta_state: Dungeon/Meta, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  <section class="menu-home">
    <div class="menu-home__hero">
      {_menu_hero_panel_desktop(hero_value, profile)}
      {_menu_hero_panel_mobile(hero_value, profile)}
      {_menu_upgrade_overlay(meta_state, hero_value, profile)}
    </div>
  </section>

def _render_menu(meta_state: Dungeon/Meta, ui_value: Dungeon/UiState) -> HTML(Dungeon/DungeonEvent):
  hero_ref = Dungeon/profile_helpers/selected_hero(meta_state);
  hero_value = Dungeon/hero_helpers/hero_at(config(), hero_ref);
  profile = Dungeon/profile_helpers/active_profile(meta_state);
  <div every_ms={125, damage_tick{}}>
    <div class="menu-home-page">
      {_menu_background(ui_value)}
      <div class="menu-home-page__content">
        {_menu_shell(
          Midum/Layout/frame(
            Dungeon/DungeonEvent,
            <div class="menu-home-scene">
              {Dungeon/View/menu_screen/_menu_screen_frame(
                _menu_header(meta_state),
                <section class="menu-stage menu-stage--home">
                  <div class="menu-stage__content menu-stage__content--home">
                    {_menu_home(meta_state, hero_value, profile)}
                  </div>
                </section>,
                _menu_actions_layout(meta_state)
              )}
            </div>,
            [width_full{}, height_full{}, inset_none{}]
          )
        )}
      </div>
    </div>
  </div>

def _character_select_shell(body: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
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

def _character_back_button() -> HTML(Dungeon/DungeonEvent):
  <div class="menu-club-btn-wrap menu-club-btn-wrap--fit">
    {Dungeon/View/action_button/back_button(Dungeon/DungeonEvent, close_character_select{}, Dungeon/Content/ui_menu_back())}
  </div>

def _character_select_header(meta_state: Dungeon/Meta) -> HTML(Dungeon/DungeonEvent):
  <div class="character-select-headers">
    {Dungeon/View/menu_topbar/render("topbar--character-select topbar--character-select-desktop", _character_back_button(), _menu_resources(meta_state))}
    {Dungeon/View/menu_topbar/render("topbar--character-select topbar--character-select-mobile", text{""}, _menu_resources(meta_state))}
  </div>

def _character_detail_portrait(hero_value: Dungeon/HeroDef) -> HTML(Dungeon/DungeonEvent):
  <div class="character-detail__portrait">
    <img class="character-detail__image" src={Dungeon/hero_helpers/hero_sprite(hero_value)} alt={Dungeon/hero_helpers/hero_name(hero_value)} />
  </div>

def _character_detail_name(hero_value: Dungeon/HeroDef) -> HTML(Dungeon/DungeonEvent):
  <div class="character-detail__name-outline">
    <span class="character-detail__name">{text{Dungeon/hero_helpers/hero_name(hero_value)}}</span>
  </div>

def _character_stats_row(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  <div class="character-detail__stats">
    <div class="character-detail__stat-level">
      {_level_chip(hero_value, profile)}
    </div>
    <div class="character-detail__stat-heart">
      <div class="hero-hud__heart">
        <img class="hero-hud__heart-image" src="assets/ui/characters/selection/icon-heart.png" alt={Dungeon/Content/stat_hp()} />
        <span class="hero-hud__heart-value">{text{Dungeon/View/selectors/hero_menu_max_hp_text(hero_value, profile)}}</span>
      </div>
    </div>
  </div>

def _character_locked_badge(profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      <p class="character-detail__locked">{text{Dungeon/Content/ui_character_locked()}}</p>
    case _:
      text{""}

def _character_locked_slot(profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      <div class="character-detail__lock-slot">
        {_character_locked_badge(profile)}
      </div>
    case _:
      text{""}

def _character_ultimate_block(presentation: Dungeon/HeroPresentation) -> HTML(Dungeon/DungeonEvent):
  <section class="character-ultimate">
    {Midum/Text/label(Dungeon/DungeonEvent, left{}, Dungeon/hero_presentation/hero_presentation_ultimate_title(presentation), [])}
    <div class="character-ultimate__body">
      <img class="character-ultimate__icon" src={Dungeon/hero_presentation/hero_presentation_ultimate_icon(presentation)} alt={Dungeon/hero_presentation/hero_presentation_ultimate_title(presentation)} />
      <div class="character-ultimate__description">
        {Midum/Text/body(Dungeon/DungeonEvent, left{}, Dungeon/hero_presentation/hero_presentation_ultimate_description(presentation), [])}
      </div>
    </div>
  </section>

def _character_ultimate_slot(presentation: Dungeon/HeroPresentation) -> HTML(Dungeon/DungeonEvent):
  <div class="character-detail__ultimate-slot">
    {_character_ultimate_block(presentation)}
  </div>

def _character_upgrade_button(meta_state: Dungeon/Meta, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  <div class="menu-club-btn-wrap menu-club-btn-wrap--fit">
    {Dungeon/View/action_button/upgrade_fit(Dungeon/DungeonEvent, upgrade{}, Dungeon/Content/ui_upgrade_upgrade(), Dungeon/View/selectors/character_upgrade_enabled(meta_state, hero_value, profile))}
  </div>

def _character_upgrade_content(meta_state: Dungeon/Meta, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile, maxed: U32) -> HTML(Dungeon/DungeonEvent):
  match maxed:
    case 0:
      <section class="character-upgrade">
        <div class="character-upgrade__row">
          <div class="character-upgrade__action">
            {_character_upgrade_button(meta_state, hero_value, profile)}
          </div>
          <p class="character-upgrade__price">
            <img class="character-upgrade__price-icon" src={Dungeon/View/assets_and_labels/_gold_icon()} alt={Dungeon/Content/ui_topbar_gold()} />
            <span class="character-upgrade__price-value">{text{Dungeon/View/selectors/character_upgrade_price_text(hero_value, profile)}}</span>
          </p>
        </div>
      </section>
    case _:
      <section class="character-upgrade character-upgrade--max">
        <p class="character-upgrade__max">{text{Dungeon/Content/ui_upgrade_max_level_short()}}</p>
      </section>

def _character_upgrade_slot(meta_state: Dungeon/Meta, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      text{""}
    case _:
      <div class="character-detail__upgrade-slot">
        {_character_upgrade_content(meta_state, hero_value, profile, Dungeon/View/selectors/character_upgrade_maxed(hero_value, profile))}
      </div>

def _character_info_column(meta_state: Dungeon/Meta, preview_hero: U32, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile, presentation: Dungeon/HeroPresentation) -> HTML(Dungeon/DungeonEvent):
  <div class="character-detail__info">
    <div class="character-detail__stack">
      {_character_detail_name(hero_value)}
      {_character_stats_row(hero_value, profile)}
      {_character_locked_slot(profile)}
      {_character_ultimate_slot(presentation)}
      {_character_upgrade_slot(meta_state, hero_value, profile)}
    </div>
  </div>

def _character_detail_panel(meta_state: Dungeon/Meta, preview_hero: U32, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile, presentation: Dungeon/HeroPresentation) -> HTML(Dungeon/DungeonEvent):
  <section class="character-detail">
    <div class="character-detail__layout">
      {_character_detail_portrait(hero_value)}
      {_character_info_column(meta_state, preview_hero, hero_value, profile, presentation)}
    </div>
  </section>

def _character_roster_card_locked_modifier(profile: Dungeon/HeroProfile) -> String:
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      " character-roster-card--locked"
    case _:
      ""

def _character_equipped(meta_state: Dungeon/Meta, hero_ref: U32) -> U32:
  match Dungeon/profile_helpers/selection_confirmed(meta_state):
    case 0:
      0
    case _:
      Dungeon/profile_helpers/selected_hero(meta_state) === hero_ref

def _character_roster_card_selected_state(selected: U32) -> String:
  match selected:
    case 0:
      ""
    case _:
      " character-roster-card--selected"

def _character_roster_card_selected_modifier(meta_state: Dungeon/Meta, hero_ref: U32, profile: Dungeon/HeroProfile) -> String:
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      ""
    case _:
      _character_roster_card_selected_state(_character_equipped(meta_state, hero_ref))

def _character_roster_card_active_modifier(active: U32) -> String:
  match active:
    case 0:
      ""
    case _:
      " character-roster-card--active"

def _character_roster_card_class(meta_state: Dungeon/Meta, preview_hero: U32, hero_ref: U32, profile: Dungeon/HeroProfile) -> String:
  "character-roster-card"
  ++ _character_roster_card_locked_modifier(profile)
  ++ _character_roster_card_selected_modifier(meta_state, hero_ref, profile)
  ++ _character_roster_card_active_modifier(preview_hero === hero_ref)

def _character_roster_card(meta_state: Dungeon/Meta, preview_hero: U32, hero_ref: U32, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  presentation = Dungeon/hero_presentation/hero_presentation_at(hero_ref);
  Dungeon/View/character_roster_card/render(
    _character_roster_card_class(meta_state, preview_hero, hero_ref, profile),
    hero_ref,
    Dungeon/hero_helpers/hero_name(hero_value),
    Dungeon/hero_presentation/hero_presentation_portrait(presentation),
    Dungeon/View/selectors/hero_level_ratio_text(hero_value, profile),
    Dungeon/View/selectors/character_upgrade_enabled(meta_state, hero_value, profile)
  )

def _character_roster_items(meta_state: Dungeon/Meta, preview_hero: U32, hero_ref: U32, count: U32) -> List(HTML(Dungeon/DungeonEvent)):
  match hero_ref < count:
    case 0:
      []
    case _:
      hero_value = Dungeon/hero_helpers/hero_at(config(), hero_ref);
      profile = Dungeon/profile_helpers/profile_for_hero(meta_state, hero_ref);
      _character_roster_card(meta_state, preview_hero, hero_ref, hero_value, profile)<>_character_roster_items(meta_state, preview_hero, hero_ref + 1, count)

def _character_roster(meta_state: Dungeon/Meta, preview_hero: U32) -> HTML(Dungeon/DungeonEvent):
  <section class="character-roster">
    <div class="character-roster__grid">
      {..._character_roster_items(meta_state, preview_hero, 0, Dungeon/hero_helpers/hero_count(config()))}
    </div>
  </section>

def _character_booster_button() -> HTML(Dungeon/DungeonEvent):
  <div class="menu-club-btn-wrap menu-club-btn-wrap--full">
    {Dungeon/View/action_button/secondary_full(Dungeon/DungeonEvent, open_boosters{}, Dungeon/Content/ui_menu_boosters(), 1)}
  </div>

def _character_booster_cta() -> HTML(Dungeon/DungeonEvent):
  <section class="character-boosters">
    <p class="character-boosters__hint">{text{Dungeon/Content/ui_character_booster_hint()}}</p>
    <div class="character-boosters__action">
      {_character_booster_button()}
    </div>
  </section>

def _character_select_content(meta_state: Dungeon/Meta, preview_hero: U32, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile, presentation: Dungeon/HeroPresentation) -> HTML(Dungeon/DungeonEvent):
  <section class="character-select">
    <div class="character-select__main">
      {_character_detail_panel(meta_state, preview_hero, hero_value, profile, presentation)}
    </div>
    <aside class="character-select__side">
      {_character_roster(meta_state, preview_hero)}
      {_character_booster_cta()}
    </aside>
  </section>

def _character_mobile_footer() -> HTML(Dungeon/DungeonEvent):
  <div class="character-select-footer">
    {_character_back_button()}
  </div>

def _render_character_select(meta_state: Dungeon/Meta, preview_hero: U32) -> HTML(Dungeon/DungeonEvent):
  hero_value = Dungeon/hero_helpers/hero_at(config(), preview_hero);
  profile = Dungeon/profile_helpers/profile_for_hero(meta_state, preview_hero);
  presentation = Dungeon/hero_presentation/hero_presentation_at(preview_hero);
  _character_select_shell(
    Midum/Layout/frame(
      Dungeon/DungeonEvent,
      Dungeon/View/menu_screen/_menu_screen_frame(
        _character_select_header(meta_state),
        <section class="character-select-stage">
          <div class="character-select-stage__content">
            {_character_select_content(meta_state, preview_hero, hero_value, profile, presentation)}
          </div>
        </section>,
        _character_mobile_footer()
      ),
      [width_full{}, height_full{}, inset_none{}]
    )
  )

def _character_upgrade_block(meta_state: Dungeon/Meta, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> HTML(Dungeon/DungeonEvent):
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      text{""}
    case _:
      _character_upgrade_content(meta_state, hero_value, profile, Dungeon/View/selectors/character_upgrade_maxed(hero_value, profile))

def _full_button_overrides(enabled: U32) -> List(Midum/Button/Override):
  match enabled:
    case 0:
      [width_full{}, state_disabled{}]
    case _:
      [width_full{}]
