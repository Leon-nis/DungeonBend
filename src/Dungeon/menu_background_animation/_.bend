def menu_background_animation() -> Unit:
  unit{}

import Dungeon/menu_background_frames as M__Dungeon_menu_background_frames

def clip() -> Midum/Image/Animation:
  animation{
    frames: Dungeon/menu_background_frames/frames(),
    fps: 8n,
    playback: loop{},
  }
