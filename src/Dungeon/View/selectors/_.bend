def selectors() -> Unit:
  unit{}

import Dungeon/game_config as config
import Dungeon as Dungeon
import Dungeon/Content as M__Dungeon_Content
import Dungeon/Deck/counts_pick as M__Dungeon_Deck_counts_pick
import Dungeon/profile_helpers as M__Dungeon_profile_helpers
import Dungeon/Boosters/inventory as M__Dungeon_Boosters_inventory
import Dungeon/Boosters/packs as M__Dungeon_Boosters_packs
import Dungeon/Boosters/reward_nav as M__Dungeon_Boosters_reward_nav
import Dungeon/hero_helpers as M__Dungeon_hero_helpers
import Dungeon/rules as M__Dungeon_rules

def meta_gold(meta_state: Dungeon/Meta) -> String:
  U32/show(Dungeon/profile_helpers/meta_gold(meta_state))

def meta_pack_total(meta_state: Dungeon/Meta) -> String:
  U32/show(Dungeon/Boosters/inventory/pack_inventory_total(Dungeon/profile_helpers/meta_pack_inventory(meta_state)))

def hero_level_text(profile: Dungeon/HeroProfile) -> String:
  Dungeon/Content/ui_hero_level_prefix_long() ++ U32/show(Dungeon/profile_helpers/profile_hero_level(profile))

def hero_display_level(profile: Dungeon/HeroProfile) -> String:
  U32/show(Dungeon/profile_helpers/profile_hero_level(profile) + 1)

def hero_menu_level_text(profile: Dungeon/HeroProfile) -> String:
  Dungeon/Content/ui_hero_level_prefix_short() ++ hero_display_level(profile)

def _upgrade_count(upgrades: List(Dungeon/Upgrade)) -> U32:
  match upgrades:
    case []:
      0
    case upgrade{cost, max_hp}<>rest:
      1 + _upgrade_count(rest)

def hero_visible_max_level(hero_value: Dungeon/HeroDef) -> U32:
  1 + _upgrade_count(Dungeon/hero_helpers/hero_upgrades(hero_value))

def _two_digit_value(value: U32) -> String:
  match value < 10:
    case 1:
      "0" ++ U32/show(value)
    case _:
      U32/show(value)

