import Dungeon/game_config as config
import Dungeon/default_ui as default_ui
import Dungeon as Dungeon
import Dungeon/App/state_helpers as M__Dungeon_App_state_helpers
import Dungeon/Boosters/inventory as M__Dungeon_Boosters_inventory
import Dungeon/Boosters/packs as M__Dungeon_Boosters_packs
import Dungeon/Boosters/reveal as M__Dungeon_Boosters_reveal
import Dungeon/Boosters/collection as M__Dungeon_Boosters_collection
import Dungeon/Boosters/reward_nav as M__Dungeon_Boosters_reward_nav
import Dungeon/profile_helpers as M__Dungeon_profile_helpers

def _return_scene(return_to: Dungeon/BoosterReturn) -> Dungeon/Scene:
  match return_to:
    case booster_return_setup{}:
      setup{}
    case booster_return_character_select{preview_hero}:
      character_select{preview_hero}

def _buy_pack_affordable(gold_lt_price: U32, meta_state: Dungeon/Meta, ref: U32, price: U32) -> Dungeon/Meta:
  match gold_lt_price:
    case 0:
      Dungeon/profile_helpers/set_meta_pack_inventory(
        Dungeon/profile_helpers/set_meta_gold(meta_state, Dungeon/profile_helpers/meta_gold(meta_state) - price),
        Dungeon/Boosters/inventory/add_pack(Dungeon/profile_helpers/meta_pack_inventory(meta_state), ref)
      )
    case _:
      meta_state

def _buy_pack_meta(meta_state: Dungeon/Meta, ref: U32, pack: Dungeon/PackDef) -> Dungeon/Meta:
  match pack:
    case pack_def{name, price, reveal_count, allow_duplicates, pool}:
      _buy_pack_affordable(Dungeon/profile_helpers/meta_gold(meta_state) < price, meta_state, ref, price)

def _buy_pack_state(config_value: Dungeon/Config, meta_state: Dungeon/Meta, reward: Dungeon/PackReward, reveal_index: U32, return_to: Dungeon/BoosterReturn, ref: U32, next_seed_value: U32) -> Dungeon/DungeonState:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      Dungeon/App/state_helpers/_state(_buy_pack_meta(meta_state, ref, Dungeon/Boosters/packs/pack_at(booster_packs, ref)), boosters{reward, reveal_index, return_to}, next_seed_value, default_ui())

def _open_pack_result(meta_state: Dungeon/Meta, ref: U32, return_to: Dungeon/BoosterReturn, result: Dungeon/PackOpenResult) -> Dungeon/DungeonState:
  match result:
    case pack_open_result{reward, next_seed}:
      next_bonus = Dungeon/Boosters/collection/bonus_deck_after_reward(Dungeon/profile_helpers/meta_bonus_deck(meta_state), reward);
      next_inventory = Dungeon/Boosters/inventory/consume_pack(Dungeon/profile_helpers/meta_pack_inventory(meta_state), ref);
      Dungeon/App/state_helpers/_state(Dungeon/profile_helpers/set_meta_pack_inventory(Dungeon/profile_helpers/set_meta_bonus_deck(meta_state, next_bonus), next_inventory), boosters{reward, 0, return_to}, next_seed, default_ui())

def _open_pack_inventory(meta_state: Dungeon/Meta, inventory_count: U32, ref: U32, pack: Dungeon/PackDef, current_reward: Dungeon/PackReward, return_to: Dungeon/BoosterReturn, next_seed_value: U32) -> Dungeon/DungeonState:
  match inventory_count:
    case 0:
      Dungeon/App/state_helpers/_state(meta_state, boosters{current_reward, 0, return_to}, next_seed_value, default_ui())
    case _:
      _open_pack_result(meta_state, ref, return_to, Dungeon/Boosters/reveal/open_pack(pack, next_seed_value))

def _open_pack_state(config_value: Dungeon/Config, meta_state: Dungeon/Meta, current_reward: Dungeon/PackReward, return_to: Dungeon/BoosterReturn, ref: U32, next_seed_value: U32) -> Dungeon/DungeonState:
  match config_value:
    case config{heroes, monsters, swords, potions, deck, booster_packs, starting_dungeon_level}:
      _open_pack_inventory(
        meta_state,
        Dungeon/Boosters/inventory/pack_inventory_count(Dungeon/profile_helpers/meta_pack_inventory(meta_state), ref),
        ref,
        Dungeon/Boosters/packs/pack_at(booster_packs, ref),
        current_reward,
        return_to,
        next_seed_value
      )

def update_boosters(evt: Dungeon/DungeonEvent, meta_state: Dungeon/Meta, reward: Dungeon/PackReward, reveal_index: U32, return_to: Dungeon/BoosterReturn, next_seed_value: U32, ui_value: Dungeon/UiState) -> Dungeon/DungeonState:
  match evt:
    case close_boosters{}:
      Dungeon/App/state_helpers/_state(meta_state, _return_scene(return_to), next_seed_value, default_ui())
    case buy_pack{ref}:
      _buy_pack_state(config(), meta_state, reward, reveal_index, return_to, ref, next_seed_value)
    case open_pack{ref}:
      _open_pack_state(config(), meta_state, reward, return_to, ref, next_seed_value)
    case prev_reward{}:
      Dungeon/App/state_helpers/_state(meta_state, boosters{reward, Dungeon/Boosters/reward_nav/prev_reward_index(reveal_index), return_to}, next_seed_value, ui_value)
    case next_reward{}:
      Dungeon/App/state_helpers/_state(meta_state, boosters{reward, Dungeon/Boosters/reward_nav/next_reward_index(reward, reveal_index), return_to}, next_seed_value, ui_value)
    case done_reward{}:
      Dungeon/App/state_helpers/_state(meta_state, boosters{no_pack_reward{}, 0, return_to}, next_seed_value, default_ui())
    case _:
      Dungeon/App/state_helpers/_state(meta_state, boosters{reward, reveal_index, return_to}, next_seed_value, ui_value)
