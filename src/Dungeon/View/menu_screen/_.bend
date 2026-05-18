def menu_screen() -> Unit:
  unit{}

import HTML as HTML
import Dungeon as Dungeon

def _menu_screen_frame(header: HTML(Dungeon/DungeonEvent), body: HTML(Dungeon/DungeonEvent), footer: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
  <section class="menu-screen">
    <div class="menu-screen__header">
      {header}
    </div>
    <div class="menu-screen__body">
      {body}
    </div>
    <div class="menu-screen__footer">
      {footer}
    </div>
  </section>