def hero_level_ratio_text(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> String:
  _two_digit_value(Dungeon/profile_helpers/profile_hero_level(profile) + 1) ++ "/" ++ _two_digit_value(hero_visible_max_level(hero_value))

def hero_level_progress_text(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> String:
  Dungeon/Content/ui_hero_level_prefix_short() ++ hero_level_ratio_text(hero_value, profile)

def hero_menu_level_chip_text(profile: Dungeon/HeroProfile) -> String:
  "Lv " ++ _two_digit_value(Dungeon/profile_helpers/profile_hero_level(profile) + 1)

def _hero_at_max_level_flag(equal: U32) -> U32:
  match equal:
    case 0:
      0
    case _:
      1

def hero_at_max_level(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> U32:
  _hero_at_max_level_flag((Dungeon/profile_helpers/profile_hero_level(profile) + 1) === hero_visible_max_level(hero_value))

def hero_base_hp_text(hero_value: Dungeon/HeroDef) -> String:
  U32/show(Dungeon/hero_helpers/hero_base_max_hp(hero_value))

def hero_max_hp_value(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> U32:
  Dungeon/Deck/counts_pick/hero_max_hp(Dungeon/hero_helpers/hero_base_max_hp(hero_value), Dungeon/hero_helpers/hero_upgrades(hero_value), Dungeon/profile_helpers/profile_hero_level(profile))

def hero_menu_max_hp_text(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> String:
  U32/show(hero_max_hp_value(hero_value, profile))

def hero_menu_current_hp_text(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> String:
  hero_menu_max_hp_text(hero_value, profile)

def _run_dungeon_level(run_value: Dungeon/Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      dungeon_level

def _run_dungeon_level_text(run_value: Dungeon/Run) -> String:
  _two_digit_value(_run_dungeon_level(run_value))

def _run_remaining_text(run_value: Dungeon/Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      U32/show(remaining) ++ "/" ++ U32/show(capacity)

def _weapon_value_from_weapon(weapon_value: Dungeon/Weapon) -> String:
  match weapon_value:
    case no_weapon{}:
      Dungeon/Content/ui_hero_unarmed()
    case weapon{ref, dmg}:
      Dungeon/Content/stat_dmg() ++ " " ++ U32/show(dmg)

def _run_weapon_text(run_value: Dungeon/Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      _weapon_value_from_weapon(weapon)

def weapon_value(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case setup{}:
      "--"
    case character_select{preview_hero}:
      "--"
    case boosters{reward, reveal_index, return_to}:
      "--"
    case ultimate_preview{fx}:
      "--"
    case ultimate_cinematic{run_value, ticks_remaining}:
      _run_weapon_text(run_value)
    case running{run_value}:
      _run_weapon_text(run_value)
    case paused{run_value}:
      _run_weapon_text(run_value)
    case resume_prompt{run_value}:
      _run_weapon_text(run_value)
    case game_over{run_value}:
      _run_weapon_text(run_value)
    case deck_list{mode, sleeve_picker}:
      "--"
    case deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker}:
      "--"

def _run_ult_label(run_value: Dungeon/Run) -> String:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      Dungeon/Content/ui_ultimate_label() ++ " " ++ U32/show(ult_charge) ++ "/" ++ U32/show(Dungeon/rules/ultimate_charge_required())

def _run_ult_ready_flag(charge_lt_required: U32) -> U32:
  match charge_lt_required:
    case 0:
      1
    case _:
      0

def _run_ult_ready(run_value: Dungeon/Run) -> U32:
  match run_value:
    case run{dungeon_level, hero_hp, hero_max_hp, hero_index, weapon, board_value, deck_blueprint, draw_counts, remaining, capacity, seed, ult_charge, hero_ref}:
      _run_ult_ready_flag(ult_charge < Dungeon/rules/ultimate_charge_required())

def dungeon_level_value(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case setup{}:
      "--"
    case character_select{preview_hero}:
      "--"
    case boosters{reward, reveal_index, return_to}:
      "--"
    case ultimate_preview{fx}:
      "--"
    case ultimate_cinematic{run_value, ticks_remaining}:
      _run_dungeon_level_text(run_value)
    case running{run_value}:
      _run_dungeon_level_text(run_value)
    case paused{run_value}:
      _run_dungeon_level_text(run_value)
    case resume_prompt{run_value}:
      _run_dungeon_level_text(run_value)
    case game_over{run_value}:
      _run_dungeon_level_text(run_value)
    case deck_list{mode, sleeve_picker}:
      "--"
    case deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker}:
      "--"

def remaining_value(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case setup{}:
      "--/--"
    case character_select{preview_hero}:
      "--/--"
    case boosters{reward, reveal_index, return_to}:
      "--/--"
    case ultimate_preview{fx}:
      "--/--"
    case ultimate_cinematic{run_value, ticks_remaining}:
      _run_remaining_text(run_value)
    case running{run_value}:
      _run_remaining_text(run_value)
    case paused{run_value}:
      _run_remaining_text(run_value)
    case resume_prompt{run_value}:
      _run_remaining_text(run_value)
    case game_over{run_value}:
      _run_remaining_text(run_value)
    case deck_list{mode, sleeve_picker}:
      "--/--"
    case deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker}:
      "--/--"

def ultimate_label(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case setup{}:
      Dungeon/Content/ui_ultimate_label() ++ " 0/" ++ U32/show(Dungeon/rules/ultimate_charge_required())
    case character_select{preview_hero}:
      Dungeon/Content/ui_ultimate_label() ++ " 0/" ++ U32/show(Dungeon/rules/ultimate_charge_required())
    case boosters{reward, reveal_index, return_to}:
      Dungeon/Content/ui_ultimate_label() ++ " 0/" ++ U32/show(Dungeon/rules/ultimate_charge_required())
    case ultimate_preview{fx}:
      Dungeon/Content/ui_ultimate_label() ++ " 0/" ++ U32/show(Dungeon/rules/ultimate_charge_required())
    case ultimate_cinematic{run_value, ticks_remaining}:
      _run_ult_label(run_value)
    case running{run_value}:
      _run_ult_label(run_value)
    case paused{run_value}:
      _run_ult_label(run_value)
    case resume_prompt{run_value}:
      _run_ult_label(run_value)
    case game_over{run_value}:
      _run_ult_label(run_value)
    case deck_list{mode, sleeve_picker}:
      Dungeon/Content/ui_ultimate_label() ++ " 0/" ++ U32/show(Dungeon/rules/ultimate_charge_required())
    case deck_detail{deck_id, draft, picker, detail_mode, sleeve_picker}:
      Dungeon/Content/ui_ultimate_label() ++ " 0/" ++ U32/show(Dungeon/rules/ultimate_charge_required())

def ultimate_enabled(scene_value: Dungeon/Scene) -> U32:
  match scene_value:
    case running{run_value}:
      _run_ult_ready(run_value)
    case _:
      0

def start_enabled(scene_value: Dungeon/Scene) -> U32:
  match scene_value:
    case setup{}:
      1
    case _:
      0

def can_upgrade(scene_value: Dungeon/Scene) -> U32:
  start_enabled(scene_value)

def _can_afford_upgrade_flag(gold_lt_cost: U32) -> U32:
  match gold_lt_cost:
    case 0:
      1
    case _:
      0

def _can_afford_upgrade_gold(gold: U32, cost: U32) -> U32:
  match cost:
    case 0:
      0
    case _:
      _can_afford_upgrade_flag(gold < cost)

def can_afford_upgrade(meta_state: Dungeon/Meta, cost: U32) -> U32:
  _can_afford_upgrade_gold(Dungeon/profile_helpers/meta_gold(meta_state), cost)

def _upgrade_enabled_flag(can_upgrade_value: U32, can_afford_value: U32) -> U32:
  match can_upgrade_value:
    case 0:
      0
    case _:
      can_afford_value

def upgrade_enabled(meta_state: Dungeon/Meta, scene_value: Dungeon/Scene, cost: U32) -> U32:
  _upgrade_enabled_flag(can_upgrade(scene_value), can_afford_upgrade(meta_state, cost))

def _upgrade_cost_or_zero(step: Dungeon/Upgrade) -> U32:
  match step:
    case upgrade{cost, max_hp}:
      match max_hp:
        case 0:
          0
        case _:
          cost

def next_upgrade_cost(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> U32:
  _upgrade_cost_or_zero(Dungeon/Deck/counts_pick/nth_upgrade(Dungeon/hero_helpers/hero_upgrades(hero_value), Dungeon/profile_helpers/profile_hero_level(profile)))

def menu_upgrade_visible(meta_state: Dungeon/Meta, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> U32:
  upgrade_enabled(meta_state, setup{}, next_upgrade_cost(hero_value, profile))

def _upgrade_label_cost(cost: U32) -> String:
  match cost:
    case 0:
      Dungeon/Content/ui_upgrade_max_level()
    case _:
      Dungeon/Content/ui_upgrade_upgrade_prefix() ++ U32/show(cost)

def upgrade_label(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> String:
  _upgrade_label_cost(next_upgrade_cost(hero_value, profile))

def _menu_upgrade_label_cost(cost: U32) -> String:
  match cost:
    case 0:
      Dungeon/Content/ui_upgrade_max_level_short()
    case _:
      Dungeon/Content/ui_upgrade_upgrade()

def menu_upgrade_label(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> String:
  _menu_upgrade_label_cost(next_upgrade_cost(hero_value, profile))

def _menu_upgrade_cost_text(cost: U32) -> String:
  match cost:
    case 0:
      Dungeon/Content/ui_upgrade_max_short()
    case _:
      U32/show(cost)

def menu_upgrade_cost_text(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> String:
  _menu_upgrade_cost_text(next_upgrade_cost(hero_value, profile))

def _unlock_cost_text(cost: U32) -> String:
  U32/show(cost)

def character_upgrade_label(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> String:
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      Dungeon/Content/ui_character_locked()
    case _:
      menu_upgrade_label(hero_value, profile)

def character_upgrade_cost_text(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> String:
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      _unlock_cost_text(Dungeon/hero_helpers/hero_unlock_cost(hero_value))
    case _:
      menu_upgrade_cost_text(hero_value, profile)

def character_upgrade_enabled(meta_state: Dungeon/Meta, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> U32:
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      0
    case _:
      menu_upgrade_visible(meta_state, hero_value, profile)

def _character_upgrade_maxed_cost(cost: U32) -> U32:
  match cost:
    case 0:
      1
    case _:
      0

def character_upgrade_maxed(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> U32:
  _character_upgrade_maxed_cost(next_upgrade_cost(hero_value, profile))

def _character_upgrade_price_text_cost(cost: U32) -> String:
  match cost:
    case 0:
      ""
    case _:
      U32/show(cost)

def character_upgrade_price_text(hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> String:
  _character_upgrade_price_text_cost(next_upgrade_cost(hero_value, profile))

def _character_selected_confirmed(confirmed: U32, same_ref: U32) -> U32:
  match confirmed:
    case 0:
      0
    case _:
      same_ref

def _character_selected(meta_state: Dungeon/Meta, hero_ref: U32) -> U32:
  _character_selected_confirmed(Dungeon/profile_helpers/selection_confirmed(meta_state), Dungeon/profile_helpers/selected_hero(meta_state) === hero_ref)

def _character_select_label(is_selected: U32) -> String:
  match is_selected:
    case 0:
      Dungeon/Content/ui_character_select()
    case _:
      Dungeon/Content/ui_character_selected()

def character_primary_label(meta_state: Dungeon/Meta, hero_ref: U32, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> String:
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      Dungeon/Content/ui_character_buy()
    case _:
      _character_select_label(_character_selected(meta_state, hero_ref))

def _character_select_enabled(is_selected: U32) -> U32:
  match is_selected:
    case 0:
      1
    case _:
      0

def character_primary_enabled(meta_state: Dungeon/Meta, hero_ref: U32, hero_value: Dungeon/HeroDef, profile: Dungeon/HeroProfile) -> U32:
  match Dungeon/profile_helpers/profile_unlocked(profile):
    case 0:
      _can_afford_upgrade_gold(Dungeon/profile_helpers/meta_gold(meta_state), Dungeon/hero_helpers/hero_unlock_cost(hero_value))
    case _:
      _character_select_enabled(_character_selected(meta_state, hero_ref))

def game_over_modal_class(scene_value: Dungeon/Scene) -> String:
  match scene_value:
    case paused{run_value}:
      "game-over-modal game-over-modal--visible"
    case resume_prompt{run_value}:
      "game-over-modal game-over-modal--visible"
    case game_over{run_value}:
      "game-over-modal game-over-modal--visible"
    case _:
      "game-over-modal"

def _pack_name(pack: Dungeon/PackDef) -> String:
  match pack:
    case pack_def{name, price, reveal_count, allow_duplicates, pool}:
      name

def active_pack_name() -> String:
  _pack_name(Dungeon/Boosters/packs/active_pack(config()))

def _pack_price(pack: Dungeon/PackDef) -> U32:
  match pack:
    case pack_def{name, price, reveal_count, allow_duplicates, pool}:
      price

def active_pack_price() -> U32:
  _pack_price(Dungeon/Boosters/packs/active_pack(config()))

def _pack_reveal_count(pack: Dungeon/PackDef) -> String:
  match pack:
    case pack_def{name, price, reveal_count, allow_duplicates, pool}:
      U32/show(reveal_count)

def active_pack_reveal_count() -> String:
  _pack_reveal_count(Dungeon/Boosters/packs/active_pack(config()))

def active_pack_owned(meta_state: Dungeon/Meta) -> U32:
  Dungeon/Boosters/inventory/pack_inventory_count(Dungeon/profile_helpers/meta_pack_inventory(meta_state), 0)

def active_pack_owned_text(meta_state: Dungeon/Meta) -> String:
  U32/show(active_pack_owned(meta_state))

def booster_buy_enabled(meta_state: Dungeon/Meta) -> U32:
  _can_afford_upgrade_gold(Dungeon/profile_helpers/meta_gold(meta_state), active_pack_price())

def _booster_open_enabled(owned: U32) -> U32:
  match owned:
    case 0:
      0
    case _:
      1

def booster_open_enabled(meta_state: Dungeon/Meta) -> U32:
  _booster_open_enabled(active_pack_owned(meta_state))

def booster_prev_enabled(reveal_index: U32) -> U32:
  match reveal_index:
    case 0:
      0
    case _:
      1

def _booster_next_enabled_match(enabled: U32) -> U32:
  match enabled:
    case 0:
      0
    case _:
      1

def _booster_next_enabled(count: U32, reveal_index: U32) -> U32:
  match count:
    case 0:
      0
    case _:
      _booster_next_enabled_match(reveal_index + 1 < count)

def booster_next_enabled(reward: Dungeon/PackReward, reveal_index: U32) -> U32:
  _booster_next_enabled(Dungeon/Boosters/reward_nav/reward_count(reward), reveal_index)

def _booster_reward_position_text(count: U32, reveal_index: U32) -> String:
  match count:
    case 0:
      ""
    case _:
      U32/show(reveal_index + 1) ++ "/" ++ U32/show(count)

def booster_reward_position_text(reward: Dungeon/PackReward, reveal_index: U32) -> String:
  _booster_reward_position_text(Dungeon/Boosters/reward_nav/reward_count(reward), reveal_index)

def _booster_is_last_card(count: U32, reveal_index: U32) -> U32:
  match count:
    case 0:
      1
    case _:
      (reveal_index + 1) === count

def booster_is_last_card(reward: Dungeon/PackReward, reveal_index: U32) -> U32:
  _booster_is_last_card(Dungeon/Boosters/reward_nav/reward_count(reward), reveal_index)

def _full_deck_from_config(config_value: Dungeon/Config, bonus: List(Dungeon/DeckEntry)) -> List(Dungeon/DeckEntry):
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      Dungeon/Deck/counts_pick/merge_deck_entries(deck, bonus)

def _full_deck(meta_state: Dungeon/Meta) -> List(Dungeon/DeckEntry):
  _full_deck_from_config(config(), Dungeon/profile_helpers/meta_bonus_deck(meta_state))

def card_copies(meta_state: Dungeon/Meta, card: Dungeon/CardRef) -> String:
  U32/show(Dungeon/Deck/counts_pick/deck_count_for_card(_full_deck(meta_state), card))
