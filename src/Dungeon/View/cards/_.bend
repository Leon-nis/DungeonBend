def cards() -> Unit:
  unit{}

import HTML as HTML
import Dungeon as Dungeon
import Dungeon/Content as M__Dungeon_Content
import Dungeon/Board/indexing as M__Dungeon_Board_indexing
import Midum/Card as M__Midum_Card
import Midum/Image as M__Midum_Image
import Dungeon/hero_helpers as M__Dungeon_hero_helpers
import Dungeon/View/assets_and_labels as M__Dungeon_View_assets_and_labels
import Dungeon/monster_damage_animation as M__Dungeon_monster_damage_animation

def _hero_hp_badge_class(hp_fx: Dungeon/HpFx) -> String:
  match hp_fx:
    case hp_fx_heal_a{}:
      "card__badge card__badge--hp card__badge--hp-heal-a"
    case hp_fx_heal_b{}:
      "card__badge card__badge--hp card__badge--hp-heal-b"
    case hp_fx_hurt_a{}:
      "card__badge card__badge--hp card__badge--hp-hurt-a"
    case hp_fx_hurt_b{}:
      "card__badge card__badge--hp card__badge--hp-hurt-b"
    case _:
      "card__badge card__badge--hp"

def _hero_dmg_badge_class(dmg_fx: Dungeon/DmgFx) -> String:
  match dmg_fx:
    case dmg_fx_up_a{}:
      "card__badge card__badge--dmg card__badge--dmg-up-a"
    case dmg_fx_up_b{}:
      "card__badge card__badge--dmg card__badge--dmg-up-b"
    case dmg_fx_down_a{}:
      "card__badge card__badge--dmg card__badge--dmg-down-a"
    case dmg_fx_down_b{}:
      "card__badge card__badge--dmg card__badge--dmg-down-b"
    case _:
      "card__badge card__badge--dmg"

def _hero_dmg_badge_node(weapon_value: Dungeon/Weapon, dmg_fx: Dungeon/DmgFx) -> HTML(Dungeon/DungeonEvent):
  match weapon_value:
    case no_weapon{}:
      text{""}
    case weapon{ref, dmg}:
      <div class={_hero_dmg_badge_class(dmg_fx)}>{text{Dungeon/Content/stat_dmg() ++ " " ++ U32/show(dmg)}}</div>

def _hero_card_values(hero_value: Dungeon/HeroDef, hero_hp: U32, hero_max_hp: U32, weapon_value: Dungeon/Weapon, hp_fx: Dungeon/HpFx, dmg_fx: Dungeon/DmgFx) -> HTML(Dungeon/DungeonEvent):
  Midum/Card/neutral(
    Dungeon/DungeonEvent,
    <div class="card card--hero">
      <div class="card__art-wrap">
        <img class="card__art" src={Dungeon/hero_helpers/hero_sprite(hero_value)} alt={Dungeon/hero_helpers/hero_name(hero_value)} />
      </div>
      <div class="card__info">
        {_hero_dmg_badge_node(weapon_value, dmg_fx)}
        <div class={_hero_hp_badge_class(hp_fx)}>{text{Dungeon/Content/stat_hp() ++ " " ++ U32/show(hero_hp) ++ "/" ++ U32/show(hero_max_hp)}}</div>
      </div>
    </div>,
    [padding_none{}]
  )

def _monster_fx_overrides() -> List(Midum/Image/Override):
  [width_px{value: 112n}, height_px{value: 112n}, fit_contain{}, sampling_pixelated{}]

