import HTML as HTML
import Dungeon/Meta as Meta
import Dungeon/Run as Run
import Dungeon/RunStats as RunStats
import Dungeon/DungeonEvent as DungeonEvent
import Dungeon/config as config
import Dungeon/hero_helpers/hero_at as hero_at
import Dungeon/hero_helpers/hero_name as hero_name
import Dungeon/hero_helpers/hero_sprite as hero_sprite
import Dungeon/run_report_helpers/run_report_average_level_text as run_report_average_level_text
import Dungeon/run_report_helpers/run_report_stats as run_report_stats
import Dungeon/View/menu_screen/_menu_screen_frame as _menu_screen_frame
import Midum/Button/primary as button_primary
import Midum/Card/neutral as card_neutral
import Midum/Layout/frame as layout_frame
import Midum/Layout/shell as layout_shell
import Midum/Text/body as text_body
import Midum/Text/h2 as text_h2
import Midum/Text/label as text_label
import Midum/Text/Align as Align

def _run_hero_ref(run_value: Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon_value, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref, ultimate_state, stats}:
      hero_ref

def _report_shell(body: HTML(DungeonEvent)) -> HTML(DungeonEvent):
  layout_shell(
    DungeonEvent,
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

def _report_header(run_value: Run) -> HTML(DungeonEvent):
  hero_value = hero_at(config(), _run_hero_ref(run_value));
  <header class="run-report-header">
    <div class="run-report-header__copy">
      {text_label(DungeonEvent, left{}, "Run Report", [])}
      {text_h2(DungeonEvent, left{}, hero_name(hero_value), [])}
      {text_body(DungeonEvent, left{}, "Summary captured at the end of the run.", [])}
    </div>
    <div class="run-report-header__portrait">
      <img class="run-report-header__image" src={hero_sprite(hero_value)} alt={hero_name(hero_value)} />
    </div>
  </header>

def _report_metric(label: String, value: String) -> HTML(DungeonEvent):
  <div class="run-report-metric">
    <p class="run-report-metric__label">{text{label}}</p>
    <strong class="run-report-metric__value">{text{value}}</strong>
  </div>

def _report_metrics(stats: RunStats, average_level_text: String) -> HTML(DungeonEvent):
  match stats:
    case run_stats{gold_collected, items_collected, weapon_damage_gained, potion_heal_effective, monsters_defeated, damage_dealt, monster_level_sum, monster_level_count, path_center, path_edge, path_corner}:
      <section class="run-report-metrics">
        {_report_metric("Gold collected", U32/show(gold_collected))}
        {_report_metric("Items collected", U32/show(items_collected))}
        {_report_metric("Weapon damage gained", U32/show(weapon_damage_gained))}
        {_report_metric("Potion heal received", U32/show(potion_heal_effective))}
        {_report_metric("Monsters defeated", U32/show(monsters_defeated))}
        {_report_metric("Total damage dealt", U32/show(damage_dealt))}
        {_report_metric("Avg. monster level", average_level_text)}
        {_report_metric("Center pathing (5)", U32/show(path_center))}
        {_report_metric("Edge pathing (2,4,6,8)", U32/show(path_edge))}
        {_report_metric("Corner pathing (1,3,7,9)", U32/show(path_corner))}
      </section>

def _report_body(run_value: Run) -> HTML(DungeonEvent):
  stats = run_report_stats(run_value);
  average_level_text = run_report_average_level_text(run_value);
  card_neutral(
    DungeonEvent,
    <div class="run-report-card">
      {_report_header(run_value)}
      {_report_metrics(stats, average_level_text)}
    </div>,
    [padding_none{}]
  )

def _report_footer() -> HTML(DungeonEvent):
  <div class="run-report-footer">
    <div class="run-report-footer__action">
      {button_primary(DungeonEvent, ok{}, large{}, "OK", [width_full{}])}
    </div>
  </div>

def _render_run_report(meta_state: Meta, run_value: Run) -> HTML(DungeonEvent):
  <div class="run-report-page">
    {_report_shell(
      layout_frame(
        DungeonEvent,
        <div class="run-report-scene">
          {_menu_screen_frame(
            text{""},
            <section class="run-report-stage">
              <div class="run-report-stage__content">
                {_report_body(run_value)}
              </div>
            </section>,
            _report_footer()
          )}
        </div>,
        [width_full{}, height_full{}, inset_none{}]
      )
    )}
  </div>
