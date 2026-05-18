def menu_topbar() -> Unit:
  unit{}

import HTML as HTML
import Dungeon as Dungeon

def render(role_class: String, leading: HTML(Dungeon/DungeonEvent), content: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
  <header class={"topbar topbar--menu-ui " ++ role_class}>
    <div class="topbar__slot topbar__slot--leading">
      {leading}
    </div>
    <div class="topbar__content">
      {content}
    </div>
  </header>
