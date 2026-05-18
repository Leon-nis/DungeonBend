def deck_sleeve_picker() -> Unit:
  unit{}

import HTML as HTML
import Dungeon as Dungeon
import Dungeon/Deck/sleeves as M__Dungeon_Deck_sleeves

def _tone_class(sleeve: Dungeon/DeckSleeve) -> String:
  match sleeve:
    case sleeve_blue{}:
      "deck-sleeve-dot--blue"
    case sleeve_chromatic{}:
      "deck-sleeve-dot--chromatic"

def _option_class(sleeve: Dungeon/DeckSleeve, selected: U32) -> String:
  match selected:
    case 0:
      "deck-sleeve-dot deck-sleeve-dot--option " ++ _tone_class(sleeve)
    case _:
      "deck-sleeve-dot deck-sleeve-dot--option deck-sleeve-dot--selected " ++ _tone_class(sleeve)

def _option(deck_id: U32, current: Dungeon/DeckSleeve, sleeve: Dungeon/DeckSleeve) -> HTML(Dungeon/DungeonEvent):
  <button class={_option_class(sleeve, Dungeon/Deck/sleeves/sleeve_eq(current, sleeve))} type="button" on_click={set_deck_sleeve{deck_id, sleeve}}></button>

def _render_menu(deck_id: U32, current: Dungeon/DeckSleeve, is_open: U32, menu_class: String) -> HTML(Dungeon/DungeonEvent):
  match is_open:
    case 0:
      text{""}
    case _:
      <div class="deck-sleeve-picker__layer">
        <button class="deck-sleeve-picker__backdrop" type="button" on_click={close_deck_sleeve_picker{}}></button>
        <div class={menu_class}>
          {_option(deck_id, current, sleeve_blue{})}
          {_option(deck_id, current, sleeve_chromatic{})}
        </div>
      </div>

def _trigger_class(sleeve: Dungeon/DeckSleeve) -> String:
  "deck-sleeve-dot deck-sleeve-dot--trigger " ++ _tone_class(sleeve)

def _render_control(deck_id: U32, sleeve: Dungeon/DeckSleeve, is_open: U32, wrapper_class: String, menu_class: String) -> HTML(Dungeon/DungeonEvent):
  <div class={wrapper_class}>
    <button class={_trigger_class(sleeve)} type="button" on_click={toggle_deck_sleeve_picker{deck_id}}></button>
    {_render_menu(deck_id, sleeve, is_open, menu_class)}
  </div>

def render_card_control(deck_id: U32, sleeve: Dungeon/DeckSleeve, is_open: U32) -> HTML(Dungeon/DungeonEvent):
  _render_control(deck_id, sleeve, is_open, "deck-sleeve-picker deck-sleeve-picker--card", "deck-sleeve-picker__menu deck-sleeve-picker__menu--card")

def render_detail_control(deck_id: U32, sleeve: Dungeon/DeckSleeve, is_open: U32) -> HTML(Dungeon/DungeonEvent):
  _render_control(deck_id, sleeve, is_open, "deck-sleeve-picker deck-sleeve-picker--detail", "deck-sleeve-picker__menu deck-sleeve-picker__menu--detail")
