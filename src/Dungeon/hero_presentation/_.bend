def hero_presentation() -> Unit:
  unit{}

import Dungeon/generated_hero_presentation as generated_hero_presentation
import Dungeon as Dungeon

def hero_presentations() -> List(Dungeon/HeroPresentation):
  generated_hero_presentation()

def _hero_presentation_at_from_list(presentations: List(Dungeon/HeroPresentation), hero_ref: U32) -> Dungeon/HeroPresentation:
  match presentations:
    case []:
      hero_presentation{"hero", presentation_center{}, "", "Ultimate", "assets/ui/characters/selection/icon-ultimate.png", ""}
    case hero_presentation{hero_id, name_align, portrait, ultimate_title, ultimate_icon, ultimate_description}<>rest:
      match hero_ref:
        case 0:
          hero_presentation{hero_id, name_align, portrait, ultimate_title, ultimate_icon, ultimate_description}
        case _:
          _hero_presentation_at_from_list(rest, hero_ref - 1)

def hero_presentation_at(hero_ref: U32) -> Dungeon/HeroPresentation:
  _hero_presentation_at_from_list(hero_presentations(), hero_ref)

def hero_presentation_name_align(presentation: Dungeon/HeroPresentation) -> Dungeon/PresentationAlign:
  match presentation:
    case hero_presentation{hero_id, name_align, portrait, ultimate_title, ultimate_icon, ultimate_description}:
      name_align

def hero_presentation_portrait(presentation: Dungeon/HeroPresentation) -> String:
  match presentation:
    case hero_presentation{hero_id, name_align, portrait, ultimate_title, ultimate_icon, ultimate_description}:
      portrait

def hero_presentation_ultimate_title(presentation: Dungeon/HeroPresentation) -> String:
  match presentation:
    case hero_presentation{hero_id, name_align, portrait, ultimate_title, ultimate_icon, ultimate_description}:
      ultimate_title

def hero_presentation_ultimate_icon(presentation: Dungeon/HeroPresentation) -> String:
  match presentation:
    case hero_presentation{hero_id, name_align, portrait, ultimate_title, ultimate_icon, ultimate_description}:
      ultimate_icon

def hero_presentation_ultimate_description(presentation: Dungeon/HeroPresentation) -> String:
  match presentation:
    case hero_presentation{hero_id, name_align, portrait, ultimate_title, ultimate_icon, ultimate_description}:
      ultimate_description
