def deck_chrome() -> Unit:
  unit{}

import HTML as HTML
import Dungeon as Dungeon
import Dungeon/View/menu_screen as M__Dungeon_View_menu_screen
import Dungeon/View/menu_topbar as M__Dungeon_View_menu_topbar
import Dungeon/View/action_button as M__Dungeon_View_action_button

def _back_button(back_event: Dungeon/DungeonEvent) -> HTML(Dungeon/DungeonEvent):
  <div class="menu-club-btn-wrap menu-club-btn-wrap--fit">
    {Dungeon/View/action_button/back_button(Dungeon/DungeonEvent, back_event, "BACK")}
  </div>

def _chrome_header(back_event: Dungeon/DungeonEvent, trailing: HTML(Dungeon/DungeonEvent), mobile_title: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
  <div class="deck-chrome-headers">
    {Dungeon/View/menu_topbar/render("topbar--deck-chrome topbar--deck-chrome-desktop", _back_button(back_event), trailing)}
    {Dungeon/View/menu_topbar/render("topbar--deck-chrome topbar--deck-chrome-mobile", text{""}, mobile_title)}
  </div>

def _wrap_action(node: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
  <div class="deck-chrome-footer__action">{node}</div>

def _wrap_actions(actions: List(HTML(Dungeon/DungeonEvent))) -> List(HTML(Dungeon/DungeonEvent)):
  match actions:
    case []:
      []
    case head<>rest:
      _wrap_action(head)<>_wrap_actions(rest)

def _chrome_footer(back_event: Dungeon/DungeonEvent, actions: List(HTML(Dungeon/DungeonEvent))) -> HTML(Dungeon/DungeonEvent):
  <div class="deck-chrome-footer">
    <div class="deck-chrome-footer__back">
      {_back_button(back_event)}
    </div>
    {..._wrap_actions(actions)}
  </div>

def render(desktop_back: Dungeon/DungeonEvent, mobile_back: Dungeon/DungeonEvent, trailing: HTML(Dungeon/DungeonEvent), mobile_title: HTML(Dungeon/DungeonEvent), actions: List(HTML(Dungeon/DungeonEvent)), body: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
  Dungeon/View/menu_screen/_menu_screen_frame(_chrome_header(desktop_back, trailing, mobile_title), body, _chrome_footer(mobile_back, actions))
