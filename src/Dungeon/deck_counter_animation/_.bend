def deck_counter_animation() -> Unit:
  unit{}

import Dungeon/deck_counter_frames as M__Dungeon_deck_counter_frames

def clip() -> Midum/Image/Animation:
  animation{
    frames: Dungeon/deck_counter_frames/frames(),
    fps: 8n,
    playback: once_hold_last{},
  }
