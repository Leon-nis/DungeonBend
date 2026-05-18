def topbar_stats() -> Unit:
  unit{}

import HTML as HTML
import Dungeon as Dungeon
import Dungeon/Content as M__Dungeon_Content
import Dungeon/View/assets_and_labels as M__Dungeon_View_assets_and_labels

def gold_stat(value: String) -> HTML(Dungeon/DungeonEvent):
  <p class="topbar-resource topbar-resource--gold">
    <img class="topbar-resource__icon" src={Dungeon/View/assets_and_labels/_gold_icon()} alt={Dungeon/Content/ui_topbar_gold()} />
    <strong class="topbar-resource__value">{text{value}}</strong>
  </p>

def boosters_stat(value: String) -> HTML(Dungeon/DungeonEvent):
  <p class="topbar-resource topbar-resource--boosters">
    <img class="topbar-resource__icon" src={Dungeon/View/assets_and_labels/_boosters_icon()} alt={Dungeon/Content/ui_topbar_boosters()} />
    <strong class="topbar-resource__value">{text{value}}</strong>
  </p>

def stat(label: String, value: String) -> HTML(Dungeon/DungeonEvent):
  <p class="topbar-stat">
    <span class="topbar-stat__label">{text{label}}</span>
    <strong class="topbar-stat__value">{text{value}}</strong>
  </p>
