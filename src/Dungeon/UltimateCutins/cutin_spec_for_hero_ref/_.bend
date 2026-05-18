import String as String
import Dungeon/game_config as config
import Dungeon/UltimateCutins/adventurer as adventurer
import Dungeon/UltimateCutins/gato_de_botas as gato_de_botas
import Dungeon as Dungeon
import Dungeon/hero_helpers as M__Dungeon_hero_helpers

def _cutin_spec_for_hero_id(hero_id_value: String) -> Dungeon/UltimateCutinSpec:
  match String/eq(hero_id_value, "gato_de_botas"):
    case true{}:
      gato_de_botas()
    case false{}:
      adventurer()

def cutin_spec_for_hero_ref(hero_ref: U32) -> Dungeon/UltimateCutinSpec:
  _cutin_spec_for_hero_id(Dungeon/hero_helpers/hero_id(Dungeon/hero_helpers/hero_at(config(), hero_ref)))
