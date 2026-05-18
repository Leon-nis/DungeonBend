def boosters() -> Unit:
  unit{}

import HTML as HTML
import Dungeon/game_config as config
import Dungeon as Dungeon
import Dungeon/Content as M__Dungeon_Content
import Dungeon/Boosters/packs as M__Dungeon_Boosters_packs
import Dungeon/View/selectors as M__Dungeon_View_selectors
import Dungeon/View/action_button as M__Dungeon_View_action_button
import Dungeon/View/menu_screen as M__Dungeon_View_menu_screen
import Dungeon/View/menu_topbar as M__Dungeon_View_menu_topbar
import Dungeon/View/assets_and_labels as M__Dungeon_View_assets_and_labels
import Dungeon/View/topbar_stats as M__Dungeon_View_topbar_stats
import Midum/Card as M__Midum_Card
import Midum/Layout as M__Midum_Layout

type RevealTier {
  tier_common{}
  tier_uncommon{}
  tier_rare{}
  tier_epic{}
  tier_legendary{}
}

def _boosters_shell(body: HTML(Dungeon/DungeonEvent)) -> HTML(Dungeon/DungeonEvent):
  Midum/Layout/shell(
    Dungeon/DungeonEvent,
    body,
    [
      max_width_px{value: 1080n},
      height_viewport{},
      overflow_hidden{},
      safe_area{},
      inset_px{top: 24n, right: 14n, bottom: 20n, left: 14n},
      compact_inset_px{top: 20n, right: 12n, bottom: 18n, left: 12n}
    ]
  )

def _booster_pack_visual() -> HTML(Dungeon/DungeonEvent):
  <div class="booster-visual booster-visual--pack">
    <img class="booster-visual__pack-img" src="assets/booster-pack.png" alt={Dungeon/Content/ui_booster_pack_alt()} />
  </div>

def _boosters_resources(meta_state: Dungeon/Meta) -> HTML(Dungeon/DungeonEvent):
  <div class="topbar-resource-row">
    {Dungeon/View/topbar_stats/boosters_stat(Dungeon/View/selectors/meta_pack_total(meta_state))}
    {Dungeon/View/topbar_stats/gold_stat(Dungeon/View/selectors/meta_gold(meta_state))}
  </div>

def _back_button() -> HTML(Dungeon/DungeonEvent):
  Dungeon/View/action_button/back_button(Dungeon/DungeonEvent, close_boosters{}, Dungeon/Content/ui_booster_back())

def _boosters_header(meta_state: Dungeon/Meta) -> HTML(Dungeon/DungeonEvent):
  Dungeon/View/menu_topbar/render("topbar--boosters", _back_button(), _boosters_resources(meta_state))

def _booster_actions(meta_state: Dungeon/Meta) -> HTML(Dungeon/DungeonEvent):
  match Dungeon/View/selectors/booster_open_enabled(meta_state):
    case 1:
      <section class="boosters-actions">
        <div class="boosters-actions__inner">
          {Midum/Layout/group(
            Dungeon/DungeonEvent,
            [
              Dungeon/View/action_button/secondary_full(Dungeon/DungeonEvent, buy_pack{0}, Dungeon/Content/ui_booster_buy_more_prefix() ++ U32/show(Dungeon/View/selectors/active_pack_price()) ++ Dungeon/Content/ui_booster_currency_suffix(), Dungeon/View/selectors/booster_buy_enabled(meta_state)),
              Dungeon/View/action_button/primary_full(Dungeon/DungeonEvent, open_pack{0}, Dungeon/Content/ui_booster_open(), 1)
            ],
            [direction_column{}, gap_sm{}, align_stretch{}]
          )}
        </div>
      </section>
    case _:
      <section class="boosters-actions">
        <div class="boosters-actions__inner">
          {Midum/Layout/group(
            Dungeon/DungeonEvent,
            [
              Dungeon/View/action_button/primary_full(Dungeon/DungeonEvent, buy_pack{0}, Dungeon/Content/ui_booster_buy_prefix() ++ U32/show(Dungeon/View/selectors/active_pack_price()) ++ Dungeon/Content/ui_booster_currency_suffix(), Dungeon/View/selectors/booster_buy_enabled(meta_state))
            ],
            [direction_column{}, gap_sm{}, align_stretch{}]
          )}
        </div>
      </section>

