def ultimate_preview() -> Unit:
  unit{}

import HTML as HTML
import Dungeon/UltimateCutins/cutin_spec_for_hero_ref as cutin_spec_for_hero_ref
import Dungeon/UltimateCutins/_render_ultimate_cutin as _render_ultimate_cutin
import Dungeon as Dungeon
import Dungeon/Content as M__Dungeon_Content
import Dungeon/profile_helpers as M__Dungeon_profile_helpers
import Dungeon/View/action_button as M__Dungeon_View_action_button
import Dungeon/View/menu_topbar as M__Dungeon_View_menu_topbar
import Midum/Layout as M__Midum_Layout

def _ultimate_preview_stage_class(fx: Dungeon/UltimatePreviewFx) -> String:
  match fx:
    case ultimate_preview_idle{}:
      "ultimate-cutin-stage--idle"
    case ultimate_preview_play_a{}:
      "ultimate-cutin-stage--play-a"
    case ultimate_preview_play_b{}:
      "ultimate-cutin-stage--play-b"

def _ultimate_preview_back_button() -> HTML(Dungeon/DungeonEvent):
  Dungeon/View/action_button/back_button(Dungeon/DungeonEvent, close_ultimate_preview{}, Dungeon/Content/ui_menu_back())

def _ultimate_preview_play_button() -> HTML(Dungeon/DungeonEvent):
  Dungeon/View/action_button/primary_full(Dungeon/DungeonEvent, play_ultimate_preview{}, "TOCAR ANIMACAO", 1)

def _render_ultimate_preview(meta_state: Dungeon/Meta, fx: Dungeon/UltimatePreviewFx) -> HTML(Dungeon/DungeonEvent):
  spec = cutin_spec_for_hero_ref(Dungeon/profile_helpers/selected_hero(meta_state));
  Midum/Layout/shell(
    Dungeon/DungeonEvent,
    <section class="ultimate-preview-scene">
      {Dungeon/View/menu_topbar/render("topbar--menu ultimate-preview-topbar", _ultimate_preview_back_button(), text{""})}
      <div class="ultimate-preview-content">
        {_render_ultimate_cutin(spec, _ultimate_preview_stage_class(fx))}
      </div>
      <div class="ultimate-preview-footer">
        <div class="menu-start-action ultimate-preview-footer__action">
          {_ultimate_preview_play_button()}
        </div>
      </div>
    </section>,
    [
      height_viewport{},
      overflow_hidden{},
      safe_area{},
      inset_none{}
    ]
  )
