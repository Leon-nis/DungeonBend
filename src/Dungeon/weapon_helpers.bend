import Dungeon/Config as Config
import Dungeon/Weapon as Weapon
import Dungeon/WeaponClass as WeaponClass
import Dungeon/SwordDef as SwordDef
import Dungeon/PassiveDef as PassiveDef
import Dungeon/hero_helpers/hero_at as hero_at
import Dungeon/hero_helpers/hero_passive as hero_passive
import Dungeon/passive_helpers/passive_can_stack_same_class_weapons as passive_can_stack_same_class_weapons

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

def _hero_passive(config_value: Config, hero_ref: U32) -> PassiveDef:
  hero_passive(hero_at(config_value, hero_ref))

def apply_weapon_pickup_rule(config_value: Config, hero_ref: U32, current_weapon: Weapon, sword_ref: U32, dmg: U32) -> Weapon:
  _apply_weapon_pickup_policy(
    passive_can_stack_same_class_weapons(_hero_passive(config_value, hero_ref)),
    current_weapon,
    sword_card_class(config_value, sword_ref),
    dmg
  )

def _apply_weapon_pickup_policy(can_stack_same_class: U32, current_weapon: Weapon, picked_class: WeaponClass, dmg: U32) -> Weapon:
  match current_weapon:
    case no_weapon{}:
      weapon{picked_class, dmg}
    case weapon{current_class, current_dmg}:
      _apply_weapon_pickup_to_equipped(can_stack_same_class, same_weapon_class(current_class, picked_class), current_class, current_dmg, picked_class, dmg)

def _apply_weapon_pickup_to_equipped(can_stack_same_class: U32, same_class: U32, current_class: WeaponClass, current_dmg: U32, picked_class: WeaponClass, picked_dmg: U32) -> Weapon:
  match can_stack_same_class same_class:
    case 1 1:
      weapon{current_class, current_dmg + picked_dmg}
    case _ _:
      _replace_weapon_pickup(picked_class, picked_dmg)

def _replace_weapon_pickup(class_kind: WeaponClass, dmg: U32) -> Weapon:
  weapon{class_kind, dmg}