def _render_boosters_idle(meta_state: Dungeon/Meta) -> HTML(Dungeon/DungeonEvent):
  _boosters_shell(
    Midum/Layout/frame(
      Dungeon/DungeonEvent,
      Dungeon/View/menu_screen/_menu_screen_frame(
        _boosters_header(meta_state),
        <section class="boosters-stage">
          <div class="boosters-stage__content">
            {_booster_pack_visual()}
          </div>
        </section>,
        _booster_actions(meta_state)
      ),
      [width_full{}, height_full{}, inset_none{}]
    )
  )

def _reveal_stat_left(card: Dungeon/CardRef) -> HTML(Dungeon/DungeonEvent):
  match card:
    case hero_card{}:
      <span class="reveal-stat--empty"></span>
    case _:
      <p class="reveal-stat reveal-stat--detail">{text{Dungeon/View/assets_and_labels/_card_stat_range(card)}}</p>

def _reveal_meta(meta_state: Dungeon/Meta, card: Dungeon/CardRef) -> HTML(Dungeon/DungeonEvent):
  <div class="reveal-meta">
    <div class="reveal-meta__top">
      <p class="reveal-name">{text{Dungeon/View/assets_and_labels/_card_name(card)}}</p>
      <p class="reveal-copies">{text{Dungeon/Content/ui_booster_copies_prefix() ++ Dungeon/View/selectors/card_copies(meta_state, card)}}</p>
    </div>
    {_reveal_stat_left(card)}
  </div>

def _reveal_card_surface_overrides() -> List(Midum/Card/Override):
  [
    padding_none{},
    background_none{},
    border_none{},
    radius_square{}
  ]

def _pool_total_weight(pool: List(Dungeon/PackPoolEntry)) -> U32:
  match pool:
    case []:
      0
    case pack_pool_entry{entry_card, weight}<>rest:
      weight + _pool_total_weight(rest)

def _card_ref_eq(left: Dungeon/CardRef, right: Dungeon/CardRef) -> U32:
  match left right:
    case hero_card{} hero_card{}:
      1
    case monster_card{left_ref} monster_card{right_ref}:
      left_ref === right_ref
    case sword_card{left_ref} sword_card{right_ref}:
      left_ref === right_ref
    case potion_card{left_ref} potion_card{right_ref}:
      left_ref === right_ref
    case _ _:
      0

def _pool_weight_for_card(pool: List(Dungeon/PackPoolEntry), target_card: Dungeon/CardRef) -> U32:
  match pool:
    case []:
      0
    case pack_pool_entry{entry_card, weight}<>rest:
      match _card_ref_eq(entry_card, target_card):
        case 1:
          weight + _pool_weight_for_card(rest, target_card)
        case _:
          _pool_weight_for_card(rest, target_card)

def _tier_for_pool_share(card: Dungeon/CardRef, pool: List(Dungeon/PackPoolEntry)) -> RevealTier:
  total = _pool_total_weight(pool);
  weighted = _pool_weight_for_card(pool, card) * 100;
  match total:
    case 0:
      tier_common{}
    case _:
      match weighted <= (total * 2):
        case 1:
          tier_legendary{}
        case _:
          match weighted <= (total * 5):
            case 1:
              tier_epic{}
            case _:
              match weighted <= (total * 12):
                case 1:
                  tier_rare{}
                case _:
                  match weighted <= (total * 25):
                    case 1:
                      tier_uncommon{}
                    case _:
                      tier_common{}

def _tier_for_weight_share(card: Dungeon/CardRef, pack: Dungeon/PackDef) -> RevealTier:
  match pack:
    case pack_def{name, price, reveal_count, allow_duplicates, pool}:
      _tier_for_pool_share(card, pool)

def _reveal_card_tier(card: Dungeon/CardRef) -> RevealTier:
  _tier_for_weight_share(card, Dungeon/Boosters/packs/active_pack(config()))

def _reveal_card_background(tier: RevealTier) -> String:
  match tier:
    case tier_common{}:
      "assets/ui/boosters/card-frame/common-bg.png"
    case tier_uncommon{}:
      "assets/ui/boosters/card-frame/uncommon-bg.png"
    case tier_rare{}:
      "assets/ui/boosters/card-frame/rare-bg.png"
    case tier_epic{}:
      "assets/ui/boosters/card-frame/epic-bg.png"
    case tier_legendary{}:
      "assets/ui/boosters/card-frame/legendary-bg.png"

