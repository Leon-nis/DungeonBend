def deck_card_tile() -> Unit:
  unit{}

import HTML as HTML
import Dungeon as Dungeon
import Dungeon/View/assets_and_labels as M__Dungeon_View_assets_and_labels

def _count_badge(label: String) -> HTML(Dungeon/DungeonEvent):
  match String/eq(label, ""):
    case true{}:
      text{""}
    case false{}:
      <span class="deck-tile__badge">{text{label}}</span>

def render_tile(card: Dungeon/CardRef, modifier: String, count_label: String, click: Dungeon/DungeonEvent) -> HTML(Dungeon/DungeonEvent):
  <button class={"deck-tile" ++ modifier} type="button" on_click={click}>
    <span class="deck-tile__art-wrap">
      <img class="deck-tile__art" src={Dungeon/View/assets_and_labels/_card_sprite(card)} alt={Dungeon/View/assets_and_labels/_card_name(card)} />
    </span>
    {_count_badge(count_label)}
  </button>

def render_tile_static(card: Dungeon/CardRef, modifier: String, count_label: String) -> HTML(Dungeon/DungeonEvent):
  <div class={"deck-tile deck-tile--static" ++ modifier}>
    <span class="deck-tile__art-wrap">
      <img class="deck-tile__art" src={Dungeon/View/assets_and_labels/_card_sprite(card)} alt={Dungeon/View/assets_and_labels/_card_name(card)} />
    </span>
    {_count_badge(count_label)}
  </div>

def render_empty(click: Dungeon/DungeonEvent, modifier: String) -> HTML(Dungeon/DungeonEvent):
  <button class={"deck-tile deck-tile--empty" ++ modifier} type="button" on_click={click}>
    <span class="deck-tile__plus">+</span>
  </button>

def render_empty_static() -> HTML(Dungeon/DungeonEvent):
  <div class="deck-tile deck-tile--empty deck-tile--static">
    <span class="deck-tile__plus">+</span>
  </div>
