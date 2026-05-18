def frame() -> Unit:
  unit{}

import HTML as HTML
import Dungeon/App/key_event as key_event
import Dungeon/UltimateCutins/cutin_spec_for_hero_ref as cutin_spec_for_hero_ref
import Dungeon/UltimateCutins/_render_ultimate_cutin as _render_ultimate_cutin
import Dungeon as Dungeon
import Dungeon/View/assets_and_labels as M__Dungeon_View_assets_and_labels
import Dungeon/View/menu as M__Dungeon_View_menu
import Dungeon/View/boosters as M__Dungeon_View_boosters
import Dungeon/View/ultimate_preview as M__Dungeon_View_ultimate_preview
import Dungeon/View/board as M__Dungeon_View_board
import Dungeon/View/deck_list as M__Dungeon_View_deck_list
import Dungeon/View/deck_detail as M__Dungeon_View_deck_detail
import Midum as M__Midum

def _focus_keeper_script() -> String:
  "(function(){
    if (window.__dungeonFocusKeeperInstalled) return;
    window.__dungeonFocusKeeperInstalled = true;
    function focusPage(){
      var active = document.activeElement;
      if (active && /^(INPUT|TEXTAREA|SELECT)$/.test(active.tagName)) return;
      var page = document.querySelector('.page');
      if (page && document.activeElement !== page) {
        page.focus({preventScroll:true});
      }
    }
    window.addEventListener('pointerup', function(){
      setTimeout(focusPage, 0);
    }, true);
  })();"

def _frame(body: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
  Midum/screen(
    Dungeon/DungeonEvent,
    <div class="page" tabindex="0" autofocus="autofocus" style="outline:none" on_key_down={key_event}>
      <script>{text{_focus_keeper_script()}}</script>
      <link rel="stylesheet" href="assets/generated/dungeon-view.css" />
      <img
        class="page-preload-image"
        src={Dungeon/View/assets_and_labels/_dungeon_bg()}
        alt=""
        aria-hidden="true"
        loading="eager"
        decoding="async"
        fetchpriority="high"
      />
      {body}
    </div>
  )

def _run_hero_ref(run_value: Dungeon/Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      hero_ref

def _render_ultimate_cinematic_overlay(run_value: Dungeon/Run) -> HTML(Dungeon/DungeonEvent):
  <div class="ultimate-cinematic-overlay" aria-hidden="true">
    {_render_ultimate_cutin(cutin_spec_for_hero_ref(_run_hero_ref(run_value)), "ultimate-cutin-stage--play-a")}
  </div>

def _render_ultimate_cinematic_scene(meta_state: Dungeon/Meta, run_value: Dungeon/Run, ticks_remaining: U32, ui_value: Dungeon/UiState) -> HTML(Dungeon/DungeonEvent):
  <div class="Midum/screen-root-stack">
    {Dungeon/View/board/_render_dungeon(meta_state, ultimate_cinematic{run_value, ticks_remaining}, run_value, ui_value)}
    {_render_ultimate_cinematic_overlay(run_value)}
  </div>

def _screen_root(meta_state: Dungeon/Meta, scene_value: Dungeon/Scene, ui_value: Dungeon/UiState) -> HTML(Dungeon/DungeonEvent):
  match scene_value:
    case setup{}:
      Dungeon/View/menu/_render_menu(meta_state, ui_value)
    case character_select{preview_hero}:
      Dungeon/View/menu/_render_character_select(meta_state, preview_hero)
    case boosters{reward, reveal_index, return_to}:
      Dungeon/View/boosters/_render_boosters(meta_state, reward, reveal_index)
    case ultimate_preview{fx}:
      Dungeon/View/ultimate_preview/_render_ultimate_preview(meta_state, fx)
    case ultimate_cinematic{run_value, ticks_remaining}:
      _render_ultimate_cinematic_scene(meta_state, run_value, ticks_remaining, ui_value)
    case running{run_value}:
      Dungeon/View/board/_render_dungeon(meta_state, running{run_value}, run_value, ui_value)
    case paused{run_value}:
      Dungeon/View/board/_render_dungeon(meta_state, paused{run_value}, run_value, ui_value)
    case resume_prompt{run_value}:
      Dungeon/View/board/_render_dungeon(meta_state, resume_prompt{run_value}, run_value, ui_value)
    case game_over{run_value}:
      Dungeon/View/board/_render_dungeon(meta_state, game_over{run_value}, run_value, ui_value)
    case deck_list{mode, sleeve_picker}:
      Dungeon/View/deck_list/_render_deck_list(meta_state, mode, sleeve_picker)
    case deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker}:
      Dungeon/View/deck_detail/_render_deck_detail(meta_state, deck_id, draft, picker, detail_mode, sleeve_picker)