def _reveal_card_border(tier: RevealTier) -> String:
  match tier:
    case tier_common{}:
      "assets/ui/boosters/card-frame/common-border.png"
    case tier_uncommon{}:
      "assets/ui/boosters/card-frame/uncommon-border.png"
    case tier_rare{}:
      "assets/ui/boosters/card-frame/rare-border.png"
    case tier_epic{}:
      "assets/ui/boosters/card-frame/epic-border.png"
    case tier_legendary{}:
      "assets/ui/boosters/card-frame/legendary-border.png"

def _reveal_card(card: Dungeon/CardRef) -> HTML(Dungeon/DungeonEvent):
  tier = _reveal_card_tier(card);
  <div class="booster-visual booster-visual--revealed booster-visual--midum">
    {Midum/Card/neutral(
      Dungeon/DungeonEvent,
      <div class="booster-visual__detail booster-visual__detail--midum">
        <div class="booster-visual__frame">
          <img class="booster-visual__frame-bg" src={_reveal_card_background(tier)} alt="" aria-hidden="true" />
          <img class="booster-visual__image booster-visual__image--midum" src={Dungeon/View/assets_and_labels/_card_sprite(card)} alt={Dungeon/View/assets_and_labels/_card_name(card)} />
          <img class="booster-visual__frame-border" src={_reveal_card_border(tier)} alt="" aria-hidden="true" />
        </div>
      </div>,
      _reveal_card_surface_overrides()
    )}
  </div>

def _reveal_action_button(reward: Dungeon/PackReward, reveal_index: U32) -> HTML(Dungeon/DungeonEvent):
  match Dungeon/View/selectors/booster_is_last_card(reward, reveal_index):
    case 1:
      Dungeon/View/action_button/secondary_full(Dungeon/DungeonEvent, done_reward{}, Dungeon/Content/ui_booster_done(), 1)
    case _:
      Dungeon/View/action_button/secondary_full(Dungeon/DungeonEvent, next_reward{}, Dungeon/Content/ui_booster_next(), 1)

def _booster_reveal_panel(meta_state: Dungeon/Meta, card: Dungeon/CardRef, reward: Dungeon/PackReward, reveal_index: U32) -> HTML(Dungeon/DungeonEvent):
  <div class="booster-reveal-panel">
    <div class="booster-reveal-panel__visual">
      {_reveal_card(card)}
    </div>
    <div class="booster-reveal-panel__meta">
      {_reveal_meta(meta_state, card)}
    </div>
    <div class="booster-reveal-panel__footer">
      <div class="booster-reveal-panel__action">
        {_reveal_action_button(reward, reveal_index)}
      </div>
    </div>
  </div>

def _card_at(cards: List(Dungeon/CardRef), idx: U32) -> Dungeon/CardRef:
  match cards:
    case []:
      hero_card{}
    case card<>rest:
      match idx:
        case 0:
          card
        case _:
          _card_at(rest, idx - 1)

def _reward_card_at(reward: Dungeon/PackReward, idx: U32) -> Dungeon/CardRef:
  match reward:
    case no_pack_reward{}:
      hero_card{}
    case pack_reward{cards}:
      _card_at(cards, idx)

def _render_boosters_reveal(meta_state: Dungeon/Meta, reward: Dungeon/PackReward, reveal_index: U32) -> HTML(Dungeon/DungeonEvent):
  card = _reward_card_at(reward, reveal_index);
  _boosters_shell(
    Midum/Layout/frame(
      Dungeon/DungeonEvent,
      Midum/Layout/overlay(Dungeon/DungeonEvent, [
        Midum/Layout/center(Dungeon/DungeonEvent,
          _booster_reveal_panel(meta_state, card, reward, reveal_index)
        )
      ]),
      [width_full{}, height_full{}, inset_none{}]
    )
  )

def _render_boosters(meta_state: Dungeon/Meta, reward: Dungeon/PackReward, reveal_index: U32) -> HTML(Dungeon/DungeonEvent):
  match reward:
    case no_pack_reward{}:
      _render_boosters_idle(meta_state)
    case pack_reward{cards}:
      _render_boosters_reveal(meta_state, pack_reward{cards}, reveal_index)
