import Dungeon/Config as Config
import Dungeon/Weapon as Weapon
import Dungeon/WeaponClass as WeaponClass
import Dungeon/SwordDef as SwordDef

def weapon_class_label(class_kind: WeaponClass) -> String:
  match class_kind:
    case weapon_sword{}:
      "sword"
    case weapon_axe{}:
      "axe"
    case weapon_bow{}:
      "bow"

def same_weapon_class(left: WeaponClass, right: WeaponClass) -> U32:
  match left right:
    case weapon_sword{} weapon_sword{}:
      1
    case weapon_axe{} weapon_axe{}:
      1
    case weapon_bow{} weapon_bow{}:
      1
    case _ _:
      0

def sword_card_class(config_value: Config, ref: U32) -> WeaponClass:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _sword_card_class_from_list(swords, ref)

def _sword_card_class_from_list(swords: List(SwordDef), ref: U32) -> WeaponClass:
  match swords:
    case []:
      weapon_sword{}
    case sword_def{name, sprite, rarity, class_kind, dmg}<>rest:
      match ref:
        case 0:
          class_kind
        case _:
          _sword_card_class_from_list(rest, ref - 1)

# Central pickup hook. Current behavior is still replace-on-pickup.
def apply_weapon_pickup_rule(config_value: Config, current_weapon: Weapon, sword_ref: U32, dmg: U32) -> Weapon:
  _replace_weapon_pickup(current_weapon, sword_card_class(config_value, sword_ref), dmg)

def _replace_weapon_pickup(current_weapon: Weapon, class_kind: WeaponClass, dmg: U32) -> Weapon:
  weapon{class_kind, dmg}