def _standard_card_shell(body: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
  Midum/Card/neutral(Dungeon/DungeonEvent, body, [padding_none{}])

def _overlay_art_tile(tile: Dungeon/Tile, base_tile: Dungeon/Tile) -> Dungeon/Tile:
  match tile:
    case gold{amount}:
      base_tile
    case _:
      tile

def _art_tile(tile: Dungeon/Tile, pos: Nat/V2, damage_overlay: Dungeon/DamageOverlay) -> Dungeon/Tile:
  match damage_overlay:
    case no_damage_overlay{}:
      tile
    case damage_overlay{overlay_pos, trigger, base_tile, overlay_state}:
      match Dungeon/Board/indexing/same_pos(pos, overlay_pos):
        case 0:
          tile
        case _:
          _overlay_art_tile(tile, base_tile)

def _damage_overlay_layer(pos: Nat/V2, damage_overlay: Dungeon/DamageOverlay) -> HTML(Dungeon/DungeonEvent):
  match damage_overlay:
    case no_damage_overlay{}:
      text{""}
    case damage_overlay{overlay_pos, trigger, base_tile, overlay_state}:
      match Dungeon/Board/indexing/same_pos(pos, overlay_pos):
        case 0:
          text{""}
        case _:
          <div class="card__art-layer card__art-layer--fx">
            {Midum/Image/animated(Dungeon/DungeonEvent, overlay_state, Dungeon/monster_damage_animation/clip(), "", _monster_fx_overrides())}
          </div>

def _tile_badge_value(tile: Dungeon/Tile) -> U32:
  match tile:
    case none{}:
      0
    case monster{ref, hp}:
      hp
    case sword{ref, dmg}:
      dmg
    case potion{ref, heal}:
      heal
    case gold{amount}:
      amount

def _tile_badge_class(tile: Dungeon/Tile) -> String:
  match _tile_badge_value(tile) < 10:
    case 1:
      "card__badge card__badge--value"
    case _:
      "card__badge card__badge--value card__badge--compact"

def _tile_badge_node(tile: Dungeon/Tile) -> HTML(Dungeon/DungeonEvent):
  <div class={_tile_badge_class(tile)}>{text{Dungeon/View/assets_and_labels/_tile_badge(tile)}}</div>

def _tile_card_body(tile: Dungeon/Tile, class_name: String, pos: Nat/V2, damage_overlay: Dungeon/DamageOverlay) -> HTML(Dungeon/DungeonEvent):
  art_tile = _art_tile(tile, pos, damage_overlay);
  <div class={class_name}>
    <div class="card__art-wrap card__art-wrap--stacked">
      {_damage_overlay_layer(pos, damage_overlay)}
      <div class="card__art-layer card__art-layer--base">
        <img class="card__art" src={Dungeon/View/assets_and_labels/_tile_sprite(art_tile)} alt={Dungeon/View/assets_and_labels/_tile_name(art_tile)} />
      </div>
    </div>
    <div class="card__info">
      {_tile_badge_node(tile)}
    </div>
  </div>

def _standard_tile_card(tile: Dungeon/Tile, class_name: String, pos: Nat/V2, damage_overlay: Dungeon/DamageOverlay) -> HTML(Dungeon/DungeonEvent):
  _standard_card_shell(_tile_card_body(tile, class_name, pos, damage_overlay))

def _tile_card(tile: Dungeon/Tile, pos: Nat/V2, damage_overlay: Dungeon/DamageOverlay) -> HTML(Dungeon/DungeonEvent):
  match tile:
    case none{}:
      Midum/Card/neutral(
        Dungeon/DungeonEvent,
        <div class="card card--empty">
          <div class="card__empty">{text{Dungeon/Content/card_empty()}}</div>
        </div>,
        [padding_none{}]
      )
    case monster{ref, hp}:
      _standard_tile_card(monster{ref, hp}, "card card--tile card--monster", pos, damage_overlay)
    case sword{ref, dmg}:
      _standard_tile_card(sword{ref, dmg}, "card card--tile card--sword", pos, damage_overlay)
    case potion{ref, heal}:
      _standard_tile_card(potion{ref, heal}, "card card--tile card--potion", pos, damage_overlay)
    case gold{amount}:
      _standard_tile_card(gold{amount}, "card card--tile card--gold", pos, damage_overlay)
