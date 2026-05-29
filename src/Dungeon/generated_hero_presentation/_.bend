import Dungeon as Dungeon
import List/append as append

def generated_hero_presentation_items_chunk_0() -> List(Dungeon/HeroPresentation):
  [
    hero_presentation{"adventurer", presentation_center{}, "assets/player-boy.png", "Ultimate", "assets/item-sword.png", "Refills the dungeon with new cards while keeping the hero in place."},
    hero_presentation{"gato_de_botas", presentation_center{}, "assets/player-gato-de-botas.png", "Ultimate", "assets/item-sword.png", "Refills the dungeon with new cards while keeping the hero in place."}
  ]

def generated_hero_presentation() -> List(Dungeon/HeroPresentation):
  generated_hero_presentation_items_chunk_0()
