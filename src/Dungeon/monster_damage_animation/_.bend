def monster_damage_animation() -> Unit:
  unit{}

import Dungeon/monster_damage_frames as M__Dungeon_monster_damage_frames

def clip() -> Midum/Image/Animation:
  animation{
    frames: Dungeon/monster_damage_frames/frames(),
    fps: 8n,
    playback: once_hold_last{},
  }
